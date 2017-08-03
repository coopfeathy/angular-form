import 'package:analyzer/dart/element/element.dart';

import 'expression_parser/ast.dart' as ast;

/// A wrapper around [ClassElement] which exposes the functionality
/// needed for the view compiler to find types for expressions.
class AnalyzedClass {
  final ClassElement _classElement;

  /// Whether this class has mock-like behavior.
  ///
  /// The heuristic used to determine mock-like behavior is if the analyzed
  /// class or one of its ancestors, other than [Object], implements
  /// [noSuchMethod].
  final bool isMockLike;

  AnalyzedClass(
    this._classElement, {
    this.isMockLike: false,
  });
}

// TODO(het): This only works for literals and simple property reads. Make this
// more robust. This should also support:
//   - chained property read (eg a.b.c)
/// Returns [true] if [expression] is immutable.
bool isImmutable(ast.AST expression, AnalyzedClass analyzedClass) {
  if (expression is ast.ASTWithSource) {
    expression = (expression as ast.ASTWithSource).ast;
  }
  if (expression is ast.LiteralPrimitive ||
      expression is ast.StaticRead ||
      expression is ast.EmptyExpr) {
    return true;
  }
  if (expression is ast.PropertyRead) {
    if (analyzedClass == null) return false;
    if (expression.receiver is ast.ImplicitReceiver) {
      var field = analyzedClass._classElement.getField(expression.name);
      if (field != null) {
        return !field.isSynthetic && (field.isFinal || field.isConst);
      }
      var method = analyzedClass._classElement.getMethod(expression.name);
      if (method != null) {
        // methods are immutable
        return true;
      }
    }
    return false;
  }
  return false;
}
