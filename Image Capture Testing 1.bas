bla$ = shell$("CommandCam.exe")

WindowWidth  =850
WindowHeight =660

open "Display" for graphics_nsb as #w

#w "trapclose quit"

handleg  =hwnd( #w)
calldll  #user32, "GetDC", handleg as ulong, hDC as ulong

loadbmp "scr", "image.bmp"
#w "down ; drawbmp scr 20 20 ; backcolor white ; flush"

#w, "when leftButtonDown [get.pix]"

wait

[get.pix]

    x = MouseX
    y = MouseY

    calldll #gdi32, "GetPixel", hDC as ulong, x as long, y as long, pixcol as ulong
        bl = int(  pixcol /( 256*256)): 
        gr = int( (pixcol -bl *256*256) / 256): 
        re = int(  pixcol -bl *256*256 -gr *256)
        
        print x, y
        print re, gr, bl

        end if
wait



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