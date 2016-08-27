custom_surface = {luaSurface = nil, custom_name = nil, oversurface = nil, subsurface = nil, subsurface_gen = false}


function custom_surface:init()
	global._custom_surface = global._custom_surface or {}
	global._custom_surface.custom_surfaces = global._custom_surface.custom_surfaces or {}
	global._custom_surface.meta_data = global._custom_surface.meta_data or {}

	global._custom_surface.static = global._custom_surface.static or {}
	self.__index = self
	setmetatable(global._custom_surface.static, self)

	global.events_manager:add_listener(defines.events.on_preplayer_mined_item ,global._custom_surface.static)
	global.events_manager:add_listener(defines.events.on_entity_died ,global._custom_surface.static)
	global.events_manager:add_listener(defines.events.on_robot_pre_mined ,global._custom_surface.static)
end



function custom_surface:new(o)
	if o.create_surface then
		if o.luasurface_name then
			if not game.surfaces[o.luasurface_name] then
				game.create_surface(o.luasurface_name, custom_surface.Generate_map_settings())
				o.subsurface_gen = true
			else
				error("A surface with the name '".. o.luasurface_name .. "' already exists, if you don't want to create a new game surface, don't use 'create_surface=true'!", 2)
			end
		else
			error("to create a new surface, you need to provide a unique 'luasurface_name' that will be used by the game",2)
		end
	end
	
	if o.luasurface_name then
		o.luaSurface = game.surfaces[o.luasurface_name]
	end
	o.custom_name = o.luaSurface.name

	if not o.luaSurface then error("A luaSurface must be given to create a new custom surface",2) end

	for _,custom_surface in ipairs(global._custom_surface.custom_surfaces) do
		if custom_surface.luaSurface.name == o.luaSurface.name then
			warning("you're trying to create a new custom surface for a surface that already has one, I returned the one that already exists\n" .. debug.traceback(nil, 2))
			return custom_surface
		end
	end

	o = o or {} -- create object if user does not provide one
	o = custom_surface:complete_data(o)

	self.__index = self
	setmetatable(o, self)
	global._custom_surface.custom_surfaces[o.luaSurface.name] = o

	if o:is_subsurface() then o.luaSurface.daytime = 0.5 end

	global.events_manager:add_listener(defines.events.on_chunk_generated ,o)

	return o
end


function custom_surface:complete_data(o)
	for key,value in pairs(custom_surface) do
		if not type(value) == "function" then
			if (o[key] == nil) then o[key] = value end
		end
	end
	return o
end

function custom_surface:setup()
	self.__index = self
	setmetatable(global._custom_surface.static, self)
	if global._custom_surface then
		for _,custom_surface in ipairs(global._custom_surface.custom_surfaces) do
			setmetatable(custom_surface, self)
		end
	end
end

function custom_surface:get_or_generate_subsurface(_surface)
	local current_surface = custom_surface:get_custom_surface{name = _surface.name}
	if current_surface.subsurface then return current_surface.subsurface end

	local subsurface_name = current_surface:generate_subsurface_name()
	if custom_surface:get_custom_surface{name = subsurface_name} then return custom_surface:get_custom_surface{name = subsurface_name} end
	return custom_surface:new{create_surface = true, luasurface_name = subsurface_name, oversurface = current_surface}
end


function custom_surface:get_custom_surface(arg) -- static function
	if arg.name then
		if global._custom_surface.custom_surfaces[arg.name] then
			return global._custom_surface.custom_surfaces[arg.name]
		end
		-- no custom_surface was found, create a new one if the surface exists in the game
		if game.surfaces[arg.name] then
			return custom_surface:new{luaSurface = game.surfaces[arg.name]}
		end
	elseif arg.custom_name then
		for _,custom_surface in ipairs(global._custom_surface.custom_surfaces) do
			if custom_surface.custom_name == arg.custom_name then
				return custom_surface
			end
		end
	end
end

function custom_surface:is_subsurface()
	if self.oversurface then return true end
end

