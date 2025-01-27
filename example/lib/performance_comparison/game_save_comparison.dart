import 'dart:ffi';

import 'package:structify/structify.dart';

void main() {
  // Create a memory scope
  final scope = StructMemory.createScope();

  try {
    // Create a point
    final point = scope.allocPoint().ref
      ..x = 10
      ..y = 20;

    // Create a vector
    final vector = SimdVector.alloc();
    vector.ref.setValues([1.0, 2.0, 3.0, 4.0]);

    print('Point: $point');
    print('Vector: ${vector.ref.values[0]}, ${vector.ref.values[1]}, ...');
  } finally {
    scope.dispose();
  }
}