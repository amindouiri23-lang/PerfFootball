import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

Widget? embeddedVideo(String src, {required bool iframe}) => HtmlElementView.fromTagName(
      key: ValueKey(src),
      tagName: iframe ? 'iframe' : 'video',
      onElementCreated: (Object e) {
        final el = e as web.HTMLElement;
        el.setAttribute('src', src);
        el.style
          ..border = '0'
          ..width = '100%'
          ..height = '100%'
          ..backgroundColor = 'black';
        if (iframe) {
          el.setAttribute('allow', 'autoplay; encrypted-media; fullscreen; picture-in-picture');
          el.setAttribute('allowfullscreen', 'true');
        } else {
          el.setAttribute('controls', 'true');
          el.setAttribute('playsinline', 'true');
        }
      },
    );
