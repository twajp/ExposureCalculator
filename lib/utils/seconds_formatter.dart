/// 秒数を「66s (1m06s)」のように整形する
String formatSeconds(double seconds) {
  if (seconds < 1) {
    // 1 秒未満なら小数表記
    return '${seconds.toStringAsFixed(3)} s';
  } else {
    // 分・秒に分解
    int secInt = seconds.round();
    int minutes = secInt ~/ 60;
    int remainSec = secInt % 60;
    // return '${secInt}s (${minutes}m ${remainSec < 10 ? "0$remainSec" : remainSec}s)';
    return '${seconds.toStringAsFixed(3)}s (${minutes}m ${remainSec < 10 ? "0$remainSec" : remainSec}s)';
  }
}
