from base cimport AAFBase, AAFObject
from util cimport lookup_object

cdef object isA(AAFBase obj1,obj2):
    try:
        obj2(obj1)
    except:
        return False
    
    return True

def resolve_object(AAFBase obj):
    
    
    if isA(obj, AAFObject):
        
        AAFObj = AAFObject(obj)
        try:
            obj_type = lookup_object(AAFObj.class_name)
        
            return obj_type(AAFObj)
        except:
            #print "no lookup for %s" % AAFObj.class_name
            return AAFObj
    
    return obj
        