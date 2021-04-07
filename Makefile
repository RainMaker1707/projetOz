OZC = ozc
OZENGINE = ozengine

OZCX = /Applications/Mozart2.app/Contents/Resources/bin/ozc
OZENGINEX = /Applications/Mozart2.app/Contents/Resources/bin/ozengine

DBPATH = database/database.txt
NOGUI = "" # setup if wanted to --nogui

SRC=$(wildcard *.oz)
OBJ=$(SRC:.oz=.ozf)

OZFLAGS = --nowarnunused

all: $(OBJ)

run: all build
	@echo "RUN main.ozf"
	@$(OZENGINEX) main.ozf --db $(DBPATH) $(NOGUI)

build:
	@echo "build main.oz to main.ozf"
	@$(OZCX) -c main.oz

clean:
	@echo rm $(OBJ)
	@rm -rf $(OBJ)

.PHONY: clean