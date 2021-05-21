import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

const Map minersLinks = const {
  'PhoenixMiner': "https://phoenixminer.info/downloads/",
  'NanoMiner':
      "https://api.github.com/repos/nanopool/nanominer/releases/latest",
  'NBMiner': "https://api.github.com/repos/NebuTech/NBMiner/releases/latest",
  'GMiner':
      "https://api.github.com/repos/develsoftware/GMinerRelease/releases/latest",
  'CryptoDredge':
      "https://api.github.com/repos/technobyl/CryptoDredge/releases",
};
main(List<String> args) {
  // downlinkfinder("NBMiner");
  // downlinkfinder("NanoMiner");
  // downlinkfinder("GMiner");
  // downlinkfinder('CryptoDredge');
  // downlinkfinder("PhoenixMiner");
}

Future downlinkfinder(String miner) {
  if (minersLinks[miner].contains("github")) return downlinkfinderGithub(miner);
  return downlinkfinderHtml(miner);
}

downlinkfinderGithub(String miner) async {
  var url = Uri.parse(minersLinks[miner]);
  var response = await http.get(url);
  var decoded = jsonDecode(response.body);
  var links = [];
  for (var asset in url.toString().contains("latest")
      ? decoded["assets"]
      : decoded[0]["assets"]) {
    if (Platform.isLinux &&
        asset["browser_download_url"]
            .contains(RegExp(r'linux', caseSensitive: false))) {
      if (!asset["browser_download_url"]
          .contains(RegExp(r'\.sha256$', caseSensitive: false)))
        links.add(asset["browser_download_url"]);
    }
  }
  return links[0];
}

downlinkfinderHtml(String miner) async {
  var url = Uri.parse(minersLinks[miner]);
  var response = await http.get(url);
  var reg = RegExp(r'href="(.*)"', caseSensitive: false, multiLine: true);
  var links = [];
  var matches = reg.allMatches(response.body);
  for (var item in matches) {
    if (item.group(1).contains(miner) &&
        item.group(1).toLowerCase().contains("linux") &&
        !item
            .group(1)
            .toLowerCase()
            .contains(RegExp(r'\.asc$', caseSensitive: false)))
      links.add(item.group(1));
  }
  //Relative link into absolute
  for (var i = 0; i < links.length; i++) {
    if (!links[i].contains(RegExp(r'^http')))
      links[i] = minersLinks[miner] + links[i];
  }
  return links[0];
}
