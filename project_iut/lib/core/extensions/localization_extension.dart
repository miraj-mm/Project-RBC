import 'package:flutter/widgets.dart';
import 'package:project_iut/l10n/app_localizations.dart';

/// Extension to easily access app localizations from BuildContext
extension LocalizationExtension on BuildContext {
  /// Quick access to AppLocalizations
  /// 
  /// Usage: `context.l10n.home` instead of `AppLocalizations.of(context)!.home`
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
