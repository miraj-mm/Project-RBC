# PowerShell Script to Update Navigation Calls to GoRouter
# Run this from the project_iut directory

$files = Get-ChildItem -Path "lib\features" -Recurse -Filter "*.dart"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $updated = $false
    
    # Check if file needs GoRouter imports
    if ($content -match "Navigator\." -and $content -notmatch "import 'package:go_router/go_router.dart'") {
        # Add imports after the first import statement
        $content = $content -replace "(import 'package:flutter/material.dart';)", "`$1`nimport 'package:go_router/go_router.dart';"
        
        # Calculate relative path to app_router.dart
        $depth = ($file.DirectoryName -replace [regex]::Escape("$PWD\lib\features"), "").Split('\').Count - 1
        $relativePath = "../" * $depth + "app_router.dart"
        $content = $content -replace "(import 'package:go_router/go_router.dart';)", "`$1`nimport '$relativePath';"
        
        $updated = $true
    }
    
    # Replace navigation patterns
    $replacements = @{
        # Simple pushNamed
        "Navigator\.of\(context\)\.pushNamed\('/login'\)" = "context.push(AppRoutes.login)"
        "Navigator\.of\(context\)\.pushNamed\('/registration'\)" = "context.push(AppRoutes.registration)"
        "Navigator\.of\(context\)\.pushNamed\('/sign-up'\)" = "context.push(AppRoutes.signUp)"
        "Navigator\.of\(context\)\.pushNamed\('/location'\)" = "context.push(AppRoutes.location)"
        "Navigator\.of\(context\)\.pushNamed\('/main'\)" = "context.push(AppRoutes.main)"
        
        # Replacement navigation
        "Navigator\.of\(context\)\.pushReplacementNamed\('/login'\)" = "context.go(AppRoutes.login)"
        "Navigator\.of\(context\)\.pushReplacementNamed\('/main'\)" = "context.go(AppRoutes.main)"
        
        # pushNamedAndRemoveUntil
        "Navigator\.of\(context\)\.pushNamedAndRemoveUntil\([^,]+,\s*\(route\)\s*=>\s*false\)" = "context.go(AppRoutes.main)"
        
        # MaterialPageRoute navigations
        "Navigator\.push\(\s*context,\s*MaterialPageRoute\(builder:\s*\(context\)\s*=>\s*const\s*EditProfileScreen\(\)\),?\s*\)" = "context.push(AppRoutes.editProfile)"
        "Navigator\.push\(\s*context,\s*MaterialPageRoute\(builder:\s*\(context\)\s*=>\s*const\s*BusRouteInfoScreen\(\)\),?\s*\)" = "context.push(AppRoutes.busRoute)"
        "Navigator\.push\(\s*context,\s*MaterialPageRoute\(builder:\s*\(context\)\s*=>\s*const\s*CreateBloodRequestScreen\(\)\),?\s*\)" = "context.push(AppRoutes.createBloodRequest)"
        "Navigator\.push\(\s*context,\s*MaterialPageRoute\(builder:\s*\(context\)\s*=>\s*const\s*BloodRequestsScreen\(\)\),?\s*\)" = "context.push(AppRoutes.bloodRequests)"
    }
    
    foreach ($pattern in $replacements.Keys) {
        if ($content -match $pattern) {
            $content = $content -replace $pattern, $replacements[$pattern]
            $updated = $true
        }
    }
    
    if ($updated) {
        $content | Set-Content $file.FullName -NoNewline
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "`nMigration complete! Please review the changes and test the app."
Write-Host "Note: Some complex navigation patterns may need manual updates."
