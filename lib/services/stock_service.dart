import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../models/stock_model.dart';

class StockService {
  final String apiKey;

  StockService(this.apiKey);

  Future<Stock> fetchStockQuote(String symbol) async {
    final Uri url = Uri.parse(
        'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey');

    final Uri uri = new Uri(
      scheme: 'https',
      host: 'finnhub.io',
      path: 'api/v1/quote',
      queryParameters: {
        'symbol': symbol,
      },
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return Stock.fromQuoteJson(symbol, data);
    } else {
      throw Exception('Failed to load stock data');
    }
  }
}
