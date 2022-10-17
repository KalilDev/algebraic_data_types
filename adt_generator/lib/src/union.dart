import 'dart:math';

import 'package:build/build.dart';
import 'package:adt_annotation_base/adt_annotation_base.dart';
import 'utils.dart';
import 'package:analyzer/dart/element/element.dart';

enum ConcreteUnionDeriveMode {
  cata,
  data,
  both,
}

extension on Union {
  static const autoCataMemberCountThreshold = 3;
  ConcreteUnionDeriveMode get concreteDeriveMode {
    switch (deriveMode) {
      case UnionVisitDeriveMode.auto:
        final maxMembers = body.values.map((e) => e.length).fold(0, max);
        if (maxMembers > autoCataMemberCountThreshold) {
          return ConcreteUnionDeriveMode.data;
        }
        return ConcreteUnionDeriveMode.cata;
      case UnionVisitDeriveMode.cata:
        return ConcreteUnionDeriveMode.cata;
      case UnionVisitDeriveMode.data:
        return ConcreteUnionDeriveMode.data;
      case UnionVisitDeriveMode.both:
        return ConcreteUnionDeriveMode.both;
    }
  }
}

String generateForUnion(
  Element element,
  DataAnnotation annotation,
  BuildStep buildStep,
) {
  final union = annotation.body as Union;
  final name = annotation.name;
  final typeParamsInstantiation = annotation.typeParams.toInstantiationCode();
  final caseTypes =
      union.body.keys.map((e) => e.toCode() + typeParamsInstantiation);
  final caseFactories = union.body.entries.map((e) =>
      '''const factory ${name.toCode()}.${stringLowercasedWithoutUnderlines(e.key.toCode())}(
          ${e.value.entries.map((e) => '${e.value.toCode()} ${e.key.toCode()}').join(',')}
    ) = ${e.key.toCode()};''');
  final deriveMode = union.concreteDeriveMode;
  final String visitName;
  switch (deriveMode) {
    case ConcreteUnionDeriveMode.cata:
      visitName = '';
      break;
    case ConcreteUnionDeriveMode.data:
    case ConcreteUnionDeriveMode.both:
      visitName = 'visit';
      break;
  }
  final String visitCName;
  switch (deriveMode) {
    case ConcreteUnionDeriveMode.cata:
      visitCName = 'visit';
      break;
    case ConcreteUnionDeriveMode.data:
      visitCName = '';
      break;
    case ConcreteUnionDeriveMode.both:
      visitCName = 'visitC';
      break;
  }
  final unionData = _UnionData(
    union,
    annotation,
    visitName,
    visitCName,
  );

  final caseClasses = unionData.caseDatas
      .map((caseData) => generateUnionCaseClass(unionData, caseData));

  return '''
${visitName != '' && union.topLevel ? topLevelVisit(unionData) : ''}

${visitCName != '' && union.topLevel ? topLevelVisitC(unionData) : ''}


${generateUnionCasesEnum(unionData)}

abstract class ${annotation.parameterizedTypeToCode()}
          ${mixinToCode(annotation.mixin)}
          ${maybeGenerate(
    annotation.deriveRuntimeType,
    () => '''implements SumType''',
  )} {
  const ${name.toCode()}._();
${caseFactories.join('\n')}
  ${maybeGenerate(
    annotation.deriveFromJson && unionData.caseDatas.isNotEmpty,
    () => """
    factory ${name.toCode()}.fromJson(Object json) {
      switch ((json as Map<String, Object?>)["\\\$type"]) {
        ${unionData.caseDatas.map((e) => '''
            case (r"${e.instantiatedType.name.toCode()}"): return ${e.instantiatedType.name.toCode()}.fromJson(json);
        ''').join('\n')}
        default: throw UnimplementedError("Invalid type");
      }
    }""",
  )}

${maybeGenerate(
    annotation.deriveRuntimeType,
    () => '''
  @override
  SumRuntimeType get runtimeType => SumRuntimeType([${caseTypes.join(', ')}]);
  ''',
  )}

  ${visitName != '' ? visitSignature(visitName, unionData.caseDatas.map((e) => e.toInstantiatedTypeAndCasename())) + ';' : ''}
  ${visitCName != '' ? visitCSignature(visitCName, unionData.caseDatas.map((e) => e.toCasebodyAndCasename())) + ';' : ''}

  ${maybeGenerate(annotation.deriveEquality, () => '''
  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) => throw UnimplementedError(
      'Each case has its own implementation of ==');
  ''')}
  ${maybeGenerate(annotation.deriveToString, () => '''
  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');
  ''')}
  ${maybeGenerate(unionData.caseDatas.isNotEmpty, () => '''
  \$${unionData.annotation.name.toCode()}Type get \$type => throw UnimplementedError(
      'Each case has its own implementation of type\\\$');
  ''')}
  ${maybeGenerate(annotation.deriveToJson, () => '''
  ${toJsonSignatureToCode()} => throw UnimplementedError(
      'Each case has its own implementation of toJson');
  ''')}
}

${caseClasses.join('\n\n')}

''';
}

