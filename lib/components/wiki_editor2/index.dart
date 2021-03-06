import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:moegirl_plus/components/styled_widgets/scrollbar.dart';
import 'package:moegirl_plus/components/wiki_editor2/components/quick_inserting_button.dart';
import 'package:moegirl_plus/language/index.dart';
import 'package:moegirl_plus/utils/keyboard_visible_aware.dart';

class WikiEditor2 extends StatefulWidget {
  final String initialValue;
  final bool newSection;
  final FocusNode focusNode;
  final bool quickInsertBarEnabled;
  final void Function(String) onChanged;
  
  WikiEditor2({
    this.initialValue,
    this.newSection = false,
    this.focusNode,
    this.quickInsertBarEnabled = true,
    this.onChanged,
    Key key
  }) : super(key: key);

  @override
  _WikiEditor2State createState() => _WikiEditor2State();
}

class _WikiEditor2State extends State<WikiEditor2> with 
  WidgetsBindingObserver, 
  KeyboardVisibleAware
{
  bool visibleQuickInsertBar = false;
  final textEditingController = TextEditingController();

  @override
  void initState() { 
    super.initState();
    textEditingController.text = widget.initialValue;

    if (widget.newSection) {
      insertText('== ${Lang.wikiEditorCom_newSectionTitle} ==', 3, 2);
      // widget.focusNode.requestFocus();
    }
  }

  @override
  void dispose(){
    super.dispose();
    textEditingController.dispose();
  }

  @override
  void didShowKeyboard() {
    super.didShowKeyboard();
    setState(() => visibleQuickInsertBar = true);
  }

  @override
  void didHideKeyboard() {
    super.didHideKeyboard();
    setState(() => visibleQuickInsertBar = false);
  }

  // 如果有selectionOffset，则minusOffset的负偏移作为选中的终点，selectionStart的负偏移(以minusOffset为原点)作为选择的起点
  insertText(String text, [int minusOffset = 0, int selectionOffset = 0]) {
    final content = textEditingController.text;
    int location = textEditingController.selection.end;
    if (location == -1) location = 0;
    final before = content.substring(0, location);
    final after = content.substring(location);
    final newLocation = location + text.length - minusOffset;

    textEditingController.text = before + text + after;
    textEditingController.selection = TextSelection(
      baseOffset: newLocation - selectionOffset,
      extentOffset: newLocation
    );

    widget.onChanged(textEditingController.text);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Expanded(
          child: StyledScrollbar(
            child: TextField(
              focusNode: widget.focusNode,
              controller: textEditingController,
              minLines: null,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Consolas',
              ),
              decoration: InputDecoration(
                fillColor: Colors.white,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 3).copyWith(top: -4, bottom: 3),
                hintText: Lang.wikiEditorCom_inputPlaceholder
              ),
              onChanged: widget.onChanged,
            ),
          ),
        ),
        Offstage(
          offstage: !(visibleQuickInsertBar && widget.quickInsertBarEnabled),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              border: Border(
                top: BorderSide(color: theme.dividerColor)
              )
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  QuickInsertingButton(
                    title: '[[ ]]',
                    subtitle: Lang.wikiEditorCom_link,
                    onPressed: () => insertText('[[]]', 2),
                  ),
                  QuickInsertingButton(
                    title: '{{ }}',
                    subtitle: Lang.wikiEditorCom_template,
                    onPressed: () => insertText('{{}}', 2),
                  ),
                  QuickInsertingButton(
                    title: '|',
                    subtitle: Lang.wikiEditorCom_pipeChar,
                    onPressed: () => insertText('|'),
                  ),
                  QuickInsertingButton(
                    icon: MaterialCommunityIcons.fountain_pen_tip,
                    subtitle: Lang.wikiEditorCom_sign,
                    onPressed: () => insertText('--~~~~'),
                  ),
                  QuickInsertingButton(
                    title: Lang.wikiEditorCom_strong,
                    onPressed: () => insertText("''''''", 3),
                  ),
                  QuickInsertingButton(
                    title: '<del>',
                    subtitle: Lang.wikiEditorCom_delLine,
                    onPressed: () => insertText('<del></del>', 6),
                  ),
                  QuickInsertingButton(
                    title: Lang.wikiEditorCom_heimu,
                    onPressed: () => insertText('{{${Lang.wikiEditorCom_heimu}|}}', 2),
                  ),
                  QuickInsertingButton(
                    title: Lang.wikiEditorCom_colorText,
                    onPressed: () => insertText('{{color|${Lang.wikiEditorCom_ColorTextPlaceholder}}}', 5, 2),
                  ),
                  QuickInsertingButton(
                    title: '*',
                    subtitle: Lang.wikiEditorCom_unorderedList,
                    onPressed: () => insertText('* '),
                  ),
                  QuickInsertingButton(
                    title: '#',
                    subtitle: Lang.wikiEditorCom_list,
                    onPressed: () => insertText('# '),
                  ),
                  QuickInsertingButton(
                    title: Lang.wikiEditorCom_level2Title,
                    onPressed: () => insertText('==  ==', 3),
                  ),
                  QuickInsertingButton(
                    title: Lang.wikiEditorCom_level3Title,
                    onPressed: () => insertText('===  ===', 4),
                  )
                ],
              ),
            ),
          ),
        )
      ]
    );
  }
}