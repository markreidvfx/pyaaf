from __future__ import print_function
import aaf
import traceback
from optparse import OptionParser

parser = OptionParser()
parser.add_option('--show_dictionary', action='store_true', default = False, dest='show_dict',
                  help = "show dictionary properties")
parser.add_option('--show_stream', action='store_true', default = False, dest='show_stream',
                  help = "show binary stream data")
(options, args) = parser.parse_args()

if not args:
    parser.error("not enough args")



def walk_properties(space, iter_item):
    for item in iter_item:
        value = item
        if isinstance(item, aaf.property.PropertyItem):
            value = item.value
        name = ""

        if hasattr(item, 'name'):
            name = item.name or ""

        print(space,name, value)

        if isinstance(value, aaf.dictionary.Dictionary) and not options.show_dict:
            continue
        # don't dump out stream data, its ugly
        if isinstance(value, aaf.iterator.TypeDefStreamDataIter) and not options.show_stream:
            continue

        s = space + '   '
        if isinstance(value, aaf.base.AAFObject):
            walk_properties(s, value.properties())
        if isinstance(value, aaf.iterator.BaseIterator):
            walk_properties(s, value)



f = aaf.open(args[0])

walk_properties("", f.header.properties())