--- generate a name that is unique
--- if the custom surface already has a subsurface, throw an error
--- the subsurface name generated has the following pattern : subsurface_<surface_name>_<subsurface_number>
function custom_surface:generate_subsurface_name()
	if self.subsurface then
		error("You cannot generate a subsurface name for a surface that already has a subsurface\nsurface name: " .. self.luaSurface.name .. " (custom name: ".. self.custom_name ..")\nsubsurface name: " .. self.subsurface.luaSurface.name .. " (custom name: ".. self.subsurface.custom_name ..")", 2)
	end
	local regex = "^subsurface_(.+)_(%d+)$"
	local surface_name, subsurface_number
	_, _, surface_name, subsurface_number = string.find(self.luaSurface.name, regex)
	local subsurface_name
	if surface_name and subsurface_number then
		subsurface_name = "subsurface_" .. surface_name .. "_" .. (subsurface_number+1)
	else
		subsurface_name = "subsurface_" .. self.luaSurface.name .. "_1"
	end
	return subsurface_name
end

function custom_surface:set_subsurface(_subsurface)
	if self.subsurface then error("you cannot change the subsurface of a surface that already has one!\nsurface name: " .. self.luaSurface.name .. " (custom name: ".. self.custom_name ..")\nalready present subsurface name: " .. self.subsurface.luaSurface.name .. " (custom name: ".. self.subsurface.custom_name ..")",2) end
	if _subsurface.oversurface then error("you cannot set a as a subsurface a surface that is already a subsurface\nsubsurface name: " .. _subsurface.luaSurface.name .. " (custom name: ".. _subsurface.custom_name ..")\nalready present oversurface name: " .. _subsurface.oversurface.luaSurface.name .. " (custom name: ".. _subsurface.oversurface.custom_name ..")",2) end
	
	local test_surface = self
	repeat
		if test_surface.oversurface == _subsurface then error("you think you're funny ? you cannot set a surface that is above another to be the subsurface of that other ...\nsurface name: " .. self.luaSurface.name .. " (custom name: ".. self.custom_name ..")\nsubsurface name: " .. self.subsurface.luaSurface.name .. " (custom name: ".. self.subsurface.custom_name ..")",2) end
		test_surface = test_surface.oversurface
	until test_surface == nil

	-- all seems to be good
	self.subsurface = _subsurface
	_subsurface.oversurface = self
end

function custom_surface:is_area_generated(_area)
	local chunk_area = {left_top = to_chunk_position(_area.left_top), right_bottom  = to_chunk_position(_area.right_bottom )}
	for x,y in iarea(chunk_area) do
		if not self.luaSurface.is_chunk_generated({x=x, y=y}) then
			return false
		end
	end
	local entities = self.luaSurface.find_entities(_area)
	return #entities
end

function custom_surface:request_gen_area(_area)
	if self:is_subsurface() then
		_area = expand_area(_area, 1)
	end
	chunk_area = {left_top = to_chunk_position(_area.left_top), right_bottom = to_chunk_position(_area.right_bottom)}
	for x,y in iarea(chunk_area) do
		self.luaSurface.request_to_generate_chunks({x=x*32 + 16,y=y*32 + 16}, 1)
	end
end


