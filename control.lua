require "util"
require "defines"
require "lib"


-- configuration variables
cavern_Wall_name = "subsurface-walls"
cavern_Ground_name = "concrete"
teleportation_time = 120
elevator_size = 5
max_pollution_move_active = 2 -- the max amount of pollution that can be moved per ticks from one surface to the above, only for active air-vent
max_pollution_move_passive = 1 -- the max amount of pollution that can be moved per ticks from one surface to the above, only for passive air-vent
max_apnea_time = 20*60
apnea_threshold = 1000
apnea_damage = 2.5
-- end configuration variables

-- state variables
time_spent_dict = {}
-- end state variables




script.on_init(function ()

	generate_tunnel_surface("Tunnel_1")
	
	global.onTickFunctions = global.onTickFunctions or {}
	global.elevator_association = global.elevator_association or {}
	global.item_elevator = global.item_elevator or {}
	global.surface_drillers = global.surface_drillers or {}
	global.air_vents = global.air_vents or {}
	global.underground_players = global.underground_players or {}

	-- move to where I create the first entrance ?
	global.onTickFunctions["teleportation_check"] = teleportation_check
	global.onTickFunctions["move_items"] = move_items
	global.onTickFunctions["pollution_moving"] = pollution_moving

	--global.onTickFunctions["debug"] = debug
end)



script.on_load(function ()
	

	--generate_tunnel_surface("Tunnel_1")

	global.onTickFunctions = global.onTickFunctions or {}
	global.onTickFunctions["teleportation_check"] = teleportation_check
	global.onTickFunctions["move_items"] = move_items
	global.onTickFunctions["pollution_moving"] = pollution_moving


	global.elevator_association = global.elevator_association or {}
	global.item_elevator = global.item_elevator or {}
	global.surface_drillers = global.surface_drillers or {}
	global.air_vents = global.air_vents or {}
end)

-- when an entity is built (to create the tunnel exit)
script.on_event(defines.events.on_built_entity, function(event) on_built_entity(event) end)
script.on_event(defines.events.on_robot_built_entity, function(event) on_built_entity(event) end)

-- when a chunk is generated (to change all tunnel tiles to out-of-map)
script.on_event(defines.events.on_chunk_generated, function (event) on_chunk_generated(event) end)

-- when a item is removed (to know when a wall is removed) /!\ will need to be removed when tiles are set to unminable
script.on_event(defines.events.on_preplayer_mined_item,  function (event) on_pre_mined_item(event) end)

-- debug only -> to add stuff to the player on game start
script.on_event(defines.events.on_player_created,  function (event) startingItems(game.get_player(event.player_index)) end)


script.on_event(defines.events.on_tick, 
	function(event) 
		for name,fun in pairs(global.onTickFunctions) do
			--we pass the name to the function so it can delete itself if it wants to, the function does not remember its own name to prevent closures
			if type(fun) == "function" then fun(name) end
			if type(fun) == "table" and fun.onTick then fun:onTick(name) end
		end
	end)



function debug(function_name)
	local gpp = game.player.print

	local surface = game.get_surface("Tunnel_1")

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

	gpp("chunk position : " .. top_left .. "-" ..top_center .. "-" ..top_right .. " | " .. center_left .. "-" ..center_center .. "-" ..center_right .. " | " .. bottom_left .. "-" ..bottom_center .. "-" ..bottom_right)
	
	return true
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
					entity.energy = entity.energy - ((pollution_to_move / max_pollution_move_active)*max_energy)
					subsurface.pollute(entity.position, -pollution_to_move)
					entity.surface.pollute(entity.position, pollution_to_move)

					if pollution_to_move > 0 and game.tick % 5 == 0 then
						entity.surface.create_entity{name="smoke-custom", position={x = entity.position.x, y = entity.position.y+1}, force=game.forces.neutral}
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
	if associative_table_count(global.underground_players) == 0 then
		global.onTickFunctions["pollution_killing_subsurface"] = nil
	end
end



function move_items(function_name)
	for _,elevator in pairs(global.item_elevator) do
		if elevator.input.active or elevator.output.active then
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
			if not KeyExists(time_spent_dict, player.name) then -- only initiate his transportation if he's not already transporting
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
							time_spent_dict[player.name] = {player = player, destination_entity = connected_entity, time_spent = 0, gui_element = progressbar_container}
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

	for player_name, data in pairs(time_spent_dict) do
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
			time_spent_dict[player_name] = nil
			gui_element.destroy()

			if #time_spent_dict == 0 then
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

function get_subsurface(surface)

	if not game.get_surface("Tunnel_1") then
		generate_tunnel_surface("Tunnel_1")
	end

	return game.get_surface("Tunnel_1")
end

function get_oversurface(_subsurface)
	return game.get_surface("nauvis")
end

function is_subsurface(surface)
	return surface == game.get_surface("Tunnel_1")
end

