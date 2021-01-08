
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/themes.dart';

Future<String> showThemeSelectionDialog({
  @required BuildContext context,
  @required String initialValue,
  @required void Function(String themeName) onChange,
}) {
  final completer = Completer<String>();

  showDialog(
    context: context,
    barrierDismissible: false,
    useRootNavigator: false,
    builder: (context) {
      return _ThemeSelectionDialog(
        initialValue: initialValue,
        completer: completer,
        onChange: onChange,
      );
    }
  )
    .then((value) {
      if (!completer.isCompleted) completer.complete(initialValue);
    });

  return completer.future;
}

class _ThemeSelectionDialog extends StatefulWidget {
  final String initialValue;
  final Completer completer;
  final void Function(String themeName) onChange;
  
  _ThemeSelectionDialog({
    @required this.initialValue,
    @required this.completer,
    @required this.onChange,
    Key key
  }) : super(key: key);

  @override
  _ThemeSelectionDialogState createState() => _ThemeSelectionDialogState();
}

class _ThemeSelectionDialogState extends State<_ThemeSelectionDialog> {
  String selected = '';
  final themesData = themes.keys
    .map((item) => _ThemeSelectionItem(item, themes[item].primaryColor));
  
  @override
  void initState() { 
    super.initState();
    selected = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('选择主题'),
      backgroundColor: theme.colorScheme.surface,
      content: SingleChildScrollView(
        child: Observer(
          builder: (context) => (
            Wrap(
              alignment: WrapAlignment.center,
              children: themesData.map((item) =>
                Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(right: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: item.color,
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                    border: settingsStore.isNightTheme ? Border.all(width: 3, color: theme.disabledColor) : null
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      splashColor: Colors.white.withOpacity(0.5),
                      highlightColor: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.all(Radius.circular(45)),
                      onTap: () => setState(() {
                        selected = item.name;
                        widget.onChange(item.name);
                      }),
                      child:selected == item.name ?
                        SizedBox.expand(
                          child: Icon(Icons.check, 
                            color: Colors.white,
                            size: 25,
                          ),
                        )
                      : null,
                    ),
                  ),
                )
              ).toList(),
            )
          ),
        ),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(theme.splashColor),
            foregroundColor: MaterialStateProperty.all(theme.hintColor)
          ),
          onPressed: () {
            Navigator.of(context).pop();
            widget.completer.complete(widget.initialValue);
          },
          child: Text('取消'),
        ), 
        TextButton(
          child: Text('确定'),
          onPressed: () {
            Navigator.of(context).pop();
            widget.completer.complete(selected);
          },
        ),
      ],
    );
  }
}

class _ThemeSelectionItem {
  final String name;
  final Color color;

  _ThemeSelectionItem(this.name, this.color);
}