class _CaseData {
  final String typeParameters;
  final String instantiatedSuperType;
  final TypeD instantiatedType;
  final String caseName;
  final Map<Symbol, TypeD> body;

  _CaseData(
    this.typeParameters,
    this.instantiatedSuperType,
    this.instantiatedType,
    this.caseName,
    this.body,
  );
}

String hashExpressionForCase(_CaseData data) =>
    hashExpressionFromTypeAndBody(data.instantiatedType, data.body);

String visitImplementation(
  String visitName,
  _UnionData union,
  _CaseData data,
) =>
    '''
@override
${visitSignature(visitName, casesFromUnionData(union))} =>
    ${data.caseName}(this);
''';

String visitCImplementation(
  String visitCName,
  _UnionData union,
  _CaseData data,
) =>
    '''
@override
${visitCSignature(visitCName, casebodiesAndNamesFromUnionData(union))} =>
    ${data.caseName}(${data.body.keys.map((e) => 'this.' + e.toCode()).join(', ')});
''';

Iterable<_InstantiatedTypeAndCasename> casesFromUnionData(_UnionData u) =>
    u.caseDatas.map((e) => e.toInstantiatedTypeAndCasename());
Iterable<_CasebodyAndCasename> casebodiesAndNamesFromUnionData(_UnionData u) =>
    u.caseDatas.map((e) => e.toCasebodyAndCasename());

extension on _CaseData {
  _InstantiatedTypeAndCasename toInstantiatedTypeAndCasename() {
    return _InstantiatedTypeAndCasename(
        this.instantiatedType.toCode(), caseName);
  }

  _CasebodyAndCasename toCasebodyAndCasename() =>
      _CasebodyAndCasename(body, this.caseName);
}

extension on _UnionData {
  Iterable<_CaseData> get caseDatas =>
      this.union.body.entries.map((e) => _CaseData(
            annotation.typeParamsToCode(),
            annotation.instantiationToCode(),
            TypeD(
              e.key,
              args: annotation.typeParams.toInstantiation().toList(),
            ),
            stringLowercasedWithoutUnderlines(e.key.toCode()),
            e.value,
          ));
}

class _UnionData {
  final Union union;
  final DataAnnotation annotation;
  final String visitName;
  final String visitCName;

  _UnionData(
    this.union,
    this.annotation,
    this.visitName,
    this.visitCName,
  );
}

String generateUnionCasesEnum(_UnionData union) {
  final name = union.annotation.name.toCode();
  if (union.caseDatas.isEmpty) {
    return '';
  }
  return '''
  enum \$${name}Type {
    ${union.caseDatas.map((e) => e.instantiatedType.name.toCode()).join(', ')}
  }
''';
}

String generateUnionCaseClass(_UnionData union, _CaseData data) {
  final name = data.instantiatedType.name.toCode();
  return '''
class $name${data.typeParameters} extends ${data.instantiatedSuperType} {
${bodyToFields(data.body)}

  const $name(${initializerArgsFromSymbols(data.body.keys)})
      : ${initializerAssertionsFromBody(data.body)}
        super._();

  ${maybeGenerate(data.body.isNotEmpty && union.union.deriveNamed, () => """const $name.named({${initializerArgsFromSymbols(data.body.keys, required: true)}})
      : ${initializerAssertionsFromBody(data.body)}
        super._();""")}
        
  ${maybeGenerate(
    union.annotation.deriveFromJson,
    () => """
    factory $name.fromJson(Object json) => ${fromJsonObjectBody(name, data.body, false)};""",
  )}

  ${maybeGenerate(union.annotation.deriveEquality, () => '''
  @override
  int get hashCode => ${hashExpressionForCase(data)};
  @override
  bool operator ==(other) =>
        ${equalityExpressionFor(data.instantiatedType.toCode(), data.body)};
  ''')}
  ${maybeGenerate(
    union.annotation.deriveToString,
    () => toStringFromTypeDAndBody(
      data.instantiatedType,
      toStringCaseBodyFrom(data.body.keys),
    ),
  )}

  ${maybeGenerate(
    union.annotation.deriveCopyWith && data.body.isNotEmpty,
    () => copyWithToCode(
      data.instantiatedType,
      data.body,
      false,
    ),
  )}

  @override
  final \$${union.annotation.name.toCode()}Type \$type =
    \$${union.annotation.name.toCode()}Type.$name;

  ${maybeGenerate(
    union.annotation.deriveToJson,
    () => toJsonObjectToCode(data.body.keys, "\$type: \$type.name"),
  )}

  ${union.visitName != '' ? visitImplementation(union.visitName, union, data) : ''}

  ${union.visitCName != '' ? visitCImplementation(union.visitCName, union, data) : ''}
}
''';
}

