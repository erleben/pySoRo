import os
import xml.etree.ElementTree as ET
import pySENSOR.api as API
import pyUTILITY.util as UTIL
from MotorControl import api as MC


def load_from_elementtree(root_tag):

    if root_tag is None:
        raise RuntimeError('load(): No root element')

    motor_control = MC.Motorcontrol()

    mc_tag = root_tag.find('motor')

    if mc_tag is None:
        return motor_control

    if UTIL.bool_from_xml(mc_tag, 'use_motor_control', False) == False:
        return None

    motor_control.num_boards = UTIL.int_from_xml(mc_tag, 'num_boards', motor_control.num_boards)
    motor_control.portname = UTIL.string_from_xml(mc_tag, 'portname', motor_control.portname)
    motor_control.distribution = UTIL.string_from_xml(mc_tag, 'distribution', motor_control.distribution)
    motor_control.update()

    return motor_control


def load(filename):
    ext = os.path.splitext(filename)[-1].lower()

    if ext != '.xml':
        raise RuntimeError('load: file was not a xml file'+filename)

    if not os.path.isfile(filename):
        raise RuntimeError('load: filename was not a file'+filename)

    if not os.path.exists(filename):
        raise RuntimeError('load: file did not exist'+filename)

    xml = ET.parse(filename)
    root = xml.getroot()
    return load_from_elementtree(root)


def save_to_elementtree(motor_control, root_tag):
    mc_tag = ET.SubElement(root_tag, 'motor')
    mc_tag.attrib['use_motor_control'] = str(motor_control.use_motor_control)
    mc_tag.attrib['num_boards'] = str(motor_control.num_boards)
    mc_tag.attrib['portname'] = str(motor_control.portname)
    mc_tag.attrib['distribution'] = str(motor_control.distribution)


def save(motor_control, filename):
    ext = os.path.splitext(filename)[-1].lower()

    if ext != '.xml':
        raise RuntimeError('save: file was not a xml file'+filename)

    root_tag = ET.Element('scene')
    save_to_elementtree(motor_control, root_tag)
    UTIL.xml_pretty_indent(root_tag)
    tree = ET.ElementTree(root_tag)
    tree.write(filename)
