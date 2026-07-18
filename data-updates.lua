local function require_prototype(prototype_type, name)
    local prototypes = data.raw[prototype_type]
    local prototype = prototypes and prototypes[name]

    if not prototype then
        error(("Advanced Fluid Handling Continued for PyMods expected %s prototype '%s'"):format(prototype_type, name))
    end

    return prototype
end

local function remove_blacklisted_prototypes(blacklist)
    for _, prototype_type in ipairs({"item", "pipe", "pipe-to-ground", "storage-tank", "valve", "recipe"}) do
        local prototypes = data.raw[prototype_type]
        if prototypes then
            for name in pairs(blacklist) do
                prototypes[name] = nil
            end
        end
    end

    for _, technology in pairs(data.raw.technology or {}) do
        if technology.effects then
            local retained_effects = {}

            for _, effect in ipairs(technology.effects) do
                if not (effect.type == "unlock-recipe" and blacklist[effect.recipe]) then
                    retained_effects[#retained_effects + 1] = effect
                end
            end

            technology.effects = retained_effects
        end
    end
end

local blacklist = {
    ["4-to-4-pipe"] = true,
}

if not settings.startup["afhfp-keep-valves"].value then
    for threshold = 10, 90, 10 do
        blacklist[threshold .. "-overflow-valve"] = true
        blacklist[threshold .. "-top-up-valve"] = true
    end
    blacklist["check-valve"] = true
end

remove_blacklisted_prototypes(blacklist)

local pipe_bases = {
    "one-to-one-forward",
    "one-to-one-left",
    "one-to-one-reverse",
    "one-to-one-right",
    "one-to-two-perpendicular",
    "one-to-two-parallel",
    "one-to-two-perpendicular-secondary",
    "one-to-two-parallel-secondary",
    "one-to-two-L-FL",
    "one-to-two-L-FR",
    "one-to-two-L-RL",
    "one-to-two-L-RR",
    "one-to-three-forward",
    "one-to-three-left",
    "one-to-three-reverse",
    "one-to-three-right",
    "one-to-four",
    "underground-i",
    "underground-L",
    "underground-t",
    "underground-cross",
}

local tier_definitions = {
    [1] = {
        source_pipe = "pipe-to-ground",
        pump = "underground-mini-pump",
        tint = {r = 255, g = 191, b = 0, a = 0.5},
    },
    [2] = {
        source_pipe = "niobium-pipe-to-ground",
        pump = "underground-mini-pump-t2",
        connection_category = "niobium-pipe",
        tint = {r = 227, g = 38, b = 45, a = 0.5},
    },
    [3] = {
        source_pipe = "ht-pipes-to-ground",
        pump = "underground-mini-pump-t3",
        connection_category = "ht-pipes",
        tint = {r = 38, g = 173, b = 227, a = 0.5},
    },
}

local longer_undergrounds = settings.startup["afhfp-longer-undergrounds"].value
local braided_pipes = settings.startup["py-braided-pipes"].value

local function tiered_pipe_name(base_name, tier)
    local tier_suffix = tier == 1 and "" or "-t" .. tier
    return base_name .. tier_suffix .. "-pipe"
end

local function source_pipe_properties(source_name)
    local source = require_prototype("pipe-to-ground", source_name)
    local fluid_box = source.fluid_box
    local underground_connection

    for _, connection in ipairs(fluid_box.pipe_connections) do
        if connection.connection_type == "underground" then
            underground_connection = connection
            break
        end
    end

    if not underground_connection then
        error(("Pipe-to-ground prototype '%s' has no underground connection"):format(source_name))
    end

    return {
        distance = underground_connection.max_underground_distance + (longer_undergrounds and 1 or 0),
        extent = fluid_box.max_pipeline_extent,
    }
end

for tier, definition in pairs(tier_definitions) do
    local properties = source_pipe_properties(definition.source_pipe)
    definition.distance = properties.distance
    definition.extent = properties.extent

    for _, base_name in ipairs(pipe_bases) do
        local pipe = require_prototype("pipe-to-ground", tiered_pipe_name(base_name, tier))
        pipe.fluid_box.max_pipeline_extent = definition.extent

        for _, connection in ipairs(pipe.fluid_box.pipe_connections) do
            if connection.connection_type == "underground" then
                connection.max_underground_distance = definition.distance
            end

            if braided_pipes and definition.connection_category then
                connection.connection_category = definition.connection_category
            end
        end
    end
end

local vanilla_pump = require_prototype("pump", "pump")

local function tint_pump_arrows(pump, tint)
    for _, animation in pairs(pump.animations or {}) do
        for _, layer in ipairs(animation.layers or {}) do
            if layer.filename and string.find(layer.filename, "hr-ug-arrow", 1, true) then
                layer.tint = util.table.deepcopy(tint)
            end
        end
    end
end

for _, tier in ipairs({1, 2, 3}) do
    local definition = tier_definitions[tier]
    local pump = require_prototype("pump", definition.pump)

    for _, connection in ipairs(pump.fluid_box.pipe_connections) do
        if connection.connection_type == "underground" then
            connection.max_underground_distance = definition.distance
        end

        if braided_pipes and definition.connection_category then
            connection.connection_category = definition.connection_category
        end
    end

    pump.pumping_speed = vanilla_pump.pumping_speed
    pump.energy_usage = vanilla_pump.energy_usage

    local icon = pump.icon or (pump.icons and pump.icons[1] and pump.icons[1].icon)
    local icon_size = pump.icon_size or (pump.icons and pump.icons[1] and pump.icons[1].icon_size) or 64

    if icon then
        pump.icons = {
            {
                icon = icon,
                icon_size = icon_size,
                tint = {
                    r = definition.tint.r,
                    g = definition.tint.g,
                    b = definition.tint.b,
                },
            },
        }
        pump.icon = nil
        pump.icon_size = nil
    end

    tint_pump_arrows(pump, definition.tint)
end

local function set_recipe_ingredients(recipe_name, ingredients)
    require_prototype("recipe", recipe_name).ingredients = ingredients
end

set_recipe_ingredients("underground-mini-pump", {
    {type = "item", name = "iron-plate", amount = 4},
    {type = "item", name = "pump", amount = 1},
    {type = "item", name = "small-pipe-coupler", amount = 2},
    {type = "item", name = "underground-pipe-segment-t1", amount = 10},
})

set_recipe_ingredients("underground-mini-pump-t2", {
    {type = "item", name = "niobium-plate", amount = 4},
    {type = "item", name = "pump", amount = 1},
    {type = "item", name = "medium-pipe-coupler", amount = 2},
    {type = "item", name = "underground-pipe-segment-t2", amount = 10},
})

set_recipe_ingredients("underground-mini-pump-t3", {
    {type = "item", name = "niobium-plate", amount = 2},
    {type = "item", name = "titanium-plate", amount = 2},
    {type = "item", name = "rubber", amount = 4},
    {type = "item", name = "pump", amount = 1},
    {type = "item", name = "large-pipe-coupler", amount = 2},
    {type = "item", name = "underground-pipe-segment-t3", amount = 10},
})

set_recipe_ingredients("medium-pipe-coupler", {
    {type = "item", name = "small-pipe-coupler", amount = 1},
    {type = "item", name = "niobium-plate", amount = 1},
})

set_recipe_ingredients("large-pipe-coupler", {
    {type = "item", name = "medium-pipe-coupler", amount = 1},
    {type = "item", name = "rubber", amount = 1},
    {type = "item", name = "plastic-bar", amount = 1},
})

set_recipe_ingredients("underground-pipe-segment-t2", {
    {type = "item", name = "underground-pipe-segment-t1", amount = 1},
    {type = "item", name = "niobium-plate", amount = 1},
})

set_recipe_ingredients("underground-pipe-segment-t3", {
    {type = "item", name = "underground-pipe-segment-t2", amount = 1},
    {type = "item", name = "rubber", amount = 1},
    {type = "item", name = "plastic-bar", amount = 1},
})

require_prototype("technology", "advanced-underground-piping-t2").prerequisites = {
    "advanced-underground-piping",
    "niobium",
}

require_prototype("technology", "advanced-underground-piping-t3").prerequisites = {
    "advanced-underground-piping-t2",
    "coal-processing-3",
}

local function is_advanced_fluid_handling_valve(name)
    return name == "check-valve"
        or name:match("^%d+%-overflow%-valve$") ~= nil
        or name:match("^%d+%-top%-up%-valve$") ~= nil
end

for name, valve in pairs(data.raw.valve or {}) do
    if is_advanced_fluid_handling_valve(name) then
        valve.flow_rate = valve.flow_rate * 2
    end
end
