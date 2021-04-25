NIMC = nim

NIMCACHE = ./cache

NIMFLAGS = -w:on --threads:on --nimcache:$(NIMCACHE)

BINDIR = bin
SRCDIR = src

_BINS = client server
BINS := $(patsubst %, $(BINDIR)/%, $(_BINS))


_SRCS := protocol.nim
SRCS := $(patsubst %, $(SRCDIR)/%, $(_SRCS))

all: $(BINS)

$(BINDIR)/client: $(SRCDIR)/client.nim $(SRCS)
	$(NIMC) c $(NIMFLAGS) -o:$@ $<

$(BINDIR)/server: $(SRCDIR)/server.nim $(SRCS)
	$(NIMC) c $(NIMFLAGS) -o:$@ $<

$(BINDIR):
	mkdir -p $@

clean:
	rm -rf $(BINDIR)
