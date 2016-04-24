require "util"
require "defines"
require "lib"
require "config"

-- require classes
require "events_manager"
require "custom_surface"

function setup()
	-- init classes
	events_manager:setup()
	custom_surface:setup()



	global.events_manager = global.events_manager or events_manager:new()
	global.data = ontick:new()
	global.data:start()


	ontick:init()

	global.onTickFunctions = global.onTickFunctions or {}
	global.elevator_association = global.elevator_association or {}
	global.item_elevator = global.item_elevator or {}
	global.surface_drillers = global.surface_drillers or {}
	global.air_vents = global.air_vents or {}
	global.underground_players = global.underground_players or {}
	global.surface_associations = global.surface_associations or {}
	global.Underground_driving_players = global.Underground_driving_players or {}
	global.fluids_elevator = global.fluids_elevator or {}
	global.waiting_entities = global.waiting_entities or {}
	global.time_spent_dict = global.time_spent_dict or {}
	global.selection_area_markers_per_player = global.selection_area_markers_per_player or {}
	global.marked_for_digging = global.marked_for_digging or {}
	global.digging_pending = global.digging_pending or {}
	global.digging_in_progress = global.digging_in_progress or {}
	global.digging_robots_deployment_centers = global.digging_robots_deployment_centers or {}

	-- move to where I create the first entrance ?
	global.onTickFunctions["teleportation_check"] = teleportation_check
	global.onTickFunctions["move_items"] = move_items
	global.onTickFunctions["fluids_elevator_management"] = fluids_elevator_management -- needed to reset the method and prevent the crash


	--global.onTickFunctions["debug"] = debug
end




ontick = {data = "data"}
function ontick:new(o)
	o = o or {}   -- create object if user does not provide one
	self.__index = self
	setmetatable(o, self)
	return o
end

function ontick:init()
	self.__index = self
	setmetatable(global.data, self)
end

function ontick:on_tick(_event)
	game.player.print(self.data)
	self.data = "on_tick - #" .. game.tick
end

function ontick:start()
	global.events_manager:add_listener(defines.events.on_tick, self)
end



script.on_init(setup)
script.on_load(setup)
script.on_configuration_changed(setup)

-- when an entity is built (to create the tunnel exit)
script.on_event({defines.events.on_built_entity, defines.events.on_robot_built_entity}, function(event) on_built_entity(event) end)

-- when a chunk is generated (to change all tunnel tiles to out-of-map)
script.on_event(defines.events.on_chunk_generated, function(event) on_chunk_generated(event) end)

-- when a item is removed (to know when a wall is removed) /!\ will need to be removed when tiles are set to unminable
script.on_event({defines.events.on_preplayer_mined_item, defines.events.on_entity_died, defines.events.on_robot_pre_mined}, function(event) on_pre_mined_item(event) end)

-- when a item is removed (to know when a wall is removed) /!\ will need to be removed when tiles are set to unminable
script.on_event(defines.events.on_player_driving_changed_state, function(event) on_player_driving_changed_state(event) end)

-- to handle digging automation
script.on_event(defines.events.on_put_item, function(event) on_put_item(event) end)


--debug only -> to add stuff to the player on game start
script.on_event(defines.events.on_player_created,  function (event) startingItems(game.get_player(event.player_index)) end)

script.on_event(defines.events.on_player_rotated_entity, function(event) on_player_rotated_entity(event) end)

script.on_event(defines.events.on_trigger_created_entity, function(event) on_trigger_created_entity(event) end)


script.on_event(defines.events.on_tick, 
	function(event) 
		for name,fun in pairs(global.onTickFunctions) do
			--we pass the name to the function so it can delete itself if it wants to, the function does not remember its own name to prevent closures
			if type(fun) == "function" then fun(name) end
			if type(fun) == "table" and fun.onTick then fun:onTick(name) end
		end
	end)



--[[function debug(function_name)
	local gpp = game.player.print

	local surface = get_subsurface(game.player.surface)

	local chunk_position = to_chunk_position(game.player.position)
	local bottom_left = surface.is_chunk_generated({x=chunk_position.x-1, y=chunk_position.y+1}) and "O" or "X"
	local bottom_center = surface.is_chunk_generated({x=chunk_position.x, y=chunk_position.y+1}) and "O" or "X"
	local bottom_right = surface.is_chunk_generated({x=chunk_position.x+1, y=chunk_position.y+1}) and "O" or "X"
	local center_left = surface.is_chunk_generated({x=chunk_position.x-1, y=chunk_position.y}) and "O" or "X"
	local center_center = surface.is_chunk_generated({x=chunk_position.x, y=chunk_position.y}) and "O" or "X"
	local center_right = surface.is_chunk_generated({x=chunk_position.x+1, y=chunk_position.y}) and "O" or "X"
	local top_left = surface.is_chunk_generated({x=chunk_position.x-1, y=chunk_position.y-1}) and "O" or "X"
	local top_center = surface.is_chunk_generated({x=chunk_position.x, y=chunk_position.y-1}) and "O" or "X"
	local top_right = surface.is_chunk_generated({x=chunk_position.x+1, y=chunk_position.y-1}) and "O" or "X"

	local string = ""
	for x,y in iarea(get_area(chunk_position, 2)) do
		string = string .. string.format("{%d,%d}-%s", x,y, surface.is_chunk_generated({x=x, y=y}) and "O" or "X")
	end
	gpp(string)

	--gpp("chunk position : " .. top_left .. "-" ..top_center .. "-" ..top_right .. " | " .. center_left .. "-" ..center_center .. "-" ..center_right .. " | " .. bottom_left .. "-" ..bottom_center .. "-" ..bottom_right)
	
	return true
end
]]


function on_trigger_created_entity(_event)
	local entity = _event.entity
	if entity.name == "digging-explosion" then
		local wall = entity.surface.find_entity(cavern_Wall_name,entity.position)
		if not wall then entity.destroy()
		else 
			for _,data in ipairs(global.digging_robots_deployment_centers) do
				if data.digging_target_wall == wall then
					global.digging_in_progress[entity.surface.name][string.format("{%d,%d}", math.floor(data.digging_target.x), math.floor(data.digging_target.y))] = nil
					data.deployed_unit.destroy()
					wall.die()
				end
			end
		end
	end
end

-- Manage when more than on deployment center is in use
function digging_robots_manager(function_name)
	for id,data in ipairs(global.digging_robots_deployment_centers) do
		if (game.tick + id) % #global.digging_robots_deployment_centers then

		if data.deployment_center.valid then
			if global.digging_pending[data.deployment_center.surface.name] then
				if not(data.deployed_unit) then
					if data.deployment_center.get_inventory(defines.inventory.assembling_machine_output).get_item_count("prepared-digging-robots") >= 1 then
						data.search_result_data = find_nearest_marked_for_digging(data.deployment_center.position, data.deployment_center.surface, data.search_result_data)
						if data.search_result_data and data.search_result_data.finished then
							data.digging_target = data.search_result_data.position
							global.digging_in_progress[data.deployment_center.surface.name][string.format("{%d,%d}", math.floor(data.digging_target.x), math.floor(data.digging_target.y))] = true
							data.deployment_center.surface.create_entity{name = "selection-marker", position = data.digging_target, force=data.deployment_center.force}
							-- deploy digger
							local entity_name = "digging-robot"
							local deployment_position = data.deployment_center.surface.find_non_colliding_position(entity_name, data.deployment_center.position, 5, 0.1)
							data.digging_target_wall = data.deployment_center.surface.find_entity(cavern_Wall_name,{x = math.floor(data.digging_target.x) + 0.5, y = math.floor(data.digging_target.y) + 0.5})
							if deployment_position then
								data.deployed_unit = data.deployment_center.surface.create_entity{
									name=entity_name, 
									position=deployment_position,
									force=data.deployment_center.force}
								data.deployment_center.get_inventory(defines.inventory.assembling_machine_output).remove({name="prepared-digging-robots", count=1})
								data.deployed_unit.set_command({type=defines.command.attack, target=data.digging_target_wall, distraction=defines.distraction.none})
							end
						end
					end
				else
					if not data.deployed_unit.valid then
						data.deployed_unit = nil
					end
				end
			end

		else
			table.remove(global.digging_robots_deployment_centers, id)
		end

		end
	end
	if #global.digging_robots_deployment_centers == 0 then
		global.onTickFunctions[function_name] = nil
	end
