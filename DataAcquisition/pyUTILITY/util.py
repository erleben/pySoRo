import pyMATH.vector3 as V3
import pyMATH.quaternion as Q
import numpy as np


def string2bool(value):
    if value in ['True', 'true', 'yes', '1']:
        return True
    if value in ['False', 'false', 'no', '0']:
        return False
    raise RuntimeError('string2bool(): Unrecognized string value')


def string_list_2_sorted_tuple(value):
    data = [n for n in value.strip('()').split(',')]
    data.sort()
    return tuple(data)


def string_from_xml(xml_tag, name, default_value=''):
    if name not in xml_tag.attrib:
        return default_value
    value = xml_tag.attrib[name]
    if value is None:
        return default_value
    return value


def bool_from_xml(xml_tag, name, default_value=False):
    if name not in xml_tag.attrib:
        return default_value
    value = xml_tag.attrib[name]
    if value is None:
        return default_value
    return string2bool(value)


def float_from_xml(xml_tag, name, default_value=0.0):
    if name not in xml_tag.attrib:
        return default_value
    value = xml_tag.attrib[name]
    if value is None:
        return default_value
    return float(value)


def int_from_xml(xml_tag, name, default_value=0):
    if name not in xml_tag.attrib:
        return default_value
    value = xml_tag.attrib[name]
    if value is None:
        return default_value
    return int(value)


def vector3_from_xml(xml_tag, name, default_value=V3.zero()):
    if name not in xml_tag.attrib:
        return default_value
    value = xml_tag.attrib[name]
    if value is None:
        return default_value
    return V3.from_string(value)


def quaternion_from_xml(xml_tag, name, default_value=Q.identity()):
    if name not in xml_tag.attrib:
        return default_value
    value = xml_tag.attrib[name]
    if value is None:
        return default_value
    return Q.from_string(value)


def xml_pretty_indent(elem, level=0):
    i = "\n" + level*"  "
    if len(elem):
        if not elem.text or not elem.text.strip():
            elem.text = i + "  "
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
        for elem in elem:
            xml_pretty_indent(elem, level+1)
        if not elem.tail or not elem.tail.strip():
            elem.tail = i
    else:
        if level and (not elem.tail or not elem.tail.strip()):
            elem.tail = i


def array2string(x):
    return np.array2string(x, precision=8, separator=',', suppress_small=True)

