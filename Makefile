CYTHON_SRC = $(shell find aaf -maxdepth 1 -name "*.pyx")
C_SRC = $(CYTHON_SRC:%.pyx=build/cython/%.cpp)
MOD_SOS = $(CYTHON_SRC:%.pyx=%.so)

.PHONY: default build_ext build clean clean-all info test docs

default: build

dev:
	python setup.py build_ext --inplace --debug

build_ext:
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
	- find aaf -maxdepth 1 -name '*.cpp' -delete

clean-all: clean
	- rm configure config.py
	- make -C docs clean
