.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
format DB "%d",13,10,0
window_title DB "DX-BALL",0
area_width EQU 700
area_height EQU 500
area DD 0

nr_linii DD 0

counter DD 0 ; numara evenimentele de tip timer
scor DD 0

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

symbol_width DD 10
symbol_height DD 20
include digits.inc
include letters.inc
include minge.inc

;paleta
x_paleta DD 300
y_paleta DD 480
sizex_paleta DD 80
sizey_paleta EQU 15

;obstacole
x_obstacole DD 10, 110, 210, 310, 410, 510, 610, 10, 110, 210, 310, 410, 510, 610, 10, 110, 210, 310, 410, 510, 610, 110, 210, 310, 410, 510 
x_obstacole_final DD 90, 190, 290, 390, 490, 590, 690, 90, 190, 290, 390, 490, 590, 690, 90, 190, 290, 390, 490, 590, 690, 190, 290, 390, 490, 590
y_obstacole DD 40, 40, 40, 40, 40, 40, 40, 80, 80, 80, 80, 80, 80, 80, 120, 120, 120, 120, 120, 120, 120, 160, 160, 160, 160, 160
y_obstacole_final DD 60, 60, 60, 60, 60, 60, 60, 100, 100, 100, 100, 100, 100, 100, 140, 140, 140, 140, 140, 140, 140, 180, 180, 180, 180, 180
obstacole_active DD 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
sizex_obstacole EQU 80
sizey_obstacole EQU 20

;mingea
x_minge DD 335
y_minge DD 460
sizex_minge DD 15
sizey_minge DD 15
viteza_x DD -8
viteza_y DD -8

ai_pierdut DD 0
ai_castigat DD 0

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y

make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	
	cmp eax, '*'
	je make_minge
	
	mov symbol_width, 10
	mov symbol_height, 20
	
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	
	jmp draw_text

make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	jmp draw_text
make_minge:
	mov eax, 0
	lea esi, minge
	mov symbol_width, 15
	mov symbol_height, 15
	jmp draw_text

draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_negru
	mov dword ptr [edi], 0FFF300h
	jmp simbol_pixel_next
simbol_pixel_negru:
	mov dword ptr [edi], 0
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

game_over macro

	make_text_macro 'G', area, 285, 350
	make_text_macro 'A', area, 295, 350
	make_text_macro 'M', area, 305, 350
	make_text_macro 'E', area, 315, 350
	make_text_macro ' ', area, 335, 350
	make_text_macro 'O', area, 355, 350
	make_text_macro 'V', area, 365, 350
	make_text_macro 'E', area, 375, 350
	make_text_macro 'R', area, 385, 350
	
	make_text_macro 'I', area, 195, 280
	make_text_macro 'N', area, 205, 280
	make_text_macro ' ', area, 215, 280
	make_text_macro 'V', area, 225, 280
	make_text_macro 'I', area, 235, 280
	make_text_macro 'A', area, 245, 280
	make_text_macro 'T', area, 255, 280
	make_text_macro 'A', area, 265, 280
	make_text_macro ' ', area, 275, 280
	make_text_macro 'M', area, 285, 280
	make_text_macro 'A', area, 295, 280
	make_text_macro 'I', area, 305, 280
	make_text_macro ' ', area, 315, 280
	make_text_macro 'P', area, 325, 280
	make_text_macro 'I', area, 335, 280
	make_text_macro 'E', area, 345, 280
	make_text_macro 'R', area, 355, 280
	make_text_macro 'Z', area, 365, 280
	make_text_macro 'I', area, 375, 280
	make_text_macro ' ', area, 385, 280
	make_text_macro 'S', area, 395, 280
	make_text_macro 'I', area, 405, 280
	make_text_macro ' ', area, 415, 280
	make_text_macro 'N', area, 425, 280
	make_text_macro 'U', area, 435, 280
	make_text_macro ' ', area, 445, 280
	make_text_macro 'C', area, 455, 280
	make_text_macro 'A', area, 465, 280
	make_text_macro 'S', area, 475, 280
	make_text_macro 'T', area, 485, 280
	make_text_macro 'I', area, 495, 280
	make_text_macro 'G', area, 505, 280
	make_text_macro 'I', area, 515, 280
	
endm

