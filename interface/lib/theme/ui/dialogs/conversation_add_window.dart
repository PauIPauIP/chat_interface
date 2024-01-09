
import 'package:chat_interface/controller/account/friend_controller.dart';
import 'package:chat_interface/controller/conversation/conversation_controller.dart';
import 'package:chat_interface/theme/components/fj_button.dart';
import 'package:chat_interface/theme/components/fj_textfield.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/util/constants.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../util/vertical_spacing.dart';

class ConversationAddWindow extends StatefulWidget {

  final Offset position;
  
  const ConversationAddWindow({super.key, required this.position});

  @override
  State<ConversationAddWindow> createState() => _ConversationAddWindowState();
}

class _ConversationAddWindowState extends State<ConversationAddWindow> {

  final _members = <Friend>[].obs;
  final _length = 0.obs;
  final _conversationLoading = false.obs;
  final _errorText = "".obs;

  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    ThemeData theme = Theme.of(context);
    FriendController friendController = Get.find();

    return SlidingWindowBase(
      position: ContextMenuData(widget.position, true, true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("conversations.create".tr, style: theme.textTheme.titleMedium),
                
              Obx(() =>
                Text("${_members.length}/100", style: theme.textTheme.bodyMedium)
              )
            ],
          ),
                
          verticalSpacing(defaultSpacing * 0.5),
                
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Obx(() => ListView.builder(
              itemCount: friendController.friends.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Friend friend = friendController.friends.values.elementAt(index);
                      
                return Padding(
                  padding: const EdgeInsets.only(bottom: elementSpacing),
                  child: Obx(() => Material(
                    color: _members.contains(friend) ? theme.colorScheme.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(defaultSpacing),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(defaultSpacing),
                      onTap: () {
                        if (_members.contains(friend)) {
                          _members.remove(friend);
                        } else {
                          _members.add(friend);
                        }
                        _length.value = _members.length;
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: defaultSpacing, vertical: defaultSpacing),
                        child: Row(
                          children: [
                            Icon(Icons.person, size: 25, color: theme.colorScheme.onPrimary),
                            horizontalSpacing(defaultSpacing),
                            Text("${friend.name}#${friend.tag}", style: theme.textTheme.labelLarge),
                          ],
                        ),
                      ),
                    ),
                  )),
                );
              },
            )),
          ),
          verticalSpacing(defaultSpacing - elementSpacing),
                                
          //* Create conversation button
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                child: Obx(() =>
                  Animate(
              
                    effects: [
                      ExpandEffect(
                        axis: Axis.vertical,
                        duration: 250.ms,
                        curve: Curves.ease,
                        alignment: Alignment.center
                      ),
                    ],
                    target: _length.value > 1 ? 1 : 0,
              
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: defaultSpacing),
                      child: FJTextField(
                        controller: _controller,
                        hintText: "conversations.name".tr,
                      ),
                    ),
                  )
                ),
              ),
              Obx(() => 
                Visibility(
                  visible: _errorText.value.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: defaultSpacing),
                    child: Text(_errorText.value, 
                      style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.error)
                    ),
                  ),
                )
              ),
              FJElevatedLoadingButton(
                onTap: () async {
                
                  if(_members.isEmpty) {
                    showMessage(SnackbarType.error, "choose.members".tr);
                    return;
                  }
            
                  if(_members.length > specialConstants["max_conversation_members"]) {
                    showMessage(SnackbarType.error, "choose.members".tr);
                    return;
                  }
            
                  if(_controller.text.isEmpty && _members.length > 1) {
                    _errorText.value = "enter.name".tr;
                    return;
                  }
            
                  if(_controller.text.length > specialConstants["max_conversation_name_length"] && _members.length > 1) {
                    _errorText.value = "too.long".trParams({ "limit": specialConstants["max_conversation_name_length"].toString() });
                    return;
                  }
            
                  _conversationLoading.value = true;
                  var result = false;
                  if(_members.length == 1) {
                    result = await openDirectMessage(_members.first);
                  } else {
                    result = await openGroupConversation(_members, _controller.text);
                  }
            
                  if(result) {
                    Get.back();
                  }
                  _conversationLoading.value = false;
                },
                label: "create".tr,
                loading: _conversationLoading,
              ),
            ],
          )
        ],
      ),
    );
  }
}