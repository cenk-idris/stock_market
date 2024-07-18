class Stock {
  final String symbol;
  final double price;
  final DateTime timestamp;

  Stock({required this.symbol, required this.price, required this.timestamp});

  factory Stock.fromJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['s'],
      price: json['p'],
      timestamp: DateTime.now(),
    );
  }
}
