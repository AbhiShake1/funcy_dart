import 'package:funcy_dart/funcy_dart.dart';
import 'package:funcy_dart/src/utils/reflection_utils.dart';
import 'package:funcy_dart/src/utils/string_utils.dart';

class FuncySchema<T extends FuncyModel> {
  final Map<String, dynamic> _json;
  final T _model;

  const FuncySchema(this._json, this._model);

  factory FuncySchema.fromJson(T schema, Map<String, dynamic> json) {
    return FuncySchema<T>(json, fillFunctionParams(schema, json) as T);
  }

  Map<String, dynamic> toJson() => _json;

  @override
  String toString() => toJson().toString();

  @override
  bool operator ==(Object other) {
    if (other is! FuncySchema) return false;
    return toJson() == other.toJson();
  }

  dynamic call(String key) => _json[toSnakeCase(key)];

  dynamic operator [](String key) => (key);

  FuncySchema<T> copyWith(T Function(T) schema) {
    final model = schema(_model);
    return FuncySchema(model.toJson(), model);
  }

  FuncySchema<T> then(void Function(T) schema) {
    schema(_model);
    return this;
  }

  M thenReturn<M>(M Function(T) schema) {
    return schema(_model);
  }
}
