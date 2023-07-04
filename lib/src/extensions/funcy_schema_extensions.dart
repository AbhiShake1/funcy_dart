import 'package:funcy_dart/funcy_dart.dart';

extension KhaltiSchemaX<T extends FuncyModel> on T {
  FuncySchema<T> fromJson(Map<String, dynamic> json) {
    return FuncySchema.fromJson(this, json);
  }
}