end

function on_put_item(event)
	local player = game.get_player(event.player_index)
    local item = player.cursor_stack
	local position = event.position
	if item.valid_for_read and item.name == "digging-planner" then 
		if global.selection_area_markers_per_player[event.player_index] == nil then
			if is_subsurface(player.surface) then 
				local entity = player.surface.create_entity{name = "selection-marker", position = position, force=player.force}
				global.selection_area_markers_per_player[event.player_index] = entity
				global.onTickFunctions["digging_planner_check"] = digging_planner_check
			end
		else -- secound marker => the area has been selected
			local marker_one_position = global.selection_area_markers_per_player[event.player_index].position
			local selected_area = {left_top = {}, right_bottom = {}}
			if marker_one_position.x < position.x then
				selected_area.left_top.x = marker_one_position.x
				selected_area.right_bottom.x = position.x
			else
				selected_area.left_top.x = position.x
				selected_area.right_bottom.x = marker_one_position.x
			end
			if marker_one_position.y < position.y then
				selected_area.left_top.y = marker_one_position.y
				selected_area.right_bottom.y = position.y
			else
				selected_area.left_top.y = position.y
				selected_area.right_bottom.y = marker_one_position.y
			end
			global.selection_area_markers_per_player[event.player_index].destroy()
			global.selection_area_markers_per_player[event.player_index] = nil

			for x,y in iarea(selected_area) do
				if player.surface.get_tile(x, y).name == "out-of-map" then
					if global.marked_for_digging[string.format("%s&@{%d,%d}", player.surface.name, math.floor(x), math.floor(y))] == nil then
						local marking_entity = player.surface.create_entity{name = "digging-marker", position = {x = x, y = y}, force=game.forces.neutral}
						global.marked_for_digging[string.format("%s&@{%d,%d}", marking_entity.surface.name, math.floor(x), math.floor(y))] = marking_entity
					end
				elseif player.surface.get_tile(x, y).name == "cave-walls" then
					if global.digging_pending[player.surface.name] == nil then global.digging_pending[player.surface.name] = {} end
					if global.digging_pending[player.surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] == nil then 
						local pending_entity = player.surface.create_entity{name = "pending-digging", position = {x = x, y = y}, force=game.forces.neutral}
						global.digging_pending[player.surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] = pending_entity
					end
				end
			end
		end

	end
end

function digging_planner_check(function_name)
	for player_index, entity in ipairs(global.selection_area_markers_per_player) do
		local player = game.get_player(player_index)
		if entity.valid then
			if not player.cursor_stack.valid_for_read or player.cursor_stack.name ~= "digging-planner" or player.surface ~= entity.surface then 
				global.selection_area_markers_per_player[player_index].destroy()
				global.selection_area_markers_per_player[player_index] = nil
			end
		else
			global.selection_area_markers_per_player[player_index] = nil
		end
	end
	if associative_table_count(global.selection_area_markers_per_player) == 0 then
		global.onTickFunctions[function_name] = nil
	end
end


function check_waiting_entities(function_name)
	for id, entitypair in ipairs(global.waiting_entities) do
		if entitypair.entity.valid then
			local entity = entitypair.entity
			local icon = entitypair.icon
			local entity_collision_box = entity.prototype.collision_box
			local entity_area = {}
			entity_area.left_top = {x = entity.position.x + entity_collision_box.left_top.x, y = entity.position.y + entity_collision_box.left_top.y}
			entity_area.right_bottom = {x = entity.position.x + entity_collision_box.right_bottom.x, y = entity.position.y + entity_collision_box.right_bottom.y}
			if game.tick % 60 == 0 then
				if icon.valid then
					icon.destroy()
				else
					icon = entity.surface.create_entity{name = "boring-in-progress", position = {x = entity.position.x, y = entity.position.y -0.25}, force=entity.force}
					entitypair.icon = icon
				end
			end
			if is_area_gen(entity_area, get_complementary_surface(entity)) then
				local complementary_entity = place_complementary_entity(entity)
				add_association_data(entity, complementary_entity)
				if icon.valid then
					icon.destroy()
				end
				global.waiting_entities[id] = nil
			end
		else
			local icon = entitypair.icon
			if icon.valid then
				icon.destroy()
			end
			global.waiting_entities[id] = nil
		end
	end
	if associative_table_count(global.waiting_entities) == 0 then
		global.onTickFunctions[function_name] = nil
	end
end

function add_association_data(_entity, _complementary_entity)
	if _entity.name == "fluid-elevator-mk1" then 
		local data = {}
		if _entity.direction < 4 then
			data.top_entity = _entity
			data.bottom_entity = _complementary_entity
		else
			data.bottom_entity = _entity
			data.top_entity = _complementary_entity
		end
		table.insert(global.fluids_elevator, data)

		if not global.onTickFunctions["fluids_elevator_management"] then
			global.onTickFunctions["fluids_elevator_management"] = fluids_elevator_management
		end

	elseif string.find(_entity.name, "independant%-item%-elevator") then
		add_elevators = function (_entity)
			if string.find(_entity.name, "upperside") then
				if _entity.direction == defines.direction.north then
					input_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x - 0.5, y = _entity.position.y + 0.5}, force=_entity.force}
					output_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x + 0.5, y = _entity.position.y - 0.5}, force=_entity.force}
				elseif _entity.direction == defines.direction.east then
					input_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x + 0.5, y = _entity.position.y + 0.5}, force=_entity.force}
					output_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x - 0.5, y = _entity.position.y - 0.5}, force=_entity.force}
				elseif _entity.direction == defines.direction.south then
					input_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x + 0.5, y = _entity.position.y - 0.5}, force=_entity.force}
					output_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x - 0.5, y = _entity.position.y + 0.5}, force=_entity.force}
				elseif _entity.direction == defines.direction.west then
					input_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x - 0.5, y = _entity.position.y - 0.5}, force=_entity.force}
					output_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x + 0.5, y = _entity.position.y + 0.5}, force=_entity.force}
				end
			else -- if string.find(_entity.name, "lowerside")
				if _entity.direction == defines.direction.north then
					output_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x - 0.5, y = _entity.position.y - 0.5}, force=_entity.force}
					input_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x + 0.5, y = _entity.position.y + 0.5}, force=_entity.force}
				elseif _entity.direction == defines.direction.east then
					output_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x - 0.5, y = _entity.position.y + 0.5}, force=_entity.force}
					input_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x + 0.5, y = _entity.position.y - 0.5}, force=_entity.force}
				elseif _entity.direction == defines.direction.south then
					output_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x + 0.5, y = _entity.position.y + 0.5}, force=_entity.force}
					input_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x - 0.5, y = _entity.position.y - 0.5}, force=_entity.force}
				elseif _entity.direction == defines.direction.west then
					output_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x + 0.5, y = _entity.position.y - 0.5}, force=_entity.force}
					input_item_elevator = _entity.surface.create_entity{name = "fast-transport-belt", position = {x = _entity.position.x - 0.5, y = _entity.position.y + 0.5}, force=_entity.force}
				end
			end
			input_item_elevator.destructible = false
			input_item_elevator.minable = false
			input_item_elevator.rotatable = false
			input_item_elevator.direction = _entity.direction
			output_item_elevator.destructible = false
			output_item_elevator.minable = false
			output_item_elevator.rotatable = false
			output_item_elevator.direction = _entity.direction
			return input_item_elevator, output_item_elevator
		end

		input1, output1 = add_elevators(_entity)
		input_complementary, output_complementary = add_elevators(_complementary_entity)

		local surface = string.find(_entity.name, "upperside") and _entity.surface or _complementary_entity.surface
		local subsurface = string.find(_entity.name, "lowerside") and  _complementary_entity.surface or _entity.surface

		global.item_elevator[string.format("%s&%s@{%d,%d}&{%d,%d}", 
				surface.name, 
				subsurface.name, 
				input1.position.x, 
				input1.position.y,
				output_complementary.position.x, 
				output_complementary.position.y)] = {input = input1,   output = output_complementary}
		global.item_elevator[string.format("%s&%s@{%d,%d}&{%d,%d}", 
				surface.name, 
				subsurface.name, 
				input_complementary.position.x, 
				input_complementary.position.y,
				output1.position.x, 
				output1.position.y)] = {input = input_complementary,   output = output1}
	end

	
