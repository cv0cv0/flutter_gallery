import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CupertinaActivityIndicatorPage extends StatelessWidget {
  static const routeName = '/cupertino/cupertino_activity_indicator';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Cupertina Activity Indicator'),
        ),
        body: const Center(
          child: CupertinoActivityIndicator(),
        ),
      );
}
