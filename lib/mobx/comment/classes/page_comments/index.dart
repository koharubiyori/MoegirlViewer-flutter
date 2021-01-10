import 'package:mobx/mobx.dart';
import 'package:moegirl_plus/mobx/comment/classes/comment_data/index.dart';

part 'index.g.dart';

class MobxPageComments = _MobxPageCommentsBase with _$MobxPageComments;

abstract class _MobxPageCommentsBase with Store {
  @observable ObservableList<MobxCommentData> popular = ObservableList();
  @observable ObservableList<MobxCommentData> commentTree = ObservableList();
  @observable int offset = 0;
  @observable int count = 0;
  /// 0：加载失败，1：初始，2：加载中，2.1：refresh加载中，3：加载成功，4：全部加载完成，5：加载过，但没有数据
  @observable num status = 1;
}