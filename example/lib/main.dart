import 'dart:ffi';
import 'package:structify/structify.dart';
import 'package:ffi/ffi.dart';
import 'dart:math';
import 'package:benchmark_harness/benchmark_harness.dart';

// Enhanced particle classes with more complex behavior
class DartParticle {
  int x, y;
  List<int> velocities;
  List<int> metadata;

  DartParticle(this.x, this.y)
      : velocities = List.filled(10, 0),
        metadata = List.filled(10, 0);

  void update(int delta) {
    x += velocities[0] * delta;
    y += velocities[1] * delta;
    metadata[0]++;
  }

  // Added: Complex interaction calculation
  void interact(DartParticle other) {
    final dx = other.x - x;
    final dy = other.y - y;
    final distance = dx * dx + dy * dy;
    if (distance > 0 && distance < 1000) {
      velocities[0] += (dx > 0 ? 1 : -1);
      velocities[1] += (dy > 0 ? 1 : -1);
      metadata[1]++; // Count interactions
    }
  }
}

@Packed(1)
final class ParticleStruct extends Struct {
  @Int32()
  external int x;

  @Int32()
  external int y;

  @Array(10)
  external Array<Int32> velocities;

  @Array(10)
  external Array<Int32> metadata;

  static Pointer<ParticleStruct> alloc() => calloc<ParticleStruct>();
}

// 1. Scaling Benchmark - Tests different particle counts
class ScalingBenchmark {
  final List<int> particleCounts = [1000, 10000, 100000, 1000000];

  void runAll() {
    print('\nScaling Benchmark - Testing different particle counts:');
    for (final count in particleCounts) {
      final dartBench = DartScalingBenchmark(count);
      final structifyBench = StructifyScalingBenchmark(count);

      print('\nParticle Count: $count');
      print('Dart Implementation:');
      dartBench.report();
      print('Structify Implementation:');
      structifyBench.report();
    }
  }
}

class DartScalingBenchmark extends BenchmarkBase {
  final int particleCount;
  static const int iterations = 100;
  late List<DartParticle> particles;
  final random = Random(42);

  DartScalingBenchmark(this.particleCount)
      : super('Dart Particles ($particleCount)');

  @override
  void setup() {
    particles = List.generate(particleCount, (_) {
      final particle = DartParticle(
        (random.nextDouble() * 100).toInt(),
        (random.nextDouble() * 100).toInt(),
      );
      for (var i = 0; i < 10; i++) {
        particle.velocities[i] = (random.nextDouble() * 10).toInt();
        particle.metadata[i] = random.nextInt(100);
      }
      return particle;
    });
  }

  @override
  void run() {
    const delta = 1;
    for (var i = 0; i < iterations; i++) {
      for (final particle in particles) {
        particle.update(delta);
      }
    }
  }

  @override
  void teardown() {
    particles.clear();
  }
}

class StructifyScalingBenchmark extends BenchmarkBase {
  final int particleCount;
  static const int iterations = 100;
  late StructScope scope;
  late Pointer<ParticleStruct> particles;
  final random = Random(42);

  StructifyScalingBenchmark(this.particleCount)
      : super('Structify Particles ($particleCount)');

  @override
  void setup() {
    scope = StructMemory.createScope();
    particles = calloc<ParticleStruct>(particleCount);
    scope.register(particles.cast());

    for (var i = 0; i < particleCount; i++) {
      final particle = (particles + i).ref;
      particle.x = (random.nextDouble() * 100).toInt();
      particle.y = (random.nextDouble() * 100).toInt();

      for (var j = 0; j < 10; j++) {
        particle.velocities[j] = (random.nextDouble() * 10).toInt();
        particle.metadata[j] = random.nextInt(100);
      }
    }
  }

  @override
  void run() {
    const delta = 1;
    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < particleCount; j++) {
        final particle = (particles + j).ref;
        particle.x += particle.velocities[0] * delta;
        particle.y += particle.velocities[1] * delta;
        particle.metadata[0]++;
      }
    }
  }

  @override
  void teardown() {
    scope.dispose();
  }
}

// 2. Complex Interaction Benchmark - Tests particle-to-particle interactions
class InteractionBenchmark {
  static const int particleCount =
      1000; // Smaller count due to O(n²) complexity

  void run() {
    print('\nComplex Interaction Benchmark - Testing particle interactions:');
    final dartBench = DartInteractionBenchmark();
    final structifyBench = StructifyInteractionBenchmark();

    print('\nDart Implementation:');
    dartBench.report();
    print('Structify Implementation:');
    structifyBench.report();
  }
}

class DartInteractionBenchmark extends BenchmarkBase {
  static const int iterations = 10;
  late List<DartParticle> particles;
  final random = Random(42);

  DartInteractionBenchmark() : super('Dart Particles Interaction');

  @override
  void setup() {
    particles = List.generate(InteractionBenchmark.particleCount, (_) {
      final particle = DartParticle(
        (random.nextDouble() * 100).toInt(),
        (random.nextDouble() * 100).toInt(),
      );
      for (var i = 0; i < 10; i++) {
        particle.velocities[i] = (random.nextDouble() * 10).toInt();
        particle.metadata[i] = random.nextInt(100);
      }
      return particle;
    });
  }

  @override
  void run() {
    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < particles.length; j++) {
        for (var k = j + 1; k < particles.length; k++) {
          particles[j].interact(particles[k]);
          particles[k].interact(particles[j]);
        }
      }
    }
  }

  @override
  void teardown() {
    particles.clear();
  }
}

