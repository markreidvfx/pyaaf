from __future__ import print_function
import aaf
import aaf.mob
import aaf.define
import aaf.iterator
import aaf.dictionary
import aaf.storage
import aaf.component

import unittest
import traceback

import os

import uuid

cur_dir = os.path.dirname(os.path.abspath(__file__))

sandbox = os.path.join(cur_dir,'sandbox')
if not os.path.exists(sandbox):
    os.makedirs(sandbox)
