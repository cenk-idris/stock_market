import 'package:flutter/material.dart';
import 'package:stock_market/services/stock_service.dart';

class StocksScreen extends StatelessWidget {
  const StocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Stonks Screen, HODL!'),
            ElevatedButton(
                onPressed: () {
                  StockService('cqc77phr01qmbcu92mt0cqc77phr01qmbcu92mtg')
                      .fetchLatestStockPrice('AAPL');
                },
                child: Text('Fetch stonk')),
          ],
        ),
      ),
    );
  }
}
