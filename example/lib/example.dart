import 'package:kalil_adt_annotation/kalil_adt_annotation.dart';
import 'int.dart' as intns;

/// example.dart
part 'example.g.dart';

@data(
  #Tree,
  [Tp(#t)],
  Union(
    {
      #Node: {
        #value: T(#t, asserts: ['{} != null']),
        #left: T(#Tree, args: [T(#t)]),
        #right: T(#Tree, args: [T(#t)]),
      },
      #Nil: {},
    },
    deriveMode: UnionVisitDeriveMode.cata,
    topLevel: true,
  ),
  deriveEquality: false,
  deriveToString: false,
  deriveRuntimeType: false,
)
const Type _tree = Tree;

@data(
  #RecordEx,
  [Tp(#Message)],
  Record({
    #message: T(#Message),
    #other_message: T(#Message),
    #number: T(#Int, namespace: #intns),
  }),
)
const Type _recordEx = RecordEx;

@data(
  #NullableEx,
  [],
  Record(
    {
      #nullable: T.n(#String),
    },
  ),
)
const Type _NullableEx = NullableEx;

@data(
  #BoardIndex,
  [],
  Tuple([T(#Int, namespace: #intns), T(#Int, namespace: #intns)]),
  deriveRuntimeType: false,
)
const Type _boardIndex = BoardIndex;

@data(
  #$Foo$,
  [],
  Record({
    #bar: T(#Int, namespace: #intns),
    #baz$: T(#Int, namespace: #intns),
    #$qux$: T(#Int, namespace: #intns),
    #$quox$: T(#$Foo$),
  }),
  deriveRuntimeType: false,
)
const Type _$foo$ = $Foo$;

@data(
  #IntList,
  [],
  Opaque(
    T(#List, args: [T(#Int, namespace: #intns)]),
    exposeConstructor: true,
  ),
)
const Type _intList = IntList;

IntList emptyIntList(int length) => IntList(List.filled(0, length));
intns.Int intListAt(IntList list, int i) => list._unwrap[i];
