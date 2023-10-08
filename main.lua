local Button = require('button')
local button = Button()

local myButton

meta = {
    name = 'buttons test',
    version = '1.0',
    description = 'test test tes',
    author = 'ac10022',
}

set_callback(function()
    if Button and #button.get_all_buttons() > 0 then
        myButton = get_entity(button.get_all_buttons()[1])
        button.set_button_identifier(myButton.uid, "my new button!")
        button.set_button_function(myButton.uid, function()
        print("hello... this is: "..tostring(myButton.user_data.identifier))
            return true
        end)
    end
end, ON.POST_LEVEL_GENERATION)

set_callback(function()
    if state.time_level > 1500 then
        button.destroy_button(myButton.uid)
    end
end, ON.GAMEFRAME)