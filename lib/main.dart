import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const ExposureCalculatorApp());
}

class ExposureCalculatorApp extends StatelessWidget {
  const ExposureCalculatorApp({Key? key}) : super(key: key);

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
  const ExposureCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<ExposureCalculatorScreen> createState() => _ExposureCalculatorScreenState();
}

class _ExposureCalculatorScreenState extends State<ExposureCalculatorScreen> {
  // 絞り値、シャッター速度、ISO の選択肢
  final List<double> _apertureList = [4.0, 4.5, 5.0, 5.6, 6.3, 7.1, 8.0, 9.0, 10.0, 11.0, 13.0, 14.0, 16.0];

  // シャッター速度は「1/125」などを String で持ちたいので Map で管理
  final Map<String, double> _shutterMap = {
    '1/60': 1.0 / 60.0,
    '1/80': 1.0 / 80.0,
    '1/100': 1.0 / 100.0,
    '1/125': 1.0 / 125.0,
    '1/160': 1.0 / 160.0,
    '1/200': 1.0 / 200.0,
    '1/250': 1.0 / 250.0,
  };

  final List<int> _isoList = [50, 100, 200, 400, 800, 1600];

  // ND フィルターとそれが何ストップに相当するかを Map で表現
  final Map<String, double> _ndFilterMap = {
    'ND128 (7 stops)': 7,
    'ND256 (8 stops)': 8,
    'ND400 (~8.6 stops)': 8.6,
    'ND512 (9 stops)': 9,
    'ND1000 (10 stops)': 10,
  };

  // Current Exposure の初期値
  double _currentAperture = 5.6;
  String _currentShutterKey = '1/125';
  int _currentISO = 400;

  // New Exposure の初期値
  double _newAperture = 11.0;
  int _newISO = 100;
  String _selectedNdFilterKey = 'ND512 (9 stops)';

  // 計算結果
  double _calculatedShutterSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    _calculateExposure();
  }

  /// ストップの差分を合計して、新シャッター速度を計算
  void _calculateExposure() {
    // 現在のシャッター速度（秒）
    double currentShutterSec = _shutterMap[_currentShutterKey] ?? 1.0 / 125.0;

    // 絞りのストップ差を計算
    // (Fstop の変化は平方比で考えるが、簡易的に「F5.6 → F11 = +2 stop」などのリスト/テーブル参照でも可)
    // ここでは厳密計算: stop = log2((NewF / OldF)^2)
    double apertureStop = _log2((_newAperture / _currentAperture) * (_newAperture / _currentAperture));

    // ISO のストップ差: stop = log2(OldISO / NewISO)
    double isoStop = _log2(_currentISO / _newISO.toDouble());

    // ND フィルターの stop
    double ndStop = _ndFilterMap[_selectedNdFilterKey] ?? 0.0;

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
                  value: _currentAperture,
                  items: _apertureList
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text('F${e.toString()}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentAperture = value!;
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
                DropdownButton<String>(
                  value: _currentShutterKey,
                  items: _shutterMap.keys
                      .map((key) => DropdownMenuItem(
                            value: key,
                            child: Text(key),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentShutterKey = value!;
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
                DropdownButton<int>(
                  value: _currentISO,
                  items: _isoList
                      .map((iso) => DropdownMenuItem(
                            value: iso,
                            child: Text(iso.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _currentISO = value!;
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
                  value: _newAperture,
                  items: _apertureList
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text('F${e.toString()}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newAperture = value!;
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
                DropdownButton<int>(
                  value: _newISO,
                  items: _isoList
                      .map((iso) => DropdownMenuItem(
                            value: iso,
                            child: Text(iso.toString()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _newISO = value!;
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
      return '${secInt}s (${minutes}m ${remainSec < 10 ? "0$remainSec" : remainSec}s)';
    }
  }
}

/// 小数の log と exp を扱うためのヘルパークラス
class MathHelper {
  static double logE(double x) => x > 0 ? math.log(x) : double.nan;
  static double expE(double x) => math.exp(x);
}
