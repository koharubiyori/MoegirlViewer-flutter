import 'package:flutter/material.dart' hide showAboutDialog;
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_back_button.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_title.dart';
import 'package:moegirl_plus/generated/l10n.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/utils/article_cache_manager.dart';
import 'package:moegirl_plus/utils/reading_history_manager.dart';
import 'package:moegirl_plus/utils/ui/dialog/alert.dart';
import 'package:moegirl_plus/utils/ui/toast/index.dart';
import 'package:moegirl_plus/views/settings/components/item.dart';
import 'package:moegirl_plus/views/settings/utils/show_language_selection_dialog.dart';
import 'package:moegirl_plus/views/settings/utils/show_theme_selection_dialog.dart';
import 'package:one_context/one_context.dart';

import 'utils/show_about_dialog.dart';

class SettingsPageRouteArgs {
  
  SettingsPageRouteArgs();
}

class SettingsPage extends StatefulWidget {
  final SettingsPageRouteArgs routeArgs;
  SettingsPage(this.routeArgs, {Key key}) : super(key: key);
  
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  S get i10n => S.of(context);
  
  void clearCache() async {
    final result = await showAlert(
      content: '确定要清除全部条目缓存吗？',
      visibleCloseButton: true
    );
    if (!result) return;

    ArticleCacheManager.clearCache();
    toast('已清除全部缓存');
  }

  void clearReadingHistory() async {
    final result = await showAlert(
      content: '确定要清除全部浏览历史吗？',
      visibleCloseButton: true
    );
    if (!result) return;

    ReadingHistoryManager.clear();
    toast('已清除全部浏览历史');
  }
  
  void showThemeDialog() async {
    final result = await showThemeSelectionDialog(
      context: context,
      initialValue: settingsStore.theme, 
      onChange: (value) => settingsStore.theme = value
    );

    settingsStore.theme = result;
  }

  void showLanguageDialog() async {
    final result = await showLanguageSelectionDialog(
      context: context,
      initialValue: settingsStore.lang, 
    );

    settingsStore.lang = result;
  }

  void toggleLoginStatus(bool isLoggedIn) async {
    if (isLoggedIn) {
      final result = await showAlert(
        content: '确定要登出吗？',
        visibleCloseButton: true
      );
      if (!result) return;

      accountStore.logout();
      toast('已登出');
    } else {
      OneContext().pushNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget title(String text) {
      return Padding(
        padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
        child: Text(text,
          style: TextStyle(
            color: theme.accentColor
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(i10n.settingsPage_title),
        leading: AppBarBackButton(),
        elevation: 0,
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Observer(
            builder: (context) => (
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  title('条目'),
                  SettingsPageItem(
                    title: '黑幕开关',
                    subtext: '关闭后黑幕将默认为刮开状态',
                    onPressed: () => settingsStore.heimu = !settingsStore.heimu,
                    rightWidget: Switch(
                      value: settingsStore.heimu,
                      onChanged: (value) => settingsStore.heimu = value,
                    ),
                  ),
                  SettingsPageItem(
                    title: '停止旧页面背景媒体',
                    subtext: '打开新条目时停止旧条目上的音频和视频',
                    onPressed: () => settingsStore.stopAudioOnLeave = !settingsStore.stopAudioOnLeave,
                    rightWidget: Switch(
                      value: settingsStore.stopAudioOnLeave,
                      onChanged: (value) => settingsStore.stopAudioOnLeave = value,
                    ),
                  ),
                  title('界面'),
                  SettingsPageItem(
                    title: '更换主题',
                    onPressed: showThemeDialog,
                  ),
                  SettingsPageItem(
                    title: '切换语言',
                    onPressed: showLanguageDialog,
                  ),
                  title('缓存'),
                  SettingsPageItem(
                    title: '缓存优先模式',
                    subtext: '如果有条目有缓存将优先使用',
                    onPressed: () => settingsStore.cachePriority = !settingsStore.cachePriority,
                    rightWidget: Switch(
                      value: settingsStore.cachePriority,
                      onChanged: (value) => settingsStore.cachePriority = value,
                    ),
                  ),
                  SettingsPageItem(
                    title: '清除条目缓存',
                    onPressed: clearCache,
                  ),
                  SettingsPageItem(
                    title: '清除浏览历史',
                    onPressed: clearReadingHistory,
                  ),
                  title('账户'),
                  Observer(
                    builder: (context) => (
                      SettingsPageItem(
                        title: accountStore.isLoggedIn ? '登出' : '登录',
                        onPressed: () => toggleLoginStatus(accountStore.isLoggedIn),
                      )
                    ),
                  ),
                  title('其他'),
                  SettingsPageItem(
                    title: '关于',
                    onPressed: () => showAboutDialog(context),
                  ),
                  // test
                  // SettingsPageItem(
                  //   title: '检查新版本',
                  //   onPressed: () {}
                  // )
                ],
              )
            ),
          ),
        ),
      )
    );
  }
}