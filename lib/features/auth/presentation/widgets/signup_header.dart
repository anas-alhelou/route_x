// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:routex_mobile/core/theme/app_colors.dart';
// import 'package:routex_mobile/core/theme/app_fonts.dart';

// class SignupHeader extends StatelessWidget {
//   final String titleStart;
//   final String titleEnd;
//   final String subtitle;

//   const SignupHeader({
//     super.key,
//     required this.titleStart,
//     required this.titleEnd,
//     required this.subtitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: '$titleStart ',
//             style: TextStyle(
//               fontFamily: AppFonts.fontFamilySatoshi,
//               fontSize: 32.sp,
//               fontWeight: FontWeight.w700,
//               color: AppColors.textPrimary,
//               height: 1.2,
//             ),
//             children: [
//               TextSpan(
//                 text: titleEnd,
//                 style: TextStyle(
//                   color: AppColors.brandMain,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         SizedBox(height: 8.h),
//         Text(
//           subtitle,
//           style: TextStyle(
//             fontFamily: AppFonts.fontFamilySatoshi,
//             fontSize: 16.sp,
//             fontWeight: FontWeight.w400,
//             color: AppColors.textGray,
//             height: 1.5,
//           ),
//         ),
//       ],
//     );
//   }
// }
