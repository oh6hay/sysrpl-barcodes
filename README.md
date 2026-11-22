# 1d and 2d barcodes in SysRPL

Long ago, my first public github repository (iirc) was 
[this one](https://github.com/oh6hay/hpcalc-barcode). For fun and to make
history come to life again, here's a QR code generator and some 1d
barcode generators implemented in SysRPL.

## how to compile

- The [hp tools for linux](https://www.hpcalc.org/details/4265)
  contains the `makerom`, `rplcomp`, `sasm`, and `sload` utilities in
  binary form that magically still work. Untar so that these binaries
  are in the current directory
- The [GNU HP Tools](https://www.hpcalc.org/details/3788) contains a
  SysRPL entries file `SupRomEntr.a` with entries that seem to work
  for both 48GX and 48SX. None of the programs here use GX-only entry
  points
- See [Makefile](Makefile), -- `make qrgen.bin`

## qrcode

This is a hairy one. The implementation follows the documented
[qr code step by step](https://www.nayuki.io/page/creating-a-qr-code-step-by-step)
approach, picking the easy mask pattern 0. Some implementation notes

- only ABUFF and GBUFF have easy PIXON/PIXOFF/PIXON? pixel
  set/clear/check facilities, so we draw on ABUFF (stack display),
  using one area for the target QR code and another are for the
  "function" (mark which modules (=pixels) were drawed on already)
- Originally the code computed the GF(256) exponents/multiplication
  table using a generator in SysRPL, but as it doesn't really depend
  on the input, it's now hardcoded as a hex string

## code39

A simple code39 generator. A few comments on the source code

- Each of the supported characters is 12 modules plus a blank
  space. Therefore, three hex characters encode each input character
- The generator uses the `charkey` to obtain an index of an input
  character
- Then, the `charnibbles` contains all 12 modules for each input
  character in the same order. To get the 12 modules for a character,
  find the input character index in `charkey` and find the
  corresponding three characters in the `charnibbles` string
- The `barkey` represents the bits in each hex digit
- A black bar is a black one-pixel-wide GROB
- White bars don't need to be drawn

## gr2x

A simple utility to 2x a GROB. Works by obtaining the string
representation of the grob, which really is just a long hex string. A
lookup table is used to make each bit two bits wide, like, `0010 -->
00001100`
