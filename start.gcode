G28
;DOWN ALL THE WAY 
;udpsend down
G4 P30000
G28

;ALL THE WAY UP
;udpsend up
G4 P31000
G28


;DOWN FOR THE PRINTER PAGE

;udpsend down

G4 P5000
G28

;udpsend stop

G28

;printpage

;ALL THE WAY UP
;udpsend up
G28



