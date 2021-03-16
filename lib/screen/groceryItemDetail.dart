import 'package:flutter/material.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'package:grocery_list/util/dbhelper.dart';

DbHelper helper = DbHelper();
final List<String> choices = const <String>[
  'Delete GroceryItem',
  'Back to List'
];

const mnuDelete = 'Delete GroceryItem';
const mnuBack = 'Back to List';

class GroceryItemDetail extends StatefulWidget {
  final GroceryItem groceryItem;
  GroceryItemDetail(this.groceryItem);

  @override
  State<StatefulWidget> createState() => GroceryItemDetailState(groceryItem);
}

class GroceryItemDetailState extends State {
  GroceryItem groceryItem;
  GroceryItemDetailState(this.groceryItem);
  final _priorities = ["High", "Medium", "Low"];
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    nameController.text = groceryItem.name;
    quantityController.text = groceryItem.quantity.toString();
    priceController.text = groceryItem.price.toString();
    TextStyle textStyle = TextStyle(
        fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18.0);

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 40.0,
          title: Text(groceryItem.name.length == 0
              ? "New Grocery Item"
              : groceryItem.name),
          backgroundColor: Colors.teal[200],
          actions: <Widget>[
            PopupMenuButton(
              icon:Icon(Icons.mediation),
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
            child: Padding(
                padding: EdgeInsets.only(top: 35.0, left: 10.0, right: 10.0),
                child: ListView(
                  children: <Widget>[
                    Column(children: <Widget>[
                      TextField(
                          controller: nameController,
                          style: textStyle,
                          onChanged: (value) => this.updateTitle(),
                          decoration: InputDecoration(
                              labelText: "Name",
                              labelStyle: textStyle,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0)))),
                      Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15.0),
                          child: TextField(
                              keyboardType: TextInputType.number,
                              controller: quantityController,
                              style: textStyle,
                              onChanged: (value) => this.updateQuantity(),
                              decoration: InputDecoration(
                                  labelText: "Quantity",
                                  labelStyle: textStyle,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))))),
                      Padding(
                          padding: EdgeInsets.only(top: 15, bottom: 15.0),
                          child: TextField(
                              keyboardType: TextInputType.number,
                              controller: priceController,
                              style: textStyle,
                              onChanged: (value) => this.updatePrice(),
                              decoration: InputDecoration(
                                  labelText: "Price",
                                  labelStyle: textStyle,
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))))),
                      ListTile(
                          title: Container(
                              child: new Theme(
                                  data: Theme.of(context).copyWith(
                                    canvasColor: Colors.blue.shade200,
                                  ),
                                  child: DropdownButton<String>(
                                      items: _priorities.map((String value) {
                                        return DropdownMenuItem<String>(
                                            value: value, child: Text(value));
                                      }).toList(),
                                      style: textStyle,
                                      value: retrievePriority(
                                          groceryItem.priority),
                                      onChanged: (value) =>
                                          updatePriority(value)))))
                    ])
                  ],
                ))),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            save();
          },
          tooltip: "Save new Grocery Item",
          child: new Icon(Icons.save),
        ));
  }

  void select(String value) async {
    int result;
    switch (value) {
      case mnuDelete:
        Navigator.pop(context, true);
        if (groceryItem.id == null) {
          return;
        }
        result = await helper.deleteGroceryItem(groceryItem.id);
        if (result != 0) {
          AlertDialog alertDialog = AlertDialog(
            title: Text('Delete GroceryItem'),
            content: Text('The GroceryItem has been deleted'),
          );
          showDialog(context: context, builder: (_) => alertDialog);
        }
        break;
      case mnuBack:
        Navigator.pop(context, true);
        break;
    }
  }

  void save() {
    if (groceryItem.id != null) {
      helper.updateGroceryItem(this.groceryItem);
    } else {
      helper.insertGroceryItem(this.groceryItem);
    }
    Navigator.pop(context, true);
  }

  void updatePriority(String value) {
    switch (value) {
      case "High":
        groceryItem.priority = 1;
        break;
      case "Medium":
        groceryItem.priority = 2;
        break;
      case "Low":
        groceryItem.priority = 3;
        break;
    }
    setState(() {});
  }

  String retrievePriority(int value) {
    return _priorities[value - 1];
  }

  void updateTitle() {
    groceryItem.name = nameController.text;
  }

  void updateQuantity() {
    groceryItem.quantity = int.parse(quantityController.text);
  }

  void updatePrice() {
    groceryItem.price = int.parse(priceController.text);
  }
}
