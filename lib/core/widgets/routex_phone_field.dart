// lib/core/widgets/routex_phone_field.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_flags/country_flags.dart';
import 'package:routex_mobile/core/extensions/tr_extension.dart';
import 'package:routex_mobile/core/theme/app_colors.dart';
import 'package:routex_mobile/core/theme/app_fonts.dart';
import 'package:routex_mobile/core/theme/app_spacing.dart';
import 'package:routex_mobile/core/widgets/routex_text_field.dart';
import 'package:routex_mobile/features/auth/domain/entities/phone_country.dart';
import 'package:routex_mobile/core/animations/routex_overlays.dart';

// Country data source

/// A country offered by [RouteXPhoneField]'s picker, and the selection a parent
/// reads back through [RouteXPhoneFieldController].
///
/// Carries three separate identifiers on purpose, because they serve three
/// different consumers and conflating them was the original bug:
///
///  * [isoCode] — ISO 3166-1 alpha-2. What phone-number parsing and
///    validation need, and what a stored E.164 number is split back on.
///  * [dialCode] — the `+970` shown in the field prefix; cosmetic.
///  * [apiName] — the **non-localized** English country name sent to the API.
///    Deliberately not [label]: sending the Arabic display name to the backend
///    because the user happens to speak Arabic would be a bug.
@immutable
class RouteXPhoneCountry extends Equatable {
  const RouteXPhoneCountry({required this.country, required this.label});

  /// Domain metadata: ISO code, dial code and the non-localized API name.
  final PhoneCountry country;

  /// What the picker shows, in the active language.
  ///
  /// Presentation only — the localized name never leaves this class.
  final String label;

  String get isoCodeName => country.isoCode;

  String get dialCode => country.dialCode;

  String get apiName => country.apiName;

  /// The two-letter code the flag widget takes.
  String get flagCode => country.isoCode;

  @override
  List<Object?> get props => [country, label];
}

/// The countries the phone field offers, with their label in the active
/// language.
///
/// The metadata comes straight from the domain list; only the display name is
/// resolved here, so the picker can never offer a dial code that the domain
/// does not validate against.
List<RouteXPhoneCountry> _getCountries(BuildContext context) {
  String labelFor(PhoneCountry country) => switch (country.isoCode) {
    'PS' => context.tr.countryPalestine,
    'SA' => context.tr.countrySaudiArabia,
    'EG' => context.tr.countryEgypt,
    'AE' => context.tr.countryUAE,
    'JO' => context.tr.countryJordan,
    'QA' => context.tr.countryQatar,
    'KW' => context.tr.countryKuwait,
    'OM' => context.tr.countryOman,
    'BH' => context.tr.countryBahrain,
    _ => country.apiName,
  };

  return [
    for (final country in kPhoneCountries)
      RouteXPhoneCountry(country: country, label: labelFor(country)),
  ];
}

/// Lets a parent read (and observe) the country [RouteXPhoneField] has
/// selected.
///
/// The selection used to live in a private field of the widget, so the signup
/// flow could render `+970` in the UI and still send a bare national number
/// beside a hard-coded `country`. A screen that needs the country — to validate
/// the number, to store it, or to restore the picker — owns one of these.
class RouteXPhoneFieldController extends ChangeNotifier {
  RouteXPhoneFieldController({PhoneCountry? initialCountry})
    : _country = initialCountry ?? kDefaultPhoneCountry;

  PhoneCountry _country;

  /// The country the number is being entered against.
  PhoneCountry get country => _country;

  /// The two-letter code, which is what the phone validator takes.
  String get isoCode => _country.isoCode;

  /// The `+` dial code, used for display and for E.164 normalization.
  String get dialCode => _country.dialCode;

  /// The non-localized name sent as the API payload's `country` field.
  String get apiName => _country.apiName;

  /// Called by the field when the user picks a country in the sheet.
  void selectCountry(PhoneCountry country) {
    if (_country == country) return;
    _country = country;
    notifyListeners();
  }
}

