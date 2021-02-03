import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moegirl_plus/language/index.dart';
import 'package:moegirl_plus/prefs/index.dart';
import 'package:moegirl_plus/prefs/search.dart';
import 'package:moegirl_plus/utils/ui/dialog/alert.dart';
import 'package:moegirl_plus/views/article/index.dart';
import 'package:moegirl_plus/views/search/views/result/index.dart';
import 'package:one_context/one_context.dart';

class CategorySearchPageRecentSearch extends StatefulWidget {
  CategorySearchPageRecentSearch({Key key}) : super(key: key);

  @override
  _CategorySearchPageRecentSearchState createState() => _CategorySearchPageRecentSearchState();
}

class _CategorySearchPageRecentSearchState extends State<CategorySearchPageRecentSearch> {
  List<SearchingHistory> get searchingHistoryList => searchingHistoryPref.getList();

  @override
  void initState() { 
    super.initState();
  }

  void removeItem(String keyword) async {
    final result = await showAlert(
      content: Lang.searchPage_recentSearch_delSingleRecordCheck,
      visibleCloseButton: true
    );

    if (!result) return;
    searchingHistoryPref.remove(keyword);
    setState(() {});
  }

  void clearList() async {
    final result = await showAlert(
      content: Lang.searchPage_recentSearch_delAllRecordCheck,
      visibleCloseButton: true
    );

    if (!result) return;
    searchingHistoryPref.clear();
    setState(() {});
  }

  void itemWasPressed(SearchingHistory item) {
    searchingHistoryPref.add(item);
    Future.delayed(Duration(milliseconds: 500)).then((_) {
      setState(() {});
    });
    
    if (item.byHint) {
      OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(
        pageName: item.keyword
      ));
    } else {
      OneContext().pushNamed('/search/result', arguments: SearchResultPageRouteArgs(
        keyword: item.keyword
      ));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (searchingHistoryList.length == 0) {
      return Container(
        alignment: Alignment.center,
        child: Text(Lang.searchPage_recentSearch_noData,
          style: TextStyle(
            color: theme.disabledColor,
            fontSize: 18
          ),
        ),
      );
    }
    
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(Lang.searchPage_recentSearch_title,
                style: TextStyle(
                  color: theme.hintColor,
                ),
              ),

              IconButton(
                icon: Icon(Icons.delete),
                iconSize: 20,
                color: theme.disabledColor,
                splashRadius: 18,
                onPressed: clearList,
              )
            ],
          ),
        ),

        SingleChildScrollView(
          child: Column(
            children: searchingHistoryList.map<Widget>((item) =>
              InkWell(
                onTap: () => itemWasPressed(item),
                onLongPress: () => removeItem(item.keyword),
                child: Container(
                  height: 42,
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor,
                        width: 1
                      )
                    )
                  ),
                  child: Text(item.keyword,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.hintColor
                    ),
                  ),
                )
              )
            ).toList(),
          ),
        )
      ],
    );
  }
}