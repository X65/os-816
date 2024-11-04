.segment "STARTUP"
.word $CAFE

.segment "VEC816"
.word $1234     ; COP    65816 vector.
.word $5678     ; BRK    65816 vector.
.word $1234     ; ABORTB 65816 vector.
.word $5678     ; NMIB   65816 vector.
.word $1234     ;
.word $5678     ; IRQB   65816 vector.

.segment "VEC02"
.word $4322     ; ABORTB   65816 vector.
.word $8765     ; NMIB     6502 ector.
.word $4321     ; RESETB   6502 vector.
.word $8765     ; IRQB/BRK 6502 vector.
