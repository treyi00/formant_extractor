import 'package:data/vector.dart';
import 'package:data/type.dart';
import 'package:extended_math/extended_math.dart' as math;

//Useful functions applied on speech sample windows

class Window {
  static double autocorrelation(Vector<double> sig, {int lag}) {
    //zero padding at the end of signal using Window.zeroPad(sig: sig, after: lag);
    Vector<double> paddedSig = Window.zeroPad(sig, after: lag);

    if (lag == 0) {
      return paddedSig.dot(paddedSig);
    } else if (lag != 0) {
      Vector<double> delayPaddedSig = Window.zeroPad(sig, before: lag);

      return paddedSig.dot(delayPaddedSig);
    }
  }

  //the hanning window used is not perfectly symmetrical
  static Vector<double> hanningApply(Vector<double> sig) {
    int sigLength = sig.count;
    double step = 1 / sigLength;

    //Uses the hanning window function  1 / 2 * (1 - cos(2 * pi * (timepoints)))
    //timepoints = index * step
    //index goes from 0 to sigLength - 1; which makes the function not perfect since start = 0, end =/= 0
    //does element-wise multiplication between the hanning window and the signal
    Vector<double> newSignal = Vector<double>.generate(
        DataType.float64,
        sigLength,
        (i) =>
            (1 / 2 * (1 - math.cos(2 * math.pi * (i * step)))) *
            sig.getUnchecked(i));

    return newSignal;
  }

  static Vector<double> zeroPad(Vector<double> sig,
      {int before = 0, int after = 0}) {
    Vector<double> zeroPadBefore =
        zeroes(before); //[for (int i = 0; i < before; i += 1) 0.0];
    Vector<double> zeroPadAfter =
        zeroes(after); //[for (int i = 0; i < after; i += 1) 0.0];

    if (before == 0 && after == 0) {
      return sig;
    } else if (before != 0 && after == 0) {
      return Vector.concat(DataType.float64, [zeroes(before), sig]);
    } else if (before == 0 && after != 0) {
      return Vector.concat(DataType.float64, [sig, zeroes(after)]);
    } else {
      return Vector.concat(
          DataType.float64, [zeroes(before), sig, zeroes(after)]);
    }
  }

  //pads the signal with a very small number that's close to zero but not quite
  static Vector<double> epsilonPad(Vector<double> sig,
      {int before = 0, int after = 0}) {
    Vector<double> epsilonPadBefore =
        epsilons(before); //[for (int i = 0; i < before; i += 1) 0.0];
    Vector<double> epsilonPadAfter =
        epsilons(after); //[for (int i = 0; i < after; i += 1) 0.0];

    if (before == 0 && after == 0) {
      return sig;
    } else if (before != 0 && after == 0) {
      return Vector.concat(DataType.float64, [epsilons(before), sig]);
    } else if (before == 0 && after != 0) {
      return Vector.concat(DataType.float64, [sig, epsilons(after)]);
    } else {
      return Vector.concat(
          DataType.float64, [epsilons(before), sig, epsilons(after)]);
    }
  }

  static Vector<double> zeroes(int n) {
    return Vector<double>.generate(DataType.float64, n, (i) => 0.0);
  }

  static Vector<double> epsilons(int n) {
    return Vector<double>.generate(
        DataType.float64, n, (i) => 4.94065645841247E-324);
  }

  static Vector<double> vectorize(List<double> signal) {
    Vector<double> vectorizedSignal = Vector<double>.generate(
        DataType.float64, signal.length, (i) => signal[i]);

    return vectorizedSignal;
  }
}
