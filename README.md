# ASI

Das "Automatic Setup Installer" Skript

## Benutzung:
Repository als .zip Archiv herunterladen, extrahieren und an einem frei wählbaren Ort die start.bat ausführen.
Das Skript kopiert sich automatisch nach C:\temp und läuft nach dem start von dort aus!

## Features:
- Geschrieben in Powershell
- Kompatibel mit Windows 10 und Windows 11
- Anpassung der Energiespareinstellungen
- Anpassung des PC-Namens

## Derzeit implementierte Programme:
- 7zip
- Firefox
- VLC
- Java
- Teamviewer
- ~Anydesk~ (entfernt, da Teamviewer besser ist)
- Adobe Reader DC
- Notepad++
- OpenVPN Connect
- *Nvidia Treiber*
- *Microsoft Office 365*

## Weitere Funktionen des Skriptes:
- Einrichten des Energiesparmodus
- Ändern des Computernamens
- Setzen der standard Schriftart im System *und in Office Produkten*
- Anbindung der Netzlaufwerke
- ~Einrichtung des VPN Profils in OpenVPN Connect~ (entfernt, da das OpenVPN Backend broken ist)

## Roadmap:
1. Option zum Anlegen von Netzlaufwerkverbindungen ✓
2. Domänenanbindung via Skript reimplementieren