import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:moegirl_plus/prefs/index.dart';

part 'index.g.dart';
 
class SettingsStore = _SettingsBase with _$SettingsStore;

abstract class _SettingsBase with Store {
  @observable Map<String, dynamic> _data = ObservableMap.of({
    'heimu': settingsPref.heimu,
    'stopAudioOnLeave': settingsPref.stopAudioOnLeave,
    'cachePriority': settingsPref.cachePriority,
    'source': settingsPref.source,
    'theme': settingsPref.theme,
    'lang': settingsPref.lang
  });

  @computed bool get heimu => _data['heimu'];
  @computed bool get stopAudioOnLeave => _data['stopAudioOnLeave'];
  @computed bool get cachePriority => _data['cachePriority'];
  @computed String get source => _data['source'];
  @computed String get theme => _data['theme'];
  @computed String get lang => _data['lang'];

  set heimu(bool value) => _data['heimu'] = value;
  set stopAudioOnLeave(bool value) => _data['stopAudioOnLeave'] = value;
  set cachePriority(bool value) => _data['cachePriority'] = value;
  set source(String value) => _data['source'] = value;
  set theme(String value) => _data['theme'] = value;
  set lang(String value) => _data['lang'] = value;

  @computed Locale get locale {
    final language = lang.split('-');
    return Locale(language[0], language[1]);
  }
}