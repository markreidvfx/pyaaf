from distutils.core import setup, Extension
import os
import subprocess

#os.environ['CC'] = 'g++'
#os.environ['ARCHFLAGS'] ="-arch x86_64"

AAF_ROOT = os.environ.get("AAF_ROOT", "/Users/mark/Dev/aaf/aaf-git/AAFx86_64DarwinSDK/g++")

AAF_INCLUDE = os.path.join(AAF_ROOT,'include')
AAF_LIB = os.path.join(AAF_ROOT,'lib/debug')

AAF_COM = os.path.join(AAF_ROOT,'bin/debug')

ext_extra = {
    'include_dirs': ['headers',AAF_INCLUDE],
    'library_dirs': [AAF_LIB, AAF_COM],
    'libraries': ['aaflib','aafiid', 'com-api']
}

# Construct the modules that we find in the "build/cython" directory.
ext_modules = []
build_dir = os.path.abspath(os.path.join(__file__, '..', 'build', 'cython'))
for dirname, dirnames, filenames in os.walk(build_dir):
    for filename in filenames:
        if filename.startswith('.') or os.path.splitext(filename)[1] != '.cpp':
            continue

        path = os.path.join(dirname, filename)
        name = os.path.splitext(os.path.relpath(path, build_dir))[0].replace('/', '.')

        ext_modules.append(Extension(
            name,
            sources=[path],
            language="c++",
            **ext_extra
        ))


setup(

    name='aaf',
    version='0.2',
    description='Python Bindings for the Advanced Authoring Format (AAF)',
    
    author="Mark Reid",
    author_email="mindmark@gmail.com",
    
    url="https://github.com/markreidvfx/pyaaf",
    
    ext_modules=ext_modules,

)