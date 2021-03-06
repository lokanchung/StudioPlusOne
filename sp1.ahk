#Persistent
#SingleInstance Force

SetTitleMatchMode RegEx
CoordMode, Mouse, Screen

; Constants
kShift := 0x4
kControl := 0x8
kNone := 0x0

; Setup Menu
Init:
    Menu Tray, NoStandard
    Menu Tray, Add, Settings
    Menu Tray, Add, Run on startup, RunOnStartup
    Menu Tray, Standard
    RegRead, sensX, HKEY_CURRENT_USER\Software\Studio Plus One, sensX
    RegRead, sensY, HKEY_CURRENT_USER\Software\Studio Plus One, sensY
    RegRead, runOnStartup, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run, Studio Plus One
    RegRead, swapZoom, HKEY_CURRENT_USER\Software\Studio Plus One, swapZoom


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

Settings:
    Gui New, -Resize, Settings
    Gui Show, W400 H200
    Gui, Add, Text,, Sensitivity X:
    Gui, Add, Edit, vGuiSensXEdit
    Gui, Add, UpDown, vGuiSensX Range1-50, %sensX%
    Gui, Add, Text,, Sensitivity Y:
    Gui, Add, Edit, vGuiSensYEdit
    Gui, Add, UpDown, vGuiSensY Range1-50, %sensY%
    Gui, Add, Checkbox, vGuiSwapZoom, Swap Ctrl+Wheel, Ctrl+Shift+Wheel
    GuiControl,,GuiSwapZoom, %swapZoom%
    Gui, Add, Button, Default, OK
return

ButtonOK:
    GuiControlGet, sensX,, GuiSensX
    GuiControlGet, sensY,, GuiSensY
    GuiControlGet, swapZoom,, GuiSwapZoom
    Gui Hide

    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, sensX, %sensX%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, sensY, %sensY%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, swapZoom, %swapZoom%
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
#If

PostMW(hWnd, delta, modifiers, x, y)
{
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
