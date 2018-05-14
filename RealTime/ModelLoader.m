% This is a module whose methods can be accessed from python
% Assumes that a function handle has been saved as mod_name

classdef ModelLoader < handle
    properties (SetAccess = private)
        Model = 0;

    end
    
    methods
        function CM = ModelLoader(mod_name)
            CM.Model = load(mod_name);
        end
        
        function a = getAlpha(CM,x)
            a = CM.Model.model(x);
        end
        
    end
end