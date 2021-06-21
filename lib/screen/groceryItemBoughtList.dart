import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'package:grocery_list/util/dbhelper.dart';
import 'package:grocery_list/screen/GroceryItemdetail.dart';
import 'package:grocery_list/util/groceryActions.dart';
import 'package:grocery_list/util/uiHelper.dart';
import 'package:grocery_list/widget/boughtIconSlideAction.dart';
import 'package:grocery_list/widget/deleteIconSlideAction%20copy.dart';
import 'package:grocery_list/widget/groceryCard.dart';

const mnuCleanBoughItems = 'Clean Grocery Bough Items';
const mnuDeleteBoughItems = 'Delete Grocery Bough Items';

final List<String> choices = const <String>[
  mnuCleanBoughItems,
  mnuDeleteBoughItems
];

class GroceryItemBoughtList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GroceryItemBoughtListState();
}

class GroceryItemBoughtListState extends State {
  DbHelper helper = DbHelper();
  SlidableController _slidableController;
  List<GroceryItem> groceryItems;
  int count = 0;
  int totalCost = 0;
  @override
  Widget build(BuildContext context) {
    if (groceryItems == null) {
      groceryItems = <GroceryItem>[];
      getData();
    }
    return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            Text('Grocery Bough Items  ',
                style: TextStyle(color: Colors.white, fontSize: 18.0)),
            Text(
              '\$$totalCost',
              style: TextStyle(color: Colors.blue[900], fontSize: 18.0),
            )
          ]),
          toolbarHeight: 40.0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.teal[200],
          actions: <Widget>[
            PopupMenuButton(
              icon: Icon(Icons.mediation),
              iconSize: 20.0,
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
            child: Center(
              child: OrientationBuilder(
                builder: (context, orientation) =>
                    _buildList(context, Axis.horizontal),
              ),
            )));
  }

  Widget _buildList(BuildContext context, Axis direction) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemBuilder: (context, position) {
        return _slidableWithDelegates(context, position, direction);
      },
      itemCount: groceryItems.length,
    );
  }

  Widget _slidableWithDelegates(
      BuildContext context, int position, Axis direction) {
    final GroceryItem item = groceryItems[position];
    return Slidable.builder(
      key: Key(item.id.toString()),
      controller: _slidableController,
      direction: direction,
      actionPane: GroceryActions.actionPane(item.id),
      actionExtentRatio: 0.20,
      child: GroceryCard(
          onChanged: (bool value) {
            setState(() {
              this.groceryItems[position].isBought = value;
              totalCost = getTotalCost();
            });
          },
          onTap: () => navigateToDetail(this.groceryItems[position]),
          groceryItem: this.groceryItems[position]),
      actionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, renderingMode) {
            return BoughtIconSlideAction(
                onTap: () {
                  GroceryActions.changeGroceryState(false, item, helper)
                      .then((value) {
                    if (value) {
                      setState(() {
                        groceryItems.remove(item);
                        UIHelper.showSnackBar(context, 'To-Bought it');
                      });
                    } else {
                      UIHelper.showSnackBar(context, 'Failed!');
                    }
                  });
                },
                renderingMode: renderingMode,
                animation: animation,
                index: index,
                caption: 'To Buy!');
          }),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, position, animation, renderingMode) {
            return DeleteIconSlideAction(
                onDialogOkPressed: () {
                  GroceryActions.deleteGroceryItem(item, helper).then((value) {
                    if (value) {
                      setState(() {
                        groceryItems.remove(item);
                      });
                      UIHelper.showSnackBar(context, 'Delete');
                    } else {
                      UIHelper.showSnackBar(context, 'Failed!');
                    }
                  });
                  Navigator.of(context).pop(true);
                },
                renderingMode: renderingMode,
                animation: animation);
          }),
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
          totalCost = getTotalCost();
        });
      });
    });
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
                      helper.cleanGroceryBoughtItem(
                          GroceryActions.getBoughItemsToClean(groceryItems));
                      Navigator.pop(context, true);
                      getData();
                    }),
              ],
            );
          },
        );
        break;
      case mnuDeleteBoughItems:
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Text(
                mnuDeleteBoughItems,
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                'Items will be deleted',
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
                      helper.deleteGroceryBoughtItem(
                          GroceryActions.getBoughItemsToClean(groceryItems));
                      Navigator.pop(context, true);
                      getData();
                    }),
              ],
            );
          },
        );
        break;
    }
  }

  int getTotalCost() {
    int total = 0;
    groceryItems.where((item) => item.isBought).forEach((item) {
      total += item.price;
    });
    return total;
  }
}
