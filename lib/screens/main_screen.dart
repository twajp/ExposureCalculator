import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/math_helper.dart';
import '../utils/constants.dart';
import '../utils/map_generator.dart';
import '../widgets/exposure_row.dart';
import '../widgets/exposure_result.dart';

// Define SharedPreferences keys
const String keyCurrentAperture = 'currentAperture';
const String keyCurrentShutter = 'currentShutter';
const String keyCurrentISO = 'currentISO';
const String keyNewAperture = 'newAperture';
const String keyNewISO = 'newISO';
const String keySelectedNdFilter = 'selectedNdFilter';
const String keyIsApertureSyncEnabled = 'isApertureSyncEnabled';
const String keyIsISOSyncEnabled = 'isISOSyncEnabled';

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

  late String currentApertureKey;
  late String currentShutterKey;
  late String currentISOKey;
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

  // SharedPreferences instance
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _apertureMap = generateThirdStopApertureMap();
    _shutterMap = generateThirdStopShutterMap();
    _isoMap = generateThirdStopISOMap();
    _ndFilterMap = generateNDFilterMap();

    // Initialize default values
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
    _currentAperturePageController = PageController(viewportFraction: 0.3, initialPage: _selectedCurrentApertureMapIndex);
    _currentShutterPageController = PageController(viewportFraction: 0.3, initialPage: _selectedCurrentShutterMapIndex);
    _currentISOPageController = PageController(viewportFraction: 0.3, initialPage: _selectedCurrentISOMapIndex);
    _newAperturePageController = PageController(viewportFraction: 0.3, initialPage: _selectedNewApertureMapIndex);
    _newISOPageController = PageController(viewportFraction: 0.3, initialPage: _selectedNewISOMapIndex);
    _ndFilterPageController = PageController(viewportFraction: 0.3, initialPage: _selectedNDFilterMapIndex);

    // Initialize SharedPreferences and load saved state
    _initializePreferences();

    if (kDebugMode) {
      print('===Loaded Maps===\n'
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

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();

    // Load saved keys or use defaults
    currentApertureKey = _prefs.getString(keyCurrentAperture) ?? _apertureMap.keys.toList()[defaultCurrentApertureIndex];
    currentShutterKey = _prefs.getString(keyCurrentShutter) ?? _shutterMap.keys.toList()[defaultCurrentShutterIndex];
    currentISOKey = _prefs.getString(keyCurrentISO) ?? _isoMap.keys.toList()[defaultCurrentISOIndex];
    newApertureKey = _prefs.getString(keyNewAperture) ?? _apertureMap.keys.toList()[defaultNewApertureIndex];
    newISOKey = _prefs.getString(keyNewISO) ?? _isoMap.keys.toList()[defaultNewISOIndex];
    selectedNdFilterKey = _prefs.getString(keySelectedNdFilter) ?? _ndFilterMap.keys.toList()[defaultNDIndex];
    isApertureSyncEnabled = _prefs.getBool(keyIsApertureSyncEnabled) ?? false;
    isISOSyncEnabled = _prefs.getBool(keyIsISOSyncEnabled) ?? false;

    // Update selected indices based on loaded keys
    _selectedCurrentApertureMapIndex = _apertureMap.keys.toList().indexOf(currentApertureKey);
    _selectedCurrentShutterMapIndex = _shutterMap.keys.toList().indexOf(currentShutterKey);
    _selectedCurrentISOMapIndex = _isoMap.keys.toList().indexOf(currentISOKey);
    _selectedNewApertureMapIndex = _apertureMap.keys.toList().indexOf(newApertureKey);
    _selectedNewISOMapIndex = _isoMap.keys.toList().indexOf(newISOKey);
    _selectedNDFilterMapIndex = _ndFilterMap.keys.toList().indexOf(selectedNdFilterKey);

    // Update PageControllers after loading preferences
    _currentAperturePageController.jumpToPage(_selectedCurrentApertureMapIndex);
    _currentShutterPageController.jumpToPage(_selectedCurrentShutterMapIndex);
    _currentISOPageController.jumpToPage(_selectedCurrentISOMapIndex);
    _newAperturePageController.jumpToPage(_selectedNewApertureMapIndex);
    _newISOPageController.jumpToPage(_selectedNewISOMapIndex);
    _ndFilterPageController.jumpToPage(_selectedNDFilterMapIndex);

    // Calculate exposure with loaded settings
    _calculateExposure();

    // For debugging purposes
    if (kDebugMode) {
      print('Loaded preferences successfully.');
    }

    setState(() {}); // Update UI with loaded preferences
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
          children: [
            Spacer(),
            // Current Exposure Section
            const Text(
              'Current Exposure',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ExposureRow(
                    label: 'Aperture',
                    pageController: _currentAperturePageController,
                    map: _apertureMap,
                    selectedIndex: _selectedCurrentApertureMapIndex,
                    onPageChanged: (index) async {
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

                      // Save to SharedPreferences
                      await _prefs.setString(keyCurrentAperture, currentApertureKey);
                      if (isApertureSyncEnabled) {
                        await _prefs.setString(keyNewAperture, newApertureKey);
                      }
                    },
                    showSyncButton: true,
                    isSyncEnabled: isApertureSyncEnabled,
                    onSyncToggle: () async {
                      setState(() {
                        isApertureSyncEnabled = !isApertureSyncEnabled;
                        if (isApertureSyncEnabled) {
                          newApertureKey = currentApertureKey;
                          _selectedNewApertureMapIndex = _selectedCurrentApertureMapIndex;
                          _newAperturePageController.jumpToPage(_selectedNewApertureMapIndex);
                          _calculateExposure();
                        }
                      });

                      // Save sync state and possibly new aperture key
                      await _prefs.setBool(keyIsApertureSyncEnabled, isApertureSyncEnabled);
                      if (isApertureSyncEnabled) {
                        await _prefs.setString(keyNewAperture, newApertureKey);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ExposureRow(
                    label: 'Shutter',
                    pageController: _currentShutterPageController,
                    map: _shutterMap,
                    selectedIndex: _selectedCurrentShutterMapIndex,
                    onPageChanged: (index) async {
                      setState(() {
                        _selectedCurrentShutterMapIndex = index;
                        currentShutterKey = _shutterMap.keys.toList()[index];
                      });
                      _calculateExposure();

                      // Save to SharedPreferences
                      await _prefs.setString(keyCurrentShutter, currentShutterKey);
                    },
                    showSyncButton: false,
                  ),
                  const SizedBox(height: 12),
                  ExposureRow(
                    label: 'ISO',
                    pageController: _currentISOPageController,
                    map: _isoMap,
                    selectedIndex: _selectedCurrentISOMapIndex,
                    onPageChanged: (index) async {
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

                      // Save to SharedPreferences
                      await _prefs.setString(keyCurrentISO, currentISOKey);
                      if (isISOSyncEnabled) {
                        await _prefs.setString(keyNewISO, newISOKey);
                      }
                    },
                    showSyncButton: true,
                    isSyncEnabled: isISOSyncEnabled,
                    onSyncToggle: () async {
                      setState(() {
                        isISOSyncEnabled = !isISOSyncEnabled;
                        if (isISOSyncEnabled) {
                          newISOKey = currentISOKey;
                          _selectedNewISOMapIndex = _selectedCurrentISOMapIndex;
                          _newISOPageController.jumpToPage(_selectedNewISOMapIndex);
                          _calculateExposure();
                        }
                      });

                      // Save sync state and possibly new ISO key
                      await _prefs.setBool(keyIsISOSyncEnabled, isISOSyncEnabled);
                      if (isISOSyncEnabled) {
                        await _prefs.setString(keyNewISO, newISOKey);
                      }
                    },
                  ),
                ],
              ),
            ),
            Spacer(),
            // New Exposure Section
            const Text(
              'New Exposure',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ExposureRow(
                    label: 'Aperture',
                    pageController: _newAperturePageController,
                    map: _apertureMap,
                    selectedIndex: _selectedNewApertureMapIndex,
                    onPageChanged: (index) async {
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

                      // Save to SharedPreferences
                      await _prefs.setString(keyNewAperture, newApertureKey);
                      if (isApertureSyncEnabled) {
                        await _prefs.setString(keyCurrentAperture, currentApertureKey);
                      }
                    },
                    showSyncButton: true,
                    isSyncEnabled: isApertureSyncEnabled,
                    onSyncToggle: () async {
                      setState(() {
                        isApertureSyncEnabled = !isApertureSyncEnabled;
                        if (isApertureSyncEnabled) {
                          currentApertureKey = newApertureKey;
                          _selectedCurrentApertureMapIndex = _selectedNewApertureMapIndex;
                          _currentAperturePageController.jumpToPage(_selectedCurrentApertureMapIndex);
                          _calculateExposure();
                        }
                      });

                      // Save sync state and possibly current aperture key
                      await _prefs.setBool(keyIsApertureSyncEnabled, isApertureSyncEnabled);
                      if (isApertureSyncEnabled) {
                        await _prefs.setString(keyCurrentAperture, currentApertureKey);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ExposureRow(
                    label: 'ISO',
                    pageController: _newISOPageController,
                    map: _isoMap,
                    selectedIndex: _selectedNewISOMapIndex,
                    onPageChanged: (index) async {
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

                      // Save to SharedPreferences
                      await _prefs.setString(keyNewISO, newISOKey);
                      if (isISOSyncEnabled) {
                        await _prefs.setString(keyCurrentISO, currentISOKey);
                      }
                    },
                    showSyncButton: true,
                    isSyncEnabled: isISOSyncEnabled,
                    onSyncToggle: () async {
                      setState(() {
                        isISOSyncEnabled = !isISOSyncEnabled;
                        if (isISOSyncEnabled) {
                          currentISOKey = newISOKey;
                          _selectedCurrentISOMapIndex = _selectedNewISOMapIndex;
                          _currentISOPageController.jumpToPage(_selectedCurrentISOMapIndex);
                          _calculateExposure();
                        }
                      });

                      // Save sync state and possibly current ISO key
                      await _prefs.setBool(keyIsISOSyncEnabled, isISOSyncEnabled);
                      if (isISOSyncEnabled) {
                        await _prefs.setString(keyCurrentISO, currentISOKey);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ExposureRow(
                    label: 'ND Filter',
                    pageController: _ndFilterPageController,
                    map: _ndFilterMap,
                    selectedIndex: _selectedNDFilterMapIndex,
                    onPageChanged: (index) async {
                      setState(() {
                        _selectedNDFilterMapIndex = index;
                        selectedNdFilterKey = _ndFilterMap.keys.toList()[index];
                      });
                      _calculateExposure();

                      // Save to SharedPreferences
                      await _prefs.setString(keySelectedNdFilter, selectedNdFilterKey);
                    },
                    showSyncButton: false,
                  ),
                ],
              ),
            ),
            Spacer(),
            SizedBox(
              height: 40,
              child: const Text(
                'Shutter Seconds',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ExposureResult(
              calculatedShutterSeconds: calculatedShutterSeconds,
              shutterMap: _shutterMap,
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
