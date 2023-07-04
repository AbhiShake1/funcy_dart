import 'dart:mirrors';

/// {@template FuncyModel}
/// Base model. Every model class must extend `FuncyModel`
abstract class FuncyModel {
  /// {@template FuncyModel}
  /// Converts the model object to a JSON representation.
  ///Returns a [Map] containing the field names and their corresponding values in the model object.
  Map<String, dynamic> toJson() {
    final classMirror = reflectClass(runtimeType);
    final instanceMirror = reflect(this);

    final json = <String, dynamic>{};

    classMirror.declarations.forEach((symbol, declarationMirror) {
      if (declarationMirror is VariableMirror && !declarationMirror.isStatic) {
        final field = MirrorSystem.getName(symbol);
        final value = instanceMirror.getField(symbol).reflectee;
        json[field] = value;
      }
    });

    return json;
  }

  @override
  String toString() {
    final mirror = reflect(this);
    final classMirror = mirror.type;
    final className = MirrorSystem.getName(classMirror.simpleName);

    final buffer = StringBuffer();

    classMirror.declarations.values.whereType<VariableMirror>().forEach((variable) {
      final variableName = MirrorSystem.getName(variable.simpleName);
      final variableValue = mirror.getField(variable.simpleName).reflectee;

      buffer.write('$variableName: $variableValue, ');
    });

    final result = buffer.toString().trimRight().replaceFirst(RegExp(r',\s*$'), '');

    return '$className($result)';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.isSetter) {
      final fieldName = MirrorSystem.getName(invocation.memberName);
      final setterName = 'set$fieldName';

      final setterSymbol = Symbol(setterName);
      final setterMirror = reflect(this).type.instanceMembers[setterSymbol];

      if (setterMirror != null) {
        final positionalArgs = [invocation.positionalArguments.first];
        final namedArgs = invocation.namedArguments;
        return reflect(this).invoke(setterMirror.simpleName, positionalArgs, namedArgs).reflectee;
      }
    }

    return super.noSuchMethod(invocation);
  }
}
