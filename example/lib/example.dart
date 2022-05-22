import 'package:adt_annotation/adt_annotation.dart';

/// example.dart
part 'example.g.dart';

@data(
  #Tree,
  [Tp(#t)],
  Union(
    {
      #Node: {
        #value: T(#t, [], ['{} != null']),
        #left: T(#Tree, [T(#t)]),
        #right: T(#Tree, [T(#t)]),
      },
      #Nil: {},
    },
    deriveMode: UnionVisitDeriveMode.cata,
    topLevel: true,
  ),
  deriveEquality: false,
  deriveToString: false,
)
const Type _tree = Tree;

@data(
  #RecordEx,
  [Tp(#Message)],
  Record({
    #message: T(#Message),
    #other_message: T(#Message),
    #number: T(#int),
  }),
)
const Type _recordEx = RecordEx;

@data(
  #BoardIndex,
  [],
  Tuple([T(#int), T(#int)]),
)
const Type _boardIndex = BoardIndex;

@data(
  #$Foo$,
  [],
  Record({
    #bar: T(#int),
    #baz$: T(#int),
    #$qux$: T(#int),
    #$quox$: T(#$Foo$),
  }),
)
const Type _$foo$ = $Foo$;
