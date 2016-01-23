library slideruler;

import 'dart:html';
import 'dart:js';
import 'dart:math';
import 'dart:async';

part 'calc.dart';

ParagraphElement questionParagraph;
DivElement timerDiv;
InputElement solutionText;
InputElement submitButton;
InputElement fractionCheckbox;
InputElement powersCheckbox;
InputElement rootsCheckbox;
TableElement timesTable;
TableCellElement averageCell;
Random random;
Problem problem;
bool timerRunning;
num globalTimer;
num timer;
List<num> times;

void main() {
  questionParagraph = querySelector('#question');
  timerDiv = querySelector('#timer');
  solutionText = querySelector('#solution')..onKeyPress.listen(onSolutionKeyPress);
  submitButton = querySelector('#submit')..onClick.listen((e) => onSubmit());
  fractionCheckbox = querySelector('#fraction');
  powersCheckbox = querySelector('#powers');
  rootsCheckbox = querySelector('#roots');
  timesTable = querySelector('#times');
  averageCell = querySelector('#average-time');
  window.onKeyUp.listen(onKeyUp);
  random = new Random();
  timerRunning = false;
  times = new List<num>();
}

void generateProblem() {
  problem = new Problem.generate(5, 3, 2, fractionCheckbox.checked, powersCheckbox.checked, rootsCheckbox.checked);
  questionParagraph.innerHtml = problem.question;
  context['MathJax']['Hub'].callMethod('Typeset');
}

void startTimer() {
  timerRunning = true;
  window.requestAnimationFrame(timeLoop);
  solutionText.focus();
}

void timeLoop(num time) {
  if (timerRunning) {
    if (globalTimer == null) {
      globalTimer = time;
      timer = 0;
      window.requestAnimationFrame(timeLoop);
    } else {
      timer += (time - globalTimer);
      globalTimer = time;
      window.requestAnimationFrame(timeLoop);
    }
  }
  timerDiv.innerHtml = getTimeString(timer);
}

void stopTimer() {
  timerRunning = false;
  globalTimer = null;
}

String getTimeString(num millis) {
  int minutes = millis ~/ 60000;
  int seconds = millis ~/ 1000 - minutes * 60;
  int centis = millis ~/ 10 - seconds * 100 - minutes * 6000;
  return (minutes < 10 ? '0' : '') + minutes.toString() + ':' + (seconds < 10 ? '0' : '') + seconds.toString() + ':' + (centis < 10 ? '0' : '') + centis.toString();
}

void onSubmit() {
  if (timerRunning) {
    if (solutionText.value != '' && solutionText.checkValidity()) {
      num answer = num.parse(solutionText.value);
      if ((answer - problem.solution).abs() <= problem.errorMargin) {
        onCorrect();
      } else {
        onWrong();
      }
      print(
          'Error: ' + (((answer / problem.solution - 1) * 10000).round() / 100)
              .abs()
              .toString() + '%');
    } else {
      window.alert('Not a number');
      solutionText.value = '';
    }
  }
}

void onCorrect() {
  stopTimer();
  addTime(timer);
  solutionText.style.backgroundColor = '#0F0';
  new Timer(new Duration(seconds: 1), () => solutionText.style.backgroundColor = '#FFF');
  questionParagraph.innerHtml = 'Press [SPACE] to start';
}

void onWrong() {
  solutionText.style.backgroundColor = '#F00';
  new Timer(new Duration(seconds: 1), () => solutionText.style.backgroundColor = '#FFF');
}

void addTime(num time) {
  times.add(time);
  TableRowElement row = timesTable.insertRow(0);
  TableCellElement indexCell = row.insertCell(0);
  indexCell.className = 'time-index';
  indexCell.innerHtml = '#' + times.length.toString();
  TableCellElement timeCell = row.insertCell(1);
  timeCell.className = 'time';
  timeCell.innerHtml = getTimeString(time);
  num average = 0;
  for (int i = 0; i < times.length; i++) {
    average += times[i];
  }
  average /= times.length;
  averageCell.innerHtml = getTimeString(average);
}

void onSolutionKeyPress(KeyboardEvent event) {
  if (event.keyCode == KeyCode.ENTER) {
    onSubmit();
  }
}

void onKeyUp(KeyboardEvent event) {
  if (event.keyCode == KeyCode.SPACE) {
    if (!timerRunning) {
      generateProblem();
      solutionText.value = '';
      startTimer();
    }
  }
}