import 'package:analyzer/dart/element/type.dart';
import 'package:source_span/source_span.dart';
import 'package:angular/src/compiler/output/convert.dart';
import 'package:angular/src/compiler/view_compiler/parse_utils.dart'
    show handlerTypeFromExpression, HandlerType;

import '../core/security.dart';
import 'compile_metadata.dart'
    show
        CompileDirectiveMetadata,
        CompileProviderMetadata,
        CompileTokenMetadata,
        CompileTypeMetadata;
import 'expression_parser/ast.dart' show AST;
import 'i18n/message.dart';
import 'output/output_ast.dart' show OutputType;

/// An Abstract Syntax Tree node representing part of a parsed Angular template.
abstract class TemplateAst {
  /// The source span from which this node was parsed.
  SourceSpan get sourceSpan;

  /// Visit this node and possibly transform it.
  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context);
}

/// A segment of text within the template.
class TextAst implements TemplateAst {
  final String value;
  final int ngContentIndex;
  final SourceSpan sourceSpan;

  TextAst(this.value, this.ngContentIndex, this.sourceSpan);

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitText(this, context);
}

/// A bound expression within the text of a template.
class BoundTextAst implements TemplateAst {
  final AST value;
  final int ngContentIndex;
  final SourceSpan sourceSpan;

  BoundTextAst(this.value, this.ngContentIndex, this.sourceSpan);

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitBoundText(this, context);
}

/// A segment of internationalized text within a template.
class I18nTextAst implements TemplateAst {
  final I18nMessage value;
  final int ngContentIndex;
  final SourceSpan sourceSpan;

  I18nTextAst(this.value, this.ngContentIndex, this.sourceSpan);

  @override
  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitI18nText(this, context);
}

/// An abstract attribute value.
abstract class AttributeValue<T> {
  T get value;
}

/// An internationalized attribute value.
class I18nAttributeValue implements AttributeValue<I18nMessage> {
  @override
  I18nMessage value;

  I18nAttributeValue(this.value);
}

/// A literal attribute value.
class LiteralAttributeValue implements AttributeValue<String> {
  @override
  final String value;

  LiteralAttributeValue(this.value);
}

/// A plain attribute on an element.
class AttrAst implements TemplateAst {
  final String name;
  final AttributeValue value;
  final SourceSpan sourceSpan;

  AttrAst(this.name, this.value, this.sourceSpan);

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitAttr(this, context);
}

/// A binding for an element property (e.g. [property]='expression').
class BoundElementPropertyAst implements TemplateAst {
  final String namespace;
  final String name;
  final PropertyBindingType type;
  final BoundValue value;
  final String unit;
  final SourceSpan sourceSpan;
  final TemplateSecurityContext securityContext;

  BoundElementPropertyAst(this.namespace, this.name, this.type,
      this.securityContext, this.value, this.unit, this.sourceSpan);

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitElementProperty(this, context);
}

/// Public part of ProviderElementContext passed to
/// ElementAst/EmbeddedTemplateAst to drive codegen optimizations.
abstract class ElementProviderUsage {
  bool get requiresViewContainer;
  bool hasNonLocalRequest(ProviderAst providerAst);
}

/// A binding for an element event (e.g. (event)='handler()').
class BoundEventAst implements TemplateAst {
  final String name;
  final AST handler;
  final SourceSpan sourceSpan;

  BoundEventAst(this.name, this.handler, this.sourceSpan);

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitEvent(this, context);

  HandlerType get handlerType => handlerTypeFromExpression(handler);
}

/// A reference declaration on an element (e.g. #someName='expression').
class ReferenceAst implements TemplateAst {
  final String name;
  final CompileTokenMetadata value;
  final SourceSpan sourceSpan;

  ReferenceAst(this.name, this.value, this.sourceSpan);

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitReference(this, context);
}

/// A variable declaration on a <template> (e.g. let-someName='someLocalName').
class VariableAst implements TemplateAst {
  /// A variable's default [value] if unassigned or assigned an empty value.
  static const implicitValue = r'$implicit';

  final String name;
  final String value;
  final SourceSpan sourceSpan;

  /// Optional type for optimizing generated code if [value] references a local.
  ///
  /// Locals are stored in a dynamic map, thus retain no type annotation. If
  /// [dartType] is non-null, it's used to generate a type annotation for the
  /// local variable declaration.
  DartType dartType;

  OutputType get type => fromDartType(dartType, resolveBounds: false);

