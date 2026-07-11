if not settings.startup["afhfp-reskin-pipe-to-grounds"].value then
    return
end

local variants = {
    ["one-to-one-forward"] = {north = "S", south = "N", west = "E", east = "W"},
    ["one-to-one-right"] = {north = "W", south = "E", west = "S", east = "N"},
    ["one-to-one-reverse"] = {north = "N", south = "S", west = "W", east = "E"},
    ["one-to-one-left"] = {north = "E", south = "W", west = "N", east = "S"},
    ["one-to-two-parallel"] = {north = "NS", south = "NS", west = "EW", east = "EW"},
    ["one-to-two-L-FR"] = {north = "SW", south = "NE", west = "ES", east = "NW"},
    ["one-to-two-perpendicular"] = {north = "EW", south = "EW", west = "NS", east = "NS"},
    ["one-to-two-L-RR"] = {north = "NW", south = "ES", west = "SW", east = "NE"},
    ["one-to-two-parallel-secondary"] = {north = "NS", south = "NS", west = "EW", east = "EW"},
    ["one-to-two-L-RL"] = {north = "NE", south = "SW", west = "NW", east = "ES"},
    ["one-to-two-perpendicular-secondary"] = {north = "EW", south = "EW", west = "NS", east = "NS"},
    ["one-to-two-L-FL"] = {north = "ES", south = "NW", west = "NE", east = "SW"},
    ["one-to-three-forward"] = {north = "ESW", south = "NEW", west = "NES", east = "NSW"},
    ["one-to-three-right"] = {north = "NSW", south = "NES", west = "ESW", east = "NEW"},
    ["one-to-three-reverse"] = {north = "NEW", south = "ESW", west = "NSW", east = "NES"},
    ["one-to-three-left"] = {north = "NES", south = "NSW", west = "NEW", east = "ESW"},
    ["one-to-four"] = {north = "NESW", south = "NESW", west = "NESW", east = "NESW"},
}

local zero_shifts = {
    north = {0, 0},
    east = {0, 0},
    south = {0, 0},
    west = {0, 0},
}

local tiers = {
    [1] = {
        base_pipe = "pipe-to-ground",
        suffix = "",
        tint = {r = 255, g = 191, b = 0, a = 0.5},
        shifts = zero_shifts,
    },
    [2] = {
        base_pipe = "niobium-pipe-to-ground",
        suffix = "-t2",
        tint = {r = 227, g = 38, b = 45, a = 0.5},
        shifts = zero_shifts,
    },
    [3] = {
        base_pipe = "ht-pipes-to-ground",
        suffix = "-t3",
        tint = {r = 38, g = 173, b = 227, a = 0.5},
        shifts = {
            north = {0, -0.25},
            east = {0, -0.25},
            south = {0, -0.28},
            west = {0, -0.25},
        },
    },
}

if mods["py_ht_pipes_reskin"] then
    tiers[3].shifts = zero_shifts
end

local function require_pipe(name)
    local pipe = data.raw["pipe-to-ground"] and data.raw["pipe-to-ground"][name]
    if not pipe then
        error(("Advanced Fluid Handling For PyMods Plus expected pipe-to-ground prototype '%s'"):format(name))
    end
    return pipe
end

local function append_picture_layers(target, picture)
    if picture.layers then
        for _, layer in ipairs(picture.layers) do
            target[#target + 1] = util.table.deepcopy(layer)
        end
    else
        target[#target + 1] = util.table.deepcopy(picture)
    end
end

for base_name, direction_map in pairs(variants) do
    for _, tier_number in ipairs({1, 2, 3}) do
        local tier = tiers[tier_number]
        local pipe = require_pipe(base_name .. tier.suffix .. "-pipe")
        local source_pipe = require_pipe(tier.base_pipe)

        for _, direction in ipairs({"north", "east", "south", "west"}) do
            local source_picture = source_pipe.pictures and source_pipe.pictures[direction]
            if not source_picture then
                error(("Pipe-to-ground prototype '%s' has no %s picture"):format(tier.base_pipe, direction))
            end

            local layers = {}
            append_picture_layers(layers, source_picture)
            layers[#layers + 1] = {
                filename = "__underground-pipe-pack__/graphics/entity/arrows/hr-ug-arrow-"
                    .. direction_map[direction]
                    .. ".png",
                priority = "extra-high",
                width = 96,
                height = 96,
                shift = tier.shifts[direction],
                scale = 0.5,
                apply_runtime_tint = true,
                tint = tier.tint,
            }

            pipe.pictures[direction] = {layers = layers}
        end

        pipe.fluid_box.pipe_covers = util.table.deepcopy(source_pipe.fluid_box.pipe_covers)
    end
end
