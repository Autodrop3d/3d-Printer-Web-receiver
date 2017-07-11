
[top]

dim info$(10, 10)


dim SettingsList$(7)
dim SettingsListValues$(7)



SettingsList$(1) = "Com Port number"
SettingsList$(2) = "Baud Speed"    
SettingsList$(3) = "printer Name"
SettingsList$(4) = "Material"
SettingsList$(5) = "Color"
SettingsList$(6) = "Server"
SettingsList$(7) = "Pause After Print"


if fileExists(DefaultDir$, "Settings.txt") then 

    open "Settings.txt" for input as #PrinterSettings
        line input #PrinterSettings, printerComPort$ 
        line input #PrinterSettings, printerBaud$    
        line input #PrinterSettings, printerNamea$    
        line input #PrinterSettings, printerMaterial$
        line input #PrinterSettings, printerColor$  
        line input #PrinterSettings, printerServer$
        line input #PrinterSettings, printerPauseAfterJob$
    close #PrinterSettings
    
    
    

else 
    goto [MySettings.Window]
end if



printerComPort$       = trim$(printerComPort$)
printerBaud$          = trim$(printerBaud$)
printerNamea$         = trim$(printerNamea$)
printerMaterial$      = trim$(printerMaterial$)
printerColor$         = trim$(printerColor$)
printerServer$        = trim$(printerServer$)
printerPauseAfterJob$ = trim$(printerPauseAfterJob$)


oncomerror [trap]

on error goto [errorHandler]



[setup.esp8266.Window]

    '-----Begin code for #esp8266


    WindowWidth = DisplayWidth - 20
    WindowHeight = DisplayHeight - 50
    UpperLeftX=int((DisplayWidth-WindowWidth)/2)
    UpperLeftY=int((DisplayHeight-WindowHeight)/2)


    GRAPHICBOX #esp8266.indi, 255,   10, 25, 45
    textbox #esp8266.terminalsend,  255 + 25,   10, WindowWidth - 255 - 20-150 -25, 45


    button #esp8266.connect,"Send",[terminal.send], ul,  WindowWidth -20-75, 10 , 75, 25
    
    
    
    button #esp8266.connect,"connect",[terminal.connect], ul,  10, 10 , 200, 95
    
    button #esp8266.LoadGcode,"Pause Print",[Pause.print], ul,  10, 110 , 200, 95
    button #esp8266.LoadGcode,"Send Gcode",[send.gcode], ul,  10, 210 , 200, 95
       
    button #esp8266.settings,"Settings",[MySettings.Window], ul,  10, 310 , 200, 95
    
    
    texteditor #esp8266.te, 255, 60, WindowWidth - 255 - 20, WindowHeight - 50 - 35 -65    'The handle for our texteditor is #window.te

    open "3d Printer Web GCODE sender" for window as #esp8266
    print #esp8266, "font courier_new 16"
    print #esp8266, "trapclose [quit.esp8266]"
    print #esp8266.te, "!autoresize";   'Tell the texteditor to resize with the terminal window
    print #esp8266.indi , "fill red"


    

goto [terminal.connect]
    wait






[quit.esp8266] 'End the program
    close #esp8266
    end



[Pause.print]
if printPaused = 0 then printPaused = 1 else printPaused = 0
goto [loop.for.Gcode]






[send.gcode]
print #esp8266.te, "!lines GcodeLinecount" ;
n = 0
SendGcodeFlag = 1
wait



[terminal.connect]
oncomerror [trap2]
if connected = 1 then 
    timer 0
    print #esp8266.indi , "fill red"
    close #comm
    connected = 0 
    
else 
    open "COM" ; printerComPort$ ; ":" ;printerBaud$; ",n,8,1" for random as #comm
    connected = 1
    print #esp8266.indi , "fill green"
    timer 30000, [loop.for.Gcode]
    goto [loop.for.Gcode]
end if
wait



[terminal.send]
if connected <> 1 then notice "Not connected" : wait
print #esp8266.terminalsend, "!contents? text$;"
text$  = text$ + chr$(13)
print #comm, text$ 
wait


