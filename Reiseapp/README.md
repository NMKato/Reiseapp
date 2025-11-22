# 🧳 Reiseapp - AI-Powered Travel Assistant

Eine intelligente Reise-App mit **KI-Sprachassistent** für Hotel- und Flugsuche, entwickelt mit SwiftUI und OpenAI GPT-4.

## ✨ Features

### 🎙️ **AI Voice Assistant**
- **Deutsche Sprachsteuerung** für natürliche Reisesuche
- **OpenAI GPT-4 Integration** mit Function Calling
- **Intelligente Kommandos**: "Suche Hotels in Berlin für 2 Gäste"
- **Text-to-Speech Antworten** in deutscher Sprache

### 🏨 **Reisebuchung**
- **Hotel-Suche** mit Amadeus API Integration
- **Flug-Suche** mit erweiterten Filteroptionen
- **Wetter-Integration** für Reiseziele
- **SwiftData Persistenz** für gespeicherte Reisen

### 🛡️ **Sicherheit & Datenschutz**
- **Sichere API-Key Verwaltung** über Environment Variables
- **Privacy-First Design** - Sprachdaten nur lokal verarbeitet
- **Git-sichere Konfiguration** - keine Secrets im Code

## 🚀 Setup

### 1. Requirements
- **Xcode 15+**
- **iOS 17.0+**
- **OpenAI API Account**

### 2. Installation
```bash
git clone [your-repo-url]
cd Reiseapp
```

### 3. API Keys konfigurieren (WICHTIG)
```bash
# 1. Kopiere das Environment Template
cp .env.example .env

# 2. Füge deinen OpenAI API Key ein
# Bearbeite .env und trage deinen echten API Key ein
```

**Oder in Xcode:**
1. Product → Scheme → Edit Scheme
2. Environment Variables → `OPENAI_API_KEY` = `dein-api-key`

### 4. Privacy Permissions hinzufügen
In Xcode Target Settings → Info Tab:
- `NSMicrophoneUsageDescription`: "KI-Sprachassistent für Reisesuche"
- `NSSpeechRecognitionUsageDescription`: "Spracheingabe für Hotel- und Flugsuche"

### 5. Build & Run
```bash
# In Xcode:
⌘ + R
```

## 🎯 Usage

### Voice Commands (Deutsch)
- "Suche Hotels in **Berlin** für **2 Gäste**"
- "Flüge von **München** nach **Paris** am **15. Juli**"
- "Wie ist das Wetter in **Rom**?"
- "Zeige meine Reisen"
- "Buche das erste Hotel"

### UI Navigation
- **Voice Button**: Unten rechts (Mikrofon-Symbol)
- **Status Bar**: Zeigt aktuellen AI-Status
- **Explore View**: Hauptsuche für Hotels/Flüge
- **Trips View**: Gespeicherte Reisen verwalten

## 🏗️ Architecture

### MVVM + Clean Architecture
```
┌─ Views (SwiftUI)
├─ ViewModels (@MainActor)
├─ Services (API, AI, Speech)
├─ Repositories (SwiftData)
└─ Models (Domain)
```

### AI Architecture
```
Speech Input → OpenAI GPT-4 → Command Parser → App Actions → TTS Output
```

## 🔧 Configuration

### Environment Variables
- `OPENAI_API_KEY`: Dein OpenAI API Schlüssel
- `DEBUG_AI=1`: Aktiviert AI Debug Features
- `AMADEUS_API_KEY`: Für Flug-APIs (optional)

### Build Configurations
- **Debug**: Mit AI Test Button und Extended Logging
- **Release**: Optimiert für App Store

## 🛡️ Security

### API Key Management
- ✅ Keine hardcodierten Schlüssel im Code
- ✅ `.env` Dateien in `.gitignore`
- ✅ Environment Variable Fallbacks
- ✅ Sichere Maskierung in Logs

### Privacy
- ✅ Sprachdaten nur lokal verarbeitet
- ✅ OpenAI API nur für Text-Processing
- ✅ Keine Tracking oder Analytics
- ✅ Privacy Manifests included

## 📱 Screenshots

[TODO: Screenshots hier einfügen]

## 🤝 Contributing

1. Fork das Repository
2. Feature Branch erstellen (`git checkout -b feature/AmazingFeature`)
3. Änderungen commiten (`git commit -m 'Add AmazingFeature'`)
4. Branch pushen (`git push origin feature/AmazingFeature`)
5. Pull Request öffnen

### Development Setup
- Folge dem Setup Guide oben
- Aktiviere `DEBUG_AI=1` für Entwicklung
- Verwende eigene API Keys (nicht teilen!)

## 📄 License

Dieses Projekt ist unter der MIT License lizensiert - siehe [LICENSE](LICENSE) für Details.

## 🙏 Acknowledgments

- **OpenAI** für GPT-4 API
- **Apple** für SwiftUI und Speech Frameworks
- **Amadeus** für Travel APIs
- **Contributors** für Feature Requests und Bug Reports

---

**Made with ❤️ in Germany** | **Powered by AI** 🤖