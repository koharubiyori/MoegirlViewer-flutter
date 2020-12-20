import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:moegirl_viewer/providers/account.dart';
import 'package:moegirl_viewer/providers/settings.dart';
import 'package:moegirl_viewer/themes.dart';
import 'package:moegirl_viewer/utils/provider_change_checker.dart';
import 'package:moegirl_viewer/utils/ui/set_status_bar.dart';

mixin AppInit<T extends StatefulWidget> on 
  State<T>, 
  AfterLayoutMixin<T>, 
  ProviderChangeChecker<T> 
{
  Timer _notificationCheckingTimer;
  
  @override
  void afterFirstLayout(_) { 
    // 初始化用户信息，开始轮询检查等待通知
    if (accountProvider.isLoggedIn) {
      accountProvider.getUserInfo();
      accountProvider.checkWaitingNotificationTotal();
    }
    
    _notificationCheckingTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (accountProvider.isLoggedIn == false) return;
      try {
        accountProvider.checkWaitingNotificationTotal();
      } catch(e) {
        print('轮询检查等待通知失败');
        print(e);
      }
    });  

    // 监听主题变化，修改底部导航栏样式
    addChangeChecker<SettingsProviderModel, bool>(
      provider: settingsProvider, 
      selector: (provider) => provider.theme == 'night', 
      handler: (isNight) {
        setNavigationBarStyle(
          isNight ? nightPrimaryColor : Colors.white,
          isNight ? Brightness.light : Brightness.light
        );
      }
    );
  }

  @override
  void dispose() {
    super.dispose();
    _notificationCheckingTimer.cancel();
  }
}