class StructifyInteractionBenchmark extends BenchmarkBase {
  static const int iterations = 10;
  late StructScope scope;
  late Pointer<ParticleStruct> particles;
  final random = Random(42);

  StructifyInteractionBenchmark() : super('Structify Particles Interaction');

  @override
  void setup() {
    scope = StructMemory.createScope();
    particles = calloc<ParticleStruct>(InteractionBenchmark.particleCount);
    scope.register(particles.cast());

    for (var i = 0; i < InteractionBenchmark.particleCount; i++) {
      final particle = (particles + i).ref;
      particle.x = (random.nextDouble() * 100).toInt();
      particle.y = (random.nextDouble() * 100).toInt();

      for (var j = 0; j < 10; j++) {
        particle.velocities[j] = (random.nextDouble() * 10).toInt();
        particle.metadata[j] = random.nextInt(100);
      }
    }
  }

  @override
  void run() {
    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < InteractionBenchmark.particleCount; j++) {
        final particle1 = (particles + j).ref;
        for (var k = j + 1; k < InteractionBenchmark.particleCount; k++) {
          final particle2 = (particles + k).ref;

          final dx = particle2.x - particle1.x;
          final dy = particle2.y - particle1.y;
          final distance = dx * dx + dy * dy;

          if (distance > 0 && distance < 1000) {
            particle1.velocities[0] += (dx > 0 ? 1 : -1);
            particle1.velocities[1] += (dy > 0 ? 1 : -1);
            particle1.metadata[1]++;

            particle2.velocities[0] += (dx > 0 ? -1 : 1);
            particle2.velocities[1] += (dy > 0 ? -1 : 1);
            particle2.metadata[1]++;
          }
        }
      }
    }
  }

  @override
  void teardown() {
    scope.dispose();
  }
}

// 3. Memory Access Pattern Benchmark - Tests different access patterns
class AccessPatternBenchmark {
  static const int particleCount = 100000;

  void run() {
    print(
        '\nMemory Access Pattern Benchmark - Testing different access patterns:');
    final dartBench = DartAccessPatternBenchmark();
    final structifyBench = StructifyAccessPatternBenchmark();

    print('\nDart Implementation:');
    dartBench.report();
    print('Structify Implementation:');
    structifyBench.report();
  }
}

class DartAccessPatternBenchmark extends BenchmarkBase {
  static const int iterations = 100;
  late List<DartParticle> particles;
  final random = Random(42);

  DartAccessPatternBenchmark() : super('Dart Access Patterns');

  @override
  void setup() {
    particles = List.generate(AccessPatternBenchmark.particleCount, (_) {
      final particle = DartParticle(
        (random.nextDouble() * 100).toInt(),
        (random.nextDouble() * 100).toInt(),
      );
      for (var i = 0; i < 10; i++) {
        particle.velocities[i] = (random.nextDouble() * 10).toInt();
        particle.metadata[i] = random.nextInt(100);
      }
      return particle;
    });
  }

  @override
  void run() {
    // Sequential access
    for (var i = 0; i < iterations; i++) {
      for (final particle in particles) {
        particle.metadata[0] += particle.velocities[0];
      }
    }

    // Random access
    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < particles.length; j++) {
        final idx = random.nextInt(particles.length);
        particles[idx].metadata[1] += particles[idx].velocities[1];
      }
    }

    // Strided access
    const stride = 16;
    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < particles.length; j += stride) {
        particles[j].metadata[2] += particles[j].velocities[2];
      }
    }
  }

  @override
  void teardown() {
    particles.clear();
  }
}

class StructifyAccessPatternBenchmark extends BenchmarkBase {
  static const int iterations = 100;
  late StructScope scope;
  late Pointer<ParticleStruct> particles;
  final random = Random(42);

  StructifyAccessPatternBenchmark() : super('Structify Access Patterns');

  @override
  void setup() {
    scope = StructMemory.createScope();
    particles = calloc<ParticleStruct>(AccessPatternBenchmark.particleCount);
    scope.register(particles.cast());

    for (var i = 0; i < AccessPatternBenchmark.particleCount; i++) {
      final particle = (particles + i).ref;
      particle.x = (random.nextDouble() * 100).toInt();
      particle.y = (random.nextDouble() * 100).toInt();

      for (var j = 0; j < 10; j++) {
        particle.velocities[j] = (random.nextDouble() * 10).toInt();
        particle.metadata[j] = random.nextInt(100);
      }
    }
  }

  @override
  void run() {
    // Sequential access
    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < AccessPatternBenchmark.particleCount; j++) {
        final particle = (particles + j).ref;
        particle.metadata[0] += particle.velocities[0];
      }
    }

    // Random access
    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < AccessPatternBenchmark.particleCount; j++) {
        final idx = random.nextInt(AccessPatternBenchmark.particleCount);
        final particle = (particles + idx).ref;
        particle.metadata[1] += particle.velocities[1];
      }
    }

    // Strided access
    const stride = 16;
    for (var i = 0; i < iterations; i++) {
      for (var j = 0; j < AccessPatternBenchmark.particleCount; j += stride) {
        final particle = (particles + j).ref;
        particle.metadata[2] += particle.velocities[2];
      }
    }
  }

  @override
  void teardown() {
    scope.dispose();
  }
}

void main() {
  print('Running comprehensive performance benchmarks...\n');

  // Run scaling benchmark
  ScalingBenchmark().runAll();

  // Run interaction benchmark
  InteractionBenchmark().run();

  // Run access pattern benchmark
  AccessPatternBenchmark().run();
}
