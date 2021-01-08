import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/api/edit.dart';
import 'package:moegirl_plus/api/edit_record.dart';
import 'package:moegirl_plus/components/indexed_view.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_back_button.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_icon.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_title.dart';
import 'package:moegirl_plus/components/styled_widgets/circular_progress_indicator.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/request/moe_request.dart';
import 'package:moegirl_plus/utils/ui/dialog/loading.dart';
import 'package:moegirl_plus/utils/ui/toast/index.dart';
import 'package:moegirl_plus/views/compare/components/diff_content.dart';
import 'package:moegirl_plus/views/compare/utils/collect_diff_blocks_from_html.dart';
import 'package:moegirl_plus/views/compare/utils/show_undo_dialog.dart';
import 'package:one_context/one_context.dart';

class ComparePageRouteArgs {
  final int formRevId;
  final int toRevId;
  final String pageName;
  
  ComparePageRouteArgs({
    @required this.formRevId,   // 只传这个会和最新版本比较
    this.toRevId,
    @required this.pageName
  });
}

class ComparePage extends StatefulWidget {
  final ComparePageRouteArgs routeArgs;
  ComparePage(this.routeArgs, {Key key}) : super(key: key);
  
  @override
  _ComparePageState createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> with SingleTickerProviderStateMixin {
  dynamic comparedData;
  List<DiffLine> leftLines = [];
  List<DiffLine> rightLines = [];
  int status = 1;

  TabController tabController;
  // ** 这个功能因为“之后”的tab不会立刻渲染，导致获取不到其中每行的高度，所以相关代码暂时注释 **
  // 为了同步两个tab的滚动，因为每行的高度是不相同的，这里需要进行一次同步，在组件内首次渲染成功时，
  // 将所有行的高度抛出来，对比后每个row取两个tab中取较大的那个，再传回组件
  // Completer<List<List<double>>> beforeRowHeightsCompleter = Completer();
  // Completer<List<List<double>>> afterRowHeightsCompleter = Completer();
  List<List<double>> syncRowHeights;

  @override
  void initState() { 
    super.initState();
    loadComparedData();

    tabController = TabController(length: 2, vsync: this);

    // Future.wait([beforeRowHeightsCompleter.future, afterRowHeightsCompleter.future])
    //   .then((data) {
    //     final beforeRowheights = data[0];
    //     final afterRowHeights = data[1];

    //     setState(() => syncRowHeights = 
    //       beforeRowheights.asMap().map((lineIndex, line) =>
    //         MapEntry(lineIndex,
    //           line.asMap().map((rowIndex, beforeRow) {
    //             final afterRow = afterRowHeights[lineIndex][rowIndex];
    //             // 对比使用较高的值
    //             return MapEntry(rowIndex, beforeRow > afterRow ? beforeRow : afterRow);
    //           }).values.toList()
    //         )
    //       ).values.toList()
    //     );
    //   });
  }

  void loadComparedData() async {
    setState(() => status = 2);
    try {
      final data = await EditRecordApi.compurePage(
        fromTitle: widget.routeArgs.pageName,
        fromRev: widget.routeArgs.formRevId, 
        toTitle: widget.routeArgs.pageName, 
        toRev: widget.routeArgs.toRevId
      );

      // 返回的是一个由tr组成的列表，没有table会导致html解析失败
      final diffBlocks = collectDiffBlocksFromHtml('<table>${data['compare']['*']}</table>');

      setState(() {
        comparedData = data['compare'];
        leftLines = diffBlocks.map((item) => item.left).cast<DiffLine>().toList();
        rightLines = diffBlocks.map((item) => item.right).cast<DiffLine>().toList();
        status = 3;
      });
    } catch(e) {
      if (!(e is MoeRequestError) && !(e is DioError)) rethrow;
      print('加载页面差异数据失败');
      print(e);
      setState(() => status = 0);
    }
  }

  void showUndoDialog() async {
    final result = await showComparePageUndoDialog();
    if (!result.submit) return;
    final String userName = comparedData['touser'];
    final summaryPrefix = '撤销[[Special:Contributions/$userName|$userName]]（[[User_talk:$userName|讨论]]）的版本${widget.routeArgs.toRevId.toString()}';

    showLoading();
    try {
      await EditApi.editArticle(
        pageName: widget.routeArgs.pageName, 
        summary: summaryPrefix + ' 撤销原因：' + result.summary,
        undoRevId: widget.routeArgs.toRevId
      );

      toast('执行撤销成功', position: ToastPosition.center);
    } catch(e) {
      print('执行撤销失败');
      print(e);
      toast('网络错误，请重试');
      Future.microtask(() => showComparePageUndoDialog(result.summary));
    } finally {
      OneContext().pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => (
        Scaffold(
          appBar: AppBar(
            title: AppBarTitle('差异：${widget.routeArgs.pageName}'),
            leading: AppBarBackButton(),
            actions: [
              if (accountStore.isLoggedIn) (
                AppBarIcon(
                  icon: Icons.low_priority, 
                  onPressed: showUndoDialog
                )
              )
            ],
            bottom: TabBar(
              controller: tabController,
              tabs: [
                Tab(text: '之前'),
                Tab(text: '之后')
              ],
            )
          ),

          body: Container(
            alignment: Alignment.center,
            child: IndexedView(
              index: status,
              builders: {
                0: () => TextButton(
                  onPressed: loadComparedData,
                  child: Text('重新加载',
                    style: TextStyle(
                      fontSize: 16
                    ),
                  ),
                ),
                2: () => StyledCircularProgressIndicator(),
                3: () => TabBarView(
                  controller: tabController,
                  children: [
                    CompareDiffContent(
                      userName: comparedData['fromuser'],
                      comment: comparedData['fromcomment'],
                      diffLines: leftLines,
                      // emitRenderedRowHeights: beforeRowHeightsCompleter.complete,
                      // syncRowHeights: syncRowHeights,
                    ),

                    CompareDiffContent(
                      userName: comparedData['touser'],
                      comment: comparedData['tocomment'],
                      diffLines: rightLines,
                      // emitRenderedRowHeights: afterRowHeightsCompleter.complete,
                      // syncRowHeights: syncRowHeights,
                    )
                  ],
                )
              },
            ),
          )
        )
      )
    );
  }
}


