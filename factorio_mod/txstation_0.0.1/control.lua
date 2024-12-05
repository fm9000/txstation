storage.txstations_data = storage.txstations_data or {}

script.on_event(defines.events.on_gui_opened, function(event)
    local player = game.get_player(event.player_index)

    
    -- Check if the opened GUI is for your txstation
    if event.entity and event.entity.name == "tx-station" then
        -- Close the default GUI
        player.opened = nil

       
        -- Open the custom GUI
        local unit_number = event.entity.unit_number
        local current_identifier = storage.txstations_data[unit_number].identifier
        
        local existing_gui = player.gui.center.txstation_gui
        if existing_gui then
            existing_gui.destroy()
        end
        

        local gui = player.gui.center.add {
            type = "frame",
            name = "txstation_gui",
            direction = "vertical",
            caption = "Set new tx_identifier"
        }

        gui.tags = {unit_number = unit_number}

        -- gui.add { type = "textfield", name = "identifier_input", text = storage.txstations_data[unit_number].identifier or "" }
        gui.add { type = "label", name = "unit_number_text", caption = "Unit number: " .. unit_number }
                gui.add { type = "label", name = "current_identifier", caption = "Current tx_identifier: " .. current_identifier }
        gui.add { type = "line", name = "separation_line", direction = "horizontal" }

        gui.add { type = "textfield", name = "identifier_input", text = current_identifier }

        gui.add { type = "button", name = "save_identifier_button", caption = "Save" }
    end
end)



function save_txstation_name(event)
    local player = game.players[event.player_index]
    local gui = player.gui.center.txstation_gui

    local new_identifier = gui.identifier_input.text
    local unit_number =  gui.tags["unit_number"]

    storage.txstations_data[unit_number].identifier = new_identifier

    gui.destroy()


end

script.on_event(defines.events.on_gui_confirmed, function(event)
    if event.element.name == "save_identifier_button" then
        save_txstation_name(event)
    end
end)

script.on_event(defines.events.on_gui_click, function(event)
    if event.element.name == "save_identifier_button" then
        save_txstation_name(event)
    end
end)


script.on_event(defines.events.on_entity_died, function(event)
    if event.entity.name == "tx-station" then
        local unit_number = event.entity.unit_number
        if storage.txstations_data[unit_number] then
            storage.txstations_data[unit_number] = nil
        end
    end
end)

script.on_event(defines.events.on_player_mined_entity, function(event)
    if event.entity.name == "tx-station" then
        local unit_number = event.entity.unit_number
        if storage.txstations_data[unit_number] then
            storage.txstations_data[unit_number] = nil
        end
    end
end)

script.on_event(defines.events.on_space_platform_mined_entity, function(event)
    if event.entity.name == "tx-station" then
        local unit_number = event.entity.unit_number
        if storage.txstations_data[unit_number] then
            storage.txstations_data[unit_number] = nil
        end
    end
end)


function build_new_txtation(event)
    local txstation = event.entity
    local unit_number = txstation.unit_number
    storage.txstations_data[unit_number] = {entity = txstation, identifier = "TX-" .. txstation.unit_number}
end

script.on_event(defines.events.on_built_entity, function(event)
    if event.entity.name == "tx-station" then
        if not storage.txstations_data[event.entity.unit_number] then
            -- Doesn't exist yet, so a new built
            build_new_txtation(event)
        end
    end
end)

script.on_event(defines.events.on_space_platform_built_entity, function(event)
    if event.entity.name == "tx-station" then
        if not storage.txstations_data[event.entity.unit_number] then
            -- Doesn't exist yet, so a new built
            build_new_txtation(event)
        end
    end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
    if event.entity.name == "tx-station" then
        if not storage.txstations_data[event.entity.unit_number] then
            -- Doesn't exist yet, so a new built
            build_new_txtation(event)
        end
    end
end)


function show_txstations(tableIn)
    for _, txstation_info in pairs(storage.txstations_data) do
        if txstation_info.entity.valid then -- Always check if the entity is valid
            game.print(txstation_info.entity.gps_tag)
        end
    end
end



-- Alternative function to write a prometheus metric file
function process_txstations_prom()
    local filename = "txstation.prom"
    local output = {}
    for tx_identifier, txstation_info in pairs(storage.txstations_data) do
        
        if txstation_info.entity.valid then -- Always check if the entity is valid
            local red_signals = txstation_info.entity.get_signals(defines.wire_connector_id.circuit_red)
            local green_signals = txstation_info.entity.get_signals(defines.wire_connector_id.circuit_green)

            if red_signals then
                for _, signal in pairs(red_signals) do
                    table.insert(output, "txstation{" ..
                                        "surface=\"" .. txstation_info.entity.surface.name ..
                                        "\", tx_identifier=\"" .. txstation_info.identifier ..
                                        "\", signal_color=\"red" ..
                                        "\", signal_name=\"" .. signal.signal.name ..
                                        "\"} " ..
                                         signal.count 
                                        )
                end
            end
            if green_signals then
                for _, signal in pairs(green_signals) do
                    table.insert(output, "txstation{" ..
                                        "surface=\"" .. txstation_info.entity.surface.name ..
                                    "\", tx_identifier=\"" .. txstation_info.identifier ..
                                        "\", signal_color=\"green" ..
                                        "\", signal_name=\"" .. signal.signal.name ..
                                        "\"} " ..
                                         signal.count 
                                        )
                end
            end
        else
            -- Cleanup invalid entities from the table
            storage.txstations_data[tx_identifier] = nil
        end
    end

    table.insert(output, "tick " .. game.tick )

    helpers.write_file(filename,table.concat(output, "\n") .. "\n", false)
    
end



function process_txstations_json()
    local filename = "txstation.json"
    local output = {}
    for tx_identifier, txstation_info in pairs(storage.txstations_data) do
        
        if txstation_info.entity.valid then -- Always check if the entity is valid
            local red_signals = txstation_info.entity.get_signals(defines.wire_connector_id.circuit_red)
            local green_signals = txstation_info.entity.get_signals(defines.wire_connector_id.circuit_green)

            if red_signals then
                for _, signal in pairs(red_signals) do
                    table.insert(output,
                                {
                                    surface=txstation_info.entity.surface.name,
                                    tx_identifier=txstation_info.identifier,
                                    signal_color="red",
                                    signal_name=signal.signal.name,
                                    signal_count=signal.count
                                }
                                        )
                end
            end
            if green_signals then
                for _, signal in pairs(green_signals) do
                    table.insert(output,
                                {
                                    surface=txstation_info.entity.surface.name,
                                    tx_identifier=txstation_info.identifier,
                                    signal_color="green",
                                    signal_name=signal.signal.name,
                                signal_count=signal.count
                                }
                                        )
                end
            end
        else
            -- Cleanup invalid entities from the table
            storage.txstations_data[tx_identifier] = nil
        end
    end

    table.insert(output, {game_tick = game.tick } )

    local json = helpers.table_to_json(output)
    helpers.write_file(filename, json .. "\n", false, 0)
    
end


script.on_nth_tick(600, process_txstations_json)
commands.add_command("show_txstations", "Create a GPS ping for all built TX stations", show_txstations)
