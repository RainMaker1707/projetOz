OZC = ozc
OZENGINE = ozengine

OZCX = /Applications/Mozart2.app/Contents/Resources/bin/ozc
OZENGINEX = /Applications/Mozart2.app/Contents/Resources/bin/ozengine

DBPATH= database.txt
NOGUI= "" # set this variable to --nogui if you don't want the GUI

SRC=$(wildcard *.oz)
OBJ=$(SRC:.oz=.ozf)

OZFLAGS = --nowarnunused

all: $(OBJ)

run: all
	@echo RUN Example.ozf
	@$(OZENGINEX) Example.ozf --db $(DBPATH) $(NOGUI)

%.ozf: %.oz
	@echo OZC $@
	@$(OZCX) $(OZFLAGS) -c $< -o $@

.PHONY: clean

clean:
	@echo rm $(OBJ)
	@rm -rf $(OBJ)
