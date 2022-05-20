import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:adt_annotation/adt_annotation.dart';
import 'union.dart';
import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

import 'record.dart';
import 'reviving.dart';
import 'tuple.dart';

Builder adtPartBuilder() => SharedPartBuilder(
      [
        AdtGenerator(),
      ],
      'adt',
      allowSyntaxErrors: true,
    );

class AdtGenerator extends GeneratorForAnnotation<DataAnnotation> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotationReader,
    BuildStep buildStep,
  ) async {
    final annotation = dataAnnotationFromReader(annotationReader);
    if (!element.isPrivate) {
      throw StateError('The variable annotated with data must be private');
    }
    if (element is! TopLevelVariableElement) {
      throw StateError(
          'The element annotated with data must be an top level variable');
    }
    if (!typeTypeChecker.isExactlyType(element.type)) {
      throw StateError(
          'The variable annotated with data must be of type `Type`');
    }
    if (!element.isConst) {
      throw StateError('The variable annotated with data must be const');
    }
    if (annotation.body is Union) {
      return generateForUnion(element, annotation, buildStep);
    }
    if (annotation.body is Tuple) {
      return generateForTuple(element, annotation, buildStep);
    }
    if (annotation.body is Record) {
      return generateForRecord(element, annotation, buildStep);
    }
    throw TypeError();
  }
}
