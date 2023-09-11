import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zeta_flutter/zeta_flutter.dart';

import '../../../zds_flutter.dart';

/// A toolbar, used for additional actions that do not fit in the app bar.
///
/// ```dart
/// ZdsToolbar(
///   title: Text('Title text'),
///   subtitle: Text('Subtitle text'),
///   actions: [
///     IconButton(onPressed: () {}, icon: Icon(ZdsIcons.filter),),
///   ],
/// ),
/// ```
///
/// See also:
///
///  * [ZdsAppBar], which allows to put a widget below it.
class ZdsToolbar extends StatelessWidget {
  /// The toolbar's title or main widget.
  ///
  /// Typically a [Text].
  final Widget? title;

  /// A widget shown under [title].
  ///
  /// Typically a [Text].
  final Widget? subtitle;

  /// Widgets shown at the end of the toolbar for additional actions.
  ///
  /// Typically a list of [IconButton].
  final List<Widget>? actions;

  /// A widget that will be shown below the toolbar.
  final Widget? child;

  /// The background color for this ToolBar. Defaults to [ColorScheme.primary]
  final Color? backgroundColor;

  /// A toolbar which can be used for additional actions that do not fit in the app bar.
  const ZdsToolbar({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.child,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconTheme(
      data: theme.primaryIconTheme,
      child: Material(
        color: backgroundColor ?? theme.colorScheme.primary,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 56),
                alignment: Alignment.center,
                // decoration: BoxDecoration(
                //   border: Border(top: BorderSide(width: 1, color: theme.colorScheme.onPrimary.withOpacity(0.1))),
                // ),
                child: Row(
                  crossAxisAlignment: _getCrossAxisAlignment,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Container(
                        padding: _resolvedContentPadding(context),
                        alignment: Alignment.center,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (title != null)
                                Container(
                                  constraints: const BoxConstraints(minHeight: 43),
                                  alignment: Alignment.bottomLeft,
                                  child: DefaultTextStyle(
                                    style: theme.primaryTextTheme.titleLarge!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    child: title!,
                                  ),
                                ),
                              if (subtitle != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  constraints: const BoxConstraints(minHeight: 43),
                                  alignment: Alignment.topLeft,
                                  child: DefaultTextStyle(
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: () {
                                      return theme.primaryTextTheme.titleSmall!.copyWith(
                                        color: ZetaColors.of(context).onPrimary.withOpacity(0.8),
                                      );
                                    }(),
                                    child: subtitle!,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (actions != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      ),
                  ],
                ),
              ),
              if (child != null) child!,
            ],
          ),
        ),
      ),
    );
  }

  CrossAxisAlignment get _getCrossAxisAlignment {
    if (_expandedLayout) return CrossAxisAlignment.baseline;
    return CrossAxisAlignment.center;
  }

  EdgeInsets _resolvedContentPadding(BuildContext context) {
    final contentPadding = Theme.of(context).zdsToolbarThemeData.contentPadding;

    return EdgeInsets.only(
      left: title is DateRange ? 0 : contentPadding.left,
      right: contentPadding.right,
    );
  }

  bool get _expandedLayout => subtitle != null && title != null;
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('backgroundColor', backgroundColor));
  }
}