[loop.for.Gcode]
    timer 0
    if SendGcodeFlag = 1 then goto [loop]
    
    print shell$("wget -O download.gcode ";chr$(34);printerServer$;"?name=";printerNamea$;"&Color=";printerColor$;"&material=";printerMaterial$;chr$(34))

        open "download.gcode" for input as #mytemfile
            print #esp8266.te, "!contents #mytemfile";
        close #mytemfile   
    
    print #esp8266.te, "!line 1 downloadedGcode$" ;
    


    dim printComments$(10)
    for xxxxxx = 2 to 10
        print  #esp8266.te, "!line ";xxxxxx;" gcodetest$" ;
        printComments$(xxxxxx) = gcodetest$
    next xxxxxx 
    


'notice "File downloaed and shwn"


    if INSTR(downloadedGcode$, ";start") > 0 then 
        print #esp8266.te, "!line 3 PrintJobID$" ;
        
        print #esp8266.te, "!cls"
        

        bla$ = shell$("combine.bat")

        '     cat start.gcode download.gcode end.gcode > out.txt

        'notice "Concatination done"

        open "out.txt" for input as #mytemfile
            print #esp8266.te, "!contents #mytemfile";
        close #mytemfile

        print #esp8266.te, "!lines GcodeLinecount" ;




        n = 0
        SendGcodeFlag = 1
        timer 0

        goto [loop]

    else
        print #esp8266.te, downloadedGcode$ 
    end if
    
    timer 30000, [loop.for.Gcode]
wait


