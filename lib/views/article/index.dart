import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:moegirl_plus/api/watch_list.dart';
import 'package:moegirl_plus/components/article_view/index.dart';
import 'package:moegirl_plus/generated/l10n.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/utils/check_if_nonauto_confirmed_to_show_edit_alert.dart';
import 'package:moegirl_plus/utils/media_wiki_namespace.dart';
import 'package:moegirl_plus/utils/reading_history_manager.dart';
import 'package:moegirl_plus/utils/route_aware.dart';
import 'package:moegirl_plus/utils/status_bar_height.dart';
import 'package:moegirl_plus/utils/trim_html.dart';
import 'package:moegirl_plus/utils/ui/dialog/alert.dart';
import 'package:moegirl_plus/utils/ui/dialog/loading.dart';
import 'package:moegirl_plus/utils/ui/toast/index.dart';
import 'package:moegirl_plus/views/article/components/header/index.dart';
import 'package:moegirl_plus/views/comment/index.dart';
import 'package:moegirl_plus/views/drawer/index.dart';
import 'package:moegirl_plus/views/edit/index.dart';
import 'package:moegirl_plus/views/edit_history/index.dart';
import 'package:one_context/one_context.dart';
import 'package:share/share.dart';

import 'components/comment_button/index.dart';
import 'components/contents/index.dart';
import 'components/header/components/animation.dart';
import 'components/header/index.dart';

class ArticlePageRouteArgs {
  final String pageName;
  final String displayPageName;
  final String anchor;
  final int revId; // 修订版本id，传入会加载历史版本

  ArticlePageRouteArgs({
    @required this.pageName, 
    this.displayPageName, 
    this.anchor,
    this.revId
  });
}

class ArticlePage extends StatefulWidget {
  final ArticlePageRouteArgs routeArgs;
  ArticlePage(this.routeArgs, {Key key}) : super(key: key);

