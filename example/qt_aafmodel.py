import sys
from PyQt4 import QtCore

import aaf
import aaf.storage
import aaf.mob
import aaf.define
import aaf.component
import aaf.base
import traceback

class DummyItem(object):
    def __init__(self,item, name):
        self.item = item
        self.name = name

    def GetName(self):
        return self.name
    def GetClassName(self):
        return ""

class TreeItem(object):

    def __init__(self, item, parent=None):
        self.parentItem = parent
        self.item = item
        self.childItems = []
        self.properties = {}
        self.loaded = False
        #self.getData()
    def columnCount(self):
        return 1

    def childCount(self):
        self.setup()
        return len(self.childItems)

    def child(self,row):
        self.setup()
        return self.childItems[row]

    def childNumber(self):
        self.setup()
        if self.parentItem != None:
            return self.parentItem.childItems.index(self)
        return 0

    def parent(self):
        self.setup()
        return self.parentItem

    def extendChildItems(self, items):
        self.childItems.extend([TreeItem(i,self) for i in items])

    def name(self):
        item = self.item
        if hasattr(item, 'name'):
            name = item.name
            if name:
                return name
        return self.className()

    def className(self):
        item = self.item

        if hasattr(item,"class_name"):
            return item.class_name
        else:
            return item.__class__.__name__

    def setup(self):
        if self.loaded:
            return

        item = self.item

        if isinstance(item, list):
            self.extendChildItems(item)

        elif isinstance(item, aaf.storage.File):
            self.extendChildItems([item.header])

        elif isinstance(item, aaf.storage.Header):
            self.extendChildItems([item.storage()])
            self.extendChildItems([item.dictionary()])

        elif isinstance(item, DummyItem):
            self.extendChildItems(item.item)

        elif isinstance(item, aaf.storage.ContentStorage):
            l = []
            l.append(DummyItem(list(item.composition_mobs()),"CompositionMobs"))
            l.append(DummyItem(list(item.master_mobs()),"MasterMobs"))
            #l.append(DummyItem(list(item.GetSourceMobs()),"SourceMobs"))

            self.extendChildItems(l)

        elif isinstance(item, aaf.dictionary.Dictionary):
            l = []
            l.append(DummyItem(list(item.class_defs()), 'ClassDefs'))
            l.append(DummyItem(list(item.codec_defs()), 'CodecDefs'))
            l.append(DummyItem(list(item.container_defs()), 'ContainerDefs'))
            l.append(DummyItem(list(item.data_defs()), 'DataDefs'))
            l.append(DummyItem(list(item.interpolation_defs()), 'InterpolationDefs'))
            l.append(DummyItem(list(item.klvdata_defs()), 'KLVDataDefs'))
            l.append(DummyItem(list(item.operation_defs()), 'OperationDefs'))
            l.append(DummyItem(list(item.parameter_defs()), 'ParameterDefs'))
            l.append(DummyItem(list(item.plugin_defs()), 'PluginDefs'))
            l.append(DummyItem(list(item.taggedvalue_defs()), 'TaggedValueDefs'))
            l.append(DummyItem(list(item.type_defs()), 'TypeDefs'))
            self.extendChildItems(l)

        elif isinstance(item, aaf.mob.Mob):

            self.extendChildItems(list(item.slots()))

        elif isinstance(item, aaf.mob.MobSlot):
             self.extendChildItems([item.segment])
        elif isinstance(item, aaf.component.NestedScope):
            self.extendChildItems(list(item.segments()))
        elif isinstance(item, aaf.component.Sequence):
            self.extendChildItems(list(item.components()))

        elif isinstance(item, aaf.component.SourceClip):
            ref = item.resolve_ref()
            name = ref.name
            if name:
                self.extendChildItems([name])

        elif isinstance(item,aaf.component.OperationGroup):
            self.extendChildItems(list(item.input_segments()))

