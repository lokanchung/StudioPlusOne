#Requires AutoHotkey v2.0
#SingleInstance Force

SetTitleMatchMode("RegEx")
CoordMode("Mouse", "Screen")

; Constants
global kShift := 0x4
global kControl := 0x8
global kNone := 0x0

; Global variables for panning
global lastX := 0, lastY := 0, startX := 0, startY := 0, dragWnd := 0

; Helper function to handle reading registry values with defaults
RegReadDef(KeyName, ValueName, DefaultValue) {
    try return RegRead(KeyName, ValueName)
    catch
        return DefaultValue
}

; Setups / Default Values
global sensX := RegReadDef("HKEY_CURRENT_USER\Software\Studio Plus One", "sensX", 4)
global sensY := RegReadDef("HKEY_CURRENT_USER\Software\Studio Plus One", "sensY", 4)
global mmbPanning := RegReadDef("HKEY_CURRENT_USER\Software\Studio Plus One", "mmbPanning", 1)
global runOnStartup := RegReadDef("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Studio Plus One", "") != ""
global swapZoom := RegReadDef("HKEY_CURRENT_USER\Software\Studio Plus One", "swapZoom", 0)
global auditionNotes := RegReadDef("HKEY_CURRENT_USER\Software\Studio Plus One", "auditionNotes", 0)
global auditionNotesShortcut := RegReadDef("HKEY_CURRENT_USER\Software\Studio Plus One", "auditionNotesShortcut", "XButton2")
global quickErase := RegReadDef("HKEY_CURRENT_USER\Software\Studio Plus One", "quickErase", 0)
global quickEraseShortcut := RegReadDef("HKEY_CURRENT_USER\Software\Studio Plus One", "quickEraseShortcut", "XButton1")

; Setup Tray Menu
A_TrayMenu.Delete()
A_TrayMenu.Add("Settings", ShowSettings)
A_TrayMenu.Add("Run on startup", ToggleRunOnStartup)
if (runOnStartup) {
    A_TrayMenu.Check("Run on startup")
}
A_TrayMenu.AddStandard()

UpdateDynamicHotKeys()

; -----------------------------------------------------------------------------
; Functions
; -----------------------------------------------------------------------------

