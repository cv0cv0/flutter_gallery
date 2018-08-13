import 'package:flutter/material.dart';

class TypogaphyPage extends StatelessWidget {
  static const routeName = '/style/typogaphy';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Typography'),
        ),
        body: SafeArea(
          top: false,
          bottom: false,
          child: ListView(
            children: _buildStyleItems(context),
          ),
        ),
      );

  List<Widget> _buildStyleItems(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final styleItems = <Widget>[
      TextStyleItem(
        name: 'Display 3',
        text: 'Regular 56sp',
        style: textTheme.display3,
      ),
      TextStyleItem(
        name: 'Display 2',
        text: 'Regular 45sp',
        style: textTheme.display2,
      ),
      TextStyleItem(
        name: 'Display 1',
        text: 'Regular 34sp',
        style: textTheme.display1,
      ),
      TextStyleItem(
        name: 'Headline',
        text: 'Regular 24sp',
        style: textTheme.headline,
      ),
      TextStyleItem(
        name: 'Title',
        text: 'Medium 20sp',
        style: textTheme.title,
      ),
      TextStyleItem(
        name: 'Subheading',
        text: 'Regular 16sp',
        style: textTheme.subhead,
      ),
      TextStyleItem(
        name: 'Body 2',
        text: 'Medium 14sp',
        style: textTheme.body2,
      ),
      TextStyleItem(
        name: 'Body 1',
        text: 'Regular 14sp',
        style: textTheme.body1,
      ),
      TextStyleItem(
        name: 'Caption',
        text: 'Regular 12sp',
        style: textTheme.caption,
      ),
      TextStyleItem(
        name: 'Button',
        text: 'MEDIUM (ALL CAPS) 14sp',
        style: textTheme.button,
      ),
    ];

    if (MediaQuery.of(context).size.width > 500.0) {
      styleItems.insert(
        0,
        TextStyleItem(
          name: 'Display 4',
          text: 'Light 112sp',
          style: textTheme.display4,
        ),
      );
    }

    return styleItems;
  }
}

class TextStyleItem extends StatelessWidget {
  const TextStyleItem({this.name, this.text, this.style});

  final String name;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              width: 72.0,
              child: Text(name, style: Theme.of(context).textTheme.caption),
            ),
            Expanded(
              child: Text(text, style: style.copyWith(height: 1.0)),
            )
          ],
        ),
      );
}
