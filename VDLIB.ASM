IZQ_SUP         EQU      0C9H
DER_SUP         EQU      0BBH
IZQ_INF         EQU      0C8H
DER_INF         EQU      0BCH
VERTICL         EQU      0BAH
HORIZTL         EQU      0CDH
EFECTOS         EQU       07H

		PUBLIC    _v_save,_v_load,_dead_time,_v_window,_v_borde,
                _v_write,_video_pos,_get_char,_video_tipo,_tipo_cursor
_TEXT           SEGMENT  WORD  PUBLIC  'CODE'
_TEXT           ENDS
_DATA           SEGMENT  WORD  PUBLIC  'DATA'
_DATA           ENDS
CONST           SEGMENT  WORD  PUBLIC  'CONST'
CONST           ENDS
_BSS            SEGMENT  WORD  PUBLIC  'BSS'
_BSS            ENDS
DGROUP          GROUP    _DATA, CONST, _BSS
		ASSUME   DS:DGROUP, SS:DGROUP

_DATA           SEGMENT
VIDEOBASE       WORD     0B000H
I               WORD     0000H
indices         WORD     20      DUP(0)
vbuffer         BYTE     25000   DUP(0)
NOMBRE          BYTE     'LIBRERIA DE ENTRADA/SALIDA ESTANDAR ESCRITA POR JOSE R. PORTILLO L. 1990'
_DATA           ENDS

_TEXT           SEGMENT
		ASSUME   CS:_TEXT



;/*[]--------------------------------------------------[]*
; *  Procedimiento que salva la porcion del video donde  *
; *  sera abierta una ventana de cualquier clase         *
; *                                                      *
; *  Entrada: #fila inicial, #columna inicial,           *
; *           #fila final, #columna final                *
; *                                                      *
; *  Formato: v_save(int fi,int ci,int ff,int cf)        *
; *[]--------------------------------------------------[]*/
_v_save     PROC
   PUSH BP
   MOV  BP,SP
   PUSH AX
   PUSH BX
   PUSH DX
   MOV  BX,OFFSET DGROUP:indices
   ADD  BX,WORD PTR DGROUP:I ;/*I*/
   MOV  AX,WORD PTR [BX]
   MOV  BX,OFFSET DGROUP:vbuffer
   ADD  BX,AX
   DEC  WORD PTR [BP+4] ;/*fila*/
   ADD  WORD PTR [BP+10],2 ;/*columna*/
   MOV  DH,BYTE PTR [BP+4]
   MOV  DL,BYTE PTR [BP+6]
  .WHILE(DH <= BYTE PTR [BP+8])
  ;{
         .WHILE(DL <= BYTE PTR [BP+10])
         ;{
                 CALL _get_char
                 MOV  WORD PTR [BX],AX ;/*buffer[indice] <-- caracter*/
                 INC  DL ;/*columna++*/
                 ADD  BX,2 ;/*apuntador++*/
         ;}
         .ENDW
          INC  DH ;/*fila++*/
          MOV  DL,BYTE PTR [BP+6] ;/*columna*/
  ;}
  .ENDW
   INC  WORD PTR DGROUP:I ;/*I++*/
   INC  WORD PTR DGROUP:I ;/*I++*/
   MOV  AX,BX
   MOV  BX,OFFSET DGROUP:indices
   ADD  BX,WORD PTR DGROUP:I ;/*direccion*/
   MOV  WORD PTR [BX],AX
   POP  DX
   POP  BX
   POP  AX
   MOV  SP,BP
   POP  BP
   RET
_v_save     ENDP



