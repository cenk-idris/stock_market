import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/asset_model.dart';

class UserState extends Equatable {
  final num balance;
  final List<Asset> assetList;

  UserState({required this.balance, required this.assetList});

  @override
  List<Object?> get props => [balance, assetList];
}

class UserBloc extends Cubit<UserState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserBloc() : super(UserState(assetList: [], balance: 0)) {
    _initialize();
  }

  void _initialize() {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          print('somethign changed');
          final data = snapshot.data()!;
          final balance = data['balance'];
          if (data['stocks'] != null) {
            final List<dynamic> stocksDynamic = data['stocks'] ?? [];
            final List<Asset> assetList = stocksDynamic.map((asset) {
              return Asset.fromMap(Map<String, dynamic>.from(asset));
            }).toList();
            emit(UserState(balance: balance, assetList: assetList));
          } else {
            emit(UserState(balance: balance, assetList: []));
          }
        }
      });
    }
  }

  Future<void> sellStock(String symbol, double quantity, double price) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final worthOfSale = quantity * price;
      final currentState = state;
      final assetToBeSold =
          currentState.assetList.firstWhere((asset) => asset.symbol == symbol);

      if (assetToBeSold.shares < quantity) {
        print('${assetToBeSold.shares} is less than $quantity');
        throw Exception('Insufficient shares');
      } else {
        print('and I get here');
        final updatedBalance = currentState.balance + worthOfSale;
        final List<Asset> updatedAssets = List.from(currentState.assetList);
        final assetToBeSoldIndex =
            updatedAssets.indexWhere((asset) => asset.symbol == symbol);
        if (assetToBeSoldIndex != -1) {
          updatedAssets[assetToBeSoldIndex] = Asset(
              symbol: assetToBeSold.symbol,
              shares: assetToBeSold.shares - quantity);
          if (updatedAssets[assetToBeSoldIndex].shares == 0) {
            updatedAssets.removeAt(assetToBeSoldIndex);
          }
        } else {
          throw Exception('Can\'t sell asset that does not exist');
        }
        await _firestore.collection('users').doc(user.uid).set({
          'balance': updatedBalance,
          'stocks': updatedAssets.map((asset) => asset.toMap()).toList(),
        });
        emit(UserState(balance: updatedBalance, assetList: updatedAssets));
      }
    }
  }

  Future<void> buyStock(String symbol, double quantity, double price) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final totalCost = quantity * price;
      final currentState = state;
      if (currentState.balance >= totalCost) {
        final updatedBalance = currentState.balance - totalCost;
        final List<Asset> updatedAssets = List.from(currentState.assetList);
        final existingAssetIndex =
            updatedAssets.indexWhere((asset) => asset.symbol == symbol);
        if (existingAssetIndex != -1) {
          final existingAsset = updatedAssets[existingAssetIndex];
          updatedAssets[existingAssetIndex] = Asset(
              symbol: existingAsset.symbol,
              shares: existingAsset.shares + quantity);
        } else {
          updatedAssets.add(Asset(symbol: symbol, shares: quantity));
        }
        await _firestore.collection('users').doc(user.uid).set({
          'balance': updatedBalance,
          'stocks': updatedAssets.map((asset) => asset.toMap()).toList(),
        });
        emit(UserState(balance: updatedBalance, assetList: updatedAssets));
      } else {
        print('Get your poor ass outta here');
      }
    }
  }
}
