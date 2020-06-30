#Persistent
#SingleInstance Force

Init:
    Menu Tray, Add, Settings
    RegRead, sensX, HKEY_CURRENT_USER\Software\Studio Plus One, sensX
    RegRead, sensY, HKEY_CURRENT_USER\Software\Studio Plus One, sensY

    If (sensX = "") {
        sensX := 4
    }
    
    If (sensY = "") {
        sensY := 4
    }
return

Settings:
    Gui New, -Resize, Settings
    Gui Show, W300 H150
    Gui, Add, Text,, Sensitivity X:
    Gui, Add, Edit, vGuiSensXEdit
    Gui, Add, UpDown, vGuiSensX Range1-50, %sensX%
    Gui, Add, Text,, Sensitivity Y:
    Gui, Add, Edit, vGuiSensYEdit
    Gui, Add, UpDown, vGuiSensY Range1-50, %sensY%
    Gui, Add, Button, Default, OK
return

ButtonOK:
    GuiControlGet, sensX,, GuiSensX
    GuiControlGet, sensY,, GuiSensY
    Gui Hide

    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, sensX, %sensX%
    RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Studio Plus One, sensY, %sensY%
return

#IfWinActive Studio One
MButton::
    MouseGetPos lastX, lastY
    MouseGetPos startX, startY
    SetTimer Timer, 10
return

MButton Up::
    SetTimer Timer, Off
return

PostMW(delta, sft, x, y)
{ ;http://msdn.microsoft.com/en-us/library/windows/desktop/ms645617(v=vs.85).aspx
  CoordMode, Mouse, Screen
  Modifiers := 0x4*sft
  PostMessage, 0x20A, delta << 16 | Modifiers, y << 16 | x ,, A
}

Timer:
    MouseGetPos curX, curY
    dX := (curX - lastX)
    dY := (curY - lastY)
    scrollX := dX * sensX
    scrollY := dY * sensY

    If (dX != 0) {
        PostMW(scrollX, true, startX, startY)
    }
    If (dY != 0) {
        PostMW(scrollY, false, startX, startY)
    }

    lastX := curX
    lastY := curY
return
