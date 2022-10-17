// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// AdtGenerator
// **************************************************************************

R visitTree<R extends Object?, t extends Object?>(
        Tree<t> union,
        R Function(t value, Tree<t> left, Tree<t> right) node,
        R Function() nil) =>
    union.visit(node: node, nil: nil);

enum $TreeType { Node, Nil }

abstract class Tree<t extends Object?> {
  const Tree._();
  const factory Tree.node(t value, Tree<t> left, Tree<t> right) = Node;
  const factory Tree.nil() = Nil;

  R visit<R extends Object?>(
      {required R Function(t value, Tree<t> left, Tree<t> right) node,
      required R Function() nil});

  $TreeType get $type => throw UnimplementedError(
      'Each case has its own implementation of type\$');

  Object toJson() => throw UnimplementedError(
      'Each case has its own implementation of toJson');
}

class Node<t extends Object?> extends Tree<t> {
  final t value;
  final Tree<t> left;
  final Tree<t> right;

  const Node(this.value, this.left, this.right)
      : assert(value != null),
        super._();

  const Node.named(
      {required this.value, required this.left, required this.right})
      : assert(value != null),
        super._();

  Node<t> copyWith(
          {Maybe<t> value = const Maybe.none(),
          Maybe<Tree<t>> left = const Maybe.none(),
          Maybe<Tree<t>> right = const Maybe.none()}) =>
      Node<t>(value.valueOr(this.value), left.valueOr(this.left),
          right.valueOr(this.right));

  @override
  final $TreeType $type = $TreeType.Node;

  Object toJson() =>
      {$type: $type.name, value: value, left: left, right: right};

  @override
  R visit<R extends Object?>(
          {required R Function(t value, Tree<t> left, Tree<t> right) node,
          required R Function() nil}) =>
      node(this.value, this.left, this.right);
}

class Nil<t extends Object?> extends Tree<t> {
  const Nil() : super._();

  @override
  final $TreeType $type = $TreeType.Nil;

  Object toJson() => {
        $type: $type.name,
      };

  @override
  R visit<R extends Object?>(
          {required R Function(t value, Tree<t> left, Tree<t> right) node,
          required R Function() nil}) =>
      nil();
}

enum $IntTreeType { IntNode, IntNil }

abstract class IntTree implements SumType {
  const IntTree._();
  const factory IntTree.intNode(intns.Int value, IntTree left, IntTree right) =
      IntNode;
  const factory IntTree.intNil() = IntNil;
  factory IntTree.fromJson(Object json) {
    switch ((json as Map<String, Object?>)["\$type"]) {
      case (r"IntNode"):
        return IntNode.fromJson(json);

      case (r"IntNil"):
        return IntNil.fromJson(json);

      default:
        throw UnimplementedError("Invalid type");
    }
  }

  @override
  SumRuntimeType get runtimeType => SumRuntimeType([IntNode, IntNil]);

  R visit<R extends Object?>(
      {required R Function(intns.Int value, IntTree left, IntTree right)
          intNode,
      required R Function() intNil});

  @override
  int get hashCode => throw UnimplementedError(
      'Each case has its own implementation of hashCode');
  bool operator ==(other) =>
      throw UnimplementedError('Each case has its own implementation of ==');

  String toString() => throw UnimplementedError(
      'Each case has its own implementation of toString');

  $IntTreeType get $type => throw UnimplementedError(
      'Each case has its own implementation of type\$');

  Object toJson() => throw UnimplementedError(
      'Each case has its own implementation of toJson');
}

class IntNode extends IntTree {
  final intns.Int value;
  final IntTree left;
  final IntTree right;

  const IntNode(this.value, this.left, this.right)
      : assert(value != null),
        super._();

  const IntNode.named(
      {required this.value, required this.left, required this.right})
      : assert(value != null),
        super._();

  factory IntNode.fromJson(Object json) => IntNode(
      (json as Map<String, Object?>)[r"value"] as intns.Int,
      (json as Map<String, Object?>)[r"left"] as IntTree,
      (json as Map<String, Object?>)[r"right"] as IntTree);

  @override
  int get hashCode => Object.hash((IntNode), value, left, right);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is IntNode &&
          true &&
          this.value == other.value &&
          this.left == other.left &&
          this.right == other.right);

  @override
  String toString() => "IntNode { $value, $left, $right }";

  IntNode copyWith(
          {Maybe<intns.Int> value = const Maybe.none(),
          Maybe<IntTree> left = const Maybe.none(),
          Maybe<IntTree> right = const Maybe.none()}) =>
      IntNode(value.valueOr(this.value), left.valueOr(this.left),
          right.valueOr(this.right));

  @override
  final $IntTreeType $type = $IntTreeType.IntNode;

  Object toJson() =>
      {$type: $type.name, value: value, left: left, right: right};

  @override
  R visit<R extends Object?>(
          {required R Function(intns.Int value, IntTree left, IntTree right)
              intNode,
          required R Function() intNil}) =>
      intNode(this.value, this.left, this.right);
}

class IntNil extends IntTree {
  const IntNil() : super._();

  factory IntNil.fromJson(Object json) => IntNil();

  @override
  int get hashCode => (IntNil).hashCode;
  @override
  bool operator ==(other) =>
      identical(this, other) || (other is IntNil && true);

  @override
  String toString() => "IntNil";

  @override
  final $IntTreeType $type = $IntTreeType.IntNil;

