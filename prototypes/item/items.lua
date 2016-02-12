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
    icon = "__Subsurface__/graphics/entities/air-vent.png",
    flags = {"goes-to-quickbar"},
    subgroup = "production-machine",
    order = "a[air-vent-1]",
    place_result = "air-vent",
    stack_size = 50
  },
  {
    type = "item",
    name = "active-air-vent",
    icon = "__Subsurface__/graphics/entities/air-vent.png",
    flags = {"goes-to-quickbar"},
    subgroup = "production-machine",
    order = "a[air-vent-2]",
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
    icon = "__base__/graphics/icons/car.png",
    flags = {"goes-to-quickbar"},
    subgroup = "transport",
    order = "b[personal-transport]-a[car]",
    place_result = "fluid-elevator-mk1",
    stack_size = 10
  },

})