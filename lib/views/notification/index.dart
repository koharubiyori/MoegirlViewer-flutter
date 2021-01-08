import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/api/notification.dart';
import 'package:moegirl_plus/components/infinity_list_footer.dart';
import 'package:moegirl_plus/components/structured_list_view.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_back_button.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_icon.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_title.dart';
import 'package:moegirl_plus/components/styled_widgets/refresh_indicator.dart';
import 'package:moegirl_plus/components/styled_widgets/scrollbar.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/request/moe_request.dart';
import 'package:moegirl_plus/utils/add_infinity_list_loading_listener.dart';
import 'package:moegirl_plus/utils/ui/dialog/loading.dart';
import 'package:moegirl_plus/utils/ui/toast/index.dart';
import 'package:moegirl_plus/views/article/index.dart';
import 'package:moegirl_plus/views/notification/components/item.dart';
import 'package:one_context/one_context.dart';

class NotificationPageRouteArgs {
  
  NotificationPageRouteArgs();
}

class NotificationPage extends StatefulWidget {
  final NotificationPageRouteArgs routeArgs;
  NotificationPage(this.routeArgs, {Key key}) : super(key: key);
  
  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> with AfterLayoutMixin {
  final notificationList = [];
  num status = 1;
  String continueKey;
  
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
      if (refresh) notificationList.clear();
    });

    try {
      final data = await NotificationApi.getList(refresh ? null : continueKey);
      final Map notiData = data['query']['notifications'];
      int status = 3;

      if (notiData['continue'] == null && notiData['list'].length != 0) {
        status = 4;        
      }

      if (notiData['list'].length == 0) {
        status = 5;
      }

      setState(() {
        notificationList.addAll(notiData['list'].reversed);
        this.status = status;
        continueKey = notiData['continue'];
      });
    } catch(e) {
      if (!(e is DioError) && !(e is MoeRequestError)) rethrow;
      print('获取通知列表失败');
      print(e);
      setState(() => status = 0);
    }
  }

  void markAllAsReaded() async {
    showLoading();
    try {
      await accountStore.markAllNotificationAsRead();
      setState(() => notificationList.forEach((item) => item['read'] = ''));
      toast('标记所有为已读');
    } catch(e) {
      print('标记全部通知为已读失败');
      print(e);
      toast('网络错误，请重试');
    } finally {
      OneContext().pop();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle('通知'),
        leading: AppBarBackButton(),
        elevation: 0,
        actions: [AppBarIcon(icon: Icons.done_all, onPressed: markAllAsReaded)],
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
                  itemDataList: notificationList,
                  itemBuilder: (context, itemData, index) => (
                    NotificationPageItem(
                      notificationData: itemData,
                      onPressed: () {
                        if (itemData['title'] == null) return;
                        OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(pageName: itemData['title']['full']));
                      },
                    )
                  ),

                  footerBuilder: () => InfinityListFooter(
                    status: status,
                    onReloadingButtonPrssed: load,
                  ),
                ),
              )
            ),
          )
        ),
      )
    );
  }
}