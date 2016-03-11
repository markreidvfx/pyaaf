from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component
import aaf.util

from aaf.util import AUID, MobID

import unittest
import os

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)

main_test_file = os.path.join(sandbox, 'test_TypeDefVariableArray.aaf')

# TypeDef IDs
TaggedValueStrongRefTypeID =  AUID.from_list([0xda60bb00, 0xba41, 0x11d4, 0xa8, 0x12, 0x8e, 0x54, 0x1b, 0x97, 0x2e, 0xa3 ])

# ValueVariableArray IDs
TEST_VA_TYPE_ID = AUID.from_list([0x47240c2e, 0x19d, 0x11d4, 0x8e, 0x3d, 0x0, 0x90, 0x27, 0xdf, 0xca, 0x7c])
TaggedValueVariableArrayTypeID =  AUID.from_list([0xc9fb1100, 0xba3e, 0x11d4, 0xa8, 0x12, 0x8e, 0x54, 0x1b, 0x97, 0x2e, 0xa3 ])
MobWeakRefVariableArrayTypeID = AUID.from_list([0xe9794b79, 0xab2f, 0x4827, 0x9a, 0x31, 0x35, 0x39, 0xb2, 0x98, 0x67, 0xd6])

# Property IDs
TEST_PROP_ID = AUID.from_list([ 0x47240c2f, 0x19d, 0x11d4, 0x8e, 0x3d, 0x0, 0x90, 0x27, 0xdf, 0xca, 0x7c ])
ComponentAttributesProperty1ID = AUID.from_list([0x198e0c80, 0xba40, 0x11d4, 0xa8, 0x12, 0x8e, 0x54, 0x1b, 0x97, 0x2e, 0xa3])
ComponentAttributesProperty2ID = AUID.from_list([0x198e0c81, 0xba40, 0x11d4,  0xa8, 0x12, 0x8e, 0x54, 0x1b, 0x97, 0x2e, 0xa3])
MobReferencedMobsPropertyID = AUID.from_list([0x6f7b3c85, 0x7f57, 0x490b, 0xa3, 0xa8, 0xe5, 0xf2, 0xb4, 0xb1, 0x44, 0x34])

TEST_MobID = MobID.from_list([0x06, 0x0c, 0x2b, 0x34, 0x02, 0x05, 0x11, 0x01, 0x01, 0x00, 0x10, 0x00, 0x13,
                               0x00, 0x00, 0x00, 0xda, 0x5a, 0xb5, 0xf4, 0x04, 0x05, 0x11, 0xd4, 0x8e, 0x3d, 0x00, 0x90, 0x27, 0xdf, 0xca, 0x7c])

class TypeDefVariableArray(unittest.TestCase):

    def test_basic(self):

        f = aaf.open(main_test_file, 'w')

        # Create Int16 Array
        int16_typedef = f.dictionary.lookup_typedef("Int16")
        int16_array = aaf.define.TypeDefVariableArray(f, int16_typedef, TEST_VA_TYPE_ID, "TEST_VA_TYPE_ID")

        assert int16_array.name == "TEST_VA_TYPE_ID"
        assert int16_array.auid == TEST_VA_TYPE_ID

        # Create TaggedValue StrongRef Array
        tag_value_classdef = f.dictionary.lookup_classdef("TaggedValue")
        strongref_typedef = aaf.define.TypeDefStrongObjRef(f, tag_value_classdef, TaggedValueStrongRefTypeID, "TaggedValueStrongReference type")
        strongref_array = aaf.define.TypeDefVariableArray(f, strongref_typedef, TaggedValueVariableArrayTypeID, "TaggedValueVariableArray type")

        # Create MobWeakRef
        mob_weakref = f.dictionary.lookup_typedef("MobWeakReference")
        mob_weakref_array = aaf.define.TypeDefVariableArray(f, mob_weakref, MobWeakRefVariableArrayTypeID, "MobWeakRefVariableArray type")

        # Add Arrays to Component Class
        component_classdef = f.dictionary.lookup_classdef('Component')

        # find typedef we added to dictionary
        int16_array = f.dictionary.lookup_typedef("TEST_VA_TYPE_ID")
        strongref_array = f.dictionary.lookup_typedef("TaggedValueVariableArray type")
        mob_weakref_array = f.dictionary.lookup_typedef("MobWeakRefVariableArray type")

        # add a New Optional property to Components classes
        propery_def = component_classdef.register_optional_propertydef(int16_array, TEST_PROP_ID, "TEST_PROP")
        assert propery_def.name == "TEST_PROP"
        property_def = component_classdef.register_optional_propertydef(strongref_array, ComponentAttributesProperty1ID, "Component Attributes property1")
        property_def = component_classdef.register_optional_propertydef(strongref_array, ComponentAttributesProperty2ID, "Component Attributes property2")

        # Add MobWeakRef to mob class
        mob_classdef = f.dictionary.lookup_classdef("Mob")
        property_def = mob_classdef.register_optional_propertydef(mob_weakref_array, MobReferencedMobsPropertyID, "Mob ReferencedMobs property")

        master_mob = f.create.MasterMob()
        master_mob.mobID = TEST_MobID

        filler = f.create.Filler("Sound", 10)

        filler['TEST_PROP'].value = [1, 2, 3]

        tagged_values = [f.create.TaggedValue(name, value) for name, value in [("tag 1", "value 1"), ("tag 2", "value 2")]]

        filler['Component Attributes property1'].value = tagged_values

        tagged_values = [f.create.TaggedValue(name, value, 'Int16') for name, value in [("tag 1", 1), ("tag 2", 2)]]

        filler['Component Attributes property2'].value = tagged_values

        mobslot = f.create.StaticMobSlot()
        mobslot.segment = filler
        mobslot.slotID = 7
        mobslot['SlotName'].value = "Slot containing our VA Segment"

        master_mob.append_slot(mobslot)
        f.storage.add_mob(master_mob)

        weakref_mobs = []
        for i in range(10):
            mob = f.create.MasterMob()
            f.storage.add_mob(mob)
            weakref_mobs.append(mob)

        master_mob["Mob ReferencedMobs property"].value = weakref_mobs
        f.save()
        f.close()


        f = aaf.open(main_test_file, 'r')

        master_mob = f.storage.lookup_mob(TEST_MobID)
        assert len(master_mob['Mob ReferencedMobs property'].value) == 10

        filler = master_mob.slots()[0].segment

        assert list(filler['TEST_PROP'].value) == [1, 2, 3]

        for i, tag in enumerate(filler['Component Attributes property1'].value):
            assert tag.name == 'tag %i' % (i+1)
            assert tag.value == 'value %i' % (i+1)

        for i, tag in enumerate(filler['Component Attributes property2'].value):
            assert tag.name == 'tag %i' % (i+1)
            assert tag.value == i + 1




if __name__ == "__main__":
    unittest.main()
