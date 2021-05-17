import 'package:extended_math/extended_math.dart';
import 'package:flutter/cupertino.dart';
import 'package:data/type.dart' as data;

class Convert {
  //converts sample points into seconds
  static double indexToSec(
      {@required int timeIndex, @required double samplingRate}) {
    return timeIndex.toDouble() / samplingRate;
  }

  //This is 1:1 when sampling rate = signal length (including zero padding)
  static double indexToHz(
      {@required int freqIndex,
      @required int totalTimeDomainPoints,
      @required double samplingRate}) {
    double nyquist = samplingRate / 2.0;

    return freqIndex.toDouble() *
        nyquist /
        (totalTimeDomainPoints.toDouble() / 2.0);
  }

  //Be aware that this returns a double
  static double hzToIndex(
      {@required double hz,
      @required int totalTimeDomainPoints,
      @required double samplingRate}) {
    double nyquist = samplingRate / 2.0;

    return hz * (totalTimeDomainPoints.toDouble() / 2.0) / nyquist;
  }

  static List<double> ampToDb(List<double> signal) {
    List<double> newList =
        signal.map((element) => 20.0 * logFunc(10, element)).toList();
    return newList;
  }

  //converts herz to mel-scale
  static double hzToMel(double hz) {
    return 2595.0 * logFunc(10, 1.0 + hz / 700.0);
  }

  //converts mel-scale to hz
  static double melToHz(double mel) {
    return 700.0 * (pow(10.0, (mel / 2595.0)) - 1);
  }

  static double logFunc(int base, double x) {
    return log(x) / log(base.toDouble());
  }

  static List<double> invert(List<double> signal) {
    return signal.map((value) => 1.0 / value).toList();
  }

  static double absComplex(data.Complex complex) {
    return sqrt(pow(complex.real, 2) + pow(complex.imaginary, 2)).toDouble();
  }
}
