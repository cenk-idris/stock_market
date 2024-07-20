import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_market/constants.dart';
import 'package:stock_market/services/stock_service.dart';

import '../models/stock_model.dart';

abstract class MarketState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MarketInitial extends MarketState {}

class MarketLoading extends MarketState {}

class MarketLoaded extends MarketState {
  final List<Stock> market;

  MarketLoaded(this.market);

  @override
  List<Object?> get props => [market];
}

class MarketError extends MarketState {
  final String message;
  MarketError(this.message);

  @override
  List<Object?> get props => [message];
}

class MarketBloc extends Cubit<MarketState> {
  final StockService _stockService =
      StockService('cqc77phr01qmbcu92mt0cqc77phr01qmbcu92mtg');
  List<Stock> _market = [];

  MarketBloc() : super(MarketInitial()) {
    populateStockList();
  }

  void populateStockList() async {
    emit(MarketLoading());
    try {
      List<Stock> tmpStocks = [];
      for (final symbol in stockSymbols) {
        final stock = await _stockService.fetchStockQuote(symbol);
        tmpStocks.add(stock);
      }
      if (tmpStocks.isNotEmpty) {
        _market = tmpStocks;
        emit(MarketLoaded(_market));
        _subscribeToRealTimeUpdates(stockSymbols);
      } else {
        emit(MarketError('Market is empty'));
      }
    } on FirebaseException catch (e) {
      print(e.toString());
      emit(MarketError(e.toString()));
    } catch (e) {
      print(e.toString());
      emit(MarketError(e.toString()));
    }
  }

  void _subscribeToRealTimeUpdates(List<String> symbols) {
    _stockService.getStockStream(symbols).listen((stock) {
      int index = _market.indexWhere((s) => s.symbol == stock.symbol);
      if (index != -1) {
        final Stock updatedStock = _market[index]
            .copyWith(price: stock.price, timestamp: stock.timestamp);
        _market[index] = updatedStock;
        emit(MarketLoaded(_market));
      }
    }, onError: (error) {
      emit(MarketError(error.toString()));
    });
  }

  @override
  Future<void> close() {
    _stockService.dispose();
    return super.close();
  }
}