  // 编辑后返回这个页面检查这个字段，如果为真则reload
  static bool popNextReloadMark = false;

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> with 
  RouteAware, 
  SubscriptionForRouteAware,
  AfterLayoutMixin
{
  S get i10n => S.of(context);
  ArticlePageRouteArgs routeArgs;
  String truePageName;
  String displayPageName;
  int pageId;
  List contentsData;

  Map pageInfo;
  bool isWatched = false;
  bool visibleCommentButton = false;  // 只有主空间和用户页显示评论
  bool editAllowed; // 权限不足将无法编辑
  bool editFullDisabled = false; // 讨论页禁止编辑全文
  bool visibleTalkButton = false;
  bool talkPageExists = true;

  bool enabledHeaderMoreButton = false; // 加载完毕确认条目真实存在之前禁用更多按钮
  // 这里要存一个不变的值，防止用户改变stopAudioOnLeave的设置后，前后值不一致造成麻烦
  final stopAudioOnLeave = settingsStore.stopAudioOnLeave;
  // 用于编程式打开条目目录
  final scaffoldKey = GlobalKey<ScaffoldState>();

  ArticlePageHeaderAnimationController headerController;
  ArticlePageCommentButtonAnimationMainController commentButtonController;
  ArticleViewController articleViewController;

  bool get isPageHistoryVersion => widget.routeArgs.revId != null;

  @override
  void initState() {
    super.initState();
    truePageName = widget.routeArgs.pageName;
    displayPageName = widget.routeArgs.displayPageName ?? widget.routeArgs.pageName;

    // 监听评论状态变化，播放评论按钮ripple动画
    var prevpageCommentStatus = 1;
    autorun((reaction) {
      final commentStatus = commentStore.data[pageId]?.status ?? 1;

      if (prevpageCommentStatus == 2.1 && commentStatus >= 3) {
        commentButtonController.ripple();
        reaction.dispose(); // 只播放一次，防止下拉刷新之后回来再播一次动画
      }

      prevpageCommentStatus = commentStatus;
    });

    // 监听登录状态变化，重新检查编辑权限
    autorun((_) {
      if (accountStore.isLoggedIn) setStateFromPageInfo(pageInfo);
    });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    if (isPageHistoryVersion) toast(i10n.articlePage_historyModeEditDisabledHint);
  }

  @override
  void didPushNext() {
    super.didPush();
    
    if (stopAudioOnLeave) {
      articleViewController.injectScript([
        pauseAllAudioJsStr,
        disableAllIframeJsStr
      ].join(';'));
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    
    headerController.show();

    if (stopAudioOnLeave) {
      articleViewController.injectScript(enableAllIframeJsStr);
    }

    if(ArticlePage.popNextReloadMark) {
      ArticlePage.popNextReloadMark = false;
      refresh();
    }
  }

  void refresh() {
    articleViewController.reload(true);
  }

  void articleDataWasLoaded(dynamic articleData, dynamic pageInfo) async {
    final parse = articleData['parse'];
    setState(() {
      truePageName = parse['title'];
      displayPageName = parse['displaytitle'];
      pageId = parse['pageid'];
      enabledHeaderMoreButton = true;
    });

    await setStateFromPageInfo(pageInfo);

    if (visibleCommentButton) {
      if (commentStore.data[pageId] == null) {
        commentStore.loadNext(pageId);
      }

      commentButtonController.show();
    }
    
    ReadingHistoryManager.add(truePageName, widget.routeArgs.pageName);
  }

  void articleWasMissed(String pageName) async {
    await showAlert(content: i10n.articlePage_articleMissedHint);
    OneContext().pop();
  }

  // 这里根据接口拿到的pageInfo进行一些和页面属性有关的设置
  Future<void> setStateFromPageInfo(dynamic pageInfo) async {

    bool editAllowed = false;
    if (accountStore.isLoggedIn) {
      final userInfo = await accountStore.getUserInfo();
      final isUnprotectednessPage = pageInfo['protection'].every((item) => item['type'] != 'edit');
      final isSysop = userInfo['groups'].contains('sysop');
      final isPatroller = userInfo['groups'].contains('patroller');
      if (isUnprotectednessPage || isSysop) {
        editAllowed = true;
      } else if(isPatroller) {
        final isPatrollerAllowed = pageInfo['protection'].singleWhere((item) => item['type'] == 'edit', orElse: () => {})['level'] == 'patrolleredit';
        editAllowed = isPatrollerAllowed;
      } else {
        editAllowed = false;
      }
    }
    
    setState(() {
      this.pageInfo = pageInfo;
      isWatched = pageInfo.containsKey('watched');
      visibleCommentButton = [
        getNsCode(MediaWikiNamespace.main), 
        getNsCode(MediaWikiNamespace.user),
      ].contains(pageInfo['ns']);
      this.editAllowed = editAllowed && !isPageHistoryVersion;  // 历史版本禁止编辑
      editFullDisabled = isTalkPage(pageInfo['ns']);
      visibleTalkButton = !isTalkPage(pageInfo['ns']);
      talkPageExists = pageInfo.containsKey('talkid');
    });
  }

  double lastScrollY = 0;
  void webViewScrollWasChanged(dynamic scrollY) {
    if (scrollY < 100) {
      headerController.show();
      commentButtonController.show();
    } else if (lastScrollY < scrollY) {
      headerController.hide();
      commentButtonController.hide();
    } else {
      headerController.show();
      commentButtonController.show();
    }

    lastScrollY = scrollY;
  }

  void headerMoreMenuWasPressed(ArticlePageHeaderMoreMenuValue value) async {
    if (value == ArticlePageHeaderMoreMenuValue.refresh) {
      refresh();
    }
    if (value == ArticlePageHeaderMoreMenuValue.edit) {
      final isNonautoConfirmed = await checkIfNonautoConfirmedToShowEditAlert(truePageName);
      if (isNonautoConfirmed) return;
      
      OneContext().pushNamed('/edit', arguments: EditPageRouteArgs(
        editRange: EditPageEditRange.full,
        pageName: truePageName,
      ));
    }
    if (value == ArticlePageHeaderMoreMenuValue.addSection) {
      final isNonautoConfirmed = await checkIfNonautoConfirmedToShowEditAlert(truePageName, 'new');
      if (isNonautoConfirmed) return;

      OneContext().pushNamed('/edit', arguments: EditPageRouteArgs(
        editRange: EditPageEditRange.section,
        pageName: truePageName,
        section: 'new'
      ));
    }
    if (value == ArticlePageHeaderMoreMenuValue.login) {
      OneContext().pushNamed('/login');
    }
    if (value == ArticlePageHeaderMoreMenuValue.toggleWatchList) {
      try {
        showLoading();
        await WatchListApi.setWatchStatus(truePageName, !isWatched);
        toast(i10n.articlePage_watchListOperatedHint(isWatched));
        setState(() => isWatched = !isWatched);
      } catch(e) {
        toast(e.toString());
      } finally {
        OneContext().pop();
      }
    }
    if (value == ArticlePageHeaderMoreMenuValue.gotoTalk) {
      final talkPageName = pageInfo['ns'] == 0 ? '${i10n.talkPagePrefix}:$truePageName' : truePageName.replaceFirst(':', '_talk:');
      
      if (talkPageExists) {
        OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(
          pageName: talkPageName,
        ));
      } else {
        final result = await showAlert(
          content: i10n.articlePage_talkPageMissedHint,
          visibleCloseButton: true,
        );
        if (!result) return;

        OneContext().pushNamed('/edit', arguments: EditPageRouteArgs(
          editRange: EditPageEditRange.section,
          pageName: talkPageName,
          section: 'new',
        ));
      }
    }
    if (value == ArticlePageHeaderMoreMenuValue.gotoVersionHistory) {
      OneContext().pushNamed('/editHistory', arguments: EditHistoryPageRouteArgs(pageName: truePageName));
    }
    if (value == ArticlePageHeaderMoreMenuValue.share) {
      Share.share('${i10n.siteName} - ${widget.routeArgs.pageName} https://mzh.moegirl.org.cn/index.php?curid=$pageId', subject: i10n.articlePage_shareSuffix);
    }
    if (value == ArticlePageHeaderMoreMenuValue.openContents) {
      scaffoldKey.currentState.openEndDrawer();
    }
  }

  void commentButtonWasPressed() {
    final currentCommentData = commentStore.data[pageId];
    if (currentCommentData.status == 0) {
      commentStore.loadNext(pageId);
      return;
    }
    if ([2, 2.1].contains(currentCommentData.status)) {
      toast(i10n.articlePage_commentButtonLoadingHint);
      return;
    }
    OneContext().pushNamed('/comment', arguments: CommentPageRouteArgs(
      pageName: truePageName, 
      pageId: pageId
    ));
  }

  void jumpToAnchor(String anchor) {
    final minusOffset = kToolbarHeight + statusBarHeight;
    articleViewController.injectScript('moegirl.method.link.gotoAnchor("$anchor", -$minusOffset)');
  }

  final injectedWindowScrollEventHandlerStr = '''
    window.onscroll = () => _postMessage('windowScrollChange', window.scrollY)
  ''';

  String get commentButtonText {
    final currentCommentData = commentStore.data[pageId];
    var text = '...';
    if (currentCommentData != null) {
      if (currentCommentData.status == 0) text = '×';
      if (currentCommentData.status >= 3) text = currentCommentData.count.toString();
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final contentTopPadding = kToolbarHeight + statusBarHeight;

    return Scaffold(
      key: scaffoldKey,
      drawer: GlobalDrawer(),
      endDrawer: ArticlePageContents(
        contentsData: contentsData,
        onSectionPressed: jumpToAnchor,
      ),
      body: Container(
        alignment: Alignment.center,
        child: Stack(
          children: [            
            ArticleView(
              pageName: truePageName,
              contentTopPadding: contentTopPadding,
              revId: widget.routeArgs.revId,
              injectedScripts: [injectedWindowScrollEventHandlerStr],
              messageHandlers: {
                'windowScrollChange': webViewScrollWasChanged
              },
              onArticleLoaded: articleDataWasLoaded,
              emitContentData: (data) => setState(() => contentsData = data),
              onArticleMissed: articleWasMissed,
              emitArticleController: (controller) => articleViewController = controller,
            ),

            Positioned(
              top: 0,
              left: 0,
              width: MediaQuery.of(context).size.width,
              child: ArticlePageHeader(
                title: trimHtml(displayPageName),
                isExistsInWatchList: isWatched,
                editAllowed: editAllowed,
                enabledMoreButton: enabledHeaderMoreButton,
                visibleTalkButton: visibleTalkButton,
                editFullDisabled: editFullDisabled,
                onMoreMenuPressed: headerMoreMenuWasPressed,
                emitController: (controller) => headerController = controller,
              ),
            ),

            Positioned(
              right: 20,
              bottom: 20,
              child: Offstage(
                offstage: !visibleCommentButton,
                child: ArticlePageCommentButton(
                  text: commentButtonText,
                  emitController: (controller) => commentButtonController = controller,
                  onPressed: commentButtonWasPressed
                ),
              )
            )
          ],
        )
      )
    );
  }
}

const disableAllIframeJsStr = '''
  (() => {
    const iframeList = document.querySelectorAll('iframe')
    iframeList.forEach(item => {
      // 通过清空src的方式停止播放
      const src = item.src
      item.src = ''
      item.dataset.src = src
    })
  })()
''';

const enableAllIframeJsStr = '''
  (() => {
    const iframeList = document.querySelectorAll('iframe')
    iframeList.forEach(item => {
      item.src = item.dataset.src
    })
  })()
''';

const pauseAllAudioJsStr = '''
  (() => {
    const audioList = document.querySelectorAll('audio')
    audioList.forEach(item => item.pause())
  })()
''';