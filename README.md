# ASI

Das "Automatic Setup Installer" Skript

# DAS GUI PROJEKT:
Ich würde gerne eine GUI für mein Skript entwickeln, daher gibt es nun den zweiten Branch namens GUI. Das grafische Interface funktioniert zwar derzeit, jedoch gibt es noch viele Bugs und keine multithreading Implementierung, weshalb das Skript manchmal aussieht als würde es hängen.
Das Projekt benötigt noch sehr viel Arbeit!

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

## Roadmap:
1. Option zum Anlegen von Netzlaufwerkverbindungen ✓
2. Domänenanbindung via Skript reimplementieren
3. Englische Übersetzung des Skriptes und der Repository
