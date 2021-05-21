import 'dart:io';
import '../config/miners.dart';
import 'package:process_run/shell.dart';

final args =
    "-pool stratum+tcp://daggerhashimoto.eu.nicehash.com:3353 -wal ${walletBTC}.1070 -pass x -proto 4 -stales 0 -log 0";

var running = true;
int pid = 0;
main() async {
  runner("PhoenixMiner", args);
  
}

runner(String miner, String args) async {
  //Find binary absolut path
  var result = await Process.run("find", [
    "../miners_binary/",
    "-iname",
    miner,
    "-type",
    "f",
    "-exec",
    "readlink",
    "-f",
    "{}",
    "\;"
  ]);
  var bin = result.stdout.toString().trim().replaceAll(" ", "\\ ") + " ";
  
  await Process.run("chmod", ["+x", bin]);
  var shell = Shell();
  await shell.run('gnome-terminal -- sh -c "${bin + args}"');
  watcher("PhoenixMiner");
}

watcher(String miner) {
  Future.delayed(Duration(seconds: 5), () async {
    var controller = ShellLinesController();
    var shell = Shell(stdout: controller.sink, verbose: false);
    // ignore: missing_return
    await shell.run("pidof ${miner}").onError((error, stackTrace) {
      runner("PhoenixMiner", args);
    });
    controller.stream.listen((event) {
      pid = int.parse(event.split(" ")[0]);
      if (running) watcher(miner);
      if (!running) Process.killPid(pid);
    });
  });
}
