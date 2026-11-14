-- ==========================================
-- SIRHUB (Player List + Auto Block + Resize)
-- ==========================================
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LP = Players.LocalPlayer

local Theme = {
    Primary   = Color3.fromRGB(176, 35, 48),
    Bg        = Color3.fromRGB(5, 5, 5),
    BgDeep    = Color3.fromRGB(2, 2, 2),
    Card      = Color3.fromRGB(11, 11, 11),
    CardHover = Color3.fromRGB(22, 22, 22),
    Line      = Color3.fromRGB(75, 30, 36),
    Text      = Color3.fromRGB(237, 237, 237),
    TextDim   = Color3.fromRGB(169, 169, 169),
    Success   = Color3.fromRGB(80, 200, 120),
}

local VirtualInput = Instance.new("VirtualInputManager")

local function getGuiParent()
    local parent = nil
    pcall(function()
        if typeof(gethui) == "function" then parent = gethui() end
    end)
    if not parent then
        pcall(function()
            local _cr = (type(cloneref) == "function") and cloneref or function(x) return x end
            parent = _cr(CoreGui)
        end)
    end
    if not parent then
        parent = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui", 5)
    end
    return parent
end

local function getNearestPlayer()
    local char = LP.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local closest, dist = nil, math.huge
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local d = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then dist = d; closest = plr end
        end
    end
    return closest
end

local function blockPlayer(plr)
    if not plr or plr == LP then return end
    pcall(function()
        StarterGui:SetCore("PromptBlockPlayer", plr)
        local Camera = Workspace.CurrentCamera
        if not Camera then return end
        local vp = Camera.ViewportSize
        local cx, cy = vp.X / 2, (vp.Y / 2) + 30
        for _ = 1, 5 do
            VirtualInput:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
            VirtualInput:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
            task.wait(0.001)
        end
    end)
end

-- Чистим старую GUI
pcall(function()
    local parents = {}
    pcall(function()
        if typeof(gethui) == "function" then
            local h = gethui()
            if h then table.insert(parents, h) end
        end
    end)
    table.insert(parents, CoreGui)
    local pg = LP:FindFirstChildOfClass("PlayerGui")
    if pg then table.insert(parents, pg) end
    for _, p in ipairs(parents) do
        local old = p:FindFirstChild("Sirhub")
        if old then old:Destroy() end
    end
end)

local parent = getGuiParent()
if not parent then
    warn("[Sirhub] Не удалось получить parent")
    return
end

local gui = Instance.new("ScreenGui")
gui.Name = "Sirhub"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Enabled = true
gui.Parent = parent

-- ================== ПАНЕЛЬ ==================
local MIN_W, MIN_H = 200, 220
local DEFAULT_W, DEFAULT_H = 260, 380

local frame = Instance.new("Frame")
frame.Name = "Frame"
frame.Size = UDim2.new(0, DEFAULT_W, 0, DEFAULT_H)
frame.Position = UDim2.new(0.5, -DEFAULT_W/2, 0.5, -DEFAULT_H/2)
frame.BackgroundColor3 = Theme.Bg
frame.BackgroundTransparency = 0.02
frame.BorderSizePixel = 0
frame.Active = true
frame.Visible = false
frame.ClipsDescendants = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 14)

local frameStroke = Instance.new("UIStroke")
frameStroke.Color = Theme.Line
frameStroke.Thickness = 1.8
frameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
frameStroke.Transparency = 0.05
frameStroke.Parent = frame

local fsGrad = Instance.new("UIGradient")
fsGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Primary),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
})
fsGrad.Rotation = 90
fsGrad.Parent = frameStroke

-- Header
local header = Instance.new("Frame")
header.Name = "TitleBar"
header.Size = UDim2.new(1, 0, 0, 34)
header.BackgroundColor3 = Theme.BgDeep
header.BackgroundTransparency = 0.05
header.BorderSizePixel = 0
header.Active = true
header.Parent = frame
Instance.new("UICorner", header).CornerRadius = UDim.new(0, 12)

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = Theme.BgDeep
headerFix.BackgroundTransparency = 0.05
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local headerAccent = Instance.new("Frame")
headerAccent.Size = UDim2.new(1, 0, 0, 2)
headerAccent.Position = UDim2.new(0, 0, 1, -2)
headerAccent.BackgroundColor3 = Theme.Primary
headerAccent.BorderSizePixel = 0
headerAccent.Parent = header

