import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:screenshot/screenshot.dart';
import '../../../../utils/localizations.dart';
import '../../../atoms.dart';
import '../models/shape.dart';
import '../utils/editor_icon.dart';
import '../utils/shape_painter.dart';
import '../utils/utils.dart';

/// A page that allows users to draw shapes on an image.
///
/// This page provides tools for drawing various shapes on an image.
/// Users can select different shapes and colors to apply to the image.
class DrawShapePage extends StatefulWidget {
  /// Creates a [DrawShapePage] with the given image.
  ///
  /// The [image] parameter is required and represents the image to be edited.
  const DrawShapePage({super.key, required this.image});

  /// The image to be edited.
  final Image image;
  @override
  State<DrawShapePage> createState() => _DrawShapePageState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Image>('image', image));
  }
}

/// The state class for [DrawShapePage].
///
/// This class manages the state of the shape drawing page, including the
/// screenshot controller and the list of shapes.
class _DrawShapePageState extends State<DrawShapePage> {
  /// Controller for capturing screenshots.
  ScreenshotController screenshotController = ScreenshotController();

  /// List of shapes drawn on the image.
  final List<Shape> _shapes = [];

  /// The currently selected shape type.
  ShapeType _selectedShapeType = ShapeType.square;

  /// The starting point of the current shape being drawn.
  Offset? _startPoint;

  /// The ending point of the current shape being drawn.
  Offset? _endPoint;

  /// The color of the shapes being drawn.
  Color shapeColor = Colors.black;
  @override
  Widget build(BuildContext context) {
    final strings = ComponentStrings.of(context);
    return PopScope(
      canPop: false,
      child: Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(strings.get('SHAPES', 'Shapes')),
            actions: appBarActions(
              undo: () {
                if (_shapes.isNotEmpty) {
                  setState(_shapes.removeLast);
                }
              },
            ),
          ),
          body: Center(
            child: Column(
              children: [
                const Expanded(child: SizedBox.shrink()),
                GestureDetector(
                  onPanStart: (details) {
                    setState(() {
                      _startPoint = details.localPosition;
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _endPoint = details.localPosition;
                    });
                  },
                  onPanEnd: (_) {
                    if (_startPoint != null && _endPoint != null) {
                      setState(() {
                        _shapes.add(
                          Shape(
                            type: _selectedShapeType,
                            start: _startPoint!,
                            end: _endPoint!,
                            color: shapeColor,
                          ),
                        );
                        _startPoint = null;
                        _endPoint = null;
                      });
                    }
                  },
                  child: Screenshot(
                    controller: screenshotController,
                    child: Stack(
                      children: [
                        widget.image,
                        CustomPaint(painter: ShapePainter(shapes: _shapes)),
                      ],
                    ),
                  ),
                ),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(strings),
          floatingActionButton: colorPickerButton(strings),
          floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
        ),
      ),
    );
  }

  /// Builds the bottom navigation bar with shape drawing tools.
  ///
  /// This method returns a widget that contains buttons for different shape drawing tools.
  Widget _buildBottomNavigationBar(ComponentStrings strings) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: double.infinity,
        height: 120,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                EditorIcon(
                  icon: const Icon(Icons.square_outlined),
                  label: strings.get('SQUARE', 'Square'),
                  onPressed: () {
                    setState(() {
                      _selectedShapeType = ShapeType.square;
                    });
                  },
                ),
                EditorIcon(
                  icon: const Icon(Icons.circle_outlined),
                  label: strings.get('CIRCLE', 'Circle'),
                  onPressed: () {
                    setState(() {
                      _selectedShapeType = ShapeType.circle;
                    });
                  },
                ),
                EditorIcon(
                  icon: const Icon(Icons.arrow_forward),
                  label: strings.get('ARROW', 'Arrow'),
                  onPressed: () {
                    setState(() {
                      _selectedShapeType = ShapeType.arrow;
                    });
                  },
                ),
                EditorIcon(
                  icon: const Icon(Icons.horizontal_rule),
                  label: strings.get('LINE', 'Line'),
                  onPressed: () {
                    setState(() {
                      _selectedShapeType = ShapeType.line;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                const Spacer(),
                ZdsButton.text(
                  child: Text(strings.get('CANCEL', 'Cancel')),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(
                  width: 8,
                ),
                ZdsButton(
                  child: Text(strings.get('APPLY', 'Apply')),
                  onTap: () {
                    unawaited(
                      screenshotController.capture().then(
                        (value) {
                          if (value != null) {
                            final image = Image.memory(value);
                            Navigator.pop(context, image);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the color picker button.
  ///
  /// This method returns a widget that allows users to select a color for drawing shapes.
  Widget colorPickerButton(ComponentStrings strings) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: IconButton(
        onPressed: () {
          unawaited(
            showDialog<dynamic>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(strings.get('SELECT_COLOR', 'Select Color')),
                content: BlockPicker(
                  pickerColor: shapeColor,
                  onColorChanged: (value) {
                    shapeColor = value;
                    Navigator.pop(context);
                    setState(() {});
                  },
                ),
              ),
            ),
          );
        },
        icon: Stack(
          children: [
            Icon(
              Icons.circle,
              size: 48,
              color: shapeColor,
            ),
            const Icon(
              Icons.circle_outlined,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<ScreenshotController>('screenshotController', screenshotController))
      ..add(ColorProperty('shapeColor', shapeColor));
  }
}
