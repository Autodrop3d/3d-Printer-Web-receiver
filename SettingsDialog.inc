'Form created with the help of Freeform 3 v07-15-08
'Generated on Mar 29, 2017 at 19:27:56


[setup.MySettings.Window]

    '-----Begin code for #MySettings

    WindowWidth = 533
    WindowHeight = 449
    UpperLeftX=int((DisplayWidth-WindowWidth)/2)
    UpperLeftY=int((DisplayHeight-WindowHeight)/2)


    '-----Begin GUI objects code

    ListboxColor$ = "white"
    listbox #MySettings.Selection, SettingsList$(, [Setting.Select],   13,  35, 192, 273
    statictext #MySettings.statictext5, "Settings List (Restart of program required to apply settings)",   9,   7, 501,  27
    listbox #MySettings.SettingsListValues, SettingsListValues$(, [Setting.Select.edit],  210,  35, 301, 273
    button #MySettings.button7,"Save",[mysettings.save], UL,  13, 317, 264,  87
    button #MySettings.button5,"Cancel",[mysettings.cancel], UL, 285, 317, 228,  87

    '-----End GUI objects code

    open "Settings" for dialog_modal as #MySettings
    print #MySettings, "font ms_sans_serif 10"

