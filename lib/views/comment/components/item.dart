import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/api/comment.dart';
import 'package:moegirl_plus/components/touchable_opacity.dart';
import 'package:moegirl_plus/constants.dart';
import 'package:moegirl_plus/mobx/comment/classes/comment_data/index.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/utils/check_is_login.dart';
import 'package:moegirl_plus/utils/diff_date.dart';
import 'package:moegirl_plus/utils/trim_html.dart';
import 'package:moegirl_plus/utils/ui/dialog/alert.dart';
import 'package:moegirl_plus/utils/ui/dialog/loading.dart';
import 'package:moegirl_plus/utils/ui/toast/index.dart';
import 'package:moegirl_plus/views/article/index.dart';
import 'package:moegirl_plus/views/comment/utils/show_comment_editor/index.dart';
import 'package:moegirl_plus/views/comment/views/reply/index.dart';
import 'package:one_context/one_context.dart';

const replyHeaderHeroTag = 'replyHeaderHeroTag';

class CommentPageItem extends StatelessWidget {
  final MobxCommentData commentData;
  final int pageId;
  final String rootCommentId;
  final bool isReply;
  final bool isPopular;
  final bool visibleReply;
  final bool visibleRpleyButton;
  final bool visibleDelButton;
  final void Function(String commentId) onReplyButtonPressed;
  final void Function(String userName) onTargetUserNamePressed;
  
  const CommentPageItem({
    @required this.commentData,
    @required this.pageId,
    this.rootCommentId,
    this.isReply = false,
    this.isPopular = false,
    this.visibleReply = false,
    this.visibleDelButton = false,
    this.visibleRpleyButton = false,
    this.onReplyButtonPressed,
    this.onTargetUserNamePressed,
    Key key
  }) : super(key: key);

  void toggleLike() async {
    await checkIsLogin();

    final isLiked = commentData.myatt == 1;
    showLoading();
    try {
      commentStore.setLike(pageId, commentData.id, !isLiked);
    } catch(e) {
      print('点赞操作失败');
      print(e);
      toast('网络错误');
    } finally {
      OneContext().pop();
    }
  }

  void delComment() async {
    final result = await showAlert(
      content: '确定要删除自己的这条${isReply ? '回复' : '评论'}吗？',
      visibleCloseButton: true
    );

    if (!result) return;
    showLoading();
    try {
      await commentStore.remove(pageId, commentData.id, rootCommentId);
      toast('评论已删除');
    } catch(e) {
      print('删除操作失败');
      print(e);
      toast('网络错误');
    } finally {
      OneContext().pop();
    }
  }

  void replyComment() async {
    await checkIsLogin();
    
    final commentContent = await showCommentEditor(
      targetName: commentData.userName,
      isReply: true
    );
    if (commentContent == null) return;
    showLoading(text: '提交中...');
    try {
      await commentStore.addComment(pageId, commentContent, commentData.id);
      toast('发布成功', position: ToastPosition.center);
    } catch(e) {
      if (!(e is DioError)) rethrow;
      print('添加回复失败');
      print(e);
      toast('网络错误', position: ToastPosition.center);
    } finally {
      OneContext().pop();
    }
  }

