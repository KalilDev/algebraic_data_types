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

abstract class Tree<t extends Object?> {
  const Tree._();
  const factory Tree.node(t value, Tree<t> left, Tree<t> right) = Node;
  const factory Tree.nil() = Nil;

  R visit<R extends Object?>(
      {required R Function(t value, Tree<t> left, Tree<t> right) node,
      required R Function() nil});
}

class Node<t extends Object?> extends Tree<t> {
  final t value;
  final Tree<t> left;
  final Tree<t> right;

  const Node(this.value, this.left, this.right)
      : assert(value != null),
        super._();

  @override
  R visit<R extends Object?>(
          {required R Function(t value, Tree<t> left, Tree<t> right) node,
          required R Function() nil}) =>
      node(this.value, this.left, this.right);
}

class Nil<t extends Object?> extends Tree<t> {
  const Nil() : super._();

  @override
  R visit<R extends Object?>(
          {required R Function(t value, Tree<t> left, Tree<t> right) node,
          required R Function() nil}) =>
      nil();
}

class RecordEx<Message extends Object?> implements ProductType {
  final Message message;
  final Message other_message;
  final intns.Int number;

  const RecordEx(this.message, this.other_message, this.number) : super();

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
}

class BoardIndex implements TupleN2<intns.Int, intns.Int> {
  final intns.Int e0;
  final intns.Int e1;

  const BoardIndex(this.e0, this.e1) : super();

  factory BoardIndex.fromTupleN(TupleN2<intns.Int, intns.Int> tpl) =>
      BoardIndex(tpl.e0, tpl.e1);

  @override
  int get hashCode => Object.hash((BoardIndex), e0, e1);
  @override
  bool operator ==(other) =>
      identical(this, other) ||
      (other is BoardIndex &&
          true &&
          this.e0 == other.e0 &&
          this.e1 == other.e1);

  @override
  String toString() => "BoardIndex ($e0, $e1)";
}

class $Foo$ {
  final intns.Int bar;
  final intns.Int baz$;
  final intns.Int $qux$;
  final $Foo$ $quox$;

  const $Foo$(this.bar, this.baz$, this.$qux$, this.$quox$) : super();

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
}
