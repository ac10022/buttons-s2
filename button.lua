define_tile_code("button")
local button_tile_code

local TEXTURE = TextureDefinition.new()
TEXTURE.width, TEXTURE.height, TEXTURE.tile_width, TEXTURE.tile_height, TEXTURE.texture_path = 128, 128, 128, 128, "button_pushable.png"

local function activate()

    -- Spawns a button.
    --
    -- Returns: the button entity
    --
    -- x, y, layer: co-ordinates and layer of the button
    --
    -- identifier (optional, defaults to an empty string): a string tag for the button, may be useful for a predicate to identify a specific button
    --
    -- presses (optional, defaults to 9999): the amount of times the button can be pressed before it is destroyed
    local function spawn_button(x, y, layer, identifier, presses)
        identifier = tostring(identifier) or ""
        presses = tonumber(presses) or 9999
        local button_uid = spawn_entity(ENT_TYPE.ITEM_BASECAMP_TUTORIAL_SIGN, x, y, layer, 0, 0)
        local button = get_entity(button_uid)
        button.user_data = {identifier = identifier, callbackid = button:set_pre_activate(function() return true end), times_pressed = 0, max_presses = presses}
        button:set_texture(define_texture(TEXTURE))
        button:set_post_activate(function(self) self.user_data.times_pressed = self.user_data.times_pressed + 1 return true end)
        return button
    end

    -- Changes the identifier of a button.
    --
    -- Does not return anything
    --
    -- uid: an entity uid, it doesn't check if it's a button but I mean why would you do that
    --
    -- identifier (optional, defaults to an empty string): a string tag for the button, may be useful for a predicate to identify a specific button
    local function set_button_identifier(uid, identifier)
        if not uid or not get_entity(uid) then return end
        identifier = tostring(identifier) or ""
        local button = get_entity(uid)
        button.user_data.identifier = tostring(identifier)
    end

    -- Changes the amount of times a button can be pressed before being destroyed.
    --
    -- Does not return anything
    --
    -- uid: an entity uid, it doesn't check if it's a button but I mean why would you do that
    --
    -- presses (optional, defaults to 9999): the amount of times the button can be pressed before it is destroyed
    local function set_button_max_presses(uid, presses)
        if not uid or not get_entity(uid) then return end
        presses = tonumber(presses) or 9999
        local button = get_entity(uid)
        button.user_data.max_presses = tonumber(presses)
    end

    -- Changes what happens when the button is activated.
    --
    -- Does not return anything
    --
    -- uid: an entity uid, it doesn't check if it's a button but I mean why would you do that
    --
    -- fun: a function <!> IMPORTANT <!> end your function with a return true statement, otherwise you will get the normal basecamp tutorial sign pop-up
    local function set_button_function(uid, fun)
        if not uid or not get_entity(uid) then return end
        local button = get_entity(uid)
        button:clear_virtual(button.user_data.callbackid)
        button.user_data.callbackid = button:set_pre_activate(fun)
    end

    -- Fetches all buttons in the level.
    --
    -- Returns: an array of uids of buttons
    local function get_all_buttons()
        return get_entities_by_type(ENT_TYPE.ITEM_BASECAMP_TUTORIAL_SIGN)
    end

    -- Destroys a button given a button uid.
    --
    -- Does not return anything
    --
    -- uid: an entity uid, it doesn't check if it's a button but I mean why would you do that
    local function destroy_button(uid)
        if not uid or not get_entity(uid) then return end
        local button = get_entity(uid)
        local particles = spawn_entity(ENT_TYPE.ITEM_BROKEN_MATTOCK, button.x, button.y, button.layer, 0, 0)
        button:destroy()
        local particlese = get_entity(particles)
        particlese.flags = clr_flag(particlese.flags, ENT_FLAG.PICKUPABLE)
        particlese.flags = clr_flag(particlese.flags, ENT_FLAG.THROWABLE_OR_KNOCKBACKABLE)
        particlese.flags = set_flag(particlese.flags, ENT_FLAG.NO_GRAVITY)
        particlese.flags = set_flag(particlese.flags, ENT_FLAG.INVISIBLE)
        generate_world_particles(PARTICLEEMITTER.ALTAR_SMOKE, particles)
    end

    set_callback(function()
        for _, v in ipairs(get_entities_by_type(ENT_TYPE.ITEM_BASECAMP_TUTORIAL_SIGN)) do
            local entity = get_entity(v)
            if entity.user_data and entity.user_data.max_presses then
                if entity.user_data.times_pressed > entity.user_data.max_presses then
                    destroy_button(v)
                end 
            end
        end
    end, ON.GAMEFRAME)

    button_tile_code = set_pre_tile_code_callback(function(x, y, layer)
        local button = spawn_button(x, y, layer)
        set_button_identifier(button.uid, F"This button is located at x: {button.x}, y: {button.y}, use this to identify and program the button!")
        set_button_function(button.uid, function(self)
            print(self.user_data.identifier)
            return true
        end)
        return true
    end, "button")

    return {
        spawn_button = spawn_button,
        get_all_buttons = get_all_buttons,
        set_button_function = set_button_function,
        set_button_identifier = set_button_identifier,
        set_button_max_presses = set_button_max_presses,
        destroy_button = destroy_button
    }

end

return activate

-- set_callback(function()
--     local x, y, layer = get_position(players[1].uid)
--     myButton = spawn_button(x, y, layer, "bob", 2)
--     set_button_function(myButton.uid, function() 
--         print("it works")
--         return true
--     end)
--     set_button_function(myButton.uid, function() 
--         players[1]:perform_teleport(1,1)
--         return true
--     end)
-- end, ON.POST_LEVEL_GENERATION)

-- set_callback(function()
--     if players[1].health < 4 then
--         destroy_button(myButton.uid)
--     end
-- end, ON.GAMEFRAME)