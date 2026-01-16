CraftingRecipes = {
    {
        id = 'lockpick',
        label = 'Lockpick',
        description = 'A basic lockpick for opening doors.',
        category = 'tools',
        duration = 5000,
        ingredients = {
            { item = 'metalscrap', count = 3 }
        },
        result = {
            { item = 'lockpick', count = 1 }
        }
    },
    {
        id = 'bandage',
        label = 'Bandage',
        description = 'A medical bandage for treating wounds.',
        category = 'medical',
        duration = 3000,
        ingredients = {
            { item = 'cloth', count = 2 }
        },
        result = {
            { item = 'bandage', count = 1 }
        }
    },
    {
        id = 'parachute',
        label = 'Parachute',
        description = 'A deployable parachute for safe landings.',
        category = 'tools',
        duration = 8000,
        ingredients = {
            { item = 'cloth', count = 5 },
            { item = 'rope', count = 2 }
        },
        result = {
            { item = 'parachute', count = 1 }
        }
    },
    {
        id = 'pistol',
        label = 'Pistol',
        description = 'A deployable parachute for safe landings.',
        category = 'weapons',
        duration = 8000,
        ingredients = {
            { item = 'aluminum', count = 5 },
            { item = 'steel', count = 3 },
            { item = 'iron', count = 2 }
        },
        result = {
            { item = 'weapon_pistol', count = 1 }
        }
    },
}

function GetRecipeById(id)
    for _, recipe in ipairs(CraftingRecipes) do
        if recipe.id == id then
            return recipe
        end
    end
    return nil
end
