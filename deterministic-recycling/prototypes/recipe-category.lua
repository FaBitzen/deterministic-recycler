data:extend{
    {
      type = "recipe-category",
      name = "recycling-deterministic"
    },
    {
      type = "recipe-category",
      name = "deterministic-framing"
    }
}

table.insert(data.raw["utility-constants"]["default"]["factoriopedia_recycling_recipe_categories"], "recycling-deterministic")
table.insert(data.raw["utility-constants"]["default"]["factoriopedia_recycling_recipe_categories"], "deterministic-framing")

-- until bug is fixed
table.insert(data.raw['assembling-machine']['deterministic-recycler-2']['crafting_categories'], 'deterministic-framing')
