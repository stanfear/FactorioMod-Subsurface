data:extend(
{
  {
    type = "technology",
    name = "tunnel-entrance",
    icon = "__base__/graphics/icons/electric-mining-drill.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "surface-driller"
      },
    },
    prerequisites = {},
    unit = {
      count = 5,
      ingredients = {
        {"science-pack-1", 1}
      },
      time = 1
    },
    order = "c-g-b-z",
  }
})