'nomainwin
'print httpget$("http://libertybasic.com")

  dim info$(10, 10)



if fileExists(DefaultDir$, "Settings.txt") then 

    open "Settings.txt" for input as #PrinterSettings
        line input #PrinterSettings, printerComPort$ 
        line input #PrinterSettings, printerBaud$    
        line input #PrinterSettings, printerName$    
        line input #PrinterSettings, printerMaterial$
        line input #PrinterSettings, printerColor$  
        line input #PrinterSettings, printerServer$
    close #PrinterSettings
end if





oncomerror [trap]

on error goto [errorHandler]



[setup.esp8266.Window]

    '-----Begin code for #esp8266


    WindowWidth = 900
    WindowHeight = 650
    UpperLeftX=int((DisplayWidth-WindowWidth)/2)
    UpperLeftY=int((DisplayHeight-WindowHeight)/2)


    GRAPHICBOX #esp8266.indi, 255,   10, 25, 25
    textbox #esp8266.terminalsend,  255 + 25,   10, WindowWidth - 255 - 20-150 -25, 25


    button #esp8266.connect,"Send",[terminal.send], ul,  WindowWidth -20-75, 10 , 75, 25
    
    
    
    button #esp8266.connect,"connect",[terminal.connect], ul,  10, 50 , 100, 25
    
    button #esp8266.LoadGcode,"Load Gcode",[load.gcode], ul,  10, 75 , 100, 25
    button #esp8266.LoadGcode,"Send Gcode",[send.gcode], ul,  10, 100 , 100, 25
       
    
    
    
    texteditor #esp8266.te, 255, 35, WindowWidth - 255 - 20, WindowHeight - 35 - 35     'The handle for our texteditor is #window.te

    open "ESP8266 Basic by ESP8266basic.com" for dialog_nf as #esp8266
    print #esp8266, "font ms_sans_serif 10"
    print #esp8266, "trapclose [quit.esp8266]"
    print #esp8266.te, "!autoresize";   'Tell the texteditor to resize with the terminal window
    print #esp8266.indi , "fill red"


    

goto [terminal.connect]
    wait



print shell$("wget -O download.gcode ";printerServer$;"?name=";printerName$;"&";"?material=";printerMaterial$;"&";"?Color=";printerColor$)



[quit.esp8266] 'End the program
    close #esp8266
    end





[load.gcode]
open "test.gcode" for input as #autoexec
print #esp8266.te, "!contents #autoexec";
close #autoexec


wait



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
    
    print shell$("wget -O download.gcode ";chr$(34);printerServer$;"?name=";printerName$;"&Color=";printerColor$;"&material=";printerMaterial$;chr$(34))

    open "download.gcode" for input as #autoexec
        print #esp8266.te, "!contents #autoexec";
    close #autoexec
    
    print  #esp8266.te, "!line 1 gcodetest$" ;
    
    if gcodetest$ = ";start" then 
        print #esp8266.te, "!lines GcodeLinecount" ;
        n = 0
        SendGcodeFlag = 1
        timer 0
        goto [loop]
        
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
        if SendGcodeFlag = 1 then
            if t$ = "WAIT" then gosub [send.the.goce.to.the.printer]
            if t$ = "OK 0" then gosub [send.the.goce.to.the.printer]
            if t$ = "RESEND:1" then gosub [REsend.the.goce.to.the.printer]
        else
            print  #esp8266.te, "!line 3 PrintJobID$" ;
            PrintJobID$ = right$(PrintJobID$,len(PrintJobID$)-1)
            print shell$("wget -O download.junk ";chr$(34);printerServer$;"?jobID=";PrintJobID$;"&stat=Done";chr$(34))
        
            notice "Printing done. Click ok to continue"
            goto [loop.for.Gcode]
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
if n > GcodeLinecount then SendGcodeFlag = 0: return
print  #esp8266.te, "!line "+str$(n)+" GcodeLineToSend$" ;
if left$(GcodeLineToSend$,1) = ";" then goto [send.the.goce.to.the.printer]
if left$(GcodeLineToSend$,1) = "" then goto [send.the.goce.to.the.printer]
print #esp8266.te, "!origin 0 ";n ;
print #comm, GcodeLineToSend$ + chr$(13)
return


[trap2]
print #esp8266.indi , "fill red"
close #comm
print "error"
wait

 
 
 
 
[trap]
[errorHandler]
if connected = 1 then 
    timer 0
    print #esp8266.indi , "fill red"
    close #comm
    connected = 0 
end if
print "Error string is " + chr$(34) + Err$ + chr$(34)
print "Error number is ";Err

wait











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









function pause( mil)
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

'       occurrances ..... ALL -> replaces all occurrances

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
 






