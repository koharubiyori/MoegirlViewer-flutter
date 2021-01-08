// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AccountStore on _AccountBase, Store {
  Computed<bool> _$isLoggedInComputed;

  @override
  bool get isLoggedIn =>
      (_$isLoggedInComputed ??= Computed<bool>(() => super.isLoggedIn,
              name: '_AccountBase.isLoggedIn'))
          .value;

  final _$userNameAtom = Atom(name: '_AccountBase.userName');

  @override
  String get userName {
    _$userNameAtom.reportRead();
    return super.userName;
  }

  @override
  set userName(String value) {
    _$userNameAtom.reportWrite(value, super.userName, () {
      super.userName = value;
    });
  }

  final _$waitingNotificationTotalAtom =
      Atom(name: '_AccountBase.waitingNotificationTotal');

  @override
  int get waitingNotificationTotal {
    _$waitingNotificationTotalAtom.reportRead();
    return super.waitingNotificationTotal;
  }

  @override
  set waitingNotificationTotal(int value) {
    _$waitingNotificationTotalAtom
        .reportWrite(value, super.waitingNotificationTotal, () {
      super.waitingNotificationTotal = value;
    });
  }

  final _$userInfoAtom = Atom(name: '_AccountBase.userInfo');

  @override
  dynamic get userInfo {
    _$userInfoAtom.reportRead();
    return super.userInfo;
  }

  @override
  set userInfo(dynamic value) {
    _$userInfoAtom.reportWrite(value, super.userInfo, () {
      super.userInfo = value;
    });
  }

  final _$loginAsyncAction = AsyncAction('_AccountBase.login');

  @override
  Future<LoginResult> login(String userName, String password) {
    return _$loginAsyncAction.run(() => super.login(userName, password));
  }

  final _$checkAccountAsyncAction = AsyncAction('_AccountBase.checkAccount');

  @override
  Future<bool> checkAccount() {
    return _$checkAccountAsyncAction.run(() => super.checkAccount());
  }

  final _$checkWaitingNotificationTotalAsyncAction =
      AsyncAction('_AccountBase.checkWaitingNotificationTotal');

  @override
  Future<int> checkWaitingNotificationTotal() {
    return _$checkWaitingNotificationTotalAsyncAction
        .run(() => super.checkWaitingNotificationTotal());
  }

  final _$markAllNotificationAsReadAsyncAction =
      AsyncAction('_AccountBase.markAllNotificationAsRead');

  @override
  Future<void> markAllNotificationAsRead() {
    return _$markAllNotificationAsReadAsyncAction
        .run(() => super.markAllNotificationAsRead());
  }

  final _$getUserInfoAsyncAction = AsyncAction('_AccountBase.getUserInfo');

  @override
  Future<dynamic> getUserInfo() {
    return _$getUserInfoAsyncAction.run(() => super.getUserInfo());
  }

  final _$_AccountBaseActionController = ActionController(name: '_AccountBase');

  @override
  void logout() {
    final _$actionInfo =
        _$_AccountBaseActionController.startAction(name: '_AccountBase.logout');
    try {
      return super.logout();
    } finally {
      _$_AccountBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
userName: ${userName},
waitingNotificationTotal: ${waitingNotificationTotal},
userInfo: ${userInfo},
isLoggedIn: ${isLoggedIn}
    ''';
  }
}
