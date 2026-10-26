import 'package:flutter/widgets.dart';

import 'video_view_io.dart' if (dart.library.js_interop) 'video_view_web.dart' as impl;

/// Lecteur intégré (version web : iframe YouTube / Vimeo ou balise vidéo). null sur téléphone : la vidéo
/// s'ouvre alors dans l'application YouTube ou le navigateur.
Widget? embeddedVideo(String src, {required bool iframe}) => impl.embeddedVideo(src, iframe: iframe);
