import 'dart:mirrors';

import 'package:funcy_dart/src/funcy_dart.dart';
import 'package:funcy_dart/src/utils/string_utils.dart';

FuncyModel fillFunctionParams<T extends FuncyModel>(T schema, Map<String, dynamic> params) {
  return fillFunctionParamsRaw(schema, params).schema;
}

_Params fillFunctionParamsRaw<T extends FuncyModel>(T schema, Map<String, dynamic> params) {
  final instanceMirror = reflect(schema);
  final classMirror = instanceMirror.type;

  params.forEach((key, value) {
    final fieldName = Symbol(toCamelCase(key));
    if (classMirror.declarations.containsKey(fieldName)) {
      instanceMirror.setField(fieldName, value);
    }
  });

  final paramList = _getClassFields<T>();

  final filledParams = <Symbol, dynamic>{};
  for (final param in paramList) {
    final paramName = param.trim().split(' ').last;
    final defaultValue = param.contains('=') ? param.split('=')[1].trim() : null;

    final snakeCaseParams = toSnakeCase(paramName);

    if (params.containsKey(snakeCaseParams)) {
      final symbol = Symbol(snakeCaseParams);
      filledParams[symbol] = params[snakeCaseParams];
    } else if (defaultValue != null) {
      final symbol = Symbol(snakeCaseParams);
      filledParams[symbol] = defaultValue;
    }
  }

  final camelCaseParams = Map.fromEntries(
    filledParams.entries.map((entry) {
      final keyString = entry.key.toString().substring(8, entry.key.toString().length - 2);
      final camelCaseKey = Symbol(
          keyString.split('_').map((part) => part[0].toUpperCase() + part.substring(1)).join('').substring(0, 1).toLowerCase() +
              keyString.split('_').map((part) => part[0].toUpperCase() + part.substring(1)).join('').substring(1));
      return MapEntry(camelCaseKey, entry.value);
    }),
  );

  return _Params(
    camelCaseParams: camelCaseParams,
    filledParams: filledParams,
    params: params,
    schema: schema,
  );
}

List<String> _getClassFields<T extends FuncyModel>() {
  final classMirror = reflectClass(T);
  final fields = <String>[];

  classMirror.declarations.forEach((symbol, declarationMirror) {
    if (declarationMirror is VariableMirror && !declarationMirror.isStatic) {
      fields.add(Symbol(symbol.toString()).toString().substring(8));
    }
  });

  return fields;
}

class _Params<T extends FuncyModel> {
  _Params({
    required this.schema,
    required this.params,
    required this.filledParams,
    required this.camelCaseParams,
  });

  final T schema;
  final Map<String, dynamic> params;
  final Map<Symbol, dynamic> filledParams;
  final Map<Symbol, dynamic> camelCaseParams;
}
