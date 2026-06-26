-- // KAM SCRIPTS PREMIUM - MAX PROTECTED KEY SYSTEM \\ --

local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local _ks_token = HttpService:GenerateGUID(false)
local _verified = false
local _callCount = 0

-- // Reset global flag
getgenv().KamScripts_Verified = nil

local function SecureFetch(url)
    local t1 = tick()
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)
    local elapsed = tick() - t1

    if elapsed < 0.03 then
        error("Hook detected!", 0)
        return nil
    end

    if success and result then
        return result:gsub("^%s*(.-)%s*$", "%1")
    end
    return nil
end

local function VerifyKey(userInput)
    _callCount = _callCount + 1
    if _callCount > 3 then
        error("Too many attempts!", 0)
    end

    local raw = SecureFetch("https://kamscripts-key-server.kamscripts-key.workers.dev/raw")
    if not raw then return false end

    local half = math.floor(#raw / 2)
    if raw:sub(1, half) ~= userInput:sub(1, half) then return false end
    if raw:sub(half + 1) ~= userInput:sub(half + 1) then return false end

    _verified = true
    raw = nil
    return true
end

-- // GUI
local targetParent = (gethui and gethui()) or CoreGui
local uiName = HttpService:GenerateGUID(false)

local KeySystemUI = Instance.new("ScreenGui")
KeySystemUI.Name = uiName
KeySystemUI.Parent = targetParent
KeySystemUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn and syn.protect_gui then pcall(syn.protect_gui, KeySystemUI) end
if protect_gui then pcall(protect_gui, KeySystemUI) end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "Main"
MainFrame.Parent = KeySystemUI
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.BorderSizePixel = 2
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -75)
MainFrame.Size = UDim2.new(0, 300, 0, 150)
MainFrame.Active = true
MainFrame.Draggable = false

local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Title.BorderColor3 = Color3.fromRGB(255, 255, 255)
Title.BorderSizePixel = 1
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.Code
Title.Text = " KamScripts | Key System "
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

local KeyInput = Instance.new("TextBox")
KeyInput.Parent = MainFrame
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
KeyInput.BorderColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.BorderSizePixel = 1
KeyInput.Position = UDim2.new(0.05, 0, 0.35, 0)
KeyInput.Size = UDim2.new(0.9, 0, 0, 30)
KeyInput.Font = Enum.Font.Code
KeyInput.PlaceholderText = "Enter your key here..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.TextSize = 14
KeyInput.ClearTextOnFocus = false

local CheckButton = Instance.new("TextButton")
CheckButton.Parent = MainFrame
CheckButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CheckButton.BorderColor3 = Color3.fromRGB(255, 255, 255)
CheckButton.BorderSizePixel = 1
CheckButton.Position = UDim2.new(0.05, 0, 0.65, 0)
CheckButton.Size = UDim2.new(0.425, 0, 0, 30)
CheckButton.Font = Enum.Font.Code
CheckButton.Text = "Check Key"
CheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckButton.TextSize = 14

local GetKeyButton = Instance.new("TextButton")
GetKeyButton.Parent = MainFrame
GetKeyButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
GetKeyButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
GetKeyButton.BorderSizePixel = 1
GetKeyButton.Position = UDim2.new(0.525, 0, 0.65, 0)
GetKeyButton.Size = UDim2.new(0.425, 0, 0, 30)
GetKeyButton.Font = Enum.Font.Code
GetKeyButton.Text = "Get Key"
GetKeyButton.TextColor3 = Color3.fromRGB(0, 0, 0)
GetKeyButton.TextSize = 14

-- // PROTECTION: Kick if not verified within 2 minutes
task.spawn(function()
    task.wait(120)
    if not _verified then
        pcall(function() KeySystemUI:Destroy() end)
        LocalPlayer:Kick("[KamScripts] Key verification timeout.")
    end
end)

GetKeyButton.MouseButton1Click:Connect(function()
    local discordLink = "https://discord.gg/BR2Vmfbetp"
    if setclipboard then
        pcall(setclipboard, discordLink)
        GetKeyButton.Text = "Copied!"
    else
        GetKeyButton.Text = "No Clipboard!"
    end
    task.wait(1.5)
    GetKeyButton.Text = "Get Key"
end)

