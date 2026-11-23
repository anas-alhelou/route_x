import 'package:go_router/go_router.dart';
import 'package:routex_mobile/core/router/routers_name.dart';
import 'package:routex_mobile/features/join_company/presentation/pages/company_approved_page.dart';
import 'package:routex_mobile/features/join_company/presentation/pages/company_declined_page.dart';
import 'package:routex_mobile/features/join_company/presentation/pages/company_under_review_page.dart';
import 'package:routex_mobile/features/join_company/presentation/pages/confirm_company_page.dart';
import 'package:routex_mobile/features/join_company/presentation/pages/enter_company_code_page.dart';

abstract final class JoinCompanyRoutes {
  const JoinCompanyRoutes._();

  static List<GoRoute> get routes => [
    GoRoute(
      name: RoutersName.joinCompanyScreen,
      path: RoutersName.joinCompanyScreen,
      builder: (context, state) => const EnterCompanyCodePage(),
    ),
    GoRoute(
      name: RoutersName.confirmCompanyScreen,
      path: RoutersName.confirmCompanyScreen,
      builder: (context, state) => const ConfirmCompanyPage(),
    ),
    GoRoute(
      name: RoutersName.companyUnderReviewScreen,
      path: RoutersName.companyUnderReviewScreen,
      builder: (context, state) => const CompanyUnderReviewPage(),
    ),
    // J13 — the company approved the request.
    GoRoute(
      name: RoutersName.companyApprovedScreen,
      path: RoutersName.companyApprovedScreen,
      builder: (context, state) => const CompanyApprovedPage(),
    ),
    // J12 — the company declined the request.
    GoRoute(
      name: RoutersName.companyDeclinedScreen,
      path: RoutersName.companyDeclinedScreen,
      builder: (context, state) => const CompanyDeclinedPage(),
    ),
  ];
}
