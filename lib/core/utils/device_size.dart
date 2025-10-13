import 'package:flutter/material.dart';


//For getting current device size
extension Context on BuildContext {
  double width() => MediaQuery.of(this).size.width;
  double height() => MediaQuery.of(this).size.height;
}
