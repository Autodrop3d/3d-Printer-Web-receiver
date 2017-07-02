'Form created with the help of Freeform 3 v07-31-2015
'Generated on Jul 02, 2017 at 16:31:51


[setup.MySettings.Window]

    '-----Begin code for #MySettings

    WindowWidth = 1123
    WindowHeight = 449
    UpperLeftX=int((DisplayWidth-WindowWidth)/2)
    UpperLeftY=int((DisplayHeight-WindowHeight)/2)


    '-----Begin GUI objects code

    TexteditorColor$ = "white"
    texteditor #MySettings.EndGcode, 524, 242, 575, 150
    texteditor #MySettings.StartGcode, 525,  51, 575, 150
    ListboxColor$ = "white"
    listbox #MySettings.Selection, SettingsList$(, [Setting.Select],   13,  35, 192, 273
    statictext #MySettings.statictext5, "Settings List (Restart of program required to apply settings)",   9,   7, 501,  27
    listbox #MySettings.SettingsListValues, SettingsListValues$(, [Setting.Select.edit],  210,  35, 301, 273
    button #MySettings.button7,"Save",[mysettings.save], UL,  13, 317, 264,  87
    button #MySettings.button5,"Cancel",[mysettings.cancel], UL, 285, 317, 228,  87
    statictext #MySettings.statictext11, "Start GCODE", 524,  24, 577,  20
    statictext #MySettings.statictext9, "End Gcode", 524, 214, 577,  20

    '-----End GUI objects code

    '-----Begin menu code

    menu #MySettings, "Edit"  ' <-- Texteditor menu.


    '-----End menu code

    open "Settings" for dialog as #MySettings
    print #MySettings, "font ms_sans_serif 10"

