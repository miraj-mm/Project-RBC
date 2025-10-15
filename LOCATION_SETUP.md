# Enhanced Location Services Setup Guide

## Overview
The enhanced location page now provides:
- **Google Places autocomplete** with real-time suggestions
- **Address validation** using Google Geocoding API
- **Current location detection** with GPS
- **Copyable Google Maps links** that update dynamically
- **Real-time address validation** with visual feedback

## Setup Instructions

### 1. Google Maps API Configuration

1. **Get Google Maps API Key:**
   - Go to [Google Cloud Console](https://console.cloud.google.com/)
   - Create a new project or select existing one
   - Enable the following APIs:
     - Places API (New)
     - Geocoding API  
     - Maps JavaScript API (optional, for web)

2. **Configure API Key:**
   - Update your `.env` file:
   ```
   GOOGLE_MAPS_API_KEY=your-actual-api-key-here
   ```

### 2. Android Configuration

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<manifest ...>
    <!-- Add permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.INTERNET" />
    
    <application ...>
        <!-- Add Google Maps API Key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="${GOOGLE_MAPS_API_KEY}" />
    </application>
</manifest>
```

### 3. iOS Configuration

Add to `ios/Runner/Info.plist`:
```xml
<dict>
    <!-- Location permissions -->
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to find nearby services</string>
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs location access to find nearby services</string>
    
    <!-- Google Maps API Key -->
    <key>GoogleMapsAPIKey</key>
    <string>${GOOGLE_MAPS_API_KEY}</string>
</dict>
```

### 4. Web Configuration (Optional)

Add to `web/index.html`:
```html
<head>
    <!-- Other meta tags -->
    <script src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&libraries=places"></script>
</head>
```

## Features

### 1. **Smart Address Search**
- Type any location and get real-time Google Places suggestions
- Tap suggestions to auto-complete address
- Automatic validation and formatting

### 2. **Current Location Detection**
- "Use Current Location" button for GPS detection
- Automatic permission handling with user-friendly error messages
- Reverse geocoding to get readable address from coordinates

### 3. **Dynamic Google Maps Links**
- Automatically generates shareable Google Maps links
- Updates in real-time as you type or select locations
- One-tap copy to clipboard functionality
- Opens directly in Google Maps app

### 4. **Address Validation**
- Real-time validation with visual indicators (✓/✗)
- Loading states during validation
- Error messages for invalid addresses
- Formatted address suggestions

### 5. **Enhanced UX**
- Debounced search to prevent excessive API calls
- Loading indicators for all async operations
- Suggestion dropdown with smart focus handling
- Copy confirmation with snackbar feedback

## Usage in Your App

### Home Screen Integration
The location feature is now integrated into your home screen as a card. Users can:
1. Tap "Set Location" to open the enhanced location screen
2. Search or use current location
3. Get validated address with Google Maps link
4. Copy link to share location

### Programmatic Usage
```dart
// Get current location
final result = await LocationService.getCurrentLocation();
if (result.success) {
  print('Location: ${result.address}');
  print('Coordinates: ${result.latitude}, ${result.longitude}');
}

// Validate address
final validation = await LocationService.validateAddress("123 Main St");
if (validation.isValid) {
  print('Valid address: ${validation.formattedAddress}');
}

// Generate maps link
final link = LocationService.generateShareableLink(
  23.8103, 90.4125, "Dhaka, Bangladesh"
);
```

## API Rate Limits & Costs

### Google Places API
- **Autocomplete**: ~$2.83 per 1,000 requests
- **Place Details**: ~$17.00 per 1,000 requests

### Google Geocoding API
- **Geocoding**: ~$5.00 per 1,000 requests

### Optimization Tips
- Requests are debounced (500ms) to reduce API calls
- Use component restrictions (country:bd) to limit results
- Cache recent results in your app
- Consider implementing session tokens for cost reduction

## Security Considerations

1. **API Key Restrictions:**
   - Restrict API key to your app package name/bundle ID
   - Enable only necessary APIs
   - Monitor usage in Google Cloud Console

2. **Environment Variables:**
   - Never commit `.env` file to version control
   - Use different API keys for development/production

3. **Permissions:**
   - Request location permissions only when needed
   - Provide clear explanations for permission requests

## Troubleshooting

### Common Issues:

1. **"API key not valid"**
   - Check API key in `.env` file
   - Verify APIs are enabled in Google Cloud Console
   - Check package name restrictions

2. **Location permission denied**
   - Check AndroidManifest.xml and Info.plist configuration
   - Test on physical device (not simulator for GPS)

3. **No search suggestions**
   - Verify Places API is enabled
   - Check network connectivity
   - Verify API key has Places API access

4. **Address validation fails**
   - Check Geocoding API is enabled
   - Verify API key permissions
   - Try different address formats

## Files Modified/Created:

### New Files:
- `lib/core/services/location_service.dart` - Google Places & Geocoding integration
- `lib/features/location/widgets/location_feature_card.dart` - Home screen integration
- `LOCATION_SETUP.md` - This setup guide

### Modified Files:
- `lib/features/location/screens/location_input_screen.dart` - Enhanced with all new features
- `lib/core/core.dart` - Added location service export
- `lib/core/config/app_config.dart` - Added Google Maps API key config
- `lib/features/home/screens/home_screen.dart` - Added location feature card
- `pubspec.yaml` - Updated dependencies
- `.env` - Added Google Maps API key configuration

## Next Steps:
1. Get Google Maps API key and update `.env`
2. Configure Android/iOS permissions
3. Test location functionality
4. Monitor API usage and costs
5. Consider implementing location caching for better performance