function custom_surface:clear_area(_clearing_area, _digging_area)
	local player_found = false
	if _clearing_area then
		for _,entity in ipairs(self.luaSurface.find_entities(_clearing_area)) do
			if entity.type ~="player" then
				entity.destroy()
			else
				player_found = true
			end
		end
	end
	if self.subsurface_gen and _digging_area then

		local walls_destroyed = 0
		local new_tiles = {}
		for x, y in iarea(_digging_area) do
			if self.luaSurface.get_tile(x, y).name ~= cavern_Ground_name then
				table.insert(new_tiles, {name = cavern_Ground_name, position = {x, y}})
			end

			--[[TODO : change the folowing code once the class handling orders has been done
			if global.marked_for_digging[string.format("%s&@{%d,%d}", self.luaSurface.name, math.floor(x), math.floor(y))] then -- remove the mark
				if global.marked_for_digging[string.format("%s&@{%d,%d}", self.luaSurface.name, math.floor(x), math.floor(y))].valid then
					global.marked_for_digging[string.format("%s&@{%d,%d}", self.luaSurface.name, math.floor(x), math.floor(y))].destroy()
				end
				global.marked_for_digging[string.format("%s&@{%d,%d}", self.luaSurface.name, math.floor(x), math.floor(y))] = nil
			end
			if global.digging_pending[self.luaSurface.name] and global.digging_pending[self.luaSurface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] then -- remove the digging pending entity
				if global.digging_pending[self.luaSurface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))].valid then
					global.digging_pending[self.luaSurface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))].destroy()
				end
				global.digging_pending[self.luaSurface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] = nil
			end
			]]
			local wall = self.luaSurface.find_entity(cavern_Wall_name, {x = x, y = y})
			if wall then 
				wall.destroy()
				walls_destroyed = walls_destroyed + 1
			else
			end
		end
		local to_add = {}

		for x, y in iouter_area_border(_digging_area) do
			if self.luaSurface.get_tile(x, y).name == "out-of-map" then
				table.insert(new_tiles, {name = "cave-walls", position = {x, y}})
				self.luaSurface.create_entity{name = cavern_Wall_name, position = {x, y}, force=game.forces.neutral}
				--[[if global.marked_for_digging[string.format("%s&@{%d,%d}", self.luaSurface.name, math.floor(x), math.floor(y))] then -- manage the marked for digging cells
					if global.digging_pending[self.luaSurface.name] == nil then global.digging_pending[self.luaSurface.name] = {} end
					if global.digging_pending[self.luaSurface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] == nil then 
						table.insert(to_add, {surface = self.luaSurface,x = x, y = y})
					end
					if global.marked_for_digging[string.format("%s&@{%d,%d}", self.luaSurface.name, math.floor(x), math.floor(y))].valid then	
						global.marked_for_digging[string.format("%s&@{%d,%d}", self.luaSurface.name, math.floor(x), math.floor(y))].destroy()
					end
					global.marked_for_digging[string.format("%s&@{%d,%d}", self.luaSurface.name, math.floor(x), math.floor(y))] = nil
				end]]
			end
		end
		self.luaSurface.set_tiles(new_tiles)

		-- done after because set_tiles remove decorations
		for _,data in ipairs(to_add) do
			local pending_entity = data.surface.create_entity{name = "pending-digging", position = {x = data.x, y = data.y}, force=game.forces.neutral}
			global.digging_pending[data.surface.name][string.format("{%d,%d}", math.floor(data.x), math.floor(data.y))] = pending_entity
		end
	end

	return {player_found = player_found, walls_destroyed = walls_destroyed}
end



function custom_surface:on_preplayer_mined_item(event) -- static
	self:on_entity_removed(event)
end
function custom_surface:on_entity_died(event) -- static
	self:on_entity_removed(event)
end
function custom_surface:on_robot_pre_mined(event) -- static
	self:on_entity_removed(event)
end


function custom_surface:on_entity_removed(event) -- static
	if event.entity.name == cavern_Wall_name then
		local c_surface = get_custom_surface{name=event.entity.surface.name}
		c_surface:clear_area(nil, {left_top = event.entity.position, right_bottom = event.entity.position})
	end
end

function custom_surface:on_chunk_generated(event)
	if event.surface.name == self.luaSurface.name then
		if not self.subsurface_gen then return end
		local newTiles = {}
		for x, y in iarea(event.area) do
			table.insert(newTiles, {name = "out-of-map", position = {x, y}})
		end
		event.surface.set_tiles(newTiles)
	end
end


--- Generate custom Map Settings
function custom_surface.Generate_map_settings()
	res = 
	{
		terrain_segmentation = "none", 
		water = "none", 
		autoplace_controls = {},
		shift = {0,0},
		peaceful_mode = true,
	}
	for ressource_name,_ in pairs(game.surfaces.nauvis.map_gen_settings) do
		res.autoplace_controls[ressource_name] = {
			frequency = "very-high",
			size = "very-big",
			richness = "very-good",
		}
	end
	return res			
end