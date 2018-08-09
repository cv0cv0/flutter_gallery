import 'package:flutter/material.dart';

import '../util/code_parser.dart';
import '../util/syntax_highlighter.dart';

class TabbedComponentScaffold extends StatelessWidget {
  const TabbedComponentScaffold({this.title, this.tabs, this.actions});

  final String title;
  final List<ComponentTabData> tabs;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: (actions ?? <Widget>[])
              ..addAll(<Widget>[
                Builder(
                  builder: (context) => IconButton(
                        icon: const Icon(Icons.description),
                        tooltip: 'Show example code',
                        onPressed: () => _showCodeDialog(context),
                      ),
                ),
              ]),
            bottom: TabBar(
              isScrollable: true,
              tabs: tabs.map((tab) => Tab(text: tab.tabName)).toList(),
            ),
          ),
          body: TabBarView(
            children: tabs
                .map((tab) => SafeArea(
                      top: false,
                      bottom: false,
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(tab.description,
                                style: Theme.of(context).textTheme.subhead),
                          ),
                          Expanded(child: tab.page),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      );

  void _showCodeDialog(BuildContext context) {
    final tag = tabs[DefaultTabController.of(context).index].codeTag;
    if (tag != null) {
      Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => FullScreenCodeDialog(tag),
          ));
    }
  }
}

class FullScreenCodeDialog extends StatefulWidget {
  const FullScreenCodeDialog(this.codeTag);

  final String codeTag;

  @override
  _FullScreenCodeDialogState createState() => _FullScreenCodeDialogState();
}

class _FullScreenCodeDialogState extends State<FullScreenCodeDialog> {
  String _code;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.clear,
              semanticLabel: 'Close',
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Example code'),
        ),
        body: _buildBody(context),
      );

  @override
  void didChangeDependencies() {
    getCode(widget.codeTag, DefaultAssetBundle.of(context)).then<Null>((code) {
      if (mounted) {
        setState(() {
          _code = code ?? 'Example code not found';
        });
      }
    });
    super.didChangeDependencies();
  }

  Widget _buildBody(BuildContext context) {
    final style = Theme.of(context).brightness == Brightness.dark
        ? SyntaxHighlighterStyle.dartThemeStyle()
        : SyntaxHighlighterStyle.lightThemeStyle();

    Widget body;
    if (_code == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontFamily: 'monospace', fontSize: 10.0),
              children: <TextSpan>[
                SyntaxHighlighter(style).format(_code),
              ],
            ),
          ),
        ),
      );
    }
    return body;
  }
}

class ComponentTabData {
  ComponentTabData({this.tabName, this.description, this.codeTag, this.page});

  final String tabName;
  final String description;
  final String codeTag;
  final Widget page;

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    return other.tabName == tabName && other.description == description;
  }

  @override
  int get hashCode => hashValues(tabName.hashCode, description.hashCode);
}
