import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final success =
                      await context.read<ProfileViewModel>().handleLogout();

                  if (success && context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                },
                child: const Text('Sign Out',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
    );
  }
}
