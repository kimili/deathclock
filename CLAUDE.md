# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## General

- Death Clock is a simple MacOS menubar app that gives the user a visual overview of how many weeks, months, or years they have left to live.
- The time left to live can be represented as a series of small blocks, or even single pixels, for each week a user has lived, and how many they have left to live. Past blocks should be faded out or gray. Future blocks should be green.
- User data for the app is simply the user's date of birth, and how long they expect to live, input in years, months, and weeks. If these settings are not set, the user should be prompted for them upon launch.
- Uses SwiftData with `ModelContainer` for persistent storage
- `Item` model stores timestamps as the primary data structure
- Data persistence configured with `isStoredInMemoryOnly: false`
- The app is primarily built using SwiftUI, using AppKit as necessary using NSViewRepresentable.
- Aim to build all functionality using SwiftUI unless there is a feature that is only supported in AppKit.
- Design UI in a way that is idiomatic for the macOS platform and follows Apple Human Interface Guidelines.
- Use SF Symbols for iconography.
- Use the most modern macOS APIs. Since there is no backward compatibility constraint, this app can target the latest macOS version with the newest APIs.
- Use the most modern Swift language features and conventions. Target Swift 6 and use Swift concurrency (async/await, actors) and Swift macros where applicable.

## Code Style

- Do not add excessive comments within function bodies. Only add comments within function bodies to highlight specific details that may not be obvious.
- Use 2 spaces for indentation
- Run swift format -i <path> to format the code in place

## Architecture

### Core Components

- **Death_ClockApp.swift**: Main app entry point with SwiftData model container setup
- **ContentView.swift**: Primary UI view implementing a NavigationSplitView with list/detail pattern
- **Item.swift**: SwiftData model representing timestamped items
- **MenuBarController.swift**: Controls the menu bar integration and status item
- **LifeVisualizationView.swift**: Renders the visual representation of weeks/months/years lived and remaining
- **EditableSettingsView.swift**: Settings interface for user configuration (date of birth, life expectancy)
- **AboutView.swift**: About screen with app information

## Project Configuration

### Targets

- **Death Clock**: Main application target (macOS 14.0+)
- **Death ClockTests**: Unit test target using Swift Testing framework
- **Death ClockUITests**: UI test target for integration testing

### Key Settings

- **Bundle Identifier**: `com.michaelbester.Death-Clock`
- **Deployment Target**: macOS 14.0
- **Development Team**: 93N9WCF9EC
- **App Sandbox**: Enabled with read-only file access permissions
- **Swift Version**: 5.0

### Entitlements

The app uses sandboxing with minimal permissions:

- App sandbox enabled
- User-selected files read-only access

## File Structure

```
Death Clock/
├── Death Clock.xcodeproj/     # Xcode project configuration
├── Death Clock/               # Main app source files
│   ├── Assets.xcassets/       # App icons and assets
│   ├── AboutView.swift        # About screen
│   ├── ContentView.swift      # Main UI view
│   ├── Death_ClockApp.swift   # App entry point
│   ├── EditableSettingsView.swift  # Settings configuration UI
│   ├── Item.swift            # Data model
│   ├── LifeVisualizationView.swift # Life visualization renderer
│   ├── MenuBarController.swift     # Menu bar integration
│   └── Death_Clock.entitlements # App capabilities
├── Death ClockTests/          # Unit tests
└── Death ClockUITests/        # UI tests
```