#         elif isinstance(item, pyaaf.AxSelector):
#             self.extendChildItems(list(item.EnumAlternateSegments()))
#
#         elif isinstance(item, pyaaf.AxScopeReference):
#             #print item, item.GetRelativeScope(),item.GetRelativeSlot()
#             pass
#
#         elif isinstance(item, pyaaf.AxEssenceGroup):
#             segments = []
#
#             for i in xrange(item.CountChoices()):
#                 choice = item.GetChoiceAt(i)
#                 segments.append(choice)
#             self.extendChildItems(segments)
#
#         elif isinstance(item, pyaaf.AxProperty):
#             self.properties['Value'] = str(item.GetValue())
        elif isinstance(item, (aaf.base.AAFObject,aaf.define.MetaDef)):
            pass

        elif isinstance(item, aaf.component.Component):
            pass

        else:
            self.properties['Name'] = str(item)
            self.properties['ClassName'] = str(type(item))
            return

        self.properties['Name'] = self.name()
        self.properties['ClassName'] = self.className()


        if isinstance(item, aaf.component.Component):
            self.properties['Length'] = item.length


        self.loaded = True

class AAFModel(QtCore.QAbstractItemModel):

    def __init__(self, moblist,parent=None):
        super(AAFModel,self).__init__(parent)

        self.rootItem = TreeItem(moblist)

        self.headers = ['Name','Length', 'ClassName']

    def headerData(self, column, orientation,role):
        if orientation == QtCore.Qt.Horizontal and role == QtCore.Qt.DisplayRole:
            return QtCore.QVariant(self.headers[column])
        return QtCore.QVariant()

    def columnCount(self,index):
        #item = self.getItem(index)

        return len(self.headers)

    def rowCount(self,parent=QtCore.QModelIndex()):
        parentItem = self.getItem(parent)
        return parentItem.childCount()

    def data(self, index, role):

        if not index.isValid():
            return 0

        if role != QtCore.Qt.DisplayRole:
            return None

        item = self.getItem(index)

        header_key = self.headers[index.column()]

        return str(item.properties.get(header_key,''))

    def parent(self, index):

        if not index.isValid():
            return QtCore.QModelIndex()

        childItem = self.getItem(index)
        parentItem = childItem.parent()

        if parentItem == self.rootItem:
            return QtCore.QModelIndex()

        return self.createIndex(parentItem.childNumber(), 0, parentItem)

    def index(self, row, column, parent = QtCore.QModelIndex()):
        if parent.isValid() and parent.column() != 0:
            return QtCore.QModelIndex()

        item = self.getItem(parent)
        childItem = item.child(row)

        if childItem:
            return self.createIndex(row, column, childItem)
        else:
            return QtCore.QModelIndex()


    def getItem(self,index):

        if index.isValid():
            item = index.internalPointer()
            if item:
                return item
        return self.rootItem


if __name__ == "__main__":

    from PyQt4 import QtGui

    from optparse import OptionParser

    parser = OptionParser()
    parser.add_option('-c','--compmobs',action="store_true", default=False)
    parser.add_option('-m','--mastermobs',action="store_true", default=False)
    parser.add_option('-s','--sourcemobs',action="store_true", default=False)
    parser.add_option('-d','--dictionary',action="store_true", default=False)
    parser.add_option('-a','--all',action="store_true", default=False)



    (options, args) = parser.parse_args()

    if not args:
        parser.error("not enough arguments")

    file_path = args[0]

    f = aaf.open(file_path)

        #root = axfile
    header = f.header
    storage = f.storage
    root = storage
    if options.compmobs:
        root = list(storage.composition_mobs())

    if options.mastermobs:
        root = list(storage.master_mobs())

    #if options.sourcemobs:
       # root = list(storage.GetSourceMobs())

    if options.dictionary:
        root = f.dictionary

    if options.all:
        root = f
    #print mobs

    app = QtGui.QApplication(sys.argv)

    model = AAFModel(root)

    tree = QtGui.QTreeView()

    tree.setModel(model)

    tree.resize(700,600)
    tree.expandToDepth(5)
    tree.resizeColumnToContents(0)
    tree.show()

    sys.exit(app.exec_())
