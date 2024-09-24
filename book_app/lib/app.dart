import 'package:flutter/material.dart';

GlobalKey<NavigatorState> navigator = GlobalKey<NavigatorState>();
push(Widget page) {
  navigator.currentState!.push(
    MaterialPageRoute(builder: (BuildContext context) => page),
  );
}
