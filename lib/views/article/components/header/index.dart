import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_back_button.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_icon.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_title.dart';
import 'package:moegirl_plus/generated/l10n.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:one_context/one_context.dart';

import 'components/animation.dart';

class ArticlePageHeader extends StatelessWidget {
  S get i10n => S.current;
  final String title;
  final bool isExistsInWatchList;
  final bool enabledMoreButton;
  final bool editAllowed; // 为null时视为正在从接口获取权限
  final bool editFullDisabled;  // 是否允许编辑全文
  final bool visibleTalkButton;
  final Function(ArticlePageHeaderAnimationController) emitController;
  final Function(ArticlePageHeaderMoreMenuValue) onMoreMenuPressed;
  
  const ArticlePageHeader({
    @required this.title,
    @required this.isExistsInWatchList,
    @required this.enabledMoreButton,
    @required this.editAllowed,
    @required this.editFullDisabled,
    @required this.visibleTalkButton,
    @required this.onMoreMenuPressed,
    @required this.emitController,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ArticlePageHeaderAnimation(
      emitController: emitController,
      fadedChildBuilder: (faded) => (
        AppBar(
          elevation: 0,
          title: faded(AppBarTitle(title)),
          leading: Builder(
            builder: (context) => faded(AppBarBackButton())
          ),
          actions: [
            faded(AppBarIcon(
              icon: Icons.search, 
              onPressed: () => OneContext().pushNamed('search')
            )),
            faded(PopupMenuButton(
              icon: Icon(Icons.more_vert,
                color: theme.colorScheme.onPrimary,
              ),
              enabled: enabledMoreButton,
              tooltip: i10n.articlePage_header_moreButtonTooltip,
              onSelected: onMoreMenuPressed,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: ArticlePageHeaderMoreMenuValue.refresh,
                  child: Text(i10n.articlePage_header_moreMenuRefreshButton),
                ),
                accountStore.isLoggedIn ? 
                  PopupMenuItem(
                    value: editFullDisabled ? ArticlePageHeaderMoreMenuValue.addSection : ArticlePageHeaderMoreMenuValue.edit,
                    enabled: editAllowed != null && editAllowed,
                    child: Text(
                      editAllowed == null ?
                        i10n.articlePage_header_moreMenuEditButton('permissionsChecking') :
                        (editAllowed ? 
                          (editFullDisabled ? 
                            i10n.articlePage_header_moreMenuEditButton('addTheme') : 
                            i10n.articlePage_header_moreMenuEditButton('full')
                          ) :
                          i10n.articlePage_header_moreMenuEditButton('disabled')
                        )
                    )
                  )
                :
                  PopupMenuItem(
                    value: ArticlePageHeaderMoreMenuValue.login,
                    child: Text(i10n.articlePage_header_moreMenuLoginButton)
                  )
                ,
                if (accountStore.isLoggedIn) (
                  PopupMenuItem(
                    value: ArticlePageHeaderMoreMenuValue.toggleWatchList,
                    child: Text(i10n.articlePage_header_moreMenuWatchListButton(isExistsInWatchList))
                  )
                ),
                if (visibleTalkButton) (
                  PopupMenuItem(
                    value: ArticlePageHeaderMoreMenuValue.gotoTalk,
                    child: Text(i10n.articlePage_header_moreMenuGotoTalkPageButton),
                  )
                ),
                PopupMenuItem(
                  value: ArticlePageHeaderMoreMenuValue.gotoVersionHistory,
                  child: Text(i10n.articlePage_header_moreMenuGotoVersionHistoryButton),
                ),
                PopupMenuItem(
                  value: ArticlePageHeaderMoreMenuValue.share,
                  child: Text(i10n.articlePage_header_moreMenuGotoShareButton),
                ),
                PopupMenuItem(
                  value: ArticlePageHeaderMoreMenuValue.openContents,
                  child: Text(i10n.articlePage_header_moreMenuShowContentsButton)
                )
              ],
            ))
          ],
        )
      )
    );
  }
}

enum ArticlePageHeaderMoreMenuValue {
  refresh, edit, login, toggleWatchList, openContents, share, addSection, gotoTalk, gotoVersionHistory
}