import 'package:flutter/material.dart';
import 'package:spend_io_app/features/wallet/presentation/viewmodels/wallet_viewmodel.dart';

class WalletProvider extends ChangeNotifier {
  final WalletViewModel viewModel;

  WalletProvider(this.viewModel);
}
