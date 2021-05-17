import 'package:flutter/widgets.dart';
import 'package:data/type.dart';
import 'package:data/vector.dart';
import 'package:data/polynomial.dart';
import 'package:extended_math/extended_math.dart' as math;
import 'package:formant_extractor/dsp_tools/window.dart';
import 'package:formant_extractor/dsp_tools/lpc.dart';
import 'package:formant_extractor/dsp_tools/convert.dart';

//Example:
//Speech speech = Speech(signal, samplingRate: Fs);
//speech.init();
//speech.formants;

class Speech {
  Speech(@required this.signal, {@required this.samplingRate});

  Vector<double> signal;
  double samplingRate;

  List<double> _formantList = [];
  List<Complex> roots;
  LPC lpc;
  Polynomial<double> polynom;
  List<double> frqs;
  List<double> bandwidths;

  //analytical method to find formants
  void init() {
    Vector<double> sigHann = Window.hanningApply(signal);

    //Get roots of the coefficients
    lpc = LPC(sigHann, order: 32);
    polynom =
        Polynomial<double>.fromCoefficients(DataType.float64, lpc.coefficients);
    roots = polynom.roots;

    //Filter the roots to positive imaginary values
    roots = roots.where((element) => element.imaginary >= 0).toList();

    //Get angles of roots and convert to frequencies
    frqs = roots
        .map((element) =>
            math.atan2(element.imaginary, element.real) *
            (samplingRate / (2 * math.pi)))
        .toList();
    frqs.sort();

    //bandwidth is distance from origin
    bandwidths = roots
        .map((element) =>
            -1 /
            2 *
            (samplingRate / (2 * math.pi)) *
            math.log(Convert.absComplex(element)))
        .toList();

    for (int k = 0; k < frqs.length; k++) {
      if (frqs[k] > 90 && frqs[k] < 5000 && bandwidths[k] < 400) {
        _formantList.add(frqs[k]);
      }
    }
  }

  List<double> get formants {
    return _formantList;
  }
}
