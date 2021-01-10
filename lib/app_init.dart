import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/themes.dart';
import 'package:moegirl_plus/utils/ui/set_status_bar.dart';
import 'package:moegirl_plus/utils/watch_list_manager.dart';

import 'generated/l10n.dart';

mixin AppInit<T extends StatefulWidget> on 
  State<T>, 
  AfterLayoutMixin<T>
{
  Timer _notificationCheckingTimer;

  @override
  void afterFirstLayout(_) { 
    // 初始化语言设置
    // final language = settingsProvider.lang.split('-');
    // S.load(Locale(language[0], language[1]));
    
    // 初始化用户信息，开始轮询检查等待通知
    if (accountStore.isLoggedIn) {
      initUserInfo();
    } 

    if (settingsStore.isNightTheme) {
      setNavigationBarStyle(nightPrimaryColor, Brightness.light);
    }

    // 监听登录状态，更新用户信息及启动或关闭轮询检查等待通知
    autorun((_) {
      if (accountStore.isLoggedIn) {
        initUserInfo();
      } else {
        _notificationCheckingTimer.cancel();
      }
    });
    
    // 监听主题变化，修改底部导航栏样式
    autorun((_) {
      setNavigationBarStyle(
        settingsStore.isNightTheme ? nightPrimaryColor : Colors.white,
        settingsStore.isNightTheme ? Brightness.light : Brightness.light
      );
    });
    
    // 监听语言变化
    // addChangeChecker<SettingsProviderModel, String>(
    //   provider: settingsProvider,
    //   selector: (provider) => provider.lang,
    //   handler: (lang) {
    //     final language = lang.split('-');
    //     S.load(Locale(language[0], language[1]));
    //   }
    // );
  }

  void initUserInfo() {
    accountStore.getUserInfo();
    accountStore.checkWaitingNotificationTotal();
    WatchListManager.refreshList();

    _notificationCheckingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      try {
        accountStore.checkWaitingNotificationTotal();
      } catch(e) {
        print('轮询检查等待通知失败');
        print(e);
      }
    });  
  }

  @override
  void dispose() {
    super.dispose();
    if (_notificationCheckingTimer != null) _notificationCheckingTimer.cancel();
  }
}