;/*[]-----------------------------------------------------[]*
; *  Procedimiento que recupera la porcion del video donde  *
; *  fue abierta una ventana de cualquier clase             *
; *                                                         *
; *  Entrada: #fila inicial, #columna inicial,              *
; *           #fila final, #columna final                   *
; *                                                         *
; *  Formato: v_load(int fi,int ci,int ff,int cf)           *
; *[]-----------------------------------------------------[]*/
_v_load     PROC
   PUSH BP
   MOV  BP,SP
   PUSH AX
   PUSH BX
   PUSH DX
   DEC  WORD PTR DGROUP:I ;/*indice--*/
   DEC  WORD PTR DGROUP:I ;/*indice--*/
   MOV  BX,OFFSET DGROUP:indices
   ADD  BX,WORD PTR DGROUP:I
   MOV  AX,WORD PTR [BX]
   MOV  BX,OFFSET DGROUP:vbuffer
   ADD  BX,AX
   DEC  WORD PTR [BP+4] ;/*fila*/
   ADD  WORD PTR [BP+10],2 ;/*columna*/
   MOV  DH,BYTE PTR [BP+4]
   MOV  DL,BYTE PTR [BP+6]
  .WHILE(DH <= BYTE PTR [BP+8])
  ;{
         .WHILE(DL <= BYTE PTR [BP+10])
         ;{
                 MOV  AX,WORD PTR [BX] ;/*caracter*/
                 CALL _video_pos
                 INC  DL ;/*columna++*/
                 ADD  BX,2 ;/*apuntador++*/
         ;}
         .ENDW
          INC  DH ;/*fila++*/
          MOV  DL,BYTE PTR [BP+6] ;/*columna*/
  ;}
  .ENDW
   POP  DX
   POP  BX
   POP  AX
   MOV  SP,BP
   POP  BP
   RET
_v_load     ENDP



_dead_time PROC
   PUSH BP
   MOV  BP,SP
  .WHILE(WORD PTR [BP+4] != 0)
  ;{
          XOR  CX,CX
         .REPEAT
         ;{
                 INC  CX
         ;}
         .UNTIL(CX == 6000)
          DEC  WORD PTR [BP+4]
  ;}
  .ENDW
   POP  BP
   RET
_dead_time ENDP



;/*[]--------------------------------------------------------------[]*
; *  Procedimiento que dibuja una ventana en la pantalla de video    *
; *                                                                  *
; *  Entrada: #fila inicial, #columna inicial, #fila final,          *
; *           #columna final,caracter Y atributo de fondo,           *
; *           y sombra(1) o no sombra(0).                            *
; *                                                                  *
; *  formato:                                                        *
; *  v_window(int fi,int ci,int ff,int cf,int atrib+carct,optativo)  *
; *[]--------------------------------------------------------------[]*/
_v_window     PROC
   PUSH BP
   MOV  BP,SP
   XOR  AX,AX
   PUSH AX
   PUSH AX
   MOV  AX,WORD PTR [BP+4] ;/*fila inicial*/
   DEC  AX
   MOV  WORD PTR [BP-4],AX ;/*fila*/
  .REPEAT
  ;{
          MOV  AX,WORD PTR [BP+6] ;/*columna inicial*/
          MOV  WORD PTR [BP-2],AX ;/*columna*/
         .REPEAT
         ;{
                 MOV  DH,BYTE PTR [BP-4] ;/*fila*/
                 MOV  DL,BYTE PTR [BP-2] ;/*columna*/
                 MOV  AX,WORD PTR [BP+12] ;/*atributo y caracter*/
                 CALL _video_pos
                 INC  WORD PTR [BP-2] ;/*columna++*/
                 MOV  CX,WORD PTR [BP+10] ;/*columna final*/
         ;}
         .UNTIL(WORD PTR [BP-2] > CX)
          INC  WORD PTR [BP-4] ;/*fila++*/
          MOV  CX,WORD PTR [BP+8] ;/*fila final*/
          DEC  CX ;/*fila*/
  ;}
  .UNTIL(WORD PTR [BP-4] > CX)
  .IF(BYTE PTR [BP+14] != 0) ;/*sombra?*/
  ;{
          MOV  DH,BYTE PTR [BP+4] ;/*fila inicial*/
          MOV  DL,BYTE PTR [BP+10] ;/*columna final*/
          INC  DL
         .REPEAT
         ;{
                 CALL  _get_char
                 MOV  AH,EFECTOS ;/*sombra*/
                 CALL  _video_pos
                 INC  DH ;/*fila++*/
         ;}
         .UNTIL(DH > BYTE PTR [BP+8])
          MOV  DH,BYTE PTR [BP+4] ;/*fila inicial*/
          INC  DL
         .REPEAT
         ;{
                 CALL  _get_char
                 MOV  AH,EFECTOS ;/*sombra*/
                 CALL  _video_pos
                 INC  DH ;/*fila++*/
         ;}
         .UNTIL(DH > BYTE PTR [BP+8])
          INC  BYTE PTR [BP+10] ;/*columna final++*/
          MOV  DH,BYTE PTR [BP+8] ;/*fila final*/
          MOV  DL,BYTE PTR [BP+6] ;/*columna inicial*/
          ADD  DL,2
         .REPEAT
         ;{
                 CALL  _get_char
                 MOV  AH,EFECTOS ;/*sombra*/
                 CALL  _video_pos
                 INC  DL ;/*columna++*/
         ;}
         .UNTIL(DL > BYTE PTR [BP+10])
  ;}
  .ENDIF
  POP  AX
  POP  AX
  MOV  SP,BP
  POP  BP
  RET
