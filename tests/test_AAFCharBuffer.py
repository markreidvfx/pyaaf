import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component
import aaf.util

import traceback

from aaf.util import AUID, MobID

import unittest
import os

class TestAAFCharBuffer(unittest.TestCase):
    
    def test_basic(self):
        
        buf = aaf.util.AAFCharBuffer()
        buf2 = aaf.util.AAFCharBuffer()
        
        buf.write_bytes(b"Hello")
        buf.null_terminate()
        
        buf2.write_unicode(u"Hello")
        buf2.write_unicode(unichr(40960))
        buf2.write_bytes("OOOOO")
        buf2.null_terminate()
        
        print [buf.read_unicode(), buf.read_bytes(), buf2.read_unicode(), buf2.read_bytes()]
        print [buf.read_raw(), buf2.read_raw()]
        
       
        print len(buf.read_raw()), len(buf2.read_raw())
        
        buf.w_dump()
        print "**"
        buf2.w_dump()
        
        #buf2.write_unicode(unichr(0x10000))

if __name__ == "__main__":
    unittest.main()
    