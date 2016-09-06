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

class TestCommentMaker(unittest.TestCase):

    def test_add_comment_marker_props(self):
        f = aaf.open()

        # add RGBColor TypeDef
        rgb_id = AUID("urn:uuid:e96e6d43-c383-11d3-a069-006094eb75cb")

        rgb_typedef_pairs = [('red',   'UInt16'),
                             ('green', 'UInt16'),
                             ("blue",  'UInt16'),
                            ]
        rgb_typdef = aaf.define.TypeDefRecord(f, rgb_typedef_pairs, rgb_id, 'RGBColor')
        f.dictionary.register_def(rgb_typdef)

        cm_classdef = f.dictionary.lookup_classdef("CommentMarker")
        string_typedef = f.dictionary.lookup_typedef("string")

        # add CommentMarkerTime property
        cm_time_id = AUID("urn:uuid:c4c45d9c-0967-11d4-a08a-006094eb75cb")
        cm_prop_name = "CommentMarkerTime"
        cm_classdef.register_optional_propertydef(string_typedef, cm_time_id, cm_prop_name)

        # add CommentMarkerDate property
        cm_date_id = AUID("urn:uuid:c4c45d9b-0967-11d4-a08a-006094eb75cb")
        cm_prop_name = "CommentMarkerDate"
        cm_classdef.register_optional_propertydef(string_typedef, cm_date_id, cm_prop_name)

        # add CommentMarkerUSer property
        cm_user_id = AUID("urn:uuid:c4c45d9a-0967-11d4-a08a-006094eb75cb")
        cm_prop_name = "CommentMarkerUSer"
        cm_classdef.register_optional_propertydef(string_typedef, cm_user_id, cm_prop_name)

        # add CommentMarkerColor property
        cm_color_id = AUID("urn:uuid:e96e6d44-c383-11d3-a069-006094eb75cb")
        cm_prop_name = "CommentMarkerColor"
        cm_classdef.register_optional_propertydef(rgb_typdef, cm_color_id, cm_prop_name)

        # add CommentMarkerAttributeList property
        cm_attr_list_id = AUID("urn:uuid:c72cc817-aac5-499b-af34-bc47fec1eaa8")
        strongref = f.dictionary.lookup_typedef("TaggedValueStrongReferenceVector")
        cm_prop_name = "CommentMarkerAttributeList"
        cm_classdef.register_optional_propertydef(strongref, cm_attr_list_id, cm_prop_name)

        marker = f.create.DescriptiveMarker()

        marker['CommentMarkerTime'].value = "22:40"
        marker['CommentMarkerDate'].value = "06/18/2016"
        marker['CommentMarkerUSer'].value = "USERNAME"
        marker["CommentMarkerColor"].value = {"red":65535, "green":0, "blue":0}

        data = {'_ATN_CRM_USER': "USERNAME",
                '_ATN_CRM_DATE': "06/18/2016",
                '_ATN_CRM_COLOR': "Red"}

        marker["CommentMarkerAttributeList"].value = [f.create.TaggedValue(name, value) for name, value in data.items()]
        for tag in marker["CommentMarkerAttributeList"].value:
            print(tag.name, tag.value)

if __name__ == "__main__":
    unittest.main()
