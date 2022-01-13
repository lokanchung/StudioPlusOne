; our little test
XButton1::
    SendInput {4}
    Click, Down
    Loop
    {
        if GetKeyState("RButton", "P") 
        {
            Click, Up
            SendInput {1}
            Click, Down
            KeyWait, RButton
            Click, Up
            SendInput {delete}
        }

    }
    Until (not GetKeyState("XButton1", "P"))
    ;KeyWait, XButton1
    Click, Up
    SendInput {1}
return