# Changelog

All notable changes to this project will be documented here.  
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).  
This project uses [Semantic Versioning](https://semver.org/).

---

## [v0.3.0] - 2025-09-12
### ✨ New Features
- Added **BreathView** screen with synced video and audio breathing exercise.
- Integrated `breath30.mov` video and `breath30.mp3` audio into app resources.
- Locked BreathView to **Light Mode** with white background.

### 🛠 Fixes & Improvements
- Fixed black bars around video playback by overlaying white strips.
- Adjusted framing so animation is fully visible (no cropping top/bottom).
- Cleaned `.gitignore` to ignore Xcode clutter but keep resource media files.
- Removed duplicate ignore rules for `.DS_Store`, `DerivedData/`, etc.

---

## [v0.2.0] - 2025-09-04
### ✨ New Features
- Added notification system with optional half-hourly buzz reminders.
- Implemented **Free Recall Test** screen with timers and skip buttons.

---

## [v0.1.0] - 2025-08-30
### 🎉 Initial Release
- Core checklist screen with 8 activities × 5 checks.
- Reset and Restart functionality.
- App icon and teal/white color palette.
