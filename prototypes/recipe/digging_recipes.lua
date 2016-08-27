for i=1,9 do
  data:extend(
  {
    {
      type = "recipe",
      name = "surface-drilling-down-" .. i,
      enabled = true,
      hidden = false,
      category = "digging",
      energy_required = 1,
      ingredients = {},
      results=
      {
        {type="item", name="stone", amount=1}
      },
      icon = "__Subsurface__/graphics/icons/Digging_icon_"..i..".png",
      group = "digging",
      subgroup = "digg-down",
    }
  })
end
