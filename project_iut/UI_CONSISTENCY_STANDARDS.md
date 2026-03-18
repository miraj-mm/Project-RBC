# UI Consistency Standards - Project IUT

## Overview
This document outlines the consistent margin, padding, and styling standards applied across the entire Project IUT Flutter application. All elements now align perfectly with the "IUT Blood Donation" section as the reference standard.

## Design System Constants

### Padding & Margins (AppSizes)
```dart
// Small spacing
static const double paddingXS = 4.0;   // Very small internal spacing
static const double paddingS = 8.0;    // Small labels, subtle spacing
static const double paddingM = 16.0;   // Standard spacing (most common)
static const double paddingL = 24.0;   // Large section spacing
static const double paddingXL = 32.0;  // Extra large spacing
static const double paddingXXL = 48.0; // Maximum spacing

// Border Radius
static const double radiusS = 8.0;     // Small radius for buttons
static const double radiusM = 16.0;    // Standard card radius
static const double radiusL = 24.0;    // Large radius for special cards
```

## Layout Structure

### Main Screen Layout
```dart
// Home Screen Structure
Scaffold(
  body: SingleChildScrollView(
    padding: const EdgeInsets.all(AppSizes.paddingM), // 16.0px all around
    child: Column(
      children: [
        // All cards and sections follow this pattern
      ],
    ),
  ),
)
```

### Card Components Standards

#### 1. Profile Section (DynamicProfileSection)
- **Internal Padding**: `AppSizes.paddingM` (16.0px)
- **Border Radius**: `AppSizes.radiusM` (16.0px) 
- **Shadow**: `blurRadius: 10, offset: Offset(0, 5)`
- **Gradient Background**: Primary red theme

#### 2. Blood Donation Section
- **Internal Padding**: `AppSizes.paddingM` (16.0px)
- **Border Radius**: `AppSizes.radiusM` (16.0px)
- **Shadow**: `blurRadius: 10, offset: Offset(0, 5)`
- **Background**: White

#### 3. Location Feature Card
- **Internal Padding**: `AppSizes.paddingM` (16.0px)
- **Border Radius**: `AppSizes.radiusM` (16.0px)
- **Shadow**: `blurRadius: 10, offset: Offset(0, 5)`
- **Background**: White

#### 4. Bus Route Cards
- **Internal Padding**: `AppSizes.paddingM` (16.0px)
- **Border Radius**: `AppSizes.radiusM` (16.0px)
- **Elevation**: 6
- **Fixed Size**: 180x220px

## Section Headers
```dart
// Consistent header styling
Padding(
  padding: EdgeInsets.only(
    left: AppSizes.paddingS,     // 8.0px left
    bottom: AppSizes.paddingS,   // 8.0px bottom
  ),
  child: Text(
    'Section Title',
    style: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Color(0xFF2C3E50),
      letterSpacing: 0.3,
    ),
  ),
)
```

## Spacing Between Elements
- **Between major sections**: `AppSizes.paddingL` (24.0px)
- **Between cards**: `AppSizes.paddingL` (24.0px)  
- **Bottom of scrollview**: `AppSizes.paddingXL` (32.0px)
- **Internal card spacing**: `AppSizes.paddingM` (16.0px)

## Button Consistency
All buttons use the HoverButton component with consistent:
- **Padding**: Varies by context but uses AppSizes constants
- **Border Radius**: Matches parent container style
- **Hover Effects**: Consistent animation and color changes

## Files Updated for Consistency

### Core Components
- ✅ `dynamic_profile_section.dart` - Fixed border radius and shadow
- ✅ `hover_button.dart` - Consistent across all buttons

### Bus Route Components  
- ✅ `bus_route_section.dart` - Added AppSizes imports, fixed header padding
- ✅ `bus_route_card.dart` - Added AppSizes imports, consistent radius/padding
- ✅ `bus_route_info_screen.dart` - Added AppSizes imports, fixed container padding

### Existing Consistent Components
- ✅ `blood_donation_section.dart` - Already using AppSizes consistently
- ✅ `location_feature_card.dart` - Already using AppSizes consistently
- ✅ `home_screen.dart` - Proper main container padding

## Benefits Achieved

1. **Visual Harmony**: All elements align perfectly with consistent margins
2. **Maintainable Code**: Single source of truth for spacing values
3. **Developer Experience**: Easy to apply consistent spacing
4. **Professional Appearance**: Unified design language
5. **Scalability**: Easy to adjust spacing globally by changing AppSizes

## Usage Guidelines

### DO:
- Always use AppSizes constants for padding/margin
- Import `../../../core/core.dart` to access constants
- Use `AppSizes.paddingM` for standard card internal padding
- Use `AppSizes.radiusM` for standard card border radius
- Maintain consistent shadow styles: `blurRadius: 10, offset: Offset(0, 5)`

### DON'T:
- Use hardcoded values like `16.0` or `EdgeInsets.all(16)`
- Mix different shadow styles within similar components
- Use different border radius values for similar cards
- Skip importing core constants

## Result
The entire app now has perfectly aligned elements with consistent spacing, creating a professional and polished user interface that follows Material Design principles while maintaining the app's unique visual identity.