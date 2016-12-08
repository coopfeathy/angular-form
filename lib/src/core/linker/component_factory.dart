import 'dart:html';

import 'package:angular2/src/core/di.dart' show Injector;
import 'package:angular2/src/core/reflection/reflection.dart' show reflector;

import '../change_detection/change_detection.dart' show ChangeDetectorRef;
import 'view_container.dart';
import 'app_view.dart';
import 'app_view_utils.dart' show OnDestroyCallback;
import 'element_ref.dart' show ElementRef;
import 'view_ref.dart' show ViewRef;

/// Represents an instance of a Component created via a [ComponentFactory].
///
/// [ComponentRef] provides access to the Component Instance as well other
/// objects related to this Component Instance and allows you to destroy the
/// Component Instance via the [#destroy] method.
class ComponentRef {
  /// The component type.
  final Type componentType;

  final ViewContainer _hostElement;
  final List _metadata;

  ComponentRef(this._hostElement, this.componentType, this._metadata);

  /// Location of the Host Element of this Component Instance.
  ElementRef get location => _hostElement.elementRef;

  /// The injector on which the component instance exists.
  Injector get injector => _hostElement.injector;

  /// The instance of the Component.
  dynamic get instance => _hostElement.component;

  /// The [ViewRef] of the Host View of this Component instance.
  ViewRef get hostView => _hostElement.parentView.ref;

  /// The [ChangeDetectorRef] of the Component instance.
  ChangeDetectorRef get changeDetectorRef => _hostElement.parentView.ref;

  @Deprecated('Part of internal ComponentRefImpl to be deprecated')
  List get metadata => _metadata;

  /// Destroys the component instance and all of the data structures associated
  /// with it.
  void destroy() {
    _hostElement.parentView.detachAndDestroy();
  }

  /// Allows to register a callback that will be called when the component is
  /// destroyed.
  void onDestroy(OnDestroyCallback callback) {
    hostView.onDestroy(callback);
  }
}

class ComponentFactory {
  final String selector;
  final NgViewFactory _viewFactory;
  final Type _componentType;
  final List<dynamic /* Type | List < dynamic > */ > _metadataPairs;
  static ComponentFactory cloneWithMetadata(
      ComponentFactory original, List<dynamic> metadata) {
    return new ComponentFactory(original.selector, original._viewFactory,
        original._componentType, [original.componentType, metadata]);
  }
  // Note: can't use a Map for the metadata due to

  // https://github.com/dart-lang/sdk/issues/21553
  const ComponentFactory(this.selector, this._viewFactory, this._componentType,
      [this._metadataPairs = null]);

  Type get componentType => _componentType;

  List get metadata {
    if (_metadataPairs == null) {
      // TODO: investigate why we can't do this upstream.
      return reflector.annotations(_componentType);
    }
    int pairCount = _metadataPairs.length;
    for (var i = 0; i < pairCount; i += 2) {
      if (identical(_metadataPairs[i], _componentType)) {
        return (_metadataPairs[i + 1] as List);
      }
    }
    return const [];
  }

  /// Creates a new component.
  ComponentRef create(Injector injector,
      [List<List> projectableNodes, String selector]) {
    // Note: Host views don't need a declarationViewContainer!
    AppView hostView = _viewFactory(injector, null);
    hostView.externalProjectableNodes = projectableNodes;
    var hostElement = hostView.create(selector);
    return new ComponentRef(hostElement, this.componentType, this.metadata);
  }

  ComponentRef loadIntoNode(Injector injector,
      [List<List<dynamic>> projectableNodes, Node node]) {
    // Note: Host views don't need a declarationViewContainer!
    AppView hostView = _viewFactory(injector, null);
    hostView.externalProjectableNodes = projectableNodes;
    var hostElement = hostView.create(node);
    return new ComponentRef(hostElement, this.componentType, this.metadata);
  }
}

/// Angular Component Factory signature.
///
/// The compiler generates a viewFactory per component host using this signature
/// to lazily create a RenderComponentType and create a new instance of the
/// View class.
///
/// Example:
///     AppView<dynamic> viewFactory_MyComponent_Host0... {
///        renderType_MyComponent = viewUtils.createRenderComponentType(....);
///        return new _View_MyComponent_Host0(parentInjector, declElement);
///     }
typedef AppView NgViewFactory(
    Injector injector, ViewContainer declarationElement);
