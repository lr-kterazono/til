ELM_MAKE=elm-make
ELM_PACKAGE=elm-package

OUT_DIR=dist
TARGET=main.js


all: $(OUT_DIR)/$(TARGET)
	cp index.html $(OUT_DIR)/index.html
	cp softwarekeyboard.css $(OUT_DIR)/softwarekeyboard.css

env:
	$(ELM_PACKAGE) install
	mkdir -p $(OUT_DIR)


$(OUT_DIR)/$(TARGET): Main.elm
	$(ELM_MAKE) Main.elm --output $(OUT_DIR)/$(TARGET)

clean:
	rm -rf $(OUT_DIR)



