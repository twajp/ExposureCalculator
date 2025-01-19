import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../helpers/math_helper.dart';
import '../utils/constants.dart';
import '../utils/map_generator.dart';
import '../utils/seconds_formatter.dart';
import '../widgets/horizontal_scroll_selector.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final Map<String, double> _apertureMap;
  late final Map<String, double> _shutterMap;
  late final Map<String, double> _isoMap;
  late final Map<String, double> _ndFilterMap;

  // Current Exposure の宣言
  late String currentApertureKey;
  late String currentShutterKey;
  late String currentISOKey;

  // New Exposure の宣言
  late String newApertureKey;
  late String newISOKey;
  late String selectedNdFilterKey;

  // 計算結果
  double calculatedShutterSeconds = 0.0;

  // 同期状態を管理する変数を追加
  bool isApertureSyncEnabled = false;
  bool isISOSyncEnabled = false;

  // HorizontalScrollSelector 用の PageController を追加
  late PageController _currentAperturePageController;
  late PageController _currentShutterPageController;
  late PageController _currentISOPageController;
  late PageController _newAperturePageController;
  late PageController _newISOPageController;
  late PageController _ndFilterPageController;

  // HorizontalScrollSelector の選択インデックスを追加
  late int _selectedCurrentApertureMapIndex;
  late int _selectedCurrentShutterMapIndex;
  late int _selectedCurrentISOMapIndex;
  late int _selectedNewApertureMapIndex;
  late int _selectedNewISOMapIndex;
  late int _selectedNDFilterMapIndex;

  // 無限ループ防止のためのフラグ
  bool _isUpdatingCurrentFromNew = false;
  bool _isUpdatingNewFromCurrent = false;

  @override
  void initState() {
    super.initState();
    _apertureMap = generateThirdStopApertureMap();
    _shutterMap = generateThirdStopShutterMap();
    _isoMap = generateThirdStopISOMap();
    _ndFilterMap = generateNDFilterMap();

    currentApertureKey = _apertureMap.keys.toList()[defaultCurrentApertureIndex];
    currentShutterKey = _shutterMap.keys.toList()[defaultCurrentShutterIndex];
    currentISOKey = _isoMap.keys.toList()[defaultCurrentISOIndex];
    newApertureKey = _apertureMap.keys.toList()[defaultNewApertureIndex];
    newISOKey = _isoMap.keys.toList()[defaultNewISOIndex];
    selectedNdFilterKey = _ndFilterMap.keys.toList()[defaultNDIndex];

    // HorizontalScrollSelector の初期位置を設定
    _selectedCurrentApertureMapIndex = defaultCurrentApertureIndex;
    _selectedCurrentShutterMapIndex = defaultCurrentShutterIndex;
    _selectedCurrentISOMapIndex = defaultCurrentISOIndex;
    _selectedNewApertureMapIndex = defaultNewApertureIndex;
    _selectedNewISOMapIndex = defaultNewISOIndex;
    _selectedNDFilterMapIndex = defaultNDIndex;

    // 初期インデックスを設定して PageController を初期化
    _currentAperturePageController = PageController(
      viewportFraction: 0.3,
      initialPage: _selectedCurrentApertureMapIndex, // Current Aperture の初期インデックス
    );
    _currentShutterPageController = PageController(
      viewportFraction: 0.3,
      initialPage: _selectedCurrentShutterMapIndex, // Current Shutter の初期インデックス
    );
    _currentISOPageController = PageController(
      viewportFraction: 0.3,
      initialPage: _selectedCurrentISOMapIndex, // Current ISO の初期インデックス
    );
    _newAperturePageController = PageController(
      viewportFraction: 0.3,
      initialPage: _selectedNewApertureMapIndex, // New Aperture の初期インデックス
    );
    _newISOPageController = PageController(
      viewportFraction: 0.3,
      initialPage: _selectedNewISOMapIndex, // New ISO の初期インデックス
    );
    _ndFilterPageController = PageController(
      viewportFraction: 0.3,
      initialPage: _selectedNDFilterMapIndex, // ND フィルターの初期インデックス
    );

    _calculateExposure();

    if (kDebugMode) {
      print('\n===Loaded Maps===\n'
          'Aperture            : ${_apertureMap.keys}\n'
          'Shutter Speeds      : ${_shutterMap.keys}\n'
          'ISO                 : ${_isoMap.keys}\n\n'
          '===Aperture===\n'
          'Third and Half Stops: ${generateThirdAndHalfStopApertureMap().keys}\n'
          'Third Stops         : ${generateThirdStopApertureMap().keys}\n'
          'Half Stops          : ${generateHalfStopApertureMap().keys}\n'
          'Only Full Stops     : ${generateFullStopApertureMap().keys}\n\n'
          '===Shutter Speeds===\n'
          'Third and Half Stops: ${generateThirdAndHalfStopShutterMap().keys}\n'
          'Third Stops         : ${generateThirdStopShutterMap().keys}\n'
          'Half Stops          : ${generateHalfStopShutterMap().keys}\n'
          'Only Full Stops     : ${generateFullStopShutterMap().keys}\n\n'
          '===ISO===\n'
          'Third and Half Stops: ${generateThirdAndHalfStopISOMap().keys}\n'
          'Third Stops         : ${generateThirdStopISOMap().keys}\n'
          'Half Stops          : ${generateHalfStopISOMap().keys}\n'
          'Only Full Stops     : ${generateFullStopISOMap().keys}\n\n'
          '===ND Filter===\n'
          'ND Filter           : $_ndFilterMap\n\n'
          '===Base Values===\n'
          'Aperture            : F${_apertureMap.keys.toList()[f1Index]}\n'
          'SS                  : ${_shutterMap.keys.toList()[ss1Index]}\n'
          'ISO                 : ${_isoMap.keys.toList()[iso100Index]}\n\n'
          '===Default Values===\n'
          'Current Aperture    : F${_apertureMap.keys.toList()[defaultCurrentApertureIndex]}\n'
          'Current Shutter     : ${_shutterMap.keys.toList()[defaultCurrentShutterIndex]}\n'
          'Current ISO         : ${_isoMap.keys.toList()[defaultCurrentISOIndex]}\n'
          'New Aperture        : F${_apertureMap.keys.toList()[defaultNewApertureIndex]}\n'
          'New ISO             : ${_isoMap.keys.toList()[defaultNewISOIndex]}\n'
          'ND Filter           : ${_ndFilterMap.keys.toList()[defaultNDIndex]}\n');
    }
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
    double apertureStop = log2((newApertureValue / currentApertureValue) * (newApertureValue / currentApertureValue));

    // ISO のストップ差: stop = log2(OldISO / NewISO)
    double currentISOValue = _isoMap[currentISOKey]!;
    double newISOValue = _isoMap[newISOKey]!;
    double isoStop = log2(currentISOValue / newISOValue);

    // ND フィルターの stop
    double ndStop = _ndFilterMap[selectedNdFilterKey]!;

    // 合計ストップ
    double totalStop = apertureStop + isoStop + ndStop;

    // 新シャッター速度 = 現在のシャッター速度 * 2^(totalStop)
    double newShutterSec = currentShutterSec * pow2(totalStop);

    setState(() {
      calculatedShutterSeconds = newShutterSec;
    });
  }

  @override
  void dispose() {
    _currentAperturePageController.dispose();
    _currentShutterPageController.dispose();
    _currentISOPageController.dispose();
    _newAperturePageController.dispose();
    _newISOPageController.dispose();
    _ndFilterPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exposure Calculator'),
      ),
      body: SafeArea(
        child: Column(
          // Current と New Exposure 全体
          children: [
            Spacer(),
            const Text(
              'Current Exposure',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 4,
                children: [
                  // Current Aperture
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Aperture',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ), // Title
                  Row(
                    children: [
                      Expanded(
                        child: HorizontalScrollSelector(
                          pageController: _currentAperturePageController,
                          map: _apertureMap,
                          selectedIndex: _selectedCurrentApertureMapIndex,
                          onPageChanged: (index) {
                            if (_isUpdatingCurrentFromNew) return;
                            setState(() {
                              _isUpdatingNewFromCurrent = true;
                              _selectedCurrentApertureMapIndex = index;
                              currentApertureKey = _apertureMap.keys.toList()[index];
                              if (isApertureSyncEnabled) {
                                newApertureKey = currentApertureKey;
                                _selectedNewApertureMapIndex = index;
                                _newAperturePageController.jumpToPage(_selectedNewApertureMapIndex);
                              }
                              _isUpdatingNewFromCurrent = false;
                            });
                            _calculateExposure();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.only(left: 8),
                          icon: Icon(
                            size: 24,
                            isApertureSyncEnabled ? Icons.sync : Icons.sync_disabled,
                            color: isApertureSyncEnabled ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isApertureSyncEnabled = !isApertureSyncEnabled; // 状態をトグル
                              if (isApertureSyncEnabled) {
                                newApertureKey = currentApertureKey; // 同期状態で初期化
                                _selectedNewApertureMapIndex = _selectedCurrentApertureMapIndex; // 選択インデックスを同期
                                _newAperturePageController.jumpToPage(_selectedNewApertureMapIndex); // PageController を同期
                                _calculateExposure();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ), // HorizontalScrollSelector と同期ボタン
                  SizedBox(height: 12),
                  // Current Shutter Seconds
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Shutter',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ), // Title
                  Row(
                    children: [
                      Expanded(
                        child: HorizontalScrollSelector(
                          pageController: _currentShutterPageController,
                          map: _shutterMap,
                          selectedIndex: _selectedCurrentShutterMapIndex,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedCurrentShutterMapIndex = index;
                              currentShutterKey = _shutterMap.keys.toList()[index];
                            });
                            _calculateExposure();
                          },
                        ),
                      ),
                      SizedBox(width: 24, height: 24),
                    ],
                  ), // HorizontalScrollSelector とSizedBox
                  SizedBox(height: 12),
                  // Current ISO
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'ISO',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ), // Title
                  Row(
                    children: [
                      Expanded(
                        child: HorizontalScrollSelector(
                          pageController: _currentISOPageController,
                          map: _isoMap,
                          selectedIndex: _selectedCurrentISOMapIndex,
                          onPageChanged: (index) {
                            if (_isUpdatingCurrentFromNew) return;
                            setState(() {
                              _isUpdatingNewFromCurrent = true;
                              _selectedCurrentISOMapIndex = index;
                              currentISOKey = _isoMap.keys.toList()[index];
                              if (isISOSyncEnabled) {
                                newISOKey = currentISOKey;
                                _selectedNewISOMapIndex = index;
                                _newISOPageController.jumpToPage(_selectedNewISOMapIndex);
                              }
                              _isUpdatingNewFromCurrent = false;
                            });
                            _calculateExposure();
                          },
                        ),
                      ),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: IconButton(
                          padding: EdgeInsets.only(left: 8),
                          icon: Icon(
                            isISOSyncEnabled ? Icons.sync : Icons.sync_disabled,
                            color: isISOSyncEnabled ? Colors.blue : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              isISOSyncEnabled = !isISOSyncEnabled; // 状態をトグル
                              if (isISOSyncEnabled) {
                                newISOKey = currentISOKey; // 同期状態で初期化
                                _selectedNewISOMapIndex = _selectedCurrentISOMapIndex; // 選択インデックスを同期
                                _newISOPageController.jumpToPage(_selectedNewISOMapIndex); // PageController を同期
                                _calculateExposure();
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ), // HorizontalScrollSelector と同期ボタン
                ],
              ),
            ),
            const Spacer(),
            const Text(
              'New Exposure',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 4,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Aperture',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: HorizontalScrollSelector(
                          pageController: _newAperturePageController,
                          map: _apertureMap,
                          selectedIndex: _selectedNewApertureMapIndex,
                          onPageChanged: (index) {
                            if (_isUpdatingNewFromCurrent) return;
                            setState(() {
                              _isUpdatingCurrentFromNew = true;
                              _selectedNewApertureMapIndex = index;
                              newApertureKey = _apertureMap.keys.toList()[index];
                              if (isApertureSyncEnabled) {
                                currentApertureKey = newApertureKey;
                                _selectedCurrentApertureMapIndex = index;
                                _currentAperturePageController.jumpToPage(_selectedCurrentApertureMapIndex);
                              }
                              _isUpdatingCurrentFromNew = false;
                            });
                            _calculateExposure();
                          },
                        ),
                      ),
                      SizedBox(width: 24, height: 24),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'ISO',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: HorizontalScrollSelector(
                          pageController: _newISOPageController,
                          map: _isoMap,
                          selectedIndex: _selectedNewISOMapIndex,
                          onPageChanged: (index) {
                            if (_isUpdatingNewFromCurrent) return;
                            setState(() {
                              _isUpdatingCurrentFromNew = true;
                              _selectedNewISOMapIndex = index;
                              newISOKey = _isoMap.keys.toList()[index];
                              if (isISOSyncEnabled) {
                                currentISOKey = newISOKey;
                                _selectedCurrentISOMapIndex = index;
                                _currentISOPageController.jumpToPage(_selectedCurrentISOMapIndex);
                              }
                              _isUpdatingCurrentFromNew = false;
                            });
                            _calculateExposure();
                          },
                        ),
                      ),
                      SizedBox(width: 24, height: 24),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'ND Filter',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: HorizontalScrollSelector(
                          pageController: _ndFilterPageController,
                          map: _ndFilterMap,
                          selectedIndex: _selectedNDFilterMapIndex,
                          onPageChanged: (index) {
                            setState(() {
                              _selectedNDFilterMapIndex = index;
                              selectedNdFilterKey = _ndFilterMap.keys.toList()[index];
                            });
                            _calculateExposure();
                          },
                        ),
                      ),
                      SizedBox(width: 24, height: 24),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            // 結果表示
            Text(
              'Shutter Speed: ${formatSeconds(_shutterMap, calculatedShutterSeconds)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
