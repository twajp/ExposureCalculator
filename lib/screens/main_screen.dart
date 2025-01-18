import 'package:flutter/material.dart';
import '../helpers/math_helper.dart';
import '../utils/constants.dart';
import '../utils/map_generator.dart';
import '../utils/seconds_formatter.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final Map<String, double> _apertureMap;
  late final Map<String, double> _shutterMap;
  late final Map<String, double> _isoMap;

  // Current Exposure の宣言と初期値
  String currentApertureKey = '5.6';
  String currentShutterKey = '1/125';
  String currentISOKey = '100';

  // New Exposure の宣言と初期値
  String newApertureKey = '5.6';
  String newISOKey = '100';
  String selectedNdFilterKey = 'No ND';

  // 計算結果
  double calculatedShutterSeconds = 0.0;

  // 同期状態を管理する変数を追加
  bool isApertureSyncEnabled = false;
  bool isISOSyncEnabled = false;

  @override
  void initState() {
    super.initState();
    _apertureMap = generateThirdStopApertureMap();
    _shutterMap = generateThirdStopShutterMap();
    _isoMap = generateThirdStopISOMap();
    _calculateExposure();

    print('\n===Loaded Maps===');
    print('Aperture      : ${_apertureMap.keys}');
    print('Shutter Speeds: ${_shutterMap.keys}');
    print('ISO           : ${_isoMap.keys}\n');

    print('===Aperture===');
    print('Third and Half Stops: ${generateThirdAndHalfStopApertureMap().keys}');
    print('Third Stops         : ${generateThirdStopApertureMap().keys}');
    print('Half Stops          : ${generateHalfStopApertureMap().keys}');
    print('Only Full Stops     : ${generateFullStopApertureMap().keys}\n');

    print('===Shutter Speeds===');
    print('Third and Half Stops: ${generateThirdAndHalfStopShutterMap().keys}');
    print('Third Stops         : ${generateThirdStopShutterMap().keys}');
    print('Half Stops          : ${generateHalfStopShutterMap().keys}');
    print('Only Full Stops     : ${generateFullStopShutterMap().keys}\n');

    print('===ISO===');
    print('Third and Half Stops: ${generateThirdAndHalfStopISOMap().keys}');
    print('Third Stops         : ${generateThirdStopISOMap().keys}');
    print('Half Stops          : ${generateHalfStopISOMap().keys}');
    print('Only Full Stops     : ${generateFullStopISOMap().keys}\n');

    print('===Base Values===');
    print('Aperture: F${_apertureMap.keys.toList()[f1Index]}');
    print('SS      : ${_shutterMap.keys.toList()[ss1Index]}');
    print('ISO     : ${_isoMap.keys.toList()[iso100Index]}');
  }

  // 便利関数: log2(x)
  double _log2(double x) {
    return (x > 0) ? (MathHelper.logE(x) / MathHelper.logE(2)) : 0;
  }

  // 便利関数: 2^(x)
  double _pow2(double x) {
    return MathHelper.expE(MathHelper.logE(2) * x);
  }

  /// ストップの差分を合計して、新シャッター速度を計算
  void _calculateExposure() {
    // 現在のシャッター速度（秒）
    double currentShutterSec = _shutterMap[currentShutterKey]!;

    // 絞りのストップ差を計算
    // (Fstop の変化は平方比で考えるが、簡易的に「F5.6 → F11 = +2 stop」などのリスト/テーブル参照でも可)
    // ここでは厳密計算: stop = log2((NewF / OldF)^2)
    double currentApertureValue = _apertureMap[currentApertureKey]!;
    double newApertureValue = _apertureMap[newApertureKey]!;
    double apertureStop = _log2((newApertureValue / currentApertureValue) * (newApertureValue / currentApertureValue));

    // ISO のストップ差: stop = log2(OldISO / NewISO)
    double currentISOValue = _isoMap[currentISOKey]!;
    double newISOValue = _isoMap[newISOKey]!;
    double isoStop = _log2(currentISOValue / newISOValue);

    // ND フィルターの stop
    double ndStop = ndFilterMap[selectedNdFilterKey]!;

    // 合計ストップ
    double totalStop = apertureStop + isoStop + ndStop;

    // 新シャッター速度 = 現在のシャッター速度 * 2^(totalStop)
    double newShutterSec = currentShutterSec * _pow2(totalStop);

    setState(() {
      calculatedShutterSeconds = newShutterSec;
    });
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Aperture: '),
                DropdownButton<double>(
                  value: _apertureMap[currentApertureKey],
                  items: _apertureMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _apertureMap[key],
                            child: Text('F$key'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      currentApertureKey = _apertureMap.keys.firstWhere((key) => _apertureMap[key] == value);
                      if (isApertureSyncEnabled) {
                        newApertureKey = currentApertureKey; // 同期する
                      }
                    });
                    _calculateExposure();
                  },
                ),
                Switch(
                  value: isApertureSyncEnabled,
                  onChanged: (value) {
                    setState(
                      () {
                        isApertureSyncEnabled = value;
                        if (value) {
                          newApertureKey = currentApertureKey; // 同期状態で初期化
                          _calculateExposure();
                        }
                      },
                    );
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Shutter: '),
                DropdownButton<double>(
                  value: _shutterMap[currentShutterKey],
                  items: _shutterMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _shutterMap[key],
                            child: Text(key),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      currentShutterKey = _shutterMap.keys.firstWhere((key) => _shutterMap[key] == value);
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ISO: '),
                DropdownButton<double>(
                  value: _isoMap[currentISOKey],
                  items: _isoMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _isoMap[key],
                            child: Text(key),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      currentISOKey = _isoMap.keys.firstWhere((key) => _isoMap[key] == value);
                      if (isISOSyncEnabled) {
                        newISOKey = currentISOKey; // 同期する
                      }
                    });
                    _calculateExposure();
                  },
                ),
                Switch(
                  value: isISOSyncEnabled,
                  onChanged: (value) {
                    setState(() {
                      isISOSyncEnabled = value;
                      if (value) {
                        newISOKey = currentISOKey; // 同期状態で初期化
                        _calculateExposure();
                      }
                    });
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Aperture: '),
                DropdownButton<double>(
                  value: _apertureMap[newApertureKey],
                  items: _apertureMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _apertureMap[key],
                            child: Text('F$key'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      newApertureKey = _apertureMap.keys.firstWhere((key) => _apertureMap[key] == value);
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ISO: '),
                DropdownButton<double>(
                  value: _isoMap[newISOKey],
                  items: _isoMap.keys
                      .map((key) => DropdownMenuItem(
                            value: _isoMap[key],
                            child: Text(key),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      newISOKey = _isoMap.keys.firstWhere((key) => _isoMap[key] == value);
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('ND Filter: '),
                DropdownButton<String>(
                  value: selectedNdFilterKey,
                  items: ndFilterMap.keys
                      .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedNdFilterKey = value!;
                    });
                    _calculateExposure();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // 結果表示
            Text(
              'Shutter: ${formatSeconds(calculatedShutterSeconds)}',
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
}
