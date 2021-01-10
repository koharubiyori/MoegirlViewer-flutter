// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$SettingsStore on _SettingsBase, Store {
  Computed<bool> _$heimuComputed;

  @override
  bool get heimu => (_$heimuComputed ??=
          Computed<bool>(() => super.heimu, name: '_SettingsBase.heimu'))
      .value;
  Computed<bool> _$stopAudioOnLeaveComputed;

  @override
  bool get stopAudioOnLeave => (_$stopAudioOnLeaveComputed ??= Computed<bool>(
          () => super.stopAudioOnLeave,
          name: '_SettingsBase.stopAudioOnLeave'))
      .value;
  Computed<bool> _$cachePriorityComputed;

  @override
  bool get cachePriority =>
      (_$cachePriorityComputed ??= Computed<bool>(() => super.cachePriority,
              name: '_SettingsBase.cachePriority'))
          .value;
  Computed<String> _$sourceComputed;

  @override
  String get source => (_$sourceComputed ??=
          Computed<String>(() => super.source, name: '_SettingsBase.source'))
      .value;
  Computed<String> _$themeComputed;

  @override
  String get theme => (_$themeComputed ??=
          Computed<String>(() => super.theme, name: '_SettingsBase.theme'))
      .value;
  Computed<String> _$langComputed;

  @override
  String get lang => (_$langComputed ??=
          Computed<String>(() => super.lang, name: '_SettingsBase.lang'))
      .value;
  Computed<bool> _$isNightThemeComputed;

  @override
  bool get isNightTheme =>
      (_$isNightThemeComputed ??= Computed<bool>(() => super.isNightTheme,
              name: '_SettingsBase.isNightTheme'))
          .value;
  Computed<Locale> _$localeComputed;

  @override
  Locale get locale => (_$localeComputed ??=
          Computed<Locale>(() => super.locale, name: '_SettingsBase.locale'))
      .value;

  final _$_dataAtom = Atom(name: '_SettingsBase._data');

  @override
  Map<String, dynamic> get _data {
    _$_dataAtom.reportRead();
    return super._data;
  }

  @override
  set _data(Map<String, dynamic> value) {
    _$_dataAtom.reportWrite(value, super._data, () {
      super._data = value;
    });
  }

  @override
  String toString() {
    return '''
heimu: ${heimu},
stopAudioOnLeave: ${stopAudioOnLeave},
cachePriority: ${cachePriority},
source: ${source},
theme: ${theme},
lang: ${lang},
isNightTheme: ${isNightTheme},
locale: ${locale}
    ''';
  }
}
