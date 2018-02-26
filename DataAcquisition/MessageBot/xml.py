import os
import xml.etree.ElementTree as ET
import pyUTILITY.util as UTIL
#from MessageBot import api as MB


def load_from_elementtree(root_tag):

    if root_tag is None:
        raise RuntimeError('load(): No root element')

    mc_tag = root_tag.find('message_bot')

    if mc_tag is None:
        return None

    if UTIL.bool_from_xml(mc_tag, 'on', False) == False:
        return None
    
    # Since sypder cant import telegram: import mb iff asked to do so
    from MessageBot import api as MB
    
    message_bot = MB.MessageBotThread(2, 'MessageBotThread')
    
    message_bot.USER = UTIL.int_from_xml(mc_tag, 'user', message_bot.USER)
    message_bot.TOKEN = UTIL.string_from_xml(mc_tag, 'token', message_bot.TOKEN)
    message_bot.enable_images = UTIL.bool_from_xml(mc_tag, 'enable_images', message_bot.enable_images)
    message_bot.update()

    return message_bot


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


def save_to_elementtree(message_bot, root_tag):
    mc_tag = ET.SubElement(root_tag, 'message_bot')
    mc_tag.attrib['on'] = str(message_bot.on)
    mc_tag.attrib['TOKEN'] = str(message_bot.TOKEN)
    mc_tag.attrib['USER'] = str(message_bot.USER)
    mc_tag.attrib['enable_images'] = str(message_bot.enable_images)


def save(motor_control, filename):
    ext = os.path.splitext(filename)[-1].lower()

    if ext != '.xml':
        raise RuntimeError('save: file was not a xml file'+filename)

    root_tag = ET.Element('scene')
    save_to_elementtree(motor_control, root_tag)
    UTIL.xml_pretty_indent(root_tag)
    tree = ET.ElementTree(root_tag)
    tree.write(filename)


