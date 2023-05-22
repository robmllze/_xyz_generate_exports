// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
//
// XYZ Generate Exports
//
// ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓

library _xyz_generate_exports;

import 'package:xyz_utils/xyz_utils.dart';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

Builder configsExportsBuilder(BuilderOptions options) => AnyExportsBuilder("configs");
Builder managersExportsBuilder(BuilderOptions options) => AnyExportsBuilder("managers");
Builder modelsExportsBuilder(BuilderOptions options) => AnyExportsBuilder("models");
Builder routingExportsBuilder(BuilderOptions options) => AnyExportsBuilder("routing");
Builder servicesExportsBuilder(BuilderOptions options) => AnyExportsBuilder("services");
Builder themesExportsBuilder(BuilderOptions options) => AnyExportsBuilder("themes");
Builder utilsExportsBuilder(BuilderOptions options) => AnyExportsBuilder("utils");
Builder widgetsExportsBuilder(BuilderOptions options) => AnyExportsBuilder("widgets");

Builder screensExportsBuilder(BuilderOptions options) => AllScreensExportsBuilder();

// xyz_shared
Builder sharedConfigsExportsBuilder(BuilderOptions options) =>
    AnyExportsBuilder("xyz_shared/src/configs");
Builder sharedManagersExportsBuilder(BuilderOptions options) =>
    AnyExportsBuilder("xyz_shared/src/managers");
Builder sharedModelsExportsBuilder(BuilderOptions options) =>
    AnyExportsBuilder("xyz_shared/src/models");
Builder sharedRoutingExportsBuilder(BuilderOptions options) =>
    AnyExportsBuilder("xyz_shared/src/routing");
Builder sharedServicesExportsBuilder(BuilderOptions options) =>
    AnyExportsBuilder("xyz_shared/src/services");
Builder sharedThemesExportsBuilder(BuilderOptions options) =>
    AnyExportsBuilder("xyz_shared/src/themes");
Builder sharedUtilsExportsBuilder(BuilderOptions options) =>
    AnyExportsBuilder("xyz_shared/src/utils");
Builder sharedWidgetsExportsBuilder(BuilderOptions options) =>
    AnyExportsBuilder("xyz_shared/src/widgets");

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class AnyExportsBuilder implements Builder {
  //
  //
  //

  final String libPath;
  late String allFileName;
  AnyExportsBuilder(this.libPath);

  //
  //
  //

  @override
  Map<String, List<String>> get buildExtensions {
    this.allFileName = "all_${this.libPath.split("/").last}.dart";
    return {
      r"$lib$": ["${this.libPath}/${this.allFileName}"],
    };
  }

  //
  //
  //

  @override
  Future<void> build(BuildStep buildStep) async {
    final lines = <String>[];
    final inputs = buildStep.findAssets(Glob("lib/${this.libPath}/**"));
    await for (final input in inputs) {
      final path = input.path.replaceFirst("lib/${this.libPath}/", "");
      final condition1 =
          // May not contain "/_"...
          !path.contains(r"/_") &&
              // ...must be all lowercalse...
              path.toLowerCase() == path &&
              // ...and must end with ".dart"
              path.endsWith(".dart");
      if (!condition1) continue;
      final line = "export '$path';";
      lines.add(line);
    }
    final output = (lines..sort()).join("\n");
    final id = AssetId(
      buildStep.inputId.package,
      path.join("lib", this.libPath, this.allFileName),
    );

    await buildStep.writeAsString(
      id,
      "// GENERATED CODE - DO NOT MODIFY BY HAND\n\n"
      "$output",
    );
  }
}

// ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░

class AllScreensExportsBuilder implements Builder {
  //
  //
  //

  @override
  Map<String, List<String>> get buildExtensions {
    return {
      r"$lib$": ["screens/all_screens.dart"],
    };
  }

  //
  //
  //

