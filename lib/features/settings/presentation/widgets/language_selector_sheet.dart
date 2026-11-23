// lib/features/settings/presentation/widgets/language_selector_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:routex_mobile/core/bloc/language/language_bloc.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';

class LanguageSelectorSheet extends StatelessWidget {
  const LanguageSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLang = context.watch<LanguageBloc>().state.languageCode;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Language',
            style: TextStyle(
              fontFamily: AppFonts.fontFamilySatoshi,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.brandBlack,
            ),
          ),
          SizedBox(height: 16.h),
          ListTile(
            title: const Text('English'),
            trailing: currentLang == 'en' ? const Icon(Icons.check, color: AppColors.brandMain) : null,
            onTap: () {
              if (currentLang != 'en') {
                context.read<LanguageBloc>().add(ToggleLanguageEvent());
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('العربية (Arabic)'),
            trailing: currentLang == 'ar' ? const Icon(Icons.check, color: AppColors.brandMain) : null,
            onTap: () {
              if (currentLang != 'ar') {
                context.read<LanguageBloc>().add(ToggleLanguageEvent());
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
