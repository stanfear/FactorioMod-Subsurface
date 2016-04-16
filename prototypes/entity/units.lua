function biterattackanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        width = 279,
        height = 184,
        frame_count = 11,
        direction_count = 16,
        shift = {scale * 1.74609, scale * -0.644531},
        animation_speed = 0.3,
        scale = scale,
        stripes =
        {
         {
          filename = "__base__/graphics/entity/biter/biter-attack-1.png",
          width_in_frames = 6,
          height_in_frames = 8,
         },
         {
          filename = "__base__/graphics/entity/biter/biter-attack-2.png",
          width_in_frames = 5,
          height_in_frames = 8,
         },
         {
          filename = "__base__/graphics/entity/biter/biter-attack-3.png",
          width_in_frames = 6,
          height_in_frames = 8,
         },
         {
          filename = "__base__/graphics/entity/biter/biter-attack-4.png",
          width_in_frames = 5,
          height_in_frames = 8,
         }
        }
      },

      {
        filename = "__base__/graphics/entity/biter/biter-attack-mask1.png",
        width = 125,
        height = 108,
        frame_count = 11,
        direction_count = 16,
        shift = {scale * 0.117188, scale * -1.11328},
        scale = scale,
        tint = tint1,
      },

      {
        filename = "__base__/graphics/entity/biter/biter-attack-mask2.png",
        width = 114,
        height = 100,
        frame_count = 11,
        direction_count = 16,
        shift = {scale * 0.117188, scale * -1.06641},
        scale = scale,
        tint = tint2
      }
    }
  }
end
function biterdieanimation(scale, tint1, tint2)
  return
  {
    layers=
    {
      {
        width = 190,
        height = 129,
        frame_count = 17,
        direction_count = 16,
        shift = {scale * 0.621094, scale * -0.1875},
        scale = scale,
        stripes =
        {
          {
            filename = "__base__/graphics/entity/biter/biter-die-1.png",
            width_in_frames = 9,
            height_in_frames = 8,
          },
          {
            filename = "__base__/graphics/entity/biter/biter-die-2.png",
            width_in_frames = 8,
            height_in_frames = 8,
          },
          {
            filename = "__base__/graphics/entity/biter/biter-die-3.png",
            width_in_frames = 9,
            height_in_frames = 8,
          },
          {
            filename = "__base__/graphics/entity/biter/biter-die-4.png",
            width_in_frames = 8,
            height_in_frames = 8,
          }
        }
      },

      {
        filename = "__base__/graphics/entity/biter/biter-die-mask1.png",
        width = 120,
        height = 109,
        frame_count = 17,
        direction_count = 16,
        shift = {scale * 0.117188, scale * -0.574219},
        scale = scale,
        tint = tint1
      },

      {
        filename = "__base__/graphics/entity/biter/biter-die-mask2.png",
        width = 115,
        height = 108,
        frame_count = 17,
        direction_count = 16,
        shift = {scale * 0.128906, scale * -0.585938},
        scale = scale,
        tint = tint2
      }
    }
  }
end



mediumbiterscale = 0.5
medium_biter_tint1 = {r=0.1, g=0.9, b=0.15, a=0.6}
medium_biter_tint2 = {r=0.1, g=0.9, b=0.3, a=0.75}

data:extend(
{
  {
    type = "unit",
    name = "digging-robot",
    icon = "__base__/graphics/icons/medium-biter.png",
    flags = {"placeable-off-grid"},
    max_health = 5,
    order="b-b-b",
    subgroup="enemies",
    resistances ={ },
    healing_per_tick = 0,
    collision_box = {{-0.05, -0.05}, {0.05, 0.05}},
    selection_box = {{-0.7, -0.7}, {0.7, 0.7}},
    sticker_box = {{-0.3, -0.5}, {0.3, 0.1}},
    distraction_cooldown = 300,
    attack_parameters =
    {
      type = "projectile",
      ammo_category = "digging-explosives",
      cooldown = 100,
      range = 0.5,
      ammo_type =
      {
        category = "digging-explosives",
        action =
        {
          type = "direct",
          action_delivery =
          {
            type = "instant",
            target_effects =
            {
              type = "create-entity",
              entity_name = "digging-explosion",
              offsets = {{0, 0}},
              trigger_created_entity=true,
            }
          }
        }
      },
      animation = biterattackanimation(mediumbiterscale, medium_biter_tint1, medium_biter_tint2)
    },
    vision_distance = 30,
    movement_speed = 0.185,
    distance_per_frame = 0.15,
    -- in pu
    pollution_to_join_attack = 1000,
    corpse = "medium-biter-corpse",
    dying_explosion = "explosion",
    working_sound = make_biter_calls(0.8),
    dying_sound = make_biter_dying_sounds(1.0),
    run_animation = biterrunanimation(mediumbiterscale, medium_biter_tint1, medium_biter_tint2)
  },



  {
    type = "explosion",
    name = "digging-explosion",
    flags = {"not-on-map"},
    animations =
    {
      {
        filename = "__base__/graphics/entity/explosion/explosion-1.png",
        priority = "extra-high",
        width = 64,
        height = 59,
        frame_count = 16,
        animation_speed = 0.5,
        shift = {0, 1},
      }
    },
    light = {intensity = 1, size = 3},
    smoke = "smoke-fast",
    smoke_count = 2,
    smoke_slow_down_factor = 1,
    sound =
    {
      {
        filename = "__base__/sound/fight/small-explosion-1.ogg",
        volume = 0.75
      }
    }
  },
})