# Key variables to define
RDIR = .

# Create list of R source files
RSOURCE = $(wildcard $(RDIR)/*.R)

# Files to indicate when the RSOURCE file was run
OUT_FILES = $(RSOURCE:.R=.Rout)

# Default target
all: $(OUT_FILES) 

# Run the RSOURCE files
$(RDIR)/%.Rout: $(RDIR)/%.R
	R CMD BATCH $<

# Remove R Out Files
clean:
	rm -fv $(OUT_FILES)

