import 'package:flutter/material.dart';
import '../utils/seconds_formatter.dart';

class ExposureResult extends StatelessWidget {
  final double calculatedShutterSeconds;
  final Map<String, double> shutterMap;

  const ExposureResult({
    super.key,
    required this.calculatedShutterSeconds,
    required this.shutterMap,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      formatSeconds(shutterMap, calculatedShutterSeconds),
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
