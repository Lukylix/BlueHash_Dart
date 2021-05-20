import 'dart:io';
import '../config/miners.dart';
import 'package:process_run/shell.dart';

final bin =
    "../miners_binary/PhoenixMiner/PhoenixMiner_5.6d_Linux/PhoenixMiner ";
final args =
    "-pool stratum+tcp://daggerhashimoto.eu.nicehash.com:3353 -wal ${walletBTC}.1070 -pass x -proto 4 -stales 0";

var running = true;
int pid = 0;
main() async {
  await runner(bin, args);
  watcher("PhoenixMiner");
}

runner(String bin, String args) async {
  var shell = Shell();
  await shell
      .cd('log')
      .run('gnome-terminal -- sh -c "chmod +x ${bin}; ${bin + args}"');
}

watcher(String miner) {
  Future.delayed(Duration(seconds: 5), () async {
    var controller = ShellLinesController();
    var shell = Shell(stdout: controller.sink, verbose: false);
    // ignore: missing_return
    await shell.run("pidof ${miner}").onError((error, stackTrace) {
      runner(bin, args);
    });
    controller.stream.listen((event) {
      pid = int.parse(event.split(" ")[0]);
      if (running) watcher(miner);
      if (!running) Process.killPid(pid);
    });
  });
}
