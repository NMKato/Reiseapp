# 🚀 ReiseApp API Setup Guide

## Schnellstart (15 Minuten)

### 1. OpenWeatherMap (Wetter)
✅ **Kostenlos** - 1000 Calls/Tag

1. Registriere dich: https://openweathermap.org/users/sign_up
2. Bestätige Email
3. Dashboard → API Keys → Copy Default Key
4. Einfügen in `APIConfiguration.swift` Zeile 50

**Test URL nach Setup:**
```
https://api.openweathermap.org/data/2.5/weather?q=Berlin&appid=DEIN_KEY
```

### 2. Amadeus (Hotels & Flüge) 
✅ **Kostenlos** - 500 Calls/Monat

1. Registriere dich: https://developers.amadeus.com/register
2. Create New App → Test Environment
3. Copy API Key & Secret
4. Einfügen in `APIConfiguration.swift` Zeilen 54-55

### 3. App testen

Nach dem Einfügen der Keys:
1. Build & Run die App
2. Gehe zum "Entdecken" Tab
3. Teste Wetter-Widget (funktioniert sofort)
4. Hotels & Flüge zeigen Mock-Daten (API Integration folgt)

## Datei zum Bearbeiten:
`/Reiseapp/Services/APIConfiguration.swift`

```swift
// Zeile 50 - OpenWeatherMap
static let openWeatherMap = "HIER_DEIN_KEY"

// Zeilen 54-55 - Amadeus
static let amadeusClientId = "HIER_DEINE_ID"
static let amadeusClientSecret = "HIER_DEIN_SECRET"
```

## Features mit API Keys:

### Mit OpenWeatherMap:
- ✅ Live Wetterdaten in TripDetailView
- ✅ 5-Tage Wettervorhersage
- ✅ Wetter für beliebige Städte

### Mit Amadeus (später):
- 🔜 Echte Hotelsuche
- 🔜 Live Flugpreise
- 🔜 Verfügbarkeiten

## Troubleshooting:

**Wetter funktioniert nicht?**
- Check: Ist der API Key korrekt?
- Test: https://api.openweathermap.org/data/2.5/weather?q=Berlin&appid=DEIN_KEY

**401 Unauthorized?**
- API Key ist falsch oder nicht aktiviert
- Warte 10 Minuten nach Registrierung

**Rate Limit?**
- Free Tier Limits beachten
- OpenWeather: 60 calls/minute
- Amadeus: 10 calls/second

## Sicherheit:

⚠️ **Wichtig für Production:**
- Nutze Environment Variables
- Oder iOS Keychain
- NIE Keys in Git committen!

## Support:
- OpenWeatherMap Docs: https://openweathermap.org/current
- Amadeus Docs: https://developers.amadeus.com/self-service