# 🌟 Contributing to Brevity

Thank you for your interest in contributing to **Brevity**! We welcome all kinds of contributions — whether it’s fixing bugs, improving documentation, or building new features.

## 📚 Index

- [⭐ Show Your Support](#show-your-support)
- [🚀 Frontend Setup Guide](#frontend-setup-guide)
  - [1. Fork the Repository](#1-fork-the-repository)
  - [2. Clone Your Fork](#2-clone-your-fork)
  - [3. Set Up Upstream](#3-set-up-upstream)
  - [4. Configure API Keys (.env)](#4-configure-api-keys-env)
- [🧱 Backend Setup Guide (Node.js)](#backend-setup-guide-nodejs)
  - [1. Navigate to the Server Directory](#1-navigate-to-the-server-directory)
  - [2. Install Dependencies](#2-install-dependencies)
  - [3. Configure Environment Variables](#3-configure-environment-variables)
  - [4. Run the Server](#4-run-the-server)
  - [Notes for Backend Contributors](#notes-for-backend-contributors)
- [📍 Backend Route Overview](#backend-route-overview)
- [🔁 Keeping Your Fork Up-to-Date](#keeping-your-fork-up-to-date)
- [🛠️ Making Contributions](#making-contributions)
- [🧩 Working on Issues](#working-on-issues)
- [💬 Community & Support](#community--support)
- [🙌 Thank You!](#thank-you)

## ⭐ Show Your Support <a id="show-your-support"></a>

If you like the project, **give it a star**!  
👉 [Star Brevity on GitHub](https://github.com/Yash159357/BREVITY)

## 🚀 Frontend Setup Guide <a id="frontend-setup-guide"></a>

### 1. Fork the Repository <a id="1-fork-the-repository"></a>

Click the **Fork** button at the top right of [this repo](https://github.com/Yash159357/BREVITY).

### 2. Clone Your Fork <a id="2-clone-your-fork"></a>

```bash
git clone https://github.com/your-username/BREVITY.git
cd BREVTY
````

### 3. Set Up Upstream <a id="3-set-up-upstream"></a>

```bash
git remote add upstream https://github.com/Yash159357/BREVITY.git
git remote -v
```

You should see:

```bash
origin    https://github.com/your-username/BREVITY.git (fetch)
upstream  https://github.com/Yash159357/BREVITY.git (fetch)
```

### 4. Configure API Keys (.env) <a id="4-configure-api-keys-env"></a>

Create a `.env` file at the root of the Flutter project:

```bash
touch .env
```

Add the following:

```env
GEMINI_API_KEY=your_gemini_api_key_here
NEWS_API_KEY=your_news_api_key_here
```

> 🔒 **Never commit this file** — it contains sensitive credentials.

## 🧱 Backend Setup Guide (Node.js) <a id="backend-setup-guide-nodejs"></a>

### 1. Navigate to the Server Directory <a id="1-navigate-to-the-server-directory"></a>

If you haven't already cloned the repo:

```bash
git clone https://github.com/Yash159357/BREVITY.git
```

Then:

```bash
cd BREVTY/server
```

### 2. Install Dependencies <a id="2-install-dependencies"></a>

```bash
npm install
```

### 3. Configure Environment Variables <a id="3-configure-environment-variables"></a>

Create a `.env` file inside the `server` directory:

```bash
touch .env
```

Add the following configuration:

```env
# Server
PORT=5001
NODE_ENV=development

# Database
MONGODB_URI=your_mongo_db_connection_string

# JWT Configuration
JWT_SECRET=your_jwt_secret
JWT_REFRESH_SECRET=your_jwt_refresh_secret
JWT_EXPIRE=7d
JWT_REFRESH_EXPIRE=30d

# Cloudinary (Media Uploads)
CLOUDINARY_CLOUD_NAME=your_cloudinary_name
CLOUDINARY_API_KEY=your_cloudinary_api_key
CLOUDINARY_API_SECRET=your_cloudinary_api_secret

# Security
BCRYPT_ROUNDS=12
MAX_LOGIN_ATTEMPTS=5
LOCK_TIME=30
```

> ⚠️ **Important:** Never commit your `.env` file — it contains sensitive credentials.

### 4. Run the Server <a id="4-run-the-server"></a>

```bash
npm run dev
```

Your backend will be running at:
[http://localhost:5001](http://localhost:5001)

### Notes for Backend Contributors <a id="notes-for-backend-contributors"></a>

* ✅ Ensure MongoDB is running and accessible.
* 🔐 Authentication uses **JWT** (access and refresh tokens).
* ☁️ Images and media uploads use **Cloudinary**.
* 🧪 Test APIs with tools like **Postman** or **Thunder Client**.
* 🗂️ Keep code modular: organize logic in `/routes`, `/controllers`, `/middlewares`, etc.

## 📍 Backend Route Overview <a id="backend-route-overview"></a>

You can view or download a detailed document outlining all backend routes and their usage.

[📄 Download Backend Route Overview](.github/assets/backend_route_overview.docx)

## 🔁 Keeping Your Fork Up-to-Date <a id="keeping-your-fork-up-to-date"></a>

Before starting new work:

```bash
git fetch upstream
git checkout main
git merge upstream/main
```

*Or use rebase for a cleaner commit history:*

```bash
git rebase upstream/main
```

## 🛠️ Making Contributions <a id="making-contributions"></a>

1. **Create a new branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes and commit them**

   ```bash
   git add .
   git commit -m "feat: add [your-feature-name]"
   ```

3. **Push your branch**

   ```bash
   git push origin feature/your-feature-name
   ```

4. **Create a Pull Request**

   * Go to your fork on GitHub
   * Open a **Pull Request** targeting the `main` branch

## 🧩 Working on Issues <a id="working-on-issues"></a>

* 💬 **Comment first**: Claim an issue by leaving a comment.
* ⏳ **7-day inactivity rule**: Issues can be unassigned if there's no activity for 7+ days.
* 🥇 **First come, first serve**: Contributors are assigned based on who claims first.

👉 [Browse Open Issues](https://github.com/Yash159357/BREVITY/issues)

## 💬 Community & Support <a id="community--support"></a>

Need help? Want to discuss features?

Join our **Discord community**:
[https://discord.gg/ueAnrmWr](https://discord.gg/ueAnrmWr)

## 🙌 Thank You! <a id="thank-you"></a>

Whether you're fixing a typo or shipping a huge feature, every contribution matters.
**We appreciate your support and input.** 🎉