  @override
  Future<void> build(BuildStep buildStep) async {
    final linesExports = <String>[],
        linesScreenMakers = <String>[],
        linesCannotRequest = <String>[],
        linesAccessible = <String>[],
        linesAccessibleIfVerified = <String>[],
        linesAccessibleIfSignedIn = <String>[],
        linesAccessibleIfSignedOut = <String>[],
        linesScreenTypes = <String>[],
        linesScreenMetadata = <String>[],
        linesConfigurationCasts = <String>[];
    final paths = [
      ...(await buildStep
          .findAssets(Glob("lib/screens/**"))
          .map((final l) => l.path.replaceFirst("lib/screens/", ""))
          .toList()),
      ...(await buildStep
          .findAssets(Glob("lib/xyz_shared/src/screens/**"))
          .map((final l) => l.path.replaceFirst("lib", ""))
          .toList())
    ]..sort();

    for (final path in paths) {
      final b0 =
          // May not contain "/_"...
          path.contains(r"/_") ||
              // ...must be all lowercalse...
              path.toLowerCase() != path ||
              // ...and must end with ".dart"
              !path.endsWith(".dart");
      if (b0) continue;
      final b1 = path.endsWith(".options.dart");
      if (b1) continue;
      linesExports.add("export '$path';");
      final nameClass =
          RegExp(r"\/((screen_)(\w+))\.dart").firstMatch(path)?.group(1)?.toCamelCaseCapitalized();
      if (nameClass != null) {
        final constNameScreen = nameClass.substring("Screen".length).toSnakeCase().toUpperCase();
        final constNameLocation = "/${constNameScreen.toLowerCase()}";
        linesScreenMakers //
            .add("maker$nameClass,");
        linesConfigurationCasts.add(
          "...cast${nameClass}Configuration,",
        );
        linesCannotRequest //
            .add("...LOCATION_NOT_REDIRECTABLE_$constNameScreen,");
        linesAccessible //
            .add("...LOCATION_ACCESSIBLE_$constNameScreen,");
        linesAccessibleIfVerified //
            .add("...LOCATION_ACCESSIBLE_ONLY_IF_SIGNED_IN_AND_VERIFIED_$constNameScreen,");
        linesAccessibleIfSignedIn //
            .add("...LOCATION_ACCESSIBLE_ONLY_IF_SIGNED_IN_$constNameScreen,");
        linesAccessibleIfSignedOut //
            .add("...LOCATION_ACCESSIBLE_ONLY_IF_SIGNED_OUT_$constNameScreen,");
        linesScreenTypes.add("\"$constNameLocation\": $nameClass,");
        linesScreenMetadata.add("$nameClass: null,");
      }
    }

    // ignore: prefer_interpolation_to_compose_strings
    final output = "\n\n" + //
        "import '/all.dart';\n\n" +
        "${linesExports.join("\n")}\n\n" +
        "const SCREEN_MAKERS = [\n  ${linesScreenMakers.join("\n  ")}\n];" +
        "\n\nconst LOCATIONS_NOT_REDIRECTABLE = [\n  ${linesCannotRequest.join("\n  ")}\n];" +
        "\n\nconst LOCATIONS_ACCESSIBLE = [\n  ${linesAccessible.join("\n  ")}\n];" +
        "\n\nconst LOCATIONS_ACCESSIBLE_ONLY_IF_SIGNED_IN_AND_VERIFIED = [\n  ${linesAccessibleIfVerified.join("\n  ")}\n];" +
        "\n\nconst LOCATIONS_ACCESSIBLE_ONLY_IF_SIGNED_IN = [\n  ${linesAccessibleIfSignedIn.join("\n  ")}\n];" +
        "\n\nconst LOCATIONS_ACCESSIBLE_ONLY_IF_SIGNED_OUT = [\n  ${linesAccessibleIfSignedOut.join("\n  ")}\n];" +
        "\n\nfinal configurationCasts = Map<Type, MyRouteConfiguration Function(MyRouteConfiguration)>.unmodifiable({\n  ${linesConfigurationCasts.join("\n  ")}\n});";
    ;
    final id = AssetId(
      buildStep.inputId.package,
      path.join("lib", "screens", "all_screens.dart"),
    );
    await buildStep.writeAsString(
      id,
      "// GENERATED CODE - DO NOT MODIFY BY HAND"
      "$output",
    );
  }
}
