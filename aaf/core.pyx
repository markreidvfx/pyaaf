
cimport lib
from .util cimport error_check

def register_all(path=None):
    """
    Loads AAF dll and registers shared plugins.
    """

    cdef bytes c_path

    if path:
        if isinstance(path, unicode):
            c_path = path.encode("ascii")
        else:
            c_path = path
        error_check(lib.AAFLoad(c_path))
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
