import 'package:logger/logger.dart';
import 'package:stack_trace/stack_trace.dart';

final logger =
    () => Logger(printer: CustomPrinter.instance, level: Level.verbose);

class CustomPrinter extends LogPrinter {
  static CustomPrinter _customPrinter = CustomPrinter();
  CustomPrinter();
  static CustomPrinter get instance {
    return _customPrinter;
  }

  String trace = Trace.current().frames[2].member.toString();
  String? clName;
  String? mlName;
  @override
  List<String> log(LogEvent event) {
    int idx = trace.indexOf(".");
    if (idx != -1) {
      clName = trace.substring(0, idx).trim();
      mlName = trace.substring(idx + 1).trim();
    } else {
      clName = trace;
    }
    final color = PrettyPrinter().levelColors?[event.level];
    final message = event.message;
    final String cName = '======= $clName =======';
    final String mName = '----- $mlName -----';
    final String end = '<' * 30;
    return [color!('\n$cName\n$mName\n\n$message\n\n$end\n')];
  }
}
