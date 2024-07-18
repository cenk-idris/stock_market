import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_market/services/stock_service.dart';

import '../models/stock_model.dart';

abstract class StockState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockBloc extends Cubit<StockState> {
  final StockService stockService =
      StockService('cqc77phr01qmbcu92mt0cqc77phr01qmbcu92mtg');
  final List<Stock> _stocks = [];

  StockBloc() : super(StockInitial()) {
    populateStockList();
  }

  void populateStockList() async {
    emit(StockLoading());
  }
}
