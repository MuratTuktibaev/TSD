import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import '../../../styles/color_palette.dart';
import '../../../styles/text_styles.dart';
import '../../../widgets/main_text_field/app_text_field.dart';

class MoveDataVModel extends ChangeNotifier {
  late AppTextField sender;
  late AppTextField recipient;
  late AppTextField organization;
  late AppTextField moveType;

  void init() {
    sender = AppTextField(
      contentPadding: EdgeInsets.zero,
      textAlign: TextAlign.right,
      showErrorMessages: false,
      onChanged: onChanged,
    );
    recipient = AppTextField(
      contentPadding: EdgeInsets.zero,
      textAlign: TextAlign.right,
      showErrorMessages: false,
      onChanged: onChanged,
    );
    organization = AppTextField(
      contentPadding: EdgeInsets.zero,
      textAlign: TextAlign.right,
      showErrorMessages: false,
      onChanged: onChanged,
    );
    moveType = AppTextField(
      contentPadding: EdgeInsets.zero,
      textAlign: TextAlign.right,
      showErrorMessages: false,
      onChanged: onChanged,
    );
  }

  void onChanged(String value) {
    notifyListeners();
  }

  bool get validated =>
      sender.controller.text.isNotEmpty &&
      recipient.controller.text.isNotEmpty &&
      organization.controller.text.isNotEmpty &&
      moveType.controller.text.isNotEmpty;
}
