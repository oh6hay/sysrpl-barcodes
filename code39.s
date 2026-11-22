ASSEMBLE
	NIBASC  /HPHP48-E/
RPL

DEFINE height SIXTEEN
DEFINE input 6GETLAM
DEFINE inputsto 6PUTLAM
DEFINE barkey 5GETLAM
DEFINE charnibbles 4GETLAM
DEFINE charkey 3GETLAM
DEFINE black 2GETLAM
DEFINE blacksto 2PUTLAM
DEFINE out 1GETLAM
DEFINE outsto 1PUTLAM

::
    0LASTOWDOB! CK1NOLASTWD
    CK1&Dispatch
	THREE ( must be a string )

    ::
        DUPLEN$ ( input length )
        TEN #> IT :: SETSIZEERR ;
        ( input )

        ( [hex 0..f as binary digits :D ] )
        "0000000100100011010001010110011110001001101010111100110111101111"
        ( store three nibbles per character and the key vector )
        "A6DD2BB2BD95A6BD35B35A5BD2DB2DD4BB4BDA5ACBD65B65A9BD4DB4DACDD53B53DA9AD3D69B69AB3D59B59AD9CAB9ABCD596BCB59B595BCAD9AD925929949A4996D"
        "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%*"
        NULL$ NULL$ ( input barkey charnibbles charkey black output )
        ' NULLLAM SIX NDUPN {}N BIND

        height input LEN$ #2+ THIRTEEN #* MAKEGROB outsto
        height ONE MAKEGROB INVGROB blacksto

        "*" input &$ "*" &$ inputsto

        input LEN$ #1+ ONE DO ( for i=1 to inputlength )
          input INDEX@ DUP SUB$ ( input[idx] )
          charkey SWAP ONE POS$ ( #pos )
          ( [not found?] )
          DUP #0= IT :: DROP THIRTYNINE ; ( [idx of space] )
          THREE #* #2- ( offset ) ( [offset in the output code39 chars] )
          DUP#2+ charnibbles 3UNROLL SUB$ ( [three nibbles for the character] )

          ( expand each nibble into 12 "0"/"1" characters )
          NULL$ SWAP ( bits hex3 )
          FOUR ONE DO ( [for each nibble in hex3] )
            "0123456789ABCDEF" OVER ( bits hex3 0-f hex3 )
            INDEX@ DUP SUB$ ( bits hex3 0-f [0-f]{1} )
            ONE POS$ ( bits hex3 v+1 )
            FOUR #* THREE #- DUP THREE #+ ( bits hex3 4v+1 4v+4 )
            barkey UNROT SUB$ ( bits hex3 1101 )
            ROTSWAP &$ SWAP ( bits' hex3 )
          LOOP
          DROP

          ( draw blacks )
          THIRTEEN ONE DO
            DUP INDEX@ SUB$1# FORTYNINE #= IT ( THIRTYONE is 1, meaning a black bar )
            :: black out
               JINDEX@ #1- THIRTEEN #* INDEX@ #1- #+ ZERO GROB! ;
          LOOP
          DROP

        LOOP
        out
        ABND
        
    ;
;
