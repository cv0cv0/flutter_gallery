import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cupertino_navigation_page.dart' show coolColorNames;

const _kPickerSheetHeight = 216.0;
const _kPickerItemHeight = 32.0;

class CupertinoPickerPage extends StatefulWidget {
  static const routeName = '/cupertino/picker';

  @override
  _CupertinoPickerPageState createState() => _CupertinoPickerPageState();
}

class _CupertinoPickerPageState extends State<CupertinoPickerPage> {
  var duration = Duration();
  int _selectedColorIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Cupertino Picker'),
        ),
        body: DefaultTextStyle(
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 17.0,
            fontFamily: '.SF UI Text',
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFF4),
            ),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 32.0),
                GestureDetector(
                  onTap: () async {
                    await showCupertinoModalPopup(
                      context: context,
                      builder: (context) =>
                          _buildBottomPicker(_buildColorPicker()),
                    );
                  },
                  child: _buildMenu(<Widget>[
                    const Text('Favorite Color'),
                    Text(coolColorNames[_selectedColorIndex],
                        style: const TextStyle(
                            color: CupertinoColors.inactiveGray))
                  ]),
                ),
                _buildCountdownTimerPicker(context),
              ],
            ),
          ),
        ),
      );

  Widget _buildColorPicker() {
    final scrollController =
        FixedExtentScrollController(initialItem: _selectedColorIndex);
    return CupertinoPicker(
      scrollController: scrollController,
      backgroundColor: CupertinoColors.white,
      itemExtent: _kPickerItemHeight,
      onSelectedItemChanged: (index) =>
          setState(() => _selectedColorIndex = index),
      children: List.generate(
          coolColorNames.length,
          (i) => Center(
                child: Text(coolColorNames[i]),
              )),
    );
  }

  Widget _buildCountdownTimerPicker(BuildContext context) => GestureDetector(
        onTap: () => showCupertinoModalPopup(
            context: context,
            builder: (context) => _buildBottomPicker(CupertinoTimerPicker(
                  initialTimerDuration: duration,
                  onTimerDurationChanged: (newDuration) =>
                      setState(() => duration = newDuration),
                ))),
        child: _buildMenu(<Widget>[
          const Text('Countdown Timer'),
          Text(
              '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: CupertinoColors.inactiveGray))
        ]),
      );

  Widget _buildBottomPicker(Widget picker) => Container(
        height: _kPickerSheetHeight,
        color: CupertinoColors.white,
        child: DefaultTextStyle(
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 22.0,
          ),
          child: GestureDetector(
            onTap: () {},
            child: SafeArea(child: picker),
          ),
        ),
      );

  Widget _buildMenu(List<Widget> chidren) => Container(
        height: 44.0,
        decoration: const BoxDecoration(
          color: CupertinoColors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
            bottom: BorderSide(color: Color(0xFFBCBBC1), width: 0.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SafeArea(
            top: false,
            bottom: false,
            child: DefaultTextStyle(
              style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 17.0,
                letterSpacing: -0.24,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: chidren,
              ),
            ),
          ),
        ),
      );
}
