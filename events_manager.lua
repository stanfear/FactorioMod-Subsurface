events_manager = {names = {}, registered_listeners = {}, registered_functions = {}, active = false }

function events_manager:new(o)
	if global._events_manager then
		warning("An event manager has already been generated. Generating a new one will render the previous useless (unless you use reload_events() again - Only one manager can be used at a time).\nPrevious event_manager generated in:\n" .. global._events_manager.meta_data.previous_traceback .. "\n\nNew event_manager generated in:\n" .. debug.traceback(nil, 2))
	end
	global._events_manager = global._events_manager or {}
	global._events_manager.meta_data = global._events_manager.meta_data or {}
	global._events_manager.meta_data.previous_traceback = debug.traceback(nil, 2)

	global._events_manager.managers = global._events_manager.managers or {}
	o = o or {} -- create object if user does not provide one
	self.__index = self
	setmetatable(o, self)
	table.insert(global._events_manager.managers, o)
	o:reload_events()
	return o
end

function events_manager:setup()
	if global._events_manager then
		for _,manager in ipairs(global._events_manager.managers) do
			self.__index = self
			setmetatable(manager, self)
			if manager.active then
				manager:reload_events()
			end
		end
	end
end

function events_manager:reload_events()
	for _,manager in ipairs(global._events_manager.managers) do
		manager.active = false
	end
	self.active = true
	for event_name,event_id in pairs(defines.events) do
		script.on_event(event_id, function (event) self:event(event) end)
		self.names[event_id] = event_name
	end
end


function events_manager:event(_event)
	local event_name = self.names[_event.name]
	if self.registered_listeners[_event.name] then -- only if the event has a listener
		for listener,fun in pairs(self.registered_listeners[_event.name]) do
			if listener[event_name] then
				if fun == 1 then listener[event_name](listener, _event) end
			end
		end
	end
	if self.registered_functions[_event.name] then
		for id,fun in pairs(self.registered_functions[_event.name]) do
			if type(fun) == "function" then fun(_event, id) end
		end
	end
end

function events_manager:add_listener(_event_id, _listener)
	if not self.names[_event_id] then self:reload_events() end -- if an event is not recorded, reload them all
	-- if after reloading the event is still not recorded
	if not self.names[_event_id] then error("invalid event id: '" .. _event_id.. "'\nthe event must be registered in the defines.events table. If you created the event yourself, please use 'defines.events.<event_name> = generate_event_name()'", 2) end
	local event_name = self.names[_event_id]
	
	--if type(_event_id) ~= "number" then error("invalid event id: '" .. _event_id.. "'", 2) end -- actually not needed since the if not self.names[_event_id] then test checks that for us
	if type(_listener) ~= "table"  then error("invalid listener : the listener must be a table (object)", 2) end
	if not _listener[event_name] then error("invalid listener : the listener must conatin a function named " .. event_name, 2) end

	if not self.registered_listeners[_event_id] then self.registered_listeners[_event_id] = {} end
	self.registered_listeners[_event_id][_listener] = 1
end

function events_manager:remove_listener(_event_id, _listener)
	if type(_event_id) ~= "number" then error("invalid event id: '" .. _event_id.. "'", 2) end
	if type(_listener) ~= "table"  then error("invalid listener : the listener must be a table (object)", 2) end
	self.registered_listeners[_event_id][_listener] = nil
end


function events_manager:add_function(_event_id, _function_id, _function)
	if not self.names[_event_id] then self:reload_events() end -- if an event is not recorded, reload them all
	-- if after reloading the event is still not recorded
	if not self.names[_event_id] then error("the event must be registered in the defines.events table. If you created the event yourself, please use 'defines.events.<event_name> = generate_event_name()'", 2) end
	local event_name = self.names[_event_id]
	
	if type(_event_id) ~= "number" then error("invalid event id: '" .. _event_id.. "'", 2) end
	if type(_function_id) ~= "string" then error("invalid argument, _function_id must be a string", 2) end
	if type(_function) ~= "function" then error("invalid argument, _function must have type function", 2) end



	if not self.registered_functions[_event_id] then self.registered_functions[_event_id] = {} end
	self.registered_functions[_event_id][_function_id] = _function
end

function events_manager:remove_function(_event_id, _function_id)
	if type(_event_id) ~= "number" then error("invalid event id: '" .. _event_id.. "'", 2) end
	if type(_function_id) ~= "string" then error("invalid argument, _function_id must be a string", 2) end
	self.registered_functions[_event_id][_function_id] = nil
end


function warning(str)
	game.show_message_dialog{text=str, point_to={type="nowhere"}}
end