_v_window     ENDP



;/*[]-----------------------------------------------[]*
; *  Procedimiento que escribe el borde de una        *
; *  ventana abierta previamente                      *
; *                                                   *
; *  Entrada: #fila inicial, #columna inicial,        *
; *           #fila final, #columna final,            *
; *           caracter y atributo de fondo            *
; *                                                   *
; *  Formato:                                         *
; *  v_borde(int fi,int ci,int ff,int cf,char atrib)  *
; *[]-----------------------------------------------[]*/
_v_borde     PROC
   PUSH BP
   MOV  BP,SP
   PUSH AX
   PUSH DX
   DEC  WORD PTR [BP+4] ;/*fila*/
   MOV  DH,BYTE PTR [BP+4] ;/*fila inicial*/
   MOV  DL,BYTE PTR [BP+6] ;/*columna inicial*/
   MOV  AL,IZQ_SUP
   MOV  AH,BYTE PTR [BP+12] ;/*color*/
   CALL _video_pos
  .WHILE(DL < BYTE PTR [BP+10]) ;/*borde horizontal superior*/
  ;{
          MOV  AL,HORIZTL
          INC  DL ;/*columna++*/
          CALL _video_pos
  ;}
  .ENDW
   MOV  AL,DER_SUP ;/*tope derecho*/
   CALL _video_pos
  .WHILE(DH < BYTE PTR [BP+8]) ;/*borde vertical derecho*/
  ;{
          INC  DH ;/*fila--*/
          MOV  AL,VERTICL
          CALL _video_pos
  ;}
  .ENDW
   MOV  AL,DER_INF ;/*tope inferior derecho*/
   CALL _video_pos
  .WHILE(DL > BYTE PTR [BP+6]) ;/*borde horizontal inferior*/
  ;{
          DEC  DL ;/*columna--*/
          MOV  AL,HORIZTL
          CALL _video_pos
  ;}
  .ENDW
   MOV  AL,IZQ_INF
   CALL _video_pos
   DEC  DH ;/*fila*/
  .REPEAT ;/*borde vertical izquierdo*/
  ;{
          MOV  AL,VERTICL
          CALL _video_pos
          DEC  DH ;/*fila--*/
  ;}
  .UNTIL(DH == BYTE PTR [BP+4])
   POP  DX
   POP  AX
   MOV  SP,BP
   POP  BP
   RET
_v_borde     ENDP



;/*[]--------------------------------------------[]*
; *  Procedimiento que escribe un mensaje en la    *
; *  pantalla de acuerdo a las coordenadas dadas   *
; *                                                *
; *  Entrada: #fila inicial,#columna inicial,      *
; *           apuntador al string terminado en     *
; *           '\0' y el atributo de fondo          *
; *                                                *
; *  Formato:                                      *
; *  v_write(int fi,int ci,char *strg,char atrib)  *
; *[]--------------------------------------------[]*/
_v_write     PROC
   PUSH BP
   MOV  BP,SP
   PUSH AX
   PUSH DX
   MOV  BX,WORD PTR [BP+8] ;/*string*/
  .REPEAT
  ;{
          MOV  DL,BYTE PTR [BP+6] ;/*columna*/
          MOV  DH,BYTE PTR [BP+4] ;/*fila*/
          DEC  DH
          MOV  AH,BYTE PTR [BP+10] ;/*atributo*/
          MOV  AL,BYTE PTR [BX]
          CALL _video_pos
          INC  BX ;/*indice++*/
          INC  WORD PTR [BP+6] ;/*columna++*/
  ;}
  .UNTIL(BYTE PTR [BX] == 0)
   POP  DX
   POP  AX
   MOV  SP,BP
   POP  BP
   RET
