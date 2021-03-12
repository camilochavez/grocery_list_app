import 'package:flutter/material.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'package:grocery_list/util/dbhelper.dart';
import 'package:grocery_list/screen/GroceryItemdetail.dart';

const mnuCleanBoughItems = 'Clean Grocery Bough Items';

final List<String> choices = const <String>[mnuCleanBoughItems];

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
      groceryItems = <GroceryItem>[];
      getData();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Grocery Bough Items List'),
          automaticallyImplyLeading: false,
          backgroundColor: Colors.teal[200],
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
        body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/fresh_vegetables.jpg"),
                fit: BoxFit.cover,
              ),
            ),
            child: groceryItemList()));
  }

  ListView groceryItemList() {
    TextStyle textStyleTitle = TextStyle(
        fontWeight: FontWeight.bold,
        color: Colors.teal[900],
        fontSize: 18.0,
        decorationThickness: 3.0,
        decoration: TextDecoration.underline,
        shadows: [
          BoxShadow(
              color: Colors.white24, blurRadius: 5.0, offset: Offset(3.0, 3.0))
        ]);
    TextStyle textStyleSubTitle = TextStyle(
        fontWeight: FontWeight.bold,
        backgroundColor: Colors.white24,
        color: Colors.teal[900],
        fontSize: 15.0,
        decorationThickness: 3.0,
        decoration: TextDecoration.underline,
        shadows: [
          BoxShadow(
              color: Colors.white, blurRadius: 5.0, offset: Offset(3.0, 3.0))
        ]);
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white38,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: getColor(this.groceryItems[position].priority),
                child: Text(this.groceryItems[position].quantity.toString())),
            title:
                Text(this.groceryItems[position].name, style: textStyleTitle),
            subtitle: Text("\$" + this.groceryItems[position].price.toString(),
                style: textStyleSubTitle),
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
        List<GroceryItem> groceryItemList = <GroceryItem>[];
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
        return Colors.redAccent[700];
        break;
      case 2:
        return Colors.orange[700];
        break;
      case 3:
        return Colors.lightBlueAccent;
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
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
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
        break;
    }
  }
}
