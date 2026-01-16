Config = {}

-- 'target' = ox_target, 'keypress' = 3D-text + E
Config.InteractionType = 'target' -- or 'keypress'

-- Only used if InteractionType = 'keypress'
Config.InteractKey = 38 -- E

-- Crafting benches
Config.CraftingBenches = {
    {
        coords = vec3(-1120.4740, -975.2245, 6.6321),
        heading = 117.06,
        prop = 'prop_tool_bench02'
    },
    -- Add more if you would like too.
}

-- Categories & colors (for UI)
Config.Categories = {
    tools = '#3B82F6',
    weapons = '#8B5CF6',
    medical = '#22D3EE',
    food = '#FACC15',
    misc = '#9CA3AF'
}

-- Optional: override recipe duration (ms) per recipe id
Config.CraftingTimers = {
    ['lockpick'] = 7000,
}
