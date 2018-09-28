import os
import xml.etree.ElementTree as ET
import pyUTILITY.util as UTIL
from MotorControl import api as MC
import importlib
import os


def load_from_elementtree(root_tag):

    if root_tag is None:
        raise RuntimeError('load(): No root element')

    motor_control = MC.MotorControl()

    mc_tag = root_tag.find('motor')

    if mc_tag is None:
        return motor_control

    if UTIL.bool_from_xml(mc_tag, 'use_motor_control', False) == False:
        return None

    motor_control.num_boards = UTIL.int_from_xml(mc_tag, 'num_boards', motor_control.num_boards)
    motor_control.portname = UTIL.string_from_xml(mc_tag, 'portname', motor_control.portname)
    motor_control.autotighten = UTIL.bool_from_xml(mc_tag, 'autotighten', motor_control.autotighten)
        
    path_name = UTIL.string_from_xml(mc_tag, 'distribution_module', None)
    module_args = UTIL.string_from_xml(mc_tag, 'module_args', None)
    _class = parse_set_args(path_name, module_args)
    motor_control.positionGenerator = _class
    
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
    mc_tag.attrib['autotighten'] = str(motor_control.autotighten)
    mc_tag.attrib['portname'] = str(motor_control.portname)
    mc_tag.attrib['distribution_module'] = str(motor_control.distribution_module)
    mc_tag.attrib['module_args'] = str(motor_control.module_args)


def save(motor_control, filename):
    ext = os.path.splitext(filename)[-1].lower()

    if ext != '.xml':
        raise RuntimeError('save: file was not a xml file'+filename)

    root_tag = ET.Element('scene')
    save_to_elementtree(motor_control, root_tag)
    UTIL.xml_pretty_indent(root_tag)
    tree = ET.ElementTree(root_tag)
    tree.write(filename)

def parse_set_args(path_to_module, args):
    
    try:
        #path_to_module = getPathToDist(module_name)
        module_name = path_to_module.split('/')[-1]
        name = module_name.split('.')[0]
        class_name = name[0].upper() + name[1:]
        module = load_module(path_to_module, name)
        _class = getattr(module, class_name)
        instance = _class()
        
        arg_pairs = args.split(';')
        
        for arg_p in arg_pairs:
            (arg_name, arg_str) = arg_p.split(',')
            arg = [int(n) for n in arg_str.strip('[]').split()]
            setter = getattr(instance, arg_name)
            setter(arg)
            
    except Exception as e:
        print(e)
        
    return instance
        
def getPathToDist(module_name):
    path = ''
    cwd_dirs = os.getcwd().split('/')[1:]
    
    for dir_ in cwd_dirs:
        path = path+'/'+dir_
        if dir_ == 'DataAcquisition':
            break
    
    path = path + '/pyDIST/' + module_name
    return path

def load_module(file_path, module_name):
    try:
        # workaround only for windows problems
        if(module_name=="uniform"):
            file_path = "C:/Users/kerus/Documents/GitHub/pySoRo/DataAcquisition/pyDIST/uniform.py"
        spec = importlib.util.spec_from_file_location(module_name, file_path)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
    except Exception as e:
        print(e)
    return mod

