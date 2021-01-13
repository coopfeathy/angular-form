import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../ast.dart';
import '../../hash.dart';

final _listEquals = const ListEquality<dynamic>();

/// A de-sugared form of longer pseudo expression.
class NgMicroAst {
  /// What variable assignments were made.
  final List<LetBindingAst> letBindings;

  /// What properties are bound.
  final List<PropertyAst> properties;

  @literal
  const NgMicroAst({
    @required this.letBindings,
    @required this.properties,
  });

  @override
  bool operator ==(Object o) {
    if (o is NgMicroAst) {
      return _listEquals.equals(letBindings, o.letBindings) &&
          _listEquals.equals(properties, o.properties);
    }
    return false;
  }

  @override
  int get hashCode {
    return hash2(_listEquals.hash(letBindings), _listEquals.hash(properties));
  }

  @override
  String toString() => '#$NgMicroAst <$letBindings $properties>';
}
