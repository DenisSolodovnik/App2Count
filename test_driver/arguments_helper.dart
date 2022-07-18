import 'dart:convert';
import 'package:args/args.dart';

class ArgumentsHelper {
  static String toArgs(List<String> args) {
    return jsonEncode(args);
  }

  static List<String> args(String? source) {
    if (source == null) return [];
    return (jsonDecode(source) as List<dynamic>).cast<String>();
  }

  static parser() {
    var parser = ArgParser();
    parser.addFlag('clear');
    parser.addFlag('restart');
    parser.addOption('database');
    return parser;
  }
}
