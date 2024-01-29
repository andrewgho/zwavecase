# Makefile - create STL files from OpenSCAD source
# Andrew Ho (andrew@zeuscat.com)

ifeq ($(shell uname), Darwin)
  OPENSCAD = /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD
else
  OPENSCAD = openscad
endif

TARGETS = case.stl

all: $(TARGETS)

case.stl: case.scad
	$(OPENSCAD) -o case.stl case.scad

clean:
	@rm -f $(TARGETS)
