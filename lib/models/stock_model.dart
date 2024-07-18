import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  final String symbol;
  final double price;
  final int timestamp;

  Stock({required this.symbol, required this.price, required this.timestamp});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['s'],
      price: double.parse(json['p']),
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
  }

  factory Stock.fromQuoteJson(String symbol, Map<String, dynamic> data) {
    try {
      print(data['t']);
      return Stock(
        symbol: symbol,
        price: data['c'],
        timestamp: (data['t'] as int) * 1000,
      );
    } catch (e) {
      print('$symbol | fromQuoteJson Err: ${e.toString()} ');
      return Stock(
        symbol: 'ERR',
        price: 00.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  @override
  List<Object?> get props => [symbol, price, timestamp];
}
