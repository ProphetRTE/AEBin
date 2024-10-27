-- v1.1.2

local Table = dofile('/modules/Table.lua')
local terminal = dofile('/modules/terminal.lua')

local menuinterface = {

    useHeaders = false,

    data = {
        term = {
            bgColor = colors.black,
            fgColor = colors.lime,
            width = nil,
            height = nil
        },
        menu = {
            selection = 1,
            key = nil,
            message = '',
            messageTimer = nil,
            columnSize = nil,
            history = {}
        },
        keys = {
            up = 200,
            down = 208,
            enter = 28,
            space = 57,
            ctrl = 29,
            alt = 56,
            tab = 15,
            w = 17,
            a = 30,
            s = 31,
            d = 32,
            f = 33,
            e = 18,
            q = 16
        },
        window = {
            width = nil,
            height = nil
        }
    },

    menus = {},

    --- Write the active menu to the screen
    -- @param self
    show = function(self)
        self.data.window.width, self.data.window.height = term.getSize()
        self.data.menu.columnSize = self.data.window.width / 2

        term.setBackgroundColor(self.data.term.bgColor)
        term.setTextColor(self.data.term.fgColor)

        term.clear()
        term.setCursorPos(1, 2)

        self.data.running = true
        while (self.data.running) do
            self:draw()
            self:handleEvent(os.pullEvent())
        end
    end,

    --- Load a menu file stored in the '/menus' directory
    -- @param title     The name of the menu file with the extension omitted
    -- @param ...       (Optional) Arguments to pass to the menu file
    -- @return          Returns the menu object returned by the menu file
    load = function(title, ...)
        local path = '/menus/' .. title .. '.lua'

        if not fs.exists(path) then return end

        return assert(
            loadfile(path, getfenv())
        )(...)
    end,

    --- Stop the menu and clear the screen
    -- @param self
    close = function(self)
        self.data.running = false
        terminal.reset()
    end,

    --- Display the previous menu stored in history
    -- @param self
    back = function(self)
        local historySize = #self.data.menu.history
        local key = self.data.menu.history[historySize]

        if (historySize > 0) then
            table.remove(self.data.menu.history, historySize)
            self:use(key, false)
        else
            term.clear()
            term.setCursorPos(1, 1)
            self.data.running = false
        end
    end,

    --- Write the header portion of the interface
    -- @param self
    drawHeader = function(self)
        term.setCursorPos(1, 1);
        term.setBackgroundColor(colors.white)

        for i=1, self.data.window.width do
            write(' ')
        end

        term.setCursorPos(3, 1);
        self:cwrite(self.data.menu.key, colors.black)

        term.setBackgroundColor(self.data.term.bgColor)
    end,

    --- Write a message to the menu interface
    --  @param self
    drawMessage = function(self)
        term.setCursorPos(3, self.data.window.height - 1)
        term.clearLine()
        self:cwrite(self.data.menu.message, colors.white)
    end,

    --- Write menu interface to the screen
    --  @param self
    drawMenu = function(self)
        local menu = self.menus[self.data.menu.key]
        local menuSize = Table.size(menu)
        local yStart = 3

        -- write each menu item
        term.setCursorPos(1, yStart)
        local column = 0
        local columns = math.floor(self.data.window.width / self.data.menu.columnSize)
        local i = 1
        for key, option in ipairs(menu) do
            local x, y = term.getCursorPos()

            if (column < columns) then
                -- if end of terminal has been reached, move to a new column
                if (y >= self.data.window.height) then
                    if ((column + 1) < columns) then
                        column = column + 1
                        y = yStart
                    else
                        break;
                    end
                end

                if (column > 0) then
                    x = column * self.data.menu.columnSize
                end

                term.setCursorPos(x, y)

                -- prefix active menu choice
                if (key == self.data.menu.selection) then
                    self:cwrite(' > ', colors.white)
                else
                    write('   ')
                end

                -- store beginning coordinates
                self.menus[self.data.menu.key][key].coords = {}
                local xPos, yPos = term.getCursorPos()
                self.menus[self.data.menu.key][key].coords[1] = {xPos, yPos}

                write(option[1])

                -- store end coordinates
                local xPos, yPos = term.getCursorPos()
                self.menus[self.data.menu.key][key].coords[2] = {xPos, yPos}

                write('\n\n')
                i = i + 1
            end
        end
    end,

    --- Displays a menu
    -- @param key           The menu title/key
    -- @param setHistory    (Optional) If false, the menu won't be stored in history. Defaults to true.
    use = function(self, key, addToHistory)
        if addToHistory == nil then addToHistory = true end

        if (addToHistory) then
            table.insert(self.data.menu.history, self.data.menu.key)
        end

        self.data.menu.key = key
        self.data.menu.selection = 1
    end,

    --- Enable the menu header
    showTitle = function(self)
        self.useHeaders = true
    end,

    --- Disable the menu header
    hideTitle = function(self)
        self.useHeaders = false
    end,

    --- Writes a string in a specific color
    --  @param self
    --  @param str      A string to write
    --  @param color    (optional) String color
    cwrite = function(self, str, color)
        if (color == nil) then color = self.data.term.fgColor end
        if (term.isColor()) then term.setTextColor(color) end
        write(str)
        if (term.isColor()) then term.setTextColor(self.data.term.fgColor) end
    end,

    --- Call methods to draw all parts of the menu interface
    --  @param self
    draw = function(self)
        term.clear()

        if self.useHeaders then
            self:drawHeader();
        end

        self:drawMenu()
        self:drawMessage()
    end,

    --- Respond to a user interaction
    --  
    --  Possible events are key presses, mouse clicks, and timer expiration.
    --
    --  @param self
    --  @param ...   Event parameters
    handleEvent = function(self, ...)
        -- remove first argument from arguments table
        local eventType = table.remove(arg, 1)

        if (eventType == 'key') then
            local key = arg[1];
            local menu = self.menus[self.data.menu.key];
            local selection = self.data.menu.selection;
            local menuSize = Table.size(menu);

            -- Move menu selection up
            if ((key == self.data.keys.up or key == self.data.keys.w) and (selection - 1) >= 1) then
                self:select(selection - 1)

                -- Move menu selection down
            elseif ((key == self.data.keys.down or key == self.data.keys.s) and (selection + 1) <= menuSize) then
                self:select(selection + 1)

                -- Choose current menu selection
            elseif (key == self.data.keys.enter or key == self.data.keys.space or key == self.data.keys.e) then
                self:message('')
                menu[self.data.menu.selection][2](self);

                -- Go back or exit menu
            elseif (key == self.data.keys.tab) then
                menu[menuSize][2](self);
            end
            
        elseif (eventType == 'mouse_click') then
            local choice = self:getChoiceClicked(arg[2], arg[3]);
            if (choice) then
                -- Select the menu item that was clicked
                self:select(
                    Table.position(choice, self.menus[self.data.menu.key])
                )

                self:draw()

                -- briefly highlight the clicked text
                local restoreColor = term.getTextColor()
                term.setCursorPos(choice.coords[1][1], choice.coords[1][2])
                term.setTextColor(colors.white)
                for key, ye in pairs(self.menus[self.data.menu.key]) do
                    if self.menus[self.data.menu.key][key] == choice then
                        io.write(ye[1])
                        term.setTextColor(restoreColor)
                        break
                    end
                end
                sleep(.12) 

                choice[2](self);
            end

        elseif eventType == 'timer' then        
            if arg[1] == self.data.menu.messageTimer then 
                self:message('')
            end
        end
    end,

    --- Indicate a menu choice as selected
    --  @param self 
    --  @param position     The position of the menu choice
    select = function(self, position)
        self.data.menu.selection = position
        self:drawMenu()
    end,

    --- Display a message
    --  @param self
    --  @param msg      Message text
    --  @param duration (optional) Seconds to display the message for
    message = function(self, msg, duration)
        self.data.menu.message = msg
        self:drawMessage()

        if duration ~= nil then
            self.data.menu.messageTimer = os.startTimer(duration)
        end
    end,

    --- Determine if a menu choice was clicked
    -- @param x     The X click coordinate
    -- @param y     The Y click coordinate
    -- @return      Returns the table of data for any choice clicked, otherwise returns false
    getChoiceClicked = function(self, x, y)
        for key, val in pairs(self.menus[self.data.menu.key]) do
            if (x >= val.coords[1][1] and x <= val.coords[2][1] and y >= val.coords[1][2] and y <= val.coords[2][2]) then
                return val;
            end
        end

        return false;
    end,

    --- Stores a new BaseOS menu
    -- @param context       The object/namespace from which the menu originated
    -- @param menuTitle     The title/key of the menu
    -- @param menuOptions   A table representing menu options.
    --                      Tables should maintain the BaseOS menu format of:
    --                      {[1] = {name='Option name', action=function(self) ... end, [2] = ...}
    add = function(self, menuTitle, menuOptions)
        self.menus[menuTitle] = menuOptions;
    end,
}

return {
    new = function(menu)
        local instance = menuinterface

        -- if menu is provided, display it
        if menu ~= nil then
            instance:add('Main Menu', menu)
            instance:use('Main Menu')
        end

        return instance
    end,

    load = menuinterface.load
}