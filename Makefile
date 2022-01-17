X64SC=x64sc-3.5

default: run

# Build test program
reu-check.prg: reu-check.s linker.cfg
	cl65 -t c64 -C linker.cfg -o $@ $<

# Build 256KB REU image with zeroes and our testdata at the end
reu-image.bin: testdata
	dd bs=$(shell expr 256 \* 1024 \- 256) seek=1 of=$@ count=0 >/dev/null
	cat testdata >> $@

# Run test program in emulator with REU activated and image mounted
run: reu-check.prg reu-image.bin
	$(X64SC) -reu -reuimage reu-image.bin -reusize 256 reu-check.prg

clean:
	rm *.o *.prg *.bin
