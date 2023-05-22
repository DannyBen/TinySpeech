;--------------------------------------------------------------------------------
; Text To Speech Library
; Based on the work of bchris01
;--------------------------------------------------------------------------------

;--------------------------------------------------------------------------------
; Name...........: _StartTTS
; Description ...: Creates a object to be used with Text-to-Speak Functions.
; Return values .: Success - Returns a object
;--------------------------------------------------------------------------------
Func _StartTTS()
	Return ObjCreate("SAPI.SpVoice")
EndFunc  

;--------------------------------------------------------------------------------
; Name...........: _SetRate
; Description ...: Sets the rendering rate of the voice. (How fast the voice talks.)
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $iRate         - Value specifying the speaking rate of the voice. Supported values range from -10 to 10
;--------------------------------------------------------------------------------
Func _SetRate(ByRef $Object, $iRate); Rates can be from -10 to 10
	$Object.Rate = $iRate
EndFunc   

;--------------------------------------------------------------------------------
; Name...........: _SetVolume
; Description ...: Sets the volume of the voice.
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $iVolume       - Value specifying the volume of the voice. Supported values range from 0-100. Default = 100
;--------------------------------------------------------------------------------
Func _SetVolume(ByRef $Object, $iVolume);Volume
	$Object.Volume = $iVolume
EndFunc   

;--------------------------------------------------------------------------------
; Name...........: _SetVoice
; Description ...: Sets the identity of the voice used for text synthesis.
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $sVoiceName    - String matching one of the voices installed.
; Return values .:	Success - Sets object to voice.
;					Failure - Sets @error to 1
;--------------------------------------------------------------------------------
Func _SetVoice(ByRef $Object, $sVoiceName)
	Local $VoiceNames, $VoiceGroup = $Object.GetVoices
	For $VoiceNames In $VoiceGroup
		If $VoiceNames.GetDescription() = $sVoiceName Then
			$Object.Voice = $VoiceNames
			Return
		EndIf
	Next
	Return SetError(1)
EndFunc   

;--------------------------------------------------------------------------------
; Name...........: _GetVoices
; Description ...: Retrives the currently installed voice identitys.
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $bReturn    	  - String of text you want spoken.
;				   |If $bReturn = True then a 0-based array is returned.
;				   |If $bReturn = False then a string seperated by delimiter "|" is returned.
; Return values .:	Success - Returns an array or string containing installed voice identitys.
;--------------------------------------------------------------------------------
Func _GetVoices(ByRef $Object, $bReturn = True)
	Local $sVoices, $VoiceGroup = $Object.GetVoices
	For $Voices In $VoiceGroup
		$sVoices &= $Voices.GetDescription() & '|'
	Next
	If $bReturn Then Return StringSplit(StringTrimRight($sVoices, 1), '|', 2)
	Return StringTrimRight($sVoices, 1)
EndFunc   

;--------------------------------------------------------------------------------
; Name...........: _Speak
; Description ...: Speaks the contents of the text string.
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $sText    	  - String of text you want spoken.
;                  $bWait (false) - If true, waits for the playback to end
;--------------------------------------------------------------------------------
Func _Speak(ByRef $Object, $sText, $bWait=false)
	Local $iFlags = 3
	If $bWait Then $iFlags = 0
	$Object.Speak($sText,$iFlags)
EndFunc   

Func _Pause(ByRef $Object)
	$Object.Pause()
EndFunc   

Func _Resume(ByRef $Object)
	$Object.Resume()
EndFunc   

;--------------------------------------------------------------------------------
; Name...........: _ShowSpeechCpl
; Description ...: Opens the Speech control panel
; Parameters ....: $Object        - Object returned from _StartTTS().
;                  $sText    	  - String of text you want spoken.
;                  $bWait (false) - If true, waits for the playback to end
; Return Value ..: True on success, false on failure
;--------------------------------------------------------------------------------
Func _ShowSpeechCpl()
	Local $cmd
	$cmdXp = @ProgramFilesDir & "\Common files\Microsoft Shared\Speech\sapi.cpl"
	$cmdW7 = @SystemDir & "\Speech\SpeechUX\sapi.cpl"
	If FileExists( $cmdXp ) Then 
		ShellExecute( $cmdXp )
		Return true
	ElseIf FileExists( $cmdW7 ) Then 
		ShellExecute( $cmdW7 )
		Return true
	Else 
		Return false
	EndIf
EndFunc  
