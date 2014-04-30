
cimport lib
from .util cimport error_check

def register_all(path=None):
    """
    Loads AAF dll and registers shared plugins.
    """
    if path:
        error_check(lib.AAFLoad(path))
    else:
        error_check(lib.AAFLoad(NULL))
        
    cdef lib.IAAFPluginManager *plugin_manager
    plugin_manager = NULL
    try:
        error_check(lib.AAFGetPluginManager(&plugin_manager))
        error_check(plugin_manager.RegisterSharedPlugins())
    finally:
        if plugin_manager:
            plugin_manager.Release()