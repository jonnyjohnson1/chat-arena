import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:chat/models/conversation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/messages.dart';

class ConversationDatabase {
  static final ConversationDatabase instance = ConversationDatabase._init();
  static Database? _database;
  static String dbPath = 'test15.db';
  ConversationDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(dbPath);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    var databasesPath = await getDatabasesPath();
    String path = p.join(databasesPath, dbPath);
    //
    if (kIsWeb) {
      sqfliteFfiInit();
      // Change default factory on the web

      return await databaseFactory.openDatabase(
        path,
        options: OpenDatabaseOptions(version: 1, onCreate: _createDB),
      );
    }
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

// executes only if the database does not exist in the filesystem
  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const boolType = 'BOOLEAN';
    const intType = 'INTEGER';
    // create conversation table
    debugPrint("Making table $tableConversations");
    await db.execute('''
CREATE TABLE IF NOT EXISTS $tableConversations (
  ${ConversationFields.id} $idType,
  ${ConversationFields.title} $textType,
  ${ConversationFields.gameType} $textType,
  ${ConversationFields.lastMessage} $textType,
  ${ConversationFields.image} $textType,
  ${ConversationFields.primaryModel} $textType,
  ${ConversationFields.time} $textType
)''');

    debugPrint("Making table $tableMessages");
    await db.execute('''
CREATE TABLE IF NOT EXISTS $tableMessages (
  ${MessageFields.id} $idType,
  ${MessageFields.conversationID} $textType,
  ${MessageFields.documentID} $textType,
  ${MessageFields.senderID} $textType,
  ${MessageFields.message} $textType,
  ${MessageFields.timestamp} $textType,
  ${MessageFields.toksPerSec} $intType,
  ${MessageFields.completionTime} $intType,
  ${MessageFields.type} $intType,
  ${MessageFields.status} $textType,
  ${MessageFields.name} $textType,
  ${MessageFields.isGenerating} $boolType,
  ${MessageFields.images} $textType
)
''');
  }

  Future _resetTable() async {
    final db = await instance.database;
    await db.execute("DROP TABLE IF EXISTS $tableConversations");
    await _createDB(db, 1);
  }

  Future<Conversation> create(Conversation conversation) async {
    final db = await instance.database;
    var datamap = conversation.toMap();

    final id = await db.insert(tableConversations, datamap);

    return conversation;
  }

  Future<Conversation> readConversation(String id) async {
    final db = await instance.database;
    final maps = await db.query(tableConversations,
        columns: ConversationFields.values,
        where:
            '${ConversationFields.id} = ?', // this format prevents sql injection attacks
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Conversation.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Conversation>> readAllConversations() async {
    final db = await instance.database;
    const orderBy = '${ConversationFields.time} DESC';
    // final result = await db
    //     .rawQuery('SELECT * FROM $tableConversations ORDER BY $orderBy'); // custom SQL QUERY
    final result = await db.query(tableConversations, orderBy: orderBy);
    print(result);
    return result.map((json) => Conversation.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<int> update(Conversation conversation) async {
    final db = await instance.database;

    return db.update(tableConversations, conversation.toMap(),
        where: '${ConversationFields.id} = ?', whereArgs: [conversation.id]);
  }

  Future<int> delete(String id) async {
    final db = await instance.database;
    readConversation(id);
    return db.delete(tableConversations,
        where: '${ConversationFields.id} = ?', whereArgs: [id]);
  }

  Future saveJsonData(jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    var saveData = jsonEncode(jsonData);
    await prefs.setString('jsonData', saveData);
  }

  Future<void> getJsonData() async {
    final prefs = await SharedPreferences.getInstance();
    print(prefs.getKeys());
    var temp = prefs.getString('jsonData') ?? [];
    debugPrint("Data Received: $temp");
    var decoded = jsonDecode(jsonDecode(temp.toString()));
    var data = Conversation.fromMap(decoded);
    debugPrint('id: ${data.id}');
  }

  // FOR THE MESSAGES TABLE

  Future _resetMsgsTable() async {
    final db = await instance.database;
    await db.execute("DROP TABLE IF EXISTS $tableMessages");
    await makeMessagesTable(db);
  }

  makeMessagesTable(Database db) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const boolType = 'BOOLEAN';
    const intType = 'INTEGER';
    const doubleType = 'DOUBLE';
    // create conversation table
    await db.execute('''
CREATE TABLE $tableMessages (
  ${MessageFields.id} $idType,
  ${MessageFields.conversationID} $textType,
  ${MessageFields.documentID} $textType,
  ${MessageFields.senderID} $textType,
  ${MessageFields.message} $textType,
  ${MessageFields.timestamp} $textType,
  ${MessageFields.toksPerSec} $doubleType,
  ${MessageFields.completionTime} $doubleType,
  ${MessageFields.type} $intType,
  ${MessageFields.status} $textType,
  ${MessageFields.name} $textType,
  ${MessageFields.isGenerating} $boolType,
  ${MessageFields.images} $textType
)

''');
  }

  Future<Message> createMessage(Message message) async {
    final db = await instance.database;
    try {
      final id = await db.insert(tableMessages, message.toMap());
    } catch (e) {
      // if table doesn't exist, make the table and try again
      await makeMessagesTable(db);
      final id = await db.insert(tableMessages, message.toMap());
    }
    return message;
  }

  Future<Message> readMessage(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableMessages,
      columns: MessageFields.values,
      where: '${MessageFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Message.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Message>> readAllMessages(String conversationID) async {
    final db = await instance.database;

    final orderBy = '${MessageFields.timestamp} ASC';
    debugPrint("\t\t[ Fetching all messages for ${conversationID} ]");
    final result = await db.query(tableMessages,
        where: '${MessageFields.conversationID} = ?',
        whereArgs: [conversationID],
        orderBy: orderBy);
    return result.map((json) => Message.fromMap(json)).toList();
  }

  Future<int> updateMessage(Message message) async {
    final db = await instance.database;
    return db.update(
      tableMessages,
      message.toMap(),
      where: '${MessageFields.id} = ?',
      whereArgs: [message.id],
    );
  }

  Future<int> deleteMessage(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableMessages,
      where: '${MessageFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMessageByConvId(String id) async {
    final db = await instance.database;
    return await db.delete(
      tableMessages,
      where: '${MessageFields.conversationID} = ?',
      whereArgs: [id],
    );
  }
}
