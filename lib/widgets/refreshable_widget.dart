import 'package:flutter/material.dart';

/// An abstract class for a refreshable widget.
abstract class RefreshableWidget extends StatefulWidget {
  /// Constructs a RefreshableWidget.
  RefreshableWidget({Key? key}) : super(key: key);

  /// The refresh function that can be overridden.
  Function() refresh = () async {};

  @override
  RefreshableWidgetState createState();
}

/// The abstract state class for a refreshable widget.
abstract class RefreshableWidgetState<T extends RefreshableWidget> extends State<T> {
  @override
  void initState() {
    super.initState();
    widget.refresh = refresh;
  }

  /// Refreshes the widget.
  void refresh();
}
