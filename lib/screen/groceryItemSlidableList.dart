import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'package:grocery_list/util/dbhelper.dart';
import 'GroceryItemdetail.dart';
import 'groceryItemBoughtList.dart';

const mnuBoughItems = 'Go to  Grocery Bough Items';

final List<String> choices = const <String>[mnuBoughItems];

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
      groceryItems = List<GroceryItem>();
      getData();
    }
    return Scaffold(
        appBar: AppBar(
          title: Text('Grocery List'),
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
        backgroundColor: Colors.white24,
        body: Center(
          child: OrientationBuilder(
            builder: (context, orientation) => _buildList(
                context,
                orientation == Orientation.portrait
                    ? Axis.vertical
                    : Axis.horizontal),
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
      scrollDirection: direction,
      itemBuilder: (context, position) {
        final Axis slidableDirection =
            direction == Axis.horizontal ? Axis.vertical : Axis.horizontal;
        return _slidableWithDelegates(context, position, slidableDirection);
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
      actionPane: _actionPane(item.id),
      actionExtentRatio: 0.20,
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
      actionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, index, animation, renderingMode) {
            return IconSlideAction(
                caption: 'Bought it!',
                color: renderingMode == SlidableRenderingMode.slide
                    ? Colors.blue.withOpacity(animation.value)
                    : (renderingMode == SlidableRenderingMode.dismiss
                        ? Colors.blue
                        : Colors.green),
                icon: Icons.shopping_cart_rounded,
                onTap: () async {
                  await _displayTextInputDialog(context, item);
                });
          }),
      secondaryActionDelegate: SlideActionBuilderDelegate(
          actionCount: 1,
          builder: (context, position, animation, renderingMode) {
            return IconSlideAction(
              caption: 'Delete',
              color: renderingMode == SlidableRenderingMode.slide
                  ? Colors.red.withOpacity(animation.value)
                  : Colors.red,
              icon: Icons.delete,
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: Colors.redAccent,
                      title: Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        'Item will be deleted',
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
                              deleteGroceryItem(item).then((value) {
                                if (value) {
                                  setState(() {
                                    groceryItems.remove(item);
                                  });
                                  _showSnackBar(context, 'Delete');
                                } else {
                                  _showSnackBar(context, 'Failed!');
                                }
                              });
                              Navigator.of(context).pop(true);
                            }),
                      ],
                    );
                  },
                );
              },
            );
          }),
    );
  }

  static Widget _actionPane(int position) {
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

  void _showSnackBar(BuildContext context, String text) {
    Scaffold.of(context).showSnackBar(SnackBar(content: Text(text)));
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
      final groceryItemsFuture = helper.getGroceryItems();
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

  void navigateToDetail(GroceryItem groceryItem) async {
    bool result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroceryItemDetail(groceryItem)));
    if (result == true) {
      getData();
    }
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

  Future<bool> deleteGroceryItem(GroceryItem groceryItem) async {
    if (groceryItem.id == null) {
      return false;
    }
    int result = await helper.deleteGroceryItem(groceryItem.id);
    return result != 0 ? true : false;
  }

  Future<bool> groceryIsBought(GroceryItem groceryItem) async {
    if (groceryItem.id == null) {
      return false;
    }
    groceryItem.isBought = true;
    int result = await helper.updateGroceryItem(groceryItem);
    return result != 0 ? true : false;
  }

  void select(String value) async {
    switch (value) {
      case mnuBoughItems:
        bool result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => GroceryItemBoughtList()));
        if (result == true) {
          getData();
        }
        break;
    }
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
            backgroundColor: Colors.blueAccent,
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
                    groceryIsBought(groceryItem).then((value) {
                      if (value) {
                        setState(() {
                          groceryItems.remove(groceryItem);
                          _showSnackBar(context, 'Bought it');
                        });
                      } else {
                        _showSnackBar(context, 'Failed!');
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
}
