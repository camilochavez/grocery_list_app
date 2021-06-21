import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'dbhelper.dart';

class GroceryActions {
  static Future<bool> deleteGroceryItem(
      GroceryItem groceryItem, DbHelper helper) async {
    if (groceryItem.id == null) {
      return false;
    }
    int result = await helper.deleteGroceryItem(groceryItem.id);
    return result != 0 ? true : false;
  }

  static Future<bool> changeGroceryState(
      bool isBought, GroceryItem groceryItem, DbHelper helper) async {
    if (groceryItem.id == null) {
      return false;
    }
    groceryItem.isBought = isBought;
    int result = await helper.updateGroceryItem(groceryItem);
    return result != 0 ? true : false;
  }

  static Widget actionPane(int position) {
    switch (position % 4) {
      case 0:
        return SlidableScrollActionPane();
      case 1:
        return SlidableDrawerActionPane();
      case 2:
        return SlidableStrechActionPane();
      case 3:
        return SlidableBehindActionPane();

      default:
        return null;
    }
  }

  static String getBoughItemsToClean(List<GroceryItem> groceryItems) {
    String ids = '';
    groceryItems.where((item) => item.isBought).forEach((item) {
      ids += item.id.toString() + ",";
    });
    return ids.substring(0, ids.length - 1);
  }
}
