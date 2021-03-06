#             __________               __   ___.
#   Open      \______   \ ____   ____ |  | _\_ |__   _______  ___
#   Source     |       _//  _ \_/ ___\|  |/ /| __ \ /  _ \  \/  /
#   Jukebox    |    |   (  <_> )  \___|    < | \_\ (  <_> > <  <
#   Firmware   |____|_  /\____/ \___  >__|_ \|___  /\____/__/\_ \
#                     \/            \/     \/    \/            \/
# $Id: firmware.make 27372 2010-07-10 13:49:49Z kugel $
#

INCLUDES += -I$(FIRMDIR) -I$(FIRMDIR)/export -I$(FIRMDIR)/drivers -I$(FIRMDIR)/include
ifndef APP_TYPE
INCLUDES += -I$(FIRMDIR)/libc/include
endif

FIRMLIB_SRC += $(call preprocess, $(FIRMDIR)/SOURCES)
FIRMLIB_OBJ := $(call c2obj, $(FIRMLIB_SRC))
ifeq (,$(findstring -DARCHOS_PLAYER,$(TARGET)))
    FIRMLIB_OBJ += $(BUILDDIR)/sysfont.o
endif
OTHER_SRC += $(FIRMLIB_SRC)

FIRMLIB = $(BUILDDIR)/firmware/libfirmware.a

SYSFONT = $(ROOTDIR)/fonts/08-Schumacher-Clean.bdf

CLEANOBJS += $(BUILDDIR)/sysfont.* $(BUILDDIR)/version.*

# Limits for the built-in sysfont: ASCII for bootloaders, ISO8859-1 for normal builds
ifneq (,$(findstring -DBOOTLOADER,$(EXTRA_DEFINES)))
	MAXCHAR = 127
else
	MAXCHAR = 255
endif

$(FIRMLIB): $(FIRMLIB_OBJ)
	$(SILENT)$(shell rm -f $@)
	$(call PRINTS,AR $(@F))$(AR) rcs $@ $^ >/dev/null

$(BUILDDIR)/sysfont.h: $(SYSFONT) $(TOOLS)
	$(call PRINTS,CONVBDF $(subst $(ROOTDIR)/,,$<))$(TOOLSDIR)/convbdf -l $(MAXCHAR) -h -o $@ $<

$(BUILDDIR)/sysfont.o: $(SYSFONT) $(BUILDDIR)/sysfont.h
	$(call PRINTS,CONVBDF $(subst $(ROOTDIR)/,,$<))$(TOOLSDIR)/convbdf -l $(MAXCHAR) -c -o $(BUILDDIR)/sysfont.c $<
	$(call PRINTS,CC $(subst $(ROOTDIR)/,,$(BUILDDIR)/sysfont.c))$(CC) $(CFLAGS) -c $(BUILDDIR)/sysfont.c -o $@

SVNVERSION:=$(shell $(TOOLSDIR)/version.sh $(ROOTDIR))
OLDSVNVERSION:=$(shell grep 'RBVERSION' $(BUILDDIR)/version.h 2>/dev/null|cut -d '"' -f 2 || echo "NOREVISION")

ifneq ($(SVNVERSION),$(OLDSVNVERSION))
.PHONY: $(BUILDDIR)/version.h
endif

$(BUILDDIR)/version.h:
	$(call PRINTS,GEN $(@F))$(TOOLSDIR)/genversion.sh $(BUILDDIR) $(TOOLSDIR)/version.sh $(ROOTDIR)