  Object toJson() => {
        $type: $type.name,
      };

  @override
  R visit<R extends Object?>(
          {required R Function(intns.Int value, IntTree left, IntTree right)
              intNode,
          required R Function() intNil}) =>
      intNil();
}

class RecordEx<Message extends Object?> implements ProductType {
  final Message message;
  final Message other_message;
  final intns.Int number;

  const RecordEx(this.message, this.other_message, this.number) : super();

  const RecordEx.named(
      {required this.message,
      required this.other_message,
      required this.number})
      : super();

  @override
  ProductRuntimeType get runtimeType =>
      ProductRuntimeType([Message, Message, intns.Int]);

  @override
  int get hashCode =>
      Object.hash((RecordEx), Message, message, other_message, number);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is RecordEx<Message> &&
          true &&
          this.message == other.message &&
          this.other_message == other.other_message &&
          this.number == other.number);

  @override
  String toString() =>
      "RecordEx<$Message> { $message, $other_message, $number }";

  RecordEx<Message> copyWith(
          {Maybe<Message> message = const Maybe.none(),
          Maybe<Message> other_message = const Maybe.none(),
          Maybe<intns.Int> number = const Maybe.none()}) =>
      RecordEx<Message>(
          message.valueOr(this.message),
          other_message.valueOr(this.other_message),
          number.valueOr(this.number));

  Object toJson() =>
      {message: message, other_message: other_message, number: number};
}

class NullableEx implements ProductType {
  final String? nullable;

  const NullableEx(this.nullable) : super();

  const NullableEx.named({required this.nullable}) : super();

  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType([Nullable<String>]);

  @override
  int get hashCode => Object.hash((NullableEx), nullable);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is NullableEx && true && this.nullable == other.nullable);

  @override
  String toString() => "NullableEx { $nullable }";

  NullableEx copyWith({Maybe<String?> nullable = const Maybe.none()}) =>
      NullableEx(nullable.valueOr(this.nullable));

  Object toJson() => {nullable: nullable};
}

class BoardIndex implements TupleN2<intns.Int, intns.Int> {
  final intns.Int e0;
  final intns.Int e1;

  const BoardIndex(this.e0, this.e1) : super();

  factory BoardIndex.fromJson(Object json) => BoardIndex(
      (json as List<Object?>)[0] as intns.Int,
      identityFromJson<intns.Int>((json as List<Object?>)[1]));

  factory BoardIndex.fromTupleN(TupleN2<intns.Int, intns.Int> tpl) =>
      BoardIndex(tpl.e0, tpl.e1);

  @override
  int get hashCode => Object.hash((BoardIndex), e0, defaultHash(e1));
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is BoardIndex &&
          true &&
          this.e0 == other.e0 &&
          defaultEquality(this.e1, other.e1));

  @override
  String toString() => "BoardIndex ($e0, $e1)";

  BoardIndex copyWith(
          {Maybe<intns.Int> e0 = const Maybe.none(),
          Maybe<intns.Int> e1 = const Maybe.none()}) =>
      BoardIndex(e0.valueOr(this.e0), e1.valueOr(this.e1));

  Object toJson() => [e0, identityToJson<intns.Int>(e1)];
}

class $Foo$ {
  final intns.Int bar;
  final intns.Int baz$;
  final intns.Int $qux$;
  final $Foo$ $quox$;

  const $Foo$(this.bar, this.baz$, this.$qux$, this.$quox$) : super();

  const $Foo$.named(
      {required this.bar,
      required this.baz$,
      required this.$qux$,
      required this.$quox$})
      : super();

  factory $Foo$.fromJson(Object json) => $Foo$(
      identityFromJson<intns.Int>((json as Map<String, Object?>)[r"bar"]),
      (json as Map<String, Object?>)[r"baz$"] as intns.Int,
      (json as Map<String, Object?>)[r"$qux$"] as intns.Int,
      (json as Map<String, Object?>)[r"$quox$"] as $Foo$);

  @override
  int get hashCode => Object.hash(($Foo$), bar, baz$, $qux$, $quox$);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is $Foo$ &&
          true &&
          this.bar == other.bar &&
          this.baz$ == other.baz$ &&
          this.$qux$ == other.$qux$ &&
          this.$quox$ == other.$quox$);

  @override
  String toString() => "\$Foo\$ { $bar, ${baz$}, ${$qux$}, ${$quox$} }";

  $Foo$ copyWith(
          {Maybe<intns.Int> bar = const Maybe.none(),
          Maybe<intns.Int> baz$ = const Maybe.none(),
          Maybe<intns.Int> $qux$ = const Maybe.none(),
          Maybe<$Foo$> $quox$ = const Maybe.none()}) =>
      $Foo$(bar.valueOr(this.bar), baz$.valueOr(this.baz$),
          $qux$.valueOr(this.$qux$), $quox$.valueOr(this.$quox$));

  Object toJson() => {
        bar: identityToJson<intns.Int>(bar),
        baz$: baz$,
        $qux$: $qux$,
        $quox$: $quox$
      };
}

class IntList implements ProductType {
  final List<intns.Int> _unwrap;

  const IntList(this._unwrap);

  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType([IntList]);

  @override
  int get hashCode => Object.hash((IntList), _unwrap);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is IntList && true && this._unwrap == other._unwrap);

  @override
  String toString() => "IntList { $_unwrap }";

  Object toJson() => {_unwrap: _unwrap};
}
