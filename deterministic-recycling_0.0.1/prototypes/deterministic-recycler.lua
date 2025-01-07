local deterministic_recycler_item = table.deepcopy(data.raw["item"]["recycler"])
local deterministic_recycler = table.deepcopy(data.raw["furnace"]["recycler"])
local deterministic_recycler_tint = {r=0.7, g=0.9, b=0.7, a=1}
local deterministic_recycler_item_tint = {r=0.7, g=1, b=0.7, a=1}

deterministic_recycler_item.name = "deterministic-recycler"
deterministic_recycler_item.icons = 
{
    {
        icon = deterministic_recycler_item.icon,
        tint = deterministic_recycler_item_tint
    }
}

deterministic_recycler.name = deterministic_recycler_item.name
deterministic_recycler.icons = deterministic_recycler_item.icons

deterministic_recycler_item.place_result = deterministic_recycler.name

deterministic_recycler.minable.result = deterministic_recycler_item.name

deterministic_recycler.crafting_categories = {
    "recycling-deterministic"
}

for _, graphic in pairs(deterministic_recycler.graphics_set.animation) do
    graphic.layers[1].tint = deterministic_recycler_tint
end

for _, graphic in pairs(deterministic_recycler.graphics_set_flipped.animation) do
    graphic.layers[1].tint = deterministic_recycler_tint
end

data:extend{deterministic_recycler, deterministic_recycler_item}

table.insert(data.raw["technology"]["recycling"].effects, {recipe = "deterministic-recycler", type = "unlock-recipe"})

if mods["space-age"] then
    table.insert(data.raw["technology"]["recycling"].effects, {recipe = "scrap-recycling-deterministic", type = "unlock-recipe"})
    table.insert(data.raw["technology"]["scrap-recycling-productivity"].effects, {change = 0.1, recipe = "scrap-recycling-deterministic", type = "change-recipe-productivity"})
end
