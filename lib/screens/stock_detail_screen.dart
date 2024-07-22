import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../blocs/stock_detail_cubit.dart';
import '../models/stock_model.dart';

class StockDetailScreen extends StatelessWidget {
  final Stock stock;

  StockDetailScreen({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    // Create a DateFormat instance
    DateFormat formatter = DateFormat('yyyy-MM-dd');
    // Get the current date
    DateTime now = DateTime.now();
    // Get the date one week before the current date for week slice
    DateTime oneDayBefore = now.subtract(Duration(days: 3));
    DateTime oneWeekBefore = now.subtract(Duration(days: 7));
    DateTime oneMonthBefore = now.subtract(Duration(days: 30));
    DateTime oneYearBefore = now.subtract(Duration(days: 365));

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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.0,
                    ),
                    AspectRatio(
                      aspectRatio: 1.7,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: LineChart(
                          LineChartData(
                            lineBarsData: [
                              LineChartBarData(
                                dotData: FlDotData(show: false),
                                isCurved: false,
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
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(value.toInt().toString());
                                    }),
                              ),
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return Text(value.toInt().toString());
                                      })),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 60,
                                    getTitlesWidget: (value, meta) {
                                      DateTime date =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              value.toInt());
                                      return SideTitleWidget(
                                          angle: 0.5,
                                          axisSide: meta.axisSide,
                                          child: Text(
                                              '${date.year.toString()}-${date.month.toString()}'));
                                    }),
                              ),
                            ),
                            gridData: FlGridData(drawHorizontalLine: false),
                            borderData: FlBorderData(
                              show: false,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<StockDetailBloc>()
                                  .fetchHistoricalData(
                                    stock.symbol,
                                    '1',
                                    'minute',
                                    formatter.format(oneDayBefore),
                                    formatter.format(now),
                                  );
                            },
                            child: Text('1D'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<StockDetailBloc>()
                                  .fetchHistoricalData(
                                      stock.symbol,
                                      '1',
                                      'hour',
                                      formatter.format(oneWeekBefore),
                                      formatter.format(now));
                            },
                            child: Text('1W'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<StockDetailBloc>()
                                  .fetchHistoricalData(
                                      stock.symbol,
                                      '1',
                                      'day',
                                      formatter.format(oneMonthBefore),
                                      formatter.format(now));
                            },
                            child: Text('1M'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<StockDetailBloc>()
                                  .fetchHistoricalData(
                                      stock.symbol,
                                      '1',
                                      'day',
                                      formatter.format(oneYearBefore),
                                      formatter.format(now));
                            },
                            child: Text('1Y'),
                          ),
                        ],
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
