# Security Configuration für Reiseapp

## API Key Setup (WICHTIG - Sicherheit)

**NIEMALS API-Schlüssel direkt im Code speichern!** Folge diesen Schritten für sichere Konfiguration:

### Option 1: Xcode Environment Variables (Empfohlen)
1. Öffne dein Xcode Projekt
2. Gehe zu Product → Scheme → Edit Scheme...
3. Wähle "Run" links aus
4. Gehe zum "Environment Variables" Tab
5. Klicke auf "+" und füge hinzu:
   - Name: `OPENAI_API_KEY`
   - Value: `dein_openai_api_schlüssel_hier`
6. Klicke auf "Close"

### Option 2: .env File (Alternative)
1. Kopiere `.env.example` zu `.env`
2. Fülle deine echten API-Schlüssel ein
3. **Niemals** `.env` in Git committen!

### Sicherheits-Checkliste
- [ ] API-Schlüssel aus dem Quellcode entfernt
- [ ] `.env` ist in `.gitignore` enthalten
- [ ] API-Schlüssel sind nur in Xcode Scheme oder .env gesetzt
- [ ] Keine Schlüssel in Git History

### Unterstützte API Services
- **OpenAI**: Für AI Assistant Funktionalität
- **Amadeus**: Für Flug- und Hotel-APIs (zukünftig)
- **Weather API**: Für Wetterdaten (zukünftig)

### Bei Problemen
Wenn die App nicht startet oder AI-Features nicht funktionieren, überprüfe:
1. Ist der OpenAI API-Schlüssel korrekt gesetzt?
2. Ist die Internetverbindung aktiv?
3. Sind die Mikrofon-Berechtigungen gewährt?

### Für Development Team
Jeder Entwickler muss seinen eigenen API-Schlüssel konfigurieren:
1. Eigenen OpenAI Account erstellen
2. API-Schlüssel generieren 
3. Lokal in Xcode Scheme eintragen
4. **Niemals** Schlüssel teilen oder in Chat/Email senden!