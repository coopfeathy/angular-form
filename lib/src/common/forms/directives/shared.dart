import 'package:angular2/angular2.dart';
import 'package:angular2/src/facade/exceptions.dart' show BaseException;
import 'package:angular2/src/facade/lang.dart' show looseIdentical;

import '../model.dart' show Control, ControlGroup;
import '../validators.dart' show Validators;
import 'abstract_control_directive.dart' show AbstractControlDirective;
import 'checkbox_value_accessor.dart' show CheckboxControlValueAccessor;
import 'control_container.dart' show ControlContainer;
import 'control_value_accessor.dart' show ControlValueAccessor;
import 'default_value_accessor.dart' show DefaultValueAccessor;
import 'ng_control.dart' show NgControl;
import 'ng_control_group.dart' show NgControlGroup;
import 'normalize_validator.dart'
    show normalizeValidator, normalizeAsyncValidator;
import 'number_value_accessor.dart' show NumberValueAccessor;
import 'radio_control_value_accessor.dart' show RadioControlValueAccessor;
import 'select_control_value_accessor.dart' show SelectControlValueAccessor;
import 'validators.dart' show ValidatorFn, AsyncValidatorFn;

List<String> controlPath(String name, ControlContainer parent) =>
    parent.path.toList()..add(name);

void setUpControl(Control control, NgControl dir) {
  if (control == null) _throwError(dir, 'Cannot find control');
  assert(
      dir.valueAccessor != null,
      'No value accessor for '
      '(${dir.path.join(' -> ')}) or you may be missing FORM_DIRECTIVES in '
      'your directives list.');
  control.validator = Validators.compose([control.validator, dir.validator]);
  control.asyncValidator =
      Validators.composeAsync([control.asyncValidator, dir.asyncValidator]);
  dir.valueAccessor.writeValue(control.value);
  // view -> model
  dir.valueAccessor.registerOnChange((dynamic newValue, {String rawValue}) {
    dir.viewToModelUpdate(newValue);
    control.updateValue(newValue,
        emitModelToViewChange: false, rawValue: rawValue);
    control.markAsDirty(emitEvent: false);
  });
  // model -> view
  control.registerOnChange(
      (dynamic newValue) => dir.valueAccessor?.writeValue(newValue));
  // touched
  dir.valueAccessor.registerOnTouched(() => control.markAsTouched());
}

void setUpControlGroup(ControlGroup control, NgControlGroup dir) {
  if (control == null) _throwError(dir, 'Cannot find control');
  control.validator = Validators.compose([control.validator, dir.validator]);
  control.asyncValidator =
      Validators.composeAsync([control.asyncValidator, dir.asyncValidator]);
}

void _throwError(AbstractControlDirective dir, String message) {
  if (dir.path != null) {
    message = "$message (${dir.path.join(" -> ")})";
  }
  throw new BaseException(message);
}

ValidatorFn composeValidators(List<dynamic> validators) {
  return validators != null
      ? Validators
          .compose(validators.map<ValidatorFn>(normalizeValidator).toList())
      : null;
}

AsyncValidatorFn composeAsyncValidators<T extends AbstractControl>(
  List validatorsOrFunctions,
) {
  if (validatorsOrFunctions == null) {
    return null;
  }
  // ignore: strong_mode_down_cast_composite
  return Validators.composeAsync(
      validatorsOrFunctions.map(normalizeAsyncValidator).toList());
}

bool isPropertyUpdated(Map<String, dynamic> changes, dynamic viewModel) {
  if (!changes.containsKey('model')) return false;
  var change = changes['model'];
  return !looseIdentical(viewModel, change.currentValue);
}

// TODO: vsavkin remove it once https://github.com/angular/angular/issues/3011 is implemented
ControlValueAccessor selectValueAccessor(
    NgControl dir, List<ControlValueAccessor> valueAccessors) {
  if (valueAccessors == null) return null;
  ControlValueAccessor defaultAccessor;
  ControlValueAccessor builtinAccessor;
  ControlValueAccessor customAccessor;
  for (var v in valueAccessors) {
    if (v is DefaultValueAccessor) {
      defaultAccessor = v;
    } else if (v.runtimeType == CheckboxControlValueAccessor ||
        v is NumberValueAccessor ||
        v is SelectControlValueAccessor ||
        v is RadioControlValueAccessor) {
      if (builtinAccessor != null)
        _throwError(dir, 'More than one built-in value accessor matches');
      builtinAccessor = v;
    } else {
      if (customAccessor != null)
        _throwError(dir, 'More than one custom value accessor matches');
      customAccessor = v;
    }
  }
  if (customAccessor != null) return customAccessor;
  if (builtinAccessor != null) return builtinAccessor;
  if (defaultAccessor != null) return defaultAccessor;
  _throwError(dir, 'No valid value accessor for');
  return null;
}
