DEBUG ?= TRUE

GCC = nspire-gcc
AS  = arm-none-eabi-as -mcpu=arm926ej-s # nspire-as
GXX = nspire-g++
LD  = nspire-ld
GENZEHN = genzehn

NSPIREIO ?= FALSE
NAVNETIO ?= FALSE

GCCFLAGS ?= 
GCCFLAGS += -Wall -W -marm # -include _nn_insert.h# -DKEYS_H # -mfloat-abi=softfp -mfpu=vfpv3 -nostdlib
O1FLAGS = 
LDFLAGS = # -Wl,--nspireio # -Wl,-wrap,printf -Wl,-wrap,puts # -Wl,-wrap,printf -Wl,-wrap,puts#-Wl,-nostdlib -lndls -lsyscalls
ZEHNFLAGS = --name "nspire-z80" --uses-lcd-blit false --240x320-support true

DEPLOY_DIR =

ifeq ($(NSPIREIO),TRUE)
	LDFLAGS += -Wl,--nspireio
	GCCFLAGS += -DNO_LCD
endif

ifeq ($(NAVNETIO),TRUE)
	LDFLAGS += -Wl,-wrap,printf -Wl,-wrap,puts
endif

ifeq ($(DEBUG),FALSE)
	GCCFLAGS += -Os
else
	GCCFLAGS += -O0 -g
	O1FLAGS += -O1
endif

OBJS = $(patsubst %.c, %.o, $(shell find . -name \*.c))
OBJS += $(patsubst %.cpp, %.o, $(shell find . -name \*.cpp))
OBJS += $(patsubst %.s, %.o, $(shell find . -name \*.s))
EXE = nspire-z80
DISTDIR = build
vpath %.tns $(DISTDIR)
vpath %.elf $(DISTDIR)

all: $(EXE).tns

$(DISTDIR)/%.o: %.c
	$(GCC) $(GCCFLAGS) -c $< -o $@

$(DISTDIR)/%.o: %.cpp
	$(GXX) $(GCCFLAGS) -c $< -o $@
	
$(DISTDIR)/%.o: %.s
	$(AS) -c $< -o $@

$(DISTDIR)/%_o1.o: %_o1.c
	$(GCC) $(GCCFLAGS) $(O1FLAGS) -c $< -o $@



$(EXE).elf: $(addprefix $(DISTDIR)/,$(OBJS))
	mkdir -p $(DISTDIR)
	$(LD) $^ -o $@ $(LDFLAGS)

$(EXE).tns: $(EXE).elf
	$(GENZEHN) --input $^ --output $@.zehn $(ZEHNFLAGS)
	make-prg $@.zehn $@
	rm $@.zehn

deploy: $(EXE).tns
	NavNet_launcher.exe NavNet_upload.exe "$(shell readlink -f $(EXE).tns | sed -e 's|/mnt/\(.\)/|\U\1:\\|' -e 's|/|\\|g')" "$(DEPLOY_DIR)$(EXE).tns"

clean:
	rm -f $(addprefix $(DISTDIR)/,$(OBJS)) $(DISTDIR)/$(EXE).tns $(DISTDIR)/$(EXE).elf $(DISTDIR)/$(EXE).zehn
