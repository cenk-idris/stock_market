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
}
