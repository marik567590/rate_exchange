import 'package:flutter/material.dart';
import 'currency_service.dart';

class ExchangeScreen extends StatefulWidget {
  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  final CurrencyService _currencyService = CurrencyService();
  String _fromCurrency = 'EUR';
  String _toCurrency = 'USD';
  final TextEditingController _amountController = TextEditingController(text: '1');

  double _exchangeRate = 0.0;
  String _result = '';
  bool _isLoading = false;
  final List<String> _currencies = ['EUR', 'USD', 'GBP', 'JPY']; // Список поддерживаемых валют

  @override
  void initState() {
    super.initState();
    _loadExchangeRate();
  }

  void _loadExchangeRate() async {
    if (_fromCurrency == _toCurrency) {
      _showError('Please choose different currencies for conversion.');
      return;
    }

    final parsedAmount = double.tryParse(_amountController.text);
    if (_amountController.text.isEmpty || parsedAmount == null || parsedAmount <= 0) {
      _showError('Amount must be greater than 0');
      return;
    }

    setState(() => _isLoading = true);
    try {
      double rate = await _currencyService.fetchExchangeRate(_fromCurrency, _toCurrency);
      setState(() {
        _exchangeRate = rate;
        _updateConversionResult(parsedAmount);
      });
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateConversionResult(double amount) {
    final result = amount * _exchangeRate;
    setState(() {
      _result = '${amount.toString()} $_fromCurrency = ${result.toStringAsFixed(2)} $_toCurrency';
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _isLoading ? Center(child: CircularProgressIndicator()) : Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            DropdownButtonFormField<String>(
              value: _fromCurrency,
              onChanged: (value) => setState(() => _fromCurrency = value!),
              items: _currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'From Currency'),
            ),
            DropdownButtonFormField<String>(
              value: _toCurrency,
              onChanged: (value) => setState(() => _toCurrency = value!),
              items: _currencies.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'To Currency'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadExchangeRate,
              child: Text('Convert'),
            ),
            SizedBox(height: 20),
            Text(_result, style: TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
