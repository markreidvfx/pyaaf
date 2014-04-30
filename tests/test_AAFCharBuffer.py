from __future__ import print_function
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
import sys

def char_num(n):
    if sys.version_info[0] < 3:
        return unichr(n)
    
    return chr(n)

class TestAAFCharBuffer(unittest.TestCase):
    
    def test_basic(self):
        
        buf = aaf.util.AAFCharBuffer()
        buf2 = aaf.util.AAFCharBuffer()
        
        print(buf.aafchar_size)
        print(buf.unicode_size)
        
        buf.write_bytes(b"Hello")
        buf.null_terminate()
        
        buf2.write_unicode(u"Hello")
        buf2.write_unicode(char_num(40960))
        buf2.write_bytes(b"OOOOO")
        buf2.null_terminate()
        
        print([buf.read_unicode(), buf.read_bytes(), buf2.read_unicode(), buf2.read_bytes()])
        print([buf.read_raw(), buf2.read_raw()])
        
       
        print(len(buf.read_raw()), len(buf2.read_raw()))
        
        
        for text in (char_num(40960), b'cow', u'cow', char_num(255), "some text", u"\U0001F600"):
            buf = aaf.util.AAFCharBuffer(text)
            result = buf.read_unicode()[:-1]
            
            if isinstance(text, bytes):
                text = text.decode("UTF-8")
            
            print([result, text])
            print(result, text)
            assert result == text


if __name__ == "__main__":
    unittest.main()
    