--[[
	Iterator for looping over an area.
	returns the x, y co-ordiantes for each position in an area.
	example:
		area = {{0, 0}, {10, 20}}
		for x, y in iarea(area) do
		end
]]
--iarea this was taken from the NESTT mod lib.lua and modified
function iarea( area )
	local leftTop = area.left_top 
	local RightBottom = area.right_bottom
	local _x = leftTop.x
	local _y = leftTop.y
	local reachedEnd = false
	return function()
		if reachedEnd then return nil end
		local x = _x
		local y = _y
		_x = _x + 1
		if _x > RightBottom.x then
			_x = leftTop.x
			_y = _y + 1
			if _y > RightBottom.y then
				reachedEnd = true
			end
		end
		return x, y
	end
end

function iouter_area_border(area)
	local left_top = {x = area.left_top.x - 1, y = area.left_top.y - 1}
	local right_bottom = {x = area.right_bottom.x + 1, y = area.right_bottom.y + 1}
	local _x = left_top.x
	local _y = left_top.y
	local reachedEnd = false
	return function()
		if reachedEnd then return nil end
		local x = _x
		local y = _y

		if y == left_top.y or y == right_bottom.y then
			_x = _x + 1
		else
			_x = right_bottom.x
		end
		if x == right_bottom.x then
			_x = left_top.x
			_y = _y + 1
			if _y > right_bottom.y then
				reachedEnd = true
			end
		end
		return x, y
	end
end

function get_area(position, size)
	return {left_top = {x = position.x - size, y = position.y - size}, right_bottom = {x = position.x + size, y = position.y + size}}
end


function KeyExists(tbl, key)
  for k,v in pairs(tbl) do
    if key == k then
      return true
    end
  end

  return false
end


function get_safe_position(entity_position, player_position)
	local distance_modifier = 1.5
	return {x = entity_position.x + (player_position.x - entity_position.x) * distance_modifier, y= entity_position.y + (player_position.y - entity_position.y) * distance_modifier}
end


function get_area(position, size)
	return {left_top = {x = position.x - size, y = position.y - size}, right_bottom = {x = position.x + size, y = position.y + size}}
end


function to_chunk_position(position)
	return {x = math.floor(position.x/32),y = math.floor(position.y/32)}
end

function associative_table_count(table)
	local i = 0
	for _,_ in pairs(table) do
		i=i+1
	end
	return i
end
