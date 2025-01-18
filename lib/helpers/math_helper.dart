import 'dart:math' as math;

/// 小数の log と exp を扱うためのヘルパークラス
class MathHelper {
  static double logE(double x) => x > 0 ? math.log(x) : double.nan;
  static double expE(double x) => math.exp(x);
}

// 便利関数: log2(x)
double log2(double x) {
  return (x > 0) ? (MathHelper.logE(x) / MathHelper.logE(2)) : 0;
}

// 便利関数: 2^(x)
double pow2(double x) {
  return MathHelper.expE(MathHelper.logE(2) * x);
}
