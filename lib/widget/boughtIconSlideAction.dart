import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class BoughtIconSlideAction extends StatefulWidget {
  final GestureTapCallback onTap;
  final SlidableRenderingMode renderingMode;
  final Animation<double> animation;
  final int index;
  final String caption;

  const BoughtIconSlideAction(
      {@required this.onTap,
      @required this.renderingMode,
      @required this.animation,
      @required this.index,
      @required this.caption});

  @override
  State<StatefulWidget> createState() =>
      _BoughtIconSlideActionState(onTap, renderingMode, animation, index, caption);
}

class _BoughtIconSlideActionState extends State {
  GestureTapCallback onTap;
  SlidableRenderingMode renderingMode;
  Animation<double> animation;
  int index;
  String caption;
  _BoughtIconSlideActionState(
      this.onTap, this.renderingMode, this.animation, this.index, this.caption);

  @override
  Widget build(BuildContext context) {
    return IconSlideAction(
        caption: caption,
        color: renderingMode == SlidableRenderingMode.slide
            ? Colors.blue.withOpacity(animation.value)
            : (renderingMode == SlidableRenderingMode.dismiss
                ? Colors.blue
                : Colors.green),
        icon: Icons.shopping_cart_rounded,
        onTap: onTap);
  }
}
