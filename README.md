# DONOR - Blood Donation & Bus Route App

A comprehensive Flutter application for blood donation management and bus route tracking, built with Supabase as the backend.

## Features

### ✅ Completed Features
- **Authentication Flow**: Login, Registration, OTP Verification, Sign Up
- **User Management**: Profile creation and management  
- **Location Services**: Current location detection and input
- **Modern UI**: Red-themed design matching Figma specifications
- **State Management**: Riverpod for state management
- **Database Integration**: Supabase for backend services

### 🔄 In Development
- Blood donation request system
- Bus route tracking and real-time updates
- Donation history and certificates
- Profile editing and settings

## Tech Stack

- **Frontend**: Flutter 3.35.4
- **State Management**: Riverpod
- **Backend**: Supabase
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth
- **Location**: Geolocator & Geocoding
- **Environment**: flutter_dotenv

## Setup Instructions

### Prerequisites
- Flutter 3.35.4 or higher
- Supabase account
- VS Code or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd project_iut
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Supabase**
   - Create a new project on [Supabase](https://supabase.com)
   - Go to Settings → API to get your credentials

4. **Environment Configuration**
   - Copy `.env.example` to `.env`
   - Update with your Supabase credentials:
   ```env
   SUPABASE_URL=https://your-project-ref.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

5. **Run the app**
   ```bash
   # For development (Chrome)
   flutter run -d chrome
   
   # For Android (requires Android Studio setup)
   flutter run -d android
   ```

## Environment Variables

Create a `.env` file with the following variables:

```env
# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here

# App Configuration
APP_NAME=DONOR
APP_VERSION=1.0.0
```

## Project Structure

```
lib/
├── core/                # Core application logic
├── features/            # Feature-based modules
└── services/            # Services widgets and utilities
```
