typedef T = TypeD;
typedef Tp = TypeParam;

// data TypeD = {
//      name :: Symbol,
//      arguments :: List<TypeD>,
//      assertions :: List<String>,
//      namespace :: Symbol?,
//      nullable :: bool
//    }
class TypeD {
  final Symbol name;
  final List<TypeD> arguments;
  final List<String> assertions;
  final Symbol? namespace;
  final bool nullable;
  final String? equality;
  final String? hash;

  const TypeD(
    this.name, {
    List<TypeD> args = const [],
    List<String> asserts = const [],
    this.namespace,
    this.equality,
    this.hash,
  })  : nullable = false,
        arguments = args,
        assertions = asserts;

  const TypeD.n(
    this.name, {
    List<TypeD> args = const [],
    List<String> asserts = const [],
    this.namespace,
    this.equality,
    this.hash,
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

/// data DataExpr = Union Map<Symbol, TypeD> UnionVisitDeriveMode bool
///               | Tuple List<TypeD>
///               | Record Map<Symbol, TypeD> RecordConstructorDeriveMode
///               | Opaque bool
abstract class DataExpr {
  const DataExpr._();
}

/// An shorthand for [DataAnnotation]
typedef data = DataAnnotation;

/// The annotation used to derive an type according to [body] with the [name]
/// with the [typeParameters], mixing in the [mixin]s, optionally generating
/// the [Object.==] operator and [Object.hashCode] according to
/// [deriveEquality], an [Object.runtimeType] according to [deriveRuntimeType],
/// and an [Object.toString] according to [deriveToString].
class DataAnnotation {
  final Symbol name;
  final List<TypeParam> typeParams;
  final DataExpr body;
  final List<TypeD> mixin;
  final bool deriveEquality;
  final bool deriveRuntimeType;
  final bool deriveToString;
  final bool deriveCopyWith;

  const DataAnnotation(
    this.name,
    this.typeParams,
    this.body, {
    this.mixin = const [],
    this.deriveEquality = true,
    this.deriveRuntimeType = true,
    this.deriveToString = true,
    this.deriveCopyWith = true,
  });
}

/// The configuration for generating the visit function(s) for an [Union].
/// [auto]: Equivalent to [cata] for bodies that are not large and [data]
///         otherwise.
/// [cata]: An `visit` function that destructures every case of the [Union].
/// [data]: An `visit` function that has an single param containing the type of
///         each [Union] case.
/// [both]: An [cata] named `visitC` and an [data] named `visit`.
enum UnionVisitDeriveMode {
  auto,
  cata,
  data,
  both,
}

/// An [SumType] that contains every type defined by taking the
/// [DataAnnotation.typeParams] and applying them to every key in the [body].
///
/// Each key generates the corresponding class, every one of them with an
/// unnamed constructor that requires every argument from the respective value
/// in [body].
///
/// The visit function, used to destructure the union is configured by
/// [deriveMode], and optionally an top level version of it is generated,
/// according to [topLevel].
class Union extends DataExpr {
  final Map<Symbol, Map<Symbol, TypeD>> body;
  final UnionVisitDeriveMode deriveMode;
  final bool topLevel;
  final bool deriveNamed;

  const Union(
    this.body, {
    this.deriveMode = UnionVisitDeriveMode.auto,
    this.topLevel = false,
    this.deriveNamed = true,
  }) : super._();
}

/// How an [Record] will derive its constructor.
/// [positionalArguments]: An unnamed constructor that requires the arguments as
///                        positional arguments.
/// [namedArguments]: An unnamed constructor that requires the arguments as
///                   required named arguments.
/// [both]: An unnamed constructor that required the arguments as positional
///         arguments and an constructor named `named` that required the
///         arguments as required named arguments.
enum RecordConstructorDeriveMode {
  positionalArguments,
  namedArguments,
  both,
}

/// An [ProductType] that contains every [TypeD] from the [body] named from
/// e0..[body.length], implementing TupleN[body.length] and with an unnamed
/// constructor initializing every value, and one `fromTupleN` constructor.
class Tuple extends DataExpr {
  final List<TypeD> body;

  const Tuple(this.body) : super._();
}

/// An [ProductType] that contains every [TypeD] from the [body] named
/// respectively as the keys in the [body].
///
/// Optionally the constructor can be configured with [deriveMode].
class Record extends DataExpr {
  final Map<Symbol, TypeD> body;
  final RecordConstructorDeriveMode deriveMode;

  const Record(
    this.body, {
    this.deriveMode = RecordConstructorDeriveMode.both,
  }) : super._();
}

/// Wrap an type and make it opaque by not exposing and allowing only usages to
/// it with specific operations defined in the library that defined this type
/// using the member named _unwrap.
///
/// Optionally the unnamed constructor can be exposed, with [exposeConstructor]
/// in case an const constructor is *needed*.
///
/// This is the mostly equal to [Record] with the body {#_unwrap: [type]}
class Opaque extends DataExpr {
  final TypeD type;
  final bool exposeConstructor;

  const Opaque(
    this.type, {
    this.exposeConstructor = false,
  }) : super._();
}
