import 'package:equatable/equatable.dart';
import 'package:stock_market/services/stock_service.dart';

class Stock extends Equatable {
  final String fullName;
  final String symbol;
  final String assetName;
  final double price;
  final int timestamp;

  Stock(
      {this.fullName = '',
      required this.symbol,
      this.assetName = '',
      required this.price,
      required this.timestamp});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['s'],
      price: double.parse(json['p']),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory Stock.fromWebSocketJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['s'],
      price: json['p'],
      timestamp: json['t'],
    );
  }

  static Future<Stock> fromQuoteJson(
      String symbol, Map<String, dynamic> data) async {
    try {
      final StockService _stockService =
          StockService('cqc77phr01qmbcu92mt0cqc77phr01qmbcu92mtg');
      final String fullName = await _stockService.fetchCompanyName(symbol);
      print(data['t']);
      return Stock(
        fullName: fullName,
        symbol: symbol,
        assetName: symbol.replaceAll('.', '-'),
        price: data['c'],
        timestamp: (data['t'] as int) * 1000,
      );
    } catch (e) {
      print('$symbol | fromQuoteJson Err: ${e.toString()} ');
      return Stock(
        fullName: 'ERROR Inc.',
        symbol: 'ERR',
        assetName: symbol.replaceAll('.', '-'),
        price: 00.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  Stock copyWith({
    String? fullName,
    String? symbol,
    String? assetName,
    double? price,
    int? timestamp,
  }) {
    return Stock(
      fullName: fullName ?? this.fullName,
      symbol: symbol ?? this.symbol,
      assetName: assetName ?? this.assetName,
      price: price ?? this.price,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [symbol, price, timestamp, fullName, assetName];
}
