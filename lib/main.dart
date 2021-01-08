import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:moegirl_plus/app_init.dart';
import 'package:moegirl_plus/prefs/index.dart';
import 'package:moegirl_plus/request/moe_request.dart';
import 'package:moegirl_plus/routes/router.dart';
import 'package:moegirl_plus/themes.dart';
import 'package:moegirl_plus/utils/provider_change_checker.dart';
import 'package:moegirl_plus/utils/ui/set_status_bar.dart';
import 'package:one_context/one_context.dart';
import 'generated/l10n.dart';

import 'mobx/index.dart';
import 'utils/route_aware.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 等待必要数据加载完毕，注意避免出现数据互相等待的情况
  await Future.wait([
    prefReady,
    mobxReady,
    moeRequestReady
  ]);

  runApp(MyApp());

  setStatusBarColor(Colors.transparent);
  S.load(Locale('zh', 'hant'));
}


class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with 
  AfterLayoutMixin, 
  AppInit
{
  @override
  Widget build(BuildContext context) {    
    return Observer(
      builder: (context) => (
        MaterialApp(
          title: 'Moegirl+',
          theme: themes[settingsStore.theme],
          onGenerateRoute: router.generator,
          navigatorObservers: [routeObserver, HeroController()],
          builder: OneContext().builder,
          navigatorKey: OneContext().key,

          locale: settingsStore.locale,
          localizationsDelegates: [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
        )
      ),
    );
  }
}


