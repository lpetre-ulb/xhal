SUBPACKAGES := \
        python \
        xhalcore \
        xhalarm

SUBPACKAGES.CLEAN    := $(patsubst %,%.clean,    $(SUBPACKAGES))
SUBPACKAGES.DEBUG    := $(patsubst %,%.debug,    $(SUBPACKAGES))
SUBPACKAGES.INSTALL  := $(patsubst %,%.install,  $(SUBPACKAGES))
SUBPACKAGES.UNINSTALL:= $(patsubst %,%.uninstall,$(SUBPACKAGES))
SUBPACKAGES.RPM      := $(patsubst %,%.rpm,      $(SUBPACKAGES))
SUBPACKAGES.CLEANRPM := $(patsubst %,%.cleanrpm, $(SUBPACKAGES))
SUBPACKAGES.DOC      := $(patsubst %,%.doc,      $(SUBPACKAGES))
SUBPACKAGES.CLEANDOC := $(patsubst %,%.cleandoc, $(SUBPACKAGES))

.PHONY: $(SUBPACKAGES) \
	$(SUBPACKAGES.CLEAN) \
	$(SUBPACKAGES.INSTALL) \
	$(SUBPACKAGES.UNINSTALL) \
	$(SUBPACKAGES.RPM) \
	$(SUBPACKAGES.CLEANRPM) \
	$(SUBPACKAGES.DOC) \
	$(SUBPACKAGES.CLEANDOC)

.PHONY: all build clean cleanall cleandoc cleanrpm
build: $(SUBPACKAGES)

all: $(SUBPACKAGES) $(SUBPACKAGES.DOC)

doc: $(SUBPACKAGES.DOC)

rpm: $(SUBPACKAGES) $(SUBPACKAGES.RPM)

clean: $(SUBPACKAGES.CLEAN)

cleanrpm: $(SUBPACKAGES.CLEANRPM)

cleandoc: $(SUBPACKAGES.CLEANDOC)

install: $(SUBPACKAGES) $(SUBPACKAGES.INSTALL)

uninstall: $(SUBPACKAGES.UNINSTALL)

cleanall: clean cleandoc cleanrpm

$(SUBPACKAGES):
	$(MAKE) -C $@

$(SUBPACKAGES.RPM): $(SUBPACKAGES)
	$(MAKE) -C $(patsubst %.rpm,%, $@) rpm

$(SUBPACKAGES.CLEAN):
	$(MAKE) -C $(patsubst %.clean,%, $@) clean

$(SUBPACKAGES.CLEANDOC):
	$(MAKE) -C $(patsubst %.cleandoc,%, $@) cleandoc

$(SUBPACKAGES.CLEANRPM):
	$(MAKE) -C $(patsubst %.cleanrpm,%, $@) cleanrpm

$(SUBPACKAGES.DOC):
	$(MAKE) -C $(patsubst %.doc,%, $@) doc

$(SUBPACKAGES.INSTALL): $(SUBPACKAGES)
	$(MAKE) -C $(patsubst %.install,%, $@) install

$(SUBPACKAGES.UNINSTALL): $(SUBPACKAGES)
	$(MAKE) -C $(patsubst %.uninstall,%, $@) uninstall

python:

xhalarm:

xhalcore:

xhalcore.install: xhalarm

xhalcore.rpm: xhalarm