end

function is_area_gen(_area, _surface)
	if is_subsurface(_surface) then
		_area = expand_area(_area, 1)
	end
	chunk_area = {left_top = to_chunk_position(_area.left_top), right_bottom = to_chunk_position(_area.right_bottom)}
	for x,y in iarea(chunk_area) do
		if not _surface.is_chunk_generated({x=x, y=y}) then
			return false
		end
	end
	return true
end

function get_complementary_surface(_entity)
	local complementary_surface
	if _entity.name == "fluid-elevator-mk1" then 
		if _entity.direction < 4 then
			complementary_surface = get_subsurface(_entity.surface)
		else
			complementary_surface = get_oversurface(_entity.surface)
		end
	elseif string.find(_entity.name, "independant%-item%-elevator") then
		if string.find(_entity.name, "upperside") then
			complementary_surface = get_subsurface(_entity.surface)
		else -- if string.find(_entity.name, "lowerside")
			complementary_surface = get_oversurface(_entity.surface)
		end
	else
		error("[[Subsurface] get_complementary_surface] error, entity not known : " .. _entity.name)
		return nil
	end

	return complementary_surface
end

function place_complementary_entity(_entity)
	local complementary_entity
	if _entity.name == "fluid-elevator-mk1" then 
		local complementary_surface = get_complementary_surface(_entity)

		clear_subsurface(complementary_surface, _entity.position, 2, 1)

		complementary_entity = complementary_surface.create_entity{name = "fluid-elevator-mk1", position = _entity.position, force=_entity.force}
		complementary_entity.direction = (_entity.direction + 4) % 8

	elseif string.find(_entity.name, "independant%-item%-elevator") then
		local complementary_entity_name
		local complementary_surface
		if string.find(_entity.name, "upperside") then
			complementary_entity_name = "independant-item-elevator-lowerside"
			complementary_surface = get_subsurface(_entity.surface)
		else -- if string.find(_entity.name, "lowerside")
			complementary_entity_name = "independant-item-elevator-upperside"
			complementary_surface = get_oversurface(_entity.surface)
		end

		clear_subsurface(complementary_surface, _entity.position, 1.5, 0.5)

		complementary_entity = complementary_surface.create_entity{name = complementary_entity_name, position = _entity.position, force=_entity.force}
		complementary_entity.direction = _entity.direction

	else
		error("[place_complementary_entity] error, entity not known " .. _entity.name)
		return nil
	end
	return complementary_entity
end

function fluids_elevator_management(function_name)
	for id, fluid_elevator_data in ipairs(global.fluids_elevator) do
		local top_entity = fluid_elevator_data.top_entity
		local bottom_entity = fluid_elevator_data.bottom_entity

		if not (top_entity.valid and bottom_entity.valid) then
			if top_entity.valid then top_entity.destroy() end
			if bottom_entity.valid then bottom_entity.destroy() end
			global.fluids_elevator[id] = nil
		else
			if #top_entity.fluidbox == #bottom_entity.fluidbox then
				for i=1,#top_entity.fluidbox do
					local fluid = {}
					local valid = false
					if top_entity.fluidbox[i] and not bottom_entity.fluidbox[i] then
						fluid = top_entity.fluidbox[i]
						fluid.amount = fluid.amount/2
						valid = true
					elseif bottom_entity.fluidbox[i] and not top_entity.fluidbox[i] then
						fluid = bottom_entity.fluidbox[i]
						fluid.amount = fluid.amount/2
						valid = true
					elseif top_entity.fluidbox[i] and bottom_entity.fluidbox[i] then
						if top_entity.fluidbox[i].type == bottom_entity.fluidbox[i].type then
							fluid = bottom_entity.fluidbox[i]
							fluid.amount = (top_entity.fluidbox[i].amount + bottom_entity.fluidbox[i].amount)/2
							valid = true
						else -- if top_entity.fluidbox[i].type ~= bottom_entity.fluidbox[i].type then
							if (not (top_entity.fluidbox[i].amount < 0.5)) == (bottom_entity.fluidbox[i].amount < 0.5) then --XOR
								fluid = (top_entity.fluidbox[i].amount > bottom_entity.fluidbox[i].amount) and top_entity.fluidbox[i] or bottom_entity.fluidbox[i]
								fluid.amount = fluid.amount/2
								valid = true
							end
						end
					end
					if valid then
						top_entity.fluidbox[i] = fluid
						bottom_entity.fluidbox[i] = fluid
					end
				end
			end
		end
	end
	if associative_table_count(global.fluids_elevator) == 0 then
		global.onTickFunctions[function_name] = nil
	end
end


function on_player_driving_changed_state(event)
	local player = game.players[event.player_index]
	if is_subsurface(player.surface) then
		if player.driving then 
			global.Underground_driving_players[event.player_index] = player

			global.onTickFunctions["boring"] = boring
		else
			global.Underground_driving_players[event.player_index] = nil

			if associative_table_count(global.Underground_driving_players) == 0 then
				global.onTickFunctions["boring"] = nil
			end
		end
	end
end

