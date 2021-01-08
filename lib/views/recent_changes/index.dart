import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/api/edit_record.dart';
import 'package:moegirl_plus/api/watch_list.dart';
import 'package:moegirl_plus/components/structured_list_view.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_back_button.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_icon.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_title.dart';
import 'package:moegirl_plus/components/styled_widgets/refresh_indicator.dart';
import 'package:moegirl_plus/components/styled_widgets/scrollbar.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/prefs/index.dart';
import 'package:moegirl_plus/request/moe_request.dart';
import 'package:moegirl_plus/utils/ui/toast/index.dart';
import 'package:moegirl_plus/utils/watch_list_manager.dart';
import 'package:moegirl_plus/views/recent_changes/components/item.dart';
import 'package:moegirl_plus/views/recent_changes/utils/show_options_dialog.dart';

class RecentChangesPageRouteArgs {
  
  RecentChangesPageRouteArgs();
}

class RecentChangesPage extends StatefulWidget {
  final RecentChangesPageRouteArgs routeArgs;
  RecentChangesPage(this.routeArgs, {Key key}) : super(key: key);
  
  @override
  _RecentChangesPageState createState() => _RecentChangesPageState();
}

class _RecentChangesPageState extends State<RecentChangesPage> with AfterLayoutMixin {
  List<String> watchList = [];
  List changesList = []; // 存放时间字符串或列表数据
  num status = 1;
  
  RecentChangesOptions get recentChangesOptions => otherPref.recentChangesOptions ?? RecentChangesOptions();
  set recentChangesOptions(RecentChangesOptions value) => otherPref.recentChangesOptions = value;

  bool get isWatchListMode => recentChangesOptions.isWatchListMode; // true，全部最近更改；false，监视列表内最近更改
  set isWatchListMode(bool value) => recentChangesOptions = recentChangesOptions.copyWith(isWatchListMode: value);
  
  final scrollController = ScrollController();
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  @override
  void initState() { 
    super.initState();
    WatchListManager.getList()
      .then((list) => setState(() => watchList = list));
  }

  @override
  void afterFirstLayout(BuildContext context) {
    refreshIndicatorKey.currentState.show();
  }

  @override
  void dispose() { 
    scrollController.dispose();
    super.dispose();
  }

  Future<void> loadChanges() async {
    if (status == 2) return;
    setState(() => status = 2);

    try {
      final options = recentChangesOptions;
      List changesData = [];

      if (isWatchListMode && accountStore.isLoggedIn) {
        changesData = await WatchListApi.getChanges(
          startISO: DateTime.now().subtract(Duration(days: options.daysAgo)).toIso8601String(),
          limit: options.totalLimit,
          includeMinor: options.includeMinor,
          includeRobot: options.includeRobot
        );
      } else {
        changesData = await EditRecordApi.getRecentChanges(
          startISO: DateTime.now().subtract(Duration(days: options.daysAgo)).toIso8601String(),
          limit: options.totalLimit,
          excludeUser: !options.includeSelf && accountStore.isLoggedIn ? accountStore.userName : null,
          includeMinor: options.includeMinor,
          includeRobot: options.includeRobot
        ); 
      }

      final dayChangesList = changesData.fold<Map<String, List>>({}, (result, item) {
        final chineseWeeks = ['', '一', '二', '三', '四', '五', '六', '日'];
        final date = DateTime.parse(item['timestamp']);
        final dateStr = '${date.year}年${date.month}月${date.day}日（星期${chineseWeeks[date.weekday]}）';
        if(!result.containsKey(dateStr)) result[dateStr] = [];
        result[dateStr].add(item);

        return result;
      })
        .map((index, item) => MapEntry(index, changesDataWithDetails(item)))  // 为每天的更改数据添加详情
        .map((index, item) => MapEntry(index, [index, ...item]))  // 将dateStr放到列表数据的头部
        .values.reduce((result, item) => [...result, ...item]);   // 丢弃作为key的dateStr，将所有列表数据合并

      setState(() {
        changesList = dayChangesList;
        status = 3;
      });
    } catch(e) {
      if (!(e is DioError) && !(e is MoeRequestError)) rethrow;
      print('加载最近更改列表失败');
      print(e);
      setState(() => status = 0);
    }
  }

  List changesDataWithDetails(List data) {
    // 收集同页面编辑，并放入details字段
    final dataWithDetails = data.fold<List>([], (result, item) {
      if (result.every((resultItem) => resultItem['title'] != item['title'])) {
        result.add({ 
          ...item, 
          'details': [item],  // 本身也算作详细信息的一部分
          'users': []
        });
      } else {
        result.singleWhere((resultItem) => resultItem['title'] == item['title'])['details'].add(item);
      }

      return result;
    });

    // 添加users和各自的编辑次数
    dataWithDetails.forEach((item) {
      item['details'].forEach((detailItem) {
        final foundUserIndex = item['users'].indexWhere((user) => user['name'] == detailItem['user']);
        if (foundUserIndex != -1) {
          item['users'][foundUserIndex]['total']++;
        } else {
          item['users'].add({ 'name': detailItem['user'], 'total': 1 });
        }
      });
    });

    return dataWithDetails;
  }

  void toggleMode() {
    setState(() {
      isWatchListMode = !isWatchListMode;
      changesList.clear();
    });
    refreshIndicatorKey.currentState.show();
    toast('切换为${isWatchListMode ? '监视列表' : '全部列表'}模式');
  }

  void showOptionsDialog() async {
    final newOptions = await showRecentChangesOptionsDialog(context, recentChangesOptions);
    recentChangesOptions = newOptions;
    refreshIndicatorKey.currentState.show();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Observer(
      builder: (context) => (
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: AppBarTitle('最近更改'),
            leading: AppBarBackButton(),
            actions: [
              if (accountStore.isLoggedIn) (
                AppBarIcon(
                  icon: isWatchListMode ? MaterialCommunityIcons.eye : Icons.format_indent_decrease,
                  onPressed: toggleMode,
                )
              ),
              
              AppBarIcon(
                icon: Icons.tune,
                onPressed: showOptionsDialog,
              )
            ],
          ),
          body: Container(
            color: settingsStore.isNightTheme ? theme.backgroundColor : Color(0xffeeeeee),
            child: StyledScrollbar(
              child: StyledRefreshIndicator(
                bodyKey: refreshIndicatorKey,
                onRefresh: loadChanges,
                child: StructuredListView(
                  itemDataList: changesList,          
                  itemBuilder: (context, itemData, index) {
                    if (itemData is String) {
                      return Container(
                        margin: EdgeInsets.only(top: 7, bottom: 8, left: 10),
                        child: Text(itemData,
                          style: TextStyle(
                            fontSize: 16
                          ),
                        ),
                      ); 
                    } else {
                      return RecentChangesItem(
                        type: itemData['type'],
                        pageName: itemData['title'],
                        comment: itemData['comment'],
                        users: itemData['users'],
                        newLength: itemData['newlen'],
                        oldLength: itemData['oldlen'],
                        revId: itemData['revid'],
                        oldRevId: itemData['old_revid'],
                        dateISO: itemData['timestamp'],
                        editDetails: itemData['details'],
                        pageWatched: (isWatchListMode && accountStore.isLoggedIn) ? false : watchList.contains(itemData['title']),
                      );
                    }
                  },
                ),
              ),
            ),
          )
        )
      ),
    );
  }
}