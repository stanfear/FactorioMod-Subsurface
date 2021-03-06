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
    energy_required = 1,
    ingredients = {},    
    results={{type="item", name="iron-plate", amount=1, probability=0},},
  }, 
  
  {
    type = "recipe",
    name = "independant-item-elevator",
    enabled = true,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "independant-item-elevator"
  },    

  {
    type = "recipe",
    name = "digging-robots-deployment-center",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "digging-robots-deployment-center"
  },

  {
    type = "recipe",
    name = "assemble-digging-robots",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 2},
    },
    result = "assembled-digging-robots"
  },

  {
    type = "recipe",
    name = "deploy-digging-robots",
    enabled = true,
    hidden = true,
    category = "deploy-entity",
    ingredients =
    {
      {"assembled-digging-robots", 1},
    },
    result = "prepared-digging-robots"
  },

  {
    type = "recipe",
    name = "digging-planner",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 2}
    },
    result = "digging-planner"
  },



 })
 