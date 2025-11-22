# Privacy Permissions Setup

## App Absturz beheben - Mikrofon Berechtigung

Die App stürzt ab mit diesem Fehler:
```
This app has crashed because it attempted to access privacy-sensitive data without a usage description.
The app's Info.plist must contain an NSSpeechRecognitionUsageDescription key
```

### Lösung: Privacy Usage Descriptions hinzufügen

Da das Projekt automatisch eine Info.plist generiert, müssen die Privacy-Beschreibungen in den Target Settings hinzugefügt werden:

#### In Xcode:
1. **Öffne das Projekt in Xcode**
2. **Wähle das "Reiseapp" Target** (blauer Projekt-Icon links)
3. **Gehe zum "Info" Tab**
4. **Klicke auf "+" bei "Custom iOS Target Properties"**
5. **Füge diese Keys hinzu:**

   - **Key**: `NSMicrophoneUsageDescription`
   - **Value**: `Diese App benötigt Zugriff auf das Mikrofon, um Ihre Spracheingaben für die KI-Assistenten-Funktion aufzunehmen. Ihre Sprachdaten werden nur zur Verarbeitung von Reisesuchen verwendet.`

   - **Key**: `NSSpeechRecognitionUsageDescription`  
   - **Value**: `Diese App nutzt Spracherkennung, um Ihnen zu ermöglichen, Hotels und Flüge per Spracheingabe zu suchen. Ihre Spracheingabe wird nur zur Verarbeitung Ihrer Reiseanfragen verwendet.`

#### Alternative: Direkt in Build Settings
1. **Target auswählen → Build Settings**
2. **Suche nach "Info.plist Values"**
3. **Füge hinzu:**
   - `INFOPLIST_KEY_NSMicrophoneUsageDescription = Diese App benötigt Zugriff auf das Mikrofon, um Ihre Spracheingaben für die KI-Assistenten-Funktion aufzunehmen.`
   - `INFOPLIST_KEY_NSSpeechRecognitionUsageDescription = Diese App nutzt Spracherkennung, um Ihnen zu ermöglichen, Hotels und Flüge per Spracheingabe zu suchen.`

### Nach dem Hinzufügen:
1. **Projekt neu builden** (⌘+B)
2. **App starten** - Privacy Dialog wird angezeigt
3. **"Erlauben" auswählen** für Mikrofon-Zugriff
4. **Voice Assistant Button testen** (unten rechts in ExploreView)

### Wichtige Features der AI-Integration:

🎙️ **Voice Commands** (Deutsch):
- "Suche Hotels in Berlin für 2 Gäste"
- "Flüge von München nach Paris"
- "Wie ist das Wetter in Rom?"
- "Zeige meine Reisen"

🔄 **AI Workflow**:
1. User tippt Voice Button → Mikrofon startet
2. Spracherkennung → Text wird zu OpenAI gesendet
3. OpenAI versteht Intent → Generiert structured Command
4. Command wird ausgeführt → App Navigation + API Calls
5. Ergebnis wird angezeigt + per TTS gesprochen

### Troubleshooting:

❌ **"OpenAI API Key not configured"**
→ Siehe SECURITY.md für API Key Setup

❌ **"Spracherkennung wurde verweigert"**
→ Settings → Privacy & Security → Microphone → Reiseapp aktivieren

❌ **Voice Button reagiert nicht**
→ Überprüfe Internetverbindung + API Key Konfiguration