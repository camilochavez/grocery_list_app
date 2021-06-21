import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'package:grocery_list/util/dbhelper.dart';
import 'package:grocery_list/util/fileManager.dart';
import 'package:grocery_list/util/groceryActions.dart';
import 'package:grocery_list/util/uiHelper.dart';
import 'package:grocery_list/widget/boughtIconSlideAction.dart';
import 'package:grocery_list/widget/deleteIconSlideAction%20copy.dart';
import 'package:grocery_list/widget/groceryCard.dart';
import 'GroceryItemdetail.dart';

const mnuImportItems = 'Import Grocery Items';
const mnuExportItems = 'Export Grocery Items';
const mnuDeleteItems = 'Delete Grocery Items';
final List<String> choices = const <String>[
  mnuImportItems,
  mnuExportItems,
  mnuDeleteItems
];

class GroceryItemSlidableList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _GroceryItemSlidableListState();
}

class _GroceryItemSlidableListState extends State {
  SlidableController _slidableController;
  DbHelper helper = DbHelper();
  List<GroceryItem> groceryItems;
  int count = 0;
  TextEditingController _txtPriceController = TextEditingController();
  TextEditingController _txtTypeAheadController = TextEditingController();

  @override
  void initState() {
    _slidableController = SlidableController(
      onSlideAnimationChanged: slideAnimationChanged,
      onSlideIsOpenChanged: slideIsOpenChanged,
    );
    super.initState();
  }

  Animation<double> _rotationAnimation;
  Color _fabColor = Colors.redAccent;

  @override
  Widget build(BuildContext context) {
    if (groceryItems == null) {
      groceryItems = <GroceryItem>[];
      getData();
    }
    TextStyle textStyle = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.white,
      fontSize: 20.0,
    );
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            toolbarHeight: 40,
            title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(children: [
                    Padding(
                        padding: EdgeInsets.only(right: 25.0, left: 5.0),
                        child: Text('Grocery List')),
                    Container(
                        width: 135.0,
                        height: 34.0,
                        child: TextField(
                            controller: _txtTypeAheadController,
                            style: textStyle,
                            onChanged: (value) => this.getSuggestionData(),
                            decoration: InputDecoration(
                                hintText: "filter by name...",
                                hintStyle: TextStyle(fontSize: 14.0),
                                fillColor: Colors.teal[100],
                                labelStyle: textStyle,
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(5.0))))),
                    Icon(Icons.search)
                  ]),
                ]),
            backgroundColor: Colors.teal[200],
            actions: <Widget>[
              PopupMenuButton(
                icon: Icon(Icons.mediation),
                iconSize: 20.0,
                padding: EdgeInsets.only(left: 1.0),
                onSelected: select,
                itemBuilder: (BuildContext context) {
                  return choices.map((String choice) {
                    return PopupMenuItem<String>(
                        value: choice, child: Text(choice));
                  }).toList();
                },
              )
            ]),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/fresh_vegetables.jpg"),
              fit: BoxFit.cover,
            ),
          ),
          child: OrientationBuilder(
            builder: (context, orientation) =>
                _buildList(context, Axis.horizontal),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: _fabColor,
            onPressed: () {
              navigateToDetail(GroceryItem(''));
            },
            tooltip: "Add new Grocery Item",
            child: _rotationAnimation == null
                ? Icon(
                    Icons.add,
                    color: Colors.white,
                  )
                : RotationTransition(
                    turns: _rotationAnimation,
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ))));
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
      child: SingleChildScrollView(
        child: GroceryCard(
            onChanged: (bool value) {
              setState(() {
                this.groceryItems[position].isBought = value;
              });
            },
            onTap: () => navigateToDetail(this.groceryItems[position]),
            groceryItem: this.groceryItems[position]),
      ),
      actionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, renderingMode) {
            return BoughtIconSlideAction(
                onTap: () => _displayTextInputDialog(context, item),
                renderingMode: renderingMode,
                animation: animation,
                index: index,
                caption: 'I Bought it!');
          }),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, position, animation, renderingMode) {
            return DeleteIconSlideAction(
                onDialogOkPressed: () {
                  deleteGroceryItem(item).then((value) {
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

  void slideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void slideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.orange : Colors.redAccent;
    });
  }

  void getData() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
      final groceryItemsFuture = helper.getNoBoughtGroceryItems();
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

  void navigateToDetail(GroceryItem groceryItem) async {
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroceryItemDetail(groceryItem)));
    if (result == true) {
      getData();
    }
  }

  Future<bool> deleteGroceryItem(GroceryItem groceryItem) async {
    if (groceryItem.id == null) {
      return false;
    }
    int result = await helper.deleteGroceryItem(groceryItem.id);
    return result != 0 ? true : false;
  }

  Future<void> _displayTextInputDialog(
      BuildContext context, GroceryItem groceryItem) async {
    _txtPriceController.text = '';
    TextStyle textStyle = TextStyle(
        color: Colors.white,
        fontSize: Theme.of(context).textTheme.headline6.fontSize);
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.lightBlueAccent,
            title: Text(
              'Item was bought!',
              style: TextStyle(color: Colors.white),
            ),
            content: TextField(
                onChanged: (value) => updatePrice(groceryItem),
                controller: _txtPriceController,
                decoration: InputDecoration(
                  hintText: 'e.g. 124',
                  hintStyle: textStyle,
                  labelText: 'Price',
                  labelStyle: textStyle,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.0),
                      borderSide: BorderSide(color: Colors.white)),
                ),
                keyboardType: TextInputType.number),
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
                    GroceryActions.changeGroceryState(true, groceryItem, helper)
                        .then((value) {
                      if (value) {
                        setState(() {
                          groceryItems.remove(groceryItem);
                          UIHelper.showSnackBar(context, 'Bought it');
                        });
                      } else {
                        UIHelper.showSnackBar(context, 'Failed!');
                      }
                    });
                    Navigator.of(context).pop(true);
                  }),
            ],
          );
        });
  }

  void updatePrice(GroceryItem item) {
    item.price = int.parse(_txtPriceController.text);
  }

  void getSuggestionData() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
      final groceryItemsFuture =
          helper.groceryItemsTypeAhead(_txtTypeAheadController.text, false);
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

  Future<void> select(String value) async {
    switch (value) {
      case mnuImportItems:
        await FileManager().importGroceryList();
        Future.delayed(const Duration(milliseconds: 500))
            .then((value) => getData());
        break;
      case mnuExportItems:
        await FileManager().exportGroceryList();
        break;
      case mnuDeleteItems:
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Colors.redAccent,
              title: Text(
                mnuDeleteItems,
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
}
