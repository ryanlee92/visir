class RegistryKey {
  const RegistryKey(this.hkey);

  final int hkey;

  RegistryKey createKey(String keyName) {
    return RegistryKey(0);
  }

  void createValue(RegistryValue value) {}
}

interface class Registry {
  static RegistryKey get currentUser {
    return RegistryKey(0);
  }
}

enum RegistryValueType { temp, string }

/// Represents an individual data value in the Windows Registry.
class RegistryValue {
  /// Creates an instance of [RegistryValue] with the specified [name], [type],
  /// and [data].
  const RegistryValue(this.name, this.type, this.data);

  /// The name of the Registry value.
  final String name;

  /// The type of the Registry value.
  final RegistryValueType type;

  /// The data associated with the Registry value.
  final Object data;

  @override
  bool operator ==(Object other) => other is RegistryValue && other.name == name && other.type == type && other.data == data;

  @override
  int get hashCode => name.hashCode * data.hashCode;

  @override
  String toString() => '$name\t$type\t$data';
}
