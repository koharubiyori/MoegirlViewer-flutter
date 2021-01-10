// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'index.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$MobxCommentData on _MobxCommentDataBase, Store {
  final _$idAtom = Atom(name: '_MobxCommentDataBase.id');

  @override
  String get id {
    _$idAtom.reportRead();
    return super.id;
  }

  @override
  set id(String value) {
    _$idAtom.reportWrite(value, super.id, () {
      super.id = value;
    });
  }

  final _$userIdAtom = Atom(name: '_MobxCommentDataBase.userId');

  @override
  int get userId {
    _$userIdAtom.reportRead();
    return super.userId;
  }

  @override
  set userId(int value) {
    _$userIdAtom.reportWrite(value, super.userId, () {
      super.userId = value;
    });
  }

  final _$userNameAtom = Atom(name: '_MobxCommentDataBase.userName');

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

  final _$textAtom = Atom(name: '_MobxCommentDataBase.text');

  @override
  String get text {
    _$textAtom.reportRead();
    return super.text;
  }

  @override
  set text(String value) {
    _$textAtom.reportWrite(value, super.text, () {
      super.text = value;
    });
  }

  final _$timestampAtom = Atom(name: '_MobxCommentDataBase.timestamp');

  @override
  int get timestamp {
    _$timestampAtom.reportRead();
    return super.timestamp;
  }

  @override
  set timestamp(int value) {
    _$timestampAtom.reportWrite(value, super.timestamp, () {
      super.timestamp = value;
    });
  }

  final _$parentIdAtom = Atom(name: '_MobxCommentDataBase.parentId');

  @override
  String get parentId {
    _$parentIdAtom.reportRead();
    return super.parentId;
  }

  @override
  set parentId(String value) {
    _$parentIdAtom.reportWrite(value, super.parentId, () {
      super.parentId = value;
    });
  }

  final _$likeAtom = Atom(name: '_MobxCommentDataBase.like');

  @override
  int get like {
    _$likeAtom.reportRead();
    return super.like;
  }

  @override
  set like(int value) {
    _$likeAtom.reportWrite(value, super.like, () {
      super.like = value;
    });
  }

  final _$myattAtom = Atom(name: '_MobxCommentDataBase.myatt');

  @override
  int get myatt {
    _$myattAtom.reportRead();
    return super.myatt;
  }

  @override
  set myatt(int value) {
    _$myattAtom.reportWrite(value, super.myatt, () {
      super.myatt = value;
    });
  }

  final _$requestOffsetAtom = Atom(name: '_MobxCommentDataBase.requestOffset');

  @override
  int get requestOffset {
    _$requestOffsetAtom.reportRead();
    return super.requestOffset;
  }

  @override
  set requestOffset(int value) {
    _$requestOffsetAtom.reportWrite(value, super.requestOffset, () {
      super.requestOffset = value;
    });
  }

  final _$childrenAtom = Atom(name: '_MobxCommentDataBase.children');

  @override
  ObservableList<MobxCommentData> get children {
    _$childrenAtom.reportRead();
    return super.children;
  }

  @override
  set children(ObservableList<MobxCommentData> value) {
    _$childrenAtom.reportWrite(value, super.children, () {
      super.children = value;
    });
  }

  final _$targetAtom = Atom(name: '_MobxCommentDataBase.target');

  @override
  MobxCommentData get target {
    _$targetAtom.reportRead();
    return super.target;
  }

  @override
  set target(MobxCommentData value) {
    _$targetAtom.reportWrite(value, super.target, () {
      super.target = value;
    });
  }

  @override
  String toString() {
    return '''
id: ${id},
userId: ${userId},
userName: ${userName},
text: ${text},
timestamp: ${timestamp},
parentId: ${parentId},
like: ${like},
myatt: ${myatt},
requestOffset: ${requestOffset},
children: ${children},
target: ${target}
    ''';
  }
}
