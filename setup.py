from __future__ import print_function
from setuptools import setup, Extension, Command
from setuptools.command.build_ext import build_ext
import os
import subprocess
import sys
import shutil
import glob
from Cython.Build import cythonize

#os.environ['CXX'] = 'g++'
#os.environ['ARCHFLAGS'] ="-arch x86_64"

# add this to fix build on mac osx mavericks
#os.environ['ARCHFLAGS'] ="-Wno-error=unused-command-line-argument-hard-error-in-future"

copy_args = sys.argv[1:]
AAF_ROOT = None
if '--aaf-root' in copy_args:
    index = copy_args.index('--aaf-root')
    AAF_ROOT = copy_args[index+1]
    del copy_args[index]
    del copy_args[index]
else:
    AAF_ROOT = os.environ.get("AAF_ROOT")

debug_default = "1"
if sys.platform.startswith('win'):
    debug_default = "0"

USE_AAF_SDK_DEBUG = bool(int(os.environ.get("USE_AAF_SDK_DEBUG", debug_default)))
NTHREADS= int(os.environ.get("NTHREADS",0))

if '--debug' in copy_args:
    USE_AAF_SDK_DEBUG=True

space = '   '
if AAF_ROOT is None:

    print( space, "Unable to locate AAF Development libraries.")
    print( space, "Please specify with --aaf-root or AAF_ROOT env variable")
    print( space, "AAF SDK can be found from http://aaf.sourceforge.net")
    print( space, "Pre-built devel libraries can be found here")
    print( space, "http://sourceforge.net/projects/aaf/files/AAF-devel-libs/1.1.6")
    print( space, "If you compiled the full SDK yourself, set AAF_ROOT")
    print( space, "to the build directory in the SDK for your platform.")
    print( space, "For example AAFx86_64LinuxSDK/g++ or AAFWinSDK/vs9")
    sys.exit(-1)

if not os.path.exists(AAF_ROOT):
    print(space, "AAF_ROOT direcotry does not exist: %s" % AAF_ROOT)
    sys.exit(-1)

AAF_INCLUDE = os.path.join(AAF_ROOT,'include')

AAF_LIB = os.path.join(AAF_ROOT,'lib', 'debug')

AAF_COM = os.path.join(AAF_ROOT,'bin', 'debug')

ext_extra = {
    'include_dirs': ['headers',AAF_INCLUDE],
    'library_dirs': [AAF_LIB, AAF_COM],
    'libraries': ['aaflib','aafiid', 'com-api'],
}

if sys.platform.startswith('linux'):
    ext_extra['extra_link_args'] = ['-Wl,-R$ORIGIN']

WIN_ARCH = 'Win32'

if sys.platform.startswith('win'):
    import platform
    if platform.architecture()[0] == '64bit':
        WIN_ARCH = 'x64'
    if USE_AAF_SDK_DEBUG:
        ext_extra['library_dirs'] = [os.path.join(AAF_ROOT,WIN_ARCH ,'Debug','Refimpl')]
        ext_extra['libraries'] = ['AAFD', 'AAFIIDD']
    else:
        ext_extra['library_dirs'] = [os.path.join(AAF_ROOT,WIN_ARCH ,'Release','Refimpl')]
        ext_extra['libraries'] = ['AAF', 'AAFIID']

    ext_extra['library_dirs'].extend([os.path.join(AAF_ROOT, 'lib'),
                                        os.path.join(AAF_ROOT, 'bin')])
print("AAF_ROOT =",AAF_ROOT)

ext_modules = []
for dirname, dirnames, filenames in os.walk("aaf", topdown=True):
    for filename in filenames:
        if filename.startswith('.') or os.path.splitext(filename)[1] != '.pyx':
            continue

        path = os.path.join(dirname, filename)
        name = "aaf." + os.path.splitext(os.path.basename(path))[0]

        sources = [path]

        extra_src_dir = os.path.join(os.path.dirname(__file__), 'aaf', os.path.splitext(filename)[0])
        extra_src = glob.glob(os.path.join(extra_src_dir, '*.cpp'))

        sources.extend(extra_src)
        extension = Extension(name,
                              sources=sources,
                              language="c++",
                              **ext_extra)

        ext_modules.append(extension)
    break

