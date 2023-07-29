import 'dart:convert';

import 'package:chat_interface/connection/connection.dart';
import 'package:chat_interface/connection/encryption/asymmetric_sodium.dart';
import 'package:chat_interface/connection/encryption/symmetric_sodium.dart';
import 'package:chat_interface/connection/messaging.dart';
import 'package:chat_interface/controller/chat/account/requests_controller.dart';
import 'package:chat_interface/controller/current/status_controller.dart';
import 'package:chat_interface/database/database.dart';
import 'package:chat_interface/util/snackbar.dart';
import 'package:chat_interface/util/web.dart';
import 'package:drift/drift.dart';
import 'package:get/get.dart';
import 'package:sodium_libs/sodium_libs.dart';

part 'key_container.dart';

class FriendController extends GetxController {
  
  final friends = <String, Friend>{}.obs;

  Future<bool> loadFriends() async {
    for(FriendData data in await db.friend.select().get()) {
      friends[data.id] = Friend.fromEntity(data);
    }

    return true;
  }

  void reset() {
    friends.clear();
  }

  // Add friend (also sends data to server vault)
  Future<bool> addFromRequest(Request request) async {

    // Remove request from server
    var res = await postRqAuthorized("/account/friends/remove", <String, dynamic>{
      "id": request.vaultId,
    });

    if(res.statusCode != 200) {
      add(request.friend); // Add regardless cause restart of the app fixes not being able to remove the guy
      return false;
    }

    var json = jsonDecode(res.body);
    if(!json["success"]) {
      add(request.friend);
      return false;
    }

    // Add friend to vault
    res = await postRqAuthorized("/account/friends/add", <String, dynamic>{
      "payload": request.friend.toStoredPayload(),
    });

    if(res.statusCode != 200) {
      add(request.friend);
      return false;
    }

    json = jsonDecode(res.body);
    if(!json["success"]) {
      add(request.friend);
      return false;
    }

    // Add friend to database with vault id
    request.friend.vaultId = json["id"];
    add(request.friend);

    return true;
  }

  void add(Friend friend) {
    friends[friend.id] = friend;
    db.friend.insertOnConflictUpdate(friend.entity());
  }
}

class Friend {
  String id;
  String name;
  String tag;
  String vaultId;
  KeyStorage keyStorage;
  var status = "-".obs;
  final statusType = 0.obs;

  /// Loading state for open conversation buttons
  final openConversationLoading = false.obs;

  Friend(this.id, this.name, this.tag, this.vaultId, this.keyStorage);

  Friend.system() : id = "system", name = "System", tag = "fjc", vaultId = "", keyStorage = KeyStorage.empty();
  Friend.me()
        : id = '',
          name = '',
          tag = '',
          vaultId = '',
          keyStorage = KeyStorage.empty() {
    final StatusController controller = Get.find();
    id = controller.id.value;
    name = controller.name.value;
    tag = controller.tag.value;
  }
  Friend.unknown(this.id) 
        : name = 'fj-$id',
          tag = 'tag',
          vaultId = '',
          keyStorage = KeyStorage.empty();

  Friend.fromEntity(FriendData data)
        : id = data.id,
          name = data.name,
          tag = data.tag,
          vaultId = data.vaultId,
          keyStorage = KeyStorage.fromJson(jsonDecode(data.keys));

  // Convert to a stored payload for the server
  String toStoredPayload() {

    final reqPayload = <String, dynamic>{
      "rq": false,
      "id": id,
      "name": name,
      "tag": tag,
    };
    reqPayload.addAll(keyStorage.toJson());

    return jsonEncode(reqPayload);
  }

  //* Remove friend
  void remove(RxBool loading) {
    loading.value = true;

    // Send action to server
    connector.sendAction(Message("fr_rem", <String, dynamic>{
      "id": id,
    }), handler: (event) async {
      loading.value = false;

      if(event.data["success"] as bool) {
        
        // Remove from database TODO: Reimplement
        //await db.delete(db.friend).delete(entity);
        Get.find<FriendController>().friends.remove(this);

        showMessage(SnackbarType.success, "friends.removed".trParams({"name": name}));
      } else {
        showMessage(SnackbarType.error, (event.data["message"] as String).tr);
      }
    });
  }

  // Check if vault id is known (this would require a restart of the app)
  bool canBeDeleted() => vaultId != "";

  FriendData entity() => FriendData(
    id: id,
    name: name,
    tag: tag,
    vaultId: vaultId,
    keys: jsonEncode(keyStorage.toJson()),
  );
}