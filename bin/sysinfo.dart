import 'dart:convert';
import 'dart:io';
import 'package:pretty_json/pretty_json.dart';
import 'package:system_info/system_info.dart';

main(List<String> args) async {
  var myFile = await File('config/config.json').readAsString();

  var config = jsonDecode(myFile);
  config["processor"] = SysInfo.processors[0].name;
  var result = await Process.run("lshw", ["-numeric", "-C", "display"]);
  String stringResult = result.stdout.toString();

  var name = stringResult.split('\n')[2].trim();
  var reg = RegExp(r'\[.*?\]');
  String gpuName =
      reg.firstMatch(name).group(0).toString().replaceAll(RegExp(r'\[|\]'), "");
  String gpuType = stringResult
          .split('\n')[3]
          .trim()
          .contains(RegExp(r"nvidia", caseSensitive: false))
      ? "NVIDIA"
      : "AMD";

  config["graphicsCards"][0]["name"] = gpuName;
  config["graphicsCards"][0]["type"] = gpuType;
  var prettyjson = prettyJson(config, indent: 2);
  File('config/config.json').writeAsString("""${prettyjson}""");
}
