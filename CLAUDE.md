# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

uPic is a macOS image hosting application built with SwiftUI that supports uploading images to various cloud storage providers and image hosting services. The project is currently on the `feature/v2` branch.

## Build and Development Commands

### Building the Project
```bash
# Build the macOS app
xcodebuild -project uPic.xcodeproj -scheme "uPic(macOS)" -configuration Debug build

# Build for release
xcodebuild -project uPic.xcodeproj -scheme "uPic(macOS)" -configuration Release build

# Open in Xcode
open uPic.xcodeproj
```

### Testing
```bash
# Run unit tests for the main app
xcodebuild test -project uPic.xcodeproj -scheme "uPic(macOS)" -destination 'platform=macOS'

# Run tests for UPicCore module
cd UPicCore && swift test
```

### Package Management
```bash
# Resolve package dependencies
cd UPicCore && swift package resolve

# Update package dependencies
cd UPicCore && swift package update
```

## Architecture Overview

### Project Structure
- **macOS/**: Main SwiftUI application
  - `uPicApp.swift`: Main app entry point with SwiftData setup
  - `ContentView.swift`: Primary UI view with navigation
  - `Item.swift`: SwiftData model for basic items
  - `Extensions/`: Various SwiftUI and Foundation extensions
  - `AppleScript/`: AppleScript integration for automation
- **UPicCore/**: Core upload functionality as Swift Package
  - `Sources/UPicCore/`: Main library source
  - `Tests/`: Unit tests for the core library
- **libs/**: External frameworks (currently contains libminipng.framework)

### UPicCore Architecture
The core library follows a modular uploader pattern:

- **UPicCore.swift**: Main entry point and upload coordinator
- **Model/**: Data models (`HostType`, `HostModel`, `HostConfig`)
- **Uploader/**: Service-specific upload implementations:
  - Aliyun OSS, Amazon S3, Tencent COS
  - Baidu BOS, Upyun USS, Qiniu Kodo
  - GitHub, Gitee, Imgur, Weibo, SM.MS
  - Custom uploaders
- **Extension/**: Utility extensions and helpers
- **Utils/**: Shared utilities for formatting, networking, etc.

### Key Dependencies
- **SwiftUI + SwiftData**: Modern UI and data persistence
- **Alamofire**: HTTP networking
- **Soto**: AWS SDK integration
- **CryptoSwift**: Cryptographic operations
- **HandyJSON**: JSON parsing
- **SWXMLHash**: XML parsing
- **SimpleLogger**: Application logging
- **KeyboardShortcuts**: Hotkey support
- **LaunchAtLogin**: Auto-launch functionality

### Upload Flow
1. User selects image file or drops into app
2. UPicCore validates file type and size limits
3. Routes to appropriate uploader based on host configuration
4. Handles authentication and upload process
5. Returns uploaded URL for user action

### Development Notes
- The app supports multiple image hosting services simultaneously
- Each uploader has its own configuration model and specific implementation
- File validation and size limits are handled centrally in UPicCore
- SwiftUI app uses SwiftData for local persistence
- Logging is configured through SimpleLogger with categorized loggers
- The project includes comprehensive error handling for upload failures

### Testing Strategy
- Unit tests exist in UPicCore module
- Use Xcode's built-in testing framework for UI testing
- Test individual uploaders separately when making changes