classdef Node
    properties 
        id {mustBeInteger}
        position Point2D
        support  Support
        point_load PointLoad
        point_moment PointMoment
    end

    methods
        function obj = Node(id, x, y, point_load, point_moment, rx, ry, rm)
            arguments
                id {mustBeInteger}
                x {mustBeNumeric}
                y {mustBeNumeric}
                point_load double;
                point_moment double;
                rx {mustBeNumericOrLogical} = 0
                ry {mustBeNumericOrLogical} = 0
                rm {mustBeNumericOrLogical} = 0
                
            end

            obj.id = id;
            obj.position = Point2D(x, y);
            obj.support = Support(rx, ry, rm);
            obj.point_load = PointLoad(point_load, obj);
            obj.point_moment = PointMoment(point_moment, obj);
        end

    end
end