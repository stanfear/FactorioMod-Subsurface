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
        picture = "__base__/graphics/terrain/concrete/concrete-inner-corner.png",
        count = 8
      },
      outer_corner =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-outer-corner.png",
        count = 8
      },
      side =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-side.png",
        count = 8
      },
      u_transition =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-u.png",
        count = 8
      },
      o_transition =
      {
        picture = "__base__/graphics/terrain/concrete/concrete-o.png",
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
    map_color={r=0.312, g=0.25, b=0.187},
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
        },
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
        count = 4
      }
    },
    map_color={r=0, g=0, b=0},
    ageing=0.0006
  },
})