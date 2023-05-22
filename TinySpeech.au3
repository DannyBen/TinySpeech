;--------------------------------------------------------------------------------
; TinySpeech 0.1.1
; Speak any selected text using Text to Speech
;--------------------------------------------------------------------------------
#include <Misc.au3>
#include "lib/TTS.au3"

$appName = "TinySpeech"

; Force single instance
_Singleton($appName)

; Initialize default sound. Abort on error.
$default = _StartTTS()
If Not IsObj($default) Then Die("Failed to initialize Text to Speech."&@CRLF&"Aborting.")
	
; Set hotkeys
HotKeySet("^{F12}", "DoSpeak")
;HotKeySet("{F10}", "ExitApp")

; Set tray menu
Opt("TrayOnEventMode",1) ; Enable OnEvent feature
Opt("TrayMenuMode",3)    ; 3 = No checkmarks, no default menu

TraySetToolTip($appName & " - Select any text and press Ctrl+F12 to have it spoken. When spoken, F11 to pause and ESC to stop.")

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
	Global $default
	HotKeySet("{ESC}", "StopSpeak")
	HotKeySet("{F11}", "PauseResumeSpeak")
	$text = GetSelectedText()
	_Resume($default)
	_Speak($default, $text)
EndFunc

Func StopSpeak() 
	Local $text
	Global $default
	HotKeySet("{ESC}")
	HotKeySet("{F11}")
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
	MsgBox(4096, "Debug Info", $text)
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
