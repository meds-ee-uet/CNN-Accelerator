# Directories
RTL_DIR       := rtl
TB_DIR        := test
BUILD_DIR     := build

# Files
DESIGN_FILES  := $(wildcard $(RTL_DIR)/*.sv)
# TB_FILES      := $(wildcard $(TB_DIR)/*.sv)
VCD_FILE      := wave.vcd
IMG 		  := test/imgs/Madara.png
# IMG := ofmap.png
SIZE := 256x256

# Tools
VLOG          := vlog
VSIM          := vsim
GTKWAVE       := gtkwave

# Top module
TOP_MODULE    := conv_tb

# Simulation flags (ENABLE VCD DUMPING)
VSIM_FLAGS    := -c -do "run -all; quit -f" -voptargs="+acc" +vcdfile=$(VCD_FILE)

# Default target
all: run

# Compile RTL & Testbench (with SystemVerilog support)
compile: imgToTxt
	@if [ ! -d $(BUILD_DIR) ]; then mkdir -p $(BUILD_DIR); fi
	$(VLOG) -work $(BUILD_DIR) -sv +acc -svinputport=relaxed $(DESIGN_FILES) $(TB_DIR)/$(TOP_MODULE).sv

# Run simulation (force VCD dump)
sim: compile
	$(VSIM) -work $(BUILD_DIR) $(VSIM_FLAGS) $(TOP_MODULE)

# Open waveform in GTKWave
wave:
	$(GTKWAVE) $(VCD_FILE) myview.sav 2>/dev/null &

# Full flow: compile → simulate → view waveforms
# run: clean sim
run: clean sim png

# Clean build artifacts
clean:
	rm -rf $(BUILD_DIR) transcript *.vcd *.wlf *.png *.pgm *.txt
	clear

img:
	convert $(IMG) -resize $(SIZE)! -compress none -depth 8 img.pgm

imgToTxt: img
	python3 scripts/pgmToTxt.py

png:
	python3 scripts/txtToPng.py
	open ofmap.png