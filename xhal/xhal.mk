BUILD_HOME   := $(shell dirname `cd ../; pwd`)
Project      := xhal
Package      := xhal
ShortPackage := xhal
LongPackage  := $(TargetArch)
PackageName  := $(ShortPackage)
PackagePath  := $(TargetArch)
PackageDir   := pkg/$(ShortPackage)
Packager     := Mykhailo Dalchenko
Arch         := $(TargetArch)

ProjectPath:=$(BUILD_HOME)/$(Project)

ConfigDir:=$(ProjectPath)/config

include $(ConfigDir)/mfCommonDefs.mk

ifeq ($(Arch),x86_64)
CFLAGS=-Wall -pthread
ADDFLAGS=-fPIC -std=c++14 -m64
else
include $(ConfigDir)/mfZynq.mk
ADDFLAGS=-std=c++14
endif

ADDFLAGS+=$(OPTFLAGS)

PackageSourceDir:=src
PackageIncludeDir:=include
PackageObjectDir:=$(PackagePath)/src/linux/$(Arch)
PackageLibraryDir:=$(PackagePath)/lib
PackageExecDir:=$(PackagePath)/bin
PackageDocsDir:=$(PackagePath)/doc/_build/html

XHAL_VER_MAJOR:=$(shell $(ConfigDir)/tag2rel.sh | awk '{split($$0,a," "); print a[1];}' | awk '{split($$0,b,":"); print b[2];}')
XHAL_VER_MINOR:=$(shell $(ConfigDir)/tag2rel.sh | awk '{split($$0,a," "); print a[2];}' | awk '{split($$0,b,":"); print b[2];}')
XHAL_VER_PATCH:=$(shell $(ConfigDir)/tag2rel.sh | awk '{split($$0,a," "); print a[3];}' | awk '{split($$0,b,":"); print b[2];}')

IncludeDirs+= $(PackageIncludeDir)
IncludeDirs+= $(PackageIncludeDir)/xhal/extern

Libraries+=-llog4cplus -lxerces-c -lstdc++
LibraryDirs+=$(PackageLibraryDir)

ifeq ($(Arch),x86_64)
IncludeDirs+= $(XDAQ_ROOT)/include

Libraries+=-lwiscrpcsvc
LibraryDirs+=$(XDAQ_ROOT)/lib
LibraryDirs+=$(WISCRPC_ROOT)/lib
else

endif

INC=$(IncludeDirs:%=-I%)
LDFLAGS+=$(LibraryDirs:%=-L%)

