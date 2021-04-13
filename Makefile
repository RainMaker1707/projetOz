OZC = ozc
OZENGINE = ozengine

OZCX = /Applications/Mozart2.app/Contents/Resources/bin/ozc
OZENGINEX = /Applications/Mozart2.app/Contents/Resources/bin/ozengine

DBPATH = database/database.txt
NOGUI = "" # setup if wanted to --nogui
ANS = "database/test_answers.txt"

SRC=$(wildcard *.oz)
OBJ=$(SRC:.oz=.ozf)

OZFLAGS = --nowarnunused

all: $(OBJ)

run: all
	@echo "RUN main.ozf"
	@$(OZENGINEX) main.ozf --db $(DBPATH) $(NOGUI) --ans $(ANS)

%.ozf: %.oz
	@echo OZC $@
	@$(OZCX) $(OZFLAGS) -c $< -o $@

clean:
	@echo rm $(OBJ)
	@rm -rf $(OBJ)

.PHONY: clean