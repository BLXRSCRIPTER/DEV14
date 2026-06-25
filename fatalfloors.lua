local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local espfilltransparency = 0 -- default
local espouttransparency = 0
local monsterColors = {
    PlantMonster = {Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 100, 0)},   -- green
    RobotMonster = {Color3.fromRGB(255, 0, 0), Color3.fromRGB(100, 0, 0)},   -- red
    CaveCrawler  = {Color3.fromRGB(0, 0, 0), Color3.fromRGB(50, 50, 50)},    -- black
    FleshMonster = {Color3.fromRGB(255, 255, 0), Color3.fromRGB(100, 100, 0)}, -- yellow
    BirdMonster  = {Color3.fromRGB(0, 0, 255), Color3.fromRGB(0, 0, 100)},    -- blue
    Default = {Color3.fromRGB(255,255,255), Color3.fromRGB(150,150,150)} -- default color for new-monsters
}

local backpackslots = 0
local function addHighlightAndBillboard(model, isProcGenItem)
    -- Remove any existing Highlight/BillboardGui first
    for _, child in ipairs(model:GetChildren()) do
        if child:IsA("Highlight") or child:IsA("BillboardGui") then
            child:Destroy()
        end
    end

    local highlight = Instance.new("Highlight")
    highlight.Parent = model
    highlight.Adornee = model
    highlight.FillTransparency = espfilltransparency
    highlight.OutlineTransparency = espouttransparency

    local outlineColor

    -- Special case: Shard models
    if model.Name == "Shard" then
        outlineColor = Color3.fromRGB(0, 0, 255) -- bright blue
        highlight.FillColor = Color3.fromRGB(0, 0, 200) -- darker blue
        highlight.OutlineColor = outlineColor
    elseif isProcGenItem then
        if string.find(model.Name, "Ore") then
            outlineColor = Color3.fromRGB(255, 255, 255) -- whitea
            highlight.FillColor = Color3.fromRGB(200, 200, 200)
        else
            outlineColor = Color3.fromRGB(255, 255, 0) -- yellow
            highlight.FillColor = Color3.fromRGB(200, 200, 0)
        end
        highlight.OutlineColor = outlineColor
    else
        local colors = monsterColors[model.Name]
        if colors then
            outlineColor = colors[1]
            highlight.FillColor = colors[2]
        else
            outlineColor = monsterColors.Default[1]
            highlight.FillColor = monsterColors.Default[2]
        end
        highlight.OutlineColor = outlineColor
    end

    -- BillboardGui
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 120, 0, 30) -- smaller
    billboard.AlwaysOnTop = true
    billboard.Adornee = model
    billboard.Parent = model

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = model.Name
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0
    textLabel.TextColor3 = outlineColor -- match highlight outline color

    -- Use Sarpanch Regular (not bold)
    textLabel.FontFace = Font.new(
        "rbxasset://fonts/families/Sarpanch.json",
        Enum.FontWeight.Regular,
        Enum.FontStyle.Normal
    )

    textLabel.Parent = billboard
end
local function processFolder(folder, isProcGenItem)
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("Model") then
            addHighlightAndBillboard(obj, isProcGenItem)
        end
    end
end
local currentwalkspeed  
local islooping = false
local function theyesprotocol()
    while islooping do
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = currentwalkspeed
        task.wait(0.01)
    end
