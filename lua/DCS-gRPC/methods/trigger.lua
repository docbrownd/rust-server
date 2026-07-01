--
-- RPC trigger actions
-- https://wiki.hoggitworld.com/view/DCS_singleton_trigger
--

-- All MarkPanels must have a unique ID but there is no way of
-- delegating the creationg of this ID to the game, so we have
-- to have the following code to make sure we always get a new
-- unique id
local MarkId = 0

local function getMarkId()
    local panels =  world.getMarkPanels()
    local idx = MarkId
    if panels then
        local l_max = math.max
        for _,panel in ipairs(panels) do
            idx = l_max(panel.idx, idx)
        end
    end
    idx = idx + 1
    MarkId = idx
    return idx
end

local function deepCopy(object)
  local lookup_table={}
  local function _copy(object)
      if type(object) ~= "table" then
          return object
      elseif lookup_table[object] then
          return lookup_table[object]
      end
      local new_table = {}
      lookup_table[object] = new_table
      for index,value in pairs(object) do
          new_table[_copy(index)] = _copy(value)
      end
      return setmetatable(new_table,getmetatable(object))
  end
  local objectreturn = _copy(object)
  return objectreturn
end


GRPC.methods.outText = function(params)
  trigger.action.outText(params.text, params.displayTime, params.clearView)

  return GRPC.success({})
end

GRPC.methods.outTextForCoalition = function(params)
  if params.coalition == 0 then
    return GRPC.errorInvalidArgument("a specific coalition must be chosen")
  end

  -- Decrement for non zero-indexed gRPC enum
  trigger.action.outTextForCoalition(params.coalition - 1, params.text, params.displayTime, params.clearView)

  return GRPC.success({})
end

GRPC.methods.outTextForGroup = function(params)
  trigger.action.outTextForGroup(params.groupId, params.text, params.displayTime, params.clearView)

  return GRPC.success({})
end

GRPC.methods.outTextForUnit = function(params)
  trigger.action.outTextForUnit(params.unitId, params.text, params.displayTime, params.clearView)

  return GRPC.success({})
end

GRPC.methods.getUserFlag = function(params)
  return GRPC.success({
    value = trigger.misc.getUserFlag(params.flag),
  })
end

GRPC.methods.setUserFlag = function(params)
  trigger.action.setUserFlag(params.flag, params.value)
  return GRPC.success({})
end

GRPC.methods.markToAll = function(params)
  local point = coord.LLtoLO(params.position.lat, params.position.lon, params.position.alt)
  local idx = getMarkId()

  trigger.action.markToAll(idx, params.text, point, params.readOnly, params.message)

  return GRPC.success({
    id = idx
  })
end

GRPC.methods.markToCoalition = function(params)
  local point = coord.LLtoLO(params.position.lat, params.position.lon, params.position.alt)
  local idx = getMarkId()

  local coalition = params.coalition - 1 -- Decrement for non zero-indexed gRPC enum
  trigger.action.markToCoalition(idx, params.text, point, coalition, params.readOnly, params.message)

  return GRPC.success({
    id = idx
  })
end

GRPC.methods.markToGroup = function(params)
  local point = coord.LLtoLO(params.position.lat, params.position.lon, params.position.alt)
  local idx = getMarkId()

  trigger.action.markToGroup(idx, params.text, point, params.groupId, params.readOnly, params.message)

  return GRPC.success({
    id = idx
  })
end

GRPC.methods.removeMark = function(params)
  trigger.action.removeMark(params.id)

  return GRPC.success({})
end

GRPC.methods.markupToAll = function(params)
  local idx = getMarkId()
  local coalition = params.coalition or -1

   -- Number of points is variable so we need to make a table that we unpack
   -- later and add all parameters after the points into it as well
  local packedParams = {}
  for _, value in ipairs(params.points) do
    table.insert(packedParams, coord.LLtoLO(value.lat, value.lon, value.alt))
  end

  table.insert(packedParams, {
    params.borderColor.red,
    params.borderColor.green,
    params.borderColor.blue,
    params.borderColor.alpha
  })
  table.insert(packedParams, {
    params.fillColor.red,
    params.fillColor.green,
    params.fillColor.blue,
    params.fillColor.alpha
  })
  table.insert(packedParams, params.lineType)
  table.insert(packedParams, params.readOnly)
  table.insert(packedParams, params.message)

  trigger.action.markupToAll(params.shape, coalition, idx, unpack(packedParams))

  return GRPC.success({
    id = idx
  })
end

GRPC.methods.markupToCoalition = function(params)
  if params.coalition == 0 then
    return GRPC.errorInvalidArgument("a specific coalition must be chosen")
  end

  params.coalition = params.coalition - 1 -- Decrement for non zero-indexed gRPC enum

  return GRPC.methods.markupToAll(params)

end


GRPC.methods.explosion = function(params)
  local point = coord.LLtoLO(params.position.lat, params.position.lon, params.position.alt)

  trigger.action.explosion(point, params.power)

  return GRPC.success({})
