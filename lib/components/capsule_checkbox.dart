import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/components/touchable_opacity.dart';
import 'package:moegirl_plus/mobx/index.dart';

class CapsuleCheckbox extends StatefulWidget {
  final String title;
  final bool value;
  final void Function(bool newValue) onPressed;

  CapsuleCheckbox({
    this.title,
    this.value,
    this.onPressed,
    Key key
  }) : super(key: key);

  @override
  _CapsuleCheckboxState createState() => _CapsuleCheckboxState();
}

class _CapsuleCheckboxState extends State<CapsuleCheckbox> {
  final focusNode = FocusNode();

  @override
  void dispose() { 
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return TouchableOpacity(
      onPressed: () => widget.onPressed(!widget.value),
      child: Observer(
        builder: (context) => (
          Container(
            height: 34,
            padding: EdgeInsets.only(left: 7, right: 3),
            decoration: BoxDecoration(
              color: settingsStore.isNightTheme ? theme.dividerColor : theme.primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(17))
            ),
            child: IntrinsicWidth(
              child: Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 3),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: Theme(
                        data: ThemeData(
                          unselectedWidgetColor: settingsStore.isNightTheme ? theme.disabledColor : theme.primaryColorDark,
                        ),
                        child: Checkbox(
                          focusNode: focusNode,
                          activeColor: theme.colorScheme.onPrimary,
                          checkColor: settingsStore.isNightTheme ? theme.primaryColor : theme.accentColor,
                          value: widget.value,
                          onChanged:widget. onPressed,
                        ),
                      )
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 5, bottom: 1.5),
                    child: Text(widget.title,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontSize: 14
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ),
      ),
    );
  }
}