function boring(function_name)
	for _,player in pairs(global.Underground_driving_players) do
		for _,entity in ipairs(player.surface.find_entities(get_area(player.position, 10))) do
			if entity.type == "decorative" then 
				entity.destroy()
			end
		end
		if player.driving and player.vehicle.name == "mobile-borer" then
			local surface = player.surface
			local vehicule_orientation = player.vehicle.orientation

			local driller_collision_box = player.vehicle.prototype.collision_box
			local center_big_excavation = move_towards_continuous(player.vehicle.position, vehicule_orientation, -driller_collision_box.left_top.y)
			local center_small_excavation = move_towards_continuous(center_big_excavation, vehicule_orientation, 1.7)
			local speed_test_position = move_towards_continuous(center_small_excavation, vehicule_orientation, 1.5)

			local walls_dug = clear_subsurface(surface, center_small_excavation, 1, nil)
			walls_dug = walls_dug + clear_subsurface(surface, center_big_excavation, 2, nil)

			if walls_dug > 0 then 
				local stack = {name = "stone", count = 2 * walls_dug}
				local actually_inserted = player.vehicle.insert(stack) 
				if actually_inserted ~= stack.count then 
					stack.count = stack.count - actually_inserted
					surface.spill_item_stack(player.vehicle.position, stack)
				end
			end

			local speed_test_tile = surface.get_tile(speed_test_position.x, speed_test_position.y)
			if player.vehicle.friction_modifier ~= 4 and player.vehicle.speed >0 and (speed_test_tile.name == "out-of-map" or speed_test_tile.name == "cave-walls") then
				player.vehicle.friction_modifier = 4
			end
			if player.vehicle.friction_modifier ~= 1 and not(player.vehicle.speed >0 and (speed_test_tile.name == "out-of-map" or speed_test_tile.name == "cave-walls")) then
				player.vehicle.friction_modifier = 1
			end
		end
	end
end

function pollution_moving(function_name)

	for _,entitydata in pairs(global.air_vents) do
		local entity = entitydata.entity
		local subsurface = get_subsurface(entity.surface)

		if entitydata.active then
			if entity.name == "active-air-vent" then
				if entity.energy > 0 then
					local current_energy = entity.energy
					entity.energy = 1000000000
					local max_energy = entity.energy
					max_movable_pollution = current_energy / max_energy * max_pollution_move_active -- how much polution can be moved with the current available

					local pollution_to_move = subsurface.get_pollution(entity.position)
					if pollution_to_move > max_movable_pollution then 
						pollution_to_move = max_movable_pollution
					end
					--entity.energy = entity.energy - ((pollution_to_move / max_pollution_move_active)*max_energy)
					subsurface.pollute(entity.position, -pollution_to_move)
					entity.surface.pollute(entity.position, pollution_to_move)
					
					if pollution_to_move > 0 then
						entity.active = true
						if game.tick % 10 == 0 then
							entity.surface.create_entity{name="smoke-custom", position={x = entity.position.x+0.25, y = entity.position.y+1}, force=game.forces.neutral}
						end
					else
						entity.active = false
					end

				end
			elseif entity.name == "air-vent" then

				local pollution_surface = entity.surface.get_pollution(entity.position)
				local pollution_subsurface = subsurface.get_pollution(entity.position)
				local diff = pollution_surface - pollution_subsurface

				if math.abs(diff) > max_pollution_move_passive then
					diff = diff / math.abs(diff) * max_pollution_move_passive
				end

				if diff < 0 and game.tick % 10 == 0  then
					entity.surface.create_entity{name="smoke-custom", position={x = entity.position.x, y = entity.position.y+1}, force=game.forces.neutral}
				end

				entity.surface.pollute(entity.position, -diff)
				subsurface.pollute(entity.position, diff)
			end
		else
			local chunk_position = to_chunk_position(entity.position)
			entitydata.active = subsurface.is_chunk_generated(chunk_position)
		end
	end
end

function pollution_killing_subsurface(function_name)
	for player_name, apnea_data in pairs(global.underground_players) do
		if apnea_data.player.connected then
			local modifier
			if is_subsurface(apnea_data.player.surface) then
				if apnea_data.player.surface.get_pollution(apnea_data.player.position) >= apnea_threshold then
					modifier = 1
				else
					modifier = 0
				end
			else
				modifier = -1
			end
			apnea_data.gui_element.airbar.value = apnea_data.gui_element.airbar.value - (modifier/max_apnea_time)
			apnea_data.gui_element.airbar.value = (apnea_data.gui_element.airbar.value <0) and 0 or (apnea_data.gui_element.airbar.value > 1) and 1 or apnea_data.gui_element.airbar.value
			if apnea_data.gui_element.airbar.value >= 1 and not is_subsurface(apnea_data.player.surface) then
				apnea_data.gui_element.destroy();
				global.underground_players[player_name] = nil
			elseif apnea_data.gui_element.airbar.value <= 0 and (game.tick %60) == 0 then
				apnea_data.player.character.damage(apnea_damage, game.forces.neutral, "poison")
				if not apnea_data.player.character then
					apnea_data.gui_element.destroy();
					global.underground_players[player_name] = nil
				end
			end
		end
	end
	if associative_table_count(global.underground_players) == 0 then
		global.onTickFunctions[function_name] = nil
	end
end



function move_items(function_name)
	for key,elevator in pairs(global.item_elevator) do
		if not(elevator.input.valid and elevator.output.valid) then
			if elevator.input.valid then elevator.input.destroy() end
			if elevator.output.valid then elevator.output.destroy() end
		elseif elevator.input.active or elevator.output.active then
			for laneI=1,2 do
				lane_input = elevator.input.get_transport_line(laneI)
				lane_output = elevator.output.get_transport_line(laneI)
				if lane_input.get_item_count() > 0 and lane_output.can_insert_at_back() then
					local item_to_move = {name = "", count = 1}
					for name, count in pairs(lane_input.get_contents()) do
						item_to_move.name = name
						break
					end
					lane_input.remove_item(item_to_move)
					lane_output.insert_at_back(item_to_move)
				end
			end
		end
	end
end

