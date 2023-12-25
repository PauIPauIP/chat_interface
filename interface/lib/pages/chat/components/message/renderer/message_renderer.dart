
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/message_controller.dart';
import 'package:chat_interface/pages/chat/components/message/renderer/attachment_renderer.dart';
import 'package:chat_interface/theme/components/user_renderer.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessageRenderer extends StatefulWidget {

  final String accountId;
  final Message message;
  final bool self;
  final bool last;
  final Friend? sender;

  const MessageRenderer({super.key, required this.message, required this.accountId, this.self = false, this.last = false, this.sender});

  @override
  State<MessageRenderer> createState() => _MessageRendererState();
}

class _MessageRendererState extends State<MessageRenderer> {

  final hovering = false.obs;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    Friend sender = widget.sender ?? Friend.unknown(widget.accountId);
    ThemeData theme = Theme.of(context);
    widget.message.initAttachments();

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(top: !widget.last ? defaultSpacing : 0),
        child: MouseRegion(
          onEnter: (e) => hovering.value = true,
          onExit: (e) => hovering.value = false,
          child: Obx(() => 
            Container(
              color: hovering.value ? Get.theme.hoverColor : Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: elementSpacing,
                  horizontal: sectionSpacing,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  
                    //* Avatar
                    Visibility(
                      visible: !widget.last,
                      replacement: const SizedBox(width: 50), //* Show timestamp instead
                      child: UserAvatar(id: sender.id, size: 50),
                    ),
                    horizontalSpacing(sectionSpacing),
                  
                    //* Message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                    
                          //* Message info
                          Visibility(
                            visible: !widget.last,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SelectionContainer.disabled(
                                  child: Text(
                                    sender.name, 
                                    style: theme.textTheme.titleLarge,
                                  )
                                ),
                                horizontalSpacing(defaultSpacing),
                                SelectionContainer.disabled(
                                  child: Text(
                                    formatTime(widget.message.createdAt),
                                    style: theme.textTheme.bodyMedium,
                                  )
                                ),
                              ],
                            ),
                          ),
                    
                          //* Content
                          Visibility(
                            visible: widget.message.content.isNotEmpty,
                            child: Text(widget.message.content, style: theme.textTheme.bodyLarge)
                          ),
                  
                          //* Attachments
                          SelectionContainer.disabled(
                            child: Obx(() {
                              final renderer = widget.message.attachmentsRenderer;
                              return Visibility(
                                visible: widget.message.attachmentsRenderer.isNotEmpty,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: elementSpacing),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: renderer.map((e) => AttachmentRenderer(container: e)).toList(),
                                  ),
                                ),
                              );
                            }),
                          ), 
                        ],
                      ),
                    ),
                  
                    horizontalSpacing(defaultSpacing),
                  
                    Obx(() =>
                      Visibility(
                        visible: !widget.message.verified.value,
                        child: Tooltip(
                          message: "chat.not.signed".tr,
                          child: const Icon(
                            Icons.warning_rounded,
                            color: Colors.amber,
                          ),
                        ),
                      )
                    )
                  ],
                ),
              ),
            )
          ),
        ),
      ),
    );
  }
}