import 'package:flutter/widgets.dart';
import 'package:data/type.dart';
import 'package:data/vector.dart';
import 'package:data/polynomial.dart';
import 'package:extended_math/extended_math.dart' as math;
import 'package:formant_extractor/dsp_tools/lips.dart';
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
  late List<Complex> _roots;
  late LPC _lpc;
  late Polynomial<double> _polynom;
  late List<double> _frqs;
  late Map<int, double> _idx2frqs;
  late Map<double, int> _frqs2idx;
  late List<double> _bandwidths;

  double _lipCoeff;

  //TODO: break this up into different formants and lip functions
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
    _frqs = _roots
        .map((element) =>
            math.atan2(element.imaginary, element.real) *
            (samplingRate / (2 * math.pi)))
        .toList();
    //to keep track of which roots freq is associated after sorting
    _idx2frqs = _frqs.asMap();
    _frqs2idx = {
      for (var i = 0; i < _frqs.length; i++)
        _idx2frqs[i]!: _idx2frqs.keys.toList()[i]
    };
    _frqs.sort();

    //bandwidth is distance from origin
    //for each sorted freq, get the bandwidth of the associated root
    _bandwidths = _frqs
        .map((f) =>
            -1 /
            2 *
            (samplingRate / (2 * math.pi)) *
            math.log(Convert.absComplex(_roots[_frqs2idx[f]!])))
        .toList();

    for (int k = 0; k < frqs.length; k++) {
      if (frqs[k] > 90 && frqs[k] < 5000 && bandwidths[k] < 400) {
        _formantList.add(frqs[k]);
      }
    }

    //Get Lip Coefficient

    Lips lips = Lips(signal);
    _lipCoeff = lips.coefficient;
  }

  List<double> get formants {
    return _formantList;
  }

  double get lipCoefficient {
    return _lipCoeff;
  }
}
