-- Load UI Library
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/insanedude59/SplixUiLib/main/Main"))()

-- Create Main Window
local window = library:new({
    textsize = 13.5,
    font = Enum.Font.RobotoMono,
    name = "YES",
    color = Color3.fromRGB(225, 58, 81)
})

-- Example Tab (Leave as is)
local tab = window:page({name = "YES2"})

local section1 = tab:section({name = "section1", side = "left", size = 250})

local multisection = tab:multisection({name = "multisection", side = "right", size = 250})

local section2 = multisection:section({name = "section2", side = "right", size = 100})

-- Example Toggle
section1:toggle({name = "toggle", def = false, callback = function(value)
    print(value)
end})

-- Example Button
section1:button({name = "button", callback = function()
    print('hot ui lib')
end})

-- Example Slider
section1:slider({name = "rate ui lib 1-100", def = 1, max = 100, min = 1, rounding = true, ticking = false, measuring = "", callback = function(value)
    print(value)
end})

-- Example Dropdown
section1:dropdown({name = "dropdown", def = "", max = 10, options = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"}, callback = function(chosen)
    print(chosen)
end})

-- Example ButtonBox
section1:buttonbox({name = "buttonbox", def = "", max = 4, options = {"yoyoyo", "yo2", "yo3", "yo4"}, callback = function(value)
    print(value)
end})

-- Example MultiBox
section1:multibox({name = "multibox", def = {}, max = 4, options = {"1", "2", "3", "4"}, callback = function(value)
    print(value)
end})

-- Example TextBox
section1:textbox({name = "textbox", def = "default text", placeholder = "Enter WalkSpeed", callback = function(value)
    print(value)
end})

-- Example Keybind
section1:keybind({name = "set ui keybind", def = nil, callback = function(key)
    window.key = key
end})

-- Example ColorPicker
local picker = section1:colorpicker({name = "color", cpname = nil, def = Color3.fromRGB(255, 255, 255), callback = function(value)
    print(value)
end})

-- New Tab for ESP
local espTab = window:page({name = "ESP Settings"})

-- Section for Extra-Sensory Perception
local espSection = espTab:section({name = "Extra-Sensory Perception", side = "left", size = 300})

-- ESP Variables
local espEnabled = false
local espOpacity = 1
local selectedEspTypes = {}
local espColor = Color3.new(1, 1, 1)
local showDistance = false -- Toggle for showing distance

--// Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--// Variables
local folder = workspace.Map.BredMakurz
local espCache = {}

--// Configuration
local TEXT_FONT = 3 -- Enum.Font.Code (monospaced font resembling RobotoMono)
local TEXT_SIZE = 16 -- Adjust size for visibility

-- Toggle for ESP
espSection:toggle({name = "Enable ESP", def = false, callback = function(value)
    espEnabled = value
    print("ESP Toggled:", espEnabled)

    if not espEnabled then
        -- Hide all ESP texts when disabled
        for _, cache in pairs(espCache) do
            cache.Drawing.Visible = false
        end
    end
end})

-- Opacity Slider
espSection:slider({name = "ESP Opacity", def = 1, max = 1, min = 0, rounding = true, ticking = false, measuring = "", callback = function(value)
    espOpacity = value

    -- Update opacity for all visible drawings
    for _, cache in pairs(espCache) do
        if cache.Drawing.Visible then
            cache.Drawing.Transparency = 1 - espOpacity
        end
    end
end})

-- Multibox for Selecting ESP Types
espSection:multibox({name = "ESP Types", def = {}, max = 3, options = {"Small Safe", "Medium Safe", "Register"}, callback = function(value)
    selectedEspTypes = value

    -- Hide ESP texts for deselected types
    for model, cache in pairs(espCache) do
        local text = ""
        if model.Name:find("Medium") and table.find(selectedEspTypes, "Medium Safe") then
            text = "Medium Safe"
        elseif model.Name:find("Small") and table.find(selectedEspTypes, "Small Safe") then
            text = "Small Safe"
        elseif model.Name:find("Register") and table.find(selectedEspTypes, "Register") then
            text = "Register"
        else
            text = "" -- No text if type is deselected
        end

        -- Update visibility and text
        if text == "" then
            cache.Drawing.Visible = false
        else
            cache.Drawing.Visible = true
            cache.Drawing.Text = text
        end
    end
end})