  VariableAst(this.name, String value, this.sourceSpan)
      : value = value != null && value.isNotEmpty ? value : implicitValue;

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitVariable(this, context);
}

/// An element declaration in a template.
class ElementAst implements TemplateAst {
  final String name;
  final List<AttrAst> attrs;
  final List<BoundElementPropertyAst> inputs;
  final List<BoundEventAst> outputs;
  final List<ReferenceAst> references;
  final List<DirectiveAst> directives;
  final List<ProviderAst> providers;
  final ElementProviderUsage elementProviderUsage;
  final List<TemplateAst> children;
  final int ngContentIndex;
  final SourceSpan sourceSpan;

  ElementAst(
      this.name,
      this.attrs,
      this.inputs,
      this.outputs,
      this.references,
      this.directives,
      this.providers,
      this.elementProviderUsage,
      this.children,
      this.ngContentIndex,
      this.sourceSpan);

  bool get hasViewContainer =>
      elementProviderUsage?.requiresViewContainer ?? false;

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitElement(this, context);
}

/// A <ng-container> element which serves as a logical container for grouping.
class NgContainerAst implements TemplateAst {
  final List<TemplateAst> children;
  final SourceSpan sourceSpan;

  NgContainerAst(this.children, this.sourceSpan);

  @override
  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitNgContainer(this, context);
}

/// A <template> element included in an Angular template.
class EmbeddedTemplateAst implements TemplateAst {
  final List<AttrAst> attrs;
  final List<BoundEventAst> outputs;
  final List<ReferenceAst> references;
  final List<VariableAst> variables;
  final List<DirectiveAst> directives;
  final List<ProviderAst> providers;
  final List<TemplateAst> children;
  final ElementProviderUsage elementProviderUsage;
  final bool hasDeferredComponent;
  final int ngContentIndex;
  final SourceSpan sourceSpan;

  EmbeddedTemplateAst(
      this.attrs,
      this.outputs,
      this.references,
      this.variables,
      this.directives,
      this.providers,
      this.elementProviderUsage,
      this.children,
      this.ngContentIndex,
      this.sourceSpan,
      {this.hasDeferredComponent = false});

  bool get hasViewContainer =>
      elementProviderUsage.requiresViewContainer ||
      // The view compiler tries to optimize when it sees a `<template>` tag
      // without `ViewContainerRef` being accessed (i.e. either via a query or
      // via injection in a directive). This behaves badly with `@deferred`,
      // which is more or less a compiler-based directive.
      //
      // See https://github.com/dart-lang/angular/issues/1539.
      hasDeferredComponent;

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitEmbeddedTemplate(this, context);
}

/// An abstract bound value.
abstract class BoundValue {}

/// A bound expression.
class BoundExpression implements BoundValue {
  final AST expression;

  BoundExpression(this.expression);
}

/// A bound internationalized message.
class BoundI18nMessage implements BoundValue {
  final I18nMessage message;

  BoundI18nMessage(this.message);
}

/// A directive property binding.
class BoundDirectivePropertyAst implements TemplateAst {
  /// The name of the property declared on the directive class.
  ///
  /// For example, "name" in
  ///
  /// ```
  /// class User {
  ///   @Input('userName')
  ///   String name;
  /// }
  /// ```
  final String directiveName;

  /// The name of the input, optionally declared by an input annotation.
  ///
  /// For example, "userName" in
  ///
  /// class User {
  ///   @Input('userName')
  ///   String name;
  /// }
  ///
  /// If no binding name is specified, this defaults to [directiveName].
  final String templateName;
  final BoundValue value;
  final SourceSpan sourceSpan;

  BoundDirectivePropertyAst(
    this.directiveName,
    this.templateName,
    this.value,
    this.sourceSpan,
  );

  @override
  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitDirectiveProperty(this, context);
}

/// A directive declared on an element.
class DirectiveAst implements TemplateAst {
  final CompileDirectiveMetadata directive;
  final List<BoundDirectivePropertyAst> inputs;
  final List<BoundElementPropertyAst> hostProperties;
  final List<BoundEventAst> hostEvents;
  final SourceSpan sourceSpan;

  DirectiveAst(this.directive, this.inputs, this.hostProperties,
      this.hostEvents, this.sourceSpan);

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitDirective(this, context);
}

/// A provider declared on an element.
class ProviderAst implements TemplateAst {
  final CompileTokenMetadata token;