ToggleRunOnStartup(ItemName, ItemPos, MyMenu) {
    global runOnStartup := !runOnStartup
    if (runOnStartup) {
        MyMenu.Check(ItemName)
        RegWrite(A_ScriptFullPath, "REG_SZ", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Studio Plus One")
    } else {
        MyMenu.UnCheck(ItemName)
        try RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run", "Studio Plus One")
    }
}

UpdateDynamicHotKeys() {
    global auditionNotesShortcut, quickEraseShortcut

    HotIf( (*) => CheckWin() && auditionNotes )
    if (auditionNotesShortcut != "")
        try Hotkey(auditionNotesShortcut, AuditionNotesHotKey, "On")

    HotIf( (*) => CheckWin() && quickErase )
    if (quickEraseShortcut != "")
        try Hotkey(quickEraseShortcut, QuickEraseHotKey, "On")
        
    HotIf ; Reset hotkey context
}

ShowSettings(*) {
    SettingsGui := Gui("-Resize", "Settings")
    
    SettingsGui.Add("Text",, "Sensitivity X:")
    SettingsGui.Add("Edit", "vSensX w50")
    SettingsGui.Add("UpDown", "Range1-50", sensX)
    
    SettingsGui.Add("Text",, "Sensitivity Y:")
    SettingsGui.Add("Edit", "vSensY w50")
    SettingsGui.Add("UpDown", "Range1-50", sensY)
    
    SettingsGui.Add("Checkbox", "vMmbPanning Checked" . mmbPanning, "Middle Mouse Button Panning")
    SettingsGui.Add("Checkbox", "vSwapZoom Checked" . swapZoom, "Swap Ctrl+Wheel, Ctrl+Shift+Wheel")
    
    SettingsGui.Add("Checkbox", "vAuditionNotes Checked" . auditionNotes, "Audition Multiple Notes")
    SettingsGui.Add("Text",, "Audition Multiple Notes Shortcut:")
    SettingsGui.Add("Edit", "vAuditionNotesShortcut w150", auditionNotesShortcut)
    
    SettingsGui.Add("Checkbox", "vQuickErase Checked" . quickErase, "Quick Erase Multiple Notes")
    SettingsGui.Add("Text",, "Quick Erase Multiple Notes Shortcut:")
    SettingsGui.Add("Edit", "vQuickEraseShortcut w150", quickEraseShortcut)
    
    BtnOK := SettingsGui.Add("Button", "Default w80", "OK")
    BtnOK.OnEvent("Click", SaveSettings)
    
    SettingsGui.Show("W400")

    SaveSettings(*) {
        ; Disable old dynamic hotkeys before updating
        HotIf( (*) => CheckWin() && auditionNotes )
        try Hotkey(auditionNotesShortcut, "Off")
        HotIf( (*) => CheckWin() && quickErase )
        try Hotkey(quickEraseShortcut, "Off")
        HotIf

        ; Submit GUI and extract values
        Saved := SettingsGui.Submit()
        
        global sensX := Saved.SensX
        global sensY := Saved.SensY
        global mmbPanning := Saved.MmbPanning
        global swapZoom := Saved.SwapZoom
        global auditionNotes := Saved.AuditionNotes
        global auditionNotesShortcut := Saved.AuditionNotesShortcut
        global quickErase := Saved.QuickErase
        global quickEraseShortcut := Saved.QuickEraseShortcut

        SettingsGui.Destroy()

        ; Save to registry
        RegWrite(sensX, "REG_DWORD", "HKEY_CURRENT_USER\Software\Studio Plus One", "sensX")
        RegWrite(sensY, "REG_DWORD", "HKEY_CURRENT_USER\Software\Studio Plus One", "sensY")
        RegWrite(mmbPanning, "REG_DWORD", "HKEY_CURRENT_USER\Software\Studio Plus One", "mmbPanning")
        RegWrite(swapZoom, "REG_DWORD", "HKEY_CURRENT_USER\Software\Studio Plus One", "swapZoom")
        RegWrite(auditionNotes, "REG_DWORD", "HKEY_CURRENT_USER\Software\Studio Plus One", "auditionNotes")
        RegWrite(auditionNotesShortcut, "REG_SZ", "HKEY_CURRENT_USER\Software\Studio Plus One", "auditionNotesShortcut")
        RegWrite(quickErase, "REG_DWORD", "HKEY_CURRENT_USER\Software\Studio Plus One", "quickErase")
        RegWrite(quickEraseShortcut, "REG_SZ", "HKEY_CURRENT_USER\Software\Studio Plus One", "quickEraseShortcut")

        UpdateDynamicHotKeys()
    }
}

CheckWin() {
    try {
        MouseGetPos(,, &wnd)
        exe := StrLower(WinGetProcessName("ahk_id " wnd))
        if (exe = "studio one.exe" || exe = "studio pro.exe") {
            return true
        }
    }
    return false
}

PostMW(hWnd, delta, modifiers, x, y) {
    CoordMode("Mouse", "Screen")
    lowOrderX := x & 0xFFFF
    highOrderY := y & 0xFFFF
    ; Note: The v1 code passed 'A' as the WinTitle which overrides the hWnd parameter. 
    ; It has been changed to 'ahk_id hWnd' so the targeted window actually receives the message.
    PostMessage(0x20A, (delta << 16) | modifiers, (highOrderY << 16) | lowOrderX,, "ahk_id " hWnd)
}

PanTimer() {
    global lastX, lastY, startX, startY, dragWnd, sensX, sensY
    MouseGetPos(&curX, &curY)
    dX := curX - lastX
    dY := curY - lastY
    scrollX := dX * sensX
    scrollY := dY * sensY
    
    if (dX != 0) {
        PostMW(dragWnd, scrollX, kShift, startX, startY)
    }
    
    if (dY != 0) {
        PostMW(dragWnd, scrollY, kNone, startX, startY)
    }

    lastX := curX
    lastY := curY
}

; -----------------------------------------------------------------------------
; Dynamic Hotkey Callbacks
; -----------------------------------------------------------------------------

AuditionNotesHotKey(ThisHotkey) {
    SendInput("{6}")
    Click("Down")
    KeyWait(ThisHotkey)
    Click("Up")
    SendInput("{1}")
}

QuickEraseHotKey(ThisHotkey) {
    SendInput("{4}")
    Click("Down")
    Loop {
        if GetKeyState("LButton", "P") {
            Click("Up")
            SendInput("{1}")
            Click("Down")
            KeyWait("LButton")
            Click("Up")
            SendInput("{Delete}")
        }
    } Until (!GetKeyState(ThisHotkey, "P"))
    Click("Up")
    SendInput("{1}")
}

; -----------------------------------------------------------------------------
; Contextual Hotkeys
; -----------------------------------------------------------------------------

#HotIf CheckWin() && mmbPanning
MButton:: {
    global lastX, lastY, startX, startY, dragWnd
    MouseGetPos(&lastX, &lastY)
    MouseGetPos(&startX, &startY, &dragWnd)
    SetTimer(PanTimer, 10)
}

MButton Up:: {
    SetTimer(PanTimer, 0)
    if (!mmbPanning) {
        Send("{MButton Up}")
    }
}
#HotIf


#HotIf CheckWin() && swapZoom
^WheelDown:: {
    MouseGetPos(&x, &y, &wheelWnd)
    PostMW(wheelWnd, -32, kShift | kControl, x, y)
}

^WheelUp:: {
    MouseGetPos(&x, &y, &wheelWnd)
    PostMW(wheelWnd, 32, kShift | kControl, x, y)
}

^+WheelDown:: {
    MouseGetPos(&x, &y, &wheelWnd)
    PostMW(wheelWnd, -32, kControl, x, y)
}

^+WheelUp:: {
    MouseGetPos(&x, &y, &wheelWnd)
    PostMW(wheelWnd, 32, kControl, x, y)
}
#HotIf
