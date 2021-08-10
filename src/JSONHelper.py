import json
import os
import posixpath
from pathlib import Path


def getNodes(node):
    return json.loads(node)


def getValue(node, key):
    vals = []
    for val in getNodes(node):
        vals.append(val[key])

    return vals


def getAllValues(node):
    return getNodes(node)