local titleDot = Instance.new("Frame")
titleDot.Size = UDim2.new(0, 6, 0, 6)
titleDot.Position = UDim2.new(0, 12, 0.5, -3)
titleDot.BackgroundColor3 = Theme.Primary
titleDot.BorderSizePixel = 0
titleDot.Parent = header
Instance.new("UICorner", titleDot).CornerRadius = UDim.new(1, 0)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 24, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Sirhub"
title.TextColor3 = Theme.Text
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.TextYAlignment = Enum.TextYAlignment.Center
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 22, 0, 22)
closeBtn.Position = UDim2.new(1, -28, 0.5, -11)
closeBtn.BackgroundColor3 = Theme.Card
closeBtn.BorderSizePixel = 0
closeBtn.Text = "x"
closeBtn.TextColor3 = Theme.TextDim
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.AutoButtonColor = false
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

-- Status
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -24, 0, 18)
statusLabel.Position = UDim2.new(0, 12, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Ready"
statusLabel.TextColor3 = Theme.TextDim
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextXAlignment = Enum.TextXAlignment.Center
statusLabel.Parent = frame

-- AUTO toggle
local autoEnabled = false

local autoBtn = Instance.new("TextButton")
autoBtn.Size = UDim2.new(0.5, -16, 0, 28)
autoBtn.Position = UDim2.new(0, 12, 0, 62)
autoBtn.BackgroundColor3 = Theme.Card
autoBtn.BorderSizePixel = 0
autoBtn.Text = "AUTO: OFF"
autoBtn.TextColor3 = Theme.TextDim
autoBtn.TextSize = 11
autoBtn.Font = Enum.Font.GothamBold
autoBtn.AutoButtonColor = false
autoBtn.Parent = frame
Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 8)

local autoStroke = Instance.new("UIStroke")
autoStroke.Color = Theme.Line
autoStroke.Thickness = 1.1
autoStroke.Transparency = 0.3
autoStroke.Parent = autoBtn

-- Block Nearest
local nearestBtn = Instance.new("TextButton")
nearestBtn.Size = UDim2.new(0.5, -16, 0, 28)
nearestBtn.Position = UDim2.new(0.5, 4, 0, 62)
nearestBtn.BackgroundColor3 = Theme.Card
nearestBtn.BorderSizePixel = 0
nearestBtn.Text = "NEAREST"
nearestBtn.TextColor3 = Theme.Text
nearestBtn.TextSize = 11
nearestBtn.Font = Enum.Font.GothamBold
nearestBtn.AutoButtonColor = false
nearestBtn.Parent = frame
Instance.new("UICorner", nearestBtn).CornerRadius = UDim.new(0, 8)

local nearestStroke = Instance.new("UIStroke")
nearestStroke.Color = Theme.Line
nearestStroke.Thickness = 1.1
nearestStroke.Transparency = 0.25
nearestStroke.Parent = nearestBtn

nearestBtn.MouseEnter:Connect(function()
    TweenService:Create(nearestBtn, TweenInfo.new(0.12), { BackgroundColor3 = Theme.CardHover }):Play()
    TweenService:Create(nearestStroke, TweenInfo.new(0.12), { Color = Theme.Primary, Transparency = 0 }):Play()
end)
nearestBtn.MouseLeave:Connect(function()
    TweenService:Create(nearestBtn, TweenInfo.new(0.12), { BackgroundColor3 = Theme.Card }):Play()
    TweenService:Create(nearestStroke, TweenInfo.new(0.12), { Color = Theme.Line, Transparency = 0.25 }):Play()
end)

-- Players label
local listLabel = Instance.new("TextLabel")
listLabel.Size = UDim2.new(1, -24, 0, 16)
listLabel.Position = UDim2.new(0, 12, 0, 96)
listLabel.BackgroundTransparency = 1
listLabel.Text = "Players"
listLabel.TextColor3 = Theme.TextDim
listLabel.TextSize = 11
listLabel.Font = Enum.Font.GothamMedium
listLabel.TextXAlignment = Enum.TextXAlignment.Left
listLabel.Parent = frame

-- ScrollingFrame для списка
local scroll = Instance.new("ScrollingFrame")
scroll.Name = "PlayerList"
scroll.Size = UDim2.new(1, -24, 1, -130) -- растягивается при ресайзе
scroll.Position = UDim2.new(0, 12, 0, 116)
scroll.BackgroundColor3 = Theme.BgDeep
scroll.BackgroundTransparency = 0.3
scroll.BorderSizePixel = 0
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Theme.Primary
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroll.Parent = frame
Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 8)