function teleportation_check(function_name)
	--proximity test done only every 10 ticks (the player has to wait 120 ticks to transport, 10 more should'nt kill him)
	if game.tick % 10 == 0 then
		for _, player in ipairs(game.players) do
			if not KeyExists(global.time_spent_dict, player.name) then -- only initiate his transportation if he's not already transporting
				if not player.walking_state.walking then -- only transport a non walking player
					local position = player.position
					local search_area = {left_top = {x = position.x - 0.5, y = position.y - 0.5}, right_bottom = {x = position.x + 0.5, y = position.y + 0.5}}
					
					local entities = player.surface.find_entities(search_area)

					for _,entity in ipairs(entities) do -- if there is an entrance close by
						connected_entity = get_player_elevator_linked_to(entity)
						if connected_entity then
							-- create the progressbar (and what goes with it)
							player.gui.center.add{type="frame", name="teleportation_progress_bar_container", direction="vertical", caption="You are being transported to your tunnel\r\n(move to cancel)"}
							local progressbar_container = player.gui.center.teleportation_progress_bar_container
							progressbar_container.add{type="progressbar", name="progressbar", size = 120}

							-- add the player and some information to the list of transporting people
							global.time_spent_dict[player.name] = {player = player, destination_entity = connected_entity, time_spent = 0, gui_element = progressbar_container}
							global.onTickFunctions["temp_teleportation_check"] = temp_teleportation_check
						end
					end
				end
			end
		end
	end
end

function get_player_elevator_linked_to(entity)

	for _, elevator_association in pairs(global.elevator_association) do
		if entity == elevator_association.surface_elevator.player_elevator then 
			return elevator_association.subsurface_elevator.player_elevator
		end
		if entity == elevator_association.subsurface_elevator.player_elevator then 
			return elevator_association.surface_elevator.player_elevator
		end
	end
end


function temp_teleportation_check(fct_name)

	for player_name, data in pairs(global.time_spent_dict) do
		local stop_teleportation

		data.time_spent = data.time_spent + 1
		local player = data.player
		local time_spent = data.time_spent
		local gui_element = data.gui_element


		if player.walking_state.walking or not data.destination_entity then -- if the player started to move, cancel the teleportation
			stop_teleportation = true
		else
			gui_element.progressbar.value = time_spent / teleportation_time

			if time_spent >= teleportation_time then
				local destination_surface = data.destination_entity.surface
				-- add to the distance 
				player.teleport(get_safe_position(data.destination_entity.position, player.position),destination_surface)
				stop_teleportation = true

				if is_subsurface(destination_surface) and not global.underground_players[player.name] then
					-- add progress bar representing the amount of air the player has
					player.gui.left.add{type="table", name="air_bar_container", colspan = 2}
					local air_bar_container = player.gui.left.air_bar_container
					air_bar_container.add{type="label", name="airbar_label", caption = "air left : "}
					air_bar_container.add{type="progressbar", name="airbar", size = 120}
					air_bar_container.airbar.value = 1
					global.underground_players[player.name] = {player = player, gui_element = air_bar_container}	
					global.onTickFunctions["pollution_killing_subsurface"] = pollution_killing_subsurface
				end

				--local chunk_position = to_chunk_position(player.position)
				--[[ shouldn't be usefull anymore as if the surface is not generated, we should never get here
				if Tunnel_1.is_chunk_generated(chunk_position) and not generating then -- if the map is still generating, the player could get killed by being on a tile switching to "out-of-map"
					-- TODO : add a little bit of distance to avoid being transported back to nauvis
					player.teleport(player.position,Tunnel_1)
					stop_teleportation = true
				end]]
			end
		end
		if stop_teleportation then
			global.time_spent_dict[player_name] = nil
			gui_element.destroy()

			if associative_table_count(global.time_spent_dict) == 0 then
				global.onTickFunctions[fct_name] = nil
			end
		end
	end
end

function on_tick_drilling(function_name)
	local drillings_needed = 1

	for key, drilling_data in pairs(global.surface_drillers) do
		if drilling_data.drilling_performed ~= drillings_needed then -- if the drillings are not over
			-- floating text drilling state
			if drilling_data.last_crafting_progress == drilling_data.entity.crafting_progress and drilling_data.state_active then 
				drilling_data.state_active = false
				local desc = drilling_data.entity.surface.create_entity{
	                name='custom-flying-text',
	                position={x = drilling_data.entity.position.x -1.7,y = drilling_data.entity.position.y -1.5},
	                force=drilling_data.entity.force,
	                text="drilling paused" 
	                }
				desc.active = false
				drilling_data.description_floating_text.destroy()
				drilling_data.description_floating_text = desc
			elseif drilling_data.last_crafting_progress ~= drilling_data.entity.crafting_progress and not drilling_data.state_active then
				drilling_data.state_active = true
				local desc = drilling_data.entity.surface.create_entity{
	                name='custom-flying-text',
	                position={x = drilling_data.entity.position.x -2.2,y = drilling_data.entity.position.y -1.5},
	                force=drilling_data.entity.force,
	                text="drilling in progress" 
	                }
				desc.active = false
				drilling_data.description_floating_text.destroy()
				drilling_data.description_floating_text = desc
			end

			-- floating text progress %
			local new_progress = (drilling_data.drilling_performed + drilling_data.last_crafting_progress) /drillings_needed *100
			if new_progress ~= drilling_data.progress then 
				drilling_data.progress = new_progress
				local progress = drilling_data.entity.surface.create_entity{
	                name='custom-flying-text',
	                position={x= drilling_data.entity.position.x - 0.30,y= drilling_data.entity.position.y -0.75},
	                force=drilling_data.entity.force,
	                text=string.format("%d", new_progress)  .. "%"
	                }
				progress.active = false
				drilling_data.progression_floating_text.destroy()
				drilling_data.progression_floating_text = progress
			end



			if drilling_data.entity.crafting_progress < drilling_data.last_crafting_progress then -- the recipe has been completed
				drilling_data.drilling_performed = drilling_data.drilling_performed + 1
			end
			drilling_data.last_crafting_progress = drilling_data.entity.crafting_progress

		else -- if drilling is over
			if drilling_data.entity.active then -- drilling is done
				drilling_data.entity.active = false
		        local desc = drilling_data.entity.surface.create_entity{
	                name='custom-flying-text',
	                position={x = drilling_data.entity.position.x -1.8,y = drilling_data.entity.position.y -1.5},
	                force=drilling_data.entity.force,
	                text="stabilizing hole" 
	                }
				desc.active = false
				drilling_data.description_floating_text.destroy()
				drilling_data.description_floating_text = desc
		    end
			local tick_mod60 = game.tick % 60
			local progress = drilling_data.entity.surface.create_entity{
                name='custom-flying-text',
                position={x= drilling_data.entity.position.x - 0.20,y= drilling_data.entity.position.y -0.50},
                force=drilling_data.entity.force,
                text= "." .. (tick_mod60 > 20 and "." or "") .. (tick_mod60 > 40 and "." or "")
                }
			progress.active = false
			drilling_data.progression_floating_text.destroy()
			drilling_data.progression_floating_text = progress

		    if can_place_surface_elevator(get_subsurface(drilling_data.entity.surface), drilling_data.entity.position) then
				drilling_data.progression_floating_text.destroy()
				drilling_data.description_floating_text.destroy()

				place_surface_elevator(drilling_data.entity.surface, get_subsurface(drilling_data.entity.surface), drilling_data.entity.position, drilling_data.entity.force)
				drilling_data.entity.destroy()
		    	-- remove entity

		    	global.surface_drillers[key] = nil

		    	local count = 0
  				for _ in pairs(global.surface_drillers) do count = count + 1 end
				if count == 0 then 
					global.onTickFunctions[function_name] = nil
				end
		    end
		end
	end
end

function can_place_surface_elevator(_surface, _position)
	local chunk_position = to_chunk_position(_position)
	local clear_tunnel_size = math.ceil(elevator_size /2) + 1
	for x,y in iarea(get_area(chunk_position, math.ceil(clear_tunnel_size / 32) +1)) do
		if not _surface.is_chunk_generated({x=x, y=y}) then
			return false
		end
	end
	return true
end

function get_subsurface(_surface)
	if global.surface_associations[_surface.name] then -- if the subsurface already exist
		return game.get_surface(global.surface_associations[_surface.name])
	else -- we need to create the subsurface (pattern : subsurface_<surface_name>_<subsurface_number> - for sub_subsurface, the number is incressed)
		local subsurface_name = ""
		if is_subsurface(_surface) then
			local regex = "^subsurface_(.+)_(%d+)$"
			local subsurface_number
			_, _,surface_name, subsurface_number = string.find(_surface.name, regex)
			subsurface_name = "subsurface_" .. surface_name .. "_" .. (subsurface_number+1)
		else
			subsurface_name = "subsurface_" .. _surface.name .. "_1"
		end
		if not game.surfaces[subsurface_name] then
			game.create_surface(subsurface_name)
		end
		local subsurface = game.get_surface(subsurface_name)
		global.surface_associations[_surface.name] = subsurface.name
		return subsurface
	end
end

function get_oversurface(_subsurface)
	if not is_subsurface(_subsurface) then return nil end
	for surface_name,subsurface_name in pairs(global.surface_associations) do
		if subsurface_name == _subsurface.name then
			return game.get_surface(surface_name)
		end
	end
end

function is_subsurface(_surface)
	local i, _ = string.find(_surface.name, "subsurface")
	if i == 1 then -- who knows it could be another surface which happens to have the same pattern
		for surface_name,subsurface_name in pairs(global.surface_associations) do
			if subsurface_name == _surface.name then
				return true
			end
		end
	end
	return false
end

function place_surface_elevator(_surface, _subsurface, _position, _force)
	if not can_place_surface_elevator(_subsurface, _position) then return end

	local clear_tunnel_size = math.ceil(elevator_size /2) + 1
	-- clean all other entities ?
	clear_subsurface(_subsurface, _position, clear_tunnel_size, 1.5)--elevator_size/2)

	local surface_player_elevator = _surface.create_entity{name = "tunnel-entrance", position = _position, force=_force}

	local surface_linked_belt_bottom = _surface.create_entity{name = "fast-transport-belt", position = {x = _position.x, y = _position.y + 1}, force=_force}
	local surface_linked_belt_top    = _surface.create_entity{name = "fast-transport-belt", position = {x = _position.x, y = _position.y - 1}, force=_force}
	local surface_linked_belt_right  = _surface.create_entity{name = "fast-transport-belt", position = {x = _position.x + 1, y = _position.y}, force=_force}
	local surface_linked_belt_left   = _surface.create_entity{name = "fast-transport-belt", position = {x = _position.x - 1, y = _position.y}, force=_force}
	surface_linked_belt_bottom.direction = defines.direction.north
	surface_linked_belt_top.direction    = defines.direction.south
	surface_linked_belt_right.direction  = defines.direction.east
	surface_linked_belt_left.direction   = defines.direction.west


	
	local subsurface_player_elevator = _subsurface.create_entity{name = "tunnel-exit", position = _position, force=_force}
	
	local subsurface_linked_belt_bottom = _subsurface.create_entity{name = "fast-transport-belt", position = {x = _position.x, y = _position.y + 1}, force=_force}
	local subsurface_linked_belt_top    = _subsurface.create_entity{name = "fast-transport-belt", position = {x = _position.x, y = _position.y - 1}, force=_force}
	local subsurface_linked_belt_right  = _subsurface.create_entity{name = "fast-transport-belt", position = {x = _position.x + 1, y = _position.y}, force=_force}
	local subsurface_linked_belt_left   = _subsurface.create_entity{name = "fast-transport-belt", position = {x = _position.x - 1, y = _position.y}, force=_force}
	subsurface_linked_belt_bottom.direction = defines.direction.south
	subsurface_linked_belt_top.direction    = defines.direction.north
	subsurface_linked_belt_right.direction  = defines.direction.west
	subsurface_linked_belt_left.direction   = defines.direction.east

	-- linking belts elevators
	global.item_elevator[string.format("%s&%s@{%d,%d}", _surface.name, _subsurface.name, surface_linked_belt_bottom.position.x, surface_linked_belt_bottom.position.y)] = {input = surface_linked_belt_bottom,   output = subsurface_linked_belt_bottom}
	global.item_elevator[string.format("%s&%s@{%d,%d}", _surface.name, _subsurface.name, surface_linked_belt_top.position.x,    surface_linked_belt_top.position.y)]    = {input = surface_linked_belt_top,      output = subsurface_linked_belt_top}
	global.item_elevator[string.format("%s&%s@{%d,%d}", _surface.name, _subsurface.name, surface_linked_belt_right.position.x,  surface_linked_belt_right.position.y)]  = {input = subsurface_linked_belt_right, output = surface_linked_belt_right}
	global.item_elevator[string.format("%s&%s@{%d,%d}", _surface.name, _subsurface.name, surface_linked_belt_left.position.x,   surface_linked_belt_left.position.y)]   = {input = subsurface_linked_belt_left,  output = surface_linked_belt_left}

	-- linking player elevators
	local elevator_assoc = {
		surface_elevator = {
			player_elevator = surface_player_elevator,
			items_elevators = {
				surface_linked_belt_bottom,
				surface_linked_belt_top,
				surface_linked_belt_right,
				surface_linked_belt_left,
			}
		},
		subsurface_elevator = {
			player_elevator = subsurface_player_elevator,
			items_elevators = {
				subsurface_linked_belt_bottom,
				subsurface_linked_belt_top,
				subsurface_linked_belt_right,
				subsurface_linked_belt_left,
			}
		}
	}
	global.elevator_association[string.format("%s&%s@{%d,%d}", _surface.name, _subsurface.name, _position.x, _position.y)] = elevator_assoc

	-- freeze modifications on items elevator
	for _,belt in ipairs(elevator_assoc.surface_elevator.items_elevators) do
		belt.destructible = false
		belt.minable = false
		belt.rotatable = false
	end	
	for _,belt in ipairs(elevator_assoc.subsurface_elevator.items_elevators) do
		belt.destructible = false
		belt.minable = false
		belt.rotatable = false
	end
	
	-- linking electricity
	surface_player_elevator.connect_neighbour(subsurface_player_elevator)
	surface_player_elevator.connect_neighbour{wire = defines.circuitconnector.red,   target_entity = subsurface_player_elevator}
	surface_player_elevator.connect_neighbour{wire = defines.circuitconnector.green, target_entity = subsurface_player_elevator}
