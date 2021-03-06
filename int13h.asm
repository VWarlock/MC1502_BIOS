;---------------------------------------------------------------------------------------------------
; Interrupt 13h - Floppydisk
;---------------------------------------------------------------------------------------------------
proc		int_13h	near
                cld
                sti
                push	bx
                push	cx
                push	dx
                push	si
                push	di
                push	ds
                push	es
                mov	si, BDAseg
                mov	ds, si
                assume ds:nothing
                call	sub_FEC85
                mov	ah, [cs:MotorOff]
                mov	[ds:dsk_motor_tmr], ah
                mov	ah, [ds:dsk_ret_code_]
                cmp	ah, 1
                cmc
                pop	es
                pop	ds
                assume ds:nothing
                pop	di
                pop	si
                pop	dx
                pop	cx
                pop	bx
                retf	2
endp		int_13h




proc		sub_FEC85 near		; ...
                push	dx
                call	sub_FECC2
                pop	dx
                mov	bx, dx
                and	bx, 1
                mov	ah, [ds:dsk_ret_code_]
                cmp	ah, 40h
                jz	short loc_FECBA
                cmp	ax, 400h
                jnz	short locret_FECC1
                call	sub_FE36C
                jz	short loc_FECBA
                mov	al, [bx+90h]
                mov	ah, 0
                test	al, 0C0h
                jnz	short loc_FECAE
                mov	ah, 80h

loc_FECAE:				; ...
                and	al, 3Fh
                or	al, ah
                mov	[bx+90h], al
                mov	al, 0
                jmp	short locret_FECC1
; ---------------------------------------------------------------------------

loc_FECBA:				; ...
                xor	[byte ptr bx+90h], 20h
                mov	al, 0

locret_FECC1:				; ...
                retn
endp		sub_FEC85





proc		sub_FECC2 near		; ...

                and	[byte ptr ds:dsk_motor_stat], 7Fh
                or	ah, ah
                jz	short loc_FED01
                dec	ah
                jz	short loc_FED31
                mov	[byte ptr ds:dsk_ret_code_], 0
                cmp	dl, 1
                ja	short loc_FECFB
                dec	ah
                jz	short loc_FED43
                dec	ah
                jz	short loc_FED3E
                dec	ah
                jz	short loc_FED35
                dec	ah
                jnz	short loc_FECEC
                jmp	loc_FEE0E
; ---------------------------------------------------------------------------

loc_FECEC:				; ...
                sub	ah, 12h
                jnz	short loc_FECF4
                jmp	loc_FEF0A
; ---------------------------------------------------------------------------

loc_FECF4:				; ...
                dec	ah
                jnz	short loc_FECFB
                jmp	loc_FEF26
; ---------------------------------------------------------------------------

loc_FECFB:				; ...
                mov	[byte ptr ds:dsk_ret_code_], 1
                retn
; ---------------------------------------------------------------------------

loc_FED01:				; ...
                mov	al, 0
                mov	[ds:3Eh], al
                mov	[ds:dsk_ret_code_], al
                mov	ah, [ds:dsk_motor_stat]
                test	ah, 3
                jz	short loc_FED1A
                mov	al, 4
                shr	ah, 1
                jb	short loc_FED1A
                mov	al, 18h

loc_FED1A:				; ...
                call	sub_FE2D3
                mov	dl, [ds:dsk_status_2]
                out	dx, al
                inc	ax
                out	dx, al
                mov	dl, [ds:dsk_status_1]
                mov	al, 0D0h
                out	dx, al
                mov	dl, [ds:dsk_status_2]
                in	al, dx
                retn
; ---------------------------------------------------------------------------

loc_FED31:				; ...
                mov	al, [ds:dsk_ret_code_]
                retn
; ---------------------------------------------------------------------------

loc_FED35:				; ...
                mov	bx, 0FC00h
                mov	es, bx
                assume es:nothing
                mov	bh, bl
                jmp	short loc_FED43
; ---------------------------------------------------------------------------

