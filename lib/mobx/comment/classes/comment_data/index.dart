import 'package:mobx/mobx.dart';

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
  @observable int requestOffset;
  @observable ObservableList<MobxCommentData> children;

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