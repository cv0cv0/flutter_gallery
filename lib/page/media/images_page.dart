import 'package:flutter/material.dart';

import '../../widget/code_component.dart';

const _kAssetsPackage = 'flutter_gallery_assets';

class ImagesPage extends StatelessWidget {
  static const routeName = '/media/images';

  @override
  Widget build(BuildContext context) => TabbedComponentScaffold(
        title: 'Animated images',
        tabs: <ComponentTabData>[
          ComponentTabData(
            tabName: 'WEBP',
            description: '',
            codeTag: 'animated_image',
            page: Semantics(
              label: 'Example of animated WEBP',
              child: Image.asset(
                  'animated_images/animated_flutter_stickers.webp',
                  package: _kAssetsPackage),
            ),
          ),
          ComponentTabData(
            tabName: 'GIF',
            description: '',
            codeTag: 'animated_image',
            page: Semantics(
              label: 'Example of animated GIP',
              child: Image.asset('animated_images/animated_flutter_lgtm.gif',
                  package: _kAssetsPackage),
            ),
          ),
        ],
      );
}
