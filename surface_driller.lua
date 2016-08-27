defines.digging_state = {}
defines.digging_state.waiting_orders = 1
defines.digging_state.digging_in_progress = 2
defines.digging_state.digging_pending = 3
defines.digging_state.waiting_stabilisation = 4



surface_driller = {drill_entity = nil, construction_area_entities = {}, levels_to_digg = nil, levels_dug = 0, current_surface_drill_progress = 0, last_crafting_progress = 0, description_floating_text = nil, progression_floating_text = nil, digging_state = nil, previous_digging_state = nil}

function surface_driller:init()
	global._surface_driller = global._surface_driller or {}
	global._surface_driller.surface_drillers = global._surface_driller.surface_drillers or {}
	global._surface_driller.meta_data = global._surface_driller.meta_data or {}

	global._surface_driller.static = global._surface_driller.static or {}
	self.__index = self
	setmetatable(global._surface_driller.static, self)

	global.events_manager:add_listener(defines.events.on_robot_built_entity, global._surface_driller.static)
	global.events_manager:add_listener(defines.events.on_built_entity, global._surface_driller.static)
end


function surface_driller:new(o)
	if not o.drill_entity then error("an entity is required to create a surface driller custom object", 2) end

	o = o or {} -- create object if user does not provide one (although, in this case, it cannot happen)
	o = surface_driller:complete_data(o)

	o.digging_state = defines.digging_state.waiting_orders

	self.__index = self
	setmetatable(o, self)
	global._surface_driller.surface_drillers[string.format("%s@{%d,%d}", o.drill_entity.surface.name, o.drill_entity.position.x, o.drill_entity.position.y)] = o

	global.events_manager:add_listener(defines.events.on_tick, o)

	o:update_shown_progress()


	local drill_area = {
		left_top = {
			x = o.drill_entity.position.x + o.drill_entity.prototype.collision_box.left_top.x,
			y = o.drill_entity.position.y + o.drill_entity.prototype.collision_box.left_top.y},
		right_bottom = {
		 	x = o.drill_entity.position.x + o.drill_entity.prototype.collision_box.right_bottom.x,
		 	y = o.drill_entity.position.y + o.drill_entity.prototype.collision_box.right_bottom.y}
		}
	local next_surface = custom_surface:get_or_generate_subsurface(o.drill_entity.surface)
	next_surface:request_gen_area(expand_area(drill_area, 1))

	return o
end


function surface_driller:complete_data(o)
	for key,value in pairs(surface_driller) do
		if not type(value) == "function" then
			if (o[key] == nil) then o[key] = value end
		end
	end
	return o
end



function surface_driller:setup()
	self.__index = self
	setmetatable(global._surface_driller.static, self)
	if global._surface_driller then
		for _,surface_driller in ipairs(global._surface_driller.surface_drillers) do
			setmetatable(surface_driller, self)
		end
	end
end


