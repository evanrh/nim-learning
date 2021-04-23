NIMC = nim

NIMFLAGS = -w:on
BINDIR = bin
BINS = recovery

MAIN = main.nim
SRCS := fat/fat.nim fat/headers.nim fat/fileops.nim

all: $(BINDIR)/$(BINS)

$(BINDIR)/recovery: $(MAIN) $(SRCS)
	$(NIMC) c $(NIMFLAGS) -o:$@ $<

$(BINDIR):
	mkdir -p $@

test: all
	./$(BINDIR)/$(BINS) ./random.img ./outputs

debug: $(MAIN)
	$(NIMC) c $(NIMFLAGS) --debugger:native -o:$(BINDIR)/recovery $(MAIN)
clean:
	rm -rf $(BINDIR)
