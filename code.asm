$NOMOD51                ; Wy³¹czenie symboli standardowego 8051
                        ; Pozostaj¹ ACC, B, DPL, DPH, PSW, SP
$include (aduc834.h)    ; W³¹czenie symboli dla ADuC834
; ______________________________________________________________________
; Deklaracja w³asnych oznaczeñ
;FAN EQU P1.0            ; Port steruj¹cy prac¹ wentylatora
                        ; Jeœli potrzebujesz, dopisz wiêcej deklaracji
; ______________________________________________________________________
CSEG                    ; Segment programu

ORG 0000H               ; Adres w pamiêci programu 0000h
    JMP START           ; Skocz do adresu przypisanego etykiecie START (0060h)

ORG 0060H               ; Tu zaczyna siê program g³ówny
START:
; Od tego miejsca do etykiety LOOP znajduj¹ siê instrukcje wykonywane TYLKO jeden raz
; na pocz¹tku programu. S¹ to instrukcje zwi¹zane z inicjalizacj¹ uk³adu.
    MOV SP,#7FH         ; Ustawienie wskaŸnika stosu na 7Fh
    ;MOV P0,#0           ; Od³¹czenie zasilania silników
    ;CLR FAN             ; Wy³¹czenie wentylatora
    
; Od tego miejsca powinien rozpoczynaæ siê kod programu g³ównego (wraz z wywo³aniem podprogramów).

LOOP:
; Instrukcje zapisane pomiêdzy etykiet¹ LOOP a instrukcj¹ JMP LOOP, s¹ powtarzane
; do wy³¹czenia zasilania / do sygna³u reset i stanowi¹ pêtlê g³ówn¹ programu.
JNB P2.1, DLUGO

    JMP LOOP
;______________________________________________________________________
; Tu powinien znajdowaæ siê kod podprogramów i obs³ugi przerwañ np.:
DLUGO:
        CPL P2.4   ;Zaneguj P2.4  
        CALL CZEKAJ_DLUGO    
        JNB P2.0, LOOP
        JNB P2.2, KROTKO
    JMP DLUGO

KROTKO:
        CPL P2.4  
        CALL CZEKAJ_KROTKO  
        JB P2.2, DLUGO  
    JMP KROTKO    
    
CZEKAJ_DLUGO: 
         MOV TMOD,#01H  ;tryb pracy 1  
         MOV TH0,#0002  ;Starszy bajt licznika  
         MOV TL0,#8000  ;Mlodszy  
         SETB TR0   ;start licznika  
    PETLA1:  
         JNB TF0, PETLA1   ;Wykonuj do czasu przepelnienia  
         CLR TF0    ;zerowanie wskaznika przepelnienia  
         CLR TR0    ;stop licznika   
    RET
CZEKAJ_KROTKO:
         MOV TMOD,#0H  
         MOV TH0,#0333
         MOV TL0,#8000 
         SETB TR0  
     PETLA2:  
         JNB TF0, PETLA2  
         CLR TF0  
         CLR TR0  
     RET   
    
; ______________________________________________________________________
END                     ; Koniec kodu do kompilacji