end

function remove_surface_player_elevator(_entity, _player) -- _player is the player to which insert the content of the belts
	local connected_entity = get_player_elevator_linked_to(_entity)
	local position = _entity.position
	local surface_name = _entity.surface.name
	local subsurface_name = connected_entity.surface.name


	-- find corresponding elevator
	local current_association = global.elevator_association[string.format("%s&%s@{%d,%d}", surface_name, subsurface_name, position.x, position.y)] 
	if not current_association then -- surface_name and subsurface_name are inverted
		local temp = surface_name
		surface_name = subsurface_name
		subsurface_name = temp
		current_association = global.elevator_association[string.format("%s&%s@{%d,%d}", surface_name, subsurface_name, position.x, position.y)]
	end

	-- stop all current tp concerning the entity
	for player_name, data in pairs(global.time_spent_dict) do
		if data.destination_entity == connected_entity or data.destination_entity == _entity then
			data.destination_entity = nil
		end
	end

	--_entity.destroy()
	connected_entity.destroy()

	for _,belt in ipairs(current_association.surface_elevator.items_elevators) do
		local key_string = string.format("%s&%s@{%d,%d}", surface_name, subsurface_name, belt.position.x, belt.position.y)
		elevator = global.item_elevator[key_string]
		if elevator then
			elevator.input.destroy()
			elevator.output.destroy()
			global.item_elevator[key_string] = nil
		end
	end

	global.elevator_association[string.format("%s&%s@{%d,%d}", surface_name, subsurface_name, position.x, position.y)] = nil
end
		    	

-- if the chunk generated is a chunk of the tunnels, change all tiles to out_of-map tiles (-> not accessible and not on the map)
function on_chunk_generated(event)

	local surface = event.surface
	local area = event.area
	if is_subsurface(surface) then
		local newTiles = {}
		for x, y in iarea(area) do
			table.insert(newTiles, {name = "out-of-map", position = {x, y}})
		end
		surface.set_tiles(newTiles)
	end
end

-- when a wall has been removed
function on_subsurface_wall_mined(wall_entity, surface)
	clear_subsurface(surface, wall_entity.position, 1, nil)
