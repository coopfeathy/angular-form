import 'dart:async';

import 'package:angular2/src/compiler/config.dart';
import 'package:angular2/src/compiler/offline_compiler.dart';
import 'package:angular2/src/transform/common/asset_reader.dart';
import 'package:angular2/src/transform/common/code/source_module.dart';
import 'package:angular2/src/transform/common/logging.dart';
import 'package:angular2/src/transform/common/names.dart';
import 'package:angular2/src/transform/common/options.dart';
import 'package:angular2/src/transform/common/ng_compiler.dart';
import 'package:angular2/src/transform/common/zone.dart' as zone;
import 'package:barback/barback.dart';

AssetId shimmedStylesheetAssetId(AssetId cssAssetId) => new AssetId(
    cssAssetId.package, toShimmedStylesheetExtension(cssAssetId.path));

AssetId nonShimmedStylesheetAssetId(AssetId cssAssetId) => new AssetId(
    cssAssetId.package, toNonShimmedStylesheetExtension(cssAssetId.path));

Future<Iterable<Asset>> processStylesheet(AssetReader reader,
    AssetId stylesheetId, TransformerOptions options) async {
  final stylesheetUrl = '${stylesheetId.package}|${stylesheetId.path}';
  var templateCompiler = zone.templateCompiler;
  if (templateCompiler == null) {
    var config = new CompilerConfig(
        useLegacyStyleEncapsulation: options.useLegacyStyleEncapsulation);
    templateCompiler = createTemplateCompiler(reader, config);
  }
  final cssText = await reader.readAsString(stylesheetId);
  return logElapsedAsync(() async {
    final sourceModules =
        templateCompiler.compileStylesheet(stylesheetUrl, cssText);

    return sourceModules.map((SourceModule module) => new Asset.fromString(
        new AssetId.parse('${module.moduleUrl}'), writeSourceModule(module)));
  }, operationName: 'processStylesheet', assetId: stylesheetId);
}
