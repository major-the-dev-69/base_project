import 'dart:io';

/// Add feature names here (one per line) and run:
///   dart run tool/generate_features.dart
/// Or pass feature names directly via CLI:
///   dart run tool/generate_features.dart profile notifications
/// Pass --force to overwrite existing files.
const List<String> features = [
  'auth',
  'call',
  'history',
  'init',
  'member',
  'purchase',
  'setting',
  'wallet',
];

void main(List<String> args) {
  final force = args.contains('--force');
  final cliFeatures = args.where((a) => !a.startsWith('--')).toList();

  List<String> targets = features;
  if (cliFeatures.isNotEmpty) {
    targets = cliFeatures;
  }

  if (targets.isEmpty) {
    stdout.writeln('No features specified.');
    return;
  }

  for (final rawName in targets) {
    final snake = _toSnakeCase(rawName.trim());
    if (snake.isEmpty) continue;
    _generateFeature(snake, force: force);
  }
}

void _generateFeature(String feature, {required bool force}) {
  final pascal = _toPascalCase(feature);
  final baseDir = 'lib/features/$feature';

  final dirs = [
    '$baseDir/binding',
    '$baseDir/data/model',
    '$baseDir/data/repo',
    '$baseDir/presentation/controller',
    '$baseDir/presentation/page',
    '$baseDir/presentation/widgets',
  ];

  for (final dir in dirs) {
    Directory(dir).createSync(recursive: true);
  }

  final files = <String, String>{
    '$baseDir/binding/${feature}_binding.dart': _bindingTemplate(
      feature,
      pascal,
    ),
    '$baseDir/data/model/${feature}_model.dart': _modelTemplate(pascal),
    '$baseDir/data/repo/${feature}_repo.dart': _repoTemplate(pascal),
    '$baseDir/presentation/controller/${feature}_controller.dart':
        _controllerTemplate(feature, pascal),
    '$baseDir/presentation/page/${feature}_page.dart': _pageTemplate(
      feature,
      pascal,
    ),
  };

  for (final entry in files.entries) {
    final file = File(entry.key);
    if (file.existsSync() && !force) {
      stdout.writeln('Skipped (exists): ${entry.key}');
      continue;
    }
    file.writeAsStringSync(entry.value);
    stdout.writeln('Created: ${entry.key}');
  }
}

String _bindingTemplate(String feature, String pascal) {
  return '''import 'package:get/get.dart';
import 'package:go_service/features/$feature/data/repo/${feature}_repo.dart';
import 'package:go_service/features/$feature/presentation/controller/${feature}_controller.dart';

class ${pascal}Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<${pascal}Repo>(() => ${pascal}Repo());
    Get.lazyPut<${pascal}Controller>(
      () => ${pascal}Controller(repo: Get.find<${pascal}Repo>()),
    );
  }
}
''';
}

String _modelTemplate(String pascal) {
  return '''import 'package:go_service/base/base_data_model.dart';

class ${pascal}Model extends BaseDataModel {
  ${pascal}Model();

  factory ${pascal}Model.fromJson(Map<String, dynamic> json) {
    return ${pascal}Model();
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{};
  }
}
''';
}

String _repoTemplate(String pascal) {
  return '''import 'package:go_service/base/base_repository.dart';

abstract class ${pascal}Repo extends BaseRepository {}
class ${pascal}RepoImpl implements class ${pascal}Repo {}
''';
}

String _controllerTemplate(String feature, String pascal) {
  return '''import 'package:go_service/base/base_controller.dart';
import 'package:go_service/features/$feature/data/repo/${feature}_repo.dart';

class ${pascal}Controller extends BaseController {
  ${pascal}Controller({required this.repo});

  final ${pascal}Repo repo;
}
''';
}

String _pageTemplate(String feature, String pascal) {
  return '''import 'package:flutter/material.dart';
import 'package:go_service/base/base_widget.dart';
import 'package:go_service/features/$feature/presentation/controller/${feature}_controller.dart';

class ${pascal}Page extends BaseWidget<${pascal}Controller> {
  const ${pascal}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('$pascal')),
      body: const SizedBox.shrink(),
    );
  }
}
''';
}

String _toSnakeCase(String input) {
  final buffer = StringBuffer();
  for (var i = 0; i < input.length; i++) {
    final char = input[i];
    if (char == '-' || char == ' ') {
      buffer.write('_');
    } else if (char.toUpperCase() == char && char.toLowerCase() != char) {
      if (i > 0 && input[i - 1] != '_' && input[i - 1] != '-') {
        buffer.write('_');
      }
      buffer.write(char.toLowerCase());
    } else {
      buffer.write(char.toLowerCase());
    }
  }
  return buffer.toString().replaceAll(RegExp(r'_+'), '_');
}

String _toPascalCase(String snake) {
  final parts = snake.split('_').where((p) => p.isNotEmpty);
  final buffer = StringBuffer();
  for (final part in parts) {
    buffer.write(part[0].toUpperCase());
    if (part.length > 1) {
      buffer.write(part.substring(1));
    }
  }
  return buffer.toString();
}
