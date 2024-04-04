import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  final String _baseUrl = 'https://api.freecurrencyapi.com/v1/latest';
  final String _apiKey = 'fca_live_pOGFdW5akBSeBt37hAeOFwfI1T4erRxbKXfT3Wdz';

  Future<double> fetchExchangeRate(String from, String to) async {
    final url = Uri.parse('$_baseUrl?apikey=$_apiKey&base_currency=$from');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rate = data['data'][to];
      if (rate != null) {
        return rate.toDouble();
      } else {
        throw Exception('Failed to get exchange rate for $from to $to');
      }
    } else {
      throw Exception('Failed to load exchange rate');
    }
  }
}
