import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth_cubit.dart';
import '../blocs/market_cubit.dart';
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
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 32.0),
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
                  Expanded(
                    child: BlocBuilder<MarketBloc, MarketState>(
                      builder: (context, marketState) {
                        if (marketState is MarketLoading) {
                          return Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(
                                  height: 20.0,
                                )
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
                                  onTap: () {},
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
                                    children: [
                                      Text(
                                          '${userAsset.shares * stockDetails.price}')
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
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
