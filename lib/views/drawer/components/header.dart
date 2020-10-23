import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:moegirl_viewer/providers/account.dart';
import 'package:moegirl_viewer/utils/status_bar_height.dart';
import 'package:moegirl_viewer/views/article/index.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';

const avatar_url = 'https://commons.moegirl.org.cn/extensions/Avatar/avatar.php?user=';
const double avatarSize = 75;

class DrawerHeader extends StatelessWidget {
  const DrawerHeader({Key key}) : super(key: key);

  void avatarOrUserNameWasClicked() {
    OneContext().pop();
    if (accountProvider.isLoggedIn) {
      OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(
        pageName: 'User:' + accountProvider.userName
      ));
    } else {
      OneContext().pushNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Selector<AccountProviderModel, bool>(
      selector: (_, model) => model.isLoggedIn,
      builder: (_, isLoggedIn, __) => (
        Container(
          alignment: Alignment.center,
          color: theme.primaryColor,
          height: 150 + statusBarHeight,
          padding: EdgeInsets.only(top: statusBarHeight),
          child: SizedBox.expand(
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CupertinoButton(
                        onPressed: avatarOrUserNameWasClicked,
                        padding: EdgeInsets.all(0),
                        child: Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.onPrimary,
                              width: 3
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(avatarSize / 2)),
                            image: DecorationImage(
                              image: isLoggedIn ? 
                                NetworkImage(avatar_url + accountProvider.userName) :
                                AssetImage('assets/images/akari.jpg')
                              ,
                            )
                          ),
                        ),
                      ),

                      CupertinoButton(
                        onPressed: avatarOrUserNameWasClicked,
                        padding: EdgeInsets.all(0),
                        child: Container(
                          margin: EdgeInsets.only(top: 10),
                          child: Text(isLoggedIn ? '欢迎你，${accountProvider.userName}' : '登录/加入萌娘百科',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontSize: 16
                            ),
                          )
                        ),
                      )
                    ],
                  )
                ),

                if (isLoggedIn) (
                  Positioned(
                    right: 10,
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        splashRadius: 20,
                        icon: Icon(Icons.notifications),
                        color: theme.colorScheme.onPrimary,
                        onPressed: () => OneContext().pushNamed('/notifications')
                      ),
                    )
                  )
                )
              ],
            ),
          ),
        )
      ),
    );
  }
}