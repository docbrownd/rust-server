--
-- RPC airbase actions
-- https://wiki.hoggitworld.com/view/DCS_Class_Airbase
--


GRPC.methods.forceCaptures = function(params)
    for _, infos in ipairs(params.infos) do
        GRPC.methods.forceCapture(infos)
    end
    return GRPC.success({})
end


GRPC.methods.forceCapture = function(params)
    local base = Airbase.getByName(params.name)
    local coalition
    if params.coalition == nil then coalition = 1 else coalition = params.coalition -1 end 
    if base and base.autoCapture and base.setCoalition  then 
        base:autoCapture(false)
        base:setCoalition(coalition)
    else 
        env.info('base inconnue : ' .. tostring(params.name))
        return GRPC.errorNotFound("base does not exist")
    end 
    return GRPC.success({})
end
