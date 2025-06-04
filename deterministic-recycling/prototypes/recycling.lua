local replace_recycling_recipes = settings.startup["deterministic-recycling-replace-recycling-recipes"].value


local function fancy_up_icons(icons)
  if not icons then return end
  local recycling_tint = {r=0.8, g=0.1, b=0.8, a=1}
  local icon_recycling = icons[1]
  icon_recycling["tint"] = recycling_tint
  local fancy_icons = {icon_recycling}
  local shift_offset = 2

  for i = 2, #icons - 1 do
    local new_icon = table.deepcopy(icons[i])
    if new_icon.shift then
      new_icon.shift[1] = new_icon.shift[1] - shift_offset
      new_icon.shift[2] = new_icon.shift[2] + shift_offset
    else
      new_icon.shift = {-shift_offset, shift_offset}
    end

    table.insert(fancy_icons, new_icon)
  end

  for i = 2, #icons - 1 do
    local icon = icons[i]
      if icon.shift then
        icon.shift[1] = icon.shift[1] + shift_offset
        icon.shift[2] = icon.shift[2] - shift_offset
      else
        icon.shift = {shift_offset, -shift_offset}
      end

      if icon.scale then
        icon.scale = icon.scale * 0.8
      end

    table.insert(fancy_icons, icon)
  end

  local icon_recycling_top = icons[#icons]
  icon_recycling_top["tint"] = recycling_tint
  table.insert(fancy_icons, icon_recycling_top)
  return fancy_icons
end


if mods["space-age"] then
  local scrap_recycling_deterministic = table.deepcopy(data.raw["recipe"]["scrap-recycling"])

  scrap_recycling_deterministic.localised_name = {
      "recipe-name.deterministic-recycling",
      {
      "item-name.scrap"
      }
  }

  if not replace_recycling_recipes then
      scrap_recycling_deterministic.name = "scrap-recycling-deterministic"
      scrap_recycling_deterministic.category = "recycling-deterministic"
  end

  scrap_recycling_deterministic.energy_required = scrap_recycling_deterministic.energy_required * 100

  scrap_recycling_deterministic.ingredients =
  {
      {
      amount = 100,
      name = "scrap",
      type = "item"
      }
  }

  for _, result in ipairs(scrap_recycling_deterministic.results) do
      result.amount = result.probability * 100
      result.probability = 1
  end

  scrap_recycling_deterministic.icons = fancy_up_icons(scrap_recycling_deterministic.icons)

  data:extend({scrap_recycling_deterministic})
end


local function get_prototype(base_type, name)
  for type_name in pairs(defines.prototypes[base_type]) do
    local prototypes = data.raw[type_name]
    if prototypes and prototypes[name] then
      return prototypes[name]
    end
  end
end

local function get_item_localised_name(name)
  local item = get_prototype("item", name)
  if not item then return end
  if item.localised_name then
    return item.localised_name
  end
  local prototype
  local type_name = "item"
  if item.place_result then
    prototype = get_prototype("entity", item.place_result)
    type_name = "entity"
  elseif item.place_as_equipment_result then
    prototype = get_prototype("equipment", item.place_as_equipment_result)
    type_name = "equipment"
  elseif item.place_as_tile then
    -- Tiles with variations don't have a localised name
    local tile_prototype = data.raw.tile[item.place_as_tile.result]
    if tile_prototype and tile_prototype.localised_name then
      prototype = tile_prototype
      type_name = "tile"
    end
  end
  return prototype and prototype.localised_name or {type_name.."-name."..name}
end


local function do_deterministic_recycling(recipe)
    if recipe.category ~= "recycling" then return end
    -- no self recycling
    if recipe.ingredients and recipe.results and recipe.ingredients[1].name == recipe.results[1].name then return end
    return true
end


local function is_stackable(item)
  if item.flags and item.flags["not-stackable"] then return end
  if item.type == 'armor' and item.equipment_grid then return end
  return true
end


local function create_dummy_item(item)
  local dummy_item_name = item.name .. '-frame'
  local dummy_item = {
    type = 'item',
    name = dummy_item_name,
    stack_size = 4,
    localised_name = {'item-name.deterministic-recycling-frame',
      get_item_localised_name(item.name)},
    localised_description = {'item-description.deterministic-recycling-frame'},
    subgroup = 'deterministic-framing'
  }

  if item.icons then dummy_item.icons = item.icons
  elseif item.icon then
    local icon = {}
    icon.icon = item.icon
    if item.icon_size then
      icon.icon_size = item.icon_size
    end
    dummy_item.icons = {icon}
  end

  table.insert(dummy_item.icons, {
    icon = '__base__/graphics/icons/repair-pack.png',
    icon_size = 64,
    scale = 0.25,
    shift = {8, 8}
  })

  data:extend{dummy_item}
  return dummy_item_name
end


local function create_framing_recipe(ingredient_name, result_name)
  data:extend{
    {
      type = 'recipe',
      name = result_name,
      category = 'deterministic-framing',
      energy_required = 0.5,
      hide_from_player_crafting = true,
      hide_from_signal_gui = true,
      allow_productivity = false,
      allow_quality = false,
      subgroup = 'deterministic-framing',
      ingredients = {{ type = 'item', name = ingredient_name, amount = 1 }},
      results = {{ type = 'item', name = result_name, amount = 1 }},
      auto_recycle = false,
      localised_name = {'recipe-name.deterministic-framing', get_item_localised_name(ingredient_name)},
      show_amount_in_title = false,
      hidden = false
    }
  }
end


local function adjust_recipe_amount(recipe, factor)
  if recipe.energy_required then
    recipe.energy_required = recipe.energy_required * factor
  end

  if recipe.ingredients then
    for _, ingredient in ipairs(recipe.ingredients) do
        ingredient.amount = ingredient.amount * factor
        if ingredient.ignored_by_stats then
          ingredient.ignored_by_stats = ingredient.ignored_by_stats * factor
        end
    end
  end

  for _, result in ipairs(recipe.results) do
    if result.amount then
      result.amount = result.amount * factor
    else
      result.amount = 0.5 * (result.amount_min + result.amount_max) * factor
    end

    if result.extra_count_fraction then
      result.extra_count_fraction = result.extra_count_fraction * factor
      if result.extra_count_fraction >= 1 then
          result.extra_count_fraction = 0
      end
    end

    if result.ignored_by_stats then
      result.ignored_by_stats = result.ignored_by_stats * factor
    end
  end
end


local function get_factor(recipe)
  local factor = {4} -- at least take 4 ingredients as input
  for _, result in ipairs(recipe.results) do
      local fraction = result.extra_count_fraction
      if not fraction or fraction < 10e-5 then
        fraction = 1
      end
      table.insert(factor, 1/fraction)
  end
  return math.max(table.unpack(factor))
end


local function finish_deterministic_recycling_recipe(recipe)
  local factor = get_factor(recipe)
  adjust_recipe_amount(recipe, factor)
  if not replace_recycling_recipes then
    recipe.category = 'recycling-deterministic'
    recipe.name = recipe.name ..'-deterministic'
    recipe.auto_recycle = false
  end
  recipe.hide_from_player_crafting = true
  recipe.hide_from_signal_gui = false
  recipe.hidden = false
  recipe.hidden_in_factoriopedia = true
  recipe.icons = fancy_up_icons(recipe.icons)
  recipe.subgroup = 'deterministic-recycling'
  if recipe.localised_name then
    recipe.localised_name[1] = 'recipe-name.deterministic-recycling'
  else
    recipe.localised_name = {'recipe-name.deterministic-recycling', ''}
  end
  recipe.show_amount_in_title = false
  data:extend{recipe}
end


local function normalize_non_stacking_recipe(recipe, item)
  local dummy_item_name = create_dummy_item(item)
  create_framing_recipe(item.name, dummy_item_name)
  recipe.ingredients[1].name = dummy_item_name
  recipe.name = dummy_item_name .. '-recycling'
  if replace_recycling_recipes then
    recipe.name = item.name .. '-recycling'
    finish_deterministic_recycling_recipe(recipe)
  else
    data:extend{recipe}
  end
end


local function generate_determinstic_recipe(recipe)
  if not do_deterministic_recycling(recipe) then return end
  local deterministic_recipe = table.deepcopy(recipe)
  if recipe.ingredients then
    local item = get_prototype('item', recipe.ingredients[1].name)
    if not item then return end
    if not is_stackable(item) then
      normalize_non_stacking_recipe(deterministic_recipe, item)
      return
    end
  end
  finish_deterministic_recycling_recipe(deterministic_recipe)
end

for _, recipe in pairs(data.raw['recipe']) do
  generate_determinstic_recipe(recipe)
end