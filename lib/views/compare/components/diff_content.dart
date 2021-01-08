import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/components/styled_widgets/scrollbar.dart';
import 'package:moegirl_plus/components/touchable_opacity.dart';
import 'package:moegirl_plus/constants.dart';
import 'package:moegirl_plus/mobx/index.dart';
import 'package:moegirl_plus/views/article/index.dart';
import 'package:moegirl_plus/views/compare/utils/collect_diff_blocks_from_html.dart';
import 'package:one_context/one_context.dart';

class CompareDiffContent extends StatefulWidget {
  final List<DiffLine> diffLines;
  final String userName;
  final String comment;
  // final List<List<double>> syncRowHeights;
  // final Function(num value) onScroll;
  // final Function(List<List<double>>) emitRenderedRowHeights;
  
  CompareDiffContent({
    @required this.diffLines,
    @required this.userName,
    @required this.comment,
    // @required this.syncRowHeights,
    // @required this.onScroll,
    // @required this.emitRenderedRowHeights,
    Key key
  }) : super(key: key);

  @override
  _CompareDiffContentState createState() => _CompareDiffContentState();
}

class _CompareDiffContentState extends State<CompareDiffContent> with AutomaticKeepAliveClientMixin {
  get wantKeepAlive => true;
  
  static final borderColors = {
    'normal': {
      DiffRowMarker.none: Color(0xffe6e6e6),
      DiffRowMarker.plus: Color(0xffd8ecff),
      DiffRowMarker.minus: Color(0xffffe49c)
    },

    'night': {
      DiffRowMarker.none: Color(0xff6D6D6D),
      DiffRowMarker.plus: Color(0xff81DAF5),
      DiffRowMarker.minus: Color(0xffFFCC00)
    }
  };
  
  static final contentColors = {
    'normal': {
      DiffRowContentType.plain: Colors.transparent,
      DiffRowContentType.add: Color(0xffd8ecff),
      DiffRowContentType.delete: Color(0xffffe49c),
    },

    'night': {
      DiffRowContentType.plain: Colors.transparent,
      DiffRowContentType.add: Color(0xff81DAF5).withOpacity(0.3),
      DiffRowContentType.delete: Color(0xffFFCC00).withOpacity(0.3),
    }
  };

  final List<List<GlobalKey>> lineGlobalKeys = [];
  final List<List<double>> lineRowsSyncHeights = [];

  @override
  void initState() { 
    super.initState();

    // 为每个line.row准备一个globalKey
    // widget.diffLines.forEach((line) {
    //   final List<GlobalKey> rowKeys = [];
    //   while (rowKeys.length < line.rows.length) {
    //     rowKeys.add(GlobalKey());
    //   }

    //   lineGlobalKeys.add(rowKeys);
    // });
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // final rowHeights = lineGlobalKeys.map((line) {
    //   return line.map((row) => row.currentContext.findRenderObject().semanticBounds.size.height).toList();
    // }).toList();
    
    // widget.emitRenderedRowHeights(rowHeights);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5).copyWith(top: 3),
      child: StyledScrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TouchableOpacity(
                            onPressed: () => OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(pageName: 'User:${widget.userName}')),
                            child: Container(
                              width: 30,       
                              height: 30,
                              margin: EdgeInsets.only(right: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                image: DecorationImage(
                                  image: NetworkImage(avatarUrl + widget.userName)
                                )
                              ),
                            ),
                          ),

                          TouchableOpacity(
                            onPressed: () => OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(pageName: 'User:${widget.userName}')),
                            child: Text(widget.userName,
                              style: TextStyle(
                                color: theme.accentColor,
                                fontSize: 14,
                                height: 1
                              ),
                            )
                          ),

                          TouchableOpacity(
                            onPressed: () => OneContext().pushNamed('/article', arguments: ArticlePageRouteArgs(pageName: 'User_talk:${widget.userName}')),
                            child: Text('（讨论）',
                              style: TextStyle(
                                color: theme.accentColor,
                                fontSize: 14,
                                height: 1
                              ),
                            )
                          )
                        ],
                      ),

                      Container(
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(10),
                        child: widget.comment == '' ? 
                          Text('（暂无编辑摘要）', style: TextStyle(color: theme.disabledColor)) :
                          Text('摘要：${widget.comment}')
                      )
                  ],
                ),
              ),

              Container(
                child: Column(
                  children: widget.diffLines.asMap().map((lineIndex, line) =>
                    MapEntry(lineIndex, 
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(line.lineHint,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),

                          Container(
                            height: 3,
                            color: theme.accentColor,
                            margin: EdgeInsets.only(right: 10, bottom: 10),
                          ),

                          ...line.rows.asMap().map((rowIndex, row) =>
                            MapEntry(rowIndex,
                              Row(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(right: 5),
                                    child: row.marker != DiffRowMarker.none ? 
                                      Padding(
                                        padding: EdgeInsets.only(bottom: 3),
                                        child: Icon(row.marker == DiffRowMarker.plus ? Icons.add : Icons.remove, 
                                          size: 20,
                                          color: theme.disabledColor,
                                        ),
                                      )
                                    :
                                      Container(width: 20)
                                    ,
                                  ),
                                  
                                  Observer(
                                    builder: (context) => (
                                      Expanded(
                                        child: Container(
                                          // key: lineGlobalKeys[lineIndex][rowIndex],
                                          // height: widget.syncRowHeights != null ? widget.syncRowHeights[lineIndex][rowIndex] : null,
                                          margin: EdgeInsets.only(bottom: 5),
                                          padding: EdgeInsets.only(left: 5, top: 3, bottom: 3),
                                          decoration: BoxDecoration(
                                            border: Border(
                                              left: BorderSide(color: borderColors[settingsStore.isNightTheme ? 'night' : 'normal'][row.marker], width: 5)
                                            ),
                                          ),
                                          child: RichText(
                                            text: TextSpan(
                                              style: TextStyle(
                                                color: theme.textTheme.bodyText1.color,
                                              ),
                                              children: row.content.map((item) => 
                                                TextSpan(
                                                  text: item.text,
                                                  style: TextStyle(
                                                    backgroundColor: contentColors[settingsStore.isNightTheme ? 'night' : 'normal'][item.type],
                                                  )
                                                )
                                              ).toList()
                                            ),
                                          )
                                        )
                                      )
                                    ),
                                  )
                                ],
                              )
                            )
                          ).values.toList()
                        ],
                      )
                    )
                  ).values.toList(),
                ),
              )
            ],
          ),
        ),
      )
    );
  }
}