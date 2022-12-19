TODO:

- *DONE* fix setting of pointer @45 
- *DONE* properly save & restore device number (now set to 8)
- finish the INSTALL utility program: save all blocks, run B-A
- kmon: slow output in conversion on c128
- bootctl, prefs

end 64  = 41349 = $a185 @45
end 128 = 46469 = $b585 @174



        clc
        lda EAL
        sbc SAL
        sta EAL
        lda EAL+1
        sbc SAL+1
        sta EAL+1
        tax
