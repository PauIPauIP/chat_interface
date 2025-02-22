import 'dart:async';

import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/controller/conversation/message_provider.dart';
import 'package:chat_interface/controller/current/connection_controller.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/chat/components/library/library_window.dart';
import 'package:chat_interface/pages/chat/messages/message_formatter.dart';
import 'package:chat_interface/pages/status/error/offline_hider.dart';
import 'package:chat_interface/theme/components/file_renderer.dart';
import 'package:chat_interface/theme/ui/dialogs/upgrade_window.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/web.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:pasteboard/pasteboard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

import '../../../theme/components/forms/icon_button.dart';
import '../../../util/vertical_spacing.dart';

import 'package:path/path.dart' as path;

class MessageInput extends StatefulWidget {
  final String draft;
  final MessageProvider provider;
  final bool secondary;
  final bool rectangle;

  const MessageInput({
    super.key,
    required this.draft,
    required this.provider,
    this.secondary = false,
    this.rectangle = false,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final FormattedTextEditingController _message = FormattedTextEditingController(Get.theme.textTheme.labelLarge!, Get.theme.textTheme.bodyLarge!);
  final loading = false.obs;
  final FocusNode _inputFocus = FocusNode();
  StreamSubscription<Conversation>? _sub;
  final GlobalKey _libraryKey = GlobalKey();
  // final GlobalKey _emojiKey = GlobalKey();
  final _emojiSuggestions = <Emoji>[].obs;

  // For a little hack to prevent the answers from disappearing instantly
  LPHAddress? _previousAccount;

  @override
  void dispose() {
    _message.dispose();
    _sub?.cancel();
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MessageInput oldWidget) {
    // Load the draft of the current conversation in case the widget was updated
    loadDraft(widget.draft);
    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();

    // Clear message input when conversation changes and change to current draft
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loadDraft(widget.draft);
    });

    _message.addListener(() {
      _emojiSuggestions.clear();

      // Search for emojis
      final regex = RegExp(":(.*?)\\s|:(.*\$)|");
      final cursorPos = _message.selection.start;
      for (var match in regex.allMatches(_message.text)) {
        // Check if the cursor is inside of the current emoji
        if (match.start < cursorPos && match.end >= cursorPos) {
          final query = _message.text.substring(match.start + 1, cursorPos);
          if (query.length >= 2) {
            sendLog("current emoji query: $query");
            _emojiSuggestions.value = UnicodeEmojis.search(query, limit: 20);
          }
        }
      }
    });
  }

  void loadDraft(String newDraft) {
    if (MessageSendHelper.currentDraft.value != null) {
      MessageSendHelper.drafts[MessageSendHelper.currentDraft.value!.target] = MessageSendHelper.currentDraft.value!;
    }
    MessageSendHelper.currentDraft.value = MessageSendHelper.drafts[newDraft] ?? MessageDraft(newDraft, "");
    _message.text = MessageSendHelper.currentDraft.value!.message;
    if (!isMobileMode()) {
      _inputFocus.requestFocus();
    }
  }

  void resetCurrentDraft() {
    if (MessageSendHelper.currentDraft.value != null) {
      MessageSendHelper.drafts[MessageSendHelper.currentDraft.value!.target] = MessageDraft(MessageSendHelper.currentDraft.value!.target, "");
      MessageSendHelper.currentDraft.value = MessageDraft(MessageSendHelper.currentDraft.value!.target, "");
      _message.clear();
    }
    loading.value = false;
  }

  /// Replace the current selection with a new text
  void replaceSelection(String replacer) {
    // Compute the new offset before the text is changed
    final beforeLeft =
        _message.selection.baseOffset > _message.selection.extentOffset ? _message.selection.baseOffset : _message.selection.extentOffset;
    final newOffset = beforeLeft - (_message.selection.end - _message.selection.start) + replacer.length;

    // Change the text in the field to include the pasted text
    _message.text =
        _message.text.substring(0, _message.selection.start) + replacer + _message.text.substring(_message.selection.end, _message.text.length);

    // Change the selection to the calculated offset
    _message.selection = _message.selection.copyWith(
      baseOffset: newOffset,
      extentOffset: newOffset,
    );
  }

