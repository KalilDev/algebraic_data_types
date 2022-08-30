import 'package:build/build.dart';
import 'package:adt_annotation_base/adt_annotation_base.dart';
import 'utils.dart';
import 'package:analyzer/dart/element/element.dart';

String generateForOpaque(
  Element element,
  DataAnnotation annotation,
  BuildStep buildStep,
) {
  final opaque = annotation.body as Opaque;
  final name = annotation.name;
  // Opaque types are an product of only themselves.
  final productTypes = [annotation.instantiationToCode()];

  final constructorName = opaque.exposeConstructor ? '' : '._';
  final body = {#_unwrap: opaque.type};

  return '''
class ${annotation.parameterizedTypeToCode()}
          ${mixinToCode(annotation.mixin)}
          ${maybeGenerate(
    annotation.deriveRuntimeType,
    () => '''implements ProductType''',
  )} {
${bodyToFields(body)}

  const ${name.toCode()}$constructorName(${initializerArgsFromSymbols(body.keys)});

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
      body.keys,
    )};
  @override
  bool operator ==(other) =>
        ${equalityExpressionFor(annotation.instantiationToCode(), body.keys)};
  ''',
  )}
  ${maybeGenerate(
    annotation.deriveToString,
    () => toStringFromTypeDAndBody(
      annotation.instantiationToType(),
      toStringRecordBodyFrom(body.keys),
    ),
  )}
}
''';
}

String toStringRecordBodyFrom(Iterable<Symbol> elements) =>
    toStringBodyFrom(elements, '{ ', ' }', false);
