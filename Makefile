ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
endif

TARGET ?= main

TOP_MODULE ?= fft32/2dfft

INCC_DIR   = csrc/sfp44/lib
INCL_DIR   = include
SRC_DIR   = csrc/sfp44 csrc/sfp44/lib
RTL_DIR   = rtl
BUILD_DIR = build

VCD = $(BUILD_DIR)/$(TARGET).vcd
EXE = $(BUILD_DIR)/$(TARGET)

# 获取当前目录下所有子文件夹
SUBDIRS := $(wildcard */)
SUBDIRS := $(filter-out testbench/,$(SUBDIRS))
SUBDIRS := $(filter-out maxexp/,$(SUBDIRS))
SUBDIRS := $(filter-out TOP/,$(SUBDIRS))
SUBDIRS := $(filter-out test/,$(SUBDIRS))

RTL += $(foreach dir,$(SUBDIRS),$(wildcard $(dir)*.v))
RTL += $(foreach dir,$(SUBDIRS),$(wildcard $(dir)*.sv))
RTL := $(filter-out $(TOP_MODULE).sv,$(RTL))

# 打印目标文件列表
print_targets:
	@echo $(RTL)


EXCLUDED_C_FILES := csrc/sfp44/main.cpp
CSRC := $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.c))
CSRC += $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.cpp))
CSRC += $(foreach dir,$(SRC_DIR),$(wildcard $(dir)/*.cc))
CSRC := $(filter-out $(EXCLUDED_C_FILES),$(CSRC))

print_ctargets:
	@echo $(CSRC)

print_include:
	@echo $(CFLAGS)

sim: clean $(VCD) $(EXE)

VERILATOR_FLAGS += -cc --exe -sv --build
VERILATOR_FLAGS += -Wall -Wno-lint
VERILATOR_FLAGS += --Mdir $(BUILD_DIR)
VERILATOR_FLAGS += --report-unoptflat

INCCFLAGS = $(addprefix -I, $(abspath $(INCC_DIR)))
INCLFLAGS = $(addprefix -I, $(abspath $(INCL_DIR)))
CFLAGS  += $(INCCFLAGS)
LDFLAGS ?=

$(VCD): $(EXE)
	@$^

$(EXE): $(TOP_MODULE).sv $(RTL) $(CSRC)
	$(VERILATOR) $(VERILATOR_FLAGS) --trace \
		$(addprefix -CFLAGS , $(CFLAGS)) $(addprefix , $(INCLFLAGS))  $(addprefix -LDFLAGS , $(LDFLAGS)) \
		-o $(abspath $@) --top fft_2d $^ > work.txt

clean:
	-rm -rf $(BUILD_DIR) *.txt

cproj:
	$(MAKE) -C $(BUILD_DIR) -f ../work/Makefile

run:
	# $(MAKE) clean
	$(MAKE) cproj
	./build/main > result.txt

wave:
	gtkwave ./build/main.vcd &

.PHONY: sim clean
