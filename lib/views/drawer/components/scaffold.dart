import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:moegirl_plus/mobx/index.dart';

class DrawerScaffold extends StatelessWidget {
  final num width;
  final Widget header;
  final Widget body;
  final Widget footer;
  const DrawerScaffold({
    this.width,
    @required this.header,
    @required this.body,
    @required this.footer,
    Key key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
    width: width,
      child: Drawer(
        child: Column(
          children: [
            header,
            Expanded(
              child: Observer(
                builder: (isNight) => (
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.backgroundColor,
                      image: DecorationImage(
                        image: AssetImage('assets/images/drawer_bg.png'),
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topLeft,
                        colorFilter: ColorFilter.mode(
                          (settingsStore.isNightTheme ? Colors.black : Colors.white).withOpacity(0.2), 
                        BlendMode.dstATop)
                      )
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: body,
                        ),
                        footer,
                      ],
                    ),
                  )
                ),
              )
            )
          ],
        )
      ),
    );
  }
}