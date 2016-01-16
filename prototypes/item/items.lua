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
})