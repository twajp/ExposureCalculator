String findClosestKey(Map<String, double> shutterMap, double target) {
  String closestKey = shutterMap.keys.first; // 最初のキーを初期値として使用
  double smallestDifference = (shutterMap[closestKey]! - target).abs();

  for (var entry in shutterMap.entries) {
    double currentDifference = (entry.value - target).abs();
    if (currentDifference < smallestDifference) {
      closestKey = entry.key;
      smallestDifference = currentDifference;
    }
  }

  return closestKey;
}

/// 秒数をわかりやすく整形する
String formatSeconds(Map<String, double> shutterMap, double seconds) {
  if (seconds < 30) {
    // カメラ内の表示に合わせる
    return findClosestKey(shutterMap, seconds);
  } else if (seconds < 60) {
    // 秒だけ表示
    int secInt = seconds.round();
    return '${secInt}s';
  } else if (seconds < 60 * 60) {
    // 分・秒に分解
    int secInt = seconds.round();
    int minutes = secInt ~/ 60;
    int remainSec = secInt % 60;
    return '${minutes}m ${remainSec < 10 ? "0$remainSec" : remainSec}s';
  } else {
    // 時間・分・秒に分解
    int secInt = seconds.round();
    int minutes = secInt ~/ 60;
    int remainSec = secInt % 60;
    int hours = minutes ~/ 60;
    int remainMin = minutes % 60;
    return '${hours}h ${remainMin < 10 ? "0$remainMin" : remainMin}m ${remainSec < 10 ? "0$remainSec" : remainSec}s';
  }
}