end

-- gRPC enums should avoid 0 so we increment it there and then subtract by 1
-- here since this enum is zero indexed.
GRPC.methods.smoke = function(params)
  if params.color == 0 then
    return GRPC.errorInvalidArgument("color cannot be unspecified (0)")
  end
  local point = coord.LLtoLO(params.position.lat, params.position.lon, 0)
  local groundPoint = {
    x = point.x,
    y = land.getHeight({x = point.x, y = point.z}),
    z = point.z
  }

  trigger.action.smoke(groundPoint, params.color - 1)

  return GRPC.success({})
end

GRPC.methods.illuminationBomb = function(params)
  local point = coord.LLtoLO(params.position.lat, params.position.lon, 0)
  local groundOffsetPoint = {
    x = point.x,
    y = land.getHeight({x = point.x, y = point.z}) + params.position.alt,
    z = point.z
  }

  trigger.action.illuminationBomb(groundOffsetPoint, params.power)

  return GRPC.success({})
end

-- gRPC enums should avoid 0 so we increment it there and then subtract by 1
-- here since this enum is zero indexed.
GRPC.methods.signalFlare = function(params)
  if params.color == 0 then
    return GRPC.errorInvalidArgument("color cannot be unspecified (0)")
  end
  local point = coord.LLtoLO(params.position.lat, params.position.lon, 0)
  local groundPoint = {
    x = point.x,
    y = land.getHeight({x = point.x, y = point.z}),
    z= point.z}

  trigger.action.signalFlare(groundPoint, params.color - 1, params.azimuth)

  return GRPC.success({})
end

GRPC.methods.getZones = function(params)
  local result = {}
  if env.mission.triggers and env.mission.triggers.zones then
    for zone_ind, zone_data in pairs(env.mission.triggers.zones) do
      local zone = {}
      zone.point = {x = zone_data.x, z = zone_data.y, y = land.getHeight({x = zone_data.x, y = zone_data.y})}
      zone.id = zone_data.name
      zone.position = GRPC.exporters.position({x = zone_data.x, y = 0, z = zone_data.y})
      zone.radius = zone_data.radius 
      zone.type = zone_data.type
      zone.verticies = {}
      if zone_data.verticies ~= nil then
        

        zone.verticies[1] = {
          x = zone_data.verticies[1].x or 0,
          y = 0,
          z = zone_data.verticies[1].y or 0
        }
        zone.verticies[2] = {
          x = zone_data.verticies[2].x or 0,
          y = 0,
          z = zone_data.verticies[2].y or 0
        }                  
        zone.verticies[3] = {
          x = zone_data.verticies[3].x or 0,
          y = 0,
          z = zone_data.verticies[3].y or 0
        }                  
        zone.verticies[4] = {
          x = zone_data.verticies[4].x or 0,
          y = 0,
          z = zone_data.verticies[4].y or 0
        }
      end
      result[#result + 1] = zone
    end
    
  end
  return GRPC.success({zones = result})
end

GRPC.methods.markToAllBatch = function(params)
  for _, mark in ipairs(params.marks) do
    local packedParams = {}
    for _, value in ipairs(mark.points) do
      table.insert(packedParams, {x=value.x, y=value.alt, z=value.y})
    end
    table.insert(packedParams, {
      mark.borderColor.red,
      mark.borderColor.green,
      mark.borderColor.blue,
      mark.borderColor.alpha
    })
    table.insert(packedParams, {
      mark.fillColor.red,
      mark.fillColor.green,
      mark.fillColor.blue,
      mark.fillColor.alpha
    })
    table.insert(packedParams, mark.lineType)
    table.insert(packedParams, mark.readOnly)
    table.insert(packedParams, mark.message)

    trigger.action.markupToAll(mark.shape, -1, mark.id, unpack(packedParams))
  end
  return GRPC.success({})

end


GRPC.methods.textToAll = function(params)
  local color = {params.color.red, params.color.green, params.color.blue, params.color.alpha}
  local fillColor = {params.fillColor.red, params.fillColor.green, params.fillColor.blue, params.fillColor.alpha}
  trigger.action.textToAll(-1, params.id, {x = params.point.x, y = 0, z = params.point.y }, color, fillColor, params.fontSize, params.readOnly, params.text)
  return GRPC.success({})
end

GRPC.methods.textToAllBatch = function(params)
  for _, mark in ipairs(params.marks) do
    local color = {mark.color.red, mark.color.green, mark.color.blue, mark.color.alpha}
    local fillColor = {mark.fillColor.red, mark.fillColor.green, mark.fillColor.blue, mark.fillColor.alpha}
    trigger.action.textToAll(-1, mark.id, {x = mark.point.x, y = 0, z = mark.point.y }, color, fillColor, mark.fontSize, mark.readOnly, mark.text)
  end
  return GRPC.success({})
end

