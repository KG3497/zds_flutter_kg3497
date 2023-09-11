import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// This widget can be used for nested flows where some parent widget has to be made available to all of
/// its descendants. For example, a provider that needs to be made available to all routes below it.
///
/// ```dart
/// SomeProvider(
///   child: ZdsNestedFlow(
///     rootPage: MaterialPage(child: SomeWidgetPage()),
///     onGenerateRoute: _generateRoute,
///   ),
/// )
/// ```
class ZdsNestedFlow extends StatefulWidget {
  /// Constructs a [ZdsNestedFlow].
  const ZdsNestedFlow({
    required this.rootPage,
    super.key,
    this.onGenerateRoute,
    this.shouldClose = true,
  });

  /// Root page for the navigator.
  final Page<dynamic> rootPage;

  /// Should page be closed when just root page remains on the stack, useful when added as root widget in TabBar.
  ///
  /// Defaults to true.
  final bool shouldClose;

  /// Route factory for page based navigator 1.0.
  final RouteFactory? onGenerateRoute;

  @override
  ZdsNestedFlowState createState() => ZdsNestedFlowState();

  /// Return the [ZdsNestedFlowState] of the current [ZdsNestedFlow]
  static ZdsNestedFlowState of(BuildContext context) {
    final stateOfType = context.findAncestorStateOfType<ZdsNestedFlowState>();
    if (stateOfType == null) throw FlutterError('Ancestor state of type ZdsNestedFlowState not found');
    return stateOfType;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<Page<dynamic>>('rootPage', rootPage))
      ..add(DiagnosticsProperty<bool>('shouldClose', shouldClose))
      ..add(ObjectFlagProperty<RouteFactory?>.has('onGenerateRoute', onGenerateRoute));
  }
}

/// State for [ZdsNestedFlowState].
class ZdsNestedFlowState extends State<ZdsNestedFlow> {
  late final _navigator = GlobalKey<NavigatorState>();

  /// Dismisses the nested navigation flow
  void pop<T extends Object?>([T? result]) {
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_navigator.currentState?.canPop() ?? false) {
          await _navigator.currentState?.maybePop();
          return false;
        }
        return widget.shouldClose;
      },
      child: Navigator(
        key: _navigator,
        pages: [widget.rootPage],
        onGenerateRoute: widget.onGenerateRoute,
        onPopPage: (route, result) {
          if (!(_navigator.currentState?.canPop() ?? false)) {
            if (widget.shouldClose) Navigator.of(context).pop(result);
            return false;
          }
          return route.didPop(result);
        }, /**/
      ),
    );
  }
}
