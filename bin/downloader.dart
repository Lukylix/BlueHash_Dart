import 'dart:io';
import 'dart:async';
import '../config/miners.dart';
import 'package:dio/dio.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';

void main(List<String> links) {
  if (links.isEmpty)
    return print("Specify miner to download: \n ${miners.keys}");

  for (var link in links) {
    if (!miners.keys.contains(link)) return print("invalid miner");
    RegExp uriEnd = RegExp(r"[^\/]+(?=\/$|$)");
    String fileName = uriEnd.firstMatch(miners[link]).group(0).toString();

    downloadFile(miners[link], "./miners_binary/${link}/${fileName}")
        .then((value) => extractFile("./miners_binary/${link}/", fileName));
  }
}

Future<void> downloadFile(String url, String savePath) async {
  String progressString = '';
  Dio dio = Dio();
  try {
    await dio.download(url, savePath, onReceiveProgress: (rec, total) {
      // print("Rec: $rec , Total: $total");
      progressString = ((rec / total) * 100).toStringAsFixed(0) + "%";
      print(Process.runSync("clear", [], runInShell: true).stdout);
      print("Downloading ${progressString}");
    });
  } catch (e) {
    print(e);
  }
  print("Download completed");
}

void extractFile(String path, String archivName) {
  var bytes = File(path + archivName).readAsBytesSync();
  if (new RegExp(r"gz$").hasMatch(archivName))
  bytes = GZipDecoder().decodeBytes(bytes);
  // Decode the Zip file
    final archive = TarDecoder().decodeBytes(bytes);

  // Extract the contents of the Zip archive to disk.
  for (final file in archive) {
    final filename = file.name;
    if (file.isFile) {
      final data = file.content as List<int>;
      File(path + filename)
        ..createSync(recursive: true)
        ..writeAsBytesSync(data);
    } else {
      Directory(path + filename)..create(recursive: true);
    }
  }
}
