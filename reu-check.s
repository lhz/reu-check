;; REU registers
REU_STATUS	= $DF00
REU_COMMAND	= $DF01
REU_MEMORY	= $DF02
REU_OFFSET	= $DF04
REU_LENGTH	= $DF07
REU_FLAGS	= $DF09

	.addr $0801		; Load address

Basic:	.addr @end		; Next line pointer
	.word 2022		; Line number
	.byte $9e, "2064"	; SYS-line
@end:	.byte 0, 0, 0		; End of program


Start:	lda #$00		; Copy last page of REU image and check
	sta REU_OFFSET		; contents, should be bytes 00..FF in order
	lda #$FF
	sta REU_OFFSET + 1
	lda #$03
	sta REU_OFFSET + 2
	lda #<$CF00
	sta REU_MEMORY
	lda #>$CF00
	sta REU_MEMORY + 1
	lda #0
	sta REU_LENGTH
	lda #1
	sta REU_LENGTH + 1
	lda #0
	sta REU_FLAGS
	sta REU_FLAGS + 1
	lda #$91
	sta REU_COMMAND
	ldy #0

	lda $CF0D		; Check a few addresses for expected data
	cmp #$0D
	bne @err
	lda $CF37
	cmp #$37
	bne @err
	lda $CFFE
	cmp #$FE
	beq @ok

@err:	lda #10
	sta $0286
:	lda reu_error,y
	beq :+
	jsr $FFD2
	iny
	bne :-
:	lda #14
	sta $0286
	rts

@ok:	lda #13
	sta $0286
:	lda reu_ok,y
	beq :+
	jsr $FFD2
	iny
	bne :-
:	lda #14
	sta $0286
	rts

reu_error:
	.byte 13, "ram expansion unit does not contain"
	.byte 13, "expected data! set size to 256 kb"
	.byte 13, "and load image before running."
	.byte 13, 0

reu_ok:
	.byte 13, "ram expansion unit content validated."
	.byte 13, 0
