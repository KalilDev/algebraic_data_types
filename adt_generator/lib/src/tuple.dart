import 'package:build/build.dart';
import 'package:adt_annotation/adt_annotation.dart';
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
  final productTypes = tuple.body.map((e) => e.toCode());
  final tupleN = tuple.body.length > 20
      ? T(#TupleN)
      : T(Symbol("TupleN${tuple.body.length}"), tuple.body);

  return '''
class ${annotation.parameterizedTypeToCode()}
          ${mixinToCode(annotation.mixin)}
          implements ProductType, ${tupleN.toCode()} {
${bodyToFields(body)}

  const ${name.toCode()}(${initializerArgsFromSymbols(body.keys)})
      : ${initializerAssertionsFromBody(body)}
        super();

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
            body.keys,
          )};
  @override
  bool operator ==(other) =>
        ${equalityExpressionFor(annotation.instantiationToCode(), body.keys)};
  ''')}
  ${maybeGenerate(
    annotation.deriveToString,
    () => toStringFromTypeDAndBody(
      annotation.instantiationToType(),
      toStringTupleBodyFrom(body.keys),
    ),
  )}
}
''';
}

String toStringTupleBodyFrom(Iterable<Symbol> elements) =>
    toStringBodyFrom(elements, '(', ')', true);