_v_write     ENDP



;/*[]--------------------------------------------[]*
; *  Escribe un caracter en la pantalla de video   *
; *                                                *
; *  Entrada: DH Y DL, #fila y #columna; caracter  *
; *           en AL y su atributo en AH            *
; *[]--------------------------------------------[]*/
_video_pos     PROC
   PUSH AX
   PUSH DX
   PUSH DI
   PUSH ES
   PUSH DX
   PUSH AX
   MOV  AX,VIDEOBASE ;/*segmento*/
   MOV  ES,AX
   XOR  AX,AX
   DEC  DL ;/*columna*/
   MOV  AL,80 ;/*AX = caracter + atributo*/
   MUL  DH ;/*DX = #fila Y #columna*/
   XOR  DH,DH ;/*F = 2 * ( (#fila*80) + #columna )*/
   ADD  AX,DX
   SHL  AX,1
   MOV  DI,AX ;/*offset*/
   POP  AX ;/*atributo*/
   MOV  WORD PTR ES:[DI],AX ;/*caracter*/
   POP  DX
   POP  ES
   POP  DI
   POP  DX
   POP  AX
   RET
_video_pos     ENDP



;/*[]---------------------------------------[]*
; *  Lee un caracter en la pantalla de video  *
; *                                           *
; *  Entrada: DH y DL, #fila y #columna       *
; *  Salida:  AX caracter y su atributo       *
; *[]---------------------------------------[]*/
_get_char     PROC
   PUSH DX
   PUSH DI
   PUSH ES
   MOV  AX,VIDEOBASE ;/*segmento*/
   MOV  ES,AX
   XOR  AX,AX
   DEC  DL ;/*columna*/
   MOV  AL,80 ;/*AX = caracter + atributo*/
   MUL  DH ;/*DX = #fila y #columna*/
   XOR  DH,DH ;/*F = 2 * ( (#fila*80) + #columna )*/
   ADD  AX,DX
   SHL  AX,1
   MOV  DI,AX ;/*offset*/
   MOV  AX,WORD PTR ES:[DI] ;/*caracter*/
   POP  ES
   POP  DI
   POP  DX
   RET
_get_char     ENDP



_video_tipo     PROC
   PUSH AX
   PUSH BX
   PUSH ES
   MOV  AX,0040H ;/*bios data area*/
   MOV  ES,AX
   MOV  BX,0010H ;/*equipment flag*/
   MOV  AX,WORD PTR ES:[BX]
   AND  AX,0030H ;/*modo de video*/
  .IF((AX == 0010H) || (AX == 0020H))
  ;{
          MOV  AX,0B800H ;/*segmento*/
          MOV  WORD PTR DGROUP:VIDEOBASE,AX
  ;}
  .ENDIF
   POP  ES
   POP  BX
   POP  AX
   RET
_video_tipo     ENDP



;/*[]--------------------------------------[]*
; *  Procedimiento que cambia los atributos  *
; *  del cursor en la pantalla de video      *
; *                                          *
; *  Entrada: tama¤o del cursor 1-F          *
; *                                          *
; *  Formato: tipo_cursor(int )              *
; *[]--------------------------------------[]*/
_tipo_cursor    PROC
   PUSH BP
   MOV  BP,SP
   PUSH AX
   PUSH CX
   MOV  CX,WORD PTR [BP+4]
   MOV  AH,01H
   INT  10H
   POP  CX
   POP  AX
   MOV  SP,BP
   POP  BP
   RET
_tipo_cursor    ENDP

_TEXT    ENDS
         END