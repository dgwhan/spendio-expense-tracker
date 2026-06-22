import 'package:flutter/material.dart';
import 'package:spend_io_app/core/constants/app_sizes.dart';
import 'package:spend_io_app/core/constants/app_text_styles.dart';

class TransactionInfoCard extends StatelessWidget {
  final String timeDetail;
  final String accountLabel;
  final String? note;
  final Color surfaceColor;
  final Color primaryTextColor;
  final Color mutedTextColor;

  const TransactionInfoCard({
    super.key,
    required this.timeDetail,
    required this.accountLabel,
    required this.surfaceColor,
    required this.primaryTextColor,
    required this.mutedTextColor,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final hasNote = note?.isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.access_time_rounded,
            label: 'Time',
            value: timeDetail,
            primaryColor: primaryTextColor,
            mutedColor: mutedTextColor,
          ),
          Divider(
              height: 28,
              thickness: 0.6,
              color: mutedTextColor.withValues(alpha: 0.1)),
          _buildInfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Wallet',
            value: accountLabel,
            primaryColor: primaryTextColor,
            mutedColor: mutedTextColor,
          ),
          Divider(
              height: 28,
              thickness: 0.6,
              color: mutedTextColor.withValues(alpha: 0.1)),
          _buildInfoRow(
            icon: Icons.notes_rounded,
            label: 'Note',
            value: hasNote ? note! : 'No description',
            primaryColor: primaryTextColor,
            mutedColor: mutedTextColor,
            isItalic: !hasNote,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color primaryColor,
    required Color mutedColor,
    bool isItalic = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: mutedColor.withValues(alpha: 0.6)),
        const SizedBox(width: AppSizes.sm),
        // Nhãn tiêu đề nằm cố định bên trái
        Text(
          label,
          style: AppTextStyles.caption
              .copyWith(color: mutedColor, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        // Giá trị thông tin được đẩy và căn lề sát hoàn toàn về bên phải
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyNormal.copyWith(
              fontWeight: FontWeight.w600,
              color: primaryColor,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}
