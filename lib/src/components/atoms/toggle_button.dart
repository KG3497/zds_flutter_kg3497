import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

import '../../../zds_flutter.dart';

/// A large text button that can toggle between multiple values with Zds style.
class ZdsToggleButton extends StatefulWidget {
  /// The name of the option that will be displayed on the toggle.
  ///
  /// It is recommended that this does not exceed 4 as the toggle would be very small.
  final List<String> values;

  /// Called when the user clicks on toggle options.
  final ValueChanged<int> onToggleCallback;

  /// The background color for the selected value from toggle bottom.
  ///
  /// Defaults to [ColorScheme.primary].
  final Color? backgroundColor;

  /// The foreground color for the selected value from toggle button.
  ///
  /// Defaults to [ColorScheme.onPrimary].
  final Color? foregroundColor;

  /// Initial value for the toggle to be loaded with.
  final int initialValue;

  /// Margin around the outside of the button.
  ///
  /// Defaults to EdgeInsets.all(18).
  final EdgeInsets margin;

  /// Constructs a ZdsToggleButton.
  const ZdsToggleButton({
    required this.values,
    required this.onToggleCallback,
    super.key,
    this.backgroundColor,
    this.initialValue = 0,
    this.margin = const EdgeInsets.all(kBigTogglePadding),
    this.foregroundColor,
  });

  @override
  ZdsToggleButtonState createState() => ZdsToggleButtonState();
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<String>('values', values));
    properties.add(ObjectFlagProperty<ValueChanged<int>>.has('onToggleCallback', onToggleCallback));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('foregroundColor', foregroundColor));
    properties.add(IntProperty('initialValue', initialValue));
    properties.add(DiagnosticsProperty<EdgeInsets>('margin', margin));
  }
}

/// State for [ZdsToggleButton].
class ZdsToggleButtonState extends State<ZdsToggleButton> {
  int _selectedValue = 0;

  @override
  void initState() {
    _selectedValue = widget.initialValue;
    super.initState();
  }

  void _setSelectedValueFromGesture(double dx, double width) {
    int newSelected = (dx / (width / widget.values.length)).truncate().clamp(0, widget.values.length - 1);
    if (newSelected > widget.values.length - 1) {
      newSelected = widget.values.length - 1;
    }

    if (newSelected != _selectedValue) {
      widget.onToggleCallback(newSelected);
      setState(() {
        _selectedValue = newSelected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - kBigTogglePadding * 2;
        return Container(
          margin: widget.margin,
          height: kBigToggleHeight,
          child: GestureDetector(
            onTapDown: (TapDownDetails details) => _setSelectedValueFromGesture(details.localPosition.dx, width),
            onPanUpdate: (DragUpdateDetails details) => _setSelectedValueFromGesture(details.localPosition.dx, width),
            child: Stack(
              children: [
                Container(
                  height: kBigToggleHeight,
                  decoration: ShapeDecoration(
                    color: ZdsColors.greySwatch(
                      context,
                    )[Theme.of(context).colorScheme.brightness == Brightness.dark ? 1100 : 200],
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                  left: _selectedValue * (width / widget.values.length),
                  right: (widget.values.length - _selectedValue - 1) * (width / widget.values.length),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: width / widget.values.length - 1,
                    decoration: ShapeDecoration(
                      color: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
                    ),
                    alignment: Alignment.center,
                  ),
                ),
                SizedBox(
                  height: kBigToggleHeight,
                  child: Row(
                    children: List.generate(
                      widget.values.length,
                      (index) => Expanded(
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            curve: Curves.ease,
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: (index == _selectedValue)
                                  ? widget.foregroundColor ??
                                      ZetaColors.computeForeground(
                                        input: widget.backgroundColor ?? Theme.of(context).colorScheme.primary,
                                      )
                                  : Theme.of(context).colorScheme.onBackground,
                            ),
                            child: Text(widget.values[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
