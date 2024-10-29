import 'package:flutter/material.dart';

void main() {
  runApp(const DebtCalculatorApp());
}

class DebtCalculatorApp extends StatelessWidget {
  const DebtCalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const DebtCalculatorScreen(),
    );
  }
}

class DebtCalculatorScreen extends StatefulWidget {
  const DebtCalculatorScreen({Key? key}) : super(key: key);

  @override
  _DebtCalculatorScreenState createState() => _DebtCalculatorScreenState();
}

class _DebtCalculatorScreenState extends State<DebtCalculatorScreen> {
  final TextEditingController _debtController = TextEditingController();
  final TextEditingController _interestRateController = TextEditingController();
  final TextEditingController _monthlyPaymentController =
      TextEditingController();

  int? _monthsNeeded;
  String _message = "";

  void _calculateMonths() {
    final double debt = double.tryParse(_debtController.text) ?? 0;
    final double annualRate =
        double.tryParse(_interestRateController.text) ?? 0;
    final double monthlyPayment =
        double.tryParse(_monthlyPaymentController.text) ?? 0;

    if (debt <= 0 || annualRate <= 0 || monthlyPayment <= 0) {
      setState(() {
        _message = "Unesite ispravne vrijednosti!";
      });
      return;
    }

    final double monthlyRate = (annualRate / 100) / 12;
    double remainingDebt = debt;
    int months = 0;

    if (monthlyPayment <= remainingDebt * monthlyRate) {
      setState(() {
        _monthsNeeded = null;
        _message = "Mjesečni doplatak nije dovoljan za pokriće kamata.";
      });
      return;
    }

    while (remainingDebt > 0) {
      remainingDebt = remainingDebt * (1 + monthlyRate) - monthlyPayment;
      months += 1;
    }

    setState(() {
      _monthsNeeded = months;
      _message = "Broj meseci potrebnih za isplatu duga: $_monthsNeeded";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kalkulator otplate duga")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _debtController,
              decoration: const InputDecoration(
                labelText: "Iznos duga (EUR)",
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _interestRateController,
              decoration: const InputDecoration(
                labelText: "Godišnja kamatna stopa (%)",
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _monthlyPaymentController,
              decoration: const InputDecoration(
                labelText: "Mjesečni doplatak (EUR)",
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateMonths,
              child: const Text("Izračunaj mjesece"),
            ),
            const SizedBox(height: 20),
            Text(
              _message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
