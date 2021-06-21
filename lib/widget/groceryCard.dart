import 'package:flutter/material.dart';
import 'package:grocery_list/model/groceryItem.dart';
import 'package:grocery_list/style/appStyle.dart';

class GroceryCard extends StatefulWidget {
  final GestureTapCallback onTap;
  final ValueChanged<bool> onChanged;
  final GroceryItem groceryItem;

  GroceryCard(
      {@required this.onTap, @required this.groceryItem, this.onChanged});

  @override
  State<StatefulWidget> createState() =>
      _GroceryCardState(onTap, groceryItem, onChanged);
}

class _GroceryCardState extends State {
  GestureTapCallback onTap;
  ValueChanged<bool> onChanged;
  GroceryItem groceryItem;

  _GroceryCardState(this.onTap, this.groceryItem, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white38,
      elevation: 2.0,
      child: Row(children: <Widget>[
        Container(
            width: MediaQuery.of(context).size.width - 80,
            height: 70.0,
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: AppStyle.getColor(this.groceryItem.priority),
                  child: Text(this.groceryItem.quantity.toString())),
              title: Text(this.groceryItem.name, style: AppStyle.titleStyle),
              subtitle: Text("\$" + this.groceryItem.price.toString(),
                  style: AppStyle.subTitleStyle),
              onTap: onTap,
            )),
        if (onChanged != null)
          Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: Checkbox(
                checkColor: Colors.white,
                activeColor: Colors.lightBlueAccent,
                value: this.groceryItem.isBought,
                onChanged: this.onChanged,
              ))
      ]),
    );
  }
}
