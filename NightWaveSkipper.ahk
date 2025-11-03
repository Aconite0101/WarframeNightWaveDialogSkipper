; ======================================================================================================================
; ||                                                                                                                  ||
; ||                                         Warframe Nightwave Helper                                                ||
; ||                                             by Aconite0101                                                       ||
; ||                                                                                                                  ||
; || DESCRIPTION:                                                                                                     ||
; || This script provides a simple macro to open and close the Nightwave screen in Warframe.                          ||
; || It features a GUI to easily change the trigger key and the screen location to click.                             ||
; ||                                                                                                                  ||
; || HOW TO USE:                                                                                                      ||
; || 1. Run this script. A settings window will appear.                                                               ||
; || 2. (First Time) Click "Set Location", then click on the Nightwave button in-game to save its position.            ||
; || 3. You can change the trigger key from the default "c" if you wish.                                              ||
; || 4. Click "Save & Reload" to apply your settings. The settings window will reappear. You can minimize it.          ||
; || 5. In-game, press your trigger key. The script will automatically open the menu, click, and close it.              ||
; ||                                                                                                                  ||
; ======================================================================================================================

; --- Ensures the script runs with only one instance and stays active for hotkeys
#SingleInstance, Force
#Persistent

; ==============================================================================
; Configuration Loading
; ==============================================================================
; The script will create and read from a config.ini file in the same directory.
SettingsFile := A_ScriptDir . "\NightwaveHelper_Config.ini"
IniRead, TriggerKey, %SettingsFile%, Settings, TriggerKey, c      ; Default trigger key is 'c'
IniRead, ClickX, %SettingsFile%, Settings, ClickX, 130             ; Default X coordinate
IniRead, ClickY, %SettingsFile%, Settings, ClickY, 825             ; Default Y coordinate

; ==============================================================================
; GUI (Graphical User Interface)
; ==============================================================================
Gui, New, , Nightwave Helper Settings
Gui, Font, s10, Segoe UI
Gui, Margin, 15, 15

Gui, Add, Text, w280, This script helps automate opening and closing the Nightwave screen in Warframe.
Gui, Add, Text, ys+10 Section, `nInstructions:`n1. Press the Trigger Key.`n2. The script automates the rest!`n(Opens menu, clicks location, closes menu)

Gui, Add, GroupBox, x15 y+15 w280 h110, Settings

; --- Trigger Key Setting
Gui, Add, Text, x35 yp+25, Trigger Key:
Gui, Add, Hotkey, x150 yp w120 vGuiTriggerKey, %TriggerKey% ; Use yp to align with the label

; --- Location Setting
Gui, Add, Text, x35 y+15, Click Location (X, Y):
Gui, Add, Text, x150 yp w120 vGuiCoordsText, %ClickX%`, %ClickY% ; Use yp to align with the label
Gui, Add, Button, x150 y+15 w120 gSetLocation, Set Location

; --- Control Buttons
Gui, Add, Button, x15 y+20 w135 gSaveSettings Default, Save & Reload
Gui, Add, Button, x160 yp w135 gExitScript, Exit

; --- Credit Text
Gui, Add, Text, x160 y+10 w135 +Right, by Aconite0101

Gui, Show, , Nightwave Helper Settings

; Set the initial hotkey based on the loaded settings from the INI file
GoSub, ApplyHotkey

return ; End of the auto-execute section of the script

; ==============================================================================
; GUI Subroutines (Button Actions)
; ==============================================================================

; --- This subroutine runs when the "Set Location" button is clicked ---
SetLocation:
    Gui, Hide
    ToolTip, Please LEFT-CLICK the desired Nightwave location.`nPress ESCAPE to cancel.
    
    ; Create a temporary hotkey to handle cancellation
    Hotkey, Escape, CancelSetLocation, On, UseErrorLevel
    
    KeyWait, LButton, D ; Wait for the user to press the left mouse button
    KeyWait, LButton   ; Wait for them to release it
    
    ; If we get here, it means LButton was clicked. Turn off the cancel hotkey.
    Hotkey, Escape, CancelSetLocation, Off
    
    MouseGetPos, tempX, tempY
    GuiControl, , GuiCoordsText, %tempX%`, %tempY% ; Update the text in the GUI
    ToolTip, Location captured: %tempX%, %tempY%
    Sleep, 1500 ; Keep tooltip visible for a moment
    
    ToolTip ; Clear the tooltip
    Gui, Show ; Show the GUI again
return

; --- This is a helper subroutine for the SetLocation action ---
CancelSetLocation:
    Hotkey, Escape, CancelSetLocation, Off ; Turn off this temporary hotkey
    ToolTip, Set location cancelled.
    Sleep, 1500
    ToolTip
    Gui, Show
return

; --- This subroutine runs when the "Save & Reload" button is clicked ---
SaveSettings:
    ; Get the current values from the GUI controls
    GuiControlGet, saveTriggerKey, , GuiTriggerKey
    GuiControlGet, saveCoordsText, , GuiCoordsText
    
    ; Use a regular expression to parse the X and Y coordinates from the text
    RegExMatch(saveCoordsText, "(\d+), (\d+)", Coords)
    saveClickX := Coords1
    saveClickY := Coords2
    
    ; Write the new settings to the INI file
    IniWrite, %saveTriggerKey%, %SettingsFile%, Settings, TriggerKey
    IniWrite, %saveClickX%, %SettingsFile%, Settings, ClickX
    IniWrite, %saveClickY%, %SettingsFile%, Settings, ClickY
    
    MsgBox, 4160, Saved, Settings have been saved. The script will now reload to apply changes.
    Reload
return

; --- This subroutine runs when the GUI is closed or "Exit" is clicked ---
GuiClose:
ExitScript:
    ExitApp
return

; ==============================================================================
; Core Script Logic
; ==============================================================================

; --- This applies the hotkey from the settings ---
ApplyHotkey:
    ; The Hotkey command creates the hotkey dynamically based on the TriggerKey variable
    Hotkey, ifWinActive, ahk_exe Warframe.x64.exe ; Make hotkey only work in Warframe
    Hotkey, %TriggerKey%, MainAction, On
    Hotkey, ifWinActive ; Reset context sensitivity
return

; --- This is the main action that runs when you press the trigger key ---
MainAction:
    ; Temporarily disable the hotkey to prevent it from firing again while the action is running
    Hotkey, %TriggerKey%, MainAction, Off
    
    ; Send Escape to open the main menu
    Send, {Escape}
    
    ; Wait for the menu animation to finish
    Sleep, 400
    
    ; Click at the saved X and Y coordinates to open Nightwave
    Click, %ClickX%, %ClickY%
    
    ; Add a small delay for the Nightwave screen to open
    Sleep, 400
    
    ; Send the final Escape key press to close the menu
    Send, {Escape}
    
    ; Re-enable the hotkey so it can be used again
    Hotkey, %TriggerKey%, MainAction, On
return