[loop]
timer 0
if lof(#comm) <> 0  then 
    t$ = t$ + input$(#comm, lof(#comm))
    if right$(t$,1) = chr$(10) then 
        t$ = upper$(trim$(t$))
        print t$
        if printPaused = 0 then
        
            if SendGcodeFlag = 1 then
                if t$ = "WAIT" then gosub [send.the.goce.to.the.printer]
                if INSTR("  ";t$, "FANSPEED") > 0 then gosub [send.the.goce.to.the.printer]
                if t$ = "OK 0" then gosub [send.the.goce.to.the.printer]
                if t$ = "OK" then gosub [send.the.goce.to.the.printer]
                if t$ = "RESEND:1" then gosub [REsend.the.goce.to.the.printer]
            else
                PrintJobID$ = right$(PrintJobID$,len(PrintJobID$)-1)
                print shell$("wget -O download.junk ";chr$(34);printerServer$;"?jobID=";PrintJobID$;"&stat=Done";chr$(34))
                SendGcodeFlag = 0
                if upper$(printerPauseAfterJob$) = "TRUE" THEN notice "Printing done. Click ok to continue"
                goto [loop.for.Gcode]
            end if 
        end if
        t$ = ""
    end if
end if
timer 10, [loop]
wait

[REsend.the.goce.to.the.printer]
n = n - 1
[send.the.goce.to.the.printer]
n = n + 1
if n > GcodeLinecount then 
    SendGcodeFlag = 0
    
    print #esp8266.indi , "fill red"
    close #comm
    open "COM" ; printerComPort$ ; ":" ;printerBaud$; ",n,8,1" for random as #comm
    print #esp8266.indi , "fill green"
    return
    
END IF
print  #esp8266.te, "!line "+str$(n)+" GcodeLineToSend$" ;


if left$(GcodeLineToSend$,10) = ";printpage" then
    bla = pauseme( 10 )
    'a Bit of code to print out a page to the default printer
    for xxxxxx = 2 to 10
        lprint printComments$(xxxxxx)
    next xxxxxx  
    dump
    
    bla = pauseme( 30000 )
end if


if left$(GcodeLineToSend$,1) = ";" then goto [send.the.goce.to.the.printer]
if left$(GcodeLineToSend$,1) = "" then goto [send.the.goce.to.the.printer]


print #esp8266.te, "!origin 0 ";n ;
print #comm, GcodeLineToSend$ + chr$(13)
return


[errorHandler]
wait

[trap2]
[trap]


    timer 0
    print #esp8266.indi , "fill red"
    close #comm
    connected = 0 
notice "there was an error"

print "Error string is " + chr$(34) + Err$ + chr$(34)
print "Error number is ";Err

wait


[MySettings.Window]

    SettingsListValues$(1) = printerComPort$ 
    SettingsListValues$(2) = printerBaud$    
    SettingsListValues$(3) = printerNamea$    
    SettingsListValues$(4) = printerMaterial$
    SettingsListValues$(5) = printerColor$  
    SettingsListValues$(6) = printerServer$
    SettingsListValues$(7) = printerPauseAfterJob$
    
    for x = 1 to 7
        if SettingsListValues$(x) = "" then SettingsListValues$(x) = "unset"
    
    next x

'include SettingsDialog.inc
print #MySettings, "trapclose [mysettings.cancel]"

print #MySettings.StartGcode, loadfile$("start.gcode")
print #MySettings.EndGcode,  loadfile$("end.gcode")



wait




[Setting.Select.edit]
print #MySettings.SettingsListValues, "selectionindex? index"
goto [settings.edit.index.value]

[Setting.Select]
print #MySettings.Selection, "selectionindex? index"
goto [settings.edit.index.value]

[settings.edit.index.value]
if index = 0 then wait
newSettingValue$ = SettingsListValues$(index)
prompt "Enter New Value";newSettingValue$
if newSettingValue$ = "" then wait
SettingsListValues$(index) =  newSettingValue$
print #MySettings.SettingsListValues, "reload"
wait


[mysettings.save]
    print #MySettings.StartGcode, "!contents? bla$";
    bla$ = savefile$("start.gcode",bla$)

    print #MySettings.EndGcode, "!contents? bla$";
    bla$ = savefile$("end.gcode", bla$)

    open "Settings.txt" for output as #PrinterSettings
        for x = 1 to 7
            print #PrinterSettings, SettingsListValues$(x)
        next x
    close #PrinterSettings
    
    close #MySettings
WAIT

[mysettings.cancel]
    close #MySettings
WAIT


'-------------------------Functions ---------------------------------------------------------


function wget$(page.to.get$)

	wget$ = shell$("wget ";chr$(34);page.to.get$;chr$(34);" -q -0 -")

end function



function shell$(command$)
    open "msvcrt" for dll as #msvcrt
    command$ = command$ + " > %temp%\lbbcmd.out"
    calldll #msvcrt, "system", command$ as ptr, r as long
    close #msvcrt
    tmp$ = space$(260)
    calldll #kernel32, "GetTempPathA", 260 as long, tmp$ as ptr, r as long
    open left$(tmp$,r) + "lbbcmd.out" for input as #tmp
    shell$ = input$(#tmp, lof(#tmp))
    close #tmp
end function








function pauseme( mil)
    t0=time$("ms")
    while time$("ms")<t0+mil
        scan
    wend
end function





function ReplaceString$(ere$,repl$,in$,occ$,pos)

' Function to replace expressions in strings

'

' Usage:

'

'   ReplaceString$({expression},{replacement},{string},{occurrances},{startposition})

'

'       expression ...... string to be replaced

'       replacement ..... substitute for expression

'       string .......... string to be parsed

'       occurrences ..... ALL -> replaces all occurrences

'                         else the specified number

'       startposition ... position to start substitution

'

'   returns altered string

    ReplaceString$ = in$

    if upper$(occ$) = "ALL" then

        number = len(in$)

    else

        number = val(occ$)

    end if

    if pos < 0 then pos = 0



    while instr(ReplaceString$,ere$,pos) > 0

        pos = instr(ReplaceString$,ere$,pos)



        ReplaceString$ = left$(ReplaceString$,pos - 1) + repl$ + mid$(ReplaceString$,pos + len(ere$))



        if upper$(occ$) = "ALL" and number > 1 then

            pos = pos + len(repl$)

            number = number - 1

        else

            pos = len(ReplaceString$)

        end if

    wend

end function




function savefile$(file.location$,stuff.to.write$)

    open file.location$ for output as #jjjj

         print #jjjj, stuff.to.write$

    close #jjjj

end function





function loadfile$(file.location$)

 
    	open file.location$ for input as #jjjj

        	loadfile$ = Input$(#jjjj, LOF(#jjjj))

    	close #jjjj

end function 




function fileExists(path$, filename$)
  'dimension the array info$( at the beginning of your program
  files path$, filename$, info$()
  fileExists = val(info$(0, 0))  'non zero is true
end function





