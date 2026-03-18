# Quick Guide: Using Bengali Localization

## How to Access Translations in Your Code

### Import the Localization Class
```dart
import 'package:project_iut/l10n/app_localizations.dart';
```

### In Any Widget's Build Method
```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  
  return Text(l10n.login);  // Shows "Login" or "লগইন"
}
```

## All Available Strings

### Authentication
- `l10n.appName` - "DONOR" / "দাতা"
- `l10n.login` - "Login" / "লগইন"
- `l10n.signUp` - "Sign Up" / "সাইন আপ"
- `l10n.registration` - "Registration" / "নিবন্ধন"
- `l10n.password` - "Password" / "পাসওয়ার্ড"
- `l10n.verifyOtp` - "Verify OTP" / "ওটিপি যাচাই করুন"
- `l10n.forgotPassword` - "Forgot Password?" / "পাসওয়ার্ড ভুলে গেছেন?"

### Navigation
- `l10n.home` - "Home" / "হোম"
- `l10n.profile` - "Profile" / "প্রোফাইল"
- `l10n.notifications` - "Notifications" / "বিজ্ঞপ্তি"
- `l10n.settings` - "Settings" / "সেটিংস"

### Blood Donation
- `l10n.wantToBeADonor` - "Want to be a donor?" / "দাতা হতে চান?"
- `l10n.requestForBlood` - "Request for Blood" / "রক্তের অনুরোধ"
- `l10n.urgentRequests` - "Urgent Requests" / "জরুরি অনুরোধ"
- `l10n.bloodRequest` - "Blood Request" / "রক্তের অনুরোধ"
- `l10n.bloodRequests` - "Blood Requests" / "রক্তের অনুরোধসমূহ"
- `l10n.bloodGroup` - "Blood Group" / "রক্তের গ্রুপ"

### Medical Information
- `l10n.medicalCondition` - "Medical Condition" / "চিকিৎসা অবস্থা"
- `l10n.medicalCollege` - "Medical College" / "মেডিকেল কলেজ"
- `l10n.units` - "Units" / "ইউনিট"
- `l10n.patientName` - "Patient Name" / "রোগীর নাম"
- `l10n.hospital` - "Hospital" / "হাসপাতাল"
- `l10n.location` - "Location" / "অবস্থান"

### Profile
- `l10n.editProfile` - "Edit Profile" / "প্রোফাইল সম্পাদনা"
- `l10n.myActivities` - "My Activities" / "আমার কার্যক্রম"
- `l10n.ongoingBloodDonation` - "Ongoing Blood Donation" / "চলমান রক্তদান"
- `l10n.logout` - "Logout" / "লগআউট"
- `l10n.yourImpact` - "Your Impact" / "আপনার অবদান"

### Statistics
- `l10n.livesSaved` - "Lives Saved" / "বাঁচানো জীবন"
- `l10n.totalDonations` - "Total Donations" / "মোট দান"
- `l10n.pendingRequests` - "Pending Requests" / "মুলতুবি অনুরোধ"

### Actions
- `l10n.yes` - "Yes" / "হ্যাঁ"
- `l10n.no` - "No" / "না"
- `l10n.save` - "Save" / "সংরক্ষণ করুন"
- `l10n.submit` - "Submit" / "জমা দিন"
- `l10n.cancel` - "Cancel" / "বাতিল করুন"
- `l10n.confirm` - "Confirm" / "নিশ্চিত করুন"
- `l10n.delete` - "Delete" / "মুছুন"
- `l10n.edit` - "Edit" / "সম্পাদনা"
- `l10n.search` - "Search" / "অনুসন্ধান"
- `l10n.filter` - "Filter" / "ফিল্টার"

### Blood Groups (Same in both languages)
- `l10n.aPositive` - "A+"
- `l10n.aNegative` - "A-"
- `l10n.bPositive` - "B+"
- `l10n.bNegative` - "B-"
- `l10n.abPositive` - "AB+"
- `l10n.abNegative` - "AB-"
- `l10n.oPositive` - "O+"
- `l10n.oNegative` - "O-"

### User Information
- `l10n.name` - "Name" / "নাম"
- `l10n.email` - "Email" / "ইমেইল"
- `l10n.phone` - "Phone" / "ফোন"
- `l10n.address` - "Address" / "ঠিকানা"
- `l10n.age` - "Age" / "বয়স"
- `l10n.gender` - "Gender" / "লিঙ্গ"
- `l10n.male` - "Male" / "পুরুষ"
- `l10n.female` - "Female" / "মহিলা"
- `l10n.other` - "Other" / "অন্যান্য"

