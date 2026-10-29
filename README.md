# 🗳️ Online Voting System

A secure, full-stack **Online Voting System** built with Java Servlets, JSP, and an embedded H2 database. Supports role-based access (Admin and Voter), election management, candidate tracking, real-time vote casting, SMS broadcast notifications, and an AI-powered voter assistant chatbot.

---

## 🌐 Live Demo

> **🔗 [https://online-voting-system-qux6.onrender.com](https://online-voting-system-qux6.onrender.com)**

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@voting.com` | `admin123` |
| **Voter** | `alice@voting.com` | `voter123` |
| **Voter** | `bob@voting.com` | `voter123` |

> ⚠️ Hosted on Render free tier — may take **30–60 seconds** to wake up if inactive.

---

## ✨ Features

### 👤 Voter Features
- Register and log in securely (with optional Two-Factor Authentication)
- View active and upcoming elections you are eligible for
- Cast votes securely (one vote per election enforced)
- Receive SMS/notification broadcasts from admins
- AI Assistant chatbot to answer voting-related queries
- View past elections and voting receipts

### 🛡️ Admin Features
- Manage Elections (create, activate, close)
- Manage Candidates (add/remove candidates per election)
- Manage Voters (set eligibility per election)
- Manage Users (view all registered users)
- **SMS Broadcast** — send messages to all eligible voters of a specific election
- Audit log tracking
- Fraud detection service

---

## 🛠️ Technologies Used

| Layer | Technology |
|-------|-----------|
| Backend | Java 11+, Jakarta Servlets |
| Frontend | JSP (JavaServer Pages), HTML5, CSS3, JavaScript |
| Database | H2 (embedded, MySQL-compatibility mode) |
| Build Tool | Apache Maven 3.9+ |
| Server | Apache Tomcat 9 (Docker) |
| Hosting | Render.com (Docker deployment) |
| Security | BCrypt password hashing, CSRF filters, Role-based AuthFilter |
| 2FA | TOTP Two-Factor Authentication |
| AI Assistant | Servlet-based context-aware chatbot (ElectionDAO / CandidateDAO) |

---

## 📂 Project Structure

```
Online-voting-system/
├── src/
│   └── main/
│       ├── java/com/voting/
│       │   ├── controller/     # Servlets (Admin, Voter, AI Chat, Auth)
│       │   ├── dao/            # Data Access Objects
│       │   ├── filter/         # Auth & CSRF Filters
│       │   ├── model/          # POJOs (User, Election, Candidate, Vote, SMSLog)
│       │   ├── service/        # Business logic (FraudDetection)
│       │   └── util/           # DB Connection, Password Util, Crypto
│       ├── resources/sql/
│       │   └── schema.sql      # Database schema
│       └── webapp/
│           ├── css/            # Stylesheets
│           ├── js/             # JavaScript
│           ├── jsp/
│           │   ├── admin/      # Admin pages
│           │   ├── voter/      # Voter pages
│           │   └── common/     # Shared pages (login, register, results)
│           └── WEB-INF/
│               └── web.xml     # Servlet configuration
├── Dockerfile                  # Docker deployment config
├── pom.xml                     # Maven build configuration
└── .gitignore
```

---

## ⚙️ Prerequisites (Local Setup)

- Java 11 or higher
- Apache Maven 3.6+
- Git

---

## 🚀 Run Locally

### 1. Clone the Repository
```bash
git clone https://github.com/balachandragonda261-cell/Online-voting-system.git
cd Online-voting-system
```

### 2. Build and Run
```bash
mvn clean tomcat7:run
```

### 3. Open in Browser
```
http://localhost:8080/
```

---

## 🐳 Run with Docker

```bash
docker build -t online-voting-system .
docker run -p 8080:8080 online-voting-system
```

Then open: **http://localhost:8080/**

---

## 🗄️ Database

The application uses an **embedded H2 database** that is auto-initialized on startup via `DatabaseInitializer.java`. Default users are seeded automatically using BCrypt password hashing on every startup.

> The `.mv.db` file is excluded from version control — a fresh database is created automatically on first run.

---

## 🔒 Security Notes

- Passwords are hashed using **BCrypt** (cost factor 10)
- **CSRF tokens** protect all state-changing forms
- Role-based access: Admins cannot access voter-only routes and vice versa
- **Two-Factor Authentication** (TOTP) is available for voters
- No API keys or secrets are stored in the codebase

---

## 🔄 Deploy Updates

Every push to `master` triggers an automatic redeploy on Render:

```bash
git add .
git commit -m "your update message"
git push origin master
# → Render auto-rebuilds and redeploys!
```

---

## 📄 License

This project is for educational purposes.
