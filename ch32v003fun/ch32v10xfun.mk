TARGET_MCU_PACKAGE?=CH32V103R8T6
MCU_PACKAGE?=1

CFLAGS+= \
	-g -Os -flto -ffunction-sections -fdata-sections \
	-static-libgcc \
	-march=rv32imac \
	-mabi=ilp32 \
	-msmall-data-limit=8 \
	-mno-save-restore \
	-fmessage-length=0 \
	-fsigned-char \
	-I/usr/include/newlib \
	-I$(CH32V003FUN) \
	-nostdlib \
	-DCH32V10x=1 \
	-I. -Wall

# MCU Flash/RAM split
ifeq ($(findstring R8, $(TARGET_MCU_PACKAGE)), R8)
	MCU_PACKAGE:=1
else ifeq ($(findstring C8, $(TARGET_MCU_PACKAGE)), C8)
	MCU_PACKAGE:=1
else ifeq ($(findstring C6, $(TARGET_MCU_PACKAGE)), C6)
	MCU_PACKAGE:=2
endif

GENERATED_LD_FILE:=$(CH32V003FUN)/generated_$(TARGET_MCU_PACKAGE).ld
LINKER_SCRIPT:=$(GENERATED_LD_FILE)
FILES_TO_COMPILE:=$(SYSTEM_C) $(TARGET).$(TARGET_EXT) $(ADDITIONAL_C_FILES)

$(GENERATED_LD_FILE) :
	$(PREFIX)-gcc -E -P -x c -DMCU_PACKAGE=$(MCU_PACKAGE) -DMCU_TYPE=CH32V10x $(CH32V003FUN)/ch32v003fun.ld > $(GENERATED_LD_FILE)

$(TARGET).elf : $(GENERATED_LD_FILE) $(FILES_TO_COMPILE)
	echo $(FILES_TO_COMPILE)
	$(PREFIX)-gcc -o $@ $(FILES_TO_COMPILE) $(CFLAGS) $(LDFLAGS)