String toStringCaseBodyFrom(Iterable<Symbol> elements) =>
    toStringBodyFrom(elements, '{ ', ' }', false);

class _InstantiatedTypeAndCasename {
  final String instantiatedType;
  final String casename;

  _InstantiatedTypeAndCasename(this.instantiatedType, this.casename);
}

String visitSignature(
  String visitName,
  Iterable<_InstantiatedTypeAndCasename> cases,
) =>
    functionSignatureToCode(TypeD(#R), visitName, {}, typeParams: {
      TypeParam(#R),
    }, requiredNamedArguments: {
      for (final c in cases)
        Symbol(c.casename):
            // TODO: This is a hack because we dont have function types yet. yuck
            TypeD(Symbol(functionTypeUnnamedToCode(
          TypeD(#R),
          [T(Symbol(c.instantiatedType))],
        ))),
    });

class _CasebodyAndCasename {
  final Map<Symbol, TypeD> body;
  final String casename;

  _CasebodyAndCasename(this.body, this.casename);

  String bodyAsParametersToCode() => body.entries
      .map((e) => '${e.value.toCode()} ${e.key.toCode()}')
      .join(', ');
}

String visitCSignature(
  String visitCName,
  Iterable<_CasebodyAndCasename> cases,
) =>
    functionSignatureToCode(TypeD(#R), visitCName, {}, typeParams: {
      TypeParam(#R),
    }, requiredNamedArguments: {
      for (final c in cases)
        Symbol(c.casename): TypeD(Symbol(functionTypeUnnamedToCode(
          TypeD(#R),
          // TODO: This is a hack because i wrote bodyAsParametersToCode earlier
          [T(Symbol(c.bodyAsParametersToCode()))],
        ))),
    });

String topLevelVisitSignature(String specificVisitName, _UnionData data) =>
    functionSignatureToCode(
      TypeD(#R),
      specificVisitName,
      {
        #union: data.annotation.instantiationToType(),
        for (final c in data.caseDatas)
          Symbol(c.caseName):
              // TODO: This is a hack because we dont have function types yet. yuck
              TypeD(Symbol(functionTypeUnnamedToCode(
            TypeD(#R),
            [c.instantiatedType],
          ))),
      },
      typeParams: [Tp(#R), ...data.annotation.typeParams],
    );

String topLevelVisit(_UnionData data) => '''
${topLevelVisitSignature('${data.visitName}${data.annotation.name.toCode()}', data)} =>
    union.${data.visitName}(
      ${data.caseDatas.map((e) => '${e.caseName}: ${e.caseName}').join(', ')}
    );''';

String topLevelVisitCSignature(String specificVisitCName, _UnionData data) =>
    functionSignatureToCode(
      TypeD(#R),
      specificVisitCName,
      {
        #union: data.annotation.instantiationToType(),
        for (final c in data.caseDatas)
          Symbol(c.caseName):
              // TODO: This is a hack because we dont have function types yet. yuck
              TypeD(Symbol(functionTypeToCode(TypeD(#R), c.body))),
      },
      typeParams: [Tp(#R), ...data.annotation.typeParams],
    );
String topLevelVisitC(_UnionData data) => '''
${topLevelVisitCSignature('${data.visitCName}${data.annotation.name.toCode()}', data)} =>
    union.${data.visitCName}(
      ${data.caseDatas.map((e) => '${e.caseName}: ${e.caseName}').join(', ')}
    );''';
