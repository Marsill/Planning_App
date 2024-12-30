import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String input = '';
  String result = '0';
  bool isScientificMode = false;

  void buttonPressed(String value) {
    setState(() {
      if (value == 'C') {
        input = '';
        result = '0';
      } else if (value == '=') {
        try {
          result = evaluateExpression(input);
        } catch (e) {
          result = 'Error';
        }
      } else {
        input += value;
      }
    });
  }

  String evaluateExpression(String expression) {
    try {
      if (expression.contains('sin')) {
        return sin(_parseFunctionArgument(expression, 'sin')).toString();
      } else if (expression.contains('cos')) {
        return cos(_parseFunctionArgument(expression, 'cos')).toString();
      } else if (expression.contains('tan')) {
        return tan(_parseFunctionArgument(expression, 'tan')).toString();
      } else if (expression.contains('log')) {
        return log(_parseFunctionArgument(expression, 'log')).toString();
      } else if (expression.contains('√')) {
        return sqrt(_parseFunctionArgument(expression, '√')).toString();
      } else if (expression.contains('^')) {
        var parts = expression.split('^');
        return pow(double.parse(parts[0]), double.parse(parts[1])).toString();
      } else {
        return _evaluateBasicExpression(expression).toString();
      }
    } catch (e) {
      return 'Error';
    }
  }

  double _parseFunctionArgument(String expression, String function) {
    String arg = expression.replaceAll(function, '').replaceAll('(', '').replaceAll(')', '');
    return double.parse(arg) * (pi / 180); // Convert to radians if necessary
  }

  double _evaluateBasicExpression(String expression) {
    double finalResult = 0;
    double currentNumber = 0;
    String currentOperator = '+';

    for (int i = 0; i < expression.length; i++) {
      String char = expression[i];

      if ('0123456789.'.contains(char)) {
        currentNumber = currentNumber * 10 + double.parse(char);
      } else {
        switch (currentOperator) {
          case '+':
            finalResult += currentNumber;
            break;
          case '-':
            finalResult -= currentNumber;
            break;
          case '*':
            finalResult *= currentNumber;
            break;
          case '/':
            finalResult /= currentNumber;
            break;
        }

        currentOperator = char;
        currentNumber = 0;
      }
    }

    switch (currentOperator) {
      case '+':
        finalResult += currentNumber;
        break;
      case '-':
        finalResult -= currentNumber;
        break;
      case '*':
        finalResult *= currentNumber;
        break;
      case '/':
        finalResult /= currentNumber;
        break;
    }

    return finalResult;
  }

  Widget buildButton(String text, Color textColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            backgroundColor: Colors.grey, // Gray background for the buttons
            padding: EdgeInsets.all(2),
          ),
          onPressed: () => buttonPressed(text),
          child: Text(
            text,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor), // Blue text color
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculator'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Scientific Mode'),
              onTap: () {
                setState(() {
                  isScientificMode = !isScientificMode;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Input display
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isScientificMode ? 10 : 20,
              horizontal: 20,
            ),
            alignment: Alignment.centerRight,
            child: Text(
              input,
              style: TextStyle(
                fontSize: isScientificMode ? 25 : 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Result display
          Container(
            padding: EdgeInsets.symmetric(
              vertical: isScientificMode ? 10 : 20,
              horizontal: 20,
            ),
            alignment: Alignment.centerRight,
            child: Text(
              result,
              style: TextStyle(
                fontSize: isScientificMode ? 30 : 40,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),

          Expanded(child: Divider()),

          Column(
            children: [
              Row(
                children: [
                  buildButton('7', Colors.blue),
                  buildButton('8', Colors.blue),
                  buildButton('9', Colors.blue),
                  buildButton('/', Colors.blue),
                ],
              ),
              Row(
                children: [
                  buildButton('4', Colors.blue),
                  buildButton('5', Colors.blue),
                  buildButton('6', Colors.blue),
                  buildButton('*', Colors.blue),
                ],
              ),
              Row(
                children: [
                  buildButton('1', Colors.blue),
                  buildButton('2', Colors.blue),
                  buildButton('3', Colors.blue),
                  buildButton('-', Colors.blue),
                ],
              ),
              Row(
                children: [
                  buildButton('C', Colors.blue),
                  buildButton('0', Colors.blue),
                  buildButton('=', Colors.blue),
                  buildButton('+', Colors.blue),
                ],
              ),
              if (isScientificMode)
                Column(
                  children: [
                    Row(
                      children: [
                        buildButton('sin', Colors.blue),
                        buildButton('cos', Colors.blue),
                        buildButton('tan', Colors.blue),
                        buildButton('log', Colors.blue),
                      ],
                    ),
                    Row(
                      children: [
                        buildButton('√', Colors.blue),
                        buildButton('π', Colors.blue),
                        buildButton('^', Colors.blue),
                      ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}