### Status & History
- `l10n.donationHistory` - "Donation History" / "দানের ইতিহাস"
- `l10n.requestHistory` - "Request History" / "অনুরোধের ইতিহাস"
- `l10n.date` - "Date" / "তারিখ"
- `l10n.time` - "Time" / "সময়"
- `l10n.status` - "Status" / "অবস্থা"
- `l10n.pending` - "Pending" / "মুলতুবি"
- `l10n.accepted` - "Accepted" / "গৃহীত"
- `l10n.rejected` - "Rejected" / "প্রত্যাখ্যাত"
- `l10n.completed` - "Completed" / "সম্পন্ন"

### Settings
- `l10n.darkMode` - "Dark Mode" / "ডার্ক মোড"
- `l10n.language` - "Language" / "ভাষা"
- `l10n.aboutUs` - "About Us" / "আমাদের সম্পর্কে"
- `l10n.privacyPolicy` - "Privacy Policy" / "গোপনীয়তা নীতি"
- `l10n.termsAndConditions` - "Terms and Conditions" / "শর্তাবলী"
- `l10n.contactUs` - "Contact Us" / "যোগাযোগ করুন"
- `l10n.faq` - "FAQ" / "প্রশ্নোত্তর"

### System Messages
- `l10n.noDataAvailable` - "No data available" / "কোন তথ্য নেই"
- `l10n.loading` - "Loading..." / "লোড হচ্ছে..."
- `l10n.error` - "Error" / "ত্রুটি"
- `l10n.success` - "Success" / "সফল"
- `l10n.retry` - "Retry" / "পুনরায় চেষ্টা করুন"

## Example Usage in Real Code

### Button
```dart
ElevatedButton(
  onPressed: () => handleLogin(),
  child: Text(AppLocalizations.of(context)!.login),
)
```

### AppBar Title
```dart
AppBar(
  title: Text(AppLocalizations.of(context)!.profile),
)
```

### Navigation Bar
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: AppLocalizations.of(context)!.home,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: AppLocalizations.of(context)!.profile,
    ),
  ],
)
```

### Form Labels
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: AppLocalizations.of(context)!.email,
  ),
)
```

### Alert Dialog
```dart
AlertDialog(
  title: Text(AppLocalizations.of(context)!.confirm),
  content: Text(AppLocalizations.of(context)!.areYouDonatingToday),
  actions: [
    TextButton(
      onPressed: () => Navigator.pop(context),
      child: Text(AppLocalizations.of(context)!.no),
    ),
    TextButton(
      onPressed: () => handleDonation(),
      child: Text(AppLocalizations.of(context)!.yes),
    ),
  ],
)
```

## Switch Language Programmatically

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_iut/core/providers/language_provider.dart';

// In a ConsumerWidget or ConsumerStatefulWidget:

// Toggle between English and Bengali
ref.read(languageProvider.notifier).toggleLanguage();

// Set specific language
ref.read(languageProvider.notifier).setLanguage('bn');  // Bengali
ref.read(languageProvider.notifier).setLanguage('en');  // English

// Get current language
final currentLocale = ref.watch(languageProvider).locale;
final isEnglish = currentLocale.languageCode == 'en';
```

## Tips

1. **Use constants for better refactoring**: Define commonly used strings in a helper
2. **Create shorthand access**: Add extension for cleaner code
   ```dart
   extension LocalizationHelper on BuildContext {
     AppLocalizations get l10n => AppLocalizations.of(this)!;
   }
   
   // Usage:
   Text(context.l10n.login)
   ```
3. **Handle null safely**: The `!` operator is safe here because localizations are always available in the app
4. **Test both languages**: Always test UI with both English and Bengali to ensure text fits properly

## Adding New Translations

1. Add to `l10n/app_en.arb`:
   ```json
   "newString": "New Text",
   "@newString": {
     "description": "Description of the string"
   }
   ```

2. Add to `l10n/app_bn.arb`:
   ```json
   "newString": "নতুন টেক্সট",
   "@newString": {
     "description": "Description of the string"
   }
   ```

3. Regenerate:
   ```bash
   flutter gen-l10n
   ```

4. Use in code:
   ```dart
   Text(AppLocalizations.of(context)!.newString)
   ```
