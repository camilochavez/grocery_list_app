import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DeleteIconSlideAction extends StatefulWidget {
  final GestureTapCallback onDialogOkPressed;
  final SlidableRenderingMode renderingMode;
  final Animation<double> animation;

  const DeleteIconSlideAction(
      {@required this.onDialogOkPressed,
      @required this.renderingMode,
      @required this.animation});

  @override
  State<StatefulWidget> createState() =>
      _DeleteIconSlideActionState(onDialogOkPressed, renderingMode, animation);
}

class _DeleteIconSlideActionState extends State {
  GestureTapCallback onDialogOkPressed;
  SlidableRenderingMode renderingMode;
  Animation<double> animation;

  _DeleteIconSlideActionState(
      this.onDialogOkPressed, this.renderingMode, this.animation);

  @override
  Widget build(BuildContext context) {
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
                    onPressed: onDialogOkPressed),
              ],
            );
          },
        );
      },
    );
  }
}
