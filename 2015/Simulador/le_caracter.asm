  jmp main
main:
  loadn r0,#10
  loadn r1, #0
  outchar r0,r1
  halt
  
;000010 | 0000 | 000000
;000000000001010
;111000 | 000 | 000 | 000 | 0
;000000000001010
;111000 | 001 | 000 | 000 | 0
;000000000000000
;110010| 000 | 001 | xxx | x
;001111 | x | xxxxxxxxx

;1100100000010000
;C810