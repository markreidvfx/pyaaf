import sys
import traceback

from PyQt4 import QtGui
from PyQt4 import QtCore
from PyQt4.QtCore import Qt

import aaf
import aaf.component

import StringIO

def clip_menu(event, item):
    print event

    menu = QtGui.QMenu()
    menu.addAction("Dump Clip", lambda x=item.getReference():dump_source(x))
    menu.addAction("Dump Positions", lambda x=item:dump_positions(x))
    menu.addAction("Walk Source", lambda x=item.getReference():walk_component(x))
    menu.exec_(event.screenPos())


def dump_source(item):

    data = dump_item(item)

    if isinstance(item, aaf.component.SourceClip):
        source = item.resolve_ref()

        data += dump_item(source)


    box_message(data)

def dump_positions(clip):

    for item in clip.track._reference.positions():
        print item

def box_message(text):
    dialog = QtGui.QDialog()


    box = QtGui.QTextEdit()

    box.setText(text)
    layout = QtGui.QVBoxLayout()
    layout.addWidget(box)

    dialog.setLayout(layout)

    dialog.resize(1200, 600)

    dialog.exec_()


def walk_component(item):

    if isinstance(item, aaf.component.SourceClip):
        walk_sourceclip(item)


    elif isinstance(item, aaf.component.OperationGroup):

        print item.operationdef().name, item

        for clip in item.input_segments():
            walk_component(clip)
            #walk_sourceclip(clip)


    elif isinstance(item, aaf.component.Selector):
        print item
        walk_sourceclip( item.selected)

    elif isinstance(item, aaf.component.Sequence):
        for clip in item.components():
            walk_component(clip)

    elif isinstance(item, aaf.component.ScopeReference):
        print item

    elif isinstance(item, aaf.component.Filler):
        print item

    elif isinstance(item, aaf.component.Transition):
        print item

    else:
        print item
        raise Exception()

def walk_sourceclip(item,space = ""):

    mob = item.resolve_ref()
    print space, item, item.start_time,item.length, mob['UsageCode'].value, mob
    cut_in = item.start_time

    space += "|"
    for sourceclip in item.walk():
        space += "--"

        mob = None
        if isinstance(sourceclip, aaf.component.EssenceGroup):
             print space, sourceclip,sourceclip.still_frame, sourceclip.all_keys()


             for item in sourceclip.choices():
                walk_sourceclip(item, space + "--")

             continue

        mob = sourceclip.resolve_ref()
        usage = None
        if mob:
            usage = mob['UsageCode'].value


        print space, sourceclip, sourceclip.start_time, sourceclip.length, usage, mob
        cut_in += sourceclip.start_time

    print space, "IN=%i OUT=%i" % (cut_in, cut_in + item.length)


def dump_item(item):
    text = StringIO.StringIO()
    text.write("%s\n" % str(item))
    walk_properties("", item.properties(), text)
    return text.getvalue()

def walk_properties(space, iter_item, text):
    for item in iter_item:
        value = item
        if isinstance(item, aaf.property.PropertyItem):
            value = item.value
        name = ""

        if hasattr(item, 'name'):
            name = item.name or ""

        if isinstance(value, unicode):
            output_value = value
        else:
            output_value = str(value)

        output = u"%s %s %s\n" % ( space,name, output_value)
        text.write(output)
        #print output.encode("ascii", errors='ignore')

        if isinstance(value, aaf.dictionary.Dictionary) and not options.show_dict:
            continue
        # don't dump out stream data, its ugly
        if isinstance(value, aaf.iterator.TypeDefStreamDataIter):
            text.write("%s    TypeDefStreamDataIter ...\n" % space)
            continue
       # elif isinstance(value, aaf.iterator.PropValueResolveIter):
            #text.write("%s    PropValueResolveIter ...\n" % space)

        if isinstance(value, aaf.component.SourceClip):

            ref = value.resolve_ref()
            if ref:
                text.write(u"%s %s\n" % ( space, str(ref)))

                walk_properties(space + '   ', ref.properties(), text )


        s = space + '   '
        if isinstance(value, aaf.base.AAFObject):
            walk_properties(s, value.properties(), text)
        if isinstance(value, aaf.iterator.BaseIterator):
            walk_properties(s, value, text)
