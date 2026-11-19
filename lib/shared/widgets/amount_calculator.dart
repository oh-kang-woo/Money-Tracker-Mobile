import 'package:flutter/material.dart';
import '../../app/config/app_colors.dart';

class AmountCalculator extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onResultChanged;

  const AmountCalculator({
    super.key,
    required this.initialValue,
    required this.onResultChanged,
  });

  @override
  State<AmountCalculator> createState() => _AmountCalculatorState();
}

class _AmountCalculatorState extends State<AmountCalculator> {
  late String _expression;

  @override
  void initState() {
    super.initState();
    _expression = widget.initialValue;
  }

  void _onButtonTap(String val) {
    setState(() {
      if (val == 'C') {
        _expression = '';
        widget.onResultChanged('');
      } else if (val == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
          widget.onResultChanged(_evaluateSafe(_expression));
        }
      } else if (val == '=') {
        final result = _evaluateSafe(_expression);
        _expression = result;
        widget.onResultChanged(result);
      } else {
        const ops = ['+', '-', '×', '÷'];
        if (ops.contains(val)) {
          if (_expression.isEmpty) return;
          final lastChar = _expression[_expression.length - 1];
          if (ops.contains(lastChar)) {
            _expression =
                _expression.substring(0, _expression.length - 1) + val;
            return;
          }
        }
        _expression += val;
        if (!ops.contains(val)) {
          widget.onResultChanged(_evaluateSafe(_expression));
        }
      }
    });
  }

  String _evaluateSafe(String expr) {
    if (expr.isEmpty) return '';
    try {
      final tokens = <String>[];
      String numBuffer = '';

      for (int i = 0; i < expr.length; i++) {
        final ch = expr[i];
        if ('0123456789.'.contains(ch)) {
          numBuffer += ch;
        } else if ('+-×÷'.contains(ch)) {
          if (numBuffer.isNotEmpty) {
            tokens.add(numBuffer);
            numBuffer = '';
          }
          tokens.add(ch);
        }
      }
      if (numBuffer.isNotEmpty) tokens.add(numBuffer);
      if (tokens.isEmpty) return '';
      if ('+-×÷'.contains(tokens.last)) tokens.removeLast();
      if (tokens.isEmpty) return '';

      // Proses perkalian & pembagian lebih dulu
      final pass1 = <String>[tokens[0]];
      for (int i = 1; i < tokens.length; i += 2) {
        final op = tokens[i];
        final nextVal = double.tryParse(tokens[i + 1]) ?? 0;
        if (op == '×' || op == '÷') {
          final prevVal = double.tryParse(pass1.removeLast()) ?? 0;
          final res = op == '×'
              ? prevVal * nextVal
              : (nextVal == 0 ? 0.0 : prevVal / nextVal);
          pass1.add(res.toString());
        } else {
          pass1.add(op);
          pass1.add(nextVal.toString());
        }
      }

      // Proses penjumlahan & pengurangan
      double total = double.tryParse(pass1[0]) ?? 0;
      for (int i = 1; i < pass1.length; i += 2) {
        final op = pass1[i];
        final nextVal = double.tryParse(pass1[i + 1]) ?? 0;
        if (op == '+') total += nextVal;
        if (op == '-') total -= nextVal;
      }

      return total < 0 ? '0' : total.round().toString();
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['C', '⌫', '÷', '×'],
      ['7', '8', '9', '-'],
      ['4', '5', '6', '+'],
      ['1', '2', '3', '='],
      ['0', '000'],
    ];

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            alignment: Alignment.centerRight,
            child: Text(
              _expression.isEmpty ? '0' : _expression,
              style: const TextStyle(
                color: AppColors.neonCyan,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Divider(height: 8, color: AppColors.cardBorder),
          ...keys.map((row) {
            return Row(
              children: row.map((k) {
                final isOp = ['+', '-', '×', '÷', '='].contains(k);
                final isClear = k == 'C' || k == '⌫';
                return Expanded(
                  flex: k == '0' ? 2 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: InkWell(
                      onTap: () => _onButtonTap(k),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 38,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: k == '='
                              ? AppColors.primaryBlue
                              : isOp
                                  ? AppColors.cardSecondary
                                  : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          k,
                          style: TextStyle(
                            color: isClear
                                ? AppColors.expenseRed
                                : isOp
                                    ? AppColors.neonCyan
                                    : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}