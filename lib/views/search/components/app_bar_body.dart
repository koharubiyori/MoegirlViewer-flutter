import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/prefs/index.dart';
import 'package:moegirl_plus/prefs/search.dart';
import 'package:moegirl_plus/views/search/views/result/index.dart';
import 'package:one_context/one_context.dart';

class SearchPageAppBarBody extends StatefulWidget {
  final void Function(String) onChanged;

  SearchPageAppBarBody({
    Key key,
    @required this.onChanged
  }) : super(key: key);

  @override
  _SearchPageAppBarBodyState createState() => _SearchPageAppBarBodyState();
}

class _SearchPageAppBarBodyState extends State<SearchPageAppBarBody> {
  final editingController = TextEditingController();

  @override
  void initState() { 
    super.initState();
    editingController.addListener(() => setState(() {}));
  }

  void clearInputText() {
    editingController.clear();
    widget.onChanged('');
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
  }

  void textFieldWasSubmitted(String keyword) {
    searchingHistoryPref.add(SearchingHistory(keyword, false));
    OneContext().pushNamed('/search/result', arguments: SearchResultPageRouteArgs(keyword: keyword));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Observer(
      builder: (isNight) => (
        Row(
          children: [
            Expanded(
              child: TextField(
                cursorHeight: 22,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '搜索萌娘百科...',
                  hintStyle: TextStyle(
                    color: settingsStore.isNightTheme ? theme.colorScheme.onPrimary : theme.hintColor
                  )
                ),
                style: TextStyle(
                  fontSize: 16,
                  color: settingsStore.isNightTheme ? theme.colorScheme.onPrimary : theme.textTheme.bodyText1.color
                ),
                controller: editingController,
                onChanged: widget.onChanged,
                onSubmitted: textFieldWasSubmitted,
              ),
            ),

            if (editingController.text != '') (
              CupertinoButton(
                onPressed: clearInputText,
                child: Icon(Icons.close,
                  size: 20,
                  color: theme.disabledColor,
                ),
              )
            )
          ],
        )
      ),
    );
  }
}