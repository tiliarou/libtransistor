.section .text.jmp, "x"
NORELOC__filestart:
.global _start
_start:
        b start
	.word _mod_header - _start
	
.section .data.mod0
	.word 0, 8
.global _mod_header
_mod_header:
        .ascii "MOD0"
	.word __dynamic_start - _mod_header
	.word __bss_start - _mod_header
	.word __bss_end - _mod_header
	.word 0, 0 // eh_frame_hdr start/end
	.word 0 // runtime-generated module object offset
.global IS_NRO
IS_NRO: 
        .word 1
        
.section .text, "x"
.global start
start:
	// clear .bss
	adrp x5, __bss_start
	add x5, x5, #:lo12:__bss_start
	adrp x6, __bss_end
	add x6, x6, #:lo12:__bss_end

bssloop:
	cmp x5, x6
	b.eq run
	str xzr, [x5]
	add x5, x5, 8
	b bssloop

run:	
        adrp x2, _start // aslr base

        // set LR to svcExitProcess if it's null
        adrp x3, svcExitProcess
        add x3, x3, #:lo12:svcExitProcess
        cmp x30, xzr
        csel x30, x3, x30, eq

        sub sp, sp, 0x10
        stp x29, x30, [sp]
        bl _libtransistor_start
        ldp x29, x30, [sp], 0x10
        ret
