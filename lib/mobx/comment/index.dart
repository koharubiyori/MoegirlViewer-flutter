import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:moegirl_plus/api/comment.dart';
import 'package:moegirl_plus/mobx/comment/classes/comment_data/index.dart';
import 'package:moegirl_plus/mobx/comment/classes/page_comments/index.dart';
import 'package:moegirl_plus/utils/comment_tree.dart';

part 'index.g.dart';

class CommentStore = _CommentBase with _$CommentStore;

abstract class _CommentBase with Store {
  // 页面id: 评论数据
  @observable Map<int, MobxPageComments> data = ObservableMap.of({});

  MobxCommentData findByCommentId(int pageId, String commentId, [bool popular = false]) {
    var foundItem = (popular ? data[pageId].popular : data[pageId].commentTree)
      .singleWhere((item) => item.id == commentId, orElse: () => null);
    if (foundItem != null || popular) return foundItem;

    foundItem = data[pageId].commentTree
      .fold<List<MobxCommentData>>([], (result, item) => result + item.children)
      .singleWhere((item) => item.id == commentId, orElse: () => null);

    return foundItem;
  }

  @action
  Future loadNext(int pageId) async {    
    try {
      if (data[pageId] != null && [2, 2.1, 4, 5].contains(data[pageId].status)) return;
      data[pageId] ??= MobxPageComments();
      data[pageId].status = data[pageId].status == 1 ? 2.1 : 2;

      final commentData = await CommentApi.getComments(pageId, data[pageId].offset);
      var nextStatus = 3;
      final int commentCount = commentData['posts'].where((item) => item['parentid'] == '').length;
      if (data[pageId].offset + commentCount >= commentData['count']) nextStatus = 4;
      if (data[pageId].commentTree.length == 0 && commentData['posts'].length == 0) nextStatus = 5;

      // 萌百的评论数据是用parentId格式串起来的，首先要树化，然后在第二层展平(将所有回复放在评论的children字段)
      final commentTree = CommentTree(commentData['posts'])..flatten();
      final newCommentData = commentTree.data;

      // 为数据带上请求时的offset
      newCommentData.forEach((item) => item['requestOffset'] = data[pageId].offset);

      // 映射为mobx可响应数据
      final mobxPopulerList = toMobxCommentList(commentData['popular']);
      final mobxCommentList = toMobxCommentList(newCommentData);

      data[pageId]
        ..popular = mobxPopulerList
        ..commentTree = [...data[pageId].commentTree, ...mobxCommentList]
        ..offset = data[pageId].offset + commentCount
        ..count = commentData['count']
        ..status = nextStatus
      ;
    } catch(e) {
      if (e is DioError) {
        data[pageId].status = 0;
        return;
      }

      rethrow;
    }
  }

  @action
  Future<void> setLike(int pageId, String commentId, [bool like = true]) async {
    await CommentApi.toggleLike(commentId, like);
    final foundItem = findByCommentId(pageId, commentId);
    final foundPopularItem = findByCommentId(pageId, commentId, true);

    foundItem.like += like ? 1 : -1;
    foundItem.myatt = like ? 1 : 0;

    if (foundPopularItem != null) {
      foundPopularItem.like += like ? 1 : -1;
      foundPopularItem.myatt = like ? 1 : 0;
    }
  }

  // 传入commentId表示回复
  @action
  addComment(int pageId, String content, [String commentId]) async {
    await CommentApi.postComment(pageId, content, commentId);

    // 因为萌百的评论api没返回评论id，这里只好手动去查
    if (commentId != null) {
      // 如果发的是评论，获取最近10条评论，并找出新评论。
      // 当然这样是有缺陷的，如果从发评论到服务器响应之间新增评论超过10条，就会导致不准。{{黑幕|不过不用担心，你百是不可能这么火的}}
      final lastCommentList = await CommentApi.getComments(pageId);
      final currentCommentIds = data[pageId].commentTree.map((item) => item.id).toList();
      final newCommentList = lastCommentList['posts']
        .where((item) => item['parent'] == '' && currentCommentIds.contains(item['id']))
        .map((item) {
          item['children'] = [];
          item['requestOffset'] = 0;
          return item;
        });
        
      final mobxNewCommentList = toMobxCommentList(newCommentList);

      data[pageId].commentTree.insertAll(0, mobxNewCommentList);
      data[pageId].count++;
    } else {
      // 如果发的是回复，先找出回复的目标数据index
      final parentComment = data[pageId].commentTree.singleWhere((item) {
        if (item.id == commentId) return true;
        if (item.children.any((childItem) => childItem.id == commentId)) return true;
        return false;
      });

      // 用回复目标的requestOffset请求，再找出回复目标数据，赋给当前渲染的评论数据，实现更新回复
      final newTargetCommentList = await CommentApi.getComments(pageId, parentComment.requestOffset);
      final commentTree = CommentTree(newTargetCommentList['posts'])..flatten();
      final newTargetComment = commentTree.data.singleWhere((item) => item['id'] == parentComment.id);

      if (newTargetComment != null) {
        newTargetComment['children'].forEach((item) => item['requestOffset'] = parentComment.requestOffset);
        parentComment.children = toMobxCommentList(newTargetComment['children']);
      }
    }

    data[pageId].status = data[pageId].commentTree.length == 0 ? 5 : 4;
  } 

  @action
  remove(int pageId, String commentId, [String rootCommentId]) async {
    await CommentApi.delComment(commentId);

    final foundItem = findByCommentId(pageId, commentId);
    if (foundItem.parentId == '') {
      final targetIndex = data[pageId].commentTree.indexOf(foundItem);
      data[pageId].commentTree.removeAt(targetIndex);
    } else {
      // 如果不是根评论，则要找到其父评论，并收集其所有子评论，删除本身和其子评论
      final foundRootComment = findByCommentId(pageId, rootCommentId);
      final childrenCommentIdList = [commentId];

      // 递归查找子评论的子评论
      collectChildrenCommentId(List<String> idList) {
        final oldListLength = childrenCommentIdList.length;
        final resultIdList = foundRootComment.children
          .where((item) => idList.contains(item.parentId))
          .map((item) => item.id);
        childrenCommentIdList.addAll(resultIdList);
        if (oldListLength != childrenCommentIdList.length) {
          collectChildrenCommentId(resultIdList);
        }
      }

      collectChildrenCommentId([commentId]);
      foundRootComment.children = foundRootComment.children
        .where((item) => childrenCommentIdList.contains(item.id));
    }

    data[pageId].status = data[pageId].commentTree.length == 0 ? 5 : 4;
  }

  @action
  refresh(int pageId) {
    data[pageId] = MobxPageComments();
    loadNext(pageId);
  }
}