import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../zds_flutter.dart';

/// Enum to determine direction used in [ZdsPropertiesList].
enum ZdsPropertiesListDirection {
  /// Display the data in a horizontal row.
  horizontal,

  /// Display the data in a vertical column.
  vertical,
}

/// A list of properties with their respective values.
///
/// This component can be used instead of a table to show a lot of data at once in an easy to scan format.
///
/// ```dart
/// ZdsPropertiesList(
//   title: Text('Walk #4'),
//   properties: {
//     'Points Scored': '380',
//     'Total Points': '700',
//     'Score (%)': '42.12',
//     'Passed (%)': '25.00',
//   },
// ),
/// ```
///
/// The data can be displayed in two ways. When [direction] is horizontal, the property and its value will be shown on
/// the same line. When it's vertical, the value will be below the property, vertically.
///
/// See also:
///
///  * [ZdsFieldsListTile], another way of showing table-like data.
class ZdsPropertiesList extends StatelessWidget {
  /// The optional title to show at the top of the list.
  ///
  /// Typically a [Text].
  final Widget? title;

  /// The properties to be shown.
  ///
  /// In this map, the keys represent each property's title or short description, and the values represent the detailed
  /// information about each.
  final Map<String, String>? properties;

  /// Whether the properties keys and values are shown horizontally (each key with its value in the same row), or
  /// vertically (each value is under its key).
  ///
  /// Defaults to [ZdsPropertiesListDirection.horizontal].
  final ZdsPropertiesListDirection direction;

  /// Shows a list of properties with their respective values.
  const ZdsPropertiesList({
    super.key,
    this.title,
    this.properties,
    this.direction = ZdsPropertiesListDirection.horizontal,
  });

  bool get _horizontal => direction == ZdsPropertiesListDirection.horizontal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            title!
                .textStyle(
                  Theme.of(context).textTheme.displaySmall!.copyWith(
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                )
                .space(20),
          if (properties != null)
            ...properties!.entries
                .map(
                  (set) => _wrap(
                    context,
                    Text(set.key),
                    _horizontal ? Text(set.value, textAlign: TextAlign.end) : Text(set.value),
                  ),
                )
                .toList()
                .divide(_divider),
        ],
      ),
    );
  }

  Widget get _divider {
    return SizedBox(height: _horizontal ? 14 : 24);
  }

  Widget _wrap(BuildContext context, Widget label, Widget value) {
    if (_horizontal) {
      return MergeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            label.textStyle(Theme.of(context).textTheme.bodyLarge),
            Flexible(child: value.textStyle(Theme.of(context).textTheme.titleSmall!.copyWith(color: ZdsColors.black))),
          ],
        ),
      );
    }

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          label
              .textStyle(
                Theme.of(context).textTheme.titleSmall!.copyWith(color: ZdsColors.blueGrey),
              )
              .space(8),
          value.textStyle(
            Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onBackground),
            overflow: TextOverflow.clip,
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Map<String, String>?>('properties', properties as Map<String, String>?))
      ..add(EnumProperty<ZdsPropertiesListDirection>('direction', direction));
  }
}
