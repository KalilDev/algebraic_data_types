import 'package:adt_annotation_base/adt_annotation_base.dart';

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
  String toTypeLiteralCode() => nullable
      ? 'Nullable<${T(name, args: arguments, asserts: assertions, namespace: namespace).toCode()}>'
      : toCode();
}

String bodyToFields(Map<Symbol, TypeD> body) => body.entries
    .map((e) => '''final ${e.value.toCode()} ${e.key.toCode()};''')
    .join('\n');

String initializerArgsFromSymbols(
  Iterable<Symbol> body, {
  bool required = false,
}) =>
    body
        .map((e) => '${required ? "required " : ""}this.${e.toCode()}')
        .join(', ');

String initializerAssertionsFromBody(Map<Symbol, TypeD> body) {
  final r = body.entries
      .expand((e) => assertStatementsFromTypeD(e.value, e.key.toCode()))
      .map((e) => '$e,')
      .join('\n');
  return r;
}

String maybeGenerate(bool condition, String Function() generate) =>
    condition ? generate() : '';

String _hashToCode(MapEntry<Symbol, TypeD> e) {
  const defaultHash = '{}';
  final hash = e.value.hash ?? defaultHash;
  return hash.replaceAll('{}', e.key.toCode());
}

Iterable<String> hashablePartsFrom(
  TypeD instantiatedType,
  Map<Symbol, TypeD> body,
) =>
    [
      '(${instantiatedType.name.toCode()})',
      ...instantiatedType.arguments.map((e) => e.toTypeLiteralCode()),
      ...body.entries.map(_hashToCode),
    ];

String hashExpressionFromTypeAndBody(
  TypeD instantiatedType,
  Map<Symbol, TypeD> body,
) =>
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

String _equalityToCode(MapEntry<Symbol, TypeD> e) {
  const defaultEquality = '{a} == {b}';
  final equality = e.value.equality ?? defaultEquality;
  return equality
      .replaceAll('{a}', 'this.${e.key.toCode()}')
      .replaceAll('{b}', 'other.${e.key.toCode()}');
}

String _specificEqualityExpressionFor(String type, Map<Symbol, TypeD> body) {
  return '(' +
      'other is $type &&\n' +
      [
        'true',
        ...body.entries.map(_equalityToCode),
      ].join(' &&\n') +
      ')';
}

String equalityExpressionFor(String type, Map<Symbol, TypeD> body) {
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

String copyWithSignatureToCode(TypeD classType, Map<Symbol, TypeD> elements) {
  final namedArgs =
      elements.map((key, value) => MapEntry(key, T(#Maybe, args: [value])));
  return '${classType.toCode()} '
      'copyWith'
      '('
      '${emptyOrSurrounded(namedArgs.entries.map(argumentFromEntryToCode).map((e) => "$e = const Maybe.none()"), '{,}')}'
      ')';
}

String copyWithToCode(TypeD classType, Map<Symbol, TypeD> elements,
        bool positionalArguments) =>
    """
  ${copyWithSignatureToCode(classType, elements)} => ${classType.toCode()}(
    ${elements.keys.map((e) => "${positionalArguments ? "${e.toCode()}: " : ""}${e.toCode()}.valueOr(this.${e.toCode()})").join(", ")}
  );
""";

String mixinToCode(List<TypeD> mixins) =>
    mixins.isEmpty ? '' : 'with ${mixins.map((e) => e.toCode()).join(',')}';
