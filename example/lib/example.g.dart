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

abstract class Tree<t extends Object?> implements SumType {
  const Tree._();
  const factory Tree.node(t value, Tree<t> left, Tree<t> right) = Node;
  const factory Tree.nil() = Nil;

  @override
  SumRuntimeType get runtimeType => SumRuntimeType([Node<t>, Nil<t>]);

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
  final int number;

  const RecordEx(this.message, this.other_message, this.number) : super();

  @override
  ProductRuntimeType get runtimeType =>
      ProductRuntimeType([Message, Message, int]);

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

class BoardIndex implements ProductType, TupleN2<int, int> {
  final int e0;
  final int e1;

  const BoardIndex(this.e0, this.e1) : super();

  @override
  ProductRuntimeType get runtimeType => ProductRuntimeType([int, int]);

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
