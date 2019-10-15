ifndef PETA_STAGE
$(error "Error: PETA_STAGE environment variable not set.  Change to the root of your PetaLinux install, and source the settings.sh file")
endif
include ../apps.common.mk

APP = ../../bin/ipbus

# Add any other object files to this list below
APP_OBJS = ipbus.o Client.o ipacl.o

all: build

build: $(APP)

$(APP): $(APP_OBJS)
	$(CXX) -std=c++11 $(CFLAGS) $(LDFLAGS) -o $@ $(APP_OBJS) $(LDLIBS) -lmemsvc -lmemhub -L${BUILD_HOME}/xhal/xcompile/memhub

clean:
	-rm -f $(APP) *.elf *.gdb *.o


%.o: %.cpp
	$(CXX) -std=c++0x -c $(CFLAGS) -I${BUILD_HOME}/ctp7_modules/include -o $@ $<

.PHONY: build
help:
	@echo ""
	@echo "Quick reference for various supported build targets for $(INSTANCE)."
	@echo "----------------------------------------------------"
	@echo "  clean                  clean out build objects"
	@echo "  all                    build $(INSTANCE)"
	@echo "  build                  build subsystem"