def get_com_api(debug=True):
    if sys.platform.startswith("win"):
        dirpath = os.path.join(AAF_ROOT, '%s' % str(WIN_ARCH))
        if debug or USE_AAF_SDK_DEBUG:
            dirpath = os.path.join(dirpath, "Debug")
        else:
            dirpath = os.path.join(dirpath, "Release")

        for dirname in ext_extra['library_dirs']:
            com_api = os.path.join(dirname, 'AAFCOAPI.dll')
            libaafintp =  os.path.join(dirname, 'aafext', 'AAFINTP.dll')
            libaafpgapi =  os.path.join(dirname, 'aafext', 'AAFPGAPI.dll')
            #print(os.path.basename(com_api), '=', com_api)
            if all([os.path.exists(item) for item in (com_api,libaafintp,libaafpgapi)]):
                return com_api, libaafintp, libaafpgapi
        raise Exception("Unable to find AAFCOAPI.dll, AAFINTP.dll, AAFPGAPI.dll")
    ext = '.so'
    if sys.platform == 'darwin':
        ext = '.dylib'
    dirpath = os.path.join(AAF_ROOT, 'bin')
    if debug or USE_AAF_SDK_DEBUG:
        dirpath = os.path.join(dirpath, 'debug')

    com_api = os.path.join(dirpath, 'libcom-api' + ext)
    libaafintp = os.path.join(dirpath, 'aafext', 'libaafintp' + ext)
    libaafpgapi = os.path.join(dirpath, 'aafext', 'libaafpgapi' + ext)

    return com_api, libaafintp, libaafpgapi

def copy_com_api(debug=True):
    com_api, libaafintp, libaafpgapi = get_com_api(debug)

    for item in [com_api, libaafintp, libaafpgapi]:
        print(os.path.basename(item), '=', item)

    dirpath = os.path.dirname(__file__)

    # copy libcom-api
    basename = os.path.basename(com_api)
    dest = os.path.join(dirpath, 'aaf', basename)
    print("copying", os.path.basename(com_api), '->', dest)
    shutil.copy(com_api, dest)

    # create ext dir
    aafext_dir = os.path.join(dirpath, 'aaf', 'aafext')
    if not os.path.exists(aafext_dir):
        print('creating', aafext_dir)
        os.makedirs(aafext_dir)

    # copy libaafintp
    basename = os.path.basename(libaafintp)
    intp_dest = os.path.join(aafext_dir,basename)
    print("copying", os.path.basename(libaafintp), '->', intp_dest)
    shutil.copy(libaafintp, intp_dest)
    # copy libaafpgapi
    basename = os.path.basename(libaafpgapi)
    pgapi_dest = os.path.join(aafext_dir,basename)
    print("copying", os.path.basename(libaafpgapi), '->', pgapi_dest)
    shutil.copy(libaafpgapi, pgapi_dest)

    return dest,intp_dest, pgapi_dest

def name_tool_fix_com_api(path):

    cmd = ['install_name_tool', '-id', 'libcom-api.dylib', path]
    #print(subprocess.list2cmdline(cmd))
    subprocess.check_call(cmd)

    #'install_name_tool -id libcom-api.dylib aaf/libcom-api.dylib'

def install_name_tool(path):
    cmd = ['sh','fixup_bundle.sh', path]
    subprocess.check_call(cmd)

class clean(Command):
    description = "custom clean command"
    user_options = []

    def initialize_options(self):
        self.cwd = None
    def finalize_options(self):
        self.cwd = os.getcwd()
    def run(self):
        assert os.getcwd() == self.cwd, 'Must be in package root: %s' % self.cwd

        for pattern in ('*.cpp', '*.so', '*.dylib', '*.dll', '*.pyd'):
            for item in(glob.glob(os.path.join('aaf', pattern))):
                print("rm %s" % item)
                os.remove(item)
        if os.path.exists("build"):
            print("rm build")
            shutil.rmtree("build")

class build_pyaaf_ext(build_ext):

    def build_extensions(self):

        result = build_ext.build_extensions(self)
        if sys.platform == 'darwin':
            for item in self.get_outputs():
                install_name_tool(item)
        return result


com_api, libaafintp, libaafpgapi = get_com_api()
package_data = [os.path.basename(com_api)]
for item in (libaafintp, libaafpgapi):
    package_data.append(os.path.join('aafext', os.path.basename(item)))

package_data = {'aaf':package_data}

include_path = ext_extra['include_dirs']

if not 'clean' in copy_args:
    copy_com_api(USE_AAF_SDK_DEBUG)
    if sys.platform == 'darwin':
        name_tool_fix_com_api(com_api)
    ext_modules = cythonize(ext_modules, include_path=include_path, nthreads=NTHREADS)

setup(
    script_args=copy_args,
    name='PyAAF',
    version='0.9.0',
    description='Python Bindings for the Advanced Authoring Format (AAF)',

    author="Mark Reid",
    author_email="mindmark@gmail.com",

    url="https://github.com/markreidvfx/pyaaf",
    license='MIT',
    packages=['aaf'],
    ext_modules=ext_modules,
    cmdclass = {'build_ext':build_pyaaf_ext,
                'clean':clean},
    package_data=package_data

)
