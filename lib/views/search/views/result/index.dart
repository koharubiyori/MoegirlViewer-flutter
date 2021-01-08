import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/api/search.dart';
import 'package:moegirl_plus/components/indexed_view.dart';
import 'package:moegirl_plus/components/structured_list_view.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_back_button.dart';
import 'package:moegirl_plus/components/styled_widgets/circular_progress_indicator.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/utils/add_infinity_list_loading_listener.dart';
import 'package:moegirl_plus/views/article/index.dart';
import 'package:one_context/one_context.dart';

import 'components/item.dart';

class SearchResultPageRouteArgs {
  final String keyword;

  SearchResultPageRouteArgs({
    @required this.keyword
  });
}

class SearchResultPage extends StatefulWidget {
  final SearchResultPageRouteArgs routeArgs;
  SearchResultPage(this.routeArgs, {Key key}) : super(key: key);
  
  @override
  _SearchResultPageState createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  List resultList = [];
  int resultTotal;
  int status = 1;
  final scrollController = ScrollController();

  @override
  void initState() { 
    super.initState();
    loadList();

    // 监听滚动，进行上拉加载
    addInfinityListLoadingListener(scrollController, loadList);
  }

  @override
  void dispose() { 
    scrollController.dispose();
    super.dispose();
  }

  void loadList() async {
    if ([4, 2].contains(status)) return;
    setState(() => status = 2);

    try {
      final data = await SearchApi.search(widget.routeArgs.keyword, resultList.length);
      if (data['query']['searchinfo']['totalhits'] == 0) {
        setState(() => status = 5);
        return;
      }

      var nextStatus = 3;
      if (data['query']['searchinfo']['totalhits'] == resultList.length + data['query']['search'].length) {
        nextStatus = 4;
      }

      setState(() {
        resultTotal = data['query']['searchinfo']['totalhits'];
        resultList.addAll(data['query']['search']);
        status = nextStatus;
      });
    } catch(e) {
      print('加载搜索结果失败');
      print(e);
      setState(() => status = 0);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Observer(
      builder: (context) => (
        Scaffold(
          appBar: AppBar(
            brightness: settingsStore.isNightTheme ? Brightness.dark : Brightness.light,
            backgroundColor: settingsStore.isNightTheme ? theme.primaryColor : Colors.white,
            elevation: 3,
            leading: AppBarBackButton(
              color: settingsStore.isNightTheme ? theme.colorScheme.onPrimary : theme.hintColor,
            ),
            title: Text('搜索：${widget.routeArgs.keyword}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: settingsStore.isNightTheme ? theme.colorScheme.onPrimary : theme.hintColor
              ),
            ),
          ),

          body: Container(
            child: StructuredListView(
              padding: EdgeInsets.only(bottom: 10),
              itemDataList: resultList,
              controller: scrollController,
              headerBuilder: () {
                if (status != 3) return Container(width: 0, height: 0);
                return Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 3, left: 10, right: 10),
                  // ignore: unnecessary_brace_in_string_interps
                  child: Text('共搜索到${resultTotal}条结果。',
                    style: TextStyle(
                      color: theme.hintColor
                    ),
                  ),
                );
              },

              itemBuilder: (context, itemData, index) {
                return SearchResultItem(
                  key: Key(itemData['title']),
                  data: itemData,
                  keyword: widget.routeArgs.keyword,
                  onPressed: (pageName) => OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(pageName: pageName)),
                );
              },
              
              footerBuilder: () => IndexedView(
                index: status,
                builders: {
                  2: () => Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 15, bottom: 5),
                    child: StyledCircularProgressIndicator(),
                  ),

                  0: () => Container(
                    child: CupertinoButton(
                      onPressed: loadList,
                      child: Text('加载失败，点击重试',
                        style: TextStyle(color: theme.hintColor),
                      ),
                    ),
                  ),

                  4: () => Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 15, bottom: 5),
                    child: Text('已经没有啦',
                      style: TextStyle(color: theme.disabledColor),
                    ),
                  ),
                },
              ),
            )
          )
        )
      )
    );
  }
}