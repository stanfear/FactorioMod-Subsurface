function blank4StorageTank()
  return
  {
    filename = "__base__/graphics/terrain/blank.png",
    priority = "high",
    width = 0,
    height = 0
  }
end

data:extend(
{
  {
    type = "electric-pole",
    name = "tunnel-entrance",
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
      width = 256,
      height = 256,
      direction_count = 1,
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
    flags = {"placeable-neutral", "not-on-map"},
    collision_box = {{-0.29, -0.29}, {0.29, 0.29}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    minable = {mining_time = 1, result="stone",count=2},
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
      single = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "high", width = 0, height = 0, shift = {0, 0}}}},
      straight_vertical = {{layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "high", width = 0, height = 0, shift = {0, 0}}}}},
      straight_horizontal = {{layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "high", width = 0, height = 0, shift = {0, 0}}}}},
      corner_right_down = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "high", width = 0, height = 0, shift = {0, 0}}}},
      corner_left_down = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "high", width = 0, height = 0, shift = {0, 0}}}},
      t_up = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "high", width = 0, height = 0, shift = {0, 0}}}},
      ending_right = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "high", width = 0, height = 0, shift = {0, 0}}}},
      ending_left = {layers = {{filename = "__base__/graphics/terrain/blank.png", priority = "high", width = 0, height = 0, shift = {0, 0}}}},
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
    icon = "__Subsurface__/graphics/icons/air_vent_22_icon.png",
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "active-air-vent"},
    max_health = 200,
    crafting_categories = {"dummy-recipe-category"},
    fixed_recipe = "dummy-air-vent-recipe",
    ingredient_count = 0,
    collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    animation =
    {
      filename = "__Subsurface__/graphics/entities/air_vent22_sheet.png",
      priority="high",
      width = 96,
      height = 96,
      frame_count = 16,
      line_length = 4,
      shift = {0.45,-0.1},
      animation_speed = 2,
    },
    crafting_speed = 1,
    energy_source =
    {
      type = "electric",
      usage_priority = "secondary-input",
      emissions = 0
    },
    energy_usage = "50kW",
  },

  {
    type = "simple-entity",
    name = "air-vent",
    flags = {"placeable-neutral", "not-on-map"},
    collision_mask = { "item-layer", "object-layer", "player-layer", "water-tile"},
    icon = "__Subsurface__/graphics/icons/air_vent_11_icon.png",
    minable = {mining_time = 1, result = "air-vent"},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    render_layer = "decorative",
    max_health = 350,
    order = "z",
    pictures =
    {
      {
        filename = "__Subsurface__/graphics/entities/air_vent_11.png",
        width = 64,
        height = 64,
      }
    },
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
    start_scale = 0.6,
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
  },
  {
    type = "car",
    name = "mobile-borer",
    icon = "__base__/graphics/icons/car.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "mobile-borer"},
    max_health = 1500,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    energy_per_hit_point = 0.2,
    order="z",
    crash_trigger = {
      type = "play-sound",
      sound =
      {
        {
          filename = "__base__/sound/car-crash.ogg",
          volume = 0.25
        },
      }
    },
    resistances =
    {
      {
        type = "impact",
        percent = 30,
        decrease = 30
      }
    },
    collision_box = {{-0.7, -1}, {0.7, 1}},
    selection_box = {{-0.7, -1}, {0.7, 1}},
    effectivity = 1,
    braking_power = "1500kW",
    burner =
    {
      effectivity = 0.70,
      fuel_inventory_size = 3,
      smoke =
      {
        {
          name = "car-smoke",
          deviation = {0.25, 0.25},
          frequency = 200,
          position = {0, 1.5},
          starting_frame = 0,
          starting_frame_deviation = 60
        }
      }
    },
    consumption = "1500kW",
    friction = 5e-2,
    light =
    {
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {-0.6, -14},
        size = 2,
        intensity = 0.6
      },
      {
        type = "oriented",
        minimum_darkness = 0.3,
        picture =
        {
          filename = "__core__/graphics/light-cone.png",
          priority = "medium",
          scale = 2,
          width = 200,
          height = 200
        },
        shift = {0.6, -14},
        size = 2,
        intensity = 0.6
      }
    },
    animation =
    {
      layers =
      {
        {
          width = 102,
          height = 86,
          frame_count = 2,
          direction_count = 64,
          shift = {0, -0.1875},
          animation_speed = 8,
          max_advance = 0.2,
          stripes =
          {
            {
             filename = "__base__/graphics/entity/car/car-1.png",
             width_in_frames = 2,
             height_in_frames = 22,
            },
            {
             filename = "__base__/graphics/entity/car/car-2.png",
             width_in_frames = 2,
             height_in_frames = 22,
            },
            {
             filename = "__base__/graphics/entity/car/car-3.png",
             width_in_frames = 2,
             height_in_frames = 20,
            },
          }
        },
        {
          width = 100,
          height = 75,
          frame_count = 2,
          apply_runtime_tint = true,
          direction_count = 64,
          max_advance = 0.2,
          line_length = 2,
          shift = {0, -0.171875},
          stripes = util.multiplystripes(2,
          {
            {
              filename = "__base__/graphics/entity/car/car-mask-1.png",
              width_in_frames = 1,
              height_in_frames = 22,
            },
            {
              filename = "__base__/graphics/entity/car/car-mask-2.png",
              width_in_frames = 1,
              height_in_frames = 22,
            },
            {
              filename = "__base__/graphics/entity/car/car-mask-3.png",
              width_in_frames = 1,
              height_in_frames = 20,
            },
          })
        },
        {
          width = 114,
          height = 76,
          frame_count = 2,
          draw_as_shadow = true,
          direction_count = 64,
          shift = {0.28125, 0.25},
          max_advance = 0.2,
          stripes = util.multiplystripes(2,
          {
           {
            filename = "__base__/graphics/entity/car/car-shadow-1.png",
            width_in_frames = 1,
            height_in_frames = 22,
           },
           {
            filename = "__base__/graphics/entity/car/car-shadow-2.png",
            width_in_frames = 1,
            height_in_frames = 22,
           },
           {
            filename = "__base__/graphics/entity/car/car-shadow-3.png",
            width_in_frames = 1,
            height_in_frames = 20,
           },
          })
        }
      }
    },
    sound_no_fuel =
    {
      {
        filename = "__base__/sound/fight/car-no-fuel-1.ogg",
        volume = 0.6
      },
    },
    stop_trigger_speed = 0.2,
    stop_trigger =
    {
      {
        type = "play-sound",
        sound =
        {
          {
            filename = "__base__/sound/car-breaks.ogg",
            volume = 0.6
          },
        }
      },
    },
    sound_minimum_speed = 0.2;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/car-engine.ogg",
        volume = 0.6
      },
      activate_sound =
      {
        filename = "__base__/sound/car-engine-start.ogg",
        volume = 0.6
      },
      deactivate_sound =
      {
        filename = "__base__/sound/car-engine-stop.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
    open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
    close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
    rotation_speed = 0.001,
    weight = 35000,
    tank_driving = true,
    inventory_size = 30
  },

  {
    type = "decorative",
    name = "boring-in-progress",
    flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
    icon = "__base__/graphics/icons/green-asterisk.png",
    subgroup = "grass",
    order = "b[decorative]-b[asterisk]-b[green]",
    collision_box = {{-0.7, -0.7}, {0.7, 0.7}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selectable_in_game = false,
    render_layer = "entity-info-icon",
    pictures =
    {
      {
        filename = "__Subsurface__/graphics/entities/digging-in-progress.png",
        width = 64,
        height = 55,
      }
    }
  },

  {
    type = "storage-tank",
    name = "fluid-elevator-mk1",
    icon = "__base__/graphics/icons/storage-tank.png",
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 3, result = "fluid-elevator-mk1"},
    max_health = 300,
    corpse = "small-remnants",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    fluid_box =
    {
      base_area = 10,
      base_level = -1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        { position = {-1, -2} },
        { position = {2, 1} },
        { position = {1, 2} },
        { position = {-2, -1} },
      },
    },
    window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
    pictures =
    {
      picture =
      {
        sheet =
        {
          filename = "__Subsurface__/graphics/entities/storage-tank.png",
          priority = "extra-high",
          frames = 4,
          width = 140,
          height = 115,
          shift = {0.6875, 0.109375}
        }
      },
      fluid_background =
      {
        filename = "__base__/graphics/entity/storage-tank/fluid-background.png",
        priority = "extra-high",
        width = 32,
        height = 15
      },
      window_background =
      {
        filename = "__base__/graphics/entity/storage-tank/window-background.png",
        priority = "extra-high",
        width = 17,
        height = 24
      },
      flow_sprite =
      {
        filename = "__base__/graphics/entity/pipe/fluid-flow-low-temperature.png",
        priority = "extra-high",
        width = 160,
        height = 20
      }
    },
    flow_length_in_ticks = 360,
    circuit_wire_connection_points =
    {
      {
        shadow =
        {
          red = {2.0, 1.0},
          green = {2.0, 1.0},
        },
        wire =
        {
          red = {1.0, -0.0},
          green = {1.0, -0.0},
        }
      },
      {
        shadow =
        {
          red = {0.0, 1.0},
          green = {0.0, 1.0},
        },
        wire =
        {
          red = {-1, -0.25},
          green = {-1, -0.25},
        }
      },
      {
        shadow =
        {
          red = {2.0, 1.0},
          green = {2.0, 1.0},
        },
        wire =
        {
          red = {1.0, -0.0},
          green = {1.0, -0.0},
        }
      },
      {
        shadow =
        {
          red = {0.0, 1.0},
          green = {0.0, 1.0},
        },
        wire =
        {
          red = {-1, -0.25},
          green = {-1, -0.25},
        }
      }
    },
    circuit_wire_max_distance = 7.5,        
    working_sound =
    {
      sound = {
        filename = "__base__/sound/storage-tank.ogg",
        volume = 0.8
      },
      apparent_volume = 1.5,      
    },
  },

  {
    type = "car",
    name = "independant-item-elevator-placer",
    icon = "__Subsurface__/graphics/icons/Tunnels-icon.png",
    flags = {"placeable-player", "player-creation", "building-direction-8-way"},
    max_health = 1500,
    corpse = "medium-remnants",
    dying_explosion = "medium-explosion",
    render_layer = "object",
    energy_per_hit_point = 0.2,
    order="z",
    collision_box = {{-0.8, -0.8}, {0.8, 0.8}},
    selection_box = {{-1, -1}, {1, 1}},
    effectivity = 0,
    braking_power = "0W",
    burner =
    {
      effectivity = 0.01,
      fuel_inventory_size = 1,
    },
    consumption = "0W",
    friction = 1,
    light = {{intensity = 0, size = 0},},
    animation =
    {
      layers =
      {
        {
          frame_count = 1,
          direction_count = 8,
          width = 64,
          height = 64,
          shift = {0,0},
          priority = "high",
          stripes =
          {
            {
             filename = "__Subsurface__/graphics/entities/item-elevator-top.png",
             width_in_frames = 4,
             height_in_frames = 1,
            },
            {
             filename = "__Subsurface__/graphics/entities/item-elevator-bottom.png",
             width_in_frames = 4,
             height_in_frames = 1,
            },
          }
        },
      }
    },
    sound_no_fuel =
    {
      {
        filename = "__base__/sound/fight/car-no-fuel-1.ogg",
        volume = 0.6
      },
    },
    stop_trigger_speed = 0.2,
    stop_trigger =
    {
      {
        type = "play-sound",
        sound =
        {
          {
            filename = "__base__/sound/car-breaks.ogg",
            volume = 0.6
          },
        }
      },
    },
    sound_minimum_speed = 0.2;
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    working_sound =
    {
      sound =
      {
        filename = "__base__/sound/car-engine.ogg",
        volume = 0.6
      },
      activate_sound =
      {
        filename = "__base__/sound/car-engine-start.ogg",
        volume = 0.6
      },
      deactivate_sound =
      {
        filename = "__base__/sound/car-engine-stop.ogg",
        volume = 0.6
      },
      match_speed_to_activity = true,
    },
    open_sound = { filename = "__base__/sound/car-door-open.ogg", volume=0.7 },
    close_sound = { filename = "__base__/sound/car-door-close.ogg", volume = 0.7 },
    rotation_speed = 0.001,
    weight = 35000,
    tank_driving = true,
    inventory_size = 30
  },


  {
    type = "storage-tank",
    name = "independant-item-elevator-upperside",
    icon = "__base__/graphics/icons/storage-tank.png",
    flags = {},
    minable = {mining_time = 1, result = "independant-item-elevator"},
    max_health = 300,
    corpse = "small-remnants",
    collision_box = {{-1, -1}, {1, 1}},
    selection_box = {{-1, -1}, {1, 1}},
    fluid_box =
    {
      base_area = 10,
      base_level = -1,
      pipe_connections = {},
    },
    window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
    pictures =
    {
      picture =
      {
        sheet =
        {
          filename = "__Subsurface__/graphics/entities/item-elevator-top.png",
          priority = "extra-high",
          frames = 4,
          width = 64,
          height = 64,
          shift = {0, 0}
        }
      },
      fluid_background = blank4StorageTank(),
      window_background = blank4StorageTank(),
      flow_sprite = blank4StorageTank(),
    },
    flow_length_in_ticks = 0,
    circuit_wire_connection_points =
    {
      {shadow = { red = {0, 0}, green = {0,0} },  wire = { red = {0, 0}, green = {0,0} },},
      {shadow = { red = {0, 0}, green = {0,0} },  wire = { red = {0, 0}, green = {0,0} },},
      {shadow = { red = {0, 0}, green = {0,0} },  wire = { red = {0, 0}, green = {0,0} },},
      {shadow = { red = {0, 0}, green = {0,0} },  wire = { red = {0, 0}, green = {0,0} },},
    },
    circuit_wire_max_distance = 0,        
  },

  {
    type = "storage-tank",
    name = "independant-item-elevator-lowerside",
    icon = "__base__/graphics/icons/storage-tank.png",
    flags = {},
    minable = {mining_time = 1, result = "independant-item-elevator"},
    max_health = 300,
    corpse = "small-remnants",
    collision_box = {{-1, -1}, {1, 1}},
    selection_box = {{-1, -1}, {1, 1}},
    fluid_box =
    {
      base_area = 10,
      base_level = -1,
      pipe_connections = {},
    },
    window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
    pictures =
    {
      picture =
      {
        sheet =
        {
          filename = "__Subsurface__/graphics/entities/item-elevator-bottom.png",
          priority = "extra-high",
          frames = 4,
          width = 64,
          height = 64,
          shift = {0, 0}
        }
      },
      fluid_background = blank4StorageTank(),
      window_background = blank4StorageTank(),
      flow_sprite = blank4StorageTank(),
    },
    flow_length_in_ticks = 0,
    circuit_wire_connection_points =
    {
      {shadow = { red = {0, 0}, green = {0,0} },  wire = { red = {0, 0}, green = {0,0} },},
      {shadow = { red = {0, 0}, green = {0,0} },  wire = { red = {0, 0}, green = {0,0} },},
      {shadow = { red = {0, 0}, green = {0,0} },  wire = { red = {0, 0}, green = {0,0} },},
      {shadow = { red = {0, 0}, green = {0,0} },  wire = { red = {0, 0}, green = {0,0} },},
    },
    circuit_wire_max_distance = 0,        
  },

  {
    type = "decorative",
    name = "selection-marker",
    flags = {"not-on-map"},
    icon = "__Subsurface__/graphics/entities/selection-marker.png",
    collision_mask = {"ghost-layer"},
    subgroup = "grass",
    order = "b[decorative]-b[selection-marker]",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selectable_in_game = false,
    render_layer = "selection-box",
    pictures =
    {
      {
        filename = "__Subsurface__/graphics/entities/selection-marker.png",
        width = 32,
        height = 32,
        priority = "high",
      }
    }
  },
  {
    type = "decorative",
    name = "digging-marker",
    flags = {},
    icon = "__Subsurface__/graphics/entities/marked-for-digging.png",
    collision_mask = { "ghost-layer"},
    subgroup = "grass",
    order = "b[decorative]-b[m2k-dbg-overlay-blue]",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selectable_in_game = false,
    render_layer = "floor",
    pictures =
    {
      {
        filename = "__Subsurface__/graphics/entities/marked-for-digging.png",
        width = 32,
        height = 32,
        priority = "high",
      }
    }
  },
  {
    type = "decorative",
    name = "pending-digging",
    flags = {},
    icon = "__Subsurface__/graphics/entities/pending-digging.png",
    collision_mask = { "ghost-layer"},
    subgroup = "grass",
    order = "b[decorative]-b[m2k-dbg-overlay-blue]",
    collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    selectable_in_game = false,
    render_layer = "floor",
    pictures =
    {
      {
        filename = "__Subsurface__/graphics/entities/pending-digging.png",
        width = 32,
        height = 32,
        priority = "high",
      }
    }
  },




  {
    type = "assembling-machine",
    name = "digging-robots-deployment-center",
    icon = "__base__/graphics/icons/assembling-machine-3.png",
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "digging-robots-deployment-center"},
    max_health = 200,
    corpse = "big-remnants",
    dying_explosion = "massive-explosion",
    crafting_categories = {"deploy-entity"},
    ingredient_count = 2,
    fixed_recipe = "deploy-digging-robots",
    collision_box = {{-1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
    animation =
    {
      filename = "__base__/graphics/entity/assembling-machine-3/assembling-machine-3.png",
      priority = "high",
      width = 142,
      height = 113,
      frame_count = 32,
      line_length = 8,
      shift = {0.84, -0.09}
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
}
)