loc_FED3E:				; ...
                or	[byte ptr ds:dsk_motor_stat], 80h

loc_FED43:				; ...
                call	sub_FE3C3
                push	bx
                mov	bl, 15h
                call	sub_FE2EF
                pop	bx
                jnb	short loc_FED52
                xor	al, al
                retn
; ---------------------------------------------------------------------------

loc_FED52:				; ...
                call	sub_FE452
                mov	ch, al
                xor	ah, ah
                call	sub_FE2D3
                mov	cl, [ds:dsk_status_1]
                add	cl, 3
                test	[byte ptr ds:dsk_motor_stat], 80h
                jnz	short loc_FED9E

loc_FED6A:				; ...
                mov	di, bx
                mov	al, 80h
                mov	dl, [ds:dsk_status_1]
                out	dx, al
                mov	dl, [ds:dsk_status_3]
                jmp	short loc_FED7A
; ---------------------------------------------------------------------------

loc_FED79:				; ...
                stosb

loc_FED7A:				; ...
                in	al, dx
                shr	al, 1
                xchg	dl, cl
                in	al, dx
                xchg	dl, cl
                jb	short loc_FED79
                mov	bx, di
                mov	dl, [ds:dsk_status_1]
                in	al, dx
                and	al, 1Fh
                jnz	short loc_FEDD7
                inc	ah
                call	sub_FEE04
                cmp	ch, ah
                jnz	short loc_FED6A
                mov	al, ah
                call	sub_FE483
                retn
; ---------------------------------------------------------------------------

loc_FED9E:				; ...
                push	ds
                mov	al, 0A0h
                mov	dl, [ds:dsk_status_1]
                out	dx, al
                mov	dl, [ds:dsk_status_3]
                mov	si, es
                mov	ds, si
                assume ds:nothing
                mov	si, bx

loc_FEDB0:				; ...
                in	al, dx
                shr	al, 1
                lodsb
                xchg	dl, cl
                out	dx, al
                xchg	dl, cl
                jb	short loc_FEDB0
                dec	si
                mov	bx, si
                pop	ds
                assume ds:nothing
                mov	dl, [ds:dsk_status_1]
                in	al, dx
                and	al, 5Fh
                jnz	short loc_FEDD7
                inc	ah
                call	sub_FEE04
                cmp	ch, ah
                jnz	short loc_FED9E
                mov	al, ah
                call	sub_FE483
                retn
; ---------------------------------------------------------------------------

loc_FEDD7:				; ...
                call	sub_FE483
                mov	bh, ah
                test	[byte ptr ds:dsk_motor_stat], 80h
                jz	short loc_FEDE9
                test	al, 40h
                mov	ah, 3
                jnz	short loc_FEDFD

loc_FEDE9:				; ...
                test	al, 10h
                mov	ah, 4
                jnz	short loc_FEDFD
                test	al, 8
                mov	ah, 10h
                jnz	short loc_FEDFD
                test	al, 1
                mov	ah, 80h
                jnz	short loc_FEDFD
                mov	ah, 20h

loc_FEDFD:				; ...
                or	[ds:dsk_ret_code_], ah
                mov	al, bh
                retn
endp		sub_FECC2





proc		sub_FEE04 near		; ...
                mov	dl, [ds:dsk_status_1]
                inc	dx
                inc	dx
                in	al, dx
                inc	ax
                out	dx, al
                retn
endp		sub_FEE04

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_FECC2

loc_FEE0E:				; ...
                push	bx
                or	[byte ptr ds:dsk_motor_stat], 80h
                call	sub_FE3C3
                mov	bl, 11h
                call	sub_FE2EF
                pop	si
                jnb	short loc_FEE20
                retn
; ---------------------------------------------------------------------------

