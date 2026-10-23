import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';

Future<void> saveFile(Uint8List bytes, String name, String mimeType) => SharePlus.instance.share(ShareParams(
      title: name,
      files: [XFile.fromData(bytes, mimeType: mimeType, name: name)],
      fileNameOverrides: [name],
    ));
