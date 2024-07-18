import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_market/services/stock_service.dart';

import '../blocs/stock_cubit.dart';

class StocksScreen extends StatelessWidget {
  const StocksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<MarketBloc, MarketState>(
        builder: (context, marketState) {
          if (marketState is MarketLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 50.0,
                  ),
                  Text('Market data is being fetched...'),
                  ElevatedButton(onPressed: () {}, child: Text('Fetch stonk')),
                ],
              ),
            );
          } else if (marketState is MarketLoaded) {
            return ListView.builder(
                itemCount: marketState.market.length,
                itemBuilder: (context, index) {
                  final stock = marketState.market[index];
                  return ListTile(
                    leading: Icon(Icons.apple),
                    title: Text(stock.symbol),
                    subtitle: Text('This is subtitle'),
                    trailing: Text('${stock.price}\$'),
                  );
                });
          } else if (marketState is MarketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning,
                    size: 100,
                    color: Colors.red,
                  ),
                  Text(marketState.message),
                ],
              ),
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
