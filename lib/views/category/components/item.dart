import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/components/touchable_opacity.dart';
import 'package:moegirl_plus/mobx/index.dart';

class CategoryPageItem extends StatelessWidget {
  final String pageName;
  final String imgUrl;
  final List<String> categories;
  final void Function() onPressed;
  final void Function(String categoryName) onCategoryPressed;
  
  const CategoryPageItem({
    @required this.pageName,
    @required this.imgUrl,
    @required this.categories,
    @required this.onPressed,
    @required this.onCategoryPressed,
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10).copyWith(top: 10),
      child: TouchableOpacity(
        onPressed: onPressed,
        child: Material(
          color: theme.colorScheme.surface,
          elevation: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(1)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pageName,
                          style: TextStyle(
                            fontSize: 17
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 15),
                          child: Wrap(
                            children: categories.map((category) =>
                              TouchableOpacity(
                                onPressed: () => onCategoryPressed(category),
                                child: Observer(
                                  builder: (context) => (
                                    IntrinsicWidth(
                                      child: Container(
                                        margin: EdgeInsets.only(right: 5, bottom: 5),
                                        padding: EdgeInsets.symmetric(vertical: 3, horizontal: 3),
                                        color: settingsStore.isNightTheme ? theme.dividerColor.withOpacity(0.5) : theme.primaryColor,
                                        alignment: Alignment.center,
                                        child: Text(category,
                                          style: TextStyle(
                                            height: 1.1,
                                            color: settingsStore.isNightTheme ? theme.textTheme.bodyText1.color : Colors.white,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    )
                                  ),
                                ),
                              )
                            ).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                imgUrl != null ? 
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 150
                    ),
                    child: Image.network(imgUrl,
                      width: 120,
                      fit: BoxFit.cover,
                    )
                  )
                :
                  Observer(
                    builder: (context) => (
                        Container(
                        width: 120,
                        height: 150,
                        color: settingsStore.isNightTheme ? Color(0xff5b5b5b) : Color(0xffe2e2e2),
                        alignment: Alignment.center,
                        child: Text('暂无图片',
                          style: TextStyle(
                            color: theme.disabledColor,
                            fontSize: 18
                          ),
                        ),
                      )
                    ),
                  )
                ,
              ],
            ),
          ),
        ),
      ),
    );
  }
}