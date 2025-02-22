import 'dart:async';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/main.dart';
import 'package:chat_interface/pages/status/setup/instance_setup.dart';
import 'package:chat_interface/theme/ui/dialogs/window_base.dart';
import 'package:chat_interface/theme/ui/profile/profile_button.dart';
import 'package:chat_interface/util/popups.dart';
import 'package:chat_interface/util/vertical_spacing.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeveloperWindow extends StatefulWidget {
  const DeveloperWindow({super.key});

  @override
  State<DeveloperWindow> createState() => _DeveloperWindowState();
}

class _DeveloperWindowState extends State<DeveloperWindow> {
  final remoteActionTesting = false.obs;

  /// Perform a remote action test with any instance server
  Future<void> remoteActionTest(String server) async {
    remoteActionTesting.value = true;

    // Make the post request to the test endpoint
    final json = await postAddress(server, "/node/actions/send", {
      "app_tag": appTag,
      "action": "ping",
      "data": {
        "echo": "hello world",
      }
    });
    remoteActionTesting.value = false;

    // Check if there was an error
    if (!json["success"]) {
      showErrorPopup("error", json["error"]);
      return;
    }

    // Show the popup from the other server
    showSuccessPopup("success", json["answer"].toString());
  }

  @override
  Widget build(BuildContext context) {
    return DialogBase(
      title: [
        Text("Developer info", style: Get.theme.textTheme.labelLarge),
      ],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Current instance: $currentInstance", style: Get.textTheme.bodyMedium),
          verticalSpacing(elementSpacing),
          Text("Instance domain: ${connector.url ?? "Not connected"}", style: Get.textTheme.bodyMedium),
          verticalSpacing(elementSpacing),
          Text("Current account: ${StatusController.ownAddress.encode()}", style: Get.textTheme.bodyMedium),
          verticalSpacing(defaultSpacing),
          ProfileButton(
            icon: Icons.launch,
            label: 'Local database viewer',
            onTap: () async {
              unawaited(Navigator.of(context).push(MaterialPageRoute(builder: (context) => DriftDbViewer(db))));
            },
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all conversations (local)",
            onTap: () => db.conversation.deleteAll(),
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all members (local)",
            onTap: () => db.member.deleteAll(),
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all friends (local)",
            onTap: () => db.friend.deleteAll(),
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all messages (local)",
            onTap: () => db.message.deleteAll(),
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.delete,
            label: "Delete all library entries (local)",
            onTap: () => db.libraryEntry.deleteAll(),
            loading: false.obs,
          ),
          verticalSpacing(elementSpacing),
          ProfileButton(
            icon: Icons.hardware,
            label: "Test remote actions",
            onTap: () => remoteActionTest(basePath),
            loading: remoteActionTesting,
          ),
          Column(
            children: Get.find<FriendController>().friends.values.where((friend) => friend.id.server != basePath).map((friend) {
              return Padding(
                padding: const EdgeInsets.only(top: elementSpacing),
                child: ProfileButton(
                  icon: Icons.hardware,
                  label: "Test remote actions (${friend.id.server})",
                  onTap: () => remoteActionTest(friend.id.server),
                  loading: remoteActionTesting,
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }
}
