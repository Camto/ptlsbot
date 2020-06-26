import "dart:io";

import "package:pointless/pointless.dart";

// import "package:logging/logging.dart";
import "package:nyxx/nyxx.dart";

final dir = Directory.systemTemp.path;
var num = 0;

void main() {
	// setupDefaultLogging();
	final bot = Nyxx(Platform.environment['TOKEN'] ?? "bruh");
	
	bot.onReady.listen((e) {
		print("${bot.self.username}#${bot.self.discriminator} logged in!");
	});
	
	bot.onMessageReceived.listen((e) {
		var content = e.message.content;
		if(content.startsWith("ptls:")) {
			e.message.channel.send(content: run_ptls(
				"output = ${content.substring(5)}"
			));
		} else if(content.startsWith("ptlse:")) {
			e.message.channel.send(content: run_ptls(
				"output = print(${content.substring(6)})"
			));
		}
	});
}

String run_ptls(String prog) {
	var file = File("${dir}/${num++}.ptls")
		..createSync()
		..writeAsStringSync(prog);
	var out = "";
	
	try {
		var source = SourceFile.loadPath(file.path, "");
		var env = source.getEnv();
		for(var command in env.getOutput()) {
			if([PtlsLabel, PtlsTuple].contains(command.runtimeType)) {
				if(
					command is PtlsTuple &&
					command.label.value == "IOPrint" &&
					command.members.length == 1 &&
					command.members[0].runtimeType == PtlsString
				) {
					out += (command.members[0] as PtlsString).value;
				}
			}
		}
	} on PtlsError catch(err) {
		out = "```\n${err.toString()}\n```";
	}
	
	file.deleteSync();
	return out;
}