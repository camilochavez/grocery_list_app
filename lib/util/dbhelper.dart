import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:grocery_list/model/groceryItem.dart';

class DbHelper {
  static final DbHelper _dbHelper = DbHelper._internal();
  String tblGroceryItem = "groceryItem";
  String colId = "id";
  String colName = "name";
  String colquantity = "quantity";
  String colPrice = "price";
  String colIsBought = "isBought";
  String colPriority = "priority";

  DbHelper._internal();

  factory DbHelper() {
    return _dbHelper;
  }

  static Database _db;

  Future<Database> get db async {
    if (_db == null) {
      _db = await initializeDb();
    }
    return _db;
  }

  Future<Database> initializeDb() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + "groceryItem.db";
    var dbGroceryItems =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return dbGroceryItems;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblGroceryItem($colId INTEGER PRIMARY KEY, $colName TEXT, " +
            "$colquantity INTEGER, $colPriority INTEGER, $colPrice INTEGER, $colIsBought INTEGER)");
  }

  Future<int> insertGroceryItem(GroceryItem groceryItem) async {
    Database db = await this.db;
    var result = await db.insert(tblGroceryItem, groceryItem.toMap());
    return result;
  }

  Future<List> getGroceryItems() async {
    Database db = await this.db;
    var result = await db.rawQuery(
        "SELECT * FROM $tblGroceryItem WHERE $colIsBought = 0 ORDER BY $colPriority, $colName ASC");
    return result;
  }

  Future<List> getGroceryBoughtItems() async {
    Database db = await this.db;
    var result = await db.rawQuery(
        "SELECT * FROM $tblGroceryItem WHERE $colIsBought = 1 ORDER BY $colPriority, $colName ASC");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.db;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT (*) FROM $tblGroceryItem"));
    return result;
  }

  Future<int> updateGroceryItem(GroceryItem groceryItem) async {
    Database db = await this.db;
    var result = await db.update(tblGroceryItem, groceryItem.toMap(),
        where: "$colId = ?", whereArgs: [groceryItem.id]);
    return result;
  }

  Future<int> deleteGroceryItem(int id) async {
    Database db = await this.db;
    var result =
        await db.rawDelete("DELETE FROM $tblGroceryItem WHERE  $colId = $id");
    return result;
  }

  Future<int> cleanGroceryBoughtItem() async {
    Database db = await this.db;
    var result = await db.rawUpdate(
        'UPDATE $tblGroceryItem SET $colIsBought = 0 WHERE $colIsBought = 1');
    return result;
  }
}
