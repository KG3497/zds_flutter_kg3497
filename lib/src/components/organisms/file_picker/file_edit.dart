import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_editor_plus/image_editor_plus.dart';
import 'package:path/path.dart' as path;

import '../../../../zds_flutter.dart';
import '../temp_directory/resolver.dart';

/// Editors used to edit only image files & to launch other types of files
class ZdsFileEditPostProcessor implements ZdsFilePostProcessor {
  ///default constructor
  ZdsFileEditPostProcessor(
    this.buildContext, {
    this.initialCropAspectRatio = ZdsAspectRatio.ratio1x1,
  });

  ///Context used for navigations and toasts
  final BuildContextProvider buildContext;

  /// Initial Aspect ratio of crop rect
  /// default is [ZdsAspectRatio.original]
  ///
  /// The argument only affects the initial aspect ratio.
  final ZdsAspectRatio initialCropAspectRatio;

  @override
  Future<FileWrapper> process(FilePickerConfig config, FileWrapper file) async {
    if (kIsWeb) return file;

    if (file.isImage() && file.content != null) {
      final originalFile = File(file.xFilePath);
      ImageEditor.i18n(ComponentStrings.of(buildContext.call()).getAll());
      final bytes = await Navigator.push<Uint8List>(
        buildContext.call(),
        MaterialPageRoute(
          builder: (context) {
            return SingleImageEditor(
              image: originalFile.readAsBytesSync(),
            );
          },
        ),
      );

      if (bytes != null) {
        final dir = await zdsTempDirectory('edited');
        await originalFile.delete(recursive: true);
        final result = File(path.join(dir, path.basename(originalFile.absolute.path)));
        await result.writeAsBytes(bytes);
        return FileWrapper(file.type, ZdsXFile.fromFile(result));
      }
    }

    return file;
  }
}
