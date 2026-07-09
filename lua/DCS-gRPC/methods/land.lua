--
-- RPC land actions
-- https://wiki.hoggitworld.com/view/DCS_singleton_land
--


GRPC.methods.findPathOnRoads = function(params)
    if params.start == nil or params.dest == nil then
        return GRPC.success({roads = {}})
    end
    local roads = land.findPathOnRoads('roads' , params.start.x ,params.start.y , params.dest.x , params.dest.y ) or {}
    return GRPC.success({
        roads = roads
    })
    
end

GRPC.methods.getClosestPointOnRoads = function(params)
    local x, y = land.getClosestPointOnRoads('roads' , params.x , params.y )
    return GRPC.success({
        x = x, y = y
    })
end
