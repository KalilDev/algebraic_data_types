import 'package:build/build.dart';
import 'package:adt_annotation_base/adt_annotation_base.dart';
import 'utils.dart';
import 'package:analyzer/dart/element/element.dart';

String generateForRecord(
  Element element,
  DataAnnotation annotation,
  BuildStep buildStep,
) {
  final record = annotation.body as Record;
  final name = annotation.name;
  final productTypes = record.body.values.map((e) => e.toTypeLiteralCode());

  return '''
class ${annotation.parameterizedTypeToCode()}
          ${mixinToCode(annotation.mixin)}
          ${maybeGenerate(
    annotation.deriveRuntimeType,
    () => '''implements ProductType''',
  )} {
${bodyToFields(record.body)}

  ${maybeGenerate(record.body.isEmpty || record.deriveMode != RecordConstructorDeriveMode.namedArguments, () => """const ${name.toCode()}(${initializerArgsFromSymbols(record.body.keys)})
      : ${initializerAssertionsFromBody(record.body)}
        super();""")}
  
  ${maybeGenerate(record.body.isNotEmpty && record.deriveMode == RecordConstructorDeriveMode.both, () => """const ${name.toCode()}.named({${initializerArgsFromSymbols(record.body.keys, required: true)}})
      : ${initializerAssertionsFromBody(record.body)}
        super();""")}

  ${maybeGenerate(record.body.isNotEmpty && record.deriveMode == RecordConstructorDeriveMode.namedArguments, () => """const ${name.toCode()}({${initializerArgsFromSymbols(record.body.keys, required: true)}})
      : ${initializerAssertionsFromBody(record.body)}
        super();""")}

  ${maybeGenerate(
    annotation.deriveFromJson,
    () => """
    factory ${name.toCode()}.fromJson(Object json) => ${fromJsonObjectBody(name.toCode(), record.body, record.deriveMode == RecordConstructorDeriveMode.namedArguments)};""",
  )}

${maybeGenerate(
    annotation.deriveRuntimeType,
    () => '''
  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType([${productTypes.join(', ')}]);
  ''',
  )}

${maybeGenerate(
    annotation.deriveEquality,
    () => '''
  @override
  int get hashCode => ${hashExpressionFromTypeAndBody(
      annotation.instantiationToType(),
      record.body,
    )};
  @override
  bool operator ==(other) =>
        ${equalityExpressionFor(annotation.instantiationToCode(), record.body)};
  ''',
  )}
  ${maybeGenerate(
    annotation.deriveToString,
    () => toStringFromTypeDAndBody(
      annotation.instantiationToType(),
      toStringRecordBodyFrom(record.body.keys),
    ),
  )}

  ${maybeGenerate(
    annotation.deriveCopyWith && record.body.isNotEmpty,
    () => copyWithToCode(
      annotation.instantiationToType(),
      record.body,
      record.deriveMode == RecordConstructorDeriveMode.namedArguments,
    ),
  )}

  ${maybeGenerate(
    annotation.deriveToJson,
    () => toJsonObjectToCode(record.body.keys),
  )}

}
''';
}

String toStringRecordBodyFrom(Iterable<Symbol> elements) =>
    toStringBodyFrom(elements, '{ ', ' }', false);