  void report() async {
    final result = await showAlert(
      content: '确定要举报这条${isReply ? '回复' : '评论'}吗？',
      visibleCloseButton: true
    );
    if (!result) return;

    showLoading();
    try {
      await CommentApi.report(commentData.id);
      Future.microtask(() => showAlert(content: '已举报，感谢您的反馈'));
    } catch(e) {
      print('举报评论失败');
      print(e);
      toast('网络错误');
    } finally {
      OneContext().pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // 为回复带上回复对象的数据
    final List<MobxCommentData> replyList = commentData.children != null ? 
      commentData.children.map((item) {
        if (item.parentId != commentData.id) {
          item.target = commentData.children.firstWhere((childItem) => childItem.id == item.parentId, orElse: () => null);
        }
        return item;
      }).toList() 
    : [];
    
    return Hero(
      tag: commentData.id + (isPopular ? '-popular' : ''),
      child: Container(
      margin: EdgeInsets.only(bottom: 1),
        child: Material(
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () {},
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Column(
                children: [
                  // 头部
                  Stack(
                    children: [
                      Row(
                        children: [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () => OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(
                              pageName: 'User:' + commentData.userName
                            )),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                image: DecorationImage(
                                  image: NetworkImage(avatarUrl + commentData.userName)
                                )
                              ),
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(commentData.userName,
                                style: TextStyle(color: theme.textTheme.bodyText1.color),
                              ),
                              Text(diffDate(DateTime.fromMillisecondsSinceEpoch(commentData.timestamp * 1000)),
                                style: TextStyle(color: theme.hintColor),
                              )
                            ]
                          )
                        ],
                      ),

                      if (visibleDelButton) (
                        Positioned(
                          width: 20,
                          height: 20,
                          top: 0,
                          right: 0,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: delComment,
                            child: Icon(Icons.clear,
                              color: theme.disabledColor,
                              size: 20,
                            ),
                          ),
                        )
                      )
                    ],
                  ),

                  Padding(
                    padding: EdgeInsets.only(left: 50),
                    child: Column(
                      children: [
                        // 评论内容
                        Container(
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(top: 10),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(color: theme.textTheme.bodyText1.color),
                              children: [
                                if (commentData.target != null) (
                                  TextSpan(
                                    children: [
                                      TextSpan(text: '回复 '),
                                      TextSpan(
                                        text: commentData.target.userName + ' ',
                                        style: TextStyle(color: theme.accentColor)
                                      )
                                    ]
                                  )
                                ),

                                TextSpan(text: trimHtml(commentData.text))
                              ]
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.only(right: 25, top: 10),
                          child: Row(
                            children: [
                              Row(
                                children: [
                                  TouchableOpacity(
                                    onPressed: toggleLike,
                                    child: Observer(
                                      builder: (context) {
                                        final foundData = commentStore.findByCommentId(pageId, commentData.id, isPopular);
                                        if (foundData == null) return Container();  // 删除评论时会触发这里导致找到的评论数据为null
                                        final likeNumber = foundData.like;
                                        final myLiked = foundData.myatt == 1;
                                        
                                        return Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 1),
                                              child: [
                                                if (likeNumber == 0) Icon(AntDesign.like2,
                                                  color: theme.disabledColor,
                                                  size: 17,
                                                ),
                                                if (likeNumber > 0 && !myLiked) Icon(AntDesign.like2,
                                                  color: theme.accentColor,
                                                  size: 17,
                                                ),
                                                if (myLiked) Icon(AntDesign.like1,
                                                  color: theme.accentColor,
                                                  size: 17,
                                                )
                                              ][0],
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(left: 5, top: 2.5),
                                              child: Text(likeNumber.toString(),
                                                style: TextStyle(
                                                  color: likeNumber > 0 ? theme.accentColor : theme.disabledColor,
                                                  fontSize: 13
                                                ),
                                              ),
                                            )
                                          ]
                                        );
                                      },
                                    )
                                  ),

                                  if (visibleRpleyButton) Padding(
                                    padding: EdgeInsets.only(left: 20),
                                    child: TouchableOpacity(
                                      onPressed: replyComment,
                                      child: Row(
                                        children: [
                                          Icon(MaterialCommunityIcons.reply,
                                            color: theme.accentColor,
                                            size: 20,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 5, top: 1),
                                            child: Text('回复',
                                              style: TextStyle(
                                                color: theme.accentColor,
                                                fontSize: 13
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  )
                                ],
                              ),

                              Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: CupertinoButton(
                                  minSize: 0,
                                  padding: EdgeInsets.zero,
                                  onPressed: report,
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Icon(Icons.assistant_photo,
                                          color: theme.dividerColor,
                                          size: 19,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5, top: 1),
                                        child: Text('举报',
                                          style: TextStyle(
                                            color: theme.dividerColor,
                                            fontSize: 13
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),

                        // 回复
                        if (visibleReply && commentData.children.length != 0) (
                          Observer(
                            builder: (context) => (
                              Container(
                                alignment: Alignment.topLeft,
                                margin: EdgeInsets.only(top: 10, right: 25, bottom: 5),
                                padding: EdgeInsets.all(10),
                                color: settingsStore.isNightTheme ? theme.backgroundColor : Color(0xffededed),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...replyList.take(3).map((item) =>
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 2),
                                        child: RichText(
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          text: TextSpan(
                                            style: TextStyle(
                                              color: theme.textTheme.bodyText1.color,
                                              fontSize: 13,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: item.userName,
                                                style: TextStyle(color: theme.accentColor)
                                              ),
                                              if (item.target != null) TextSpan(text: ' 回复 '),
                                              if (item.target != null) TextSpan(
                                                text: item.target.userName,
                                                style: TextStyle(color: theme.accentColor)
                                              ),
                                              TextSpan(text: '：'),
                                              TextSpan(text: trimHtml(item.text))
                                            ]
                                          ),
                                        ),
                                      )
                                    ).toList(),

                                    CupertinoButton(
                                      minSize: 0,
                                      padding: EdgeInsets.only(top: 3),
                                      onPressed: () => OneContext().pushNamed('/comment/reply', arguments: CommentReplyPageRouteArgs(
                                        pageId: pageId,
                                        commentId: commentData.id
                                      )),
                                      child: Text('共${replyList.length}条回复 >',
                                        style: TextStyle(
                                          color: theme.accentColor,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ),
                          )
                        ),
                      ],
                    ),
                  )
                ],
              )
            ),
          ),
        ),
      ),
    );
  }
}