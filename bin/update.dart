import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Map minersLinks = const {
  'PhoenixMiner': "https://phoenixminer.info/downloads/",
  'NanoMiner':
      "https://api.github.com/repos/nanopool/nanominer/releases/latest",
  'NBMiner': "https://api.github.com/repos/NebuTech/NBMiner/releases/latest",
};
main(List<String> args) {
  downlinkfinderGithub("NBMiner");
  downlinkfinderGithub("NanoMiner");
}

downlinkfinderGithub(String miner) async {
  var url = Uri.parse(minersLinks[miner]);
  var response = await http.get(url);
  var decoded = jsonDecode(response.body);
  var links = [];
  for (var asset in decoded["assets"]) {
    if (Platform.isLinux &&
        asset["browser_download_url"]
            .contains(RegExp(r'linux', caseSensitive: false))) {
      if (!asset["browser_download_url"]
          .contains(RegExp(r'\.sha256$', caseSensitive: false)))
        links.add(asset["browser_download_url"]);
    }
  }
  print(links);
  return links;
}