well_done macro

	make_text_macro 'W', area, 285, 350
	make_text_macro 'E', area, 295, 350
	make_text_macro 'L', area, 305, 350
	make_text_macro 'L', area, 315, 350
	make_text_macro ' ', area, 325, 350
	make_text_macro 'D', area, 335, 350
	make_text_macro 'O', area, 345, 350
	make_text_macro 'N', area, 355, 350
	make_text_macro 'E', area, 365, 350
	
	make_text_macro 'N', area, 210, 280
	make_text_macro 'U', area, 220, 280
	make_text_macro ' ', area, 230, 280
	make_text_macro 'A', area, 240, 280
	make_text_macro 'I', area, 250, 280
	make_text_macro ' ', area, 260, 280
	make_text_macro 'V', area, 270, 280
	make_text_macro 'E', area, 280, 280
	make_text_macro 'N', area, 290, 280
	make_text_macro 'I', area, 300, 280
	make_text_macro 'T', area, 310, 280
	make_text_macro ' ', area, 320, 280
	make_text_macro 'L', area, 330, 280
	make_text_macro 'A', area, 340, 280
	make_text_macro ' ', area, 350, 280
	make_text_macro 'P', area, 360, 280
	make_text_macro 'O', area, 370, 280
	make_text_macro 'L', area, 380, 280
	make_text_macro 'I', area, 390, 280
	make_text_macro ' ', area, 400, 280
	make_text_macro 'D', area, 410, 280
	make_text_macro 'E', area, 420, 280
	make_text_macro 'G', area, 430, 280
	make_text_macro 'E', area, 440, 280
	make_text_macro 'A', area, 450, 280
	make_text_macro 'B', area, 460, 280
	make_text_macro 'A', area, 470, 280
	
endm

;colorez un dreptunghi prin linii orizontale 
coloreaza_dreptunghi macro x, y, lungime, latime, color
local umple, bucla_line, out_m
	
	mov edi, y
	mov ebx, latime
	
	mov eax, y
	add eax, ebx
	mov nr_linii, eax
	
	umple:
	cmp edi, nr_linii
	je out_m
	;pos = (y * area_width + x) * 4
	mov eax, edi
	mov ebx, area_width
	mul ebx
	add eax, x
	shl eax, 2
	add eax, area
	mov ecx, lungime
	bucla_line:
	mov dword ptr[eax], color
	add eax, 4
	loop bucla_line
	inc edi
	jmp umple
	
	out_m:
	
endm


; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	;cmp eax, 1
	;jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	
	mov eax, [ebp+arg2]
	
	cmp eax, 000025h
	je paleta_stanga
	
	cmp eax, 000027h
	je paleta_dreapta
	
	jmp afisare_litere
	
paleta_stanga:
	cmp x_paleta, 0
	je afisare_litere
	sub x_paleta, 20
	jmp afisare_litere
	
paleta_dreapta:
	cmp x_paleta, 620
	je afisare_litere
	add x_paleta, 20
	jmp afisare_litere
	
bucla_linii:
	mov eax, [ebp+arg2]
	and eax, 0FFh
	; provide a new (random) color
	mul eax
	mul eax
	add eax, ecx
	push ecx
	mov ecx, area_width
bucla_coloane:
	mov [edi], eax
	add edi, 4
	add eax, ebx
	loop bucla_coloane
	pop ecx
	loop bucla_linii
	jmp afisare_litere
	
evt_timer:
	
	cmp ai_castigat, 1
	jne skip
	well_done
	
	skip:
	cmp ai_pierdut,1
	jne aici
	game_over
	
	aici:
	inc counter
		
