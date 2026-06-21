import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GoalInitialAmountField extends StatefulWidget {
  final TextEditingController controller;

  const GoalInitialAmountField({
    super.key,
    required this.controller,
  });

  @override
  State<GoalInitialAmountField> createState() => _GoalInitialAmountFieldState();
}

class _GoalInitialAmountFieldState extends State<GoalInitialAmountField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      // Nhấn vào ô: nếu đang là '0' thì xóa trống để nhập '123' chứ không bị '0123'
      if (widget.controller.text == '0') {
        widget.controller.clear();
      }
    } else {
      // Thoát ra ngoài: nếu bỏ trống hoàn toàn thì tự trả về '0' cho đẹp dữ liệu
      if (widget.controller.text.trim().isEmpty) {
        widget.controller.text = '0';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      textInputAction: TextInputAction.done,
      inputFormatters: [
        // FIX: Ngăn chặn không cho gõ số 0 ở đầu nếu đằng sau có số khác (Ví dụ: 0123 -> 123)
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        TextInputFormatter.withFunction((oldValue, newValue) {
          final text = newValue.text;
          // Nếu người dùng cố tình gõ số dạng '01', '02'... hệ thống tự động xóa số 0 đầu đi
          if (text.startsWith('0') &&
              text.length > 1 &&
              !text.startsWith('0.')) {
            return TextEditingValue(
              text: text.substring(1),
              selection: TextSelection.collapsed(offset: text.length - 1),
            );
          }
          return newValue;
        }),
      ],
      decoration: const InputDecoration(
        labelText: 'Initial Amount',
        hintText: '0',
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return null;
        }

        final amount = double.tryParse(value);

        if (amount == null || amount < 0) {
          return 'Invalid amount';
        }

        return null;
      },
    );
  }
}