end
local executor = getgenv().identifyexecutor and (getgenv().identifyexecutor()) or game["Run Service"]:IsStudio() and (game["Run Service"]:IsServer() and "Server" or "Client").."StudioApp" or game["Run Service"]:IsServer() and "Server" or "Client"
local Window = Fluent:CreateWindow({
    Title = "DEV14 HUB",
    SubTitle = "Fatal Floors",
    TabWidth = 160,
    Size = UDim2.fromOffset(650,480),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.K -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Home", Icon = "rbxassetid://10723407389" }),
    Farm = Window:AddTab({ Title = "Farming", Icon = "rbxassetid://10709770178" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "rbxassetid://10723346959" }),
    Special = Window:AddTab({ Title = "Special", Icon = "rbxassetid://10709783217" }),
}

local Options = Fluent.Options

do
    Tabs.Main:AddParagraph({
        Title = "Fatal Floors",
        Content = "Version 1.00"
    })
    Tabs.Main:AddParagraph({
        Title = "Current Executor: " .. executor,
        Content = "Welcome! I hope this script provides almost everything you need."
    })
    local Toggle = Tabs.Main:AddToggle("Sprint", {Title = "Disable Sprint", Default = false })

    Toggle:OnChanged(function(Value)
        if Value == true then
            game.Players.LocalPlayer.PlayerScripts.SprintClient.Disabled = true
        else
            game.Players.LocalPlayer.PlayerScripts.SprintClient.Disabled = false
        end
    end) 
    local Slider = Tabs.Main:AddSlider("yo", {
        Title = "Player WalkSpeed",
        Description = "Player Walkspeed Value (Default = 16)",
        Default = 16,
        Min = 16,
        Max = 80,
        Rounding = 0,
        Callback = function(Value)
            currentwalkspeed = Value
        end
    })
    Slider:OnChanged(function(Value)
        print("Set Walkspeed to: ", Value)
    end)
    local Toggle2 = Tabs.Main:AddToggle("Enable Walkspeed", {Title = "Enable Walkspeed", Default = false})
    Toggle2:OnChanged(function(Value)
        islooping = Value
        task.spawn(theyesprotocol)
    end)
    Options["Enable Walkspeed"]:SetValue(false)
    Options["Sprint"]:SetValue(false)
    Tabs.Main:AddButton({
        Title = "Infinite Yield FE",
        Description = "Executes Inf Yield.",
        Callback = function()
            loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-infinite-yield-14328"))()
        end
    })
    Tabs.Main:AddButton({
        Title = "Dex Explorer",
        Description = "Executes Dex Explorer.",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
        end
    })
    Tabs.Farm:AddButton({
        Title = "Auto Farm Ores",
        Description = "Automatically get ores",
        Callback = function()
            Fluent:Notify({
                Title = "DEV14 HUB",
                Content = "Started Ore Farm",
                Duration = 5
            })
            local count = 0
            while count < tonumber(backpackslots) do
                local foundOre = false

                for _, v in ipairs(workspace.ProcGenGenerated.ProcGenItems:GetChildren()) do
                    if string.find(v.Name, "Ore") and v:FindFirstChild("Handle") then
                        local prompt = v.Handle:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            -- move to ore
                            character:PivotTo(v:GetPivot())
                            task.wait(0.5)
                            prompt:InputHoldBegin()
                            task.wait(0.1)
                            prompt:InputHoldEnd()
                            count += 1
                            foundOre = true
                            task.wait(1)
                        end
                    end
                    if count >= tonumber(backpackslots) then break end
                end

                if not foundOre then
                    task.wait(2)
                end
            end

            -- teleport back when done
            character.HumanoidRootPart.CFrame = workspace.Teleport223_DEV14.CFrame
            Fluent:Notify({
                Title = "DEV14 HUB",
                Content = "Finished Ore Farm",
                Duration = 5
            })
        end
    })
    local Slider = Tabs.Farm:AddSlider("Slider", {
        Title = "Backpack Slots",
        Description = "(THIS DOES NOT CHANGE YOUR BACKPACK SLOTS) the script doesnt know how many slots you have, you have to use this for now.",
        Default = 2,
        Min = 1,
        Max = 10,
        Rounding = 0,
        Callback = function(Value)
            backpackslots = Value
            print("boom")
        end
    })
    Tabs.Farm:AddParagraph({
        Title = "Selling Ores",
        Content = "This script automatically sells whatever ore you have in your inventory."
    })
    Tabs.Farm:AddButton({
        Title = "Sell Ores",
        Description = "Sells your ores.",
        Callback = function()
            for _, child in ipairs(Game.Players.LocalPlayer.Character:GetChildren()) do
                if string.find(child.Name, "Ore") then
                    print("nono")
                    Fluent:Notify({
                        Title = "DEV14 HUB",
                        Content = "Please unequip your ore(s).",
                        SubContent = "ERROR: Attempted to index nil",
                        Duration = 5
                    })
                    return
                end
            end
            local orecounts = 0
            for _, tool in ipairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name, "Ore") then
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = workspace.PlacedTiles.SellStation.SellingSpot.CFrame
                    local prompt = workspace.PlacedTiles.SellStation.SellingSpot.ProximityPrompt
                    tool.Parent = game.Players.LocalPlayer.Character
                    task.wait(0.1)
                    prompt:InputHoldBegin()
                    task.wait(0.1)
                    prompt:InputHoldEnd()
                    orecounts += 1
                    task.wait(0.1)
                end
            end
            Fluent:Notify({
                Title = "DEV14 HUB",
                Content = "Successfully sold " .. orecounts .. " Ore(s).",
                SubContent = "",
                Duration = 5

            })
        end
    })
    Slider:OnChanged(function(Value)
        print("Set Backpack slots to: ", Value)
        slidervar = Value
    end)
    Slider:SetValue(2)
    Tabs.ESP:AddParagraph({
        Title = "Section not finished",
        Content = "This section is still in progress, and may / may not have more features in the future."
    })
    Tabs.ESP:AddButton({
        Title = "ESP Everything",
        Description = "You might wanna re-enable this every floor.",
        Callback = function()
            Fluent:Notify({
                Title = "DEV14 HUB",
                Content = "ESP Enabled",
                SubContent = "Re-enable this every floor (ores arent esp'd correctly every floor if you press this only once).", -- Optional
                Duration = 5 -- Set to nil to make the notification not disappear
            })
            local monstersFolder = workspace:FindFirstChild("Monsters")
            if monstersFolder then
                processFolder(monstersFolder, false)
            end
            local procGenFolder = workspace:FindFirstChild("ProcGenGenerated")
            if procGenFolder then
                local itemsFolder = procGenFolder:FindFirstChild("ProcGenItems")
                if itemsFolder then
                    processFolder(itemsFolder, true)
                end
            end
        end
    })
    Tabs.Special:AddParagraph({
        Title = "Monster ESP Settings",
        Content = "This includes customizing the ESP highlights."
    })
    local currentmonsterpicked = nil
    local colorpicked1 = nil
    local colorpicked2 = nil
    local Dropdown = Tabs.Special:AddDropdown("Monsters", {
        Title = "Monster Highlight Select",
        Values = {"PlantMonster", "RobotMonster", "CaveCrawler", "FleshMonster", "BirdMonster", "Default"},
        Multi = false,
        Default = 1,
    })
    Dropdown:OnChanged(function(value)
        currentmonsterpicked = tostring(value)
    end)
    local Colorpicker = Tabs.Special:AddColorpicker("CustomColorPicker", {
        Title = "Fill Highlight",
        Default = Color3.fromRGB(255,255,255)
    })
    local Colorpicker2 = Tabs.Special:AddColorpicker("CustomColorPicker2", {
        Title = "Outline Highlight",
        Default = Color3.fromRGB(255,255,255)
    })
    local selectedtrans1 = 0
    local selectedtrans2 = 0
    local espslider1 = Tabs.Special:AddSlider("CustomESPTransparency1", {
        Title = "Fill Transparency",
        Description = "Changes the fill transparency for the selected monster.",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 1,
        Callback = function(Value)
            selectedtrans1 = tonumber(Value)
        end

    })
    local espslider2 = Tabs.Special:AddSlider("CustomESPTransparency1", {
        Title = "Outline Transparency",
        Description = "Changes the Outline transparency for the selected monster.",
        Default = 0,
        Min = 0,
        Max = 1,
        Rounding = 1,
        Callback = function(Value)
            selectedtrans2 = tonumber(Value)
        end

    })
    Colorpicker:OnChanged(function()
        colorpicked1 = Colorpicker.Value
    end)

    Colorpicker2:OnChanged(function()
        colorpicked2 = Colorpicker2.Value
    end)
    Tabs.Special:AddButton({
        Title = "Apply Changes",
        Description = "Apply your custom settings.",
        Callback = function()
            if currentmonsterpicked == nil then
                Fluent:Notify({
                    Title = "DEV14 HUB",
                    Content = "Please pick a monster first.",
                    Duration = 5
                })
                return
            end
            monsterColors[currentmonsterpicked] = {colorpicked1, colorpicked2}
            espfilltransparency = selectedtrans1
            espouttransparency = selectedtrans2
            Fluent:Notify({
                Title = "DEV14 HUB",
                Content = "Settings Successfully applied! (Reload your ESP by clicking the ESP button.)",
                Duration = 5
            })
        end
    })
    Tabs.Special:AddParagraph({
        Title = "Others",
        Content = "This includes Add-ons for your client."
    })
    Tabs.Special:AddButton({
        Title = "FullBright (CLIENT)",
        Description = "Makes the game look brighter overall.",
        Callback = function()
            game.Lighting.ClockTime = 10
            game.Lighting.Ambient = Color3.fromRGB(255,255,255)
            game.Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
            Fluent:Notify({
                Title = "DEV14 HUB",
                Content = "Fullbright enabled.",
                Duration = 5
            })
        end
    })
end
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")
Window:SelectTab(1)
local part = Instance.new("Part", workspace)
part.Size = Vector3.new(4,1,2)
part.CFrame = CFrame.new(0,34,0)
part.CanCollide = false
part.Transparency = 1
part.Anchored = true
part.Name = "Teleport223_DEV14"
print("Created part")
Fluent:Notify({
    Title = "DEV14 HUB",
    Content = "The script was loaded successfully.",
    Duration = 8
})
SaveManager:LoadAutoloadConfig()