; Inno Setup script for the Oncard Windows installer.
; Version is passed in via /DMyAppVersion=... on the ISCC command line.
#ifndef MyAppVersion
#define MyAppVersion "1.0"
#endif

[Setup]
AppName=Oncard
AppVersion={#MyAppVersion}
AppPublisher=josholaf
DefaultDirName={autopf}\Oncard
DefaultGroupName=Oncard
OutputBaseFilename=Oncard-Setup
; OutputDir is resolved relative to the script file, so anchor it
; at the repository root: <root>/installer.
OutputDir={#SourcePath}\..\installer
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64

[Files]
; Source is also relative to the .iss file (scripts/), so climb to repo root.
Source: "..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Oncard"; Filename: "{app}\oncard.exe"; WorkingDir: "{app}"
Name: "{group}\Uninstall Oncard"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Oncard"; Filename: "{app}\oncard.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Additional icons:"

[Run]
Filename: "{app}\oncard.exe"; Description: "Launch Oncard"; Flags: nowait postinstall skipifsilent
