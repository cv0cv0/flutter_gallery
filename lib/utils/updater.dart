import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

typedef Future<String> UpdateUrlFetcher();

class Updater extends StatefulWidget {
  const Updater({@required this.updateUrlFetcher, this.child})
      : assert(updateUrlFetcher != null);

  final UpdateUrlFetcher updateUrlFetcher;
  final Widget child;

  @override
  State<StatefulWidget> createState() => _UpdaterState();
}

class _UpdaterState extends State<Updater> {
  static DateTime _lastUpdateCheck;

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  @override
  Widget build(BuildContext context) => widget.child;

  Future<void> _checkForUpdates() async {
    if (_lastUpdateCheck != null &&
        DateTime.now().difference(_lastUpdateCheck) < Duration(days: 1))
      return null;
    _lastUpdateCheck = DateTime.now();

    final updateUrl = await widget.updateUrlFetcher();
    if (updateUrl != null) {
      final wantsUpdate =
          await showDialog<bool>(context: context, builder: _buildDialog);
      if (wantsUpdate != null && wantsUpdate) launch(updateUrl);
    }
  }

  Widget _buildDialog(BuildContext context) {
    final theme = Theme.of(context);
    final dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    return AlertDialog(
      title: Text('Update Flutter Gallery?'),
      content: Text('A newer version is available.', style: dialogTextStyle),
      actions: <Widget>[
        FlatButton(
          child: Text('NO THANKS'),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        FlatButton(
          child: Text('UPDATE'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }
}
