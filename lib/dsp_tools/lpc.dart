import 'package:flutter/cupertino.dart';
import 'package:data/vector.dart';
import 'package:data/matrix.dart';
import 'package:data/type.dart';
import 'window.dart';

//Example:
//LPC lpc = LPC(signal, order);
//lpc.getCoefficients;

class LPC {
  LPC(@required this.signal, {@required this.order});

  final Vector<double> signal;
  final int order;
  List<double> coeffs;
  List<double> autocorrelations = []; //index is equal to the lag

  List<double> get coefficients {
    _solveMatrix();
    return coeffs;
  }

  void _solveMatrix() {
    //populate autocorrelations with autocorrelation values for different lags
    for (int i = 0; i <= order; i++) {
      double value = Window.autocorrelation(signal, lag: i);
      autocorrelations.add(value);
    }

    //create the autocorrelation square matrix
    Matrix<double> autocorrMatrix = Matrix<double>.generate(
        DataType.float64,
        order,
        order,
        (j, k) => autocorrelations[((k + 1) - (j + 1)).abs()]); //R(|j-k|)

    //create a column vector
    //the column vector, c, in the equation M * a = c
    Matrix<double> equalsColVector = Vector<double>.generate(
            DataType.float64, order, (j) => autocorrelations[j + 1])
        .columnMatrix; //R(|j|)

    //the column vector, a, in the equation M * a = c
    Matrix<double> a = Matrix<double>(DataType.float64, order, 0);

    a = autocorrMatrix.solve(equalsColVector);
    a = a.mulScalar(-1);
    coeffs = [1.0] + [for (int i = 0; i < order; i++) a.getUnchecked(i, 0)];
  }
}
