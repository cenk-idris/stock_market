import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_market/screens/stock_detail_screen.dart';

import '../blocs/auth_cubit.dart';
import '../blocs/market_cubit.dart';
import '../blocs/stock_detail_cubit.dart';
import '../blocs/user_cubit.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, userState) {
          final authState = BlocProvider.of<AuthBloc>(context).state;
          if (authState is Authenticated) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32.0, vertical: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your current USD balance:'),
                      Text(
                        '\$${userState.balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'My Stonks 🤑',
                    style: TextStyle(fontSize: 32),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<MarketBloc, MarketState>(
                    builder: (marketContext, marketState) {
                      if (marketState is MarketLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(
                                height: 20.0,
                              ),
                              Text('Please wait while fetching market data...')
                            ],
                          ),
                        );
                      } else if (marketState is MarketLoaded) {
                        return ListView.builder(
                            itemCount: userState.assetList.length,
                            itemBuilder: (context, index) {
                              final userAsset = userState.assetList[index];
                              final stockDetails =
                                  marketState.market.firstWhere((stock) {
                                return stock.symbol == userAsset.symbol;
                              });
                              return ListTile(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context2) =>
                                              MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                    create: (context) =>
                                                        StockDetailBloc(
                                                            marketContext
                                                                .read<
                                                                    MarketBloc>()
                                                                .stockService)
                                                          ..fetchHistoricalData(
                                                              userAsset.symbol,
                                                              '1',
                                                              'day',
                                                              '2023-07-20',
                                                              '2024-07-20'),
                                                  ),
                                                  BlocProvider.value(
                                                    value: BlocProvider.of<
                                                        UserBloc>(context),
                                                  ),
                                                  BlocProvider.value(
                                                    value: BlocProvider.of<
                                                        MarketBloc>(context),
                                                  )
                                                ],
                                                child: StockDetailScreen(
                                                    stock: stockDetails),
                                              )));
                                },
                                leading: Container(
                                  width: 40,
                                  child: Image.asset(
                                    'assets/stock_icons/${stockDetails.assetName}.png',
                                    width: 50,
                                    height: 40,
                                  ),
                                ),
                                title: Text(stockDetails.symbol),
                                subtitle: Text(stockDetails.fullName),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${(userAsset.shares * stockDetails.price).toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 15),
                                    )
                                  ],
                                ),
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
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                )
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
