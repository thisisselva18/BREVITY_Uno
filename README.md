# 🚀 Brevity - Short, Smart, Straight to the point

<p align="center">
  <img src="https://raw.githubusercontent.com/Yash159357/NewsAI/main/assets/logos/applogo.png" width="150"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.29.2-blue?logo=flutter" alt="Flutter Version" />
  <img src="https://img.shields.io/badge/Dart-3.7.2-blue?logo=dart" alt="Dart Version" />
  <img src="https://img.shields.io/badge/License-MIT-green" alt="License" />
  <img src="https://img.shields.io/badge/Version-1.0.0-orange" alt="Version" />
</p>

<p align="center">
  <b>Stay informed effortlessly with real-time news, seamless navigation, and a personalized reading experience.</b>
</p>

---

## 👥 Collaborators

<p align="center">
  <table>
    <tr>
      <td align="center">
        <a href="https://github.com/saysamarth">
          <img src="https://user-images.githubusercontent.com/cccb1dc2-c7b6-4962-bffd-dde402e2c3be" width="100px" alt="Your Name"/>
          <br />
          <sub><b>Samarth Sharma</b></sub>
        </a>
        <br />
        <sub>Full Stack Developer</sub>
      </td>
      <td align="center">
        <a href="https://github.com/Yash159357">
          <img src="" width="100px" alt="Collaborator 1"/>
          <br />
          <sub><b>Yash</b></sub>
        </a>
        <br />
        <sub>Full Stack Developer</sub>
      </td>
    </tr>
  </table>
</p>

---

## ✨ App Demo

<p align="center">
  <a href="https://youtu.be/your-video-link" target="_blank">
    <img src="https://via.placeholder.com/640x360" alt="App Demo Video" width="70%"/>
  </a>
</p>

<details>
<summary>📱 View App Screenshots</summary>
<p align="center">
  <img src="https://via.placeholder.com/270x585" alt="Dashboard Screen" width="24%"/>
  <img src="https://via.placeholder.com/270x585" alt="Analytics Screen" width="24%"/>
  <img src="https://via.placeholder.com/270x585" alt="Transactions Screen" width="24%"/>
  <img src="https://via.placeholder.com/270x585" alt="Profile Screen" width="24%"/>
</p>
</details>

---

## 🌟 Features

### Core Features
- **Infinite Scrolling** - Never hit “the end” – keep scrolling for more stories! 🔄
- **Side Page Navigation** -Bookmark articles, adjust settings, and access more details with ease. 📚
- **Theming Support** - Users can personalize their reading experience by selecting their preferred theme. 🎨
- **Direct Full Article Access** - Easily navigate to the full news article from the app. 🌐
- **Search News** - Quickly find news articles based on keywords or categories. 🔍
- **Shareability** - Effortlessly share the app with friends using share_plus. 🤝

### Technical Highlights

- **State Management** – Uses flutter_bloc for efficient, scalable, and predictable state handling. ⚡
- **Dynamic Routing** – Seamless navigation with go_router for a smooth user experience. 🚦
- **Optimized Caching** – Uses cached_network_image for efficient image loading and reduced data usage. 📶
- **Engaging Animations** – Implements shimmer effects and smooth transitions for a delightful UI. 🎬
- **Modular Architecture** – Clean and maintainable codebase with a well-structured project setup. 🏗️

---

## 🛠️ Tech Stack

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/flutter/flutter-original.svg" alt="Flutter" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/firebase/firebase-original-wordmark.svg" alt="Firebase" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/git/git-original.svg" alt="git" width="50" height="50"/>
  <img src="https://cdn.jsdelivr.net/gh/devicons/devicon@latest/icons/vscode/vscode-original.svg" alt="VScode" width="50" height="50"/>
</p>

- **Frontend**: Flutter, Dart, BLoc for state management
- **Backend**: Firebase (Authentication, Firestore, Functions)
- **Local Storage**: Shared Preferences
- **APIs**: News API, Gemini API

---

### Key Dependencies

- **go_router**: For easy and dynamic navigation between screens.
- **flutter_bloc**: Manages state effectively so that your app stays responsive.
- **firebase_core, firebase_auth, & cloud_firestore**: Integrate Firebase services to power backend functionalities.
- **google_sign_in**: Seamlessly lets users log in with their Google accounts.
- **http**: For robust API calls fetching the latest news data.
- **equatable**: Simplifies comparing objects within your business logic.
- **card_swiper & flutter_card_swiper**: Enhance the user interface with cool card-swipe animations.
- **cached_network_image**: Ensures your images load quickly and cache effectively.
- **shimmer**: Adds attractive shimmer effects during image and content loading.
- **url_launcher**: Allows you to open URLs directly from the app.
- **intl**: Formats dates and times to keep everything neat and localized.
- **gap**: Provides spacing utilities for a cleaner layout.
- **shared_preferences**: Stores user settings and preferences locally.
- **flutter_dotenv**: Manages environment variables securely.
- **share_plus**: Makes sharing content a breeze.
- **showcaseview**: Guides new users with in-app feature showcases.


## 📲 Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/flutterwave.git

# Navigate to project directory
cd flutterwave

# Install dependencies
flutter pub get

# Run the application
flutter run
```

### System Requirements
- Flutter SDK: 3.15.0 or higher
- Dart SDK: 3.2.0 or higher
- iOS: 12.0+
- Android: 5.0+ (API level 21+)

---

## 📖 Code Examples

### Implementing the Dashboard Widget

```dart
class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceModel>(
      builder: (context, model, child) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceSummaryCard(
                    totalBalance: model.totalBalance,
                    monthlyChange: model.monthlyChange,
                  ),
                  SpendingChart(transactions: model.recentTransactions),
                  BudgetProgressList(budgets: model.budgets),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

---

## 🗺️ Roadmap

<p align="center">
  <img src="https://via.placeholder.com/800x300" alt="Product Roadmap" width="80%"/>
</p>

| Timeline | Milestone | Status |
|----------|-----------|--------|
| Q2 2025 | Investment Portfolio Tracking | 🔜 Planned |
| Q3 2025 | AI Financial Advisor | 🔜 Planned |
| Q4 2025 | Group Expense Sharing | 🔜 Planned |
| Q1 2026 | Blockchain Wallet Integration | 🔜 Planned |

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test
```

Test coverage: **94%** 📊

---

## 🤝 Contributing

We welcome contributions to FlutterWave! Check out our [Contributing Guide](CONTRIBUTING.md) to get started.

<p align="center">
  <img src="https://via.placeholder.com/600x250" alt="Contributors" width="70%"/>
</p>

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 💬 Community

<p align="center">
  <a href="https://discord.gg/flutterwave">
    <img src="https://img.shields.io/badge/Discord-Join%20Community-7289DA?style=for-the-badge&logo=discord" alt="Discord" />
  </a>
  <a href="https://twitter.com/flutterwave_app">
    <img src="https://img.shields.io/badge/Twitter-Follow%20Us-1DA1F2?style=for-the-badge&logo=twitter" alt="Twitter" />
  </a>
</p>

---

<p align="center">
  Made with ❤️ by the FlutterWave Team
</p>
