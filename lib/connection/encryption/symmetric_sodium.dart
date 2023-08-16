import 'dart:convert';

import 'package:chat_interface/main.dart';
import 'package:sodium_libs/sodium_libs.dart';

String encryptSymmetric(String data, SecureKey key, [Sodium? sd]) {

  final sodium = sd ?? sodiumLib;
  final nonce = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);
  final plainTextBytes = data.toCharArray().unsignedView();
  return base64Encode(nonce + sodium.crypto.secretBox.easy(key: key, nonce: nonce, message: plainTextBytes));
}

String decryptSymmetric(String data, SecureKey key, [Sodium? sd]) {

  final sodium = sd ?? sodiumLib;
  final byteData = base64Decode(data);
  final nonce = byteData.sublist(0, sodium.crypto.secretBox.nonceBytes);
  final encrypted = byteData.sublist(sodium.crypto.secretBox.nonceBytes);

  return String.fromCharCodes(sodium.crypto.secretBox.openEasy(key: key, nonce: nonce, cipherText: encrypted));
}


SecureKey randomSymmetricKey([Sodium? sd]) {
  final Sodium sodium = sd ?? sodiumLib;
  return sodium.crypto.secretBox.keygen();
}

String packageSymmetricKey(SecureKey key) {
  return base64Encode(key.extractBytes());
}

SecureKey unpackageSymmetricKey(String key, [Sodium? sd]) {
  final Sodium sodium = sd ?? sodiumLib;
  return SecureKey.fromList(sodium, base64Decode(key));
}
