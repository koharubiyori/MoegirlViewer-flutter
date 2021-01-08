import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/prefs/index.dart';
import 'package:moegirl_plus/utils/ui/dialog/alert.dart';
import 'package:moegirl_plus/views/article/index.dart';
import 'package:one_context/one_context.dart';

class DrawerBody extends StatelessWidget {
  const DrawerBody({Key key}) : super(key: key);

  void showOperationHelp() {
    showAlert(
      title: '操作提示',
      content: [
        '1. 左滑开启抽屉',
        '2. 条目页右滑开启目录',
        // '3. 条目内容中长按b站播放器按钮跳转至b站对应视频页(当然前提是手机里有b站app)',
        // '4. 左右滑动视频播放器小窗可以关闭视频'
      ].join('\n')
    );
  }

  void toggleNight() {
    if (settingsStore.isNightTheme) {
      settingsStore.theme = otherPref.lastTheme;
    } else {
      otherPref.lastTheme = settingsStore.theme;
      settingsStore.theme = 'night';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget listItem(IconData icon, String text, onPressed) {      
      return Material(
        color: Colors.transparent,
        child: InkWell(
          splashColor: theme.accentColor.withOpacity(0.2),
          highlightColor: Colors.transparent,
          onTap: onPressed,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            child: Row(
              children: [
                Icon(icon, size: 28, color: theme.accentColor),
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Text(text,
                    style: TextStyle(
                      color: theme.hintColor,
                      fontSize: 17
                    ),
                  ),
                )
              ],
            ),
          )
        ),
      );
    }
    
    return SingleChildScrollView(
      child: Column(
        children: [
          listItem(Icons.forum, '讨论版', () {
            OneContext().pop();
            OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(
              pageName: '萌娘百科 talk:讨论版'
            ));
          }),
          listItem(Icons.format_indent_decrease, '最近更改', () {
            OneContext().pop();
            OneContext().pushNamed('/recentChanges');
          }),
          listItem(Icons.history, '浏览历史', () {
            OneContext().pop();
            OneContext().pushNamed('/history');
          }),
          listItem(Icons.touch_app, '操作提示', showOperationHelp),
          Observer(
            builder: (context) => (
              listItem(Icons.brightness_4, '${settingsStore.isNightTheme ? '关闭' : '开启'}黑夜模式', toggleNight)
            ),
          )
        ],
      )
    );
  }
}