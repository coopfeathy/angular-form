// =============================================================================
// =============================================================================
// ============= S T O P   -    S T O P   -  S T O P   -  S T O P  =============
// =============================================================================
// =============================================================================
//
// DO NOT EDIT THIS LIST OF PUBLIC APIS UNLESS YOU GET IT CLEARED BY:
// ferhat or matanl!
//
// =============================================================================
// =============================================================================

const publicLibraries = const <String, List<String>>{
  'angular.dart': angularApis,
  'core.dart': NG_CORE,
  'di.dart': diApis,
  'experimental.dart': null,
  'router/testing.dart': null,
  'security.dart': null,
  'source_gen.dart': null,
  'testing.dart': null,
  'transform/codegen.dart': null,
  'transform/deferred_rewriter.dart': null,
  'transform/reflection_remover.dart': null,
  'transformer.dart': null,
};
const NG_CORE = const [
  'APP_INITIALIZER',
  'APP_ID',
  'Attribute',
  'Provider',
  'ProviderUseClass',
  'ProviderUseMulti',
  'ChangeDetectionStrategy',
  'ChangeDetectorRef',
  'Component',
  'ComponentState',
  'ComponentStateCallback',
  'ContentChild',
  'ContentChildren',
  'Directive',
  'Output',
  'EventEmitter',
  'ExceptionHandler',
  'Host',
  'HostBinding',
  'HostListener',
  'Inject',
  'Injectable',
  'Injector',
  'ReflectiveInjector',
  'Module',
  'NgZone',
  'NgZoneError',
  'OpaqueToken',
  'Optional',
  'Pipe',
  'Input',
  'RenderComponentType',
  'Self',
  'SkipSelf',
  'SimpleChange',
  'UrlResolver',
  'ViewChild',
  'ViewChildren',
  'ViewEncapsulation',
  'Visibility',
  'WrappedException',
  'provide',
  'PLATFORM_INITIALIZER',
  'AfterContentChecked',
  'AfterContentInit',
  'AfterViewChecked',
  'AfterViewInit',
  'DoCheck',
  'OnChanges',
  'OnDestroy',
  'OnInit',
  'PipeTransform',
  'TrackByFn',
  'noValueProvided',
];
const angularApis = const [
  'APP_ID',
  'APP_INITIALIZER',
  'AfterContentChecked',
  'AfterContentInit',
  'AfterViewChecked',
  'AfterViewInit',
  'AngularEntrypoint',
  'ApplicationRef',
  'AsyncPipe',
  'Attribute',
  'bootstrap',
  'bootstrapStatic',
  'browserStaticPlatform',
  'COMMON_DIRECTIVES',
  'COMMON_PIPES',
  'CORE_DIRECTIVES',
  'ChangeDetectionStrategy',
  'ChangeDetectorRef',
  'Component',
  'ComponentFactory',
  'ComponentLoader',
  'ComponentRef',
  'ComponentResolver',
  'ComponentState',
  'ComponentStateCallback',
  'ContentChild',
  'ContentChildren',
  'createDocument',
  'CurrencyPipe',
  'DatePipe',
  'DecimalPipe',
  'Directive',
  'disableDebugTools',
  'DoCheck',
  'ElementRef',
  'EmbeddedViewRef',
  'enableDebugTools',
  'EventEmitter',
  'EventManagerPlugin',
  'ExceptionHandler',
  'ExpressionChangedAfterItHasBeenCheckedException',
  'GetTestability',
  'Host',
  'HostBinding',
  'HostListener',
  'Inject',
  'Injectable',
  'Injector',
  'Input',
  'JsonPipe',
  'LowerCasePipe',
  'Module',
  'NgClass',
  'NgFor',
  'NgIf',
  'NgStyle',
  'NgSwitch',
  'NgSwitchDefault',
  'NgSwitchWhen',
  'NgTemplateOutlet',
  'NgZone',
  'NgZoneError',
  'OnChanges',
  'OnDestroy',
  'OnInit',
  'OpaqueToken',
  'Optional',
  'Output',
  'PLATFORM_INITIALIZER',
  'PercentPipe',
  'Pipe',
  'PipeTransform',
  'PlatformRef',
  'Provider',
  'ProviderUseClass',
  'ProviderUseMulti',
  'QueryList',
  'ReflectiveInjector',
  'RenderComponentType',
  'ReplacePipe',
  'Self',
  'SimpleChange',
  'SkipSelf',
  'SlicePipe',
  'SlowComponentLoader',
  'TemplateRef',
  'Testability',
  'TestabilityRegistry',
  'TrackByFn',
  'UpperCasePipe',
  'UrlResolver',
  'ViewChild',
  'ViewChildren',
  'ViewContainerRef',
  'ViewEncapsulation',
  'ViewRef',
  'Visibility',
  'WrappedException',
  'noValueProvided',
  'provide',
];
const diApis = const [
  'Component',
  'Directive',
  'EventEmitter',
  'ExceptionHandler',
  'Host',
  'Inject',
  'Injectable',
  'Injector',
  'Input',
  'Module',
  'NgZone',
  'NgZoneError',
  'OpaqueToken',
  'Optional',
  'Output',
  'Pipe',
  'PipeTransform',
  'Provider',
  'ProviderUseClass',
  'ProviderUseMulti',
  'ReflectiveInjector',
  'Self',
  'SkipSelf',
  'WrappedException',
  'noValueProvided',
  'provide'
];
