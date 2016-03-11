from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage

import unittest
import traceback

import os


cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(cur_dir,"files/test_file_01.aaf")
print(main_test_file)
assert os.path.exists(main_test_file)

class TestFile(unittest.TestCase):

    def setUp(self):
        pass

    def test_new_file_aaf(self):
        test_file = os.path.join(sandbox,"new_file.aaf")
        f = aaf.open(test_file, 'w')
        f.save()

    def test_save_as_aaf(self):
        test_file = main_test_file
        copy_file = os.path.join(sandbox,"copy_file.aaf")
        f = aaf.open(test_file)

        new = f.save(copy_file)

    def test_new_file_xml(self):
        test_file = os.path.join(sandbox,"new_file.xml")
        f = aaf.open(test_file, 'w')

        f.save()

    def test_save_as_xml(self):
        test_file = main_test_file
        copy_file = os.path.join(sandbox,"copy_file.xml")
        f = aaf.open(test_file)

        new = f.save(copy_file)


    def test_file_modify(self):
        test_file = os.path.join(sandbox,"modify_file.aaf")
        f = aaf.open(test_file, 'w')
        f.save()
        f.close()

        f = aaf.open(test_file, 'rw')

        f.save()

    def test_file_readonly(self):
        test_file = os.path.join(sandbox,"readonly_file.aaf")
        f = aaf.open(test_file, 'w')
        f.save()
        f.close()

        f = aaf.open(test_file, 'r')
        f.save()

    def test_file_transient(self):

        output_file =  os.path.join(sandbox,"transient_output.aaf")
        f = aaf.open(None, 't')
        f.save() # Doesn't do anything but should crash
        f.save(output_file)
        f.close()

    def test_master_mobs(self):

        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        dictionary = f.dictionary
        storage = f.storage

        print(storage.count_mobs())

        for mob in storage.master_mobs():
            #mob.count_properties()
            print(mob)

    def test_comp_mobs(self):

        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        dictionary = f.dictionary
        storage = f.storage

        #print storage.count_mobs()

        for mob in storage.composition_mobs():
            print(mob)

    def test_toplevel_mobs(self):

        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        dictionary = f.dictionary
        storage = f.storage

        print(storage.count_mobs())

        for mob in storage.toplevel_mobs():
            compMob = mob
            definition = compMob.classdef()


    def test_file_properties(self):
        test_file = main_test_file

        f = aaf.open(test_file)

        #for p in f.properties():
            #print p.name, p.value_typedef(),p.property_def(), p.value

    def test_header(self):
        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        for p in header.properties():
            pass
            #print p.name, p.value_typedef(),p.property_def(), p.value


    def test_storage(self):
        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        dictionary = f.dictionary
        storage = f.storage

        for p in storage.properties():
            pass
            value_typedef = p.typedef

            value =  p.value
            print(p.name, value_typedef, value_typedef.category,p.property_def)

            if isinstance(value, aaf.iterator.BaseIterator):
                for item in value:
                    pass
                    #print "wee",item.value

    def test_dictionary(self):
        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        dictionary = f.dictionary
        storage = f.storage

        for p in dictionary.properties():
            pass
            #print p.name, p.value_typedef(),p.property_def(), p.value
        print(dictionary.classdef().parent().name)


    def test_properties(self):
        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        dictionary = f.dictionary
        storage = f.storage

        print(storage.count_mobs())

        for mob in storage.mobs():
            #print mob.count_properties()
            for p in mob.properties():
                value = p.property_value()
                valuedef = value.typedef()

                if valuedef.value(value) is None:
                    #pass
                    print("** missing", valuedef,valuedef.category)
                #print valuedef
                #print p,valuedef.name,
                #print valuedef.category
                if valuedef.category == 1:
                    intDef = valuedef
                    size = intDef.size()
                    signed = intDef.is_signed()
                    v = intDef.value(value)
                   # print v,size

                if valuedef.category == 3:
                    strongRef = valuedef
                    obj = strongRef.value(value)
                    obj_type = strongRef.object_type()
                    #print strongRef
                    #print strongRef.value(value),strongRef.object_type().name

                if valuedef.category == 6:
                    enum = valuedef
                    element_typdef = enum.element_typedef()
                    value = enum.value(value)
                    for key,value in enum.elements().items():
                        pass


                if valuedef.category == 7:
                    VariableArrayDef = valuedef

                    count = VariableArrayDef.count(value)
                    typedef = VariableArrayDef.type()
                    #print VariableArrayDef.count(value), VariableArrayDef,VariableArrayDef.name,typedef.name
                    for item in VariableArrayDef.value(value):
                        name = item.typedef().name
                        #rint '  ', item, name

                if valuedef.category == 8:
                    VariableArrayDef = valuedef

                    size = VariableArrayDef.size(value)
                    typedef = VariableArrayDef.type()
                    #print VariableArrayDef.count(value), VariableArrayDef,VariableArrayDef.name,typedef.name
                    for item in VariableArrayDef.value(value):
                        pass
                        #print item
                        #print '  ', item, name
                    #print '   ', p.name, intDef,signed, '=',v

                if valuedef.category == 10:
                    recordDef = valuedef
                    #recordDef = aaf.define.TypeDefRecord(valuedef)
                    #print '   ',p.name, recordDef, recordDef.value(value)
                    #print p.name
                    for x in range(recordDef.size()):
                        member_name = recordDef.member_name(x)
                        member_type = recordDef.member_typedef(x)

                    record_value = recordDef.value(value)
                    #for key,value in record_value.items():
                        #pass
                        #print '   ', key,value
                        #print '      ',recordDef.member_name(x),recordDef.member_type(x).name
                if valuedef.category == 12:
                    pass
                    #stringDef = aaf.define.TypeDefString(valuedef)

                if valuedef.category == 13:
                    enumExDef = valuedef
                    size = enumExDef.size()
                    #print size ,enumExDef
                    for key,value in enumExDef.elements().items():
                        pass
    def test_walk_file(self):
        test_file = main_test_file

        f = aaf.open(test_file)

        header = f.header

        def walk_properties(space, iter_item):

            for item in iter_item:
                value = item
                if isinstance(item, aaf.property.PropertyItem):
                    value = item.value
                name = ""
                if hasattr(item, 'name'):
                    name = item.name or ""

                #print space,name, value
                s = space + '   '
                if isinstance(value, aaf.base.AAFObject):
                    #print space, value.class_name
                    walk_properties(s, value.properties())
                if isinstance(value, aaf.iterator.BaseIterator):


                    walk_properties(s, value)
                    #print "iterator!"

        walk_properties("", header.properties())

    def test_comments(self):
        test_file = main_test_file
        f = aaf.open(test_file)
        header = f.header
        storage = f.storage

        for mob in storage.mobs():

            comments = list(mob.comments())
            if comments:
                print(mob.name)
                for c in comments:
                    print('  ', c.name, c.value)

    def test_create_comments(self):
        test_file = os.path.join(sandbox, 'comments_create.aaf')
        f = aaf.open(test_file, 'w')

        header = f.header
        d = f.dictionary

        mob = d.create.MasterMob("bob")
        f.storage.add_mob(mob)

        d = {'comment1':'value1', 'comment2': "value2", 'comment3':"value3"}
        for key, value in d.items():
            mob.append_comment(key,value)

        for item in mob.comments():
            print('**', item.name, item.value)
            assert d[item.name] == item.value

        mob.remove_comment_by_name('comment3')

        for item in mob.comments():
            assert item.name != 'comment3'

        f.save()
        f.close()


    def test_lookup_index(self):
        test_file = main_test_file
        f = aaf.open(test_file)
        header = f.header

        d = header['Dictionary'].value
        storage = header['Content'].value

        self.assertTrue(isinstance(d, aaf.dictionary.Dictionary))
        self.assertTrue(isinstance(storage, aaf.storage.ContentStorage))

        try:
            header["header doesn't have this key"]
        except KeyError as e:
            pass
        else:
            raise

        keys = d.keys()
        print(keys)
        for item in d['OperationDefinitions'].value:
            pass
    def test_dictionary_defs(self):
        test_file = main_test_file
        f = aaf.open(test_file)
        header = f.header
        d = f.dictionary

        for item in d.classdefs():
            pass
            #c,name = item.class_name, item.name
            print(item)
        for item in d.codecdefs():
            c,name = item.class_name, item.name
            #print c,name
        for item in d.typedefs():
            pass
            print(item)
            #c,name = item.class_name, item.name
            #print c,name
        for item in d.plugindefs():
            print(item)
            c,name = item.class_name, item.name
            #print c,name
        print("klv")
        for item in d.klvdatadefs():
            print(item)
            c,name = item.class_name, item.name
            #print c,name
        print("operation")
        for item in d.operationdefs():
            c,name = item.class_name, item.name
            #print c,name
        for item in d.parameterdefs():
            c,name =  item.class_name, item.name
            #print c,name
        for item in d.datadefs():
            c,name =  item.class_name, item.name
            #print c,name
        for item in d.containerdefs():
            c,name =  item.class_name, item.name
            #print c,name
        for item in d.interpolationdefs():
            c,name =  item.class_name, item.name
            #print c,name
        for item in d.taggedvaluedefs():
            c,name =  item.class_name, item.name
            #print c,name
    def test_plugin_manager(self):
        manager = aaf.dictionary.PluginManager()

        print(list(manager.loaded_plugins('codec')))

if __name__ == '__main__':
    unittest.main()
