import 'package:flutter/material.dart';
import 'package:grocery_list/screen/groceryItemBoughtList.dart';
import 'package:grocery_list/screen/groceryItemSlidableList.dart';

import 'groceryItemBoughtList.dart';
import 'groceryItemSlidableList.dart';

class GroceryPageView extends StatefulWidget {
  @override
  _GroceryPageViewState createState() => _GroceryPageViewState();
}

class _GroceryPageViewState extends State<GroceryPageView> {

  PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
      children: [
        GroceryItemSlidableList(),
        GroceryItemBoughtList()        
      ],
    );
  }
}