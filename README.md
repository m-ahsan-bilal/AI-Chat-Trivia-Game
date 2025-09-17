# 🎮 AI Chat Trivia – Real-Time Multiplayer Chat Game

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.32.2-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![WebSocket](https://img.shields.io/badge/WebSocket-4f4f4f?style=for-the-badge&logo=socketdotio&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-State_Management-purple?style=for-the-badge)

**A beautiful, animated Flutter app with real-time human-AI chat, custom trivia gameplay, and scalable lobby systems**

[![Backend API](https://img.shields.io/badge/🔗_Backend_API-FastAPI-brightgreen?style=for-the-badge)](https://github.com/your-username/trivia-chat-backend)

</div>

---

## 🎥 Demo Video

<div align="center">
  
  [![Demo Video](https://img.shields.io/badge/▶️_Watch_Full_Demo-Google_Drive-red?style=for-the-badge&logo=googledrive&logoColor=white)](https://drive.google.com/file/d/1Vm1u51dXvkR-Zrqbv-osoIhOXxpGd94E/view?usp=sharing)
  
</div>

*Click above to watch the complete app demonstration showing real-time chat, AI interactions, and trivia gameplay*

---

## 🚀 Features

### 💬 Real-Time Chat System
- **WebSocket Integration** - Instant messaging with sub-second latency
- **AI Bot Interactions** - 5 unique AI personalities respond within 2 seconds
- **Typing Indicators** - See when others are typing in real-time
- **Message History** - Persistent chat history with reply functionality

### 🎯 Interactive Trivia Game
- **Auto-Triggered Questions** - Trivia appears every 8 messages
- **30-Second Timer** - Fast-paced competitive gameplay
- **Real-Time Scoring** - Instant winner announcements
- **AI Participation** - Bots can join trivia rounds

### 🏠 Advanced Lobby System
- **Public & Private Lobbies** - Create or join existing rooms
- **Invite Code System** - Share private room codes
- **Live Participant Count** - See active users and bots
- **Configurable Settings** - Control max players and bot limits

### 🎨 Beautiful UI/UX
- **Custom Animations** - Smooth transitions and micro-interactions
- **Responsive Design** - Works perfectly on all screen sizes
- **Modern Theme System** - Clean, professional interface
- **Stream Typing Effect** - AI responses appear with typing animation

## 🛠️ Tech Stack

<div align="center">

| Frontend | State Management | Communication | Storage |
|----------|------------------|---------------|---------|
| ![Flutter](https://img.shields.io/badge/Flutter_3.32.2-02569B?style=flat-square&logo=flutter) | ![Provider](https://img.shields.io/badge/Provider-purple?style=flat-square) | ![WebSocket](https://img.shields.io/badge/WebSocket-4f4f4f?style=flat-square&logo=socketdotio) | ![SharedPreferences](https://img.shields.io/badge/SharedPrefs-4CAF50?style=flat-square) |
| ![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart) | ![GoRouter](https://img.shields.io/badge/GoRouter-FF6F00?style=flat-square) | ![HTTP](https://img.shields.io/badge/HTTP_Client-02569B?style=flat-square) | ![JSON](https://img.shields.io/badge/JSON-000000?style=flat-square) |

</div>

## 📱 Download & Try

<div align="center">

**📦 Download APK (Android 10+)**

<a href="./ai_chat_game.apk">
  <img src="https://img.shields.io/badge/📱_Download_APK-Direct_Download-blue?style=for-the-badge" alt="Download APK" height="50"/>
</a>

**☁️ Alternative Download**

<a href="https://drive.google.com/file/d/1iFilwjoqCSxOWQfA46M4jKCBTAZn33jP/view?usp=drive_link">
  <img src="https://img.shields.io/badge/☁️_Google_Drive-Alternative_Link-brightgreen?style=for-the-badge" alt="Google Drive Link" height="50"/>
</a>

</div>

---

## ⚡ Quick Start

### Prerequisites
- Flutter 3.32.2 or higher
- Dart SDK
- Android Studio / VS Code
- Backend API running ([Setup Instructions](https://github.com/your-username/trivia-chat-backend))

### Installation

```bash
# Clone repository
git clone https://github.com/m-ahsan-bilal/AI-Chat-Trivia-Game.git
cd AI-Chat-Trivia-Game

# Install dependencies
flutter pub get

# Generate JSON models (if needed)
flutter packages pub run build_runner build

# Run the app
flutter run
```

### Build APK

```bash
# Release APK for Android
flutter build apk --release

# APK will be created in: build/app/outputs/flutter-apk/
```

## 🏗️ Architecture Overview

### Project Structure
```
lib/
├── core/
│   ├── models/         # User, Lobby, Message, Trivia data models
│   ├── providers/      # ChatProvider for WebSocket & state management
│   ├── services/       # WebSocket service & API interactions
│   └── theme/          # App themes & styling constants
├── ui/
│   ├── screens/        # Home, Lobby, CreateLobby screens
│   └── widgets/        # Reusable animated UI components
├── utils/              # Constants, helper functions
└── main.dart           # Application entry point
```

### Communication Flow
```
Flutter App ←→ WebSocket ←→ FastAPI Backend ←→ AI Models (Hugging Face)
     │                                              │
     └── HTTP REST API ←→ Lobby Management ←→ Trivia System
```

## 🤖 AI Integration

### Available Bot Personalities
- **ChatBot** 🤖 - Friendly conversation companion
- **QuizMaster** 🎯 - Trivia expert and game host
- **Cheerleader** ⭐ - Upbeat motivational supporter
- **Philosopher** 🧠 - Thoughtful conversationalist
- **Comedian** 😄 - Witty joke teller

### AI Features
- **Hugging Face Models** - `facebook/blenderbot-400M-distill`, `microsoft/DialoGPT-medium`
- **Context Awareness** - Bots remember recent conversation
- **Personality Consistency** - Each bot maintains unique character
- **Response Timing** - 0.5-1.5 second realistic delays

## 🔧 Configuration

### Backend Connection
Update the WebSocket and API endpoints in your configuration:

```dart
// lib/utils/constants.dart
class ApiConstants {
  static const String baseUrl = 'http://your-backend-url:8080';
  static const String wsUrl = 'ws://your-backend-url:8080';
}
```

### App Settings
- **Message Limit** - 1000 messages per lobby
- **Trivia Frequency** - Every 8 messages
- **Connection Timeout** - 30 seconds
- **Typing Indicator Duration** - 3 seconds

## 📊 Performance

### Optimizations
- **Lazy Loading** - Messages load on demand
- **Connection Pooling** - Efficient WebSocket management
- **Memory Management** - Automatic cleanup of old messages
- **Smooth Animations** - 60 FPS performance on most devices

### Requirements
- **Android** - 10+ (API level 29+)
- **iOS** - 11+ (planned)
- **RAM** - 512MB minimum
- **Storage** - 50MB installation size

## 🔒 Security Features

- **Input Sanitization** - All messages validated before sending
- **WebSocket Authentication** - JWT-ready authentication system
- **Rate Limiting** - Prevents message flooding
- **Safe AI Responses** - Content filtering for appropriate responses

## 🚧 Known Limitations

- **No Offline Mode** - Requires internet connection
- **Static Question Pool** - Trivia questions are predefined
- **AI Context Reset** - Bot memory resets between lobbies
- **Single Language** - English only (currently)

## 🔮 Future Enhancements

### Planned Features
- **🎯 Advanced Scoring System** - Points, leaderboards, achievements
- **👤 Avatar Customization** - Profile pictures and themes
- **🔊 Audio Support** - Text-to-speech for accessibility
- **📱 iOS Version** - Native iOS app
- **🌐 Multi-language** - Support for multiple languages
- **💾 Cloud Sync** - Cross-device message history
- **🎮 Game Modes** - Different trivia formats and challenges

### Technical Improvements
- **Offline Mode** - Cached messages and bot responses
- **Push Notifications** - Message alerts when app is closed
- **Video/Image Sharing** - Rich media support
- **Group Voice Chat** - Audio communication features

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart best practices
- Add tests for new features
- Update documentation
- Ensure backwards compatibility

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

---

<div align="center">

**🔗 Related Projects**

[![Backend API](https://img.shields.io/badge/🔧_Backend_API-FastAPI_Server-009688?style=for-the-badge)](https://github.com/your-username/trivia-chat-backend)

**📞 Contact**

**Muhammad Ahsan** - Flutter Developer & AI Integration Specialist

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/m-ahsan-bilal)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](#)

---

*Built with ❤️ using Flutter + FastAPI + AI*

</div>