local listLayout = Instance.new("UIListLayout")
listLayout.SortOrder = Enum.SortOrder.Name
listLayout.Padding = UDim.new(0, 4)
listLayout.Parent = scroll

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 6)
listPadding.PaddingBottom = UDim.new(0, 6)
listPadding.PaddingLeft = UDim.new(0, 6)
listPadding.PaddingRight = UDim.new(0, 6)
listPadding.Parent = scroll

-- ===== RESIZE HANDLE =====
local resizeHandle = Instance.new("TextButton")
resizeHandle.Name = "ResizeHandle"
resizeHandle.Size = UDim2.new(0, 16, 0, 16)
resizeHandle.Position = UDim2.new(1, -18, 1, -18)
resizeHandle.BackgroundColor3 = Theme.Primary
resizeHandle.BackgroundTransparency = 0.4
resizeHandle.BorderSizePixel = 0
resizeHandle.Text = ""
resizeHandle.AutoButtonColor = false
resizeHandle.ZIndex = 20
resizeHandle.Parent = frame
Instance.new("UICorner", resizeHandle).CornerRadius = UDim.new(0, 4)

-- маленькие полоски для вида
local line1 = Instance.new("Frame")
line1.Size = UDim2.new(0, 8, 0, 1)
line1.Position = UDim2.new(0.5, -4, 0.35, 0)
line1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line1.BackgroundTransparency = 0.3
line1.BorderSizePixel = 0
line1.Parent = resizeHandle

local line2 = Instance.new("Frame")
line2.Size = UDim2.new(0, 8, 0, 1)
line2.Position = UDim2.new(0.5, -4, 0.55, 0)
line2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line2.BackgroundTransparency = 0.3
line2.BorderSizePixel = 0
line2.Parent = resizeHandle

local line3 = Instance.new("Frame")
line3.Size = UDim2.new(0, 8, 0, 1)
line3.Position = UDim2.new(0.5, -4, 0.75, 0)
line3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
line3.BackgroundTransparency = 0.3
line3.BorderSizePixel = 0
line3.Parent = resizeHandle

-- Resize logic
local resizing = false
local resizeStart, startSize

resizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        startSize = frame.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not resizing then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - resizeStart
        local newW = math.clamp(startSize.X.Offset + delta.X, MIN_W, 500)
        local newH = math.clamp(startSize.Y.Offset + delta.Y, MIN_H, 600)
        frame.Size = UDim2.new(0, newW, 0, newH)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

-- Хранилище кнопок игроков
local playerRows = {}

