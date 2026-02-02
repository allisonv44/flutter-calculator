import 'package:flutter/material.dart';
import 'package:expressions/expressions.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator - Allison V',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = ''; // shows the ongoing calculation (accumulator)
  String _input = ''; // current compact input (used for evaluation)
  String _result = ''; // last result or error

  
  final _evaluator = const ExpressionEvaluator();

  void _append(String value) {
    setState(() {
      // handle operators so expression is human-readable
      if (_isOperator(value)) {
        if (_expression.isEmpty && value != '-') {
          // don't allow starting with an operator except minus
          return;
        }
        // if last char is operator, replace it (avoid duplicate operators)
        if (_expression.isNotEmpty && _isOperator(_expression.trim().split(' ').last)) {
          _expression = _expression.trimRight();
          // remove last operator token
          final parts = _expression.split(' ');
          parts.removeLast();
          _expression = parts.join(' ');
        }
        _expression = _expression.isEmpty ? value : '$_expression $value';
      } else {
        // number or dot
        if (_expression.isNotEmpty && !_isOperator(_expression.trim().split(' ').last)) {
          // append to last number without space
          _expression = '$_expression$value';
        } else {
          _expression = '$_expression$value';
        }
      }
      _input = _expression;
      _result = '';
    });
  }

  void _clearAll() {
    setState(() {
      _expression = '';
      _input = '';
      _result = '';
    });
  }

  void _backspace() {
    setState(() {
      if (_expression.isEmpty) return;
      _expression = _expression.substring(0, _expression.length - 1);
      _input = _expression;
      _result = '';
    });
  }

  void _evaluate() {
  setState(() {
    final sanitized = _sanitizeForEval(_input);
    if (sanitized.trim().isEmpty) return;

    try {
      final exp = Expression.parse(sanitized);
      final eval = _evaluator.eval(exp, {});

      if (eval is double) {
        if (eval.isInfinite || eval.isNaN) {
          _result = 'Error';
        } else if (eval == eval.roundToDouble()) {
          _result = eval.toInt().toString();
        } else {
          _result = eval.toString();
        }
      } else {
        _result = eval.toString();
      }

      _expression = _result;
      _input = _result;
    } catch (e) {
      _result = 'Error';
    }
  });
}


  String _sanitizeForEval(String s) {
    // Replace common symbols with programmatic ones
    return s.replaceAll('×', '*').replaceAll('÷', '/').replaceAll('×', '*');
  }

  bool _isOperator(String token) {
    const ops = ['+', '-', '×', '÷', '*', '/', '^'];
    return ops.contains(token);
  }

  Widget _buildButton(String label, {Color? color, double fontSize = 22, void Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: ElevatedButton(
        onPressed: onTap ?? () => _append(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.grey[850],
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Calculator - Allison V'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Display area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Calculator', style: theme.textTheme.labelLarge?.copyWith(color: Colors.grey[300])),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Accumulator (ongoing calculation)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          reverse: true,
                          child: Text(
                            _expression.isEmpty ? '0' : _expression,
                            style: const TextStyle(fontSize: 20, color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Result
                        Text(
                          _result.isEmpty ? '' : '= $_result',
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Buttons grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('C', color: Colors.redAccent, onTap: _clearAll)),
                          Expanded(child: _buildButton('⌫', color: Colors.orangeAccent, onTap: _backspace)),
                          Expanded(child: _buildButton('(', color: Colors.blueGrey)),
                          Expanded(child: _buildButton(')', color: Colors.blueGrey)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('7')),
                          Expanded(child: _buildButton('8')),
                          Expanded(child: _buildButton('9')),
                          Expanded(child: _buildButton('÷', color: Colors.deepPurpleAccent)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('4')),
                          Expanded(child: _buildButton('5')),
                          Expanded(child: _buildButton('6')),
                          Expanded(child: _buildButton('×', color: Colors.deepPurpleAccent)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('1')),
                          Expanded(child: _buildButton('2')),
                          Expanded(child: _buildButton('3')),
                          Expanded(child: _buildButton('-', color: Colors.deepPurpleAccent)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: _buildButton('0')),
                          Expanded(child: _buildButton('.')),
                          Expanded(child: _buildButton('%', color: Colors.blueGrey, onTap: () => _append('/100'))),
                          Expanded(child: _buildButton('+', color: Colors.deepPurpleAccent)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 76,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ElevatedButton(
                                onPressed: _evaluate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent[700],
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('=', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(6.0),
                              child: ElevatedButton(
                                onPressed: () => setState(() {
                                  // toggle sign for the last number
                                  _toggleSign();
                                }),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueGrey,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('+/-', style: TextStyle(fontSize: 20)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _toggleSign() {
    // flip the sign of the last number in the expression
    if (_expression.isEmpty) return;
    // find last number token
    final regex = RegExp(r'(-?\d*\.?\d+)\$');
    final match = regex.firstMatch(_expression);
    if (match != null) {
      final numStr = match.group(1)!;
      if (numStr.startsWith('-')) {
        _expression = _expression.substring(0, match.start) + numStr.substring(1);
      } else {
        _expression = _expression.substring(0, match.start) + '-$numStr';
      }
      _input = _expression;
    }
  }
}