/// A phone-number input that wraps [RouteXTextField] and prepends a tappable
/// country-code prefix.
///
/// Tapping the prefix opens a searchable [showModalBottomSheet]; its country
/// list is filtered as the user types a search query.
class RouteXPhoneField extends StatefulWidget {
  const RouteXPhoneField({
    super.key,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.labelText = 'Phone Number',
    this.hintText = 'Enter your phone number',
    this.countryController,
    this.initialCountryIsoCode,
    this.labelStyle,
    this.labelInset = 0,
    this.textStyle,
    this.outlinedErrorIcon = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String labelText;
  final String hintText;

  /// Lets the parent read the selected country and react to changes.
  ///
  /// Optional: without one the field behaves exactly as before.
  final RouteXPhoneFieldController? countryController;

  /// Restores a previously stored selection — when the user returns to step 1,
  /// or when an edit sheet is pre-filled from a saved E.164 number.
  ///
  /// Only applied when [countryController] is null or still holds its default,
  /// so a selection the user has already made is never overwritten.
  final String? initialCountryIsoCode;

  /// Forwarded to [RouteXTextField.labelStyle].
  final TextStyle? labelStyle;

  /// Forwarded to [RouteXTextField.labelInset].
  final double labelInset;

  /// Forwarded to [RouteXTextField.textStyle]; also sizes the dial code.
  final TextStyle? textStyle;

  /// Forwarded to [RouteXTextField.outlinedErrorIcon].
  final bool outlinedErrorIcon;

  @override
  State<RouteXPhoneField> createState() => _RouteXPhoneFieldState();
}

class _RouteXPhoneFieldState extends State<RouteXPhoneField> {
  late FocusNode _focusNode;
  RouteXPhoneFieldController? _ownedCountryController;

  /// The externally supplied controller when there is one, otherwise a private
  /// one seeded from [RouteXPhoneField.initialCountryIsoCode].
  RouteXPhoneFieldController get _countryController =>
      widget.countryController ??
      (_ownedCountryController ??= RouteXPhoneFieldController(
        initialCountry: phoneCountryByIsoCode(widget.initialCountryIsoCode),
      ));

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    // Listens to whichever controller it is reading from — the parent's, or the
    // private one this state just created. The controller is constructed with
    // the restored ISO code and already falls back to kDefaultPhoneCountry, so
    // the prefix is correct on the very first build without a seeded call.
    // Listens to whichever controller it is reading from — the parent's, or the
    // private one this state just created. The controller is constructed with
    // the restored ISO code and already falls back to kDefaultPhoneCountry, so
    // the prefix is correct on the very first build without a seeded call.
    _countryController.addListener(_handleCountryChanged);
  }

  @override
  void didUpdateWidget(covariant RouteXPhoneField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.countryController != widget.countryController) {
      oldWidget.countryController?.removeListener(_handleCountryChanged);
      // The state always listens to whichever controller it is currently
      // reading from. Without this the picker would be a no-op on screen
      // whenever the parent supplied no controller of its own: the private
      // one notifies its listeners, and the field would be the only listener
      // it had — except it was not registered.
      (widget.countryController ?? _countryController).addListener(
        _handleCountryChanged,
      );
    }
    if (oldWidget.initialCountryIsoCode != widget.initialCountryIsoCode &&
        widget.countryController == null) {
      final restored = phoneCountryByIsoCode(widget.initialCountryIsoCode);
      if (restored != null) _countryController.selectCountry(restored);
    }
  }

  /// Repaints the prefix when the selected country changes.
  ///
  /// Covers both the owning screen changing the selection itself (restoring a
  /// saved number) and the user picking one in the sheet.
  void _handleCountryChanged() {
    if (mounted) setState(() {});
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    (widget.countryController ?? _ownedCountryController)?.removeListener(
      _handleCountryChanged,
    );
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _ownedCountryController?.dispose();
    super.dispose();
  }

