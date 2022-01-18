#Persistent
#SingleInstance Force

SetTitleMatchMode RegEx
CoordMode, Mouse, Screen

; Constants
kShift := 0x4
kControl := 0x8
kNone := 0x0

; Setups
Init:
    Menu Tray, NoStandard
    Menu Tray, Add, Settings
    Menu Tray, Add, Run on startup, RunOnStartup
    Menu Tray, Standard
    RegRead, sensX, HKEY_CURRENT_USER\Software\Studio Plus One, sensX
    RegRead, sensY, HKEY_CURRENT_USER\Software\Studio Plus One, sensY
    RegRead, runOnStartup, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One
    RegRead, swapZoom, HKEY_CURRENT_USER\Software\Studio Plus One, swapZoom
    RegRead, auditionNotes, HKEY_CURRENT_USER\Software\Studio Plus One, auditionNotes
    RegRead, auditionNotesShortcut, HKEY_CURRENT_USER\Software\Studio Plus One, auditionNotesShortcut
    RegRead, quickErase, HKEY_CURRENT_USER\Software\Studio Plus One, quickErase
    RegRead, quickEraseShortcut, HKEY_CURRENT_USER\Software\Studio Plus One, quickEraseShortcut

    ; Default Values
    If (sensX = "") {
        sensX := 4
    }

    If (sensY = "") {
        sensY := 4
    }

    If (runOnStartup = "") {
        runOnStartup := false
    } Else {
        runOnStartup := true
        Menu Tray, Check, Run on startup
        RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One, %A_ScriptFullPath%
    }

    If (swapZoom = "") {
        swapZoom := false
    }

    If (auditionNotes = "") {
        auditionNotes := false
    }

    If (auditionNotesShortcut = "") {
        auditionNotesShortcut := "XButton2"
    }

    If (quickErase = "") {
        quickErase := false
    }

    If (quickEraseShortcut = "") {
        quickEraseShortcut := "XButton1"
    }

    GOSUB UpdateDynamicHotKeys
return

RunOnStartup:
    If (runOnStartup) {
        Menu %A_ThisMenu%, UnCheck, %A_ThisMenuItem%
        runOnStartup := false
        RegDelete, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One
    } Else {
        Menu %A_ThisMenu%, Check, %A_ThisMenuItem%
        runOnStartup := true
        RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One, %A_ScriptFullPath%
    }
return

UpdateDynamicHotKeys:
    Hotkey, %auditionNotesShortcut%, AuditionNotesHotKey
    Hotkey, %quickEraseShortcut%, quickEraseHotKey
return

; Settings Menu
Settings:
    Gui New, -Resize, Settings
    Gui Show, W400 H250
    Gui, Add, Text,, Sensitivity X:
    Gui, Add, Edit, vGuiSensXEdit
    Gui, Add, UpDown, vGuiSensX Range1-50, %sensX%
    Gui, Add, Text,, Sensitivity Y:
    Gui, Add, Edit, vGuiSensYEdit
    Gui, Add, UpDown, vGuiSensY Range1-50, %sensY%
    Gui, Add, Checkbox, vGuiSwapZoom, Swap Ctrl+Wheel, Ctrl+Shift+Wheel
    GuiControl,,GuiSwapZoom, %swapZoom%
    Gui, Add, Checkbox, vGuiAuditionNotes, Audition Multiple Notes
    GuiControl,,GuiAuditionNotes, %auditionNotes%
    GUI, Add, Edit, vGuiAuditionNotesShortcut, Audition Multiple Notes Shortcut
    GuiControl,,GuiAuditionNotesShortcut, %auditionNotesShortcut%
    Gui, Add, Checkbox, vGuiQuickErase, Quick Erase Multiple Notes
    GuiControl,,GuiQuickErase, %quickErase%
    GUI, Add, Edit, vGuiQuickEraseShortcut, Quick Erase Multiple Notes Shortcut
    GuiControl,,GuiQuickEraseShortcut, %QuickEraseShortcut%
    Gui, Add, Button, Default, OK
return

ButtonOK:
    GuiControlGet, sensX,, GuiSensX
    GuiControlGet, sensY,, GuiSensY
    GuiControlGet, swapZoom,, GuiSwapZoom
    GuiControlGet, auditionNotes,, GuiAuditionNotes
    GuiControlGet, auditionNotesShortcut,, GuiAuditionNotesShortcut
    GuiControlGet, quickErase,, GuiQuickErase
    GuiControlGet, quickEraseShortcut,, GuiQuickEraseShortcut

    Gui Hide

    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, sensX, %sensX%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, sensY, %sensY%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, swapZoom, %swapZoom%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, auditionNotes, %auditionNotes%
    RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Studio Plus One, auditionNotesShortcut, %auditionNotesShortcut%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, quickErase, %quickErase%
    RegWrite, REG_SZ, HKEY_CURRENT_USER\Software\Studio Plus One, quickEraseShortcut, %quickEraseShortcut%

    GOSUB UpdateDynamicHotKeys
return

CheckWin() {
    MouseGetPos ,,, wnd
    WinGet, exe, ProcessName, ahk_id %wnd%
    StringLower, exe, exe

    If (exe = "studio one.exe") {
        return true
    }
    return false
}

#If CheckWin()
MButton::
    MouseGetPos lastX, lastY
    MouseGetPos startX, startY, dragWnd
    SetTimer Timer, 10
return

MButton Up::
    SetTimer Timer, Off
return

#If CheckWin() and swapZoom
^WheelDown::
    MouseGetPos x, y, wheelWnd
    PostMW(wheelWnd, -32, kShift | kControl, x, y)
return

^WheelUp::
    MouseGetPos x, y, wheelWnd
    PostMW(wheelWnd, 32, kShift | kControl, x, y)
return

^+WheelDown::
    MouseGetPos x, y, wheelWnd
    PostMW(wheelWnd, -32, kControl, x, y)
return

^+WheelUp::
    MouseGetPos x, y, wheelWnd
    PostMW(wheelWnd, 32, kControl, x, y)
return

#If CheckWin() and auditionNotes
AuditionNotesHotkey:
    SendInput {6}
    Click, Down
    KeyWait, %auditionNotesShortcut%
    Click, Up
    SendInput {1}
return

#If CheckWin() and quickErase
QuickEraseHotkey:
    SendInput {4}
    Click, Down
    Loop {
        if GetKeyState("LButton", "P") {
            Click, Up
            SendInput {1}
            Click, Down
            KeyWait, LButton
            Click, Up
            SendInput {delete}
        }
    }
    Until (not GetKeyState(quickEraseShortcut, "P"))
    Click, Up
    SendInput {1}
return

PostMW(hWnd, delta, modifiers, x, y) {
    CoordMode, Mouse, Screen
    PostMessage, 0x20A, delta << 16 | modifiers, y << 16 | x ,, A
}

Timer:
    MouseGetPos curX, curY
    dX := (curX - lastX)
    dY := (curY - lastY)
    scrollX := dX * sensX
    scrollY := dY * sensY
    
    If (dX != 0) {
        PostMW(dragWnd, scrollX, kShift, startX, startY)
    }
    
    If (dY != 0) {
        PostMW(dragWnd, scrollY, kNone, startX, startY)
    }

    lastX := curX
    lastY := curY
return
