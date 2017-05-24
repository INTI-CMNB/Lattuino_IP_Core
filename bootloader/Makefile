OBJDIR=../Work
LIB=lattuino
GHDLFLAGS=--work=$(LIB) --workdir=$(OBJDIR)

.PHONY: lattuino_1_bl

# Library Modules
LIB_MODS_1=lattuino_1_bl_2 lattuino_1_bl_4 lattuino_1_bl_8 lattuino_1_bl_2s
LIB_MODS_2=ad_conv tm16b tmcounter
LIB_MODS=$(addsuffix .o,$(addprefix $(OBJDIR)/,$(LIB_MODS_1)))
LIB_SRCS=$(addsuffix .vhdl,$(addprefix $(OBJDIR)/,$(LIB_MODS_1)))
LIB_DEVS=$(addsuffix .vhdl,$(addprefix ../devices/,$(LIB_MODS_2)))

$(OBJDIR)/%.o : $(OBJDIR)/%.vhdl
	ghdl -a $(GHDLFLAGS) -o $@ $<

all: lib

$(OBJDIR):
	mkdir $(OBJDIR)

$(OBJDIR)/pm_pkg.vhdl: pm_pkg.in.vhdl $(LIB_SRCS) $(LIB_DEVS)
	vhdlspp.pl $< $@

$(OBJDIR)/lattuino_1_bl_8.vhdl: lattuino_1_bl
$(OBJDIR)/lattuino_1_bl_4.vhdl: lattuino_1_bl
$(OBJDIR)/lattuino_1_bl_2.vhdl: lattuino_1_bl

lattuino_1_bl:
	$(MAKE) -C $@

needed: $(OBJDIR) lattuino_1_bl $(OBJDIR)/pm_pkg.vhdl

lib: needed $(LIB_MODS) $(OBJDIR)/pm_pkg.o