function place_surface_elevator(_surface, _subsurface, _position, _force)
	if not can_place_surface_elevator(_surface, _position) then return end

	local clear_tunnel_size = math.ceil(elevator_size /2) + 1
	-- clean all other entities ?
	clearTunnel(_subsurface, _position, clear_tunnel_size, 1.5)--elevator_size/2)
			

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
	for player_name, data in pairs(time_spent_dict) do
		if data.destination_entity == connected_entity or data.destination_entity == _entity then
			data.destination_entity = nil
		end
	end
	

	--_entity.destroy()
	connected_entity.destroy()

	for _,belt in ipairs(current_association.surface_elevator.items_elevators) do
		local key_string = string.format("%s&%s@{%d,%d}", surface_name, subsurface_name, belt.position.x, belt.position.y)
		if global.item_elevator[key_string] then
			global.item_elevator[key_string] = nil
		end

		-- take content of the item and insert in player
		belt.destroy()
	end

	for _,belt in ipairs(current_association.subsurface_elevator.items_elevators) do
		-- take content of the item and insert in player
		belt.destroy()
	end

	global.elevator_association[string.format("%s&%s@{%d,%d}", surface_name, subsurface_name, position.x, position.y)] = nil
end
		    	

-- if the chunk generated is a chunk of the tunnels, change all tiles to out_of-map tiles (-> not accessible and not on the map)
function on_chunk_generated(event)

	local surface = event.surface
	local area = event.area
	if surface.name == "Tunnel_1" then
		local newTiles = {}
		for x, y in iarea(area) do
			table.insert(newTiles, {name = "out-of-map", position = {x, y}})
		end
		surface.set_tiles(newTiles)
	end
end

-- when a wall has been removed
function on_tunnel_wall_mined(wall_entity, surface)
	clearTunnel(surface, wall_entity.position, 1, 0)
end

-- when a building has been removed (to check when a wall is removed)
function on_pre_mined_item(event)
	local entity = event.entity
	local surface = entity.surface

	if event.entity.name == cavern_Wall_name then
		on_tunnel_wall_mined(entity, surface)
	elseif event.entity.name == "tunnel-entrance" or event.entity.name == "tunnel-exit" then
		remove_surface_player_elevator(event.entity, game.get_player(event.player_index))
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

	elseif entity.name == "active-air-vent" or entity.name == "air-vent" then
		global.air_vents[string.format("%s@{%d,%d}", entity.surface.name, entity.position.x, entity.position.y)] = nil
	
	end
end

-- when a building is built
function on_built_entity(event)
	local entity = event.created_entity

	if entity.name == "surface-driller" then
		local Tunnel_1 = get_subsurface(entity.surface)
		local chunk_position = to_chunk_position(entity.position)
		local clear_tunnel_size = math.floor(elevator_size /2) + 1
		Tunnel_1.request_to_generate_chunks(entity.position, math.floor(clear_tunnel_size / 32) + 3)

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
		
	elseif entity.name == "active-air-vent" or entity.name == "air-vent" then

		-- generate chunk in the subsurface (just in case)
		local subsurface = get_subsurface(entity.surface)
		local chunk_position = to_chunk_position(entity.position)
		subsurface.request_to_generate_chunks(entity.position, 1)

		global.air_vents[string.format("%s@{%d,%d}", entity.surface.name, entity.position.x, entity.position.y)] = {entity = entity, active = false}
		entity.operable = false
	end
end

function generate_tunnel_surface(name)
	game.create_surface(name)
end


function clearTunnel(_surface, _position, _digging_radius, _clearing_radius)
	if _digging_radius < 1 then return nil end -- min _digging_radius is 1 

	local digging_subsurface_area = get_area(_position, _digging_radius - 1)
	local clearing_subsurface_area = get_area(_position, _clearing_radius)
	local new_tiles = {}

	for _,entity in ipairs(_surface.find_entities(clearing_subsurface_area)) do
		if entity.type ~="player" then
			entity.destroy()
		else
			entity.teleport(get_safe_position(_position, {x=_position.x + _clearing_radius, y = _position.y}))
		end
	end 
	for x, y in iarea(digging_subsurface_area) do
		table.insert(new_tiles, {name = cavern_Ground_name, position = {x, y}})

		local wall = _surface.find_entity(cavern_Wall_name, {x = x, y = y})
		if wall then wall.destroy() end
	end
	for x, y in iouter_area_border(digging_subsurface_area) do
		if _surface.get_tile(x, y).name == "out-of-map" then
			table.insert(new_tiles, {name = "cave-walls", position = {x, y}})
			_surface.create_entity{name = cavern_Wall_name, position = {x, y}, force=game.forces.neutral}
		end
	end
	_surface.set_tiles(new_tiles)
end





function startingItems(player)
  player.insert{name="iron-plate", count=100}
  player.insert{name="pistol", count=1}
  player.insert{name="basic-bullet-magazine", count=100}
  player.insert{name="wooden-chest", count=64}
  player.insert{name="small-electric-pole", count=32}
  player.insert{name="basic-inserter", count=64}
  player.insert{name="solar-panel", count=54}
  player.insert{name="basic-transport-belt", count=128}
  player.insert{name="steam-engine", count=16}
  player.insert{name="boiler", count=32}
  player.insert{name="lab", count=8}
  player.insert{name="pipe", count=64}
  player.insert{name="basic-mining-drill", count=32}
  player.insert{name="basic-transport-belt-to-ground", count=32}
  player.insert{name="pipe-to-ground", count=32}
  player.insert{name="basic-splitter", count=32}
  player.insert{name="coal", count=128}
  player.insert{name="raw-wood", count=128}
  player.insert{name="car", count=1}
  player.insert{name="chemical-plant", count=8}
  player.insert{name="assembling-machine-3", count=8}
end


