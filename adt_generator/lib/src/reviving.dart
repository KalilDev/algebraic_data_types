import 'package:adt_annotation_base/adt_annotation_base.dart';
import 'package:source_gen/source_gen.dart';

TypeChecker unionTypeChecker = TypeChecker.fromRuntime(Union);
TypeChecker tupleTypeChecker = TypeChecker.fromRuntime(Tuple);
TypeChecker recordTypeChecker = TypeChecker.fromRuntime(Record);
TypeChecker opaqueTypeChecker = TypeChecker.fromRuntime(Opaque);

TypeD typeDFromReader(ConstantReader reader) {
  final name = reader.read('name').symbolValue;
  final arguments = reader
      .read('arguments')
      .listValue
      .map(ConstantReader.new)
      .map(typeDFromReader)
      .toList();
  final assertions = reader
      .read('assertions')
      .listValue
      .map(
        (e) => e.toStringValue()!,
      )
      .toList();
  final namespace = reader.read('namespace').isNull
      ? null
      : reader.read('namespace').symbolValue;
  if (reader.read('nullable').boolValue) {
    return TypeD.n(
      name,
      args: arguments,
      asserts: assertions,
      namespace: namespace,
    );
  }
  return TypeD(
    name,
    args: arguments,
    asserts: assertions,
    namespace: namespace,
  );
}

Union unionFromReader(ConstantReader reader) {
  return Union(
    reader.read('body').mapValue.map((caseName, caseBody) => MapEntry(
          ConstantReader(caseName).symbolValue,
          caseBody!.toMapValue()!.map((memberName, memberType) => MapEntry(
                ConstantReader(memberName).symbolValue,
                typeDFromReader(ConstantReader(memberType!)),
              )),
        )),
    deriveMode: UnionVisitDeriveMode
        .values[reader.read('deriveMode').read('index').intValue],
    topLevel: reader.read('topLevel').boolValue,
  );
}

Tuple tupleFromReader(ConstantReader reader) {
  return Tuple(
    reader
        .read('body')
        .listValue
        .map(ConstantReader.new)
        .map(typeDFromReader)
        .toList(),
  );
}

Opaque opaqueFromReader(ConstantReader reader) {
  return Opaque(
    typeDFromReader(reader.read('type')),
    exposeConstructor: reader.read('exposeConstructor').boolValue,
  );
}

Record recordFromReader(ConstantReader reader) {
  return Record(
    reader.read('body').mapValue.map((name, type) => MapEntry(
          ConstantReader(name).symbolValue,
          typeDFromReader(ConstantReader(type)),
        )),
    deriveMode: RecordConstructorDeriveMode
        .values[reader.read('deriveMode').read('index').intValue],
  );
}

DataExpr dataExprFromReader(ConstantReader reader) {
  if (reader.instanceOf(unionTypeChecker)) {
    return unionFromReader(reader);
  }
  if (reader.instanceOf(tupleTypeChecker)) {
    return tupleFromReader(reader);
  }
  if (reader.instanceOf(recordTypeChecker)) {
    return recordFromReader(reader);
  }
  if (reader.instanceOf(opaqueTypeChecker)) {
    return opaqueFromReader(reader);
  }
  throw TypeError();
}

TypeParam typeParamFromReader(ConstantReader reader) {
  return TypeParam(
    reader.read('name').symbolValue,
    typeDFromReader(reader.read('constraint')),
  );
}

DataAnnotation dataAnnotationFromReader(ConstantReader reader) =>
    DataAnnotation(
      reader.read('name').symbolValue,
      reader
          .read('typeParams')
          .listValue
          .map(ConstantReader.new)
          .map(typeParamFromReader)
          .toList(),
      dataExprFromReader(reader.read('body')),
      mixin: reader
          .read('mixin')
          .listValue
          .map(ConstantReader.new)
          .map(typeDFromReader)
          .toList(),
      deriveEquality: reader.read('deriveEquality').boolValue,
      deriveRuntimeType: reader.read('deriveRuntimeType').boolValue,
      deriveToString: reader.read('deriveToString').boolValue,
    );

final typeTypeChecker = TypeChecker.fromRuntime(Type);
