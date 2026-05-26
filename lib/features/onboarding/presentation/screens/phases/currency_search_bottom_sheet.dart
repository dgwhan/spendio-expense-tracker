import 'package:flutter/material.dart';
import 'package:spend_io_app/features/onboarding/data/models/currency_item.dart';

class CurrencySearchBottomSheet extends StatefulWidget {
  final CurrencyItem currentSelection;
  final Function(CurrencyItem) onCurrencySelected;

  const CurrencySearchBottomSheet({
    super.key,
    required this.currentSelection,
    required this.onCurrencySelected,
  });

  @override
  State<CurrencySearchBottomSheet> createState() =>
      _CurrencySearchBottomSheetState();
}

class _CurrencySearchBottomSheetState extends State<CurrencySearchBottomSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredList = supportedCurrencies.where((c) {
      return c.countryName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.code.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        top: 16,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nút back đóng sheet
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 8),

          // Thanh Tìm Kiếm Chuẩn UI
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              decoration: const InputDecoration(
                hintText: 'Search by code, name country',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 300,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final currency = filteredList[index];
                final isCurrent = widget.currentSelection.code == currency.code;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4),
                  leading:
                      Text(currency.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(
                    currency.countryName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 16),
                  ),
                  trailing: Text(
                    currency.code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isCurrent ? const Color(0xFF6366F1) : Colors.black,
                    ),
                  ),
                  selected: isCurrent,
                  selectedTileColor: const Color(0xFFF3F4F6),
                  onTap: () {
                    widget.onCurrencySelected(currency);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
