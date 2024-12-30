import 'dart:math';
import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scientific Calculator',
      home: ScientificCalculator(),
    );
  }
}

class ScientificCalculator extends StatefulWidget {
  @override
  _ScientificCalculatorState createState() => _ScientificCalculatorState();
}

class _ScientificCalculatorState extends State<ScientificCalculator> {
  String _expression = ''; // Stores the mathematical expression
  String _displayText = '0'; // Text displayed on the calculator screen
  bool _showScientificButtons = false; // Toggle scientific buttons visibility

  // Handle button press events
  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'AC') {
        _expression = '';
        _displayText = '0';
      } else if (value == 'DEL') {
        _expression = _expression.isNotEmpty
            ? _expression.substring(0, _expression.length - 1)
            : '';
        _displayText = _expression.isEmpty ? '0' : _expression;
      } else if (value == '=') {
        _evaluateExpression();
      } else {
        if (_displayText == '0' && value != '.') _expression = '';
        _expression += value;
        _displayText = _expression;
      }
    });
  }

  // Evaluate the expression using math_expressions library
  void _evaluateExpression() {
    try {
      final exp = _expression.replaceAll('×', '*').replaceAll('÷', '/');
      Parser p = Parser();
      Expression expression = p.parse(exp);
      ContextModel cm = ContextModel();

      double result = expression.evaluate(EvaluationType.REAL, cm);
      setState(() {
        _displayText = result.toString();
        _expression = result.toString();
      });
    } catch (e) {
      setState(() {
        _displayText = 'Error';
      });
    }
  }

  // Button widget
  Widget _calcButton(String text,
      {Color color = Colors.grey, Color textColor = Colors.white}) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: textColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Display
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Text(
                _displayText,
                style: TextStyle(fontSize: 50, color: Colors.white),
              ),
            ),
          ),

          // Toggle Scientific Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: Colors.white, size: 30),
                onPressed: () {
                  setState(() {
                    _showScientificButtons = !_showScientificButtons;
                  });
                },
              ),
            ],
          ),

          // Standard Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calcButton('AC', color: Colors.grey),
              _calcButton('DEL', color: Colors.grey),
              _calcButton('%', color: Colors.grey),
              _calcButton('÷', color: Colors.orange),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calcButton('7'),
              _calcButton('8'),
              _calcButton('9'),
              _calcButton('×', color: Colors.orange),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calcButton('4'),
              _calcButton('5'),
              _calcButton('6'),
              _calcButton('-', color: Colors.orange),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _calcButton('1'),
              _calcButton('2'),
              _calcButton('3'),
              _calcButton('+', color: Colors.orange),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _onButtonPressed('0'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: Text('0',
                      style: TextStyle(fontSize: 20, color: Colors.white)),
                ),
              ),
              _calcButton('.', color: Colors.grey),
              _calcButton('=', color: Colors.orange),
            ],
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
