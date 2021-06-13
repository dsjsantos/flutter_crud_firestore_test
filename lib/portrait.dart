import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Forces portrait-only mode in the entire application
/// Use this Mixin on the main app widget i.e. MyApp.dart wich has to extend Stateless widget.
///
/// Call 'super.build(context)' in the main build() method to enable it
/// 
mixin PortraitModeMixin on StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _setPortraitModeOnly();
    return Container();
  }
}

/// Forces portrait-only mode on a specific screen of application
/// Use this Mixin in the specific screen to block it to portrait only mode.
///
/// Call 'super.build(context)' in the state's build() method
/// and 'super.dispose()' in the state's dispose() method
mixin PortraitStatefulModeMixin<T extends StatefulWidget> on State<T> {
  @override
  Widget build(BuildContext context) {
    _setPortraitModeOnly();
    return Container();
  }

  @override
  void dispose() {
    _enableRotation();
    super.dispose();
  }
}

/// Block rotation setting orientation only to portrait
void _setPortraitModeOnly() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

// Enable rotation setting orientation to portrait and landscape
void _enableRotation() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
}


/*
--------------------------------------------
SAMPLE - Block rotation in the entire App
--------------------------------------------

class MyApp extends StatelessWidget with PortraitModeMixin {
  const MyApp();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MaterialApp(
      title: 'MyApp Title',
      theme: ThemeData(primarySwatch: Colors.blue),
			home: Text("Block entire app screen rotation example"),
    );
  }
}

--------------------------------------------
SAMPLE - Block rotation in a specific screen
--------------------------------------------
class SampleScreen extends StatefulWidget {
  SampleScreen() : super();

  @override
  State<StatefulWidget> createState() => _SampleScreenState();
}

class _SampleScreenState extends State<SampleScreen> with PortraitStatefulModeMixin<SampleScreen> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Text("Block specific screen rotation example");
  }

  @override
  void dispose() {
     super.dispose();
  }
}

*/