local function createPlayerRow(plr)
    if plr == LP then return end

    local row = Instance.new("Frame")
    row.Name = plr.Name
    row.Size = UDim2.new(1, -4, 0, 32)
    row.BackgroundColor3 = Theme.Card
    row.BorderSizePixel = 0
    row.Parent = scroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, -70, 1, 0)
    nameLabel.Position = UDim2.new(0, 8, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = plr.DisplayName ~= plr.Name and (plr.DisplayName .. " (@" .. plr.Name .. ")") or plr.Name
    nameLabel.TextColor3 = Theme.Text
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.GothamMedium
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    nameLabel.Parent = row

    local blockBtn = Instance.new("TextButton")
    blockBtn.Size = UDim2.new(0, 54, 0, 22)
    blockBtn.Position = UDim2.new(1, -60, 0.5, -11)
    blockBtn.BackgroundColor3 = Theme.Primary
    blockBtn.BorderSizePixel = 0
    blockBtn.Text = "BLOCK"
    blockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    blockBtn.TextSize = 10
    blockBtn.Font = Enum.Font.GothamBold
    blockBtn.AutoButtonColor = false
    blockBtn.Parent = row
    Instance.new("UICorner", blockBtn).CornerRadius = UDim.new(0, 5)

    blockBtn.MouseButton1Click:Connect(function()
        blockPlayer(plr)
        statusLabel.Text = "Blocked: " .. plr.Name
        statusLabel.TextColor3 = Theme.Primary
        TweenService:Create(blockBtn, TweenInfo.new(0.1), {
            BackgroundColor3 = Theme.Success,
            Text = "OK"
        }):Play()
        task.delay(1.2, function()
            if blockBtn and blockBtn.Parent then
                TweenService:Create(blockBtn, TweenInfo.new(0.15), {
                    BackgroundColor3 = Theme.Primary,
                    Text = "BLOCK"
                }):Play()
            end
            if statusLabel and statusLabel.Parent and not autoEnabled then
                statusLabel.Text = "Ready"
                statusLabel.TextColor3 = Theme.TextDim
            end
        end)
    end)

    playerRows[plr] = row
end

local function refreshPlayerList()
    for plr, row in pairs(playerRows) do
        if not plr.Parent or not Players:FindFirstChild(plr.Name) then
            if row and row.Parent then row:Destroy() end
            playerRows[plr] = nil
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and not playerRows[plr] then
            createPlayerRow(plr)
        end
    end
end

refreshPlayerList()
Players.PlayerAdded:Connect(function()
    task.wait(0.3)
    refreshPlayerList()
end)
Players.PlayerRemoving:Connect(function(plr)
    if playerRows[plr] then
        if playerRows[plr].Parent then playerRows[plr]:Destroy() end
        playerRows[plr] = nil
    end
end)

task.spawn(function()
    while task.wait(3) do
        if frame.Visible then
            refreshPlayerList()
        end
    end
end)

-- AUTO logic
autoBtn.MouseButton1Click:Connect(function()
    autoEnabled = not autoEnabled
    if autoEnabled then
        autoBtn.Text = "AUTO: ON"
        autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        autoBtn.BackgroundColor3 = Theme.Primary
        autoStroke.Color = Theme.Primary
        autoStroke.Transparency = 0
        statusLabel.Text = "Auto Block enabled"
        statusLabel.TextColor3 = Theme.Primary
    else
        autoBtn.Text = "AUTO: OFF"
        autoBtn.TextColor3 = Theme.TextDim
        autoBtn.BackgroundColor3 = Theme.Card
        autoStroke.Color = Theme.Line
        autoStroke.Transparency = 0.3
        statusLabel.Text = "Ready"
        statusLabel.TextColor3 = Theme.TextDim
    end
end)

local lastBlockTime = 0
local function doNearestBlock()
    local now = tick()
    if now - lastBlockTime < 0.48 then return end
    lastBlockTime = now

    local target = getNearestPlayer()
    if target then
        blockPlayer(target)
        statusLabel.Text = "Blocked: " .. target.Name
        statusLabel.TextColor3 = Theme.Primary
    else
        statusLabel.Text = "No player found"
        statusLabel.TextColor3 = Theme.TextDim
    end

    task.delay(1.2, function()
        if statusLabel and statusLabel.Parent and not autoEnabled then
            statusLabel.Text = "Ready"
            statusLabel.TextColor3 = Theme.TextDim
        end
    end)
end

nearestBtn.MouseButton1Click:Connect(function()
    TweenService:Create(nearestBtn, TweenInfo.new(0.08), {
        BackgroundColor3 = Theme.Primary,
        TextColor3 = Color3.fromRGB(45, 5, 13),
    }):Play()
    task.delay(0.12, function()
        TweenService:Create(nearestBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Card,
            TextColor3 = Theme.Text,
        }):Play()
    end)
    doNearestBlock()
end)

task.spawn(function()
    while task.wait(0.5) do
        if autoEnabled then
            doNearestBlock()
        end
    end
end)

-- ================== КНОПКА "S" ==================
local pill = Instance.new("TextButton")
pill.Name = "SirhubPill"
pill.Size = UDim2.new(0, 44, 0, 44)
pill.Position = UDim2.new(0, 12, 0.5, -22)
pill.BackgroundColor3 = Theme.Primary
pill.BorderSizePixel = 0
pill.Text = "S"
pill.TextColor3 = Color3.fromRGB(255, 255, 255)
pill.TextSize = 18
pill.Font = Enum.Font.GothamBlack
pill.AutoButtonColor = false
pill.Active = true
pill.ZIndex = 10
pill.Parent = gui
Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

local pillStroke = Instance.new("UIStroke")
pillStroke.Color = Color3.fromRGB(35, 4, 10)
pillStroke.Thickness = 2
pillStroke.Parent = pill

local pillGradient = Instance.new("UIGradient")
pillGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(140, 20, 40)),
})
pillGradient.Rotation = 90
pillGradient.Parent = pill

pill.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
    if frame.Visible then
        refreshPlayerList()
        if not autoEnabled then
            statusLabel.Text = "Ready"
            statusLabel.TextColor3 = Theme.TextDim
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    frame.Visible = false
end)

-- Drag панели
local dragging = false
local dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

-- Drag кнопки S
local pillDragging = false
local pillDragStart, pillStartPos
pill.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        pillDragging = true
        pillDragStart = input.Position
        pillStartPos = pill.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if not pillDragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - pillDragStart
        pill.Position = UDim2.new(
            pillStartPos.X.Scale, pillStartPos.X.Offset + delta.X,
            pillStartPos.Y.Scale, pillStartPos.Y.Offset + delta.Y
        )
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        pillDragging = false
    end
end)

print("[Sirhub] Loaded | Player List + Resize + Auto 0.5s")
