import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

import 'generate/collections.dart';
import 'generate/schema.dart';

const inputPath = 'input-path';
const ouputPath = 'output-path';
bool dev;
main(List<String> args) async {
  final parser = ArgParser()
    ..addOption(inputPath, abbr: 'i')
    ..addOption(ouputPath, abbr: 'o');
  final argResult = parser.parse(args);
  final jsonString =
      await File(argResult[inputPath] ?? '../flamestore.json').readAsString();
  final schema = Schema.fromJson(json.decode(jsonString));
  final path = argResult[ouputPath] ?? 'lib/flamestore';
  final colContent = schema.collections.entries
      .map((col) => generateCollection(schema, col.key, col.value))
      .join();
  final content = """
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flamestore/flamestore.dart';
$colContent
""";
  final filePath = '${path}/flamestore.g.dart';
  await File(filePath).writeAsString(content);
  await Process.run('flutter', ['format', filePath]);
}
