import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Kalkulator Navigacija",
      initialRoute: "/",
      routes: {
        "/": (context) => const HomePage(),
        "/second": (context) => const DebtCalculatorScreen(),
        "/result": (context) => const ResultScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kalkulator otplate duga")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              "/second",
              arguments: "Vratite se na naslovnicu",
            );
          },
          child: const Text("Započni"),
        ),
      ),
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

  void _calculateMonths() {
    final double debt = double.tryParse(_debtController.text) ?? 0;
    final double annualRate =
        double.tryParse(_interestRateController.text) ?? 0;
    final double monthlyPayment =
        double.tryParse(_monthlyPaymentController.text) ?? 0;

    if (debt <= 0 || annualRate <= 0 || monthlyPayment <= 0) {
      Navigator.pushNamed(context, "/result",
          arguments: "Unesite ispravne vrijednosti!");
      return;
    }

    final double monthlyRate = (annualRate / 100) / 12;
    double remainingDebt = debt;
    int months = 0;

    if (monthlyPayment <= remainingDebt * monthlyRate) {
      Navigator.pushNamed(context, "/result",
          arguments: "Mjesečni doplatak nije dovoljan za pokriće kamata.");
      return;
    }

    while (remainingDebt > 0) {
      remainingDebt = remainingDebt * (1 + monthlyRate) - monthlyPayment;
      months += 1;
    }

    Navigator.pushNamed(context, "/result",
        arguments: "Broj mjeseci potrebnih za isplatu duga: $months");
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
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/");
              },
              child: const Text("Povratak na početnu stranicu"),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String message =
        ModalRoute.of(context)?.settings.arguments as String? ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Rezultat")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/second");
              },
              child: const Text("Povratak na unos vrijednosti"),
            ),
          ],
        ),
      ),
    );
  }
}
