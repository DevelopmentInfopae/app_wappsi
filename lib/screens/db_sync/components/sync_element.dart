import 'package:flutter/material.dart';
// ignore: implementation_imports
import 'package:nb_utils/src/extensions/widget_extensions.dart';
import 'package:pos_wappsi/config/theme/colors.dart';
import 'package:pos_wappsi/screens/db_sync/components/widgets.dart';
import 'package:pos_wappsi/utils/responsive.dart';
import 'package:pos_wappsi/utils/text_formating/functions.dart';

class ElementSync extends StatelessWidget {
  const ElementSync({
    Key? key,
    required this.status,
    required this.optionInfo,
    required this.optionName,
  }) : super(key: key);

  final Map<String, dynamic> optionInfo;
  final String optionName;
  final bool status;

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDesign(context);
    return Padding(
      padding: responsive.verticalMaxPadding(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: status ? AppColors.okColorWappsi : Colors.blueAccent,
              borderRadius: BorderRadius.circular(100),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/images/' + (optionInfo['image'] ?? 'countries.png'),
              ).withSize(
                width: responsive.maxHeightValue(28),
                height: responsive.maxHeightValue(28),
              ),
            ),
          ).paddingRight(8),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    // ignore: unnecessary_null_comparison
                    capitalizeText(optionName),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    textAlign: TextAlign.left,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 20,
                        ),
                  ),
                ),
                // .withWidth(_size.width * 0.55),
                syncStatus(status).paddingLeft(8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
