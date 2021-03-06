import 'package:adt_annotation/adt_annotation.dart';

String stringLowercasedWithoutUnderlines(String s) => s.startsWith('_')
    ? stringLowercasedWithoutUnderlines(s.substring(1))
    : s[0].toLowerCase() + s.substring(1);

String unqualifiedStringFromSymbol(Symbol s) {
  final asString = s.toString();
  return asString.split('"')[1];
}

String emptyOrSurrounded(Iterable<String> strings, [String seps = '<,>']) =>
    strings.isEmpty ? '' : '${seps[0]}${strings.join(seps[1])}${seps[2]}';

extension aaaaa on DataAnnotation {
  String typeParamsToCode() => typeParams.toCode();
  String parameterizedTypeToCode() => name.toCode() + typeParamsToCode();
  String instantiationToCode() => instantiationToType().toCode();
  TypeD instantiationToType() => TypeD(
        name,
        args: typeParams.toInstantiation().toList(),
      );
}

extension aaaa on Symbol {
  String toCode() => unqualifiedStringFromSymbol(this);
}

extension aaa on TypeD {
  String toCode() =>
      (namespace == null ? '' : '${namespace!.toCode()}.') +
      name.toCode() +
      emptyOrSurrounded(arguments.map((e) => e.toCode())) +
      (nullable ? '?' : '');
}

String bodyToFields(Map<Symbol, TypeD> body) => body.entries
    .map((e) => '''final ${e.value.toCode()} ${e.key.toCode()};''')
    .join('\n');

String initializerArgsFromSymbols(Iterable<Symbol> body) =>
    body.map((e) => 'this.${e.toCode()}').join(', ');

String initializerAssertionsFromBody(Map<Symbol, TypeD> body) {
  final r = body.entries
      .expand((e) => assertStatementsFromTypeD(e.value, e.key.toCode()))
      .map((e) => '$e,')
      .join('\n');
  return r;
}

String maybeGenerate(bool condition, String Function() generate) =>
    condition ? generate() : '';

Iterable<String> hashablePartsFrom(
        TypeD instantiatedType, Iterable<Symbol> body) =>
    [
      '(${instantiatedType.name.toCode()})',
      ...instantiatedType.arguments.map((e) => e.toCode()),
      ...body.map((e) => e.toCode()),
    ];

String hashExpressionFromTypeAndBody(
        TypeD instantiatedType, Iterable<Symbol> body) =>
    hashExpressionFromHashable(hashablePartsFrom(instantiatedType, body));
String hashExpressionFromHashable(Iterable<String> hashable) {
  if (hashable.length == 1) {
    return '${hashable.single}.hashCode';
  }
  if (hashable.length <= 20) {
    return 'Object.hash(${hashable.join(', ')})';
  }

  return 'Object.hashAll([${hashable.join(', ')}])';
}

String _specificEqualityExpressionFor(String type, Iterable<Symbol> body) {
  return '(' +
      'other is $type &&\n' +
      [
        'true',
        ...body.map((e) => 'this.${e.toCode()} == other.${e.toCode()}'),
      ].join(' &&\n') +
      ')';
}

String equalityExpressionFor(String type, Iterable<Symbol> body) {
  return 'identical(this, other) || ${_specificEqualityExpressionFor(type, body)}';
}

extension a on TypeParam {
  String toCode() => name.toCode() + ' extends ' + constraint.toCode();
}

extension aa on Iterable<TypeParam> {
  Iterable<TypeD> toInstantiation() => map((e) => TypeD(e.name));
  String toInstantiationCode() =>
      emptyOrSurrounded(toInstantiation().map((e) => e.toCode()));
  String toCode() => emptyOrSurrounded(map((e) => e.toCode()));
}

Iterable<String> assertStatementsFromTypeD(TypeD typeD, String name) =>
    typeD.assertions
        .map((e) => e.replaceAll('{}', name))
        .map((e) => 'assert($e)');

String argumentFromEntryToCode(MapEntry<Symbol, TypeD> e) =>
    '${e.value.toCode()} ${e.key.toCode()}';

String argumentFromEntryStringToCode(MapEntry<String, TypeD> e) =>
    '${e.value.toCode()} ${e.key}';

Iterable<String> namedArgumentsAndArgumentsToCode(
  Map<Symbol, TypeD> namedArguments,
  Map<Symbol, TypeD> requiredNamedArguments,
) =>
    namedArguments.entries.map(argumentFromEntryToCode).followedBy(
          requiredNamedArguments.entries
              .map(argumentFromEntryToCode)
              .map((e) => 'required $e'),
        );

String functionSignatureToCode(
  TypeD returnType,
  String name,
  Map<Symbol, TypeD> arguments, {
  Map<Symbol, TypeD> namedArguments = const {},
  Map<Symbol, TypeD> requiredNamedArguments = const {},
  Iterable<TypeParam> typeParams = const [],
}) =>
    '${returnType.toCode()} '
    '$name${typeParams.toCode()}'
    '('
    '${arguments.entries.map(argumentFromEntryToCode).join(', ')}'
    '${emptyOrSurrounded(namedArgumentsAndArgumentsToCode(namedArguments, requiredNamedArguments), '{,}')}'
    ')';

String functionTypeUnnamedToCode(
  TypeD returnType,
  Iterable<TypeD> arguments, [
  Iterable<TypeParam> typeParams = const [],
]) =>
    '${returnType.toCode()} '
    'Function'
    '${typeParams.toCode()}'
    '('
    '${arguments.map((e) => e.toCode()).join(', ')}'
    ')';

String functionTypeToCode(TypeD returnType, Map<Symbol, TypeD> arguments,
        [Iterable<TypeParam> typeParams = const []]) =>
    '${returnType.toCode()} '
    'Function'
    '${typeParams.toCode()}'
    '('
    '${arguments.entries.map(argumentFromEntryToCode).join(', ')}'
    ')';
bool _stringContains$(String s) => s.contains('\$');
String _escapedStringWith$(String s) => s.replaceAll(r'$', r'\$');
String _stringWithLeading$OrWrapped(String s) =>
    _stringContains$(s) ? '\${$s}' : '\$$s';
String _typeDToOutputString(TypeD type) =>
    '${_escapedStringWith$(type.name.toCode())}'
    '${emptyOrSurrounded(type.arguments.map((e) => _stringWithLeading$OrWrapped(e.toCode())))}';
String toStringFromTypeAndBody(String typePart, String bodyPart) =>
    '@override\n'
    'String toString() =>\n'
    ' "${bodyPart.isEmpty ? typePart : '$typePart $bodyPart'}"\n;';

String toStringFromTypeDAndBody(TypeD type, String bodyPart) =>
    toStringFromTypeAndBody(_typeDToOutputString(type), bodyPart);

String toStringBodyFrom(
  Iterable<Symbol> elements,
  String delimiterL,
  String delimiterR,
  bool outputOnEmpty,
) =>
    elements.isEmpty
        ? (outputOnEmpty ? '$delimiterL$delimiterR' : '')
        : '$delimiterL'
            '${elements.map((e) => _stringWithLeading$OrWrapped(e.toCode())).join(', ')}'
            '$delimiterR';

String mixinToCode(List<TypeD> mixins) =>
    mixins.isEmpty ? '' : 'with ${mixins.map((e) => e.toCode()).join(',')}';
