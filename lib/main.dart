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

  final List<String> _apertureList = ['0.5', '0.56', '0.6', '0.7', '0.8', '0.9', '1', '1.1', '1.2', '1.4', '1.6', '1.8', '2', '2.2', '2.5', '2.8', '3.2', '3.5', '4', '4.5', '5.0', '5.6', '6.3', '7.1', '8', '9', '10', '11', '13', '14', '16', '18', '20', '22', '25', '28', '32', '36', '40', '45', '50', '60', '64', '72', '80', '90', '100', '115', '128', '144', '160', '180', '200', '230', '256'];
  final List<String> _shutterList = ['1/32000', '1/25600', '1/20000', '1/16000', '1/12800', '1/10000', '1/8000', '1/6400', '1/5000', '1/4000', '1/3200', '1/2500', '1/2000', '1/1600', '1/1250', '1/1000', '1/800', '1/640', '1/500', '1/400', '1/320', '1/250', '1/200', '1/160', '1/125', '1/100', '1/80', '1/60', '1/50', '1/40', '1/30', '1/25', '1/20', '1/15', '1/13', '1/10', '1/8', '1/6', '1/5', '1/4', '1/3', '1/2.5', '1/2', '1/1.6', '1/1.3', '1', '1.3', '1.6', '2', '2.5', '3', '4', '5', '6', '8', '10', '13', '15', '20', '25', '30'];
  final List<String> _isoList = ['3','4','5','6','8','10','12','16','20','25','32','40','50', '64', '80', '100', '125', '160', '200', '250', '320', '400', '500', '640', '800', '1000', '1250', '1600', '2000', '2500', '3200', '4000', '5000', '6400', '8000', '10000', '12800', '16000', '20000', '25600', '32000', '40000', '51200', '64000', '80000', '102400', '128000'];
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
  final int f1Index = 6;
  final int ss1Index = 45;
  final int iso100Index = 15;
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
    _apertureMap = _generateApertureMap();
    _shutterMap = _generateShutterMap();
    _isoMap = _generateISOMap();
    _calculateExposure();
    print(_apertureMap.keys);
    print(_shutterMap.keys);
    print(_isoMap.keys);
    print(_apertureMap.keys.toList()[f1Index]);
    print(_shutterMap.keys.toList()[ss1Index]);
    print(_isoMap.keys.toList()[iso100Index]);
  }

  double calculateShutterSpeed(int n) {
    const num baseShutterSpeed = 1; // 1s 基準
    const num step = 1 / 3;
    num stepRatio = math.pow(2, step); // 1/3段刻みの倍率
    double res = baseShutterSpeed * math.pow(stepRatio, n) as double;
    return res;
  }

  double calculateApertureValue(int n) {
    const num baseFValue = 1; // f1 基準
    const num step = 1 / 3;
    num stepRatio = math.pow(2, step * 1 / 2); // 1/3段刻みの倍率（√2^(1/3)）
    double res = baseFValue * math.pow(stepRatio, n) as double;
    return res;
  }

  double calculateISOValue(int n) {
    const num baseISOValue = 100; // ISO 100 基準
    const num step = 1 / 3;
    num stepRatio = math.pow(2, step); // 1/3段刻みの倍率
    double res = baseISOValue * math.pow(stepRatio, n) as double;
    return res;
  }

  Map<String, double> _generateShutterMap() {
    return {for (int i = 0; i < _shutterList.length; i++) _shutterList[i]: calculateShutterSpeed(i - ss1Index)};
  }

  Map<String, double> _generateApertureMap() {
    return {for (int i = 0; i < _apertureList.length; i++) _apertureList[i]: calculateApertureValue(i - f1Index)};
  }

  Map<String, double> _generateISOMap() {
    return {for (int i = 0; i < _isoList.length; i++) _isoList[i]: calculateISOValue(i - iso100Index)};
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
                  items: _apertureMap.keys.toSet().map((key) {
                    return DropdownMenuItem<double>(
                      value: _apertureMap[key],
                      child: Text('F$key'),
                    );
                  }).toList(),
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
                  items: _shutterMap.keys.toSet().map((key) {
                    return DropdownMenuItem<double>(
                      value: _shutterMap[key],
                      child: Text(key),
                    );
                  }).toList(),
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
                  items: _isoMap.keys.toSet().map((key) {
                    return DropdownMenuItem<double>(
                      value: _isoMap[key],
                      child: Text(key),
                    );
                  }).toList(),
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