  /// Replace the emoji selector in the input with an emoji
  void doEmojiSuggestion(String emoji) {
    // Search for emojis
    final regex = RegExp(":(.*?)\\s|:(.*\$)|");
    final cursorPos = _message.selection.start;
    for (var match in regex.allMatches(_message.text)) {
      // Check if the cursor is inside of the current emoji
      if (match.start < cursorPos && match.end >= cursorPos) {
        final query = _message.text.substring(match.start + 1, cursorPos);
        if (query.length >= 2) {
          _emojiSuggestions.value = UnicodeEmojis.search(query, limit: 20);
          _message.text = "${_message.text.substring(0, match.start)}$emoji ${_message.text.substring(cursorPos, _message.text.length)}";
          _emojiSuggestions.clear();
          _inputFocus.requestFocus();
          // Change the selection to the calculated offset
          final newOffset = cursorPos - query.length + 3;
          _message.selection = _message.selection.copyWith(
            baseOffset: newOffset,
            extentOffset: newOffset,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);

    // All actions that can be performed using shortcuts in the input field-
    final actionsMap = {
      SendIntent: CallbackAction<SendIntent>(
        onInvoke: (SendIntent intent) async {
          // Check if there is a connection before doing this
          if (!Get.find<ConnectionController>().connected.value) {
            showErrorPopup("error", "error.no_connection".tr);
            return;
          }

          // Do emoji suggestion instead when pressing enter
          if (_emojiSuggestions.isNotEmpty) {
            doEmojiSuggestion(_emojiSuggestions[0].emoji);
            return;
          }

          // Send a regular text message if there are no files to attach
          if (MessageSendHelper.currentDraft.value!.files.isEmpty) {
            final error = await widget.provider.sendMessage(
              loading,
              MessageType.text,
              [],
              _message.text,
              MessageSendHelper.currentDraft.value!.answer.value?.id ?? "",
            );
            if (error != null) {
              showErrorPopup("error", error);
            } else {
              resetCurrentDraft();
            }
            return;
          }

          if (MessageSendHelper.currentDraft.value!.files.length > 5) {
            return;
          }

          // Send a regular text message with files
          final error = await widget.provider.sendTextMessageWithFiles(
            loading,
            _message.text,
            MessageSendHelper.currentDraft.value!.files,
            MessageSendHelper.currentDraft.value!.answer.value?.id ?? "",
          );
          if (error != null) {
            showErrorPopup("error", error);
          } else {
            resetCurrentDraft();
          }
          return null;
        },
      ),

      // For support to paste files
      PasteIntent: CallbackAction<PasteIntent>(
        onInvoke: (PasteIntent intent) async {
          final files = await Pasteboard.files();
          final image = await Pasteboard.image; // Assumption is that this will always return a png
          final data = await Clipboard.getData(Clipboard.kTextPlain);

          // When nothing is copied
          if (data == null && image == null && files.isEmpty) {
            return;
          }

          // Check if files are in the clipboard
          if (files.isNotEmpty) {
            for (var path in files) {
              await MessageSendHelper.addFile(XFile(path));
            }
            return;
          }

          // Check if an image is copied
          if (image != null) {
            final tempPath = await getTemporaryDirectory();

            // Save the file
            final filePath = path.join(tempPath.path, "pasted_image_${getRandomString(5)}.png");
            final tempFile = XFile(filePath, bytes: image);
            await tempFile.saveTo(filePath);
            MessageSendHelper.currentDraft.value!.files.add(UploadData(tempFile));
            return;
          }

          // Compute the new offset before the text is changed
          replaceSelection(data!.text!);
          return null;
        },
      ),
    };

    // Build actual widget
    final double padding = widget.rectangle
        ? 0
        : isMobileMode()
            ? defaultSpacing
            : sectionSpacing;
    return Padding(
      padding: EdgeInsets.only(right: padding, left: padding, bottom: padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //* Input
          Actions(
            actions: actionsMap,
            child: Material(
              color: widget.secondary ? theme.colorScheme.inverseSurface : theme.colorScheme.onInverseSurface,
              borderRadius: BorderRadius.circular(defaultSpacing * (widget.rectangle ? 0 : 1.5)),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultSpacing,
                  vertical: elementSpacing,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //* Reply preview
                    Obx(
                      () {
                        final answer = MessageSendHelper.currentDraft.value?.answer.value;
                        if (answer != null) {
                          _previousAccount = answer.senderAddress;
                        }

                        return Animate(
                          effects: [
                            ExpandEffect(
                              duration: 300.ms,
                              curve: Curves.easeInOut,
                              axis: Axis.vertical,
                              alignment: Alignment.center,
                            ),
                            FadeEffect(
                              duration: 300.ms,
                            )
                          ],
                          target: MessageSendHelper.currentDraft.value == null || answer == null ? 0 : 1,
                          child: Padding(
                            padding: const EdgeInsets.all(elementSpacing),
                            child: Row(
                              children: [
                                Icon(Icons.reply, color: theme.colorScheme.tertiary),
                                horizontalSpacing(defaultSpacing),
                                Expanded(
                                  child: Text(
                                    "message.reply.text".trParams({
                                      "name": _previousAccount == null
                                          ? "tf"
                                          : Get.find<FriendController>().friends[_previousAccount]?.name ?? Friend.unknown(_previousAccount!).name,
                                    }),
                                    style: theme.textTheme.labelMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                LoadingIconButton(
                                  iconSize: 22,
                                  extra: 4,
                                  padding: 4,
                                  onTap: () {
                                    MessageSendHelper.currentDraft.value!.answer.value = null;
                                  },
                                  icon: Icons.close,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    //* Emoji suggestions
                    Obx(
                      () {
                        if (_emojiSuggestions.isEmpty) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.all(elementSpacing),
                          child: ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var emoji in _emojiSuggestions)
                                    Padding(
                                      padding: const EdgeInsets.only(right: elementSpacing),
                                      child: Tooltip(
                                        key: ValueKey(emoji.shortName),
                                        exitDuration: 0.ms,
                                        message: ":${emoji.shortName}:",
                                        child: Center(
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(1000),
                                            onTap: () {
                                              doEmojiSuggestion(emoji.emoji);
                                            },
                                            child: Text(
                                              emoji.emoji,
                                              style: Get.theme.textTheme.titleLarge!.copyWith(/* fontFamily: "Emoji", */ fontSize: 30),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    //* File preview
                    Obx(
                      () {
                        if (MessageSendHelper.currentDraft.value == null) {
                          return const SizedBox();
                        }
                        return Animate(
                          effects: [
                            ExpandEffect(
                              duration: 250.ms,
                              curve: Curves.easeInOut,
                              axis: Axis.vertical,
                            )
                          ],
                          target: MessageSendHelper.currentDraft.value!.files.isEmpty ? 0 : 1,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: defaultSpacing * 0.5),
                            child: Row(
                              children: [
                                const SizedBox(height: 200 + defaultSpacing),
                                for (final file in MessageSendHelper.currentDraft.value!.files)
                                  SquareFileRenderer(
                                    file: file,
                                    onRemove: () => MessageSendHelper.currentDraft.value!.files.remove(file),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    //* Input
                    Row(
                      children: [
                        //* Attach a file
                        IconButton(
                          onPressed: () async {
                            if (isWeb) {
                              unawaited(Get.dialog(UpgradeWindow()));
                              return;
                            }

                            if (MessageSendHelper.currentDraft.value!.files.length == 5) {
                              showErrorPopup("error", "file.too_many".tr);
                              return;
                            }
                            final result = await openFile();
                            if (result == null) {
                              return;
                            }
                            await MessageSendHelper.addFile(result);
                          },
                          icon: const Icon(Icons.add),
                          color: theme.colorScheme.tertiary,
                          tooltip: "chat.add_file".tr,
                        ),
                        //* Attach from the library
                        horizontalSpacing(defaultSpacing),
                        Expanded(
                          child: FocusableActionDetector(
                            autofocus: !isMobileMode(),
                            actions: actionsMap,
                            shortcuts: {
                              LogicalKeySet(LogicalKeyboardKey.enter): const SendIntent(),
                              LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV): const PasteIntent(),
                            },
                            descendantsAreTraversable: false,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxHeight: Get.height * 0.5),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'chat.message'.tr,
                                  hintStyle: theme.textTheme.bodyLarge,
                                ),
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(1000),
                                ],
                                focusNode: _inputFocus,
                                onChanged: (value) {
                                  MessageSendHelper.currentDraft.value!.message = value;
                                },
                                onAppPrivateCommand: (action, data) {
                                  sendLog("app private command");
                                },
                                onTapOutside: (event) {
                                  _inputFocus.unfocus();
                                },
                                cursorColor: theme.colorScheme.tertiary,
                                style: theme.textTheme.labelLarge,
                                controller: _message,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          key: _libraryKey,
                          onPressed: () => showModal(
                            LibraryWindow(
                              data: ContextMenuData.fromKey(_libraryKey, above: true, right: true),
                              provider: widget.provider,
                            ),
                          ),
                          icon: const Icon(Icons.folder),
                          color: theme.colorScheme.tertiary,
                        ),
                        OfflineHider(
                          axis: Axis.horizontal,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.only(left: elementSpacing),
                          child: LoadingIconButton(
                            onTap: () => {},
                            onTapContext: (context) {
                              Actions.invoke(context, const SendIntent());
                            },
                            icon: Icons.send,
                            color: theme.colorScheme.tertiary,
                            loading: loading,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SendIntent extends Intent {
  const SendIntent();
}

class PasteIntent extends Intent {
  const PasteIntent();
}
