import 'dart:io';
import 'dart:async';
import 'package:flutter_share/flutter_share.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'package:grocery_list/util/dbhelper.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static final FileManager _fileManager = FileManager._internal();
  String fileName;
  File jsonFile;
  FileType fileType;

  FileManager._internal();

  factory FileManager() {
    return _fileManager;
  }

  Future<void> importGroceryList() async {
    try {
      if (await _openFileExplorer()) {
        final String response = await jsonFile.readAsString();
        final data = await json.decode(response);
        await data.forEach((groceryJsonItem) {
          GroceryItem gItem = GroceryItem.fromJson(groceryJsonItem);
          DbHelper()
              .isGroceryItemAlreadyExistsByName(gItem.name)
              .then((isNewGroceryItem) async {
            if (!isNewGroceryItem) {
              await DbHelper().insertGroceryItem(gItem);
            }
          });
        });
      }
    } catch (e) {
      throw Exception("Error Importing Grocery List");
    }
  }

  Future<void> exportGroceryList() async {
    final directory = await getExternalStorageDirectory();
    final path = directory.absolute.path;
    List<GroceryItem> groceryItems = await getGroceryList();
    String jsonGroceryItemList = jsonEncode(groceryItems);
    File exportFile = File('$path/grocerlys.json');
    exportFile.writeAsString(jsonGroceryItemList);
    await FlutterShare.shareFile(
      title: 'Grocery Item List exported',
      text: 'Grocery Item List ',
      filePath: exportFile.absolute.path,
    );
  }

  Future<bool> _openFileExplorer() async {
    try {
      FilePickerResult result = await FilePicker.platform.pickFiles();
      jsonFile = File(result.files.single.path);
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
      return false;
    }
    fileName = jsonFile != null ? jsonFile.path.split('/').last : '';
    return fileName.length > 0;
  }

  Future<List<GroceryItem>> getGroceryList() async {
    DbHelper helper = DbHelper();
    List<GroceryItem> groceryItemList = <GroceryItem>[];
    final groceryItemsFuture = await helper.getGroceryItems();
    int count = groceryItemsFuture.length;
    for (int i = 0; i < count; i++) {
      groceryItemList.add(GroceryItem.fromObject(groceryItemsFuture[i]));
    }
    return groceryItemList;
  }
}