-- Color Picker for ESP Text
local colorPicker = espSection:colorpicker({name = "ESP Text Color", cpname = nil, def = Color3.fromRGB(255, 255, 255), callback = function(value)
    espColor = value

    -- Update color for all visible drawings
    for _, cache in pairs(espCache) do
        if cache.Drawing.Visible then
            cache.Drawing.Color = espColor
        end
    end
end})

-- Toggle for Showing Distance
espSection:toggle({name = "Show Distance", def = false, callback = function(value)
    showDistance = value
end})

-- Keybind for Toggling ESP
espSection:keybind({name = "Toggle ESP Keybind", def = nil, callback = function(key)
    print("ESP Toggle Keybind Set To:", key)
end})

-- Function to create/update ESP
local function updateESP()
    if not espEnabled then return end -- Exit if ESP is disabled

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not rootPart then return end -- Ensure the player has a root part

    for _, model in pairs(folder:GetChildren()) do
        if model:IsA("Model") then
            -- Find base part (check multiple possible locations)
            local basePart = model:FindFirstChild("Base")
                or (model:FindFirstChild("Parts") and model.Parts:FindFirstChild("Base"))
                or model.PrimaryPart
            
            if not basePart then continue end

            -- Check for Values/Broken
            local values = model:FindFirstChild("Values")
            local broken = values and values:FindFirstChild("Broken")
            if not broken then continue end

            -- Determine text based on selected types
            local text = ""
            if model.Name:find("Medium") and table.find(selectedEspTypes, "Medium Safe") then
                text = "Medium Safe"
            elseif model.Name:find("Small") and table.find(selectedEspTypes, "Small Safe") then
                text = "Small Safe"
            elseif model.Name:find("Register") and table.find(selectedEspTypes, "Register") then
                text = "Register"
            else
                text = "" -- No text if type is not selected
            end

            -- Add distance if enabled
            if showDistance and text ~= "" then
                local distance = (rootPart.Position - basePart.Position).Magnitude
                text = text .. "\nDistance: [" .. math.floor(distance) .. "]"
            end

            -- Create ESP if it doesn't exist
            if not espCache[model] then
                local drawingText = Drawing.new("Text")
                drawingText.Visible = false -- Initially hidden
                drawingText.Size = TEXT_SIZE
                drawingText.Center = true
                drawingText.Outline = true
                drawingText.Font = TEXT_FONT -- Use monospaced font
                drawingText.Text = text
                drawingText.Color = broken.Value and Color3.fromRGB(255, 0, 0) or espColor
                drawingText.Transparency = 1 - espOpacity

                espCache[model] = {
                    Drawing = drawingText,
                    BasePart = basePart
                }
            end

            -- Update existing ESP
            local cache = espCache[model]
            if cache then
                local position, onScreen = workspace.CurrentCamera:WorldToViewportPoint(cache.BasePart.Position)
                if onScreen and text ~= "" then
                    cache.Drawing.Position = Vector2.new(position.X, position.Y - 20) -- Offset above the part
                    cache.Drawing.Visible = true
                    cache.Drawing.Text = text
                    cache.Drawing.Color = broken.Value and Color3.fromRGB(255, 0, 0) or espColor
                    cache.Drawing.Transparency = 1 - espOpacity
                else
                    cache.Drawing.Visible = false
                end
            end
        end
    end
end

-- Cleanup when models are removed
folder.ChildRemoved:Connect(function(model)
    local cache = espCache[model]
    if cache then
        cache.Drawing:Remove()
        espCache[model] = nil
    end
end)

-- Main loop (60 FPS)
RunService.RenderStepped:Connect(updateESP)