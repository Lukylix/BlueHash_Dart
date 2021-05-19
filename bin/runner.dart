import 'dart:io';

import '../config/miners.dart';
import 'package:process_run/shell.dart';

final bin =
    "../miners_binary/PhoenixMiner/PhoenixMiner_5.6d_Linux/PhoenixMiner ";
final args =
    "-pool stratum+tcp://daggerhashimoto.eu.nicehash.com:3353 -wal ${walletBTC}.1070 -pass x -proto 4 -stales 0";
main() async {
  var shell = Shell();

  await shell.cd('log').run('gnome-terminal -- sh -c "${bin + args}"');

  var controller = ShellLinesController();
  var shell2 = Shell(stdout: controller.sink, verbose: false);
  var pid;
  controller.stream.listen((event) {
    print("event: ${event.split(" ").first}");
    pid = int.parse(event);
  });

  Future.delayed(Duration(seconds: 3), () async {
    await shell2.run("pidof PhoenixMiner");
    print("PID: ${pid}");
    shell2.kill();
    // Process.killPid(pid);
  });

  
}