  /// Whether the provider is `multi: true`.
  final bool multiProvider;

  /// The type provided by this provider.
  ///
  /// Note this may be null, in which case the expected type is generally
  /// available from a related expression or piece of metadata.
  final CompileTypeMetadata typeArgument;

  /// Whether provider should be eagerly created at build time.
  ///
  /// Otherwise the AppView will provide a getter for the provider to lazily
  /// access the provider and return it.
  final bool eager;

  /// False if provider doesn't support injection into dynamically loaded
  /// children.
  ///
  /// Typically TemplateRef, NgIf don't need to be injected into dynamic
  /// children and this flag allows injectorGetInternal to create more
  /// optimal code by skipping these.
  final bool dynamicallyReachable;

  /// Whether the provider is visible for injection.
  ///
  /// If false, no code is generated to return this provider from an injector,
  /// nor will the instance be used as a parameter to satisfy local
  /// dependencies.
  final bool visibleForInjection;

  final List<CompileProviderMetadata> providers;
  final ProviderAstType providerType;
  final SourceSpan sourceSpan;

  ProviderAst(
    this.token,
    this.multiProvider,
    this.providers,
    this.providerType,
    this.sourceSpan, {
    this.eager,
    this.dynamicallyReachable = true,
    this.typeArgument,
    this.visibleForInjection = false,
  });

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitProvider(this, context);

  /// Returns true if the provider is used by a constructor in a child
  /// CompileView or queried which requires non local access.
  ///
  /// It is a signal to view builder to create a public field inside AppView
  /// to allow other AppView(s) or change detector access to this provider.
  bool get hasNonLocalRequests => throw UnimplementedError();
}

enum ProviderAstType {
  /// Public providers (Directive.providers) that can be reached across views.
  PublicService,

  /// Provide providers (Directive.viewProviders) that are visible within
  /// template only.
  PrivateService,

  /// A provider that represents the Component type.
  Component,

  /// A provider that represents a Directive type.
  Directive,

  /// A provider for a functional directive only visible within a template.
  FunctionalDirective,

  /// Provider that is used by compiled code itself such as TemplateRef.
  Builtin
}

/// Position where content is to be projected (instance of <ng-content> in
/// a template).
class NgContentAst implements TemplateAst {
  final int index;
  final int ngContentIndex;
  final SourceSpan sourceSpan;

  NgContentAst(this.index, this.ngContentIndex, this.sourceSpan);

  R visit<R, C>(TemplateAstVisitor<R, C> visitor, C context) =>
      visitor.visitNgContent(this, context);
}

/// Enumeration of types of property bindings.
enum PropertyBindingType {
  /// A normal binding to a property (e.g. [property]='expression').
  property,

  /// A binding to an element attribute (e.g. [attr.name]='expression').
  attribute,

  /// A binding to a CSS class (e.g. [class.name]='condition').
  cssClass,

  /// A binding to a style rule (e.g. [style.rule]='expression').
  style
}

/// A visitor for [TemplateAst] trees that will process each node.
abstract class TemplateAstVisitor<R, C> {
  R visitNgContainer(NgContainerAst ast, C context);
  R visitNgContent(NgContentAst ast, C context);
  R visitEmbeddedTemplate(EmbeddedTemplateAst ast, C context);
  R visitElement(ElementAst ast, C context);
  R visitReference(ReferenceAst ast, C context);
  R visitVariable(VariableAst ast, C context);
  R visitEvent(BoundEventAst ast, C context);
  R visitElementProperty(BoundElementPropertyAst ast, C context);
  R visitAttr(AttrAst ast, C context);
  R visitBoundText(BoundTextAst ast, C context);
  R visitText(TextAst ast, C context);
  R visitDirective(DirectiveAst ast, C context);
  R visitDirectiveProperty(BoundDirectivePropertyAst ast, C context);
  R visitProvider(ProviderAst providerAst, C context);
  R visitI18nText(I18nTextAst ast, C context);
}

/// Visit every node in a list of [TemplateAst]s with the given
/// [TemplateAstVisitor].
List<R> templateVisitAll<R, C>(
    TemplateAstVisitor<R, C> visitor, List<TemplateAst> asts,
    [C context]) {
  var result = <R>[];
  for (TemplateAst ast in asts) {
    var astResult = ast.visit(visitor, context);
    if (astResult != null) {
      result.add(astResult);
    }
  }
  return result;
}
