import 'dart:math' as math;
import 'package:flutter/material.dart';

void main() {
  runApp(const ExposureCalculatorApp());
}

class ExposureCalculatorApp extends StatelessWidget {
  const ExposureCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exposure Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ExposureCalculatorScreen(),
    );
  }
}

class ExposureCalculatorScreen extends StatefulWidget {
  const ExposureCalculatorScreen({super.key});

  @override
  State<ExposureCalculatorScreen> createState() => _ExposureCalculatorScreenState();
}

class _ExposureCalculatorScreenState extends State<ExposureCalculatorScreen> {
  // https://www.scantips.com/lights/fstop2.html

  final List<String> _thirdAndHalfStopApertureList = ['0.5', '0.56', '0.6', '0.6', '0.7', '0.8', '0.8', '0.9', '1', '1.1', '1.2', '1.2', '1.4', '1.6', '1.7', '1.8', '2', '2.2', '2.4', '2.5', '2.8', '3.2', '3.3', '3.5', '4', '4.5', '4.8', '5.0', '5.6', '6.3', '6.7', '7.1', '8', '9', '9.5', '10', '11', '13', '13', '14', '16', '18', '19', '20', '22', '25', '27', '28', '32', '36', '38', '40', '45', '50', '55', '60', '64', '72', '76', '80', '90', '100', '110', '115', '128', '144', '152', '160', '180', '200', '220', '230', '256'];
  final List<String> _thirdAndHalfStopShutterList = ['1/32000', '1/25600', '1/24000', '1/20000', '1/16000', '1/12800', '1/12000', '1/10000', '1/8000', '1/6400', '1/6000', '1/5000', '1/4000', '1/3200', '1/3000', '1/2500', '1/2000', '1/1600', '1/1500', '1/1250', '1/1000', '1/800', '1/750', '1/640', '1/500', '1/400', '1/350', '1/320', '1/250', '1/200', '1/180', '1/160', '1/125', '1/100', '1/90', '1/80', '1/60', '1/50', '1/45', '1/40', '1/30', '1/25', '1/20', '1/20', '1/15', '1/13', '1/10', '1/10', '1/8', '1/6', '1/6', '1/5', '1/4', '1/3', '1/3', '1/2.5', '1/2', '1/1.6', '1/1.5', '1/1.3', '1', '1.3', '1.5', '1.6', '2', '2.5', '3', '3', '4', '5', '6', '6', '8', '10', '10', '13', '15', '20', '20', '25', '30'];
  final List<String> _thirdAndHalfStopISOList = ['0.75', '1', '1.1', '1.2', '1.5', '2', '2.2', '2.5', '3', '4', '4', '5', '6', '8', '9', '10', '12', '16', '18', '20', '25', '32', '35', '40', '50', '64', '70', '80', '100', '125', '140', '160', '200', '250', '280', '320', '400', '500', '560', '640', '800', '1000', '1100', '1250', '1600', '2000', '2200', '2500', '3200', '4000', '4400', '5000', '6400', '8000', '8800', '10000', '12500', '16000', '17600', '20000', '25000', '32000', '35200', '40000', '50000', '64000', '70400', '80000', '100000', '125000', '140800', '160000', '200000', '250000', '281600', '320000', '400000', '500000', '563200', '640000', '800000', '1000000', '1126400', '1250000', '1600000', '2000000', '2260000', '2500000', '3200000', '4000000', '4520000', '5000000', '6400000', '8000000'];
  final Map<String, double> _ndFilterMap = {
    // NDフィルターとそれが何段分に相当するかを Map で表現
    'No ND': 0,
    'ND2 (1 stop)': 1,
    'ND4 (2 stops)': 2,
    'ND8 (3 stops)': 3,
    'ND16 (4 stops)': 4,
    'ND32 (5 stops)': 5,
    'ND64 (6 stops)': 6,
    'ND128 (7 stops)': 7,
    'ND256 (8 stops)': 8,
    'ND400 (~8.6 stops)': 8.6,
    'ND512 (9 stops)': 9,
    'ND1000 (10 stops)': 10,
  };

  // 1/3段刻みのみ想定
  final int f1Index = 6;
  final int ss1Index = 45;
  final int iso100Index = 21;
  late final Map<String, double> _apertureMap;
  late final Map<String, double> _shutterMap;
  late final Map<String, double> _isoMap;

  // Current Exposure の初期値
  String _currentApertureKey = '5.6';
  String _currentShutterKey = '1/125';
  String _currentISOKey = '100';

  // New Exposure の初期値
  String _newApertureKey = '5.6';
  String _newISOKey = '100';
  String _selectedNdFilterKey = 'No ND';

  // 計算結果
  double _calculatedShutterSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _apertureMap = _generateThirdStopApertureMap();
    _shutterMap = _generateThirdStopShutterMap();
    _isoMap = _generateThirdStopISOMap();
    _calculateExposure();

    print('\n===Loaded Maps===');
    print('Aperture      : ${_apertureMap.keys}');
    print('Shutter Speeds: ${_shutterMap.keys}');
    print('ISO           : ${_isoMap.keys}\n');

