local deterministic_recycler_recipe = table.deepcopy(data.raw["recipe"]["recycler"])

deterministic_recycler_recipe.name = "deterministic-recycler"
deterministic_recycler_recipe.ingredients = {
  {
    amount = 9,
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
deterministic_recycler_recipe.results =
{
  {
    amount = 1,
    name = "deterministic-recycler",
    type = "item"
  }
}

local deterministic_recycler_recipe_2 = table.deepcopy(deterministic_recycler_recipe)
deterministic_recycler_recipe_2.name = "deterministic-recycler-2"
deterministic_recycler_recipe_2.ingredients = {
  {
    amount = 12,
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
deterministic_recycler_recipe_2.results =
{
  {
    amount = 1,
    name = "deterministic-recycler-2",
    type = "item"
  }
}

data:extend({deterministic_recycler_recipe, deterministic_recycler_recipe_2})

data:extend({
  {
    type = 'recipe',
    name = 'test',
    category = 'recycling',
    results = {{type = 'item', name = 'loader', amount = 1}}
  }
})