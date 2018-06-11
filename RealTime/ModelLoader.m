% This is a module whose methods can be accessed from python
% Assumes that a function handle has been saved as mod_name

classdef ModelLoader < handle
    properties (SetAccess = private)
        Model = 0;

    end
    
    methods
        function CM = ModelLoader(mod_name)
            CM.Model = load(mod_name);
            addpath('../Modeling/PointModel/experiments/');
        end
        
        function a = getAlpha(CM,x)
            a = CM.Model.model(x);
        end
        
        function a = getAlphaPath(CM, a, s, oc, or)
            a = cellfun(@double, cell(a));
            s = cellfun(@double, cell(s));
            oc = cellfun(@double, cell(oc));
            or = double(or);
            
            a = CM.Model.model(a, s, oc, or);
        end
        
    end
end