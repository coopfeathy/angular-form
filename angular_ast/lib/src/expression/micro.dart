// @dart=2.9

import '../ast.dart';
import 'micro/ast.dart';
import 'micro/parser.dart';

export 'micro/ast.dart' show NgMicroAst;

final _isBind = RegExp(r'\S+[:;]');

/// Returns whether [expression] is a special Angular *-star expression.
///
/// This means it won't parse correctly with the standard expression parser, and
/// [parseMicroExpression] is needed to de-sugar the expression into its
/// multiple intents.
bool isMicroExpression(String expression) =>
    expression != null &&
    (expression.startsWith('let') || expression.startsWith(_isBind));

/// Returns a de-sugared micro AST from [expression].
NgMicroAst parseMicroExpression(
  String directive,
  String expression,
  int expressionOffset, {
  String sourceUrl,
  TemplateAst origin,
}) =>
    const NgMicroParser().parse(
      directive,
      expression,
      expressionOffset,
      sourceUrl: sourceUrl,
      origin: origin,
    );
