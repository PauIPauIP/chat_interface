import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/chat/setup_listener.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/account/friends/friend_controller.dart';
import 'package:chat_interface/controller/conversation/attachment_controller.dart';
import 'package:chat_interface/controller/current/steps/account_step.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/settings/account/data_settings.dart';
import 'package:chat_interface/pages/settings/data/settings_controller.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

class StatusController extends GetxController {
  static String ownAccountId = "";
  static List<String> permissions = [];
  static List<RankData> ranks = [];
  static LPHAddress get ownAddress => LPHAddress(basePath, ownAccountId);

  Timer? _timer;
  StatusController() {
    if (_timer != null) _timer!.cancel();

    // Update status every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (connector.isConnected()) {
        setStatus();
      }
    });
  }

  final displayName = "not-set".obs;
  final name = 'not-set'.obs;

  // Status message
  final statusLoading = true.obs;
  final status = ''.obs;
  final type = 1.obs;

  // Shared content by friends
  final sharedContent = RxMap<LPHAddress, ShareContainer>();

  // Current shared content (by this account)
  final ownContainer = Rx<ShareContainer?>(null);

  void setName(String value) => name.value = value;

  String statusJson() => jsonEncode(<String, dynamic>{
        "s": base64Encode(utf8.encode(status.value)),
        "t": type.value,
      });

  String newStatusJson(String status, int type) => jsonEncode(<String, dynamic>{
        "s": base64Encode(utf8.encode(status)),
        "t": type,
      });

  void fromStatusJson(String json) {
    sendLog("received $json");
    final data = jsonDecode(json);
    try {
      status.value = utf8.decode(base64Decode(data["s"]));
    } catch (e) {
      status.value = "";
    }
    type.value = data["t"] ?? 1;
  }

  String statusPacket([String? newStatusJson]) {
    return encryptSymmetric(newStatusJson ?? statusJson(), profileKey);
  }

  String sharedContentPacket() {
    if (ownContainer.value == null) {
      return "";
    }
    return encryptSymmetric(ownContainer.value!.toJson(), profileKey);
  }

  Future<bool> share(ShareContainer container) async {
    if (ownContainer.value != null) return false; // TODO: Potentially remove
    ownContainer.value = container;
    await setStatus();
    return true;
  }

  void stopSharing() {
    if (ownContainer.value == null) {
      return;
    }
    ownContainer.value = null;
    setStatus();
  }

  Future<bool> setStatus({String? message, int? type, Function()? success}) async {
    if (statusLoading.value) return false;
    statusLoading.value = true;

    // Secret: Enable new social features experiment
    if (message == "liphium.social") {
      message = "activated";
      await Get.find<SettingController>().settings[DataSettings.socialFeatures]!.setValue(true);
    }

    // Validate the status to make sure everything is fine
    connector.sendAction(
        ServerAction("st_validate", <String, dynamic>{
          "status": statusPacket(newStatusJson(message ?? status.value, type ?? this.type.value)),
          "data": sharedContentPacket(),
        }), handler: (event) {
      statusLoading.value = false;
      success?.call();
      if (event.data["success"] == true) {
        if (message != null) status.value = message;
        if (type != null) this.type.value = type;

        // Send the new status
        subscribeToConversations(controller: this);
      }
    });

    return true;
  }

  // Log out of this account
  Future<void> logOut({deleteEverything = false, deleteFiles = false}) async {
    // Delete the session information
    await db.setting.deleteWhere((tbl) => tbl.key.equals("profile"));

    // Delete all data
    if (deleteEverything) {
      for (var table in db.allTables) {
        await table.deleteAll();
      }
    }

    // Delete all files
    if (deleteFiles) {
      await Get.find<AttachmentController>().deleteAllFiles();
    }

    // Exit the app
    exit(0);
  }
}

enum ShareType { space }

abstract class ShareContainer {
  final Friend? sender;
  final ShareType type;

  ShareContainer(this.sender, this.type);

  Map<String, dynamic> toMap();

  String toJson() {
    final map = toMap();
    map["type"] = type.index;
    return jsonEncode(map);
  }

  void onDrop() {}
}

class RankData {
  int id;
  String name;
  int level;

  RankData({
    required this.id,
    required this.name,
    required this.level,
  });

  // Factory constructor to create Rank object from JSON
  factory RankData.fromJson(Map<String, dynamic> json) {
    return RankData(
      id: json['id'] as int,
      name: json['name'] as String,
      level: json['level'] as int,
    );
  }

  // Method to convert Rank object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
    };
  }
}