end

-- when a building has been removed (to check when a wall is removed)
function on_pre_mined_item(event)
	local entity = event.entity
	local surface = entity.surface

	if event.entity.name == cavern_Wall_name then
		on_subsurface_wall_mined(entity, surface)
	elseif event.entity.name == "tunnel-entrance" or event.entity.name == "tunnel-exit" then
		local player = nil
		if event.player_index then
			player = game.get_player(event.player_index)
		end
		remove_surface_player_elevator(event.entity, player)
	elseif entity.name == "surface-driller" then
		local drilling_data = global.surface_drillers[string.format("%s@{%d,%d}", entity.surface.name, entity.position.x, entity.position.y)]

		drilling_data.progression_floating_text.destroy()
		drilling_data.description_floating_text.destroy()

		local count = 0
		for _ in pairs(global.surface_drillers) do count = count + 1 end
		if count == 0 then 
			global.onTickFunctions["drilling"] = nil
		end

		global.surface_drillers[string.format("%s@{%d,%d}", entity.surface.name, entity.position.x, entity.position.y)] = nil
	elseif string.find(entity.name, "independant%-item%-elevator") then
		for _,v in ipairs(entity.surface.find_entities_filtered{area = get_area(entity.position, 0.5), type="transport-belt"}) do
		 	v.destroy()
		end 
		local comp_surface = get_complementary_surface(entity)
		for _,v in ipairs(comp_surface.find_entities_filtered{area = get_area(entity.position, 0.5), type="transport-belt"}) do
		 	v.destroy()
		end
		local complementary_entity_name
		if string.find(entity.name, "upperside") then
			complementary_entity_name = "independant-item-elevator-lowerside"
		else -- if string.find(entity.name, "lowerside")
			complementary_entity_name = "independant-item-elevator-upperside"
		end
		comp_surface.find_entity(complementary_entity_name, entity.position).destroy()


	elseif entity.name == "active-air-vent" or entity.name == "air-vent" then
		global.air_vents[string.format("%s@{%d,%d}", entity.surface.name, entity.position.x, entity.position.y)] = nil
	
	end
end

function on_player_rotated_entity(event)
	local entity = event.entity
	if entity.name == "fluid-elevator-mk1" then
		if entity.direction == defines.direction.north then
			entity.direction = defines.direction.south
		elseif entity.direction == defines.direction.south then
			entity.direction = defines.direction.north
		end
	end
end

-- when a building is built
function on_built_entity(event)
	local entity = event.created_entity
	if entity.name == "surface-driller" then
		local subsurface = get_subsurface(entity.surface)
		local chunk_position = to_chunk_position(entity.position)
		local clear_tunnel_size = math.floor(elevator_size /2) + 1
		subsurface.request_to_generate_chunks(entity.position, math.floor(clear_tunnel_size / 32) + 3)

		local desc = entity.surface.create_entity{
                name='custom-flying-text',
                position={x = entity.position.x -1.7,y = entity.position.y -1.5},
                force=entity.force,
                text="drilling paused"
                }
		desc.active = false

		local progress = entity.surface.create_entity{
                name='custom-flying-text',
                position={x= entity.position.x - 0.30,y= entity.position.y -0.75},
                force=entity.force,
                text=string.format("%d", 0) .. "%"
                }
		progress.active = false

		global.surface_drillers[string.format("%s@{%d,%d}", entity.surface.name, entity.position.x, entity.position.y)] = {entity = entity, drilling_performed = 0, last_crafting_progress = 0, description_floating_text = desc, progression_floating_text = progress, state_active = false, progress = 0}
		global.onTickFunctions["drilling"] = on_tick_drilling
		
	elseif entity.name == "independant-item-elevator-placer" then
		local direction = math.floor(entity.orientation * 8)

		local complementary_surface
		if direction >= 4 and not is_subsurface(entity.surface) then
			if event.player_index then
				game.get_player(event.player_index).print("the lower part of a elevator can only be placed in a subsurface ! (the change has been made for you, but try to not do it again !)")
			end
			direction = (direction + 4) % 8
			complementary_surface = get_subsurface(entity.surface)
		elseif entity.direction >= 4 and is_subsurface(entity.surface) then
			complementary_surface = get_oversurface(entity.surface)
		else
			complementary_surface = get_subsurface(entity.surface)
		end

		local old_entity = entity

		local entity_name
		local new_direction
		local input_item_elevator
		local output_item_elevator
		if direction < 4 then
			entity_name = "independant-item-elevator-upperside"
			new_direction = direction * 2
		elseif direction >= 4 then
			entity_name = "independant-item-elevator-lowerside"
			new_direction = (direction - 4) * 2
		end

		local entity = entity.surface.create_entity{name = entity_name, position = entity.position, force=entity.force}
		entity.direction = new_direction

		old_entity.destroy()

		local icon = entity.surface.create_entity{name = "boring-in-progress", position = {x = entity.position.x, y = entity.position.y -0.25}, force=entity.force}
		table.insert(global.waiting_entities, {entity = entity, icon = icon})

		local entity_collision_box = entity.prototype.collision_box
		local entity_area = {}
		entity_area.left_top = {x = entity.position.x + entity_collision_box.left_top.x, y = entity.position.y + entity_collision_box.left_top.y}
		entity_area.right_bottom = {x = entity.position.x + entity_collision_box.right_bottom.x, y = entity.position.y + entity_collision_box.right_bottom.y}
		
		request_area_gen(entity_area, complementary_surface)
		global.onTickFunctions["check_waiting_entities"] = check_waiting_entities

	elseif entity.name == "active-air-vent" or entity.name == "air-vent" then

		-- generate chunk in the subsurface (just in case)
		local subsurface = get_subsurface(entity.surface)
		local chunk_position = to_chunk_position(entity.position)
		subsurface.request_to_generate_chunks(entity.position, 1)

		global.air_vents[string.format("%s@{%d,%d}", entity.surface.name, entity.position.x, entity.position.y)] = {entity = entity, active = false}
		entity.operable = false
		global.onTickFunctions["pollution_moving"] = pollution_moving

	elseif entity.name == "fluid-elevator-mk1" then
		local complementary_surface
		if entity.direction >= 4 and not is_subsurface(entity.surface) then
			if event.player_index then
				game.get_player(event.player_index).print("the lower part of a fluid-elevator can only be placed in a subsurface ! (the change has been made for you, but try to not do it again !)")
			end
			entity.direction = (entity.direction + 4) % 8
			complementary_surface = get_subsurface(entity.surface)
		elseif entity.direction >= 4 and is_subsurface(entity.surface) then
			complementary_surface = get_oversurface(entity.surface)
		else
			complementary_surface = get_subsurface(entity.surface)
		end
		local icon = entity.surface.create_entity{name = "boring-in-progress", position = {x = entity.position.x, y = entity.position.y -0.25}, force=entity.force}
		table.insert(global.waiting_entities, {entity = entity, icon = icon})

		local entity_collision_box = entity.prototype.collision_box
		local entity_area = {}
		entity_area.left_top = {x = entity.position.x + entity_collision_box.left_top.x, y = entity.position.y + entity_collision_box.left_top.y}
		entity_area.right_bottom = {x = entity.position.x + entity_collision_box.right_bottom.x, y = entity.position.y + entity_collision_box.right_bottom.y}
		
		request_area_gen(entity_area, complementary_surface)
		global.onTickFunctions["check_waiting_entities"] = check_waiting_entities

	elseif entity.name == "selection-marker" then
		if not game.get_player(event.player_index).cursor_stack.valid_for_read then 
			game.get_player(event.player_index).cursor_stack.set_stack{ name = "digging-planner", count = 1 }
		end
		entity.destroy()

	elseif entity.name == "digging-robots-deployment-center" then
		if global.digging_in_progress[entity.surface.name] == nil then global.digging_in_progress[entity.surface.name] = {} end
		table.insert(global.digging_robots_deployment_centers, {deployment_center = entity})
		global.onTickFunctions["digging_robots_manager"] = digging_robots_manager
	end
