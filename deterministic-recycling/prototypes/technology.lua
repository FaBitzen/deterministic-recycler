local replace_recycling_recipes = settings.startup["deterministic-recycling-replace-recycling-recipes"].value

if not replace_recycling_recipes then
    table.insert(data.raw["technology"]["recycling"].effects, {recipe = "deterministic-recycler", type = "unlock-recipe"})
    table.insert(data.raw["technology"]["recycling"].effects, {recipe = "deterministic-recycler-2", type = "unlock-recipe"})
end

if mods["space-age"] and not replace_recycling_recipes then
    table.insert(data.raw["technology"]["recycling"].effects, {recipe = "scrap-recycling-deterministic", type = "unlock-recipe"})
    table.insert(data.raw["technology"]["scrap-recycling-productivity"].effects, {change = 0.1, recipe = "scrap-recycling-deterministic", type = "change-recipe-productivity"})
end
