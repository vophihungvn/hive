import 'package:hive/hive.dart';
import 'package:hive/src/registry/type_registry_impl.dart';
import 'package:test/test.dart';

import '../common.dart';

class TestAdapter extends TypeAdapter<int> {
  TestAdapter([this.typeId = 0]);

  @override
  final int typeId;

  @override
  int read(BinaryReader reader) {
    return 5;
  }

  @override
  void write(BinaryWriter writer, obj) {}
}

class TestAdapter2 extends TypeAdapter<int> {
  @override
  int get typeId => 1;

  @override
  int read(BinaryReader reader) {
    return 5;
  }

  @override
  void write(BinaryWriter writer, obj) {}
}

void main() {
  group('TypeRegistryImpl', () {
    group('.registerAdapter()', () {
      test('register', () {
        var registry = TypeRegistryImpl();
        var adapter = TestAdapter();
        registry.registerAdapter(adapter, 0);

        var resolved = registry.findAdapterForValue(123);
        expect(resolved.typeId, 32);
        expect(resolved.adapter, adapter);
      });

      test('unsupported typeId', () {
        var registry = TypeRegistryImpl();
        expect(() => registry.registerAdapter(TestAdapter(-1), -1),
            throwsHiveError('not allowed'));
        expect(() => registry.registerAdapter(TestAdapter(224), 224),
            throwsHiveError('not allowed'));
      });

      test('duplicate typeId', () {
        var registry = TypeRegistryImpl();
        registry.registerAdapter(TestAdapter(), 0);
        expect(() => registry.registerAdapter(TestAdapter(), 0),
            throwsHiveError('already a TypeAdapter for typeId'));
      });
    });

    test('.findAdapterForTypeId()', () {
      var registry = TypeRegistryImpl();
      var adapter = TestAdapter();
      registry.registerAdapter(adapter, 0);

      var resolvedAdapter = registry.findAdapterForTypeId(32);
      expect(resolvedAdapter.typeId, 32);
      expect(resolvedAdapter.adapter, adapter);
    });

    group('.findAdapterForValue()', () {
      test('finds adapter', () {
        var registry = TypeRegistryImpl();
        var adapter = TestAdapter();
        registry.registerAdapter(adapter, 0);

        var resolvedAdapter = registry.findAdapterForValue(123);
        expect(resolvedAdapter.typeId, 32);
        expect(resolvedAdapter.adapter, adapter);
      });

      test('returns first matching adapter', () {
        var registry = TypeRegistryImpl();
        var adapter1 = TestAdapter();
        var adapter2 = TestAdapter();
        registry.registerAdapter(adapter1, 0);
        registry.registerAdapter(adapter2, 1);

        var resolvedAdapter = registry.findAdapterForValue(123);
        expect(resolvedAdapter.typeId, 32);
        expect(resolvedAdapter.adapter, adapter1);
      });
    });

    test('.resetAdapters()', () {
      var registry = TypeRegistryImpl();
      var adapter = TestAdapter();
      registry.registerAdapter(adapter, 0);

      registry.resetAdapters();
      expect(registry.findAdapterForValue(123), null);
    });
  });
}