loc_FEE20:				; ...
                push	ax
                push	bp
                mov	ah, al
                xor	bx, bx
                mov	ds, bx
                lds	bx, [ds:prn_timeout_1_]
                mov	di, [bx+7]
                mov	bx, BDAseg
                mov	ds, bx
                assume ds:nothing
                call	sub_FE452
                call	sub_FE2D3
                mov	dl, [ds:dsk_status_3]
                mov	bp, dx
                mov	dl, [ds:dsk_status_1]
                mov	al, 0F0h
                out	dx, al
                add	dl, 3
                test	[byte ptr ds:dsk_motor_stat], 20h
                jz	short loc_FEE60
                lods	[word ptr es:si]
                xchg	ax, cx

loc_FEE54:				; ...
                xchg	bp, dx
                in	al, dx
                lods	[byte ptr es:si]
                xchg	bp, dx
                out	dx, al
                loop	loc_FEE54
                jmp	short loc_FEEB1
; ---------------------------------------------------------------------------

loc_FEE60:				; ...
                mov	bx, offset unk_FEEEB
                mov	ch, 5
                call	sub_FEED3

loc_FEE68:				; ...
                mov	bx, offset unk_FEEF5
                mov	ch, 3
                call	sub_FEED3
                mov	cx, 4

loc_FEE73:				; ...
                xchg	bp, dx
                in	al, dx
                lods	[byte ptr es:si]
                xchg	bp, dx
                out	dx, al
                loop	loc_FEE73
                push	ax
                mov	ch, 5
                call	sub_FEED3
                pop	cx
                mov	bx, 80h
                shl	bx, cl
                mov	cx, bx
                mov	bx, di

loc_FEE8D:				; ...
                xchg	bp, dx
                in	al, dx
                mov	al, bh
                xchg	bp, dx
                out	dx, al
                loop	loc_FEE8D
                xchg	bp, dx
                in	al, dx
                mov	al, 0F7h
                xchg	bp, dx
                out	dx, al
                mov	cx, di
                xor	ch, ch

loc_FEEA3:				; ...
                xchg	bp, dx
                in	al, dx
                mov	al, 4Eh
                xchg	bp, dx
                out	dx, al
                loop	loc_FEEA3
                dec	ah
                jnz	short loc_FEE68

loc_FEEB1:				; ...
                xchg	bp, dx
                in	al, dx
                xchg	bp, dx
                shr	al, 1
                mov	al, 4Eh
                out	dx, al
                jb	short loc_FEEB1
                pop	bp
                pop	cx
                mov	dl, [ds:dsk_status_1]
                in	al, dx
                and	al, 47h
                jz	short loc_FEECD
                sub	ah, ah
                jmp	loc_FEDD7
; ---------------------------------------------------------------------------

loc_FEECD:				; ...
                call	sub_FE483
                mov	al, cl
                retn
; END OF FUNCTION CHUNK	FOR sub_FECC2




proc		sub_FEED3 near		; ...
                mov	cl, [cs:bx+1]

loc_FEED7:				; ...
                xchg	bp, dx
                in	al, dx
                mov	al, [cs:bx]
                xchg	bp, dx
                out	dx, al
                dec	cl
                jnz	short loc_FEED7
                inc	bx
                inc	bx
                dec	ch
                jnz	short sub_FEED3
                retn
endp		sub_FEED3

; ---------------------------------------------------------------------------
unk_FEEEB	db  4Eh	; N		; ...
                db  10h
                db    0
                db  0Ch
                db 0F6h	; ?
                db    3
                db 0FCh	; ?
                db    1
                db  4Eh	; N
                db  32h	; 2
unk_FEEF5	db    0			; ...
                db  0Ch
                db 0F5h	; ?
                db    3
                db 0FEh	; ?
                db    1
                db 0F7h	; ?
                db    1
                db  4Eh	; N
                db  16h
                db    0
                db  0Ch
                db 0F5h	; ?
                db    3
                db 0FBh	; ?
                db    1

data_37	db  93h	; ?
                db  74h	; t
                db  15h
                db  97h	; ?
                db  17h
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_FECC2

loc_FEF0A:				; ...
                dec	ax
                cmp	al, 5
                jb	short loc_FEF12
                jmp	loc_FECFB
; ---------------------------------------------------------------------------

