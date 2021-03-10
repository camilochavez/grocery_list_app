import 'package:flutter/material.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'package:grocery_list/util/dbhelper.dart';
import 'package:grocery_list/screen/GroceryItemdetail.dart';

const mnuCleanBoughItems = 'Clean Grocery Bough Items';
const mnuGoBack = 'Go back to Grocery Items List';

final List<String> choices = const <String>[mnuCleanBoughItems, mnuGoBack];

class GroceryItemBoughtList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GroceryItemBoughtListState();
}

class GroceryItemBoughtListState extends State {
  DbHelper helper = DbHelper();
  List<GroceryItem> groceryItems;
  int count = 0;

  @override
  Widget build(BuildContext context) {
    if (groceryItems == null) {
      groceryItems = List<GroceryItem>();
      getData();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Grocery Bough Items List'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          PopupMenuButton(
            onSelected: select,
            itemBuilder: (BuildContext context) {
              return choices.map((String choice) {
                return PopupMenuItem<String>(
                    value: choice, child: Text(choice));
              }).toList();
            },
          )
        ],
      ),
      body: groceryItemList(),
    );
  }

  ListView groceryItemList() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: getColor(this.groceryItems[position].priority),
                child: Text(this.groceryItems[position].priority.toString())),
            title: Text(this.groceryItems[position].name),
            subtitle: Text(this.groceryItems[position].quantity.toString() +
                " - \$" +
                this.groceryItems[position].price.toString()),
            onTap: () {
              navigateToDetail(this.groceryItems[position]);
            },
          ),
        );
      },
    );
  }

  void getData() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
      final groceryItemsFuture = helper.getGroceryBoughtItems();
      groceryItemsFuture.then((result) {
        List<GroceryItem> groceryItemList = List<GroceryItem>();
        count = result.length;
        for (int i = 0; i < count; i++) {
          groceryItemList.add(GroceryItem.fromObject(result[i]));
        }
        setState(() {
          groceryItems = groceryItemList;
          count = count;
        });
      });
    });
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.orange;
        break;
      case 3:
        return Colors.green;
        break;
      default:
        return Colors.green;
    }
  }

  void navigateToDetail(GroceryItem groceryItem) async {
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroceryItemDetail(groceryItem)));
    if (result == true) {
      getData();
    }
  }

  void select(String value) async {
    switch (value) {
      case mnuCleanBoughItems:
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Text(
                mnuCleanBoughItems,
                style: TextStyle(color: Colors.white),                
              ),
              content: Text(
                'Items will be cleaned',
                style: TextStyle(color: Colors.white),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                FlatButton(
                    child: Text(
                      'Ok',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      helper.cleanGroceryBoughtItem();
                      Navigator.pop(context, true);
                    }),
              ],
            );
          },
        );
        Navigator.pop(context, true);
        break;
      case mnuGoBack:
        Navigator.pop(context, true);
        break;
    }
  }
}
