import 'package:data/vector.dart';
import 'package:formant_extractor/dsp_tools/window.dart';
import 'package:data/type.dart';
import 'package:list_ext/list_ext.dart';

class Lips {
  Lips(this.signal);

  Vector<double> signal;
  double _coef;

  double get coefficient {
    _solve();
    return _coef;
  }

  void _solve() {
    Vector<double> s = Window.epsilonPad(signal, before: 0, after: 1);
    Vector<double> d = Window.epsilonPad(signal, before: 1, after: 0);

    Vector<double> s3 = s.mul(s).mul(s);
    Vector<double> s4 = s3.mul(s);
    Vector<double> d2 = d.mul(d);

    double numerator = s4.div(d2).sum;
    double denominator = s3.div(d).sum;

    _coef = numerator / denominator;
  }
}
