# Firebase Setup Instructions

## Step 1: Place google-services.json
Copy your `google-services.json` file to:
```
veteran_benefits_app/android/app/google-services.json
```

## Step 2: Update android/build.gradle
Open `android/build.gradle` and add the following:

In the `dependencies` block (around line 8-12), add:
```gradle
classpath 'com.google.gms:google-services:4.4.0'
```

It should look like:
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:8.1.0'
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    classpath 'com.google.gms:google-services:4.4.0'  // Add this line
}
```

## Step 3: Update android/app/build.gradle
Open `android/app/build.gradle` and add at the BOTTOM of the file (after the last line):
```gradle
apply plugin: 'com.google.gms.google-services'
```

## Step 4: Run flutter pub get
After making these changes and placing google-services.json, run:
```bash
cd veteran_benefits_app
flutter pub get
```

## Verification
To verify Firebase is set up correctly, we'll test it when we build the authentication screens.
