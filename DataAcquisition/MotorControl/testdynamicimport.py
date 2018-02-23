import importlib
import os

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
        spec = importlib.util.spec_from_file_location(module_name, file_path)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
    except Exception as e:
        print(e)
    return mod

def get_function(module, function_name):
    try:
        func = getattr(module, function_name)
    except Exception as e:
        print(e)
    return func


mod=load_module('/Users/FredrikHolsten/Desktop/TA/week4/week4.py','week4')
fun = get_function(mod, 'testfun')
print(fun())
    
#print(os.path.dirname(os.path.abspath(__file__)))
#print(os.getcwd())

#Load module, increment and getPos
#In xml settup
#settup.xml: 
#    motor:  num_baords
#            ...
#            distribution_module_name
#
#Hardcoded: The place you stpre the module
#            The name of increment and getPos
            