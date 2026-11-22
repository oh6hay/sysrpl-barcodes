ASSEMBLE
	NIBASC  /HPHP48-E/
RPL

DEFINE src 7GETLAM ( source grob string, hex )
DEFINE h 6GETLAM ( height )
DEFINE w 5GETLAM ( width )
DEFINE srn 4GETLAM ( nibbles per source row, 2*ceil[w/8] )
DEFINE p2 3GETLAM ( digits holding pixels, ceil[w/4] )
DEFINE offset 2GETLAM ( offset of the data in src )
DEFINE dst 1GETLAM ( dest grob string, hex, sans grob header )
DEFINE dststo 1PUTLAM

::
    0LASTOWDOB! CK1NOLASTWD
    CK1&Dispatch
    TWELVE ( grob )
    ::
        ( grob ) ( create destination grob )
        DUPGROBDIM
        ROT DECOMP$ UNROT ( grobstr hei wid )
        DUP SEVEN #+ EIGHT #/ SWAPDROP #2* ( grobstr hei wid srn )
        OVER THREE #+ FOUR #/ SWAPDROP ( grobstr hei wid srn p2 )
        5PICK ( grobstr hei wid srn p2 grobstr )
        LEN$ 5PICK 4PICK #* #- ( ..., offset )
        NULL$ ( ... dst )
        ' NULLLAM SEVEN NDUPN {}N BIND ( bind nulllams )

        h ZERO DO
          NULL$ ( row )
          p2 #1+ ONE DO
            "0123456789ABCDEF" ( row hex )
            src offset ( row hex src offset )
            JINDEX@ srn #* ( --skip whole rows )
            #+ INDEX@ #+ ( row hex src position-at-row )
            DUP SUB$ ( row hex digit[one hexdigitnibble] )
            ONE POS$ ( row v+1 )
            #2* DUP #1- SWAP ( row 2v+1 2v+2 )
            "0030C0F00333C3F30C3CCCFC0F3FCFFF" ( lookup table to map bits to bit pairs, nibble to byte )
            UNROT SUB$ ( row pair )
            &$ ( row' )
          LOOP
          DUP &$
          dst SWAP &$ dststo
        LOOP

        "GROB " w #2* #>$ &$ " " &$
        h #2* #>$ &$ " " &$ dst &$
        palparse DROP
        ABND
    ;
;
