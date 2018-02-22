import importlib

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
