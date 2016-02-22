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
{
    type = "recipe",
    name = "mobile-borer",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "mobile-borer"
  },  
  {
    type = "recipe",
    name = "fluid-elevator-mk1",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "fluid-elevator-mk1"
  }, 
  
  {
    type = "recipe",
    name = "dummy-air-vent-recipe",
    enabled = true,
    hidden = true,
    category = "dummy-recipe-category",
    energy_required = 10000,
    ingredients = {},    
    results={{type="item", name="void", amount=1, probability=0},},
  }, 
  
 })
 