# News Agent

A comprehensive news aggregation and delivery system with multiple client interfaces. This project consists of three main components: a Node.js server, a Python web client, and a Flutter mobile application.

## Project Structure

```
news-agent/
├── agent-server/     # Node.js backend server
├── agent-client/     # Python web client
└── agent-flutter/    # Flutter mobile application
```

## Components

### 1. Server (agent-server)
- Built with Node.js
- Handles news aggregation and API endpoints
- Manages news sources and data processing
- Provides RESTful API for clients

### 2. Web Client (agent-client)
- Python-based web application
- Flask web interface
- Displays news content in a browser
- Templates for news presentation

### 3. Mobile App (agent-flutter)
- Cross-platform mobile application
- Built with Flutter
- Native mobile experience
- Supports Android and iOS

## Setup Instructions

### Server Setup
1. Navigate to the server directory:
   ```bash
   cd agent-server
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the server:
   ```bash
   node server.js
   ```

### Web Client Setup
1. Navigate to the client directory:
   ```bash
   cd agent-client
   ```
2. Create a virtual environment (optional but recommended):
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the application:
   ```bash
   python app.py
   ```

### Flutter App Setup
1. Navigate to the Flutter project directory:
   ```bash
   cd agent-flutter
   ```
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Features
- Real-time news aggregation
- Multiple news sources integration
- Cross-platform support
- Responsive web interface
- Native mobile experience
- RESTful API architecture

## Requirements
- Node.js (for server)
- Python 3.x (for web client)
- Flutter SDK (for mobile app)
- Modern web browser
- Android Studio / Xcode (for mobile development)

## Contributing
1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.
