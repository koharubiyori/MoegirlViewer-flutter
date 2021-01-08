import 'package:mobx/mobx.dart';
import 'package:moegirl_plus/mobx/comment/classes/page_comments/index.dart';

part 'index.g.dart';

class MobxCommentData = _MobxCommentDataBase with _$MobxCommentData;

List<MobxCommentData> toMobxCommentList(List list) {
  return list.map((item) => MobxCommentData.fromApiData(item)).cast<MobxCommentData>();
}

abstract class _MobxCommentDataBase with Store {
  @observable String id;
  @observable int userId;
  @observable String userName;
  @observable String text;
  @observable int timestamp;
  @observable String parentId;
  @observable int like;
  @observable int myatt;
  
  /// 加载这条数据时给接口传的offset，用来在添加回复后刷新数据使用
  @observable int requestOffset;
  /// 评论的所有回复，不是评论数据的话这个属性为null
  @observable ObservableList<MobxCommentData> children;
  /// 回复数据的回复对象，不是回复数据的话这个属性为null
  @observable MobxCommentData target;

  _MobxCommentDataBase.fromApiData(Map apiData) {
    id = apiData['id'];
    userId = apiData['userid'];
    userName = apiData['username'];
    text = apiData['text'];
    timestamp = apiData['timestamp'];
    parentId = apiData['parentId'];
    like = apiData['like'];
    requestOffset = apiData['requestOffset'];
    children = toMobxCommentList(apiData['children']);
  }
}