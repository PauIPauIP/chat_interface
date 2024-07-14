import 'package:chat_interface/pages/settings/app/file_settings.dart';
import 'package:drift/drift.dart';

enum ConversationType { directMessage, group }

class Conversation extends Table {
  TextColumn get id => text()();
  TextColumn get vaultId => text()();
  IntColumn get type => intEnum<ConversationType>()();
  TextColumn get data => text()();
  TextColumn get token => text()();
  TextColumn get key => text()();
  Int64Column get lastVersion => int64()();
  Int64Column get updatedAt => int64()();
  Int64Column get readAt => int64()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Member extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text().nullable()();
  TextColumn get accountId => text()();

  // 1 - member, 2 - admin, 3 - owner
  IntColumn get roleId => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Friend extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  TextColumn get vaultId => text()();
  TextColumn get keys => text()();
  Int64Column get updatedAt => int64()();

  @override
  Set<Column> get primaryKey => {id};
}

class LibraryEntry extends Table {
  IntColumn get type => intEnum<LibraryEntryType>()();
  Int64Column get createdAt => int64()();
  TextColumn get data => text()();
  IntColumn get width => integer()();
  IntColumn get height => integer()();
}

enum LibraryEntryType {
  image,
  gif;

  static LibraryEntryType fromFileName(String name) {
    for (var type in FileSettings.staticImageTypes) {
      if (name.endsWith(".$type")) {
        return LibraryEntryType.image;
      }
    }
    return LibraryEntryType.gif;
  }
}

class Profile extends Table {
  TextColumn get id => text()();

  // Profile picture data
  TextColumn get pictureContainer => text()();

  TextColumn get data => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Request extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  BoolColumn get self => boolean()(); // Whether the request is sent by the current user
  TextColumn get vaultId => text()();
  TextColumn get keys => text()();
  Int64Column get updatedAt => int64()();

  @override
  Set<Column> get primaryKey => {id};
}

class Setting extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>>? get primaryKey => {key};
}

class UnknownProfile extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get displayName => text()();
  TextColumn get keys => text()();

  @override
  Set<Column> get primaryKey => {id};
}
