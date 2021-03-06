
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moegirl_plus/components/touchable_opacity.dart';
import 'package:moegirl_plus/language/index.dart';
import 'package:moegirl_plus/utils/get_custom_app_info.dart';
import 'package:moegirl_plus/views/article/index.dart';
import 'package:one_context/one_context.dart';
import 'package:package_info/package_info.dart';

void showAboutDialog(BuildContext context) async {
  final packageInfo = await PackageInfo.fromPlatform();
  final appInfo = await getCustomAppInfo();
  
  showDialog(
    context: context,
    barrierDismissible: true,
    useRootNavigator: false,
    builder: (context) {
      final theme = Theme.of(context);

      return AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text(Lang.settingsPage_showAboutDialog_title),
        content: SizedBox(
          height: 80,
          child: Container(
            child: Row(
              children: [
                Image.asset('assets/images/app_icon.png', width: 70, height: 70),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${Lang.settingsPage_showAboutDialog_version}：${packageInfo.version}'),
                      Text('${Lang.settingsPage_showAboutDialog_updateDate}：${appInfo.date}'),
                      Row(
                        children: [
                          Text('${Lang.settingsPage_showAboutDialog_development}：'),
                          TouchableOpacity(
                            onPressed: () {
                              OneContext().pop();
                              OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(pageName: 'User:東東君'));
                            },
                            child: Text('東東君',
                              style: TextStyle(
                                color: theme.accentColor,
                                decoration: TextDecoration.underline
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ),
        actions: [
          TextButton(
            child: Text(Lang.settingsPage_showAboutDialog_close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }
  );
}