loc_FEF12:				; ...
                mov	bx, ax
                and	bx, 7
                mov	al, data_37[bx]

loc_FEF1C:
                mov	bx, dx
                and	bx, 1
                mov	[bx+90h], al
                retn
; ---------------------------------------------------------------------------

loc_FEF26:				; ...
                mov	al, 2
                cmp	cx, 2709h
                jz	short loc_FEF12
                inc	ax
                cmp	cx, 4F0Fh
                jz	short loc_FEF12
                inc	ax
                cmp	cx, 4F09h
                jz	short loc_FEF12
                inc	ax
                cmp	cx, 4F12h
                jz	short loc_FEF12
                jmp	loc_FECFB

; ---------------------------------------------------------------------------

proc		sub_FE2EF near		; ...
                push	ax
                push	cx
                mov	ax, si
                inc	ax
                mov	ah, ch
                test	[ds:dsk_recal_stat], al
                jnz	short loc_FE308
                call	sub_FE394
                jnb	short loc_FE304
                pop	cx
                jmp	short loc_FE36A
; ---------------------------------------------------------------------------
; dsk_status ?
loc_FE304:				; ...
                or	[ds:dsk_recal_stat], al

loc_FE308:				; ...
                mov	al, ah
                call	sub_FE2D3
                mov	dl, [ds:dsk_status_1]
                inc	dx
                out	dx, al
                mov	cl, [ds:dsk_status_7]
                shl	al, cl
                cmp	al, [si+dsk_status_5]
                jz	short loc_FE360
                inc	dx
                inc	dx
                out	dx, al
                xchg al, [si+dsk_status_5]
                dec	dx
                dec	dx
                out	dx, al
                dec	dx
                mov	al, 10h
                out	dx, al
                call	sub_FE2DD
                mov	al, ah
                mov	dl, [ds:dsk_status_1]
                inc	dx
                out	dx, al
                test	[byte ptr ds:dsk_motor_stat], 80h
                jz	short loc_FE360
                inc	dx
                inc	dx
                out	dx, al
                mov	dl, [ds:dsk_status_1]
                mov	al, bl
                out	dx, al
                mov	dl, [ds:dsk_status_3]
                in	al, dx
                mov	dl, [ds:dsk_status_1]
                in	al, dx
                and	al, 19h
                jz	short loc_FE360
                or	[byte ptr ds:dsk_ret_code_], 40h
                stc
                pop	cx
                jmp	short loc_FE36A
; ---------------------------------------------------------------------------

loc_FE360:				; ...
                pop	cx
                mov	al, cl
                mov	dl, [ds:dsk_status_1]
                inc	dx
                inc	dx
                out	dx, al

loc_FE36A:				; ...
                pop	ax
                retn
endp		sub_FE2EF

proc		sub_FE3C3 near		; ...
                push	ax
                push	cx
                and	dl, 1
                mov	si, dx
                and	si, 1
                mov	cl, dl
                inc	cx
                mov	[byte ptr ds:dsk_status_7], 0
                test	[byte ptr si+90h], 10h
                jnz	short loc_FE3E1
                mov	[byte ptr si+0090h], 17h

loc_FE3E1:				; ...
                test	[byte ptr si+0090h], 20h
                jz	short loc_FE3F8
                cmp	ch, 2Ch
                jnb	short loc_FE3F3
                inc	[byte ptr ds:dsk_status_7]
                jmp	short loc_FE3F8
; ---------------------------------------------------------------------------

loc_FE3F3:				; ...
                and	[byte ptr si+90h], 0DFh

loc_FE3F8:				; ...
                mov	al, 82h
                test	[byte ptr ds:dsk_motor_stat], 40h
                jz	short loc_FE404
                xor	dl, 1

loc_FE404:				; ...
                test	dl, 1
                jz	short loc_FE40B
                mov	al, 8Ch

loc_FE40B:				; ...
                or	al, dh
                test	[byte ptr si+90h], 0C0h
                jnz	short loc_FE416
                or	al, 10h

