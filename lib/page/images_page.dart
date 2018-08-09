import 'package:flutter/material.dart';

import '../widget/code_component.dart';

class ImagesPage extends StatelessWidget {
  static const routeName='/images';

  @override
  Widget build(BuildContext context) => TabbedComponentScaffold(
    title: 'Animated images',
    tabs: <ComponentTabData>[
      ComponentTabData(
        tabName: 'ANIMATED WEBP',
        description: '',
        codeTag: 'animated_image',
        page: Semantics(
          label: 'Example of animated WEBP',
          child: Image.asset('packages/flutter_gallery_assets/animated_flutter_stickers.webp'),
        ),
      ),
      ComponentTabData(
        tabName: 'ANIMATED GIF',
        description: '',
        codeTag: 'animated_image',
        page: Semantics(
          label: 'Example of animated GIP',
          child: Image.asset('packages/flutter_gallery_assets/animated_flutter_lgtm.gif'),
        ),
      ),
    ],
  );
}