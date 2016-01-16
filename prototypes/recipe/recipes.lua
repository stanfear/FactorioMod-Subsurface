data:extend(
{
  {
    type = "recipe",
    name = "surface-driller",
    enabled = "true",
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "surface-driller"
  },
  {
    type = "recipe",
    name = "air-vent",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "air-vent"
  }, 
  {
    type = "recipe",
    name = "active-air-vent",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "active-air-vent"
  },

  {
    type = "recipe",
    name = "drilling",
    enabled = true,
    hidden = true,
    category = "digging",
    energy_required = 10,
    ingredients = {},
    results=
    {
      {type="item", name="stone", amount=50}
    }
  },
 })
 