loc_FE416:				; ...
                rol	al, 1
                call	sub_FE2D3
                mov	ah, 0FFh
                mov	[ds:dsk_motor_tmr], ah

                inc	ah
                mov	dl, [ds:dsk_status_2]
                out	dx, al
                in	al, dx
                mov	dl, [ds:dsk_status_1]
                mov	al, 0D0h
                out	dx, al
                test	[ds:dsk_motor_stat], cl
                jnz	short loc_FE446

loc_FE436:				; ...
                mov	al, [ds:dsk_motor_tmr]
                sub	al, ah
                not	al
                shr	al, 1
                cmp	al, [cs:MotorOn]
                jb	short loc_FE436

loc_FE446:				; ...
                and	[byte ptr ds:dsk_motor_stat], 0FCh
                or	[ds:dsk_motor_stat], cl
                pop	cx
                pop	ax
                retn
endp		sub_FE3C3

proc		sub_FE2D3 near		; ...
                mov	dh, [ds:dsk_status_4]
                dec	dh
                and	dh, 1
                retn
endp		sub_FE2D3





proc		sub_FE2DD near		; ...
                push ax
                mov	[byte ptr ds:dsk_motor_tmr], 0FFh ; dsk_motor_tmr
                mov	[byte ptr ds:dsk_motor_tmr], 0FFh ; dsk_motor_tmr

loc_FE2E8:				; ...
                in	al, dx
                shr	al, 1
                jb	short loc_FE2E8
                pop	ax
                retn
endp		sub_FE2DD









proc		sub_FE36C near		; ...
                mov	al, 0D0h
                call	sub_FE2D3
                mov	dl, [ds:dsk_status_1]
                out	dx, al
                call	sub_FE2DD
                mov	al, 0C0h
                out	dx, al
                mov	ah, 3
                add	ah, dl

loc_FE380:				; ...
                mov	dl, [ds:dsk_status_3]
                in	al, dx
                shr	al, 1
                mov	dl, ah
                in	al, dx
                jb	short loc_FE380
                mov	dl, [ds:dsk_status_1]
                in	al, dx
                and	al, 10h
                retn
endp		sub_FE36C





proc		sub_FE394 near		; ...
                push	ax
                mov	dl, [ds:dsk_status_2]
                in	al, dx
                mov	dl, [ds:dsk_status_1]
                mov	al, 0D0h
                out	dx, al
                call	sub_FE2DD
                mov	al, 9
                out	dx, al
                call	sub_FE2DD
                in	al, dx
                and	al, 5
                cmp	al, 4
                jz	short loc_FE3B7
                or	[byte ptr ds:dsk_ret_code_], 80h
                stc

loc_FE3B7:				; ...
                mov	dl, [ds:dsk_status_2]
                in	al, dx
                mov	[byte ptr si+0046h], 0
                pop	ax
                retn
endp		sub_FE394

proc		sub_FE452 near		; ...
                cli
                push	ax
                mov	al, [ds:video_mode_reg_]
                test	al, 1
                jz	short loc_FE48C
                mov	ax, es
                push	cx
                mov	cl, 4
                push	bx
                shr	bx, cl
                add	ax, bx
                pop	bx
                pop	cx
                push	ax
                mov	ax, [ds:0013h] ; main_ram_size
                cmp	ax, 0060h  ; 96 kb
                pop	ax
                ja	short loc_FE475
                mov	al, 0
                jmp	short loc_FE488
; ---------------------------------------------------------------------------

loc_FE475:				; ...
                cmp	ax, 7EC0h
                jb	short loc_FE48C
                cmp	ax, 0C000h
                jnb	short loc_FE48C
                mov	al, 0
                jmp	short loc_FE488
endp		sub_FE452





proc		sub_FE483 near		; ...
                sti
                push	ax
                mov	al, [ds:video_mode_reg_]

loc_FE488:				; ...
                mov	dx, 3D8h
                out	dx, al

loc_FE48C:				; ...
                pop	ax
                retn
endp		sub_FE483

