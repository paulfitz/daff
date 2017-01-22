# -*- coding: utf-8 -*-
from __future__ import unicode_literals, print_function
try:
    import builtins
except:
    import __builtin__
    builtins = __builtin__
import functools

if hasattr(builtins,'unicode'):
    # python2 variant
    hxunicode = builtins.unicode
    hxunichr = builtins.unichr
    hxrange = xrange
    def hxnext(x):
        return x.next()
    if hasattr(functools,"cmp_to_key"):
        hx_cmp_to_key = functools.cmp_to_key
    else:
        # stretch to support python2.6
        def hx_cmp_to_key(mycmp):
            class K(object):
                def __init__(self, obj, *args):
                    self.obj = obj
                def __lt__(self, other):
                    return mycmp(self.obj, other.obj) < 0
                def __gt__(self, other):
                    return mycmp(self.obj, other.obj) > 0
                def __eq__(self, other):
                    return mycmp(self.obj, other.obj) == 0
                def __le__(self, other):
                    return mycmp(self.obj, other.obj) <= 0  
                def __ge__(self, other):
                    return mycmp(self.obj, other.obj) >= 0
                def __ne__(self, other):
                    return mycmp(self.obj, other.obj) != 0
            return K
else:
    # python3 variant
    hxunicode = str
    hxrange = range
    hxunichr = chr
    unichr = chr
    unicode = str
    def hxnext(x):
        return x.__next__()
    hx_cmp_to_key = functools.cmp_to_key

python_lib_Builtin = builtins
String = builtins.str
python_lib_Dict = builtins.dict
python_lib_Set = builtins.set
