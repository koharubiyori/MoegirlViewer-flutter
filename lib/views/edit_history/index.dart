import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/api/edit_record.dart';
import 'package:moegirl_plus/components/infinity_list_footer.dart';
import 'package:moegirl_plus/components/structured_list_view.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_back_button.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_title.dart';
import 'package:moegirl_plus/components/styled_widgets/refresh_indicator.dart';
import 'package:moegirl_plus/components/styled_widgets/scrollbar.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/utils/add_infinity_list_loading_listener.dart';
import 'package:moegirl_plus/views/edit_history/components/item.dart';

class EditHistoryPageRouteArgs {
  final String pageName;
  
  EditHistoryPageRouteArgs({
    @required this.pageName
  });
}

class EditHistoryPage extends StatefulWidget {
  final EditHistoryPageRouteArgs routeArgs;
  EditHistoryPage(this.routeArgs, {Key key}) : super(key: key);
  
  @override
  _EditHistoryPageState createState() => _EditHistoryPageState();
}

class _EditHistoryPageState extends State<EditHistoryPage> with AfterLayoutMixin {
  List editHistoryList = [];
  String continueKey;
  num status = 1;

  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final scrollController = ScrollController();

  @override
  void initState() { 
    super.initState();

    // 监听滚动，进行上拉加载
    addInfinityListLoadingListener(scrollController, load);
  }

  @override
  void afterFirstLayout(context) {
    refreshIndicatorKey.currentState.show();
  }

  @override
  void dispose() { 
    scrollController.dispose();
    super.dispose();
  }

  Future<void> load([bool refresh = false]) async {
    if ([2, 2.1, 4, 5].contains(status) && !refresh) return;
    
    setState(() {
      status = refresh ? 2.1 : 2;
      if (refresh) editHistoryList.clear();
    });

    try {
      final data = await EditRecordApi.getEditHistory(widget.routeArgs.pageName, refresh ? null : this.continueKey);

      final String continueKey = data['continue'] != null ? data['continue']['rvcontinue'] : null;
      final List list = data['query']['pages'].values.first['revisions'];

      int status = 3;

      if (continueKey == null && list.length != 0) {
        status = 4;
      }

      if (list.length == 0) {
        status = 5;
      }

      setState(() {
        editHistoryList.addAll(list);
        this.status = status;
        this.continueKey = continueKey;
      });
    } catch(e) {
      print('加载页面编辑历史失败');
      print(e);
    }
  }
  

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: AppBarTitle('版本历史：${widget.routeArgs.pageName}'),
        leading: AppBarBackButton(),
      ),
      body: Observer(
        builder: (context) => (
          Container(
            color: settingsStore.isNightTheme ? theme.backgroundColor : Color(0xffeeeeee),
            child: StyledRefreshIndicator(
              bodyKey: refreshIndicatorKey,
              onRefresh: () => load(true),
              child: StyledScrollbar(
                child: StructuredListView(
                  controller: scrollController,
                  itemDataList: editHistoryList,
                  itemBuilder: (context, itemData, index) {
                    int diffSize = (index + 1 < editHistoryList.length) ? (itemData['size'] - editHistoryList[index + 1]['size']) : null;
                    if (itemData['parentid'] == 0) diffSize = itemData['size'];

                    return EditHistoryItem(
                      pageName: widget.routeArgs.pageName,
                      revId: itemData['revid'],
                      prevRevId: itemData['parentid'],
                      userName: itemData['user'],
                      comment: itemData['comment'],
                      timestamp: itemData['timestamp'],
                      // 接口没有提供更改的大小，只能自己算，这样当前加载的最后一条没法计算，就传null，组件内部进行判断
                      diffSize: diffSize,
                      visibleCurrentCompareButton: index != 0,  // 第一条不显示“当前”按钮
                      visiblePrevCompareButton: itemData['parentid'] != 0,  // 最后一条不显示“之前”按钮
                    );
                  },

                  footerBuilder: () => InfinityListFooter(
                    status: status,
                    onReloadingButtonPrssed: load,
                  ),
                ),
              ),
            ),
          )
        ),
      )
    );
  }
}