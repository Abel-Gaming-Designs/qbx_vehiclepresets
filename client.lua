-- Helper to enable/disable extras
local function applyExtras(veh, extras)
    for i = 0, 20 do
        if extras and table.contains(extras, i) then
            SetVehicleExtra(veh, i, 0)
        else
            SetVehicleExtra(veh, i, 1)
        end
    end
end

-- Helper to check if a table contains a value
local function tableContains(tbl, val)
    if not tbl then return false end
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

-- Apply livery + extras
local function applyPreset(veh, preset)
    if not DoesEntityExist(veh) then return end
    SetVehicleLivery(veh, preset.livery)
    applyExtras(veh, preset.extras)
    exports.qbx_core:Notify(('Applied preset: %s'):format(preset.label), 'success')
end

-- Open Ox Menu
local function openVehiclePresetMenu()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if not DoesEntityExist(veh) or GetPedInVehicleSeat(veh, -1) ~= ped then
        return exports.qbx_core:Notify('You must be the driver of a vehicle!', 'error')
    end

    local modelHash = GetEntityModel(veh)
    local presets = Config.vehicles[modelHash]

    if not presets then
        return exports.qbx_core:Notify('No presets available for this vehicle.', 'error')
    end

    local options = {}
    for _, preset in ipairs(presets) do
        options[#options + 1] = {
            label = preset.label,
            description = ('Livery #%d + Extras'):format(preset.livery + 1),
            args = preset
        }
    end

    lib.registerMenu({
        id = 'vehicle_preset_menu',
        title = 'Vehicle Presets',
        options = options,
        position = 'left',
        onSelected = function(selected, secondary, args)
            local ped = PlayerPedId()
            local veh = GetVehiclePedIsIn(ped, false)

            if not DoesEntityExist(veh) then
                return exports.qbx_core:Notify('You must be in a vehicle!', 'error')
            end

            -- Apply livery
            SetVehicleLivery(veh, args.livery)

            -- Apply extras
            for i = 0, 20 do
                if args.extras and tableContains(args.extras, i) then
                    SetVehicleExtra(veh, i, 0)
                else
                    SetVehicleExtra(veh, i, 1)
                end
            end

            exports.qbx_core:Notify(('Applied preset: %s'):format(args.label), 'success')
        end
})
    lib.showMenu('vehicle_preset_menu')
end

-- Command to open menu
RegisterCommand('presetmenu', function()
    openVehiclePresetMenu()
end, false)