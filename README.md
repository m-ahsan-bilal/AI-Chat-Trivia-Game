# AI Chat Trivia – Real-Time Multiplayer Chat Game with AI

> A beautiful, animated Flutter app demonstrating **real-time human-AI chat**, **custom trivia gameplay**, and **scalable lobby systems** using WebSockets and open-source LLMs.

---

## 📚 Project Summary

**AI Chat Trivia** is a real-time mobile chat game built in Flutter. Players can join lobbies with other users and AI bots, exchange messages, and participate in periodic trivia rounds. The app features:

* Real-time chat using WebSockets
* AI-driven responses powered by **Hugging Face** open-source models
* Dynamic trivia mini-games triggered after every 8 messages
* Beautiful UI/UX with full custom animations and themes


---

## 📊 Architecture Overview

### Flutter Frontend

```
lib/
├── core/
│   ├── models/         # User, Lobby, Message, Trivia
│   ├── providers/      # ChatProvider for socket/event state
│   ├── services/       # WebSocket + AI interaction
│   └── theme/          # App themes & styling
│
├── ui/
│   ├── screens/        # Home, Lobby, CreateLobby
│   └── widgets/        # Custom animated UI components
│
├── utils/              # Constants, helper functions
└── main.dart           # App entry point
```

### Client <--> Server <--> AI

```mermaid
graph LR
A[Flutter App] -- WebSocket --> B[FastAPI WebSocket Server]
B -- Event/Trivia/Game Msgs --> A
B -- REST or Async Call --> C[HuggingFace API (LLM)]
C -- AI Response --> B --> A
```

---

## 🔍 Features

### 🚀 Real-Time Chat

* Scalable lobby system via WebSockets
* Unlimited rooms/participants
* Auto-bot replies within 2 seconds
* Chat animations + stream typing simulation

### 🎮 Trivia Gameplay

* Trivia question triggered after every 8 messages
* Timer-based question + bot determines winner
* Trivia logic handled server-side and broadcasted

### 🔖 Lobby System

* Create/join public or private lobbies
* Max human/AI seat settings
* See live participant counts on lobby ssettings

### 🎨 Beautiful UI/UX

* Custom animated widgets
* Fully responsive and adaptive
* Smooth transitions and rich theming

### 🤖 AI Integration

* Open-source Hugging Face models (e.g., `facebook/blenderbot-400M-distill`, `microsoft/DialoGPT-medium`)
* Rate-limited token usage
* Prompt strategy:

  * Concise bot instructions
  * Maintain personality per lobby
  * Trivia logic separated from chat

---

## 🔧 Tech Stack

| Layer     | Technology                     |
| --------- | ------------------------------ |
| Frontend  | Flutter 3.32.2                  |
| State     | Provider                       |
| Routing   | GoRouter                       |
| Real-time | WebSocketChannel + FastAPI     |
| Backend   | Python FastAPI (WebSocket)     |
| AI Model  | Hugging Face Inference API     |
| Storage   | SharedPreferences (local only) |

---

## 🔄 Build & Run Instructions

### ⚡ Flutter Setup After Clone

```bash
flutter pub get
flutter run
```

### ⚖️ JSON Generation

```bash
flutter packages pub run build_runner build
```

### 📄 APK Build

```bash
flutter build apk --release
```

APK works on Android 10+

### 📎 Adding Demo Video and APK



<p align="center">
  <a href="./ai_chat_game.apk">
    <img src="https://img.shields.io/badge/Download-APK-blue?style=for-the-badge" alt="Download APK"/>
  </a>
</p>

<p align="center">
  <a href="https://drive.google.com/file/d/1iFilwjoqCSxOWQfA46M4jKCBTAZn33jP/view?usp=drive_link">
    <img src="https://img.shields.io/badge/Alternate%20Download-Google%20Drive-brightgreen?style=for-the-badge" alt="Drive Link"/>
  </a>
</p>

<p align="center">
  <a href="https://drive.google.com/file/d/1Vm1u51dXvkR-Zrqbv-osoIhOXxpGd94E/view?usp=sharing">
    <img src="https://img.shields.io/badge/Watch-Demo%20Video-red?style=for-the-badge&logo=youtube" alt="Demo Video"/>
  </a>
</p>

<!-- ```markdown
🔗 [Click here to download the latest APK](./ai_chat_game.apk)
🔗 [Click here if above is not working](https://drive.google.com/file/d/1iFilwjoqCSxOWQfA46M4jKCBTAZn33jP/view?usp=drive_link)
🎥 [Watch Demo Video][([https://youtu.be/your-demo-video](https://drive.google.com/file/d/1Vm1u51dXvkR-Zrqbv-osoIhOXxpGd94E/view?usp=sharing))](https://drive.google.com/file/d/1iFilwjoqCSxOWQfA46M4jKCBTAZn33jP/view?usp=sharing)
``` -->

---

## 🛡️ Security

* AI API token stored securely in backend
* WebSocket auth included (JWT ready)
* Input sanitization for chat messages

---

## ⚡ Known Limitations

* No offline mode
* AI context resets between lobbies
* Trivia question pool is static (for now)

---

## 📊 Future Enhancements

* AI memory per user/lobby
* Leaderboards and scoring
* Avatar customization and reactions
* Group trivia games with real scores
* Audio responses (TTS) for accessibility


---

## 🙏 Author

**Muhammad Ahsan**
Flutter Developer | AI Chat Systems | Trivia Game Prototyper

---

**Built with ❤️ with Flutter + FastAPI + Web Sockets + AI** 
