data:extend(
{
  {
    type = "electric-pole",
    name = "tunnel-entrance",
    icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1},
    max_health = 250,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.4, -1.4}, {1.4, 1.4}},
    render_layer = "object",
    order="zzz",
    pictures =
    {
      filename = "__base__/graphics/entity/big-electric-pole/big-electric-pole.png",
      priority = "high",
      width = 168,
      height = 165,
      direction_count = 1,
      shift = {1.6, -1.1}
    },
        connection_points =
    {
      {
        shadow =
        {
          copper = {2.7, 0},
          green = {1.8, 0},
          red = {3.6, 0}
        },
        wire =
        {
          copper = {0, -3.1},
          green = {-0.6,-3.1},
          red = {0.6,-3.1}
        }
      }
    },
    radius_visualisation_picture =
    {
      filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
      width = 12,
      height = 12,
      priority = "extra-high-no-scale"
    },
    resistances =
    {
      {
        type = "fire",
        percent = 100
      }
    },
    circuit_wire_max_distance = 7.5,
    maximum_wire_distance = 5,
    supply_area_distance = 2,
  },
  {
    type = "electric-pole",
    name = "tunnel-exit",
    icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
    flags = {},
    minable = {mining_time = 1},
    max_health = 250,
    corpse = "big-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.4, -1.4}, {1.4, 1.4}},
    render_layer = "object",
    order="zzz",
    pictures =
    {
      filename = "__base__/graphics/entity/big-electric-pole/big-electric-pole.png",
      priority = "high",
      width = 168,
      height = 165,
      direction_count = 1,
      shift = {1.6, -1.1}
    },
        connection_points =
    {
      {
        shadow =
        {
          copper = {2.7, 0},
          green = {1.8, 0},
          red = {3.6, 0}
        },
        wire =
        {
          copper = {0, -3.1},
          green = {-0.6,-3.1},
          red = {0.6,-3.1}
        }
      }
    },
    radius_visualisation_picture =
    {
      filename = "__base__/graphics/entity/small-electric-pole/electric-pole-radius-visualization.png",
      width = 12,
      height = 12,
      priority = "extra-high-no-scale"
    },
    resistances =
    {
      {
        type = "fire",
        percent = 100
      }
    },
    circuit_wire_max_distance = 7.5,
    maximum_wire_distance = 5,
    supply_area_distance = 2,
  },
  {
    type = "wall",
    name = "subsurface-walls",
    icon = "__base__/graphics/icons/stone-wall.png",
    flags = {"placeable-neutral", "player-creation"},
    collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    minable = {mining_time = 1, result = "stone"},
    max_health = 350,
    repair_speed_modifier = 2,
    corpse = "wall-remnants",
    repair_sound = { filename = "__base__/sound/manual-repair-simple.ogg" },
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    vehicle_impact_sound =  { filename = "__base__/sound/car-stone-impact.ogg", volume = 1.0 },
    order = "z",
    resistances =
    {
      { type = "physical", percent = 100 },
      { type = "impact", percent = 100 },
      { type = "explosion", percent = 100 },
      { type = "fire", percent = 100 },
      { type = "laser", percent = 100 }
    },
    pictures =
    {
      single = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "extra-high", width = 0, height = 0, shift = {0, 0}}}},
      straight_vertical = {{layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "extra-high", width = 0, height = 0, shift = {0, 0}}}}},
      straight_horizontal = {{layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "extra-high", width = 0, height = 0, shift = {0, 0}}}}},
      corner_right_down = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "extra-high", width = 0, height = 0, shift = {0, 0}}}},
      corner_left_down = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "extra-high", width = 0, height = 0, shift = {0, 0}}}},
      t_up = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "extra-high", width = 0, height = 0, shift = {0, 0}}}},
      ending_right = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "extra-high", width = 0, height = 0, shift = {0, 0}}}},
      ending_left = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "extra-high", width = 0, height = 0, shift = {0, 0}}}},
    }
  },


  {
    type = "flying-text",
    name = "custom-flying-text",
    flags = {"not-on-map", "placeable-off-grid"},
    time_to_live = 1,
    speed = 0
  },

  {
    type = "assembling-machine",
    name = "active-air-vent",
    icon = "__Subsurface__/graphics/entities/air-vent.png",
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "active-air-vent"},
    max_health = 200,
    crafting_categories = {"crafting"},
    ingredient_count = 0,
    collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    animation =
    {
      filename = "__Subsurface__/graphics/entities/air-vent.png",
      priority="high",
      width = 30,
      height = 28,
      frame_count = 1,
      line_length = 1,
      shift = {0,0}
    },
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0
    },
    energy_usage = "50kW",
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__base__/sound/oil-refinery.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
  },


  {
    type = "decorative",
    name = "air-vent",
    flags = {"placeable-neutral", "not-on-map"},
    icon = "__Subsurface__/graphics/entities/air-vent.png",
    minable = {mining_time = 1, result = "air-vent"},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    render_layer = "decorative",
    max_health = 350,
    order = "z",
    smoke =
    {
      {
        name = "light-smoke",
        north_position = {0.9, 0.0},
        east_position = {-2.0, -2.0},
        frequency = 10 / 32,
        starting_vertical_speed = 0.08,
        slow_down_factor = 1,
        starting_frame_deviation = 60
      }
    },
    pictures =
    {
      {
        filename = "__Subsurface__/graphics/entities/air-vent.png",
        width = 30,
        height = 28,
      }
    }
  },

  {
    type = "assembling-machine",
    name = "surface-driller",
    icon = "__base__/graphics/icons/assembling-machine-1.png",
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "surface-driller"},
    max_health = 200,
    corpse = "big-remnants",
    dying_explosion = "massive-explosion",
    crafting_categories = {"digging"},
    ingredient_count = 0,
    fixed_recipe = "drilling",
    collision_box = {{-2.2, -2.2}, {2.2, 2.2}},
    selection_box = {{-2.5, -2.5}, {2.5, 2.5}},
    animation =
    {
      filename = "__Subsurface__/graphics/entities/big-assembly.png",
      priority="high",
      width = 165,
      height = 170,
      frame_count = 32,
      line_length = 8,
      shift = {0.417, -0.167}
    },
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0.05 / 1.5
    },
    energy_usage = "50kW",
    open_sound = { filename = "__base__/sound/machine-open.ogg", volume = 0.85 },
    close_sound = { filename = "__base__/sound/machine-close.ogg", volume = 0.75 },
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound = { filename = "__base__/sound/oil-refinery.ogg" },
      idle_sound = { filename = "__base__/sound/idle1.ogg", volume = 0.6 },
      apparent_volume = 2.5,
    },
  },

  {
    type = "smoke",
    name = "smoke-custom",
    flags = {"not-on-map", "placeable-off-grid"},
    duration = 120,
    fade_away_duration = 120,
    spread_duration = 120,
    start_scale = 0.20,
    end_scale = 1.0,
    cyclic = true,
    color = {r = 1, g = 1, b = 1, a = 0.9},
    affected_by_wind = true,
    animation =
    {
      width = 152,
      height = 120,
      line_length = 5,
      frame_count = 60,
      axially_symmetrical = false,
      direction_count = 1,
      shift = {-0.53125, -0.4375},
      priority = "high",
      animation_speed = 0.25,
      filename = "__base__/graphics/entity/smoke/smoke.png"
    }
  }
}
)
