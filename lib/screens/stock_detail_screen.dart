import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/stock_detail_cubit.dart';
import '../models/stock_model.dart';

class StockDetailScreen extends StatelessWidget {
  final Stock stock;

  StockDetailScreen({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/stock_icons/${stock.assetName}.png',
                width: 30,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(stock.symbol),
            ],
          ),
        ),
        body: BlocBuilder<StockDetailBloc, StockDetailState>(
          builder: (context, detailState) {
            if (detailState is StockDetailLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (detailState is StockDetailLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                dotData: FlDotData(show: false),
                                isCurved: true,
                                spots: detailState.historicalData
                                    .map((data) => FlSpot(
                                        data.time.millisecondsSinceEpoch
                                            .toDouble(),
                                        data.price))
                                    .toList(),
                                color: Colors.white,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.purpleAccent,
                                    Colors.blueAccent,
                                  ],
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.withOpacity(0.1),
                                      Colors.purpleAccent.withOpacity(0.1),
                                      Colors.blueAccent.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (detailState is StockDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning,
                      size: 100,
                      color: Colors.red,
                    ),
                    Text(detailState.message),
                  ],
                ),
              );
            } else {
              return Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    Text('Whats that brother'),
                  ],
                ),
              );
            }
          },
        ));
  }
}
