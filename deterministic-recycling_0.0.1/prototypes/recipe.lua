local deterministic_recycler = table.deepcopy(data.raw["recipe"]["recycler"])

deterministic_recycler.name = "deterministic-recycler"
deterministic_recycler.ingredients = {
  {
    amount = 10,
    name = "processing-unit",
    type = "item"
  },
  {
    amount = 20,
    name = "steel-plate",
    type = "item"
  },
  {
    amount = 40,
    name = "iron-gear-wheel",
    type = "item"
  },
  {
    amount = 20,
    name = "concrete",
    type = "item"
  }
}
deterministic_recycler.results = 
{
  {
    amount = 1,
    name = "deterministic-recycler",
    type = "item"
  }
}

local deterministic_recycler_recycling = table.deepcopy(data.raw["recipe"]["recycler-recycling"])

deterministic_recycler_recycling.name = "deterministic-recycler-recycling"
deterministic_recycler_recycling.ingredients =
{
  {
    amount = 1,
    name = "deterministic-recycler",
    type = "item"
  }
}
deterministic_recycler_recycling.localised_name =
{
  "recipe-name.recycling",
  {
    "entity-name.deterministic-recycler"
  }
}
deterministic_recycler_recycling.results =
{
  {
    amount = 2.5,
    extra_count_fraction = 0.5,
    name = "processing-unit",
    type = "item"
  },
  {
    amount = 5,
    extra_count_fraction = 0,
    name = "steel-plate",
    type = "item"
  },
  {
    amount = 10,
    extra_count_fraction = 0,
    name = "iron-gear-wheel",
    type = "item"
  },
  {
    amount = 5,
    extra_count_fraction = 0,
    name = "concrete",
    type = "item"
  }
}

data:extend({deterministic_recycler, deterministic_recycler_recycling})

function fancy_up_icons(icons)
  local fancy_icons = {icons[1]}
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

  table.insert(fancy_icons, icons[#icons])
  return fancy_icons
end

if mods["space-age"] then
  local scrap_recycling_deterministic = table.deepcopy(data.raw["recipe"]["scrap-recycling"])

  scrap_recycling_deterministic.localised_name = {
    "recipe-name.recycling",
    {
      "item-name.scrap"
    }
  }
  scrap_recycling_deterministic.name = "scrap-recycling-deterministic"


  scrap_recycling_deterministic.category = "recycling-deterministic"

  scrap_recycling_deterministic.energy_required = scrap_recycling_deterministic.energy_required * 100

  scrap_recycling_deterministic.ingredients =
  {
    {
      amount = 100,
      name = "scrap",
      type = "item"
    }
  }

  scrap_recycling_deterministic.results =
  {
    {type = "item", name = "processing-unit",        amount = 2, show_details_in_recipe_tooltip = false},
    {type = "item", name = "advanced-circuit",       amount = 3, show_details_in_recipe_tooltip = false},
    {type = "item", name = "low-density-structure",  amount = 1, show_details_in_recipe_tooltip = false},
    {type = "item", name = "solid-fuel",             amount = 7, show_details_in_recipe_tooltip = false},
    {type = "item", name = "steel-plate",            amount = 4, show_details_in_recipe_tooltip = false},
    {type = "item", name = "concrete",               amount = 6, show_details_in_recipe_tooltip = false},
    {type = "item", name = "battery",                amount = 4, show_details_in_recipe_tooltip = false},
    {type = "item", name = "ice",                    amount = 5, show_details_in_recipe_tooltip = false},
    {type = "item", name = "stone",                  amount = 4, show_details_in_recipe_tooltip = false},
    {type = "item", name = "holmium-ore",            amount = 1, show_details_in_recipe_tooltip = false},
    {type = "item", name = "iron-gear-wheel",        amount = 20, show_details_in_recipe_tooltip = false},
    {type = "item", name = "copper-cable",           amount = 3, show_details_in_recipe_tooltip = false}
  }

  scrap_recycling_deterministic.icons = fancy_up_icons(scrap_recycling_deterministic.icons)

  data:extend({scrap_recycling_deterministic})
end



function adjust_recipe_amount(recipe, factor)
  recipe.energy_required = recipe.energy_required * factor

  for _, ingredient in ipairs(recipe.ingredients) do
    ingredient.amount = ingredient.amount * factor
    if ingredient.ignored_by_stats then
      ingredient.ignored_by_stats = ingredient.ignored_by_stats * factor
    end
  end

  for _, result in ipairs(recipe.results) do
    result.amount = result.amount * factor

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

function generate_determinstic_recipe(recipe)
  local deterministic_recipe = table.deepcopy(recipe)
  deterministic_recipe.hidden = true
  deterministic_recipe.category = "recycling-deterministic"
  deterministic_recipe.name = deterministic_recipe.name .. "-deterministic"
  deterministic_recipe.icons = fancy_up_icons(deterministic_recipe.icons)
  adjust_recipe_amount(deterministic_recipe, 4)

  return deterministic_recipe
end

local deterministic_recycler_recipes = {}
for _, recipe in pairs(data.raw["recipe"]) do
  if recipe.category == "recycling" then
    if recipe.ingredients[1].name ~= recipe.results[1].name then -- don't do self recycling recipes
      table.insert(deterministic_recycler_recipes, generate_determinstic_recipe(recipe))
    end
  end
end
data:extend(deterministic_recycler_recipes)