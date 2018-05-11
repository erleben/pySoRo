classdef ConfigModel < handle
    properties (SetAccess = private)
        Model = 0;

    end
    
    methods
        function CM = ConfigModel(mod_name)
            CM.Model = load(mod_name);
        end
        
        function a = getAlpha(CM,x)
            a = CM.Model.model(x);
        end
        
    end
end