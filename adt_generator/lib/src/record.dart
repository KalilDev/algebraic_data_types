import 'package:build/build.dart';
import 'package:adt_annotation/adt_annotation.dart';
import 'utils.dart';
import 'package:analyzer/dart/element/element.dart';

String generateForRecord(
  Element element,
  DataAnnotation annotation,
  BuildStep buildStep,
) {
  final record = annotation.body as Record;
  final name = annotation.name;
  final productTypes = record.body.values.map((e) => e.toCode());

  return '''
class ${annotation.parameterizedTypeToCode()}
          ${mixinToCode(annotation.mixin)}
          implements ProductType {
${bodyToFields(record.body)}

  const ${name.toCode()}(${initializerArgsFromSymbols(record.body.keys)})
      : ${initializerAssertionsFromBody(record.body)}
        super();

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
      record.body.keys,
    )};
  @override
  bool operator ==(other) =>
        ${equalityExpressionFor(annotation.instantiationToCode(), record.body.keys)};
  ''',
  )}
  ${maybeGenerate(
    annotation.deriveToString,
    () => toStringFromTypeDAndBody(
      annotation.instantiationToType(),
      toStringRecordBodyFrom(record.body.keys),
    ),
  )}
}
''';
}

String toStringRecordBodyFrom(Iterable<Symbol> elements) =>
    toStringBodyFrom(elements, '{ ', ' }', false);
