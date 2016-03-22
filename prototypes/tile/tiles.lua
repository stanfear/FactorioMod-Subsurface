data:extend(
{
  {
    type = "tile",
    name = "caveground",
    needs_correction = false,
    mined_sound = { filename = "__base__/sound/deconstruct-bricks.ogg" },
    collision_mask = {"ground-tile"},
    walking_speed_modifier = 1.4,
    layer = 61,
    variants =
    {
      main =
      {
        {
          picture = "__Subsurface__/graphics/terrain/underground-dirt/underground-dirt.png",
          count = 4,
          size = 1
        }
      },
      inner_corner =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt/underground-dirt-inner-corner.png",
        count = 1
      },
      outer_corner =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt/underground-dirt-outer-corner.png",
        count = 1
      },
      side =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt/underground-dirt-side.png",
        count = 4
      },
      u_transition =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt/underground-dirt-u.png",
        count = 1
      },
      o_transition =
      {
        picture = "__Subsurface__/graphics/terrain/underground-dirt/underground-dirt-o.png",
        count = 1
      }
    },
    walking_sound =
    {
      {
        filename = "__base__/sound/walking/dirt-02.ogg",
        volume = 0.8
      },
      {
        filename = "__base__/sound/walking/dirt-03.ogg",
        volume = 0.8
      },
      {
        filename = "__base__/sound/walking/dirt-04.ogg",
        volume = 0.8
      }
    },
    map_color={r=0.5, g=0.332, b=0.144},
    ageing=0
  },
  {
    type = "tile",
    name = "cave-walls",
    collision_mask =
    {
      "ground-tile",
      --"water-tile",
      "resource-layer",
      --"floor-layer",
      --"item-layer",
      --"object-layer",
      --"player-layer",
      "doodad-layer"
    },
    layer = 60,
    variants =
    {
      main =
      {
        {
          picture = "__Subsurface__/graphics/terrain/cave-walls/cave-walls.png",
          count = 4,
          size = 1
        }
      },
      inner_corner =
      {
        picture = "__Subsurface__/graphics/terrain/cave-walls/cave-walls-inner-corner.png",
        count = 1
      },
      outer_corner =
      {
        picture = "__Subsurface__/graphics/terrain/cave-walls/cave-walls-outer-corner.png",
        count = 1
      },
      side =
      {
        picture = "__Subsurface__/graphics/terrain/cave-walls/cave-walls-side.png",
        count = 1
      },
      u_transition =
      {
        picture = "__Subsurface__/graphics/terrain/cave-walls/cave-walls-u.png",
        count = 1
      },
      o_transition =
      {
        picture = "__Subsurface__/graphics/terrain/cave-walls/cave-walls-o.png",
        count = 1
      }
    },
    map_color={r=0.367, g=0.234, b=0.082},
    ageing=0.0006
  },
})