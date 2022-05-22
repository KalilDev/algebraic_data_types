import 'package:utils/utils.dart';
export 'package:utils/utils.dart'
    show
        SumType,
        ProductType,
        SumRuntimeType,
        ProductRuntimeType,
        TupleN0,
        TupleN1,
        TupleN2,
        TupleN3,
        TupleN4,
        TupleN5,
        TupleN6,
        TupleN7,
        TupleN8,
        TupleN9,
        TupleN10,
        TupleN11,
        TupleN12,
        TupleN13,
        TupleN14,
        TupleN15,
        TupleN16,
        TupleN17,
        TupleN18,
        TupleN19,
        TupleN20;

typedef T = TypeD;
typedef Tp = TypeParam;

// data TypeD = {name :: Symbol, arguments :: List<TypeD>, nullable :: bool}
class TypeD {
  final Symbol name;
  final List<TypeD> arguments;
  final List<String> assertions;
  final Symbol? namespace;
  final bool nullable;

  const TypeD(
    this.name, {
    List<TypeD> args = const [],
    List<String> asserts = const [],
    this.namespace,
  })  : nullable = false,
        arguments = args,
        assertions = asserts;

  const TypeD.n(
    this.name, {
    List<TypeD> args = const [],
    List<String> asserts = const [],
    this.namespace,
  })  : nullable = true,
        arguments = args,
        assertions = asserts;
  static const object = TypeD(#Object);
  static const objectN = TypeD.n(#Object);
}

/// data TypeParam = {name :: Symbol, constraint :: TypeD}
class TypeParam {
  final Symbol name;
  final TypeD constraint;
  const TypeParam(this.name, [this.constraint = TypeD.objectN]);
}

enum UnionVisitDeriveMode {
  auto,
  cata,
  data,
  both,
}

/// data DataExpr = Union Map<Symbol, TypeD> UnionVisitDeriveMode
///               | Tuple List<TypeD> bool
///               | Record Map<Symbol, TypeD>
abstract class DataExpr {
  const DataExpr();
}

class Union extends DataExpr {
  final Map<Symbol, Map<Symbol, TypeD>> body;
  final UnionVisitDeriveMode deriveMode;
  final bool topLevel;

  const Union(
    this.body, {
    this.deriveMode = UnionVisitDeriveMode.auto,
    this.topLevel = false,
  });
}

class Tuple extends DataExpr {
  final List<TypeD> body;
  final bool deriveVisit;

  const Tuple(this.body, {this.deriveVisit = true});
}

class Record extends DataExpr {
  final Map<Symbol, TypeD> body;

  const Record(this.body);
}

typedef data = DataAnnotation;

class DataAnnotation {
  final Symbol name;
  final List<TypeParam> typeParams;
  final DataExpr body;
  final List<TypeD> mixin;
  final bool deriveEquality;
  final bool deriveRuntimeType;
  final bool deriveToString;

  const DataAnnotation(
    this.name,
    this.typeParams,
    this.body, {
    this.mixin = const [],
    this.deriveEquality = true,
    this.deriveRuntimeType = true,
    this.deriveToString = true,
  });
}