function surface_driller:on_tick(event)
	if not self.levels_to_digg and self.drill_entity.recipe then --TODO : Allow the player to change how deep he wants to go !
		self.levels_to_digg = tonumber(string.match(self.drill_entity.recipe.name, 'surface%-drilling%-down%-(%d)'))
		self.digging_state = defines.digging_state.digging_in_progress
	end

	--[[if self.digging_state == defines.digging_state.waiting_orders then
		-- nothing can happen here		
	else]]
	if self.digging_state == defines.digging_state.digging_pending then
		if self.drill_entity.active then self.digging_state = defines.digging_state.digging_in_progress end
	end

	if self.digging_state == defines.digging_state.digging_in_progress then
		if self.drill_entity.active then
			if self.drill_entity.crafting_progress < self.last_crafting_progress then
				self.current_surface_drill_progress = self.current_surface_drill_progress + 1
			end
			self.last_crafting_progress = self.drill_entity.crafting_progress
			if self.current_surface_drill_progress >= configuration.drilling.Recepies_amount_per_levels then
				self.current_surface_drill_progress = 0
				self.levels_dug = self.levels_dug + 1
				self.digging_state = defines.digging_state.waiting_stabilisation -- one level lower is newly available, we have to stabilize it
			end
		else
			self.digging_state = defines.digging_state.digging_pending
		end
	elseif self.digging_state == defines.digging_state.waiting_stabilisation then
		local last_surface_entity = self.construction_area_entities[#self.construction_area_entities] or self.drill_entity
		local last_dug_surface = custom_surface:get_or_generate_subsurface(last_surface_entity.surface)
		
		local drill_area = {
			left_top = {
				x = self.drill_entity.position.x + self.drill_entity.prototype.collision_box.left_top.x,
				y = self.drill_entity.position.y + self.drill_entity.prototype.collision_box.left_top.y},
			right_bottom = {
			 	x = self.drill_entity.position.x + self.drill_entity.prototype.collision_box.right_bottom.x,
			 	y = self.drill_entity.position.y + self.drill_entity.prototype.collision_box.right_bottom.y}
			}

		if last_dug_surface:is_area_generated(drill_area) then -- the area is gennerated and contains no entity in it
			if not last_dug_surface:clear_area(drill_area, expand_area(drill_area, 0.3)).player_found then

				last_dug_surface.luaSurface.create_entity{name="drilling-work-area", position=self.drill_entity.position, force=self.drill_entity.force}


				if self.levels_dug == self.levels_to_digg then 
					self:handle_finished_digging()
					return true
				else
					local next_surface = custom_surface:get_or_generate_subsurface(last_dug_surface.luaSurface)
					next_surface:request_gen_area(expand_area(drill_area, 1))

					self.digging_state = defines.digging_state.digging_in_progress
				end
			end
		end
	end
	self:update_shown_progress()
end

function surface_driller:destroy()
	--destoy the object (only it does not actually destroys it but remove all reference to it)
	global.events_manager:remove_listener(defines.events.on_tick, self)
	global._surface_driller.surface_drillers[string.format("%s@{%d,%d}", self.drill_entity.surface.name, self.drill_entity.position.x, self.drill_entity.position.y)] = nil

	-- destoy the entities
	if self.description_floating_text and self.description_floating_text.valid then self.description_floating_text.destroy() end
	if self.progression_floating_text and self.progression_floating_text.valid then self.progression_floating_text.destroy() end
	if self.drill_entity and self.drill_entity.valid then self.drill_entity.destroy() end
	for _,entity in ipairs(self.construction_area_entities) do
		if entity.valid then entity.destroy() end
	end
end

function surface_driller:update_shown_progress()
	if self.digging_state ~= self.previous_digging_state then
		if self.description_floating_text and self.description_floating_text.valid then self.description_floating_text.destroy() end
		local position = {x=self.drill_entity.position.x, y=self.drill_entity.position.y - 1.5}
		local desc_text = ""

		if self.digging_state == defines.digging_state.waiting_orders then
			desc_text = "awaiting orders"
			position.x = position.x - 1.8			
		elseif self.digging_state == defines.digging_state.waiting_stabilisation then
			desc_text = "stabilizing hole (" .. self.levels_dug .. "/" .. self.levels_to_digg .. ")"
			position.x = position.x - 2			
		elseif self.digging_state == defines.digging_state.digging_in_progress then
			desc_text = "drilling in progress"
			position.x = position.x - 2.2
		elseif self.digging_state == defines.digging_state.digging_pending then
			desc_text = "drilling paused"
			position.x = position.x - 1.7
		end
		self.description_floating_text = self.drill_entity.surface.create_entity{
	                name='custom-flying-text',
	                position=position,
	                force=self.drill_entity.force,
	                text=desc_text
	                }
		self.description_floating_text.active = false
	end

	if self.progression_floating_text and self.progression_floating_text.valid then self.progression_floating_text.destroy() end

	local position = {x=self.drill_entity.position.x, y=self.drill_entity.position.y - 0.75}
	local progress_text = ""

	if self.digging_state == defines.digging_state.waiting_stabilisation then
		local tick_mod60 = game.tick % 60
		progress_text =  "." .. (tick_mod60 > 20 and "." or "") .. (tick_mod60 > 40 and "." or "")
		position.x = position.x - 0.3	
	elseif self.digging_state == defines.digging_state.digging_in_progress then
		local new_progress = (self.current_surface_drill_progress + self.last_crafting_progress) /configuration.drilling.Recepies_amount_per_levels *100
		progress_text = string.format("%d", new_progress)  .. "%"
		position.x = position.x - 0.2
	end
	self.progression_floating_text = self.drill_entity.surface.create_entity{
                name='custom-flying-text',
                position=position,
                force=self.drill_entity.force,
                text=progress_text
                }
	self.progression_floating_text.active = false
end

function surface_driller:handle_finished_digging()
	player_elevator:new{main_surface = self.drill_entity.surface, position = self.drill_entity.position, depth = self.levels_to_digg}
	self.destroy()
--TODO
end

--- STATIC
function surface_driller:on_robot_built_entity(_event)
	on_built_entity(_event)
end
function surface_driller:on_built_entity(_event)
	local entity = _event.created_entity
	if entity.name == "surface-driller" then
		surface_driller:new{drill_entity = entity}
	end
end
---END STATIC