end

function request_area_gen(_area, _surface) -- request is only done once per chunck since the game generate the map by chunks
	if is_subsurface(_surface) then
		_area = expand_area(_area, 1)
	end
	chunk_area = {left_top = to_chunk_position(_area.left_top), right_bottom = to_chunk_position(_area.right_bottom)}
	for x,y in iarea(chunk_area) do
		_surface.request_to_generate_chunks({x=x*32 + 16,y=y*32 + 16}, 1)
	end
end

function clear_subsurface(_surface, _position, _digging_radius, _clearing_radius)
	if _digging_radius < 1 then return nil end -- min _digging_radius is 1 
	local digging_subsurface_area = get_area(_position, _digging_radius - 1)
	local new_tiles = {}

	if _clearing_radius then
		local clearing_subsurface_area = get_area(_position, _clearing_radius)
		for _,entity in ipairs(_surface.find_entities(clearing_subsurface_area)) do
			if entity.type ~="player" then
				entity.destroy()
			else
				entity.teleport(get_safe_position(_position, {x=_position.x + _clearing_radius, y = _position.y}))
			end
		end 
	end

	if not is_subsurface(_surface) then return end

	local walls_destroyed = 0
	for x, y in iarea(digging_subsurface_area) do
		if _surface.get_tile(x, y).name ~= cavern_Ground_name then
			table.insert(new_tiles, {name = cavern_Ground_name, position = {x, y}})
		end

		if global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))] then -- remove the mark
			if global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))].valid then
				global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))].destroy()
			end
			global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))] = nil
		end
		if global.digging_pending[_surface.name] and global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] then -- remove the digging pending entity
			if global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))].valid then
				global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))].destroy()
			end
			global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] = nil
		end

		local wall = _surface.find_entity(cavern_Wall_name, {x = x, y = y})
		if wall then 
			wall.destroy()
			walls_destroyed = walls_destroyed + 1
		else
		end
	end
	local to_add = {}
	for x, y in iouter_area_border(digging_subsurface_area) do
		if _surface.get_tile(x, y).name == "out-of-map" then
			table.insert(new_tiles, {name = "cave-walls", position = {x, y}})
			_surface.create_entity{name = cavern_Wall_name, position = {x, y}, force=game.forces.neutral}
			if global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))] then -- manage the marked for digging cells
				if global.digging_pending[_surface.name] == nil then global.digging_pending[_surface.name] = {} end
				if global.digging_pending[_surface.name][string.format("{%d,%d}", math.floor(x), math.floor(y))] == nil then 
					table.insert(to_add, {surface = _surface,x = x, y = y})
				end
				if global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))].valid then	
					global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))].destroy()
				end
				global.marked_for_digging[string.format("%s&@{%d,%d}", _surface.name, math.floor(x), math.floor(y))] = nil
			end
		end
	end
	_surface.set_tiles(new_tiles)

	-- done after because set_tiles remove decorations
	for _,data in ipairs(to_add) do
		local pending_entity = data.surface.create_entity{name = "pending-digging", position = {x = data.x, y = data.y}, force=game.forces.neutral}
		global.digging_pending[data.surface.name][string.format("{%d,%d}", math.floor(data.x), math.floor(data.y))] = pending_entity
	end

	return walls_destroyed
end





function startingItems(player)
	--[[
  player.insert{name="iron-plate", count=100}
  player.insert{name="solar-panel", count=50}
  player.insert{name="substation", count=50}
  player.insert{name="basic-accumulator", count=50}
  player.insert{name="digging-planner", count=1}

  player.force.research_all_technologies()
  ]]
end


-- A* inspired algorithme to find the closest digging pending position
function find_nearest_marked_for_digging(_position, _surface, _data)
	_data = _data or {}

	local starting_node = {position = _position, surface = _surface, cost = 0}
	_data.open_list = _data.open_list or {}
	_data.closed_list = _data.closed_list or {}
	_data.open_list_data = _data.open_list_data or {}
	_data.inactive_cells_list = _data.inactive_cells_list or {}

	_data.finished = false

	function next_new_nodes(node)
		local result = {}
		for disc_x,disc_y in iarea(get_area(node.position, 1)) do
			local x, y = math.floor(disc_x), math.floor(disc_y)
			if not(_data.closed_list[string.format("{%d,%d}",x,y)] or _data.open_list[string.format("{%d,%d}",x,y)]) then
				local added_cost = 0
				if x ~= math.floor(node.position.x) then added_cost = added_cost + 1 end
				if y ~= math.floor(node.position.y) then added_cost = added_cost + 1 end			
				added_cost = (added_cost == 2 and 1.4 or added_cost)
				table.insert(result, {position = {x=x, y=y}, surface = node.surface, cost = node.cost + added_cost})
			end
		end
		return result
	end

	table.insert(_data.open_list_data, starting_node)
	_data.open_list[string.format("{%d,%d}", math.floor(starting_node.position.x),math.floor(starting_node.position.y))] = true

	local count = 0


	while #_data.open_list_data > 0 and count < 10 do
		count = count + 1
		local current_node = table.remove(_data.open_list_data, 1)

		if global.digging_pending[current_node.surface.name][string.format("{%d,%d}", math.floor(current_node.position.x), math.floor(current_node.position.y))] 
		and not global.digging_in_progress[current_node.surface.name][string.format("{%d,%d}", math.floor(current_node.position.x), math.floor(current_node.position.y))] then
			return {finished = true, position = current_node.position}
		else
			for _,node in ipairs(next_new_nodes(current_node)) do
				if not global.digging_in_progress[current_node.surface.name][string.format("{%d,%d}", math.floor(node.position.x), math.floor(node.position.y))] then
					if node.surface.get_tile(node.position.x, node.position.y).name ~= "cave-walls"
					or global.digging_pending[current_node.surface.name][string.format("{%d,%d}", math.floor(node.position.x), math.floor(node.position.y))] then
						table.insert(_data.open_list_data, node)
						_data.open_list[string.format("{%d,%d}", math.floor(node.position.x),math.floor(node.position.y))] = true
					else
						table.insert(_data.inactive_cells_list, node)
					end
				end
			end
			table.sort(_data.open_list_data, function(node1, node2) return node1.cost < node2.cost end )
		end
		_data.closed_list[string.format("{%d,%d}", math.floor(current_node.position.x),math.floor(current_node.position.y))] = true
	end
	if count == 10 then -- the search didn't finish
		return _data
	end
	return nil
end



remote.add_interface("subsurface", {
	activate_automated_boring = function() 
		game.forces.player.recipes["digging-robots-deployment-center"].enabled = true
		game.forces.player.recipes["assemble-digging-robots"].enabled = true
		game.forces.player.recipes["digging-planner"].enabled = true
	end
	})

-- /c remote.call("subsurface", "activate_automated_boring")