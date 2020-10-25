import 'package:flutter/material.dart';
import 'package:moegirl_viewer/providers/settings.dart';
import 'package:provider/provider.dart';

class NightSelector extends StatelessWidget {
  final Widget Function(bool isNight) builder;

  const NightSelector({
    @required this.builder,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<SettingsProviderModel, bool>(
      selector: (_, model) => model.theme == 'night',
      builder: (_, isNight, __) => builder(isNight),
    );
  }
}