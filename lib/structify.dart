
/// A library for working with C-style structs and unions in Dart
library structify;

export 'core/base.dart';
export 'core/union.dart';
export 'core/memory_manager.dart';
export 'core/memory_pool.dart';
export 'core/pointer_extensions.dart';
export 'core/serialization.dart';
export 'types/struct_types.dart';
export 'types/geometric_types.dart';
export 'types/string_types.dart';
export 'types/advanced_structs.dart';
export 'utils/endian.dart';

// Version info
const String structifyVersion = '0.1.0';

// Library info
const String description = '''
Structify is a Dart library for working with C-style structs and unions.
It provides support for:
- Memory-aligned data structures
- Binary serialization
- Nested structs and arrays
- Unions for multiple data interpretations
- Automatic memory management
- Safe memory access
- Memory pooling
''';