import aaf
import os
from optparse import OptionParser

parser = OptionParser()
(options, args) = parser.parse_args()

if not args:
    parser.error("not enough argements")

path = args[0]
name, ext = os.path.splitext(path)

f = aaf.open(path, 'r')
f.save(name + ".xml")
f.close()
