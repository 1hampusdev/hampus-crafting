local function hasIngredients(src, recipe)
    for _, ing in ipairs(recipe.ingredients) do
        local itemCount = exports.ox_inventory:GetItem(src, ing.item, false, true)
        if not itemCount or itemCount < ing.count then
            return false
        end
    end
    return true
end

local function removeIngredients(src, recipe)
    for _, ing in ipairs(recipe.ingredients) do
        exports.ox_inventory:RemoveItem(src, ing.item, ing.count)
    end
end

local function giveResults(src, recipe)
    for _, res in ipairs(recipe.result) do
        exports.ox_inventory:AddItem(src, res.item, res.count)
    end
end

RegisterNetEvent('hampus-crafting:craftItem', function(recipeId)
    local src = source
    local recipe = GetRecipeById(recipeId)
    if not recipe then return end

    if not hasIngredients(src, recipe) then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Crafting',
            description = 'You do not have the correct items to craft this item.',
            type = 'error'
        })
        return
    end

    removeIngredients(src, recipe)

    giveResults(src, recipe)

    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Crafting',
        description = ('You crafted %s.'):format(recipe.label or recipe.id),
        type = 'success'
    })
end)
