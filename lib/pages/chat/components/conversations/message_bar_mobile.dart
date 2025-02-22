import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_info_mobile.dart';
import 'package:chat_interface/pages/chat/components/conversations/conversation_members_page.dart';
import 'package:chat_interface/theme/components/forms/icon_button.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MobileMessageBar extends StatefulWidget {
  final Conversation conversation;

  const MobileMessageBar({super.key, required this.conversation});

  @override
  State<MobileMessageBar> createState() => _MessageBarState();
}

class _MessageBarState extends State<MobileMessageBar> {
  final callLoading = false.obs;

  @override
  Widget build(BuildContext context) {
    if (widget.conversation.borked) {
      return Material(
        color: Get.theme.colorScheme.onInverseSurface,
        child: Padding(
          padding: const EdgeInsets.all(defaultSpacing),
          child: Row(
            children: [
              Icon(Icons.person_off, size: 30, color: Theme.of(context).colorScheme.error),
              horizontalSpacing(defaultSpacing),
              Text("friend.removed".tr, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
        ),
      );
    }

    return Material(
      color: Get.theme.colorScheme.onInverseSurface,
      child: InkWell(
        onTap: () => Get.to(ConversationMembersPage(
          conversation: widget.conversation,
        )),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: elementSpacing),
          child: Row(
            children: [
              //* Back button
              LoadingIconButton(
                icon: Icons.arrow_back,
                iconSize: 27,
                loading: callLoading,
                onTap: () => Get.back(),
              ),

              //* Conversation label
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.conversation.isGroup ? Icons.group : Icons.person, size: 30, color: Theme.of(context).colorScheme.onPrimary),
                      horizontalSpacing(elementSpacing),
                      Flexible(
                        child: Text(
                          widget.conversation.isGroup ? widget.conversation.containerSub.value.name : widget.conversation.dmName,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick actions button
              LoadingIconButton(
                icon: Icons.more_vert,
                iconSize: 27,
                loading: callLoading,
                onTap: () => showModal(ConversationInfoMobile(
                  conversation: widget.conversation,
                  position: const ContextMenuData(Offset(0, 0), false, false),
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
