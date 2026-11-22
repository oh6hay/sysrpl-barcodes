ASSEMBLE
	NIBASC  /HPHP48-E/
RPL

* graphics
DEFINE QX FOUR
DEFINE QY FOUR
DEFINE FX FORTYNINE
DEFINE FY FOUR

* nice names for nulllams
DEFINE input 11GETLAM
DEFINE data 11GETLAM
DEFINE datasto 11PUTLAM
DEFINE qrsize 10GETLAM
DEFINE codewords 9GETLAM
DEFINE eccodewords 8GETLAM
DEFINE xycenter 7GETLAM
DEFINE genpoly 6GETLAM ( ec generator polynomial coefficients )
DEFINE ecrem 5GETLAM
DEFINE ecremsto 5PUTLAM
DEFINE exptable 4GETLAM
DEFINE exptablesto 4PUTLAM
DEFINE setxyandfunc 3GETLAM EVAL ( x y val -> )
DEFINE setregionandfunc 2GETLAM EVAL ( x y wid hei val -> )
DEFINE isfunc? 1GETLAM EVAL ( x y -> isset? )


::
	CK1&Dispatch
	THREE ( must be a string )

	::
		DUP ( input input )
		( check string length, output { size #codewords #eccodewords #xycenter } )
		LEN$ ( input len )
		:: 
				DUP # 12 #< casedrop { TWENTYONE NINETEEN SEVEN ZERO 
					{ # 57 # E5 # 92 # 95 # EE # 66 # 15 } }
				DUP # 21 #< casedrop { TWENTYFIVE THIRTYFOUR TEN EIGHTEEN 
					{ # FB # 43 # 2E # 3D # 76 # 46 # 40 # 5E # 20 # 2D } }
				DUP # 36 #< casedrop { TWENTYNINE FIFTYFIVE FIFTEEN TWENTYTWO 
					{ # 08 # B7 # 3D # 5B # CA # 25 # 33 # 3A # 3A # ED
					  # 8C # 7C # 05 # 63 # 69 } }
				DUP # 4F #< casedrop { THIRTYTHREE EIGHTY TWENTY TWENTYSIX 
					{ # 11 # 3C # 4F # 32 # 3D # A3 # 1A # BB # CA # B4
			    	  # DD # E1 # 53 # EF # 9C # A4 # D4 # D4 # BC # BE } }
				DROP SETSIZEERR
		; ( input { size codewords .. xycenter } )
		INCOMPDROP ( input size codewords .. xycenter )
		NULL$ NULL$ ( input size codewords .. xycenter null null null null )
		
		( graphics helpers: )
		( setxyandfunc )
		' :: ( x y val )
		  UNROT ( val x y )
		  ( set func: )
		  2DUP FY #+ SWAP FX #+ SWAP PIXON
		  ( set on screen )
		  QY #+ SWAP QX #+ SWAP ( val qx qy )
		  ROT ( qx qy val )
		  ITE PIXON PIXOFF
		;

		( setregionandfunc )
		' :: ( x y wid hei val )
		  3UNROLL ( x y val wid hei )
		  ( mask it first )
		  2DUP SWAP MAKEGROB INVGROB ( x y val wid hei func )
		  6PICK 6PICK ( x y val wid hei func x y )
		  ABUFF 3UNROLL ( x y val wid hei func ABUFF x y )
		  FY #+ SWAP FX #+ SWAP ( x y val wid hei ABUFF func fx fy )
		  GROB! ( x y val wid hei )  ( draw func on screen! )
		  SWAP MAKEGROB SWAP IT INVGROB ( x y region )
		  ABUFF 4UNROLL 4UNROLL ( region ABUFF x y )
		  QY #+ SWAP QX #+ SWAP ( region abuff qx qy )
		  GROB!
		;

		( isfunc? )
		( x y -> isset? )
		' ::
		  FY #+ SWAP FX #+ SWAP PIXON?
		;
		
		( assign to nulllams )
  		' NULLLAM ELEVEN NDUPN {}N BIND

		( now, construct the data bitstream )
		( prepend count to the input )
		input DUPLEN$ #>CHR >H$ datasto

		( some status )
		ClrDA1IsStat RECLAIMDISP
		"comp. data stream" DISPROW1

		NULL$ FOUR ( outstring #leftover )
		( at the start of the loop, nothing has been written to the output, and the mode nibble is a leftover )
		data LEN$ #1+ ONE DO
			 data INDEX@ SUB$1# ( outstring leftover data[index] )
			 SIXTEEN #/ ( outstring leftover lo hi ) ( #/ leaves remainder quotient )
			 ROT SIXTEEN #* #+ ( outstring lo lft*16+hi ) 
			 #>CHR ROTSWAP ( lo outstring newchar )
			 >T$ SWAP ( outstring lo )
		LOOP
		SIXTEEN #* #>CHR >T$ ( append last nibble and terminator )

		"computing padding" DISPROW2
		( now fill until it's #codewords bytes long )
		DUPLEN$ codewords SWAP #-
		( padding needed? )
		DUP #0<> ITE
		::
			#1+ ONE DO
				INDEX@ TWO #/ DROP ( data even-char-1? )
				#0=ITE
					:: SEVENTEEN #>CHR >T$ ; ( data.0x11 )
					:: # ec #>CHR >T$ ; ( data.0xec )
			LOOP
		; DROP ( drop the padding guard )
		datasto

		"exp table" DISPROW3

		( exp table: alpha^0 … alpha^254, as a constant string )
ASSEMBLE
        CON(5)  =DOCSTR
        REL(5)  exptabend
        NIBHEX  1020408001020408D1A3478EDC783162C489D2A54B57AE9CF83060C08103060C
        NIBHEX  D972E4C952A44953A64D5B77EE1CF93264C850A04182050AD5AB962D9BF6ED1A
        NIBHEX  F5EB162C99F2E5CB56AC98F0E1C3870FDF7E3DBBB66D1BF7EF1EFD3AB56B172E
        NIBHEX  9DFA346811224488D0A143860DDB76EC18F1E3C78FDE7C39B367CE5C793366CC
        NIBHEX  5871E2C58BD6AD9AF4E912244851A2458AD4A992254A55AA942993274E5D7B37
        NIBHEX  6E1DFB366C19F3E7CF5E7D3BB76F1FFF3EBDBAB46913264C5973E6CD5A75EA14
        NIBHEX  289123468CD870E0C183070EDD7A356A152A952B972F9FFE3CB9B265CA54A890
        NIBHEX  21428409D3A74F5F7F3FBFBEBCB8B061C2850BD7AF9EFC38B163C68DDA74E8
exptabend
RPL
		exptablesto

		( first construct the ec bytes )
		NULL$
		eccodewords #1+ ONE DO
			ZERO #>CHR >T$
		LOOP ecremsto

		( now the mess that is reed-solomon )
		data LEN$ #1+ ONE DO
			 ( f = data[i] XOR rem[1] )
			 data INDEX@ DUP SUB$ ( b )
			 ecrem ONEONE SUB$ XOR$ ( f )
			 exptable SWAP ONE POS$ ( #pos ) ( find index of f in exptable )
			 ( shift rem[2..n] + 00 )
			 ecrem TWO eccodewords SUB$ ( $pos $rem[2..n] )
			 ZERO #>CHR >T$ ( pos shifted )
			 SWAP ( shifted pos )
			 
			 DUP #0<> ITE (  )
			 ::
				#1- ( shifted lf )
				NULL$ SWAP ( shifted p lf )
				eccodewords #1+ ONE DO
				  genpoly INDEX@ NTHCOMPDROP ( shifted p lf g )
				  OVER #+ ( shifted p lf e )
				  DUP # FE #> IT ( is e >= 255? )
				  	  :: # FF #- ;
				  #1+ exptable SWAP DUP SUB$ ( shifted p lf byte )
				  ROT SWAP &$ SWAP ( shifted p' lf )
				LOOP
				DROP ( shifted p )
				XOR$ ( rem )
			 ;
			 DROP ecremsto
		LOOP

		data ecrem &$ datasto

		( now the fun stuff, drawing on screen! )
		RECLAIMDISP
        
		( dummy format bits )
		ZERO EIGHT NINE ONE FALSE setregionandfunc
        EIGHT ZERO ONE NINE FALSE setregionandfunc
        qrsize EIGHT #- EIGHT EIGHT ONE FALSE setregionandfunc
        EIGHT qrsize SEVEN #- ONE SEVEN FALSE setregionandfunc
        EIGHT qrsize EIGHT #- TRUE setxyandfunc

        ( timing pattern )
        qrsize ZERO DO
            INDEX@ TWO #/ DROP #0= ( even-flag )
            DUP SIX INDEX@ ROT setxyandfunc
            INDEX@ SIX ROT setxyandfunc
        LOOP

        ( finder patterns )
        ZERO ZERO EIGHT EIGHT FALSE setregionandfunc
        ZERO ZERO SEVEN SEVEN TRUE setregionandfunc
        ONE ONE FIVE FIVE FALSE setregionandfunc
        TWO TWO THREE THREE TRUE setregionandfunc

        qrsize EIGHT #- ZERO EIGHT EIGHT FALSE setregionandfunc
        qrsize SEVEN #- ZERO SEVEN SEVEN TRUE setregionandfunc
        qrsize SIX #- ONE FIVE FIVE FALSE setregionandfunc
        qrsize FIVE #- TWO THREE THREE TRUE setregionandfunc

        ZERO qrsize EIGHT #- EIGHT EIGHT FALSE setregionandfunc
        ZERO qrsize SEVEN #- SEVEN SEVEN TRUE setregionandfunc
        ONE qrsize SIX #- FIVE FIVE FALSE setregionandfunc
        TWO qrsize FIVE #- THREE THREE TRUE setregionandfunc

        xycenter #0<> IT
        ::
            xycenter TWO #- DUP FIVE FIVE TRUE setregionandfunc
            xycenter #1- DUP THREE THREE FALSE setregionandfunc
            xycenter DUP TRUE setxyandfunc
        ;

        ( now draw the actual data stream )
        ( hmm let's add an extra zero byte just in case )
        data ZERO #>CHR >T$ datasto

        ZERO ( i )  ( it's a bit counter )
        qrsize #1- TWO #/ SWAPDROP ( i numpairs ) ( we operate in strips here! a strip is two columns )
        ZERO DO ( horizontal loop )
             qrsize ZERO DO ( vertical loop )
                  JINDEX@ TWO #/ DROP #0= ( even strip? )
                  ITE 
                  :: qrsize #1- INDEX@ #- ; ( yes, we go up:  n-1-vert ) ( i y )
                  INDEX@ ( no, we go down: vert ) ( i y )

                  qrsize #1- JINDEX@ DUP #+ #- ( i y right-column )
                  DUP SEVEN #< IT #1- ( i y right )  ( here, we just skip the timing column at col=6 )
                  TWO ZERO DO
                      DUP INDEX@ #- ( i y right x )
                      3PICK 5ROLL ( y right x y i )
                      ( reserved? )
                      3PICK 3PICK isfunc? ( y right x y i isfunc? )
                      ITE
                      :: UNROT 2DROP ; ( it was a func: drop x y, keep i )
                      ::
                        DUP EIGHT #/ ( x y i r q )
                        #1+ data SWAP SUB$1# ( x y i r byte )
                        SWAP { # 80 # 40 THIRTYTWO SIXTEEN EIGHT FOUR TWO ONE }
                        SWAP #1+ NTHCOMPDROP ( x y i byte pow )
                        #/ SWAPDROP TWO #/ DROP ( x y i bit )
                        4PICK 4PICK #+ #1+ TWO #/ DROP ( x y i bit m )
                        #+ TWO #/ DROP ( x y i dark? )
                        #0<> IT :: 3PICK QX #+ 3PICK QY #+ PIXON ; ( x y i )
                        #1+ UNROT 2DROP ( i+1 )
                      ;
                      3UNROLL ( i y right )
                  LOOP
                  2DROP
             LOOP
        LOOP
        DROP

        ( now the format bits )
        # 77C4 ( format ) ( magical, derived from error correction level and mask number )
        ( which always works out to 0x77c4 )
        ( fmt )
        FIFTEEN ZERO DO
            TWO #/ ( bit fmt' )
            SWAP #0<> ( fmt' dark? )
            ( first copy from funny positions )
            { EIGHT EIGHT EIGHT EIGHT EIGHT EIGHT EIGHT EIGHT
              SEVEN FIVE FOUR THREE TWO ONE ZERO }
            INDEX@ #1+ NTHCOMPDROP ( fmt' dark? x1 )
            { ZERO ONE TWO THREE FOUR FIVE SEVEN EIGHT
              EIGHT EIGHT EIGHT EIGHT EIGHT EIGHT EIGHT }
            INDEX@ #1+ NTHCOMPDROP ( fmt' dark? x1 y1 )
            3PICK setxyandfunc

            ( now the straight runs, )
            INDEX@ EIGHT #< ITE
              :: qrsize #1- INDEX@ #- EIGHT ;
              :: EIGHT qrsize FIFTEEN #- INDEX@ #+ ;
            ROT setxyandfunc
        LOOP
        DROP

        ( now pick the qr from the screen, including some blank space )
        ABUFF
        QX FOUR #- QY FOUR #-
        qrsize EIGHT #+ qrsize EIGHT #+
        SUBGROB

        ABND ( abandon temp env )
        SetDAsTemp ( remain showing ABUFF as is )
    ;

;
