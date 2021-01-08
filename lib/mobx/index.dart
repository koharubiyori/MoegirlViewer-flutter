import 'package:moegirl_plus/prefs/index.dart';

import 'account/index.dart';
import 'comment/index.dart';
import 'settings/index.dart';

SettingsStore settingsStore;
AccountStore accountStore;
CommentStore commentStore;

final Future<void> mobxReady = Future(() async {
  await prefReady;
  settingsStore = SettingsStore();
  accountStore = AccountStore();
  commentStore = CommentStore();
});
