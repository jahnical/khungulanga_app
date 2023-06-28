import 'package:flutter/material.dart';

abstract class RefreshableWidget extends StatefulWidget {
  RefreshableWidget({Key? key}) : super(key: key);
  Function() refresh = () async {};


  @override
  RefreshableWidgetState createState();
}

abstract class RefreshableWidgetState<T extends RefreshableWidget> extends State<T> {

  @override
  void initState() {
    super.initState();
    widget.refresh = refresh;
  }

  refresh();
}
