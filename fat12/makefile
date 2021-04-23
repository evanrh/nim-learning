NIMC = nim

BINDIR = bin
BINS = recovery

MAIN = main.nim
SRCS := fat/fat.nim fat/headers.nim fat/fileops.nim

all: $(BINDIR)/$(BINS)

$(BINDIR)/recovery: $(MAIN) $(SRCS)
	$(NIMC) c -o:$@ $<

$(BINDIR):
	mkdir -p $@

test: all
	./$(BINDIR)/$(BINS) ./random.img ./outputs

clean:
	rm -rf $(BINDIR)
