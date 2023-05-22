;--------------------------------------------------------------------------------
; TinySpeech 0.1.2
; Speak any selected text using Text to Speech
;--------------------------------------------------------------------------------
#include <Misc.au3>
#include "lib/TTS.au3"

$appName = "TinySpeech"

; Force single instance
_Singleton($appName)

; Initialize default sound. Abort on error.
$default = _StartTTS()
If Not IsObj($default) Then Die("Failed to initialize Text to Speech." & @CRLF & "Aborting.")

; Define INI file path
$iniFile = @ScriptDir & "\TinySpeech.ini"

; Create the INI file if it does not exist
If Not FileExists($iniFile) Then
  FileWrite($iniFile, "[hotkeys]" & @CRLF & "speak = {F1}" & @CRLF & "pause = {F3}" & @CRLF & "stop = {F4}")
EndIf

; Read INI file
$hotkeySpeak = IniRead($iniFile, "hotkeys", "speak", "{F1}")
$hotkeyPause = IniRead($iniFile, "hotkeys", "pause", "{F3}")
$hotkeyStop = IniRead($iniFile, "hotkeys", "stop", "{F4}")
  
; Set hotkeys
HotKeySet($hotkeySpeak, "DoSpeak")
If Not @Compiled Then HotKeySet("{ESC}", "ExitApp")

; Set tray menu
Opt("TrayOnEventMode", 1) ; Enable OnEvent feature
Opt("TrayMenuMode", 3)    ; 3 = No checkmarks, no default menu

TraySetToolTip($appName & " - Select any text and press F12 to have it spoken. When spoken, F11 to pause and F10 to stop.")
$trayCpl = TrayCreateItem("Open Speech Control Panel")
TrayItemSetOnEvent($trayCpl, "OpenControlPanel")
TrayCreateItem("")

$trayExit = TrayCreateItem("Exit")
TrayItemSetOnEvent($trayExit, "ExitApp")

; Main program loop
While 1
  Sleep(10)
WEnd

; DoSpeak - called when the speak hotkey is pressed
; Will attempt to get the selected text and speak it
Func DoSpeak() 
  Local $text
  Global $default, $hotkeyPause, $hotkeyStop
  HotKeySet($hotkeyStop, "StopSpeak")
  HotKeySet($hotkeyPause, "PauseResumeSpeak")
  $text = GetSelectedText()
  _Resume($default)
  _Speak($default, $text)
EndFunc

Func StopSpeak() 
  Local $text
  Global $default, $hotkeyPause, $hotkeyStop
  HotKeySet($hotkeyStop)
  HotKeySet($hotkeyPause)
  $text = ""
  _Resume($default)
  _Speak($default, $text)
EndFunc

Func PauseResumeSpeak() 
  Global $default
  Static $paused = false
  
  If($paused) Then
    $paused = false
    _Resume($default)
  Else
    $paused = true
    _Pause($default)
  EndIf
EndFunc

; GetSelectedText - sends a Ctrl+C keystroke to the screen to capture the
; selected text
Func GetSelectedText($delay = 10) 
  Local $text, $count
  $text = ""
  ClipPut($text)
  Send("^c")
  $count = 0
  While $count < $delay And $text == ""
    Sleep(100)
    $text = ClipGet() 
    $count += 1
  WEnd
  $text = StringRegExpReplace($text, "[\r\n]+", " ")
  Return $text
EndFunc

; OpenControlPanel - launches the Speech control panel
Func OpenControlPanel()
  $success = _ShowSpeechCpl()
  if(not $success) Then ErrorBox('Failed to open Speech Control Panel')
EndFunc

Func Die($msg) 
  ErrorBox($msg)
  Exit
EndFunc

Func ErrorBox($msg) 
  MsgBox(16, "Error", $msg)
EndFunc

Func ExitApp()
  Exit
EndFunc