CheckButton.MouseButton1Click:Connect(function()
    CheckButton.Text = "Checking..."

    local ok, err = pcall(function()
        local userInput = KeyInput.Text

        if #userInput < 5 then
            CheckButton.Text = "Too Short!"
            task.wait(1.5)
            CheckButton.Text = "Check Key"
            return
        end

        local verified = VerifyKey(userInput)

        if verified then
            CheckButton.Text = "Correct!"
            task.wait(0.5)
            KeySystemUI:Destroy()

            -- // Activate global flag with token
            getgenv().KamScripts_Verified = _ks_token
            print("[KamScripts] Authenticated! Loading main script...")

            -- // MAIN SCRIPT STARTS HERE
            local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/bygyyds666/QJ/refs/heads/main/ui.lua"))()
            local Window = WindUI:CreateWindow({
                Title = "KamScripts - Restaurant Tycoon 3",
                Author = "Made by: KamScripts",
                Folder = "KamScripts",
                Size = UDim2.fromOffset(200, 395),
                Transparent = true,
                Theme = "Dark",
                User = {
                    Enabled = true,
                    Callback = function() end,
                    Anonymous = false
                },
                SideBarWidth = 200,
                ScrollBarEnabled = true,
                BackgroundImageTransparency = 0.65,
            })

            Window:EditOpenButton({
                Title = "KamScripts - Restaurant Tycoon 3",
                Icon = "crown",
                CornerRadius = UDim.new(0, 16),
                StrokeThickness = 2.35,
                Color = ColorSequence.new(
                    Color3.fromHex("3C1361"),
                    Color3.fromHex("6A0DAD")
                ),
                Draggable = true,
            })

            local HttpSvc = cloneref(game:GetService("HttpService"))

            local isfunctionhooked = clonefunction(isfunctionhooked)
            if isfunctionhooked(game.HttpGet) or isfunctionhooked(getnamecallmethod) or isfunctionhooked(request) then
                return
            end

            local function verifyKey(k)
                local ok2, res = pcall(function()
                    return request({
                        Url = "https://ouo.lat/api/verify.php",
                        Method = "POST",
                        Headers = {["Content-Type"] = "application/json"},
                        Body = HttpSvc:JSONEncode({key = k, time = os.time()})
                    })
                end)

                if not ok2 then return false end

                if res.Body ~= "True" then
                    return false
                end

                local ok3, res2 = pcall(function()
                    return game:HttpGet("https://www.wtb.lat/keysystem/check-key?key="..k.."&user="..game.Players.LocalPlayer.Name)
                end)

                return ok3 and res2 == "success"
            end

            local savedKey = ""
            pcall(function() savedKey = readfile("DyzhKey.json") end)
            if savedKey ~= "" then
                if verifyKey(savedKey) then
                    print("[KamScripts] Secondary key verified.")
                else
                    return
                end
            end

            local Data = {
                ["AutoCollectBill"]   = false,
                ["AutoCollectDishes"] = false,
                ["AutoCook"]          = false,
                ["AutoGiveFood"]      = false,
                ["AutoDoOrder"]       = false,
                ["AutoTakeOrder"]     = false,
                ["AutoSendTable"]     = false,
                ["AutoTips"]          = false,
            }

            local Plrs = cloneref(game:GetService("Players"))
            local LP = cloneref(Plrs.LocalPlayer)
            local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

            pcall(function()
                hookfunction(require(ReplicatedStorage:FindFirstChild("Source"):FindFirstChild("Utility"):FindFirstChild("NPC"):FindFirstChild("PathUtility")).GetMovementTime, function(...)
                    return 0.1
                end)
            end)

            function GetFriend()
                for _, v in next, Plrs:GetPlayers() do
                    if LP:IsFriendsWith(v.UserId) then
                        return v
                    end
                end
                return nil
            end

            local MainSection = Window:Section({
                Title = "Main Features",
                Opened = true
            })

            local Main   = MainSection:Tab({Title = "My Tycoon",     Icon = "Sword"})
            local Friend = MainSection:Tab({Title = "Friend Tycoon", Icon = "Sword"})

            -- ===================== MY TYCOON =====================

            Main:Toggle({
                Title = "Auto Collect Bill",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoCollectBill"] = state
                    spawn(function()
                        while Data["AutoCollectBill"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v.Player.Value == game.Players.LocalPlayer then
                                        for _, a in pairs(v.Items.Surface:GetChildren()) do
                                            if a:FindFirstChild("Bill") then
                                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                    ["Tycoon"] = v,
                                                    ["Name"] = "CollectBill",
                                                    ["FurnitureModel"] = a
                                                })
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Main:Toggle({
                Title = "Auto Collect Dishes",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoCollectDishes"] = state
                    spawn(function()
                        while Data["AutoCollectDishes"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v.Player.Value == game.Players.LocalPlayer then
                                        for _, a in pairs(v.Items.Surface:GetChildren()) do
                                            if a.Name:find("T") and a:FindFirstChild("Trash") then
                                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                    ["Tycoon"] = v,
                                                    ["Name"] = "CollectDishes",
                                                    ["FurnitureModel"] = a
                                                })
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Main:Toggle({
                Title = "Auto Cook",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoCook"] = state
                    spawn(function()
                        while Data["AutoCook"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v:FindFirstChild("Player") and v.Player.Value == game.Players.LocalPlayer then
                                        for _, a in pairs(v.Items.Surface:GetDescendants()) do
                                            if a.Name:find("Oven") then
                                                ReplicatedStorage.Events.Cook.CookInputRequested:FireServer(
                                                    "Interact",
                                                    a.Parent,
                                                    "Oven"
                                                )
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Main:Toggle({
                Title = "Auto Give Food",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoGiveFood"] = state
                    spawn(function()
                        while Data["AutoGiveFood"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v:FindFirstChild("Player") and v.Player.Value == game.Players.LocalPlayer then
                                        if #v.Objects.Food:GetChildren() > 0 then
                                            for _, a in pairs(v.Objects.Food:GetChildren()) do
                                                if not a:GetAttribute("Taken") then
                                                    ReplicatedStorage.Events.Restaurant.GrabFood:InvokeServer(a)
                                                    for _, gui in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
                                                        if gui:IsA("ImageLabel") and gui.Parent and
                                                           gui.Parent.Parent.Parent.Name == "CustomerSpeechUI" and
                                                           gui.Parent.Parent.Size == UDim2.new(1, 0, 1, 0) then
                                                           ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                                Name = "Serve",
                                                                GroupId = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Parent.Name),
                                                                Tycoon = v,
                                                                FoodModel = a,
                                                                CustomerId = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Name)
                                                            })
                                                            task.wait(0.1)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Main:Toggle({
                Title = "Auto Do Order",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoDoOrder"] = state
                    spawn(function()
                        while Data["AutoDoOrder"] do
                            pcall(function()
                                for _, v in next, workspace.Temp:GetChildren() do
                                    if v.Name == "Part" and v:FindFirstChildOfClass("ProximityPrompt") then
                                        fireproximityprompt(v:FindFirstChildOfClass("ProximityPrompt"))
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Main:Toggle({
                Title = "Auto Take Order",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoTakeOrder"] = state
                    spawn(function()
                        while Data["AutoTakeOrder"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v:FindFirstChild("Player") and v.Player.Value == game.Players.LocalPlayer then
                                        for _, gui in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
                                            if
                                                gui:IsA("ImageLabel") and gui.Parent and
                                                gui.Parent.Parent.Parent.Name == "CustomerSpeechUI" and
                                                gui.Parent.Parent.Size == UDim2.new(1, 0, 1, 0)
                                            then
                                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                    Name = "TakeOrder",
                                                    GroupId = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Parent.Name),
                                                    Tycoon = v,
                                                    CustomerId = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Name)
                                                })
                                                task.wait(0.1)
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Main:Toggle({
                Title = "Auto Send Table",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoSendTable"] = state
                    spawn(function()
                        while Data["AutoSendTable"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v.Player.Value == game.Players.LocalPlayer then
                                        for _, a in pairs(v.Items.Surface:GetChildren()) do
                                            if a.Name:find("T") and not a:GetAttribute("InUse") then
                                                for _, gui in pairs(game.Players.LocalPlayer.PlayerGui:GetDescendants()) do
                                                    if gui:IsA("ImageLabel") and gui.Parent and
                                                       gui.Parent.Parent.Parent.Name == "CustomerSpeechUI" and
                                                       gui.Parent.Parent.Size == UDim2.new(1, 0, 1, 0) then
                                                        ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                            ["FurnitureModel"] = a,
                                                            ["Tycoon"] = v,
                                                            ["Name"] = "SendToTable",
                                                            ["GroupId"] = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Parent.Name)
                                                        })
                                                        task.wait(0.1)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    task.wait(0.1)
                                end
                            end)
                            task.wait()
                        end
                    end)
                end
            })

            Main:Toggle({
                Title = "Auto Tips",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoTips"] = state
                    spawn(function()
                        while Data["AutoTips"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v:FindFirstChild("Player") and v.Player.Value == game.Players.LocalPlayer then
                                        ReplicatedStorage.Events.Restaurant.TipsCollected:FireServer(v)
                                    end
                                end
                            end)
                            task.wait()
                        end
                    end)
                end
            })

            -- ===================== FRIEND TYCOON =====================

            Friend:Toggle({
                Title = "Auto Collect Bill",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoCollectBill"] = state
                    spawn(function()
                        while Data["AutoCollectBill"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v.Player.Value == GetFriend() then
                                        for _, a in pairs(v.Items.Surface:GetChildren()) do
                                            if a:FindFirstChild("Bill") then
                                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                    ["Tycoon"] = v,
                                                    ["Name"] = "CollectBill",
                                                    ["FurnitureModel"] = a
                                                })
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Friend:Toggle({
                Title = "Auto Collect Dishes",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoCollectDishes"] = state
                    spawn(function()
                        while Data["AutoCollectDishes"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v.Player.Value == GetFriend() then
                                        for _, a in pairs(v.Items.Surface:GetChildren()) do
                                            if a.Name:find("T") and a:FindFirstChild("Trash") then
                                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                    ["Tycoon"] = v,
                                                    ["Name"] = "CollectDishes",
                                                    ["FurnitureModel"] = a
                                                })
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Friend:Toggle({
                Title = "Auto Cook",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoCook"] = state
                    spawn(function()
                        while Data["AutoCook"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v:FindFirstChild("Player") and v.Player.Value == GetFriend() then
                                        for _, a in pairs(v.Items.Surface:GetDescendants()) do
                                            if a.Name:find("Oven") then
                                                ReplicatedStorage.Events.Cook.CookInputRequested:FireServer(
                                                    "Interact",
                                                    a.Parent,
                                                    "Oven"
                                                )
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Friend:Toggle({
                Title = "Auto Give Food",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoGiveFood"] = state
                    spawn(function()
                        while Data["AutoGiveFood"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v:FindFirstChild("Player") and v.Player.Value == GetFriend() then
                                        if #v.Objects.Food:GetChildren() > 0 then
                                            for _, a in pairs(v.Objects.Food:GetChildren()) do
                                                if not a:GetAttribute("Taken") then
                                                    ReplicatedStorage.Events.Restaurant.GrabFood:InvokeServer(a)
                                                    for _, gui in pairs(GetFriend().PlayerGui:GetDescendants()) do
                                                        if gui:IsA("ImageLabel") and gui.Parent and
                                                           gui.Parent.Parent.Parent.Name == "CustomerSpeechUI" and
                                                           gui.Parent.Parent.Size == UDim2.new(1, 0, 1, 0) then
                                                           ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                                Name = "Serve",
                                                                GroupId = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Parent.Name),
                                                                Tycoon = v,
                                                                FoodModel = a,
                                                                CustomerId = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Name)
                                                            })
                                                            task.wait(0.1)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Friend:Toggle({
                Title = "Auto Do Order",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoDoOrder"] = state
                    spawn(function()
                        while Data["AutoDoOrder"] do
                            pcall(function()
                                for _, v in next, workspace.Temp:GetChildren() do
                                    if v.Name == "Part" and v:FindFirstChildOfClass("ProximityPrompt") then
                                        fireproximityprompt(v:FindFirstChildOfClass("ProximityPrompt"))
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Friend:Toggle({
                Title = "Auto Take Order",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoTakeOrder"] = state
                    spawn(function()
                        while Data["AutoTakeOrder"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v:FindFirstChild("Player") and v.Player.Value == GetFriend() then
                                        for _, gui in pairs(GetFriend().PlayerGui:GetDescendants()) do
                                            if
                                                gui:IsA("ImageLabel") and gui.Parent and
                                                gui.Parent.Parent.Parent.Name == "CustomerSpeechUI" and
                                                gui.Parent.Parent.Size == UDim2.new(1, 0, 1, 0)
                                            then
                                                ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                    Name = "TakeOrder",
                                                    GroupId = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Parent.Name),
                                                    Tycoon = v,
                                                    CustomerId = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Name)
                                                })
                                                task.wait(0.1)
                                            end
                                        end
                                    end
                                end
                            end)
                            task.wait(0.1)
                        end
                    end)
                end
            })

            Friend:Toggle({
                Title = "Auto Send Table",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoSendTable"] = state
                    spawn(function()
                        while Data["AutoSendTable"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v.Player.Value == GetFriend() then
                                        for _, a in pairs(v.Items.Surface:GetChildren()) do
                                            if a.Name:find("T") and not a:GetAttribute("InUse") then
                                                for _, gui in pairs(GetFriend().PlayerGui:GetDescendants()) do
                                                    if gui:IsA("ImageLabel") and gui.Parent and
                                                       gui.Parent.Parent.Parent.Name == "CustomerSpeechUI" and
                                                       gui.Parent.Parent.Size == UDim2.new(1, 0, 1, 0) then
                                                        ReplicatedStorage.Events.Restaurant.TaskCompleted:FireServer({
                                                            ["FurnitureModel"] = a,
                                                            ["Tycoon"] = v,
                                                            ["Name"] = "SendToTable",
                                                            ["GroupId"] = tostring(gui.Parent.Parent.Parent.Adornee.Parent.Parent.Name)
                                                        })
                                                        task.wait(0.1)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                    task.wait(0.1)
                                end
                            end)
                            task.wait()
                        end
                    end)
                end
            })

            Friend:Toggle({
                Title = "Auto Tips",
                Image = "swords",
                Value = false,
                Callback = function(state)
                    Data["AutoTips"] = state
                    spawn(function()
                        while Data["AutoTips"] do
                            pcall(function()
                                for _, v in pairs(workspace.Tycoons:GetChildren()) do
                                    if v:FindFirstChild("Player") and v.Player.Value == GetFriend() then
                                        ReplicatedStorage.Events.Restaurant.TipsCollected:FireServer(v)
                                    end
                                end
                            end)
                            task.wait()
                        end
                    end)
                end
            })

            Window:OnClose(function()
                if rainbowBorderAnimation then
                    rainbowBorderAnimation:Disconnect()
                    rainbowBorderAnimation = nil
                end
            end)

            Window:OnDestroy(function()
                if rainbowBorderAnimation then
                    rainbowBorderAnimation:Disconnect()
                    rainbowBorderAnimation = nil
                end
                for _, animation in pairs(fontColorAnimations or {}) do
                    animation:Disconnect()
                end
                fontColorAnimations = {}
            end)

            WindUI:Notify({
                Title = "KamScripts",
                Content = "Restaurant Tycoon 3 script loaded successfully!",
                Duration = 5,
                Icon = "check-circle"
            })

            pcall(function()
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "KamScripts Premium";
                    Text = "Authentication Successful!";
                    Duration = 5;
                })
            end)
            -- // MAIN SCRIPT ENDS HERE
        else
            CheckButton.Text = "Wrong Key!"
            task.wait(1.5)
            CheckButton.Text = "Check Key"
        end
    end)

    if not ok then
        pcall(function() KeySystemUI:Destroy() end)
        LocalPlayer:Kick("[KamScripts] Security violation detected.")
    end
end)