-- ESP Module
local esp = {}

-- Services
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- Configuration
esp.folder = workspace.Map.BredMakurz
esp.TEXT_FONT = 3 -- Enum.Font.Code
esp.TEXT_SIZE = 16
esp.espCache = {}
esp.showDistance = false

-- Initialize ESP Settings
function esp:init(settings)
    -- ESP Variables
    self.espEnabled = settings.Enabled or false
    self.espOpacity = settings.Opacity or 1
    self.selectedEspTypes = settings.Types or {}
    self.espColor = settings.Color or Color3.new(1, 1, 1)
    self.showDistance = settings.ShowDistance or false

    -- Main ESP Loop
    RunService.RenderStepped:Connect(function()
        self:updateESP()
    end)

    -- Cleanup when models are removed
    self.folder.ChildRemoved:Connect(function(model)
        local cache = self.espCache[model]
        if cache then
            cache.Drawing:Remove()
            self.espCache[model] = nil
        end
    end)
end

-- Update ESP Functionality
function esp:updateESP()
    if not self.espEnabled then return end

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    for _, model in pairs(self.folder:GetChildren()) do
        if model:IsA("Model") then
            local basePart = model:FindFirstChild("Base")
                or (model:FindFirstChild("Parts") and model.Parts:FindFirstChild("Base"))
                or model.PrimaryPart
            if not basePart then continue end

            local values = model:FindFirstChild("Values")
            local broken = values and values:FindFirstChild("Broken")
            if not broken then continue end

            local text = ""
            if model.Name:find("Medium") and table.find(self.selectedEspTypes, "Medium Safe") then
                text = "Medium Safe"
            elseif model.Name:find("Small") and table.find(self.selectedEspTypes, "Small Safe") then
                text = "Small Safe"
            elseif model.Name:find("Register") and table.find(self.selectedEspTypes, "Register") then
                text = "Register"
            end

            if self.showDistance and text ~= "" then
                local distance = (rootPart.Position - basePart.Position).Magnitude
                text = text .. "\nDistance: [" .. math.floor(distance) .. "]"
            end

            if not self.espCache[model] then
                local drawingText = Drawing.new("Text")
                drawingText.Visible = false
                drawingText.Size = self.TEXT_SIZE
                drawingText.Center = true
                drawingText.Outline = true
                drawingText.Font = self.TEXT_FONT
                drawingText.Text = text
                drawingText.Color = broken.Value and Color3.fromRGB(255, 0, 0) or self.espColor
                drawingText.Transparency = 1 - self.espOpacity

                self.espCache[model] = {
                    Drawing = drawingText,
                    BasePart = basePart
                }
            end

            local cache = self.espCache[model]
            if cache then
                local position, onScreen = workspace.CurrentCamera:WorldToViewportPoint(cache.BasePart.Position)
                if onScreen and text ~= "" then
                    cache.Drawing.Position = Vector2.new(position.X, position.Y - 20)
                    cache.Drawing.Visible = true
                    cache.Drawing.Text = text
                    cache.Drawing.Color = broken.Value and Color3.fromRGB(255, 0, 0) or self.espColor
                    cache.Drawing.Transparency = 1 - self.espOpacity
                else
                    cache.Drawing.Visible = false
                end
            end
        end
    end
end

return esp
