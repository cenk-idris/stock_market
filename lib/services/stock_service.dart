import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import '../models/stock_model.dart';

class StockService {
  final String apiKey;
  WebSocketChannel? _channel;

  StockService(this.apiKey);

  Stream<Stock> getStockStream(List<String> symbolList) {
    _initializeWebSocket();
    _subscribeToSymbols(symbolList);
    return _channel!.stream.expand((data) {
      final decoded = json.decode(data);
      if (decoded['type'] == 'trade') {
        print(decoded['data']);
        return decoded['data']
            .map<Stock>((trade) => Stock.fromWebSocketJson(trade))
            .toList();
      }
      return [];
    });
  }

  Future<void> _initializeWebSocket() async {
    if (_channel == null) {
      _channel = WebSocketChannel.connect(
          Uri.parse('wss://ws.finnhub.io?token=$apiKey'));

      try {
        await _channel?.ready;
        print('WebSocket Sink ready');
      } on SocketException catch (e) {
        print('SocketException: ${e.toString()}');
        throw Exception(e);
      } on WebSocketChannelException catch (e) {
        print('WSChannelException: ${e.toString()}');
        throw Exception(e);
      }
    }
  }

  void _subscribeToSymbols(List<String> symbolList) async {
    await _initializeWebSocket();
    for (final symbol in symbolList) {
      final message = json.encode({'type': 'subscribe', 'symbol': symbol});
      _channel!.sink.add(message);
    }
  }

  void dispose() {
    _channel?.sink.close();
  }

  Future<Stock> fetchStockQuote(String symbol) async {
    final Uri url = Uri.parse(
        'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$apiKey');

    final Uri uri = new Uri(
      scheme: 'https',
      host: 'finnhub.io',
      path: 'api/v1/quote',
      queryParameters: {
        'symbol': symbol,
        'token': apiKey,
      },
    );
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      return Stock.fromQuoteJson(symbol, data);
    } else {
      throw Exception('Failed to load stock data');
    }
  }

  Future<String> fetchCompanyName(String symbol) async {
    final Uri uri = new Uri(
      scheme: 'https',
      host: 'finnhub.io',
      path: 'api/v1/stock/profile2',
      queryParameters: {
        'symbol': symbol,
        'token': apiKey,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['name'];
    } else {
      throw Exception('Failed to fetch company name');
    }
  }
}
