from . import core
import sys
import os

path = None
if sys.platform.startswith("win"):
    path = os.path.join(os.path.dirname(__file__),"AAFCOAPI.dll")
core.register_all(path)
del core
del os
del sys

from .storage import open
