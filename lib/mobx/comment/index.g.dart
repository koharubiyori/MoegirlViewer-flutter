// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$CommentStore on _CommentBase, Store {
  final _$dataAtom = Atom(name: '_CommentBase.data');

  @override
  Map<int, MobxPageComments> get data {
    _$dataAtom.reportRead();
    return super.data;
  }

  @override
  set data(Map<int, MobxPageComments> value) {
    _$dataAtom.reportWrite(value, super.data, () {
      super.data = value;
    });
  }

  final _$loadNextAsyncAction = AsyncAction('_CommentBase.loadNext');

  @override
  Future<dynamic> loadNext(int pageId) {
    return _$loadNextAsyncAction.run(() => super.loadNext(pageId));
  }

  final _$setLikeAsyncAction = AsyncAction('_CommentBase.setLike');

  @override
  Future<void> setLike(int pageId, String commentId, [bool like = true]) {
    return _$setLikeAsyncAction
        .run(() => super.setLike(pageId, commentId, like));
  }

  final _$addCommentAsyncAction = AsyncAction('_CommentBase.addComment');

  @override
  Future addComment(int pageId, String content, [String commentId]) {
    return _$addCommentAsyncAction
        .run(() => super.addComment(pageId, content, commentId));
  }

  final _$removeAsyncAction = AsyncAction('_CommentBase.remove');

  @override
  Future remove(int pageId, String commentId, [String rootCommentId]) {
    return _$removeAsyncAction
        .run(() => super.remove(pageId, commentId, rootCommentId));
  }

  final _$_CommentBaseActionController = ActionController(name: '_CommentBase');

  @override
  dynamic refresh(int pageId) {
    final _$actionInfo = _$_CommentBaseActionController.startAction(
        name: '_CommentBase.refresh');
    try {
      return super.refresh(pageId);
    } finally {
      _$_CommentBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
data: ${data}
    ''';
  }
}
