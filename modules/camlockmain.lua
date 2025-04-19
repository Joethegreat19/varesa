getgenv().OldAimPart = "Torso"
getgenv().AimPart = "Torso" -- Default AimPart
getgenv().AimlockKey = "l"
getgenv().AimRadius = 30 -- How far away from someone's character you want to lock on at
getgenv().ThirdPerson = true 
getgenv().FirstPerson = true
getgenv().TeamCheck = false -- Check if Target is on your Team
getgenv().PredictMovement = true -- Predicts movement for faster targets
getgenv().PredictionVelocity = 16
getgenv().CheckIfJumped = false
getgenv().Smoothness = true
getgenv().SmoothnessAmount = 0.32

local Players, Uis, RService, SGui = game:GetService"Players", game:GetService"UserInputService", game:GetService"RunService", game:GetService"StarterGui";
local Client, Mouse, Camera, CF, RNew, Vec3, Vec2 = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), workspace.CurrentCamera, CFrame.new, Ray.new, Vector3.new, Vector2.new;
local Aimlock, MousePressed, CanNotify = true, false, false;
local AimlockTarget;

-- Function to get the nearest body part to the mouse
getgenv().GetNearestBodyPart = function(Target)
    local ClosestPart = nil
    local ClosestDistance = math.huge
    local ScreenPos = nil

    -- Define body parts to check
    local BodyParts = {"Head", "HumanoidRootPart", "LeftArm", "RightArm"}

    for _, PartName in pairs(BodyParts) do
        local BodyPart = Target.Character:FindFirstChild(PartName)
        if BodyPart then
            local Pos, Visible = Camera:WorldToScreenPoint(BodyPart.Position)
            if Visible then
                local Distance = (Vec2(Pos.X, Pos.Y) - Vec2(Mouse.X, Mouse.Y)).Magnitude
                if Distance < ClosestDistance then
                    ClosestDistance = Distance
                    ClosestPart = BodyPart
                    ScreenPos = Pos
                end
            end
        end
    end

    return ClosestPart, ScreenPos
end

-- Modified GetNearestTarget function
getgenv().GetNearestTarget = function()
    local players = {}
    local PLAYER_HOLD = {}
    local DISTANCES = {}

    for i, v in pairs(Players:GetPlayers()) do
        if v ~= Client and v.Character and v.Character:FindFirstChild("Head") then
            table.insert(players, v)
        end
    end

    for i, v in pairs(players) do
        if v.Character ~= nil then
            local AIM = v.Character:FindFirstChild("Head")
            if (getgenv().TeamCheck == false or (getgenv().TeamCheck == true and v.Team ~= Client.Team)) then
                local DISTANCE = (AIM.Position - Camera.CFrame.p).Magnitude
                if DISTANCE <= getgenv().AimRadius then
                    local ClosestPart, _ = GetNearestBodyPart(v)
                    if ClosestPart then
                        PLAYER_HOLD[v.Name .. i] = {}
                        PLAYER_HOLD[v.Name .. i].dist = DISTANCE
                        PLAYER_HOLD[v.Name .. i].plr = v
                        table.insert(DISTANCES, DISTANCE)
                    end
                end
            end
        end
    end

    if #DISTANCES == 0 then
        return nil
    end

    local L_DISTANCE = math.min(unpack(DISTANCES))
    for i, v in pairs(PLAYER_HOLD) do
        if v.dist == L_DISTANCE then
            return v.plr
        end
    end

    return nil
end

-- RenderStepped Loop
RService.RenderStepped:Connect(function()
    if Aimlock == true and MousePressed == true then
        if AimlockTarget and AimlockTarget.Character then
            -- Get the closest body part to the mouse
            local ClosestPart, ScreenPos = GetNearestBodyPart(AimlockTarget)
            if ClosestPart then
                -- Switch AimPart dynamically
                getgenv().AimPart = ClosestPart.Name

                -- Calculate target position with prediction
                local TargetPosition = ClosestPart.Position
                if getgenv().PredictMovement then
                    TargetPosition = TargetPosition + ClosestPart.Velocity / getgenv().PredictionVelocity
                end

                -- Smoothness handling
                if getgenv().Smoothness then
                    local Main = CF(Camera.CFrame.p, TargetPosition)
                    Camera.CFrame = Camera.CFrame:Lerp(Main, getgenv().SmoothnessAmount)
                else
                    Camera.CFrame = CF(Camera.CFrame.p, TargetPosition)
                end
            end
        end
    end
end)

-- Keybind to toggle Aimlock
Mouse.KeyDown:Connect(function(a)
    if not (Uis:GetFocusedTextBox()) then
        if a == AimlockKey and AimlockTarget == nil then
            pcall(function()
                MousePressed = true
                AimlockTarget = GetNearestTarget()
            end)
        elseif a == AimlockKey and AimlockTarget ~= nil then
            MousePressed = false
            AimlockTarget = nil
        end
    end
end)