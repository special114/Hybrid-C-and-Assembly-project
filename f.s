; A function that draws Bezier curve with five control points
; author: Rafał Surdej
; 05.2020

section .text

; rdi				pixel_buff
; [rbp - 8]			W
; [rbp - 16]		H
; [rbp - 24]		P0x
; [rbp - 32]		P0y
; [rbp - 40]		P1x
; [rbp + 16]		P1y
; [rbp + 24]		P2x
; [rbp + 32]		P2y
; [rbp + 40]		P3x
; [rbp + 48]		P3y
; [rbp + 56]		P4x
; [rbp + 64]		P4y
; [rbp - 48]		iterator
; [rbp - 56]		num of samples
; [rbp - 64] 		const. = 1
; [rbp - 72]		const. = 4
; [rbp - 80]		const. = 6
; [rbp - 88]		Px
; [rbp - 96]		Py


global f
f:
	push rbp
	mov rbp, rsp

	sub rsp, 200



	mov [rbp - 8], rsi			; W
	mov [rbp - 16], rdx			; H
	mov [rbp - 24], rcx			; P0x
	mov [rbp - 32], r8			; P0y
	mov [rbp - 40], r9			; P1x

	mov r8, 0
	mov r9, 3000

	mov QWORD [rbp - 48], r8
	mov QWORD [rbp - 56], r9
	mov QWORD [rbp - 64], 1
	mov QWORD [rbp - 72], 4
	mov QWORD [rbp - 80], 6


	fild QWORD [rbp - 56]				; num of sampl
	fild QWORD [rbp - 64]				; 1
	fdivr								; 1/num of sampl

	fild QWORD [rbp - 64]				; tmp
	fild QWORD [rbp - 64]				; 1-t
	fild QWORD [rbp - 48]				; t


	; Before calculations the stack looks like this:

	; st0	|---         t        ---|
	; st1	|---       1 - t      ---|
	; st2	|---        tmp       ---|
	; st3	|---  1 / num of samp ---|
	; st4	|------------------------|
	; st5	|------------------------|
	; st6	|------------------------|
	; st7	|------------------------|


	; To get the coordinates of certain point we need to calculate them from the equation below:
	;
	; P = (1-t)^4*P0 + 4(1-t)^3*t*P1 + 6(1-t)^2*t^2*P2 + 4(1-t)*t^3*P3 + t^4P4
	;
	; Program calculates each component of the sum starting and stores the sum on the stack.
	; During calculations the stack looks like the one below.
	; Temporary register is needed not to calculate twice the same coefficient for x and for y.
	; t is a parameter and its value changes from 0 to 1 with the frequency of 1 / number of samples.
	; As we store 1 / number of samples on the stack we don't need to access memory during all the
	; calculations.

	; st0	|---    current calculation    ---|
	; st1	|---   current sum of y comp.  ---|
	; st2	|---   current sum of x comp.  ---|
	; st3	|---            t              ---|
	; st4	|---          1 - t            ---|
	; st5	|---           tmp             ---|
	; st6	|---       1/num of samp       ---|
	; st7	|---------------------------------|

loop:
	fld st1
	fmul st0, st2				; (1-t)^2
	fld st0
	fmul						; (1-t)^4
	fst st3
	fild QWORD [rbp - 24]		; P0x
	fmul						; (1-t)^4*P0x
	fld st3						; (1-t)^4
	fild QWORD [rbp - 32]		; P0y
	fmul 						; (1-t)^4*P0y

	fld st3						; 1-t
	fmul st0, st4				; (1-t)^2
	fmul st0, st4				; (1-t)^3
	fmul st0, st3				; (1-t)^3*t
	fild QWORD [rbp - 72]		; 4
	fmul						; 4^(1-t)^3*t
	fst st5						;
	fild QWORD [rbp - 40]		; P1x
	fmul						; 4^(1-t)^3*t*P1x
	faddp st2, st0				; (1-t)^4*P0x + 4^(1-t)^3*t*P1x
	fld st4						; 4^(1-t)^3*t
	fild QWORD [rbp + 16]		; P1y
	fmul						; 4^(1-t)^3*t*P1y
	fadd						; (1-t)^4*P0y + 4^(1-t)^3*t*P1y

	fld st3						; 1-t
	fmul st0, st4				; (1-t)^2
	fmul st0, st3				; (1-t)^2*t
	fmul st0, st3				; (1-t)^2*t^2
	fild QWORD [rbp - 80]		; 6
	fmul						; 6*(1-t)^2*t^2
	fst st5
	fild QWORD [rbp + 24]		; P2x
	fmul						; 6*(1-t)^2*t^2*P2x
	faddp st2, st0				; (1-t)^4*P0x + 4^(1-t)^3*t*P1x + 6*(1-t)^2*t^2*P2x	~ 96.4654
	fld st4						; 6*(1-t)^2*t^2
	fild QWORD [rbp + 32]		; P2y
	fmul						; 6*(1-t)^2*t^2*P2y
	fadd						; (1-t)^4*P0y + 4^(1-t)^3*t*P1y + 6*(1-t)^2*t^2*P2y	~ 192.925

	fld st2						; t
	fmul st0, st3				; t^2
	fmul st0, st3				; t^3
	fmul st0, st4				; (1-t)*t^3
	fild QWORD [rbp - 72]		; 4
	fmul						; 4*(1-t)*t^3
	fst st5
	fild QWORD [rbp + 40]		; P3x
	fmul						; 4*(1-t)*t^3*P3x
	faddp st2, st0				; (1-t)^4*P0x + 4^(1-t)^3*t*P1x + 6*(1-t)^2*t^2*P2x + 4*(1-t)*t^3*P3x ~ 96.505
	fld st4						; 4*(1-t)*t^3
	fild QWORD [rbp + 48]		; P3y
	fmul						; 4*(1-t)*t^3*P3y
	fadd						; (1-t)^4*P0y + 4^(1-t)^3*t*P1y + 6*(1-t)^2*t^2*P2y + 4*(1-t)*t^3*P3y ~ 192.964

	fld st2						; t
	fmul st0, st3				; t^2
	fld st0
	fmul						; t^4
	fst st5
	fild QWORD [rbp + 56]		; P4x
	fmul						; t^4*P4x
	faddp st2, st0				; (1-t)^4*P0x + 4^(1-t)^3*t*P1x + 6*(1-t)^2*t^2*P2x + 4*(1-t)*t^3*P3x + t^4*P4x
	fld st4						; t^4
	fild QWORD [rbp + 64]		; P4y
	fmul						; t^4*P4y
	fadd						; (1-t)^4*P0y + 4^(1-t)^3*t*P1y + 6*(1-t)^2*t^2*P2y + 4*(1-t)*t^3*P3y + t^4*P4y


	fistp QWORD [rbp - 96]		; save Py
	fistp QWORD [rbp - 88]		; save Px


	mov r10, [rbp - 96]			; r10 = Py
	imul r10, [rbp - 8]			; W*Py
	add r10, [rbp - 88]			; W*Py + Px

	mov DWORD [rdi + r10 * 4], 0xff000000


	fadd st0, st3				; t += 1/num of samples
	fld st3
	fsubp st2, st0				; (1-t) -= 1/num of samples
	inc r8						; iterator += 1
	cmp r8, r9					; if iterator <= num of samples
	jle loop					; repeat calculations


end:
	mov rsp, rbp
	pop rbp
	ret
