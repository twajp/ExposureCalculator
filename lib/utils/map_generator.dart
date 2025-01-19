import 'dart:math' as math;
import 'constants.dart';
import '../helpers/math_helper.dart';

double calculateShutterSpeed(num step, int n) {
  const num baseShutterSpeed = 1; // 1s 基準
  num stepRatio = math.pow(2, step); // 1/3段刻みの倍率
  double res = baseShutterSpeed * math.pow(stepRatio, n) as double;
  return res;
}

double calculateApertureValue(num step, int n) {
  const num baseFValue = 1; // f1 基準
  num stepRatio = math.pow(2, step * 1 / 2); // 1/3段刻みの倍率（√2^(1/3)）
  double res = baseFValue * math.pow(stepRatio, n) as double;
  return res;
}

double calculateISOValue(num step, int n) {
  const num baseISOValue = 100; // ISO 100 基準
  num stepRatio = math.pow(2, step); // 1/3段刻みの倍率
  double res = baseISOValue * math.pow(stepRatio, n) as double;
  return res;
}

Map<String, double> generateThirdAndHalfStopApertureMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopApertureList.length; i++) {
    int n = i - ((i + 1) ~/ 6) - ((i + 5) ~/ 6);
    if (i % 6 == 0) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 6, n - f1Index);
    } else if (i % 6 == 2) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 6, n - f1Index);
    } else if (i % 6 == 3) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 6, n - f1Index);
    } else if (i % 6 == 4) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 6, n - f1Index);
    }
  }
  return res;
}

Map<String, double> generateThirdStopApertureMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopApertureList.length; i++) {
    int n = i - ((i + 2) ~/ 4);
    if (i % 4 == 0) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 3, n - f1Index);
    } else if (i % 4 == 1) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 3, n - f1Index);
    } else if (i % 4 == 3) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 3, n - f1Index);
    }
  }
  return res;
}

Map<String, double> generateHalfStopApertureMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopApertureList.length; i++) {
    int n = i - ((i + 1) ~/ 4) - ((i + 3) ~/ 4);
    if (i % 2 == 0) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 2, n - f1Index);
    }
  }
  return res;
}

Map<String, double> generateFullStopApertureMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopApertureList.length; i++) {
    int n = i - ((i + 1) ~/ 4) - ((i + 2) ~/ 4) - ((i + 3) ~/ 4);
    if (i % 4 == 0) {
      res[thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 1, n - f1Index);
    }
  }
  return res;
}

Map<String, double> generateThirdAndHalfStopShutterMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopShutterList.length; i++) {
    int n = i - ((i + 1) ~/ 6) - ((i + 5) ~/ 6);
    if (i % 6 == 0) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 6, n - ss1Index);
    } else if (i % 6 == 2) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 6, n - ss1Index);
    } else if (i % 6 == 3) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 6, n - ss1Index);
    } else if (i % 6 == 4) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 6, n - ss1Index);
    }
  }
  return res;
}

Map<String, double> generateThirdStopShutterMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopShutterList.length; i++) {
    int n = i - ((i + 2) ~/ 4);
    if (i % 4 == 0) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 3, n - ss1Index);
    } else if (i % 4 == 1) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 3, n - ss1Index);
    } else if (i % 4 == 3) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 3, n - ss1Index);
    }
  }
  return res;
}

Map<String, double> generateHalfStopShutterMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopShutterList.length; i++) {
    int n = i - ((i + 1) ~/ 4) - ((i + 3) ~/ 4);
    if (i % 2 == 0) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 2, n - ss1Index);
    }
  }
  return res;
}

Map<String, double> generateFullStopShutterMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopShutterList.length; i++) {
    int n = i - ((i + 1) ~/ 4) - ((i + 2) ~/ 4) - ((i + 3) ~/ 4);
    if (i % 4 == 0) {
      res[thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 1, n - ss1Index);
    }
  }
  return res;
}

Map<String, double> generateThirdAndHalfStopISOMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopISOList.length; i++) {
    int n = i - ((i + 1) ~/ 6) - ((i + 5) ~/ 6);
    if (i % 6 == 0) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 6, n - iso100Index);
    } else if (i % 6 == 2) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 6, n - iso100Index);
    } else if (i % 6 == 3) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 6, n - iso100Index);
    } else if (i % 6 == 4) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 6, n - iso100Index);
    }
  }
  return res;
}

Map<String, double> generateThirdStopISOMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopISOList.length; i++) {
    int n = i - ((i + 2) ~/ 4);
    if (i % 4 == 0) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 3, n - iso100Index);
    } else if (i % 4 == 1) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 3, n - iso100Index);
    } else if (i % 4 == 3) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 3, n - iso100Index);
    }
  }
  return res;
}

Map<String, double> generateHalfStopISOMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopISOList.length; i++) {
    int n = i - ((i + 1) ~/ 4) - ((i + 3) ~/ 4);
    if (i % 2 == 0) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 2, n - iso100Index);
    }
  }
  return res;
}

Map<String, double> generateFullStopISOMap() {
  Map<String, double> res = {};
  for (int i = 0; i < thirdAndHalfStopISOList.length; i++) {
    int n = i - ((i + 1) ~/ 4) - ((i + 2) ~/ 4) - ((i + 3) ~/ 4);
    if (i % 4 == 0) {
      res[thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 1, n - iso100Index);
    }
  }
  return res;
}

Map<String, double> generateNDFilterMap() {
  Map<String, double> res = {};
  for (int i = 0; i < ndFilterList.length; i++) {
    double stop = log2(ndFilterList[i] as double);
    if (i == 0) {
      res['No Filter'] = stop;
    } else {
      res['ND${ndFilterList[i]}'] = stop;
    }
  }
  return res;
}
