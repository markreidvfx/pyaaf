from base cimport AAFBase, AAFObject
from util cimport lookup_object

from metadef cimport MetaDef, TypeDef, ClassDef, PropertyDef, resolve_typedef

cdef object isA(AAFBase obj1,obj2):
    try:
        obj2(obj1)
    except:
        return False
    
    return True

def resolve_object(AAFBase obj):
    """
    resolve any AAFBase object into it highest level class
    """
    
    if isA(obj, AAFObject):
        
        AAFObj = AAFObject(obj)
        try:
            obj_type = lookup_object(AAFObj.class_name)
        
            return obj_type(AAFObj)
        except:
            #print "no lookup for %s" % AAFObj.class_name
            
            if isinstance(obj, AAFObject):
                return obj
            else:
                return AAFObj
    elif isA(obj, MetaDef):
        
        if isA(obj, TypeDef):
            return resolve_typedef(TypeDef(obj))
        elif isA(obj, ClassDef):
            return ClassDef(obj)
        elif isA(obj, PropertyDef):
            return PropertyDef(obj)
        else:        
            raise ValueError("Unknown Metadef")
        

    
    return obj
        