    print('===Aperture===');
    print('Third and Half Stops: ${_generateThirdAndHalfStopApertureMap().keys}');
    print('Third Stops         : ${_generateThirdStopApertureMap().keys}');
    print('Half Stops          : ${_generateHalfStopApertureMap().keys}');
    print('Only Full Stops     : ${_generateFullStopApertureMap().keys}\n');

    print('===Shutter Speeds===');
    print('Third and Half Stops: ${_generateThirdAndHalfStopShutterMap().keys}');
    print('Third Stops         : ${_generateThirdStopShutterMap().keys}');
    print('Half Stops          : ${_generateHalfStopShutterMap().keys}');
    print('Only Full Stops     : ${_generateFullStopShutterMap().keys}\n');

    print('===ISO===');
    print('Third and Half Stops: ${_generateThirdAndHalfStopISOMap().keys}');
    print('Third Stops         : ${_generateThirdStopISOMap().keys}');
    print('Half Stops          : ${_generateHalfStopISOMap().keys}');
    print('Only Full Stops     : ${_generateFullStopISOMap().keys}\n');

    print('===Base Values===');
    print('Aperture: F${_apertureMap.keys.toList()[f1Index]}');
    print('SS      : ${_shutterMap.keys.toList()[ss1Index]}');
    print('ISO     : ${_isoMap.keys.toList()[iso100Index]}');
  }

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

  Map<String, double> _generateThirdAndHalfStopApertureMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopApertureList.length; i++) {
      int n = i - ((i + 1) ~/ 6) - ((i + 5) ~/ 6);
      if (i % 6 == 0) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 6, n - f1Index);
      } else if (i % 6 == 2) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 6, n - f1Index);
      } else if (i % 6 == 3) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 6, n - f1Index);
      } else if (i % 6 == 4) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 6, n - f1Index);
      }
    }
    return res;
  }

  Map<String, double> _generateThirdStopApertureMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopApertureList.length; i++) {
      int n = i - ((i + 2) ~/ 4);
      if (i % 4 == 0) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 3, n - f1Index);
      } else if (i % 4 == 1) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 3, n - f1Index);
      } else if (i % 4 == 3) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 3, n - f1Index);
      }
    }
    return res;
  }

  Map<String, double> _generateHalfStopApertureMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopApertureList.length; i++) {
      int n = i - ((i + 1) ~/ 4) - ((i + 3) ~/ 4);
      if (i % 2 == 0) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 2, n - f1Index);
      }
    }
    return res;
  }

  Map<String, double> _generateFullStopApertureMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopApertureList.length; i++) {
      int n = i - ((i + 1) ~/ 4) - ((i + 2) ~/ 4) - ((i + 3) ~/ 4);
      if (i % 4 == 0) {
        res[_thirdAndHalfStopApertureList[i]] = calculateApertureValue(1 / 1, n - f1Index);
      }
    }
    return res;
  }

  Map<String, double> _generateThirdAndHalfStopShutterMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopShutterList.length; i++) {
      int n = i - ((i + 1) ~/ 6) - ((i + 5) ~/ 6);
      if (i % 6 == 0) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 6, n - ss1Index);
      } else if (i % 6 == 2) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 6, n - ss1Index);
      } else if (i % 6 == 3) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 6, n - ss1Index);
      } else if (i % 6 == 4) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 6, n - ss1Index);
      }
    }
    return res;
  }

  Map<String, double> _generateThirdStopShutterMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopShutterList.length; i++) {
      int n = i - ((i + 2) ~/ 4);
      if (i % 4 == 0) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 3, n - ss1Index);
      } else if (i % 4 == 1) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 3, n - ss1Index);
      } else if (i % 4 == 3) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 3, n - ss1Index);
      }
    }
    return res;
  }

  Map<String, double> _generateHalfStopShutterMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopShutterList.length; i++) {
      int n = i - ((i + 1) ~/ 4) - ((i + 3) ~/ 4);
      if (i % 2 == 0) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 2, n - ss1Index);
      }
    }
    return res;
  }

  Map<String, double> _generateFullStopShutterMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopShutterList.length; i++) {
      int n = i - ((i + 1) ~/ 4) - ((i + 2) ~/ 4) - ((i + 3) ~/ 4);
      if (i % 4 == 0) {
        res[_thirdAndHalfStopShutterList[i]] = calculateShutterSpeed(1 / 1, n - ss1Index);
      }
    }
    return res;
  }

  Map<String, double> _generateThirdAndHalfStopISOMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopISOList.length; i++) {
      int n = i - ((i + 1) ~/ 6) - ((i + 5) ~/ 6);
      if (i % 6 == 0) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 6, n - iso100Index);
      } else if (i % 6 == 2) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 6, n - iso100Index);
      } else if (i % 6 == 3) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 6, n - iso100Index);
      } else if (i % 6 == 4) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 6, n - iso100Index);
      }
    }
    return res;
  }

  Map<String, double> _generateThirdStopISOMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopISOList.length; i++) {
      int n = i - ((i + 2) ~/ 4);
      if (i % 4 == 0) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 3, n - iso100Index);
      } else if (i % 4 == 1) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 3, n - iso100Index);
      } else if (i % 4 == 3) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 3, n - iso100Index);
      }
    }
    return res;
  }

  Map<String, double> _generateHalfStopISOMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopISOList.length; i++) {
      int n = i - ((i + 1) ~/ 4) - ((i + 3) ~/ 4);
      if (i % 2 == 0) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 2, n - iso100Index);
      }
    }
    return res;
  }

  Map<String, double> _generateFullStopISOMap() {
    Map<String, double> res = {};
    for (int i = 0; i < _thirdAndHalfStopISOList.length; i++) {
      int n = i - ((i + 1) ~/ 4) - ((i + 2) ~/ 4) - ((i + 3) ~/ 4);
      if (i % 4 == 0) {
        res[_thirdAndHalfStopISOList[i]] = calculateISOValue(1 / 1, n - iso100Index);
      }
    }
    return res;
  }

  /// ストップの差分を合計して、新シャッター速度を計算
  void _calculateExposure() {
    // 現在のシャッター速度（秒）
    double currentShutterSec = _shutterMap[_currentShutterKey]!;

    // 絞りのストップ差を計算
    // (Fstop の変化は平方比で考えるが、簡易的に「F5.6 → F11 = +2 stop」などのリスト/テーブル参照でも可)
    // ここでは厳密計算: stop = log2((NewF / OldF)^2)
    double currentApertureValue = _apertureMap[_currentApertureKey]!;
    double newApertureValue = _apertureMap[_newApertureKey]!;
    double apertureStop = _log2((newApertureValue / currentApertureValue) * (newApertureValue / currentApertureValue));

    // ISO のストップ差: stop = log2(OldISO / NewISO)
    double currentISOValue = _isoMap[_currentISOKey]!;
    double newISOValue = _isoMap[_newISOKey]!;
    double isoStop = _log2(currentISOValue / newISOValue);

    // ND フィルターの stop
    double ndStop = _ndFilterMap[_selectedNdFilterKey]!;

    // 合計ストップ
    double totalStop = apertureStop + isoStop + ndStop;

    // 新シャッター速度 = 現在のシャッター速度 * 2^(totalStop)
    double newShutterSec = currentShutterSec * _pow2(totalStop);

    setState(() {
      _calculatedShutterSeconds = newShutterSec;
    });
  }

  // 便利関数: log2(x)
  double _log2(double x) {
    return (x > 0) ? (MathHelper.logE(x) / MathHelper.logE(2)) : 0;
  }

  // 便利関数: 2^(x)
  double _pow2(double x) {
    return MathHelper.expE(MathHelper.logE(2) * x);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exposure Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Current Exposure',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Aperture
            Row(
              children: [
                const Text('Aperture: '),
                DropdownButton<double>(
                  value: _apertureMap[_currentApertureKey],
                  items: _apertureMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _apertureMap[key],
                            child: Text('F$key'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentApertureKey = _apertureMap.keys.firstWhere((key) => _apertureMap[key] == value);
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            // Shutter
            Row(
              children: [
                const Text('Shutter: '),
                DropdownButton<double>(
                  value: _shutterMap[_currentShutterKey],
                  items: _shutterMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _shutterMap[key],
                            child: Text(key),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentShutterKey = _shutterMap.keys.firstWhere((key) => _shutterMap[key] == value);
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            // ISO
            Row(
              children: [
                const Text('ISO: '),
                DropdownButton<double>(
                  value: _isoMap[_currentISOKey],
                  items: _isoMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _isoMap[key],
                            child: Text(key),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentISOKey = _isoMap.keys.firstWhere((key) => _isoMap[key] == value);
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'New Exposure',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Aperture
            Row(
              children: [
                const Text('Aperture: '),
                DropdownButton<double>(
                  value: _apertureMap[_newApertureKey],
                  items: _apertureMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _apertureMap[key],
                            child: Text('F$key'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newApertureKey = _apertureMap.keys.firstWhere((key) => _apertureMap[key] == value);
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            // ISO
            Row(
              children: [
                const Text('ISO: '),
                DropdownButton<double>(
                  value: _isoMap[_newISOKey],
                  items: _isoMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _isoMap[key],
                            child: Text(key),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newISOKey = _isoMap.keys.firstWhere((key) => _isoMap[key] == value);
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            // ND Filter
            Row(
              children: [
                const Text('ND Filter: '),
                DropdownButton<String>(
                  value: _selectedNdFilterKey,
                  items: _ndFilterMap.keys
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedNdFilterKey = value!;
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 結果表示
            Text(
              'Shutter: ${_formatSeconds(_calculatedShutterSeconds)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 秒数を「66s (1m06s)」のように整形する
  String _formatSeconds(double seconds) {
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
}

/// 小数の log と exp を扱うためのヘルパークラス
class MathHelper {
  static double logE(double x) => x > 0 ? math.log(x) : double.nan;
  static double expE(double x) => math.exp(x);
}