afisare_litere:

	;mai jos e codul care intializeaza fereastra cu pixeli negri 
	;pentru a nu fi nevoie sa redesenez mingea in pozitiile vechi

	;daca am pierdut => nu se mai intampla nimic
	cmp ai_pierdut, 1
	je afara_din_joc
	
	cmp scor, 26
	jl jocul_continua
	mov ai_castigat, 1
	jmp final_draw
	
	jocul_continua:
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 0
	push area
	call memset
	add esp, 12
	
	;afisare nume
	make_text_macro 'I', area, 570, 5
	make_text_macro 'R', area, 580, 5
	make_text_macro 'I', area, 590, 5
	make_text_macro 'N', area, 600, 5
	make_text_macro 'I', area, 610, 5
	make_text_macro ' ', area, 620, 5
	make_text_macro 'K', area, 630, 5
	make_text_macro 'A', area, 640, 5
	make_text_macro 'R', area, 650, 5
	make_text_macro 'I', area, 660, 5
	make_text_macro 'N', area, 670, 5
	make_text_macro 'A', area, 680, 5
	
	;afisare scor
	make_text_macro 'S', area, 10, 5
	make_text_macro 'C', area, 20, 5
	make_text_macro 'O', area, 30, 5
	make_text_macro 'R', area, 40, 5
	make_text_macro ' ', area, 50, 5
	
	
	;colorare obstacolele - 26 de obstacole
	mov esi, 0
	obstacole:
	cmp esi, 25
	jg paleta
	cmp obstacole_active[4*esi], 1
	jne urmatorul_obstacol
	coloreaza_dreptunghi x_obstacole[4*esi], y_obstacole[4*esi], sizex_obstacole, sizey_obstacole, 0BB8FCEh
	urmatorul_obstacol:
	inc esi
	jmp obstacole
	
	paleta:
	;colorare paleta
	coloreaza_dreptunghi x_paleta, y_paleta, sizex_paleta, sizey_paleta, 0FF529Bh
	
	;miscarea mingii - porneste spre stanga sus
	mov ebx, viteza_x
	add x_minge, ebx
	mov ebx, viteza_y
	add y_minge, ebx
	
	mov esi,0
	verif_obstacol:
	cmp esi,25
	jg poz1
	
	;daca obstacolul este activ
	cmp obstacole_active[4*esi], 1
	jne next
	
	;coliziune de jos
	mov eax, x_minge
	add eax, sizex_minge
	cmp eax, x_obstacole[4*esi]
	jl verif2
	
	;add eax, sizex_minge
	cmp eax, x_obstacole_final[4*esi]
	jg verif2
	
	;daca verifica conditiile si atinge obstacolul - il sterg adica il dezactivez
	mov edi, y_minge
	cmp edi, y_obstacole_final[4*esi]
	jne verif2
	
	mov ebx, 0
	sub ebx, viteza_y
	mov viteza_y, ebx
	mov obstacole_active[4*esi], 0
	inc scor
	
	;coliziune din dreapta
	verif2:
	mov eax, y_minge
	add eax, sizey_minge
	cmp eax, y_obstacole[4*esi]
	jl verif3
	
	;mov eax, y_minge
	add eax, sizey_minge
	cmp eax, y_obstacole_final[4*esi]
	jg verif3
	
	mov edi, x_minge
	;add edi, sizex_minge
	cmp edi, x_obstacole_final[4*esi]
	jne verif3
	
	mov ebx, 0
	sub ebx, viteza_y
	mov viteza_y, ebx
	mov obstacole_active[4*esi], 0
	inc scor
	
	;coliziune de sus
	verif3:
	mov eax, x_minge
	add eax, sizex_minge
	cmp eax, x_obstacole[4*esi]
	jl verif4
	
	;add eax, sizex_minge
	cmp eax, x_obstacole_final[4*esi]
	jg verif4
	
	mov edi, y_minge
	add edi, sizey_minge
	cmp edi, y_obstacole[4*esi]
	jne verif4
	
	mov ebx, 0
	sub ebx, viteza_y
	mov viteza_y, ebx
	mov obstacole_active[4*esi], 0
	inc scor
	
	;coliziune din stanga
	verif4:
	mov eax, y_minge
	add eax, sizey_minge
	cmp eax, y_obstacole[4*esi]
	jl next
	
	;mov eax, y_minge
	;add eax, sizey_minge
	cmp eax, y_obstacole_final[4*esi]
	jg next
	
	mov edi, x_minge
	add edi, sizex_minge
	cmp edi, x_obstacole[4*esi]
	jne next
	
	mov ebx, 0
	add ebx, viteza_x
	mov viteza_x, ebx
	mov obstacole_active[4*esi], 0
	inc scor
	
	jmp verif_obstacol
	
	next:
	inc esi
	jmp verif_obstacol
	
	;coliziunile cu marginile
	;marginea din stanga
	poz1:
	cmp x_minge, 7
	jg poz2
	
	;se schimba x
	mov ebx, 0
	sub ebx, viteza_x
	mov viteza_x, ebx
	
	poz2:
	;marginea de sus
	cmp y_minge, 40
	jg poz3
	
	mov ebx, 0
	sub ebx, viteza_y 
	mov viteza_y, ebx
	
	poz3:
	;marginea din dreapta
	cmp x_minge, 675
	jl poz4
	
	mov ebx, 0
	sub ebx, viteza_x
	mov viteza_x, ebx
	
	poz4:
	;verific daca e pe paleta
	cmp y_minge, 460
	je verifica_x
	jmp poz5
	
	verifica_x:
	;daca marginea din dreapta a mingii nu se afla pe paleta => game over
	;mov esi, x_paleta
	mov edi, x_minge
	add edi, sizex_minge
	cmp edi, x_paleta
	jl afara_din_joc
	
	;daca marginea din stanga a mingii nu se afla pe paleta => game over 
	mov esi, x_paleta
	add esi, sizex_paleta
	cmp x_minge, esi
	jg afara_din_joc
	
	mov ebx, 0
	sub ebx, viteza_y
	mov viteza_y, ebx
	jmp poz5
	
	afara_din_joc:
	mov ai_pierdut, 1
	
	poz5:
	
	;afisam valoarea scorului curent (zeci si unitati)
	mov ebx, 10
	mov eax, scor
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 75, 5
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 65, 5
	
	;afisare minge
	make_text_macro '*', area, x_minge, y_minge

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start
