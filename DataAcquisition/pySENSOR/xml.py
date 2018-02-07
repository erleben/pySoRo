import os
import xml.etree.ElementTree as ET
import pySENSOR.api as API
import pyUTILITY.util as UTIL


def load_from_elementtree(root_tag):

    if root_tag is None:
        raise RuntimeError('load(): No root element')

    rs_thread = API.RealSenseThread(1, 'RealSenseThread')

    rs_tag = root_tag.find('realsense')

    if rs_tag is None:
        return rs_thread

    rs_thread.save_png = UTIL.bool_from_xml(rs_tag, 'save_png', rs_thread.save_png)
    rs_thread.save_ply = UTIL.bool_from_xml(rs_tag, 'save_ply', rs_thread.save_ply)
    rs_thread.prefix_filename = UTIL.string_from_xml(rs_tag, 'prefix', rs_thread.prefix_filename)
    rs_thread.postfix_filename = UTIL.string_from_xml(rs_tag, 'postfix', rs_thread.postfix_filename)

    return rs_thread


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


def save_to_elementtree(rs_thread, root_tag):
    rs_tag = ET.SubElement(root_tag, 'realsense')
    rs_tag.attrib['save_png'] = str(rs_thread.save_png)
    rs_tag.attrib['save_ply'] = str(rs_thread.save_ply)
    rs_tag.attrib['postfix'] = str(rs_thread.postfix)
    rs_tag.attrib['prefix'] = str(rs_thread.prefix)


def save(rs_thread, filename):
    ext = os.path.splitext(filename)[-1].lower()

    if ext != '.xml':
        raise RuntimeError('save: file was not a xml file'+filename)

    root_tag = ET.Element('scene')
    save_to_elementtree(rs_thread, root_tag)
    UTIL.xml_pretty_indent(root_tag)
    tree = ET.ElementTree(root_tag)
    tree.write(filename)

