import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/components/structured_list_view.dart';
import 'package:moegirl_plus/components/styled_widgets/app_bar_icon.dart';
import 'package:moegirl_plus/mobx/comment/classes/comment_data/index.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/utils/check_is_login.dart';
import 'package:moegirl_plus/utils/ui/dialog/loading.dart';
import 'package:moegirl_plus/utils/ui/toast/index.dart';
import 'package:moegirl_plus/views/comment/components/item.dart';
import 'package:moegirl_plus/views/comment/utils/show_comment_editor/index.dart';
import 'package:one_context/one_context.dart';

class CommentReplyPageRouteArgs {
  final int pageId;
  final String commentId;
  
  CommentReplyPageRouteArgs({
    this.pageId,
    this.commentId
  });
}

class CommentReplyPage extends StatefulWidget {
  final CommentReplyPageRouteArgs routeArgs;
  CommentReplyPage(this.routeArgs, {Key key}) : super(key: key);
  
  @override
  _CommentReplyPageState createState() => _CommentReplyPageState();
}

class _CommentReplyPageState extends State<CommentReplyPage> {
  int get pageId => widget.routeArgs.pageId;
  String get commentId => widget.routeArgs.commentId;
  MobxCommentData get commentData => commentStore.findByCommentId(pageId, commentId);
  
  void addReply([String initialValue = '']) async {
    await checkIsLogin();
    
    final commentContent = await showCommentEditor(
      targetName: commentData.userName,
      initialValue: initialValue,
      isReply: true
    );
    if (commentContent == null) return;
    showLoading(text: '提交中...');
    try {
      await commentStore.addComment(widget.routeArgs.pageId, commentContent, commentId);
      toast('发布成功', position: ToastPosition.center);
    } catch(e) {
      if (!(e is DioError)) rethrow;
      print('添加回复失败');
      print(e);
      toast('网络错误', position: ToastPosition.center);
      Future.microtask(() => addReply(commentContent));
    } finally {
      OneContext().pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Observer(
      builder: (context) {
        final replyData = commentStore.findByCommentId(pageId, commentId);
        return Scaffold(
          appBar: AppBar(
            title: Text('回复：${replyData.userName}'),
            actions: [AppBarIcon(icon: Icons.reply, onPressed: addReply)],
            elevation: 0,
          ),
          body: Container(
            color: settingsStore.isNightTheme ? theme.backgroundColor : Color(0xffeeeeee),
            child: StructuredListView<MobxCommentData>(
              itemDataList: commentData.children,
              reverse: true,
              
              headerBuilder: () => (
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommentPageItem(
                      isReply: true,
                      pageId: pageId,
                      commentData: commentData,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10).copyWith(top: 9),
                      child: Text('共${commentData.children.length}条回复',
                        style: TextStyle(
                          color: theme.hintColor,
                          fontSize: 17
                        ),
                      ),
                    )
                  ],
                )
              ),

              itemBuilder: (_, itemData, index) => (
                CommentPageItem(
                  pageId: pageId,
                  commentData: itemData,
                  rootCommentId: commentId,
                  visibleRpleyButton: true,
                  visibleDelButton: accountStore.userName == itemData.userName,
                )
              ),

              footerBuilder: () => (
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(vertical: 20).copyWith(top: 19),
                  child: Text('已经没有啦',
                    style: TextStyle(
                      color: theme.disabledColor,
                      fontSize: 17
                    )
                  ),
                )
              ),
            ),
          ),
        );
      },
    );
  }
}