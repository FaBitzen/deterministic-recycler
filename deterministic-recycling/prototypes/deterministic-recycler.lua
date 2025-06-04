local deterministic_recycler_tint = {r=0.4, g=0.6, b=0.9, a=1}
local deterministic_recycler_item_tint = {r=0.4, g=0.6, b=1, a=1}
local deterministic_recycler_2_tint = {r=0.7, g=0.7, b=0.4, a=1}
local deterministic_recycler_2_item_tint = {r=0.7, g=0.7, b=0.4, a=1}

local function copy_recycler(new_name, new_type, new_tint, new_item_tint)
    local deterministic_recycler_item = table.deepcopy(data.raw["item"]["recycler"])
    local deterministic_recycler = table.deepcopy(data.raw["furnace"]["recycler"])

    deterministic_recycler_item.name = new_name
    deterministic_recycler_item.icons =
    {
        {
            icon = deterministic_recycler_item.icon,
            tint = new_item_tint
        }
    }

    deterministic_recycler.name = deterministic_recycler_item.name
    deterministic_recycler.type = new_type
    deterministic_recycler.icons = deterministic_recycler_item.icons

    deterministic_recycler_item.place_result = deterministic_recycler.name

    deterministic_recycler.minable.result = deterministic_recycler_item.name

    deterministic_recycler.cant_insert_at_source_message_key = 'inventory-restriction.cant-be-deterministicly-recycled'

    if settings.startup["deterministic-recycling-replace-recycling-recipes"].value then
        deterministic_recycler.crafting_categories = {
            "recycling",
            "recycling-or-hand-crafting",
            "recycling-deterministic",
            --'deterministic-framing'
        }
    else
        deterministic_recycler.crafting_categories = {
            "recycling-deterministic",
            --'deterministic-framing'
        }
    end


    for _, graphic in pairs(deterministic_recycler.graphics_set.animation) do
        graphic.layers[1].tint = new_tint
    end

    for _, graphic in pairs(deterministic_recycler.graphics_set_flipped.animation) do
        graphic.layers[1].tint = new_tint
    end

    data:extend{deterministic_recycler, deterministic_recycler_item}
end

copy_recycler("deterministic-recycler", "furnace", deterministic_recycler_tint, deterministic_recycler_item_tint)
copy_recycler("deterministic-recycler-2", "assembling-machine", deterministic_recycler_2_tint, deterministic_recycler_2_item_tint)


data.raw["heat-pipe"]["heat-pipe"].heating_energy = "1MW"