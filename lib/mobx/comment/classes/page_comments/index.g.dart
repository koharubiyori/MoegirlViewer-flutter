// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MobxPageComments on _MobxPageCommentsBase, Store {
  final _$popularAtom = Atom(name: '_MobxPageCommentsBase.popular');

  @override
  List<MobxCommentData> get popular {
    _$popularAtom.reportRead();
    return super.popular;
  }

  @override
  set popular(List<MobxCommentData> value) {
    _$popularAtom.reportWrite(value, super.popular, () {
      super.popular = value;
    });
  }

  final _$commentTreeAtom = Atom(name: '_MobxPageCommentsBase.commentTree');

  @override
  List<MobxCommentData> get commentTree {
    _$commentTreeAtom.reportRead();
    return super.commentTree;
  }

  @override
  set commentTree(List<MobxCommentData> value) {
    _$commentTreeAtom.reportWrite(value, super.commentTree, () {
      super.commentTree = value;
    });
  }

  final _$offsetAtom = Atom(name: '_MobxPageCommentsBase.offset');

  @override
  int get offset {
    _$offsetAtom.reportRead();
    return super.offset;
  }

  @override
  set offset(int value) {
    _$offsetAtom.reportWrite(value, super.offset, () {
      super.offset = value;
    });
  }

  final _$countAtom = Atom(name: '_MobxPageCommentsBase.count');

  @override
  int get count {
    _$countAtom.reportRead();
    return super.count;
  }

  @override
  set count(int value) {
    _$countAtom.reportWrite(value, super.count, () {
      super.count = value;
    });
  }

  final _$statusAtom = Atom(name: '_MobxPageCommentsBase.status');

  @override
  num get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(num value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  @override
  String toString() {
    return '''
popular: ${popular},
commentTree: ${commentTree},
offset: ${offset},
count: ${count},
status: ${status}
    ''';
  }
}
