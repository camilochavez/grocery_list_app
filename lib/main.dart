import 'package:flutter/material.dart';
import 'package:grocery_list/screen/groceryItemSlidableList.dart';
import 'package:grocery_list/util/dbhelper.dart';

void main() {
  runApp(GroceryListApp());
}

class GroceryListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DbHelper helper = DbHelper();
    helper.initializeDb().then((result) => helper.getGroceryItems());
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //body: GroceryItemList()
        body: GroceryItemSlidableList());
  }
}
