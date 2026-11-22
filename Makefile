# Generic HP 48 SysRPL/asm build with HP Tools (rplcomp/sasm/sload).
#
#   make foo.bin      build foo.bin from foo.s (or foo.S)
#   make              build a .bin for every .s/.S in this directory
#   make clean
#
# Override paths on the command line or in the environment, e.g.
#   make HPTOOLS=~/hp/hptools ENTRIES=~/hp/sdk/ENTRIES.O foo.bin

HPTOOLS ?= .
ENTRIES ?= SupRomEntr.o

RPLCOMP = $(HPTOOLS)/rplcomp
SASM    = $(HPTOOLS)/sasm
SLOAD   = $(HPTOOLS)/sload

MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
%.o: %.s
%.o: %.S

SRCS := $(wildcard *.s *.S)
BINS := $(addsuffix .bin,$(basename $(SRCS)))

all: $(BINS)

# 1. SysRPL -> Saturn assembly
%.a: %.s
	$(RPLCOMP) $< $@
%.a: %.S
	$(RPLCOMP) $< $@

# 2. assemble -> relocatable object (sasm writes $*.o and a $*.l listing)
%.o: %.a
	$(SASM) $<

# 3. loader control file, generated per program
%.m:
	printf 'OU %s.bin\nLL %s.lr\nSU XR\nSE %s\nRE %s.o\n' $* $* $(ENTRIES) $* > $@

# 4. link against the ROM entry table -> downloadable binary
%.bin: %.o %.m $(ENTRIES)
	$(SLOAD) -H $*.m

# sload exits non-zero on unresolved references but still writes the
# output; don't let a broken .bin look up to date.
.DELETE_ON_ERROR:

# Keep .a/.o/.m around: the .a and listings are handy when debugging.
.SECONDARY:

clean:
	rm -f $(BINS) $(foreach b,$(basename $(SRCS)),$(b).a $(b).o $(b).l $(b).lr $(b).m)

.PHONY: all clean
