import 'package:mobx/mobx.dart';
import 'package:moegirl_plus/api/account.dart';
import 'package:moegirl_plus/api/edit.dart';
import 'package:moegirl_plus/api/notification.dart';
import 'package:moegirl_plus/prefs/index.dart';

part 'index.g.dart';

class AccountStore = _AccountBase with _$AccountStore;

abstract class _AccountBase with Store {
  @observable String userName = accountPref.userName;
  @observable int waitingNotificationTotal = 0;
  @observable dynamic userInfo;

  @computed bool get isLoggedIn => userName != null;

  @action
  Future<LoginResult> login(String userName, String password) async {
    final res = await AccountApi.login(userName, password);
    if (res['clientlogin']['status'] == 'PASS') {
      this.userName = userName;
      accountPref.userName = userName;
      return LoginResult(true);
    } else {
      return LoginResult(false, res['clientlogin']['message']);
    }
  }

  @action
  void logout() {
    AccountApi.logout();
    userName = null;
    accountPref.userName = null;
  }

  @action
  Future<bool> checkAccount() async {
    try {
      final data = await EditApi.getCsrfToken();
      if (data['query']['tokens']['csrftoken'] != '+\\') return true;
      logout();
      return false;
    } catch(e) {
      print('检查账户有效性失败');
      print(e);
      return true;  // 因为萌百服务器不稳定，所以将网络超时认定为有效
    }
  }

  @action
  Future<int> checkWaitingNotificationTotal() async {
    final data = await NotificationApi.getList('', 1);
    waitingNotificationTotal = data['query']['notifications']['rawcount'];
    return waitingNotificationTotal;
  }

  @action
  Future<void> markAllNotificationAsRead() async {
    await NotificationApi.markAllAsRead();
    waitingNotificationTotal = 0;
  }

  @action
  Future getUserInfo() async {
    if (userInfo != null) return userInfo;
    final res = await AccountApi.getInfo();
    if (res['query']['userinfo'].containsKey('anon')) return;
    
    userInfo = res['query']['userinfo'];
    return userInfo;
  }

  Future<bool> inUserGroup(UserGroups userGroup) async {
    final userInfo = await getUserInfo();
    final groupName = userGroup.toString().replaceAll('UserGroups.', '').toLowerCase();
    return userInfo['groups'].contains(groupName);
  }
}

class LoginResult {
  final bool successed;
  final String message;

  LoginResult(this.successed, [this.message]);
}

enum UserGroups {
  autoConfirmed, goodEditor, patroller
}