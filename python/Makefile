SUBPACKAGES := \
        reg_interface_gem

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

.PHONY: all build clean cleanall cleandoc cleanrpm doc install uninstall rpm
build: $(SUBPACKAGES)

all: $(SUBPACKAGES) $(SUBPACKAGES.DOC)

rpm: $(SUBPACKAGES) $(SUBPACKAGES.RPM)

doc: $(SUBPACKAGES.DOC)

clean: $(SUBPACKAGES.CLEAN)

cleandoc: $(SUBPACKAGES.CLEANDOC)

cleanrpm: $(SUBPACKAGES.CLEANRPM)

install: $(SUBPACKAGES.INSTALL)

uninstall: $(SUBPACKAGES.UNINSTALL)

cleanall: clean cleandoc cleanrpm

$(SUBPACKAGES):
	$(MAKE) -C $@

$(SUBPACKAGES.RPM):
	$(MAKE) -C $(patsubst %.rpm,%, $@) rpm

$(SUBPACKAGES.CLEAN):
	$(MAKE) -C $(patsubst %.clean,%, $@) clean

$(SUBPACKAGES.CLEANDOC):
	$(MAKE) -C $(patsubst %.cleandoc,%, $@) cleandoc

$(SUBPACKAGES.CLEANRPM):
	$(MAKE) -C $(patsubst %.cleanrpm,%, $@) cleanrpm

$(SUBPACKAGES.DOC):
	$(MAKE) -C $(patsubst %.doc,%, $@) html

$(SUBPACKAGES.INSTALL):
	$(MAKE) -C $(patsubst %.install,%, $@) install-site

$(SUBPACKAGES.UNINSTALL):
	$(MAKE) -C $(patsubst %.uninstall,%, $@) uninstall-site