SRCS_XHAL   = $(wildcard $(PackageSourceDir)/common/utils/*.cpp)
SRCS_XHAL  += $(wildcard $(PackageSourceDir)/common/rpc/*.cpp)
SRCS_CLIENT = $(wildcard $(PackageSourceDir)/client/*.cpp)
SRCS_SERVER = $(wildcard $(PackageSourceDir)/server/*.cpp)
# SRCS_EXES     = $(wildcard $(PackageSourceDir)/*.cxx)
# SRCS_TEST_EXES= $(wildcard $(PackageTestSourceDir)/*.cxx)

AUTODEPS_XHAL   = $(patsubst $(PackageSourceDir)/%.cpp,$(PackageObjectDir)/%.d,$(SRCS_XHAL))
AUTODEPS_CLIENT = $(patsubst $(PackageSourceDir)/%.cpp,$(PackageObjectDir)/%.d,$(SRCS_CLIENT))
AUTODEPS_SERVER = $(patsubst $(PackageSourceDir)/%.cpp,$(PackageObjectDir)/%.d,$(SRCS_SERVER))

OBJS_XHAL   = $(patsubst %.d,%.o,$(AUTODEPS_XHAL))
OBJS_CLIENT = $(patsubst %.d,%.o,$(AUTODEPS_CLIENT))
OBJS_SERVER = $(patsubst %.d,%.o,$(AUTODEPS_SERVER))

XHAL_LIB   = $(PackageLibraryDir)/libxhal-base.so
CLIENT_LIB = $(PackageLibraryDir)/libxhal-client.so
SERVER_LIB = $(PackageLibraryDir)/libxhal-server.so

ifeq ($(Arch),x86_64)
TargetLibraries:= xhal-base xhal-server xhal-client
else
TargetLibraries:= xhal-base xhal-server
endif

## Update spec file for subpackage specific requirements
ifndef BASE_REQUIRED_PACKAGE_LIST
BASE_REQUIRED_PACKAGE_LIST=$(shell awk 'BEGIN{IGNORECASE=1} /define XHAL_BASE_REQUIRED_PACKAGE_LIST/ {print $$3;}' $(PackageIncludeDir)/packageinfo.h)
endif

ifndef CLIENT_REQUIRED_PACKAGE_LIST
CLIENT_REQUIRED_PACKAGE_LIST=$(shell awk 'BEGIN{IGNORECASE=1} /define XHAL_CLIENT_REQUIRED_PACKAGE_LIST/ {print $$3;}' $(PackageIncludeDir)/packageinfo.h)
endif

ifndef SERVER_REQUIRED_PACKAGE_LIST
SERVER_REQUIRED_PACKAGE_LIST=$(shell awk 'BEGIN{IGNORECASE=1} /define XHAL_SERVER_REQUIRED_PACKAGE_LIST/ {print $$3;}' $(PackageIncludeDir)/packageinfo.h)
endif

ifndef BASE_BUILD_REQUIRED_PACKAGE_LIST
BASE_BUILD_REQUIRED_PACKAGE_LIST=$(shell awk 'BEGIN{IGNORECASE=1} /define XHAL_BASE_BUILD_REQUIRED_PACKAGE_LIST/ {print $$3;}' $(PackageIncludeDir)/packageinfo.h)
endif

ifndef CLIENT_BUILD_REQUIRED_PACKAGE_LIST
CLIENT_BUILD_REQUIRED_PACKAGE_LIST=$(shell awk 'BEGIN{IGNORECASE=1} /define XHAL_CLIENT_BUILD_REQUIRED_PACKAGE_LIST/ {print $$3;}' $(PackageIncludeDir)/packageinfo.h)
endif

ifndef SERVER_BUILD_REQUIRED_PACKAGE_LIST
SERVER_BUILD_REQUIRED_PACKAGE_LIST=$(shell awk 'BEGIN{IGNORECASE=1} /define XHAL_SERVER_BUILD_REQUIRED_PACKAGE_LIST/ {print $$3;}' $(PackageIncludeDir)/packageinfo.h)
endif

## Override the RPM_DIR variable because we're a special case
RPM_DIR:=$(ProjectPath)/$(PackageName)/$(LongPackage)/rpm
include $(ConfigDir)/mfRPMRules.mk

$(PackageSpecFile): $(ProjectPath)/$(PackageName)/spec.template

specificspecupdate: $(PackageSpecFile)
	echo Running specific spec update
	sed -i 's#__base_requires_list__#$(BASE_REQUIRED_PACKAGE_LIST)#'                 $<
	sed -i 's#__base_build_requires_list__#$(BASE_BUILD_REQUIRED_PACKAGE_LIST)#'     $<
	sed -i 's#__client_requires_list__#$(CLIENT_REQUIRED_PACKAGE_LIST)#'             $<
	sed -i 's#__client_build_requires_list__#$(CLIENT_BUILD_REQUIRED_PACKAGE_LIST)#' $<
	sed -i 's#__server_requires_list__#$(SERVER_REQUIRED_PACKAGE_LIST)#'             $<
	sed -i 's#__server_build_requires_list__#$(SERVER_BUILD_REQUIRED_PACKAGE_LIST)#' $<

# destination path macro we'll use below
df = $(PackageObjectDir)/$(*F)

.PHONY: xhal-base xhal-client xhal-server

## @xhal Compile all target libraries
build: $(TargetLibraries)

all:

default: $(TARGETS)

## @xhal Prepare the package for building the RPM
rpmprep: build doc

# Define as dependency everything that should cause a rebuild
TarballDependencies = $(XHAL_LIB) $(SERVER_LIB) Makefile xhal.mk spec.template $(PackageIncludeDir)/packageinfo.h
ifeq ($(Arch),x86_64)
TarballDependencies+= $(CLIENT_LIB)
else
endif

## this needs to reproduce the compiled tree because... wrong headed
## either do the make in the spec file, or don't make up your mind!
$(PackageSourceTarball): $(TarballDependencies)
	$(MakeDir) $(PackagePath)/$(PackageDir)
ifeq ($(Arch),x86_64)
	echo nothing to do
else
	$(MakeDir) $(PackagePath)/$(PackageDir)/gem-peta-stage/ctp7/$(INSTALL_PATH)/lib
	@cp -rfp $(PackageLibraryDir)/* $(PackagePath)/$(PackageDir)/gem-peta-stage/ctp7/$(INSTALL_PATH)/lib
endif
	$(MakeDir) $(RPM_DIR)
	@cp -rfp spec.template $(PackagePath)
	$(MakeDir) $(PackagePath)/$(PackageDir)/$(PackageName)/$(LongPackage)
	@cp -rfp --parents $(PackageObjectDir) $(PackagePath)/$(PackageDir)/$(PackageName)
	@cp -rfp --parents $(PackageLibraryDir) $(PackagePath)/$(PackageDir)/$(PackageName)
	-cp -rfp --parents $(PackageExecDir) $(PackagePath)/$(PackageDir)/$(PackageName)
	@cp -rfp $(PackageSourceDir) $(PackagePath)/$(PackageDir)/$(PackageName)
	@cp -rfp $(PackageIncludeDir) $(PackagePath)/$(PackageDir)/$(PackageName)
	@cp -rfp xhal.mk $(PackagePath)/$(PackageDir)/$(PackageName)/Makefile
	@cp -rfp $(ProjectPath)/config $(PackagePath)/$(PackageDir)
#	cd $(ProjectPath); cp -rfp --parents xhal/Makefile $(PackagePath)/$(PackageDir)
#	cd $(ProjectPath); cp -rfp --parents xhal/{include,src} $(PackagePath)/$(PackageDir)
	cd $(PackagePath)/$(PackageDir)/..; \
	    tar cjf $(PackageSourceTarball) . ;
#	$(RM) $(PackagePath)/$(PackageDir)

## @xhal Compile the xhal library
xhal-base: $(XHAL_LIB)

## @xhal Compile the xhal-client library
xhal-client: $(CLIENT_LIB)

## @xhal Compile the xhal-server library
xhal-server: $(SERVER_LIB)

## adapted from http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/
## Generic object creation rule, generate dependencies and use them later
$(PackageObjectDir)/%.o: $(PackageSourceDir)/%.cpp Makefile
	$(MakeDir) $(@D)
	$(CXX) $(CFLAGS) $(ADDFLAGS) $(INC) -c -MT $@ -MMD -MP -MF $(@D)/$(*F).Td -o $@ $<
	mv $(@D)/$(*F).Td $(@D)/$(*F).d
	touch $@

## dummy rule for dependencies
$(PackageObjectDir)/%.d:

## mark dependencies and objects as not auto-removed
.PRECIOUS: $(PackageObjectDir)/%.d
.PRECIOUS: $(PackageObjectDir)/%.o

## Force rule for all target library names
$(TargetLibraries):

$(XHAL_LIB): $(OBJS_XHAL)
	$(MakeDir) -p $(@D)
	$(CXX) $(ADDFLAGS) $(LDFLAGS) $(SOFLAGS) -o $(@D)/$(LibraryFull) $^ $(Libraries)
	$(link-sonames)

$(CLIENT_LIB): $(OBJS_CLIENT)
	$(MakeDir) -p $(@D)
	$(CXX) $(ADDFLAGS) $(LDFLAGS) $(SOFLAGS) -o $(@D)/$(LibraryFull) $^ $(Libraries)
	$(link-sonames)

$(SERVER_LIB): $(OBJS_SERVER)
	$(MakeDir) -p $(@D)
	$(CXX) $(ADDFLAGS) $(LDFLAGS) $(SOFLAGS) -o $(@D)/$(LibraryFull) $^ $(Libraries)
	$(link-sonames)

ifeq ($(Arch),x86_64)
else
TARGET_BOARD?=ctp7

install: crosslibinstall

uninstall: crosslibuninstall

endif

clean:
	$(RM) $(OBJS_XHAL) $(OBJS_CLIENT) $(OBJS_SERVER)
	$(RM) $(PackageLibraryDir)
	$(RM) $(PackageExecDir)
	$(RM) $(PackagePath)/$(PackageDir)

cleanall:
	$(RM) $(PackageObjectDir)
	$(RM) $(PackagePath)
