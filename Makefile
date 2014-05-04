CYTHON_SRC = $(shell find aaf -maxdepth 1 -name "*.pyx")
C_SRC = $(CYTHON_SRC:%.pyx=build/cython/%.cpp)
MOD_SOS = $(CYTHON_SRC:%.pyx=%.so)

.PHONY: default build cythonize clean clean-all info test docs

default: build_dev

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

build_dev: cythonize
	python setup.py build_ext --inplace --debug

build: cythonize
	python setup.py build_ext --debug

install: build
	python setup.py install
	
test:
	cd tests;nosetests -v

docs: build
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
