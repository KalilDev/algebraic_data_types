import 'package:build/build.dart';
import 'package:adt_annotation_base/adt_annotation_base.dart';
import 'utils.dart';
import 'package:analyzer/dart/element/element.dart';

Iterable<MapEntry<Symbol, TypeD>> mapBodyEntriesFromTuple(Tuple tuple) sync* {
  var i = 0;
  for (final t in tuple.body) {
    final e = 'e${i++}';
    yield MapEntry(Symbol(e), t);
  }
}

String generateForTuple(
  Element element,
  DataAnnotation annotation,
  BuildStep buildStep,
) {
  final tuple = annotation.body as Tuple;
  final name = annotation.name;
  final body = Map.fromEntries(mapBodyEntriesFromTuple(tuple));
  final productTypes = tuple.body.map((e) => e.toTypeLiteralCode());
  final tupleN = tuple.body.length > 20
      ? T(#TupleN)
      : T(
          Symbol("TupleN${tuple.body.length}"),
          args: tuple.body,
        );

  return '''
class ${annotation.parameterizedTypeToCode()}
          ${mixinToCode(annotation.mixin)}
          implements ${maybeGenerate(
    annotation.deriveRuntimeType,
    () => 'ProductType, ',
  )}${tupleN.toCode()} {
${bodyToFields(body)}

  const ${name.toCode()}(${initializerArgsFromSymbols(body.keys)})
      : ${initializerAssertionsFromBody(body)}
        super();

  ${maybeGenerate(
    annotation.deriveFromJson,
    () => """
    factory ${name.toCode()}.fromJson(Object json) => ${fromJsonListBody(name, body.values.toList())};""",
  )}


${maybeGenerate(tuple.body.length <= 20, () => '''
  factory ${name.toCode()}.fromTupleN(${tupleN.toCode()} tpl) =>
       ${name.toCode()}(${Iterable.generate(tuple.body.length, (i) => 'tpl.e$i').join(', ')});
  ''')}

${maybeGenerate(
    annotation.deriveRuntimeType,
    () => '''
  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType([${productTypes.join(', ')}]);
  ''',
  )}
  
  ${maybeGenerate(annotation.deriveEquality, () => '''
  @override
  int get hashCode => ${hashExpressionFromTypeAndBody(
            annotation.instantiationToType(),
            body,
          )};
  @override
  bool operator ==(other) =>
        ${equalityExpressionFor(annotation.instantiationToCode(), body)};
  ''')}
  ${maybeGenerate(
    annotation.deriveToString,
    () => toStringFromTypeDAndBody(
      annotation.instantiationToType(),
      toStringTupleBodyFrom(body.keys),
    ),
  )}

  ${maybeGenerate(
    annotation.deriveCopyWith && body.isNotEmpty,
    () => copyWithToCode(
      annotation.instantiationToType(),
      body,
      false,
    ),
  )}

  ${maybeGenerate(
    annotation.deriveToJson,
    () => toJsonListToCode(body),
  )}

}
''';
}

String toStringTupleBodyFrom(Iterable<Symbol> elements) =>
    toStringBodyFrom(elements, '(', ')', true);
