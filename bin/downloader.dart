import 'dart:io';
import '../config/miners.dart';

void main(List<String> links) {
  if (links.isEmpty)
    return print("Specify miner to download: \n ${miners.keys}");

  for (var link in links) {
    if (!miners.keys.contains(link)) return print("invalid miner");
    RegExp uriEnd = RegExp(r"[^\/]+(?=\/$|$)");
    String fileName = uriEnd.firstMatch(miners[link]).group(0).toString();

    HttpClient client = new HttpClient();
    client.getUrl(Uri.parse(miners[link])).then((HttpClientRequest request) {
      return request.close();
    }).then((HttpClientResponse response) {
      print("Downloading ${fileName} ...");
      Directory('./miners_binary/${link}').create(recursive: true).then((dir) {
        response
            .pipe(new File("./miners_binary/${link}/${fileName}").openWrite());
        
      });
    });
  }
}
