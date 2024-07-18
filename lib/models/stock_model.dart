import 'package:equatable/equatable.dart';

class Stock extends Equatable {
  final String symbol;
  final double price;
  final DateTime timestamp;

  Stock({required this.symbol, required this.price, required this.timestamp});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['s'],
      price: double.parse(json['p']),
      timestamp: DateTime.now(),
    );
  }

  factory Stock.fromQuoteJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['s'],
      price: json['p'],
      timestamp: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [symbol, price, timestamp];
}
