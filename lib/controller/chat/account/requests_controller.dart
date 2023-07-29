import 'dart:convert';

import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/pages/status/setup/account/remote_id_setup.dart';
import 'package:chat_interface/pages/status/setup/encryption/key_setup.dart';
import 'package:chat_interface/theme/ui/dialogs/confirm_window.dart';
import 'package:chat_interface/util/logging_framework.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';

import 'friend_controller.dart';

class RequestController extends GetxController {

  final requestsSent = <Request>[].obs;
  final requests = <Request>[].obs;

  void reset() {
    requests.clear();
  }

  Future<bool> loadRequests() async {
    for(RequestData data in await db.request.select().get()) {
      if(data.self) {
        requestsSent.add(Request.fromEntity(data));
      } else {
        requests.add(Request.fromEntity(data));
      }
    }

    return true;
  }

  void addSentRequest(Request request) {
    requestsSent.add(request);
    db.request.insertOnConflictUpdate(request.entity(true));
  }

  void addRequest(Request request) {
    requests.add(request);
    db.request.insertOnConflictUpdate(request.entity(false));
  }

}

final requestsLoading = false.obs;

void newFriendRequest(String name, String tag, Function() success) async {

  requestsLoading.value = true;

  final controller = Get.find<StatusController>();
  if(name == controller.name.value && tag == controller.tag.value) {
    showErrorPopup("request.self", "request.self.text");
    requestsLoading.value = false;
    return;
  }

  // Get public key and id of the user
  var res = await postRqAuth("/account/stored_actions/details", <String, dynamic>{
    "username": name,
    "tag": tag,
  }, randomRemoteID());

  if (res.statusCode != 200) {
    showErrorPopup("error.network", "error.network.text");
    requestsLoading.value = false;
    return;
  }

  var json = jsonDecode(res.body);
  if(!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return;
  }

  final id = json["account"];
  final publicKey = unpackagePublicKey(json["key"]);


  //* Prompt with confirm popup
  var declined = true;
  await showConfirmPopup(ConfirmWindow(
    title: "request.confirm.title".tr,
    text: "request.confirm.text".trParams(<String, String>{
      "name": name,
      "tag": tag,
    }),
    onConfirm: () async {
      declined = false;
      sendFriendRequest(controller, name, tag, id, publicKey, success);
    },
    onDecline: () {
      declined = true;
      return false;
    },
  ));

  requestsLoading.value = !declined;
  return;
}

void sendFriendRequest(StatusController controller, String name, String tag, String id, Uint8List publicKey, Function() success) async {
  
  // Encrypt friend request
  final encryptedPayload = encryptAsymmetricAnonymous(publicKey, storedAction("fr_rq", <String, dynamic>{
    "name": controller.name.value,
    "tag": controller.tag.value,
    "s": asymmetricSignature(asymmetricKeyPair.secretKey, "$name#$tag"),
    "pf": packageSymmetricKey(profileKey),
  }));

  // Store in friends vault 
  var request = Request(id, name, tag, "", KeyStorage(publicKey, profileKey));
  sendLog(encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, request.toStoredPayload()));
  var res = await postRqAuthorized("/account/friends/add", <String, String>{
    "payload": encryptAsymmetricAnonymous(asymmetricKeyPair.publicKey, request.toStoredPayload()), // Maybe use authenticated encryption here?
  });

  if (res.statusCode != 200) {
    sendLog("Error: ${res.body}");
    showErrorPopup("error.network", "error.network.text");
    requestsLoading.value = false;
    return;
  }

  var json = jsonDecode(res.body);
  if(!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return;
  }

  // This had me in a mental breakdown, but then I ended up fixing it in 10 minutes LMFAO
  request.vaultId = json["id"];

  // Send stored action
  res = await postRqAuth("/account/stored_actions/send", <String, dynamic>{
    "account": id,
    "payload": encryptedPayload,
  }, randomRemoteID());

  if (res.statusCode != 200) {
    showErrorPopup("error.network", "error.network.text");
    requestsLoading.value = false;
    return;
  }

  json = jsonDecode(res.body);
  if(!json["success"]) {
    showErrorPopup("request.${json["error"]}", "request.${json["error"]}.text");
    requestsLoading.value = false;
    return;
  }

  RequestController requestController = Get.find();
  requestController.requestsSent.add(request);

  success();
  requestsLoading.value = false;
  
  return;
}

class Request {

  final String id;
  final String name;
  final String tag;
  String vaultId;
  final KeyStorage keyStorage;
  final loading = false.obs;

  Request.empty() : id = "", name = "", tag = "", vaultId = "", keyStorage = KeyStorage.empty();
  Request(this.id, this.name, this.tag, this.vaultId, this.keyStorage);
  Request.fromEntity(RequestData data)
      : name = data.name,
        tag = data.tag,
        vaultId = data.id,
        keyStorage = KeyStorage.fromJson(jsonDecode(data.keys)),
        id = data.id;

  // Convert to a payload for the friends vault (on the server)
  String toStoredPayload() {

    final reqPayload = <String, dynamic>{
      "rq": true,
      "id": id,
      "name": name,
      "tag": tag,
    };
    reqPayload.addAll(keyStorage.toJson());

    return jsonEncode(reqPayload);
  }

  RequestData entity(bool self) => RequestData(
    id: id,
    name: name,
    tag: tag,
    vaultId: vaultId,
    keys: jsonEncode(keyStorage.toJson()),
    self: self
  );

  Friend get friend => Friend(id, name, tag, vaultId, keyStorage);

}