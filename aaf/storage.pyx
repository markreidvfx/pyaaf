
cimport lib

from base cimport AAFBase, AAFObject
from dictionary cimport Dictionary

from .util cimport error_check, query_interface, register_object, lookup_object, AUID, MobID, AAFCharBuffer
from .iterator cimport EssenceDataIter, MobIter
from .mob cimport Mob
from .essence cimport EssenceData
from wstring cimport wstring,toWideString
import os
import weakref

include "storage/File.pyx"
include "storage/Header.pyx"
include "storage/ContentStorage.pyx"
include "storage/Identification.pyx"

register_object(Header)
register_object(ContentStorage)
register_object(Identification)

# Handy alias.
open = File
