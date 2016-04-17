data:extend(
{
  {
    type = "item",
    name = "surface-driller",
    icon = "__base__/graphics/icons/assembling-machine-1.png",
    flags = {"goes-to-quickbar"},
    subgroup = "production-machine",
    order = "a[assembling-machine-1]",
    place_result = "surface-driller",
    stack_size = 50
  },
  {
    type = "item",
    name = "air-vent",
    icon = "__Subsurface__/graphics/icons/air_vent_11_icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "inter-surface-transport",
    order = "a[air-vent-passive]",
    place_result = "air-vent",
    stack_size = 50
  }, 
  {
    type = "item",
    name = "active-air-vent",
    icon = "__Subsurface__/graphics/icons/air_vent_22_icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "inter-surface-transport",
    order = "b[air-vent-active]",
    place_result = "active-air-vent",
    stack_size = 50
  },
  {
    type = "item",
    name = "mobile-borer",
    icon = "__base__/graphics/icons/car.png",
    flags = {"goes-to-quickbar"},
    subgroup = "transport",
    order = "b[personal-transport]-a[car]",
    place_result = "mobile-borer",
    stack_size = 1
  },

  {
    type = "item",
    name = "fluid-elevator-mk1",
    icon = "__Subsurface__/graphics/icons/fluid_elevator_mk1_icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "inter-surface-transport",
    order = "d[fluid]-a[fluid-elevator-mk1]",
    place_result = "fluid-elevator-mk1",
    stack_size = 10
  },

  {
    type = "item",
    name = "independant-item-elevator",
    icon = "__Subsurface__/graphics/icons/items-elevator-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "inter-surface-transport",
    order = "c[transport-belt]-c[items-elevator-mk1]",
    place_result = "independant-item-elevator-placer",
    stack_size = 10
  },

  {
    type = "item",
    name = "digging-planner",
    icon = "__Subsurface__/graphics/icons/digging-planner-icon.png",
    flags = {"goes-to-quickbar"},
    subgroup = "tool",
    order = "c[automated-construction]-c[digging-planner]",
    place_result = "selection-marker",
    stack_size = 1
  },
  {
    type = "item",
    name = "digging-robots-deployment-center",
    icon = "__base__/graphics/icons/assembling-machine-1.png",
    flags = {"goes-to-quickbar"},
    subgroup = "production-machine",
    order = "a[assembling-machine-1]",
    place_result = "digging-robots-deployment-center",
    stack_size = 50
  },

  {
    type = "item",
    name = "assembled-digging-robots",
    icon = "__base__/graphics/icons/assembling-machine-1.png",
    flags = {},
    subgroup = "production-machine",
    order = "a[assembling-machine-1]",
    stack_size = 50
  },

  {
    type = "item",
    name = "prepared-digging-robots",
    icon = "__base__/graphics/icons/assembling-machine-1.png",
    flags = {"hidden"},
    subgroup = "production-machine",
    order = "a[assembling-machine-1]",
    stack_size = 1
  },
})