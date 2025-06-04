data:extend{
  {
    type = 'item-group',
    name = 'deterministic-recycling',
    order = 'ca',
    icons = {
      {
        icon = '__quality__/graphics/icons/recycling.png',
        icon_size = 64,
        tint = {r=0.8, g=0.1, b=0.8, a=1},
        scale = 2
      }
    }
  }
}

data:extend{
  {
    type = 'item-subgroup',
    name = 'deterministic-recycling',
    group = 'deterministic-recycling',
    order = 'b'
  },
  {
    type = 'item-subgroup',
    name = 'deterministic-framing',
    group = 'deterministic-recycling',
    order = 'a'
  }
}