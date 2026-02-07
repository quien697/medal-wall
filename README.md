# Medal Wall

It is a personal archive for every race I have completed.



## 📝 Overview

**Medal Wall** is an iOS app for archiving race events and results. It allows users to manage races, track medals, and view detailed information for each event and achievement.



## ✨ Features

- Add and manage race events
- Store race results including medals, notes, and outcomes
- Race list and detail views
- Medal list and detail views



## 🛠️ Technologies & Frameworks

- iOS 26
- Swift 6
- SwiftUI
- SwiftData - for local data storage
- Swift Testing - unit & integration tests



## 🔧 Development Tools

- Xcode 26.2
- icons: [SF Symbols](https://developer.apple.com/sf-symbols/)
- Version control: GitHub / Git
- AI tools: [ChatGPT](https://chatgpt.com/), [GitHub Copilot](https://github.com/features/copilot), [AI image generators](https://deepai.org/machine-learning-model/text2img)



## 🧱 Architecture

**MVVM (Model-View-ViewModel)** architecture drives this app:

- Models – Data structures for Medals, Races, Profile, etc.
- **ViewModels** – Business logic and state management
- **Views** – SwiftUI views, structured by feature
- **Repositories / Data** – Handle data storage and retrieval
- **Shared** – Reusable components, UIModels, extensions, and helpers



## 📂 Folder Structure

```text
MedalWall/
├─ Data/ (Repositories)
├─ Features/
│ ├─ Main/
│ ├─ Medal/
│ │  ├─ ViewModels/
│ │  └─ Views/
│ ├─ Profile/
│ ├─ Race/
│ └─ Setting/
├─ Models/
├─ Shared/
│ ├─ Components/
│ ├─ Errors/
│ ├─ Extensions/
│ └─ UIModels/
└─ Resources/
```



## 🚀 Getting Started

1. Open the project in Xcode
2. Build & run on simulator or device



## 🗺 Roadmap

### v1 (Current)

- Core race and medal management
- Race list and detail views
- Medal list and detail views
- Search and filter races and medals
- Local data persistence using SwiftData

### v2 (Planned)

- Profile dashboard with auto-calculated race and medal statistics
- Achievements system with badges and progress-based milestones
- Settings & customization including data sync, export, and appearance options



### v3 (Future Ideas)

- Calendar integration and race reminders
- Map-based visualization of completed races
- Cloud sync and cross-device backup
- Sharing and widgets



## 👨‍💻 Author

**Tsung-Hsun Liu**  
📧 [quien697@gmail.com](mailto:quien697@gmail.com)  
🌐 [tsunghsun.me](https://www.tsunghsun.me)



## 📄 License

MIT License © 2025 Tsung-Hsun Liu
