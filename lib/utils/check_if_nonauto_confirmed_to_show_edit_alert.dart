import 'package:moegirl_plus/mobx/account/index.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/utils/ui/dialog/alert.dart';
import 'package:url_launcher/url_launcher.dart';

Future<bool> checkIfNonautoConfirmedToShowEditAlert(String pageName, [String section]) async {
  final isAutoConfirmed = await accountStore.inUserGroup(UserGroups.autoConfirmed);
  if (!isAutoConfirmed) {
    final result = await showAlert(
      content: '您不是自动确认用户(编辑数超过10次且注册超过24小时)，无法在客户端进行编辑。要前往网页版进行编辑吗？',
      visibleCloseButton: true
    );

    if (result) {
      final sectionParam = section != null ? '&section=$section' : '';
      launch('https://mzh.moegirl.org.cn/index.php?title=$pageName&action=edit$sectionParam');
    }

    return true;
  }

  return false;
}