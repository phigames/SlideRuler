part of slideruler;

class Problem {

  String question;
  num solution;
  num errorMargin;

  Problem.generate(int operandNumber, int figures, int magnitudeCap, bool fraction, bool powers, bool squareRoots) {
    if (fraction) {
      question = '\\[\\frac{x}{y}\\]';
    } else {
      question = '\\[x\\]';
    }
    solution = 1;
    List<Factor> factors = new List<Factor>();
    int multipliers = 0;
    int dividers = 0;
    for (int i = 0; i < operandNumber; i++) {
      factors.add(new Factor.generate(figures, magnitudeCap, fraction, powers, squareRoots));
      if (factors[i].inverse) {
        question = question.replaceFirst('y', factors[i].getTeX(figures) + '\\timesy');
        dividers++;
      } else {
        question = question.replaceFirst('x', factors[i].getTeX(figures) + '\\timesx');
        multipliers++;
      }
      solution *= factors[i].getValue();
    }
    if (multipliers > 0) {
      question = question.replaceFirst('\\timesx', '');
    } else {
      question = question.replaceFirst('x', '1');
    }
    if (fraction) {
      if (dividers > 0) {
        question = question.replaceFirst('\\timesy', '');
      } else {
        question = question.replaceFirst('y', '1');
      }
    }
    errorMargin = solution * 0.05;
    print(solution);
  }

}

class Factor {

  num number;
  bool inverse;
  int power;
  bool squareRoot;

  Factor.generate(int figures, int magnitudeCap, bool fraction, bool powers, bool squareRoots) {
    int r = random.nextInt(pow(10, figures) - 1) + 1;
    num m = (log(r) / log(10)).ceil() - 1 + random.nextInt(magnitudeCap + 1) * (random.nextInt(2) * 2 - 1);
    number = r / pow(10, m);
    inverse = fraction && random.nextInt(2) == 0;
    if (powers && random.nextInt(3) == 0) {
      power = random.nextInt(2) + 2;
    } else {
      power = 1;
    }
    squareRoot = squareRoots && power != 2 && random.nextInt(5) == 0;
  }

  num getValue() {
    num value = number;
    if (inverse) {
      value = 1 / value;
    }
    if (power != 1) {
      value = pow(value, power);
    }
    if (squareRoot) {
      value = sqrt(value);
    }
    return value;
  }

  String getTeX(int precision) {
    String tex = number.toStringAsPrecision(precision);
    if (power != 1) {
      tex += '^' + power.toString();
    }
    if (squareRoot) {
      tex = '\\sqrt{' + tex + '}';
    }
    return tex;
  }

}

enum Operation {

  fraction,
  powers,
  squareRoots

}