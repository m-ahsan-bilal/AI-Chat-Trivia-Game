# AI Chat Trivia - Flutter MVP Architecture

An AI-powered multiplayer chat trivia game built with Flutter using the **MVP (Model-View-Presenter)** architectural pattern.

## 🏗️ Architecture Overview

This project follows the **MVP (Model-View-Presenter)** pattern, which provides a clean separation of concerns and makes the codebase scalable and maintainable.

### MVP Pattern Implementation

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│      View       │    │   Presenter     │    │     Model       │
│                 │    │                 │    │                 │
│ • UI Components │◄──►│ • Business Logic│◄──►│ • Data Models   │
│ • User Input    │    │ • State Mgmt    │    │ • API Services  │
│ • Display Data  │    │ • Event Handling│    │ • WebSocket     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### **Model Layer**
- **Data Models**: `User`, `Lobby`, `Message` classes with JSON serialization
- **Services**: `ApiService` for REST API calls, `WebSocketService` for real-time communication
- **Responsibility**: Data management, API communication, business entities

#### **View Layer**
- **Screens**: UI components that display data and handle user interactions
- **Widgets**: Reusable UI components in the `shared` folder
- **Responsibility**: User interface, user input handling, data display

#### **Presenter Layer**
- **Presenters**: `HomePresenter`, `LobbyPresenter` that manage business logic
- **Responsibility**: Business logic, state management, coordination between Model and View

## 📁 Project Structure

```
lib/
├── models/                 # Data models
│   ├── user.dart          # User model with JSON serialization
│   ├── lobby.dart         # Lobby model for game rooms
│   └── message.dart       # Message model for chat
│
├── views/                  # UI Layer (View)
│   ├── home/              # Home screen (lobby list)
│   │   └── home_screen.dart
│   ├── lobby/             # Lobby screen (chat & game)
│   │   └── lobby_screen.dart
│   ├── create_lobby/      # Create lobby screen
│   │   └── create_lobby_screen.dart
│   └── shared/            # Reusable widgets
│       └── loading_widget.dart
│
├── presenters/            # Business Logic Layer (Presenter)
│   ├── home_presenter.dart    # Home screen logic
│   └── lobby_presenter.dart   # Lobby screen logic
│
├── services/              # Data Layer (Model)
│   ├── api_service.dart       # REST API client
│   └── websocket_service.dart # WebSocket client
│
├── utils/                 # Utilities and helpers
│   ├── constants.dart         # App constants
│   └── app_theme.dart         # Theme configuration
│
└── main.dart              # App entry point
```

## 🚀 Key Features

### **Real-time Communication**
- WebSocket integration for live chat and game events
- Automatic reconnection handling
- Ping/pong mechanism for connection health

### **REST API Integration**
- HTTP client for lobby management
- Authentication handling
- Error handling and retry logic

### **State Management**
- Stream-based reactive programming
- Presenter pattern for business logic
- Clean separation of concerns

### **Navigation**
- GoRouter for declarative routing
- Deep linking support
- Error handling for invalid routes

## 🛠️ Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0                    # REST API calls
  web_socket_channel: ^2.4.0      # WebSocket communication
  go_router: ^12.1.3              # Navigation and routing
  provider: ^6.1.1                # State management
  json_annotation: ^4.8.1         # JSON serialization

dev_dependencies:
  json_serializable: ^6.7.1       # JSON code generation
  build_runner: ^2.4.7            # Code generation
```

## 🔧 Setup Instructions

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate JSON Code
```bash
flutter packages pub run build_runner build
```

### 3. Run the App
```bash
flutter run
```

## 📱 Screens

### **Home Screen**
- Displays list of available lobbies
- Pull-to-refresh functionality
- Search and filter capabilities
- Create new lobby button

### **Lobby Screen**
- Real-time chat interface
- Player list and status
- Game state management
- Message history

### **Create Lobby Screen**
- Form for lobby creation
- Customizable settings
- Validation and error handling

## 🔄 Data Flow

### **Home Screen Flow**
1. **View** → `HomeScreen` displays UI
2. **Presenter** → `HomePresenter` manages state and API calls
3. **Model** → `ApiService` fetches lobby data
4. **Presenter** → Processes data and updates streams
5. **View** → Listens to streams and updates UI

### **Lobby Screen Flow**
1. **View** → `LobbyScreen` displays chat interface
2. **Presenter** → `LobbyPresenter` manages WebSocket connection
3. **Model** → `WebSocketService` handles real-time communication
4. **Presenter** → Processes incoming messages and events
5. **View** → Updates chat and game state

## 🎨 Theming

The app uses a comprehensive theme system with:
- Light and dark theme support
- Consistent color palette
- Custom text styles
- Reusable component themes

## 🔒 Security

- JWT token-based authentication
- Secure WebSocket connections
- Input validation and sanitization
- Error handling without exposing sensitive data

## 🧪 Testing Strategy

### **Unit Tests**
- Presenter logic testing
- Service method testing
- Model validation testing

### **Widget Tests**
- UI component testing
- User interaction testing
- Navigation testing

### **Integration Tests**
- End-to-end workflow testing
- API integration testing
- WebSocket communication testing

## 📈 Scalability Features

### **Code Organization**
- Clear separation of concerns
- Reusable components
- Consistent naming conventions
- Comprehensive documentation

### **Performance**
- Efficient state management
- Optimized UI rendering
- Background data fetching
- Memory leak prevention

### **Maintainability**
- Modular architecture
- Dependency injection
- Error handling patterns
- Logging and debugging support

## 🤝 Contributing

1. Follow the MVP pattern structure
2. Add comprehensive comments
3. Write unit tests for new features
4. Update documentation
5. Follow Flutter best practices

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For questions or issues:
1. Check the documentation
2. Review existing issues
3. Create a new issue with detailed information

---

**Built with ❤️ using Flutter and MVP Architecture**
