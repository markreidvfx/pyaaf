CYTHON_SRC = $(shell find aaf -maxdepth 1 -name "*.pyx")
C_SRC = $(CYTHON_SRC:%.pyx=build/cython/%.cpp)
MOD_SOS = $(CYTHON_SRC:%.pyx=%.so)

.PHONY: default build_ext build cythonize clean clean-all info test docs

default: build

info:
	@ echo Cython sources: $(CYTHON_SRC)

cythonize: $(C_SRC)

build/cython/aaf/%.cpp: aaf/%.pyx aaf/%.pxd aaf/%/*.pyx aaf/%/*.cpp
	@ mkdir -p $(shell dirname $@)
	cython --cplus -I. -Iheaders -o $@ $<

build/cython/aaf/%.cpp: aaf/%.pyx aaf/%.pxd aaf/%/*.pyx
	@ mkdir -p $(shell dirname $@)
	cython --cplus -I. -Iheaders -o $@ $<
	
build/cython/aaf/%.cpp: aaf/%.pyx aaf/%.pxd
	@ mkdir -p $(shell dirname $@)
	cython --cplus -I. -Iheaders -o $@ $<

build/cython/aaf/%.cpp: aaf/%.pyx
	@ mkdir -p $(shell dirname $@)
	cython --cplus -I. -Iheaders -o $@ $<

dev: cythonize
	python setup.py build_ext --inplace --debug

build_ext: cythonize
	python setup.py build_ext --debug

build: build_ext
	python setup.py build

install: build
	python setup.py install
	
test:
	cd tests;nosetests -v

docs: build_ext
	make -C docs html

clean:
	- rm -rf build
	- find aaf -name '*.so' -delete
	- find aaf -name '*.dylib' -delete
	- find aaf -name '*.pyd' -delete
	- find aaf -name '*.dll' -delete

clean-all: clean
	- rm configure config.py
	- make -C docs clean
