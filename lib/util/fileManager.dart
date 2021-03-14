import 'dart:io';
import 'dart:async';
import 'package:filex/filex.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {

  void importGroceryList() async {
    try {
      final file = await _filePath;
      // Read the file.
      String contents = await file.readAsString();
    } catch (e) {
      // If encountering an error, return 0.
      return;
    }
  }

  Future<File> get _filePath async {
var dir = await getApplicationDocumentsDirectory();
   final controller = FilexController(path: dir.path);
   Filex(controller: controller);
    if (controller != null) {
      File file = File(controller.path);
      return file;
    }
    return null;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }
}