  void _showCountryPickerBottomSheet() {
    showRoutexSheet<void>(
      context: context,
      isScrollControlled: true, // respects height: 70 %
      backgroundColor: Colors.transparent, // sheet draws its own bg
      builder: (BuildContext sheetCtx) {
        String searchQuery = '';
        List<RouteXPhoneCountry> filtered = List.of(_getCountries(context));

        return StatefulBuilder(
          builder: (BuildContext sbCtx, StateSetter setSheetState) {
            return Padding(
              // Push sheet up when keyboard appears
              padding: EdgeInsetsDirectional.only(
                bottom: MediaQuery.of(sbCtx).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(sbCtx).size.height * 0.7,
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        top: AppSpacing.s12.h,
                        bottom: AppSpacing.s8.h,
                      ),
                      child: Container(
                        width: AppSpacing.s40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceEmpty,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16.w,
                        vertical: AppSpacing.s8.h,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          context.tr.selectCountryCode,
                          style: TextStyle(
                            fontFamily: AppFonts.fontFamilySatoshi,
                            fontFamilyFallback: AppFonts.fontFamilyFallback,
                            fontSize: AppFonts.size16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                    ),

                    // 3. Search text field
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s16.w,
                        vertical: AppSpacing.s8.h,
                      ),
                      child: TextField(
                        autofocus: false,
                        style: TextStyle(
                          fontFamily: AppFonts.fontFamilySatoshi,
                          fontFamilyFallback: AppFonts.fontFamilyFallback,
                          fontSize: AppFonts.size14.sp,
                          color: AppColors.textBlack,
                        ),
                        decoration: InputDecoration(
                          hintText: context.tr.searchCountry,
                          hintStyle: TextStyle(
                            fontFamily: AppFonts.fontFamilySatoshi,
                            fontFamilyFallback: AppFonts.fontFamilyFallback,
                            fontSize: AppFonts.size14.sp,
                            color: AppColors.textGray,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: AppColors.textGray,
                            size: AppFonts.size20.sp,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s16.w,
                            vertical: AppSpacing.s12.h,
                          ),
                          filled: true,
                          fillColor: AppColors.brandBackground,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: AppColors.borderDeactivated,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: AppColors.borderActivated,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          // StatefulBuilder's setState, which only rebuilds the sheet
                          setSheetState(() {
                            searchQuery = value.toLowerCase().trim();
                            filtered = searchQuery.isEmpty
                                ? List.of(_getCountries(context))
                                : _getCountries(context)
                                      .where(
                                        (c) =>
                                            c.label.toLowerCase().contains(
                                              searchQuery,
                                            ) ||
                                            c.dialCode.contains(searchQuery) ||
                                            c.isoCodeName
                                                .toLowerCase()
                                                .contains(searchQuery),
                                      )
                                      .toList();
                          });
                        },
                      ),
                    ),

                    // 4. Country list (Expanded prevents unbounded height)
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                context.tr.noResultsFound,
                                style: TextStyle(
                                  fontFamily: AppFonts.fontFamilySatoshi,
                                  fontFamilyFallback:
                                      AppFonts.fontFamilyFallback,
                                  fontSize: AppFonts.size14.sp,
                                  color: AppColors.textGray,
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.s16.w,
                                vertical: AppSpacing.s8.h,
                              ),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) => Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.surfaceEmpty,
                              ),
                              itemBuilder: (_, index) {
                                final country = filtered[index];
                                return InkWell(
                                  onTap: () {
                                    // Update parent prefix display
                                    _countryController.selectCountry(
                                      country.country,
                                    );
                                    Navigator.of(sheetCtx).pop();
                                  },
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.s8.w,
                                      vertical: AppSpacing.s12.h,
                                    ),
                                    child: Row(
                                      children: [
                                        // Country flag
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            2.r,
                                          ),
                                          child: SizedBox(
                                            width: 20.w,
                                            height: 14.h,
                                            child: FittedBox(
                                              fit: BoxFit.cover,
                                              child:
                                                  CountryFlag.fromCountryCode(
                                                    country.flagCode,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: AppSpacing.s12.w),

                                        // Country name
                                        Expanded(
                                          child: Text(
                                            country.label,
                                            style: TextStyle(
                                              fontFamily:
                                                  AppFonts.fontFamilySatoshi,
                                              fontSize: AppFonts.size14.sp,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.textBlack,
                                            ),
                                          ),
                                        ),

                                        // Dial code
                                        Text(
                                          country.dialCode,
                                          style: TextStyle(
                                            fontFamily:
                                                AppFonts.fontFamilySatoshi,
                                            fontSize: AppFonts.size14.sp,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.textGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    SizedBox(height: AppSpacing.s16.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCountry = _countryController.country;
    // Determine prefix icon color strictly based on focus
    final Color activeColor = _focusNode.hasFocus
        ? AppColors.brandMain
        : AppColors.textGray;

    return RouteXTextField(
      controller: widget.controller,
      focusNode: _focusNode,
      tintPrefixIcon: false, // Prevents flag emoji from turning solid green
      validator: widget.validator,
      onChanged: widget.onChanged,
      labelText: widget.labelText,
      hintText: widget.hintText,
      labelStyle: widget.labelStyle,
      labelInset: widget.labelInset,
      textStyle: widget.textStyle,
      outlinedErrorIcon: widget.outlinedErrorIcon,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(9),
      ],
      prefixIcon: GestureDetector(
        onTap: _showCountryPickerBottomSheet,
        behavior: HitTestBehavior.opaque, // ensures full tap-area coverage
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: AppSpacing.s12.w,
            end: AppSpacing.s4.w,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Country flag
              ClipRRect(
                borderRadius: BorderRadius.circular(2.r),
                child: SizedBox(
                  width: 20.w,
                  height: 14.h,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: CountryFlag.fromCountryCode(selectedCountry.isoCode),
                  ),
                ),
              ),

              SizedBox(width: AppSpacing.s4.w),

              Text(
                selectedCountry.dialCode,
                style:
                    widget.textStyle ??
                    TextStyle(
                      fontFamily: AppFonts.fontFamilySatoshi,
                      fontFamilyFallback: AppFonts.fontFamilyFallback,
                      fontSize: AppFonts.size14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textBlack,
                    ),
              ),

              SizedBox(width: AppSpacing.s4.w),

              // Dropdown arrow
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: AppFonts.size20.sp,
                color: activeColor,
              ),

              SizedBox(width: AppSpacing.s8.w),

              // Vertical divider (design: a tall hairline between the
              // country selector and the number).
              Container(
                width: 1.w,
                height: 28.h,
                color: AppColors.borderDeactivated,
              ),

              SizedBox(width: AppSpacing.s8.w),
            ],
          ),
        ),
      ),
    );
  }
}
