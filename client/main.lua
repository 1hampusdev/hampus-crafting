local showingBench = false
local currentBench = nil

local function buildUIRecipes()
    local uiRecipes = {}

    for _, recipe in ipairs(CraftingRecipes) do

        local resultItem = recipe.result[1].item
        local resultData = exports.ox_inventory:Items(resultItem)
        local recipeLabel = resultData and resultData.label or recipe.id

        local ingredients = {}
        for _, ing in ipairs(recipe.ingredients) do
            local ingData = exports.ox_inventory:Items(ing.item)
            ingredients[#ingredients+1] = {
                item = ing.item,
                count = ing.count,
                label = ingData and ingData.label or ing.item
            }
        end

        uiRecipes[#uiRecipes+1] = {
            id = recipe.id,
            label = recipeLabel,
            ingredients = ingredients,
            category = recipe.category,
            duration = recipe.duration,
            result = recipe.result
        }
    end

    return uiRecipes
end

local function playCraftingAnim()
    exports['scully_emotemenu']:playEmoteByCommand("mechanic2")
end

local function stopCraftingAnim()
    exports['scully_emotemenu']:cancelEmote()
end

local function spawnBenchProp(bench)
    local model = joaat(bench.prop)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local obj = CreateObject(model, bench.coords.x, bench.coords.y, bench.coords.z - 1.0, false, false, false)
    SetEntityHeading(obj, bench.heading)
    FreezeEntityPosition(obj, true)
    SetEntityAsMissionEntity(obj, true, true)

    bench.entity = obj
end

local function setupTarget(bench)
    exports.ox_target:addLocalEntity(bench.entity, {
        {
            name = 'hampus_crafting_bench_' .. bench.coords.x,
            label = 'Open Crafting Bench',
            icon = 'fa-solid fa-hammer',
            onSelect = function()
                currentBench = bench
                SetNuiFocus(true, true)
                SendNUIMessage({
                    action = 'open',
                    recipes = buildUIRecipes(),
                    categories = Config.Categories
                })
            end
        }
    })
end

local function draw3DText(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

CreateThread(function()
    SetNuiFocus(false, false)

    for _, bench in ipairs(Config.CraftingBenches) do
        spawnBenchProp(bench)

        if Config.InteractionType == 'target' then
            setupTarget(bench)
        end
    end

    if Config.InteractionType == 'keypress' then
        while true do
            local sleep = 1000
            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)

            for _, bench in ipairs(Config.CraftingBenches) do
                local dist = #(pCoords - bench.coords)
                if dist < 2.0 then
                    sleep = 0
                    draw3DText(bench.coords + vec3(0, 0, 1.0), '[E] Open Crafting Bench')
                    if IsControlJustPressed(0, Config.InteractKey) then
                        currentBench = bench
                        SetNuiFocus(true, true)
                        SendNUIMessage({
                            action = 'open',
                            recipes = buildUIRecipes(),
                            categories = Config.Categories
                        })
                    end
                end
            end

            Wait(sleep)
        end
    end
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('craftItem', function(data, cb)
    local recipeId = data.recipeId
    local recipe = GetRecipeById(recipeId)
    if not recipe then
        cb({ success = false })
        return
    end

    for _, ing in ipairs(recipe.ingredients) do
        if exports.ox_inventory:Search('count', ing.item) < ing.count then
            lib.notify({
                title = 'Crafting',
                description = 'You do not have the correct items to craft this item.',
                type = 'error'
            })
            cb({ success = false })
            return
        end
    end

    local duration = Config.CraftingTimers[recipe.id] or recipe.duration or 5000

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })

    Wait(150)
    playCraftingAnim()
    Wait(150)

    local resultItem = recipe.result[1].item
    local resultData = exports.ox_inventory:Items(resultItem)
    local itemLabel = resultData and resultData.label or recipe.id

    local success = lib.progressCircle({
        duration = duration,
        label = 'Crafting ' .. itemLabel,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = {
            move = true,
            car = true,
            combat = true,
            mouse = false
        }
    })

    stopCraftingAnim()

    if not success then
        lib.notify({
            title = 'Crafting',
            description = 'You cancelled the crafting.',
            type = 'error'
        })
        cb({ success = false })
        return
    end

    TriggerServerEvent('hampus-crafting:craftItem', recipe.id)
    cb({ success = true })
end)
