classdef Beam2D < handle

    properties
        total_length (1, 1) {mustBeNumeric}
        nodes (1, :) BmNode
        members (1, :) BmMember
        point_loads (1, :) PointLoad
        point_moments (1, :) PointMoment
        distributed_loads (1, :) UniformDistributedLoad

        is_solved
    end

    properties (Access=private)
        DIV = 100000;
    end

    methods
        function obj = Beam2D(total_length)
            obj.total_length = total_length;
            obj.nodes = BmNode.empty();
            obj.members = BmMember.empty();
            obj.point_loads = PointLoad.empty();
            obj.point_moments = PointMoment.empty();
            obj.distributed_loads = UniformDistributedLoad.empty();
            obj.is_solved = false;
        end

        function obj = add_distributed_load(obj, distributed_load)
            obj.distributed_loads(end + 1) = distributed_load;
        end

        function obj = add_node(obj, node)
            obj.nodes(end + 1) = node;
            obj.point_loads(end + 1) = node.point_load;
            obj.point_moments(end + 1) = node.point_moment;
        end

        function obj = add_member(obj, member)
            obj.members(end + 1) = member;
        end

        function obj = add_nodes(obj, nodes)
            arguments
                obj
                nodes (1, :) BmNode
            end

            for i=1:length(nodes)
                obj.add_node(nodes(i));
            end
        end

        function obj = add_members(obj, members)
            arguments
                obj
                members (1, :) BmMember
            end

            for i=1:length(members)
                obj.add_member(members(i));
            end
        end

        function [x, shear_force] = calc_shear_force(obj)
            x = linspace(0, obj.total_length, obj.DIV);
            num_of_nodes = numel(obj.nodes);
            num_of_dist_loads = numel(obj.distributed_loads);
            shear_force = zeros(size(x));

            if ~obj.is_solved
                StaticBeam2DSolver.solve(obj);
            end

            for i = 1:numel(x)
                current_x = x(i);
                V = 0;

                % Add contribution from point loads
                for j = 1:num_of_nodes
                    node = obj.nodes(j);
                    if node.position.x <= current_x
                        V = V + double(node.reaction_force);
                        V = V + double(node.point_load);
                    end
                end

                % Add contribution from distributed loads
                for k = 1:num_of_dist_loads
                    distributed_load = obj.distributed_loads(k);
                    x_start = distributed_load.start_position.x;
                    x_end = distributed_load.end_position.x;

                    if current_x > x_start && current_x <= x_end
                        w = distributed_load.magnitude;
                        length_covered = current_x - x_start;
                        V = V + w * length_covered;
                    end
                end

                shear_force(i) = V;

            end
        end

        function [x, bending_moment] = calc_bending_moment(obj)
            node = obj.nodes(1);
            [x, shear_force] = obj.calc_shear_force();
            bending_moment = cumtrapz(x, shear_force);
            bending_moment = bending_moment - double(node.reaction_moment);
        end
    end
end