simple_item_elevator = {input_belt = nil, output_belt = nil, active = nil, valid = true}

function simple_item_elevator:init()
	global._simple_item_elevator = global._simple_item_elevator or {}
	global._simple_item_elevator.simple_item_elevators = global._simple_item_elevator.simple_item_elevators or {}
	global._simple_item_elevator.meta_data = global._simple_item_elevator.meta_data or {}

	global._simple_item_elevator.static = global._simple_item_elevator.static or {}
	self.__index = self
	setmetatable(global._simple_item_elevator.static, self)
end

function simple_item_elevator:new(o)
	if not (o.input_belt.valid and o.output_belt.valid) then
		error("Eather the input belt or the output belt from the item_elevator is invalid",2)
	end

	o = o or {} -- create object if user does not provide one
	o = simple_item_elevator:complete_data(o)

	self.__index = self
	setmetatable(o, self)
	global._simple_item_elevator.simple_item_elevators[string.format("%s@{%d,%d}-%s@{%d,%d}", o.input_belt.surface.name, o.input_belt.position.x, o.input_belt.position.y, o.output_belt.surface.name, o.output_belt.position.x, o.output_belt.position.y)] = o
	
	global.events_manager:add_listener(defines.events.on_tick, o)

	return o
end


function simple_item_elevator:complete_data(o)
	for key,value in pairs(simple_item_elevator) do
		if not type(value) == "function" then
			if (o[key] == nil) then o[key] = value end
		end
	end
	return o
end


function simple_item_elevator:setup()
	if global._simple_item_elevator then
		for _,simple_item_elevator in ipairs(global._simple_item_elevator.simple_item_elevators) do
			self.__index = self
			setmetatable(simple_item_elevator, self)
		end
	end
end


function simple_item_elevator:on_tick(_)
	if not (self.input_belt.valid and self.output_belt.valid) then
		self.valid = false
	elseif self.input_belt.active or self.output_belt.active then
		for laneI=1,2 do
			local lane_input = self.input_belt.get_transport_line(laneI)
			local lane_output = self.output_belt.get_transport_line(laneI)
			if lane_input.get_item_count() > 0 then
				local item_to_move = {name = next(lane_input.get_contents(), nil), count = 1}
				if lane_output.insert_at_back(item_to_move) then lane_input.remove_item(item_to_move) end
			end
		end
	end
end

function simple_item_elevator:destroy()
	global.events_manager:remove_listener(defines.events.on_tick, self)
	global._simple_item_elevator.simple_item_elevators[string.format("%s@{%d,%d}-%s@{%d,%d}", self.input_belt.surface.name, self.input_belt.position.x, self.input_belt.position.y, self.output_belt.surface.name, self.output_belt.position.x, self.output_belt.position.y)] = nil
end