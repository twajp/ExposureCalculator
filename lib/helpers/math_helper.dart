import 'dart:math' as math;

/// 小数の log と exp を扱うためのヘルパークラス
class MathHelper {
  static double logE(double x) => x > 0 ? math.log(x) : double.nan;
  static double expE(double x) => math.exp(x);
}
