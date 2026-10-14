local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
if not game:IsLoaded() then
    game.Loaded:Wait()
end
local LocalPlayer = Players.LocalPlayer
local env = (typeof(getgenv) == "function" and getgenv()) or _G
if env.WinterUI and typeof(env.WinterUI.Destroy) == "function" then
    pcall(env.WinterUI.Destroy, env.WinterUI)
end
local Winter = { Connections = {}, Guis = {}, Cleanup = {}, Flags = {} }
function Winter:Track(connection)
    table.insert(self.Connections, connection)
    return connection
end
function Winter:Destroy()
    for _, cleanup in ipairs(self.Cleanup) do
        pcall(cleanup)
    end
    for _, connection in ipairs(self.Connections) do
        pcall(function() connection:Disconnect() end)
    end
    for _, gui in ipairs(self.Guis) do
        pcall(function() gui:Destroy() end)
    end
    table.clear(self.Connections)
    table.clear(self.Guis)
    table.clear(self.Cleanup)
    table.clear(self.Flags)
    if env.WinterUI == self then
        env.WinterUI = nil
    end
end
env.WinterUI = Winter
local function ResolveGuiParent()
    if typeof(gethui) == "function" then
        local ok, container = pcall(gethui)
        if ok and typeof(container) == "Instance" then
            return container
        end
    end
    local ok, container = pcall(function()
        local probe = Instance.new("Folder")
        probe.Parent = CoreGui
        probe:Destroy()
        return CoreGui
    end)
    if ok and container then
        return container
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end
local GuiParent = ResolveGuiParent()
local function SafeFont(name, fallback)
    local ok, font = pcall(function()
        return Enum.Font[name]
    end)
    return ok and font or fallback
end
local Config = {
    Name = "Winter",
    Author = "Mans",
    Version = "1.2",
    Telegram = "https://t.me/winter_scripts",
    IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled,
    Icons = {
        Snowflake = "rbxassetid://0",
        Combat = "rbxassetid://0",
        Visuals = "rbxassetid://0",
        Settings = "rbxassetid://0",
        Info = "rbxassetid://0",
    },
    Fonts = {
        Display = SafeFont("JosefinSans", Enum.Font.GothamBold),
        Body = Enum.Font.Gotham,
        Medium = Enum.Font.GothamMedium,
        Bold = Enum.Font.GothamBold,
    },
    Boot = {
        Stages = {
            { Progress = 0.30, Time = 0.9, Text = "Preparing interface" },
            { Progress = 0.64, Time = 1.1, Text = "Building components" },
            { Progress = 0.90, Time = 0.9, Text = "Applying frost theme" },
            { Progress = 1.00, Time = 0.6, Text = "Ready" },
        },
    },
}
Config.Boot.SnowCount = Config.IsMobile and 36 or 60
local Theme = {
    Midnight = Color3.fromRGB(7, 10, 20),
    Window = Color3.fromRGB(12, 17, 31),
    Surface = Color3.fromRGB(18, 25, 44),
    SurfaceHigh = Color3.fromRGB(26, 35, 60),
    Graphite = Color3.fromRGB(30, 35, 48),
    Stroke = Color3.fromRGB(42, 56, 86),
    Accent = Color3.fromRGB(122, 190, 255),
    AccentDeep = Color3.fromRGB(70, 128, 214),
    Frost = Color3.fromRGB(214, 236, 255),
    Text = Color3.fromRGB(232, 241, 255),
    TextMuted = Color3.fromRGB(132, 150, 182),
    TextDim = Color3.fromRGB(86, 102, 134),
    Snow = Color3.fromRGB(255, 255, 255),
    Danger = Color3.fromRGB(200, 56, 74),
    DangerHover = Color3.fromRGB(222, 72, 92),
    DangerDeep = Color3.fromRGB(146, 36, 54),
    DangerSoft = Color3.fromRGB(255, 128, 144),
}
local Tweens = {
    Fast = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Smooth = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Slow = TweenInfo.new(0.80, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
}
local function Create(className, properties, children)
    local instance = Instance.new(className)
    if instance:IsA("GuiObject") then
        instance.BorderSizePixel = 0
    end
    if instance:IsA("GuiButton") then
        instance.AutoButtonColor = false
    end
    if instance:IsA("TextLabel") or instance:IsA("TextButton") or instance:IsA("TextBox") then
        instance.Font = Config.Fonts.Body
        instance.TextColor3 = Theme.Text
    end
    local parent
    for property, value in pairs(properties or {}) do
        if property == "Parent" then
            parent = value
        else
            instance[property] = value
        end
    end
    for _, child in ipairs(children or {}) do
        child.Parent = instance
    end
    instance.Parent = parent
    return instance
end
local function Tween(instance, info, goal)
    local tween = TweenService:Create(instance, info, goal)
    tween:Play()
    return tween
end
local function Corner(parent, radius)
    return Create("UICorner", { CornerRadius = radius or UDim.new(0, 8), Parent = parent })
end
local function Stroke(parent, color, thickness, transparency)
    return Create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end
local function Padding(parent, top, right, bottom, left)
    return Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 0),
        PaddingRight = UDim.new(0, right or top or 0),
        PaddingBottom = UDim.new(0, bottom or top or 0),
        PaddingLeft = UDim.new(0, left or right or top or 0),
        Parent = parent,
    })
end
local function Gradient(parent, sequence, rotation)
    return Create("UIGradient", {
        Color = sequence,
        Rotation = rotation or 90,
        Parent = parent,
    })
end
local FADE_PROPERTIES = {
    Frame = { "BackgroundTransparency" },
    TextLabel = { "BackgroundTransparency", "TextTransparency" },
    ImageLabel = { "BackgroundTransparency", "ImageTransparency" },
    UIStroke = { "Transparency" },
}
local function FadeOut(root, info)
    local targets = root:GetDescendants()
    table.insert(targets, root)
    for _, object in ipairs(targets) do
        local properties = FADE_PROPERTIES[object.ClassName]
        if properties then
            local goal = {}
            for _, property in ipairs(properties) do
                goal[property] = 1
            end
            Tween(object, info, goal)
        end
    end
end
local function IsIconSet(assetId)
    return type(assetId) == "string" and assetId ~= "" and assetId ~= "rbxassetid://0"
end
local function BuildSnowflakeGlyph(parent, size, color)
    local thickness = math.max(2, math.floor(size / 22))
    local branchLength = size * 0.2
    local rootOffset = size * 0.26
    local angle = math.rad(50)
    local glyph = Create("Frame", {
        Name = "SnowflakeGlyph",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    for index = 0, 2 do
        local arm = Create("Frame", {
            Name = "Arm" .. index,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(thickness, size),
            Rotation = index * 60,
            BackgroundColor3 = color,
            Parent = glyph,
        })
        Corner(arm, UDim.new(1, 0))
        for _, tip in ipairs({ -1, 1 }) do
            for _, side in ipairs({ -1, 1 }) do
                local branch = Create("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(
                        0.5 + side * math.sin(angle) * branchLength / 2 / thickness,
                        0.5 + tip * (rootOffset + math.cos(angle) * branchLength / 2) / size
                    ),
                    Size = UDim2.fromScale(1, branchLength / size),
                    Rotation = -tip * side * 50,
                    BackgroundColor3 = color,
                    Parent = arm,
                })
                Corner(branch, UDim.new(1, 0))
            end
        end
    end
    local core = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(thickness * 3, thickness * 3),
        BackgroundColor3 = color,
        Parent = glyph,
    })
    Corner(core, UDim.new(1, 0))
    return glyph
end
local function SnowflakeIcon(parent, size, color)
    local holder = Create("Frame", {
        Name = "SnowflakeIcon",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local hasImage = IsIconSet(Config.Icons.Snowflake)
    Create("ImageLabel", {
        Name = "SnowflakeImage",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = hasImage and Config.Icons.Snowflake or "",
        ImageColor3 = color,
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    if not hasImage then
        BuildSnowflakeGlyph(holder, size, color)
    end
    return holder
end
local function RunBootScreen(onReveal)
    local rng = Random.new()
    local snowActive = true
    local gui = Create("ScreenGui", {
        Name = "WinterBoot",
        DisplayOrder = 1000,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = GuiParent,
    })
    table.insert(Winter.Guis, gui)
    local backdrop = Create("Frame", {
        Name = "Backdrop",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = gui,
    })
    Gradient(backdrop, ColorSequence.new(Color3.fromRGB(15, 24, 48), Theme.Midnight), 90)
    local glow = Create("Frame", {
        Name = "Glow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(0, 0),
        BackgroundTransparency = 1,
        Parent = backdrop,
    })
    for ring = 1, 8 do
        local diameter = 140 + ring * 60
        local disc = Create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(diameter, diameter),
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.972,
            Parent = glow,
        })
        Corner(disc, UDim.new(1, 0))
        TweenService:Create(
            disc,
            TweenInfo.new(2.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { BackgroundTransparency = 0.99 }
        ):Play()
    end
    local snowLayer = Create("Frame", {
        Name = "Snow",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = backdrop,
    })
    local function Fall(wrapper, depth, scatter)
        if not snowActive or not wrapper.Parent then
            return
        end
        local startX = rng:NextNumber(0, 1)
        local startY = scatter and rng:NextNumber(-0.05, 1) or -0.06
        local endY = 1.06
        local speed = 0.06 + depth * 0.12
        wrapper.Position = UDim2.fromScale(startX, startY)
        local fall = TweenService:Create(
            wrapper,
            TweenInfo.new((endY - startY) / speed, Enum.EasingStyle.Linear),
            { Position = UDim2.fromScale(startX + rng:NextNumber(-0.05, 0.05), endY) }
        )
        fall.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed then
                Fall(wrapper, depth, false)
            end
        end)
        fall:Play()
    end
    for _ = 1, Config.Boot.SnowCount do
        local depth = rng:NextNumber(0.15, 1)
        local diameter = math.floor(2 + depth * 5)
        local sway = rng:NextInteger(8, 30)
        local wrapper = Create("Frame", {
            Size = UDim2.fromOffset(0, 0),
            BackgroundTransparency = 1,
            Parent = snowLayer,
        })
        local flake = Create("Frame", {
            Position = UDim2.fromOffset(-sway, 0),
            Size = UDim2.fromOffset(diameter, diameter),
            BackgroundColor3 = Theme.Snow,
            BackgroundTransparency = 0.8 - depth * 0.5,
            Parent = wrapper,
        })
        Corner(flake, UDim.new(1, 0))
        TweenService:Create(
            flake,
            TweenInfo.new(rng:NextNumber(1.8, 3.4), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Position = UDim2.fromOffset(sway, 0) }
        ):Play()
        Fall(wrapper, depth, true)
    end
    local content = Create("Frame", {
        Name = "Content",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(340, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = backdrop,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = content,
    })
    Padding(content, 0, 30, 0, 30)
    local logo = Create("Frame", {
        Name = "Logo",
        Size = UDim2.fromOffset(84, 84),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = content,
    })
    local logoScale = Create("UIScale", { Scale = 0.4, Parent = logo })
    local snowflake = SnowflakeIcon(logo, 72, Theme.Frost)
    Tween(logoScale, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    TweenService:Create(
        snowflake,
        TweenInfo.new(16, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
        { Rotation = 360 }
    ):Play()
    local titleRow = Create("Frame", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 62),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = content,
    })
    Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = titleRow,
    })
    for index = 1, #Config.Name do
        local cell = Create("Frame", {
            Name = "Cell" .. index,
            Size = UDim2.fromOffset(0, 62),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            LayoutOrder = index,
            Parent = titleRow,
        })
        local letter = Create("TextLabel", {
            Name = "Letter",
            Position = UDim2.fromOffset(0, 18),
            Size = UDim2.fromOffset(0, 62),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Text = Config.Name:sub(index, index),
            Font = Config.Fonts.Display,
            TextSize = 54,
            TextColor3 = Theme.Frost,
            TextTransparency = 1,
            Parent = cell,
        })
        task.delay(0.25 + index * 0.07, function()
            Tween(letter, Tweens.Smooth, { TextTransparency = 0, Position = UDim2.fromOffset(0, 0) })
        end)
    end
    local status = Create("TextLabel", {
        Name = "Status",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = Config.Boot.Stages[1].Text,
        Font = Config.Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.TextMuted,
        TextTransparency = 1,
        LayoutOrder = 3,
        Parent = content,
    })
    Tween(status, Tweens.Slow, { TextTransparency = 0 })
    local barBlock = Create("Frame", {
        Name = "Bar",
        Size = UDim2.new(1, 0, 0, 34),
        BackgroundTransparency = 1,
        LayoutOrder = 4,
        Parent = content,
    })
    local percent = Create("TextLabel", {
        Name = "Percent",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.fromOffset(48, 14),
        BackgroundTransparency = 1,
        Text = "0%",
        Font = Config.Fonts.Medium,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = barBlock,
    })
    local track = Create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = Theme.Surface,
        Parent = barBlock,
    })
    Corner(track, UDim.new(1, 0))
    Stroke(track, Theme.Stroke, 1, 0.5)
    local fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = track,
    })
    Corner(fill, UDim.new(1, 0))
    local sheen = Gradient(fill, ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.AccentDeep),
        ColorSequenceKeypoint.new(0.5, Theme.Frost),
        ColorSequenceKeypoint.new(1, Theme.AccentDeep),
    }), 0)
    sheen.Offset = Vector2.new(-0.5, 0)
    TweenService:Create(
        sheen,
        TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Offset = Vector2.new(0.5, 0) }
    ):Play()
    local spark = Create("Frame", {
        Name = "Spark",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(1, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = Theme.Snow,
        BackgroundTransparency = 0.1,
        Parent = fill,
    })
    Corner(spark, UDim.new(1, 0))
    local progress = Create("NumberValue", { Name = "Progress", Parent = gui })
    progress.Changed:Connect(function(value)
        fill.Size = UDim2.fromScale(value, 1)
        percent.Text = string.format("%d%%", math.floor(value * 100 + 0.5))
    end)
    local function SetStatus(text)
        Tween(status, Tweens.Fast, { TextTransparency = 1 }).Completed:Wait()
        status.Text = text
        Tween(status, Tweens.Fast, { TextTransparency = 0 })
    end
    task.spawn(function()
        task.wait(0.6)
        for index, stage in ipairs(Config.Boot.Stages) do
            if not gui.Parent then
                return
            end
            if index > 1 then
                SetStatus(stage.Text)
            end
            local step = Tween(
                progress,
                TweenInfo.new(stage.Time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                { Value = stage.Progress }
            )
            step.Completed:Wait()
            task.wait(0.12)
        end
        task.wait(0.35)
        snowActive = false
        if onReveal then
            task.spawn(onReveal)
        end
        FadeOut(backdrop, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut))
        task.wait(1)
        gui:Destroy()
    end)
end
local ContentProvider = game:GetService("ContentProvider")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local TextService = game:GetService("TextService")
Config.Icons = {
    Snowflake = "rbxassetid://10734964600",
    Combat = "rbxassetid://10734975692",
    Trolling = "rbxassetid://10747374003",
    Visuals = "rbxassetid://10723346959",
    Settings = "rbxassetid://10734950309",
    Info = "rbxassetid://10723415903",
    Telegram = "",
}
Config.Tabs = { "Combat", "Trolling", "Visuals", "Settings", "Info" }
Config.ToggleKey = Enum.KeyCode.RightShift
local WINDOW_WIDTH, WINDOW_HEIGHT = 600, 390
local HEADER_HEIGHT, SIDEBAR_WIDTH = 48, 150
local TAB_HEIGHT, TAB_GAP, TAB_TOP = 40, 6, 12
local function Set(instance, info, properties)
    if info then
        Tween(instance, info, properties)
    else
        for property, value in pairs(properties) do
            instance[property] = value
        end
    end
end
local function NextOrder(container)
    local order = (container:GetAttribute("WinterOrder") or 0) + 1
    container:SetAttribute("WinterOrder", order)
    return order
end
local function GetViewport()
    local camera = Workspace.CurrentCamera
    return camera and camera.ViewportSize or Vector2.new(1280, 720)
end
local function IsPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch
end
local function MakeDraggable(handle, target, onTap)
    local pressing, moved = false, false
    local activeInput, pointerStart, targetStart, absoluteStart
    Winter:Track(handle.InputBegan:Connect(function(input)
        if IsPress(input) then
            pressing, moved = true, false
            activeInput = input
            pointerStart = input.Position
            targetStart = target.Position
            absoluteStart = target.AbsolutePosition
        end
    end))
    Winter:Track(UserInputService.InputChanged:Connect(function(input)
        if not pressing then
            return
        end
        local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
        local isOurTouch = input.UserInputType == Enum.UserInputType.Touch and input == activeInput
        if not (isMouseMove or isOurTouch) then
            return
        end
        local delta = Vector2.new(input.Position.X - pointerStart.X, input.Position.Y - pointerStart.Y)
        if not moved and delta.Magnitude < 6 then
            return
        end
        moved = true
        local screen, size = GetViewport(), target.AbsoluteSize
        local dx = math.clamp(absoluteStart.X + delta.X, 0, math.max(0, screen.X - size.X)) - absoluteStart.X
        local dy = math.clamp(absoluteStart.Y + delta.Y, 0, math.max(0, screen.Y - size.Y)) - absoluteStart.Y
        target.Position = UDim2.new(
            targetStart.X.Scale, targetStart.X.Offset + dx,
            targetStart.Y.Scale, targetStart.Y.Offset + dy
        )
    end))
    Winter:Track(UserInputService.InputEnded:Connect(function(input)
        if pressing and (input == activeInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
            pressing = false
            if not moved and onTap then
                onTap()
            end
        end
    end))
end
local VectorIcons = {}
local function VBar(parent, tint, color, centerX, centerY, width, height, rotation)
    local bar = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(centerX, centerY),
        Size = UDim2.fromScale(width, height),
        Rotation = rotation or 0,
        BackgroundColor3 = color,
        Parent = parent,
    })
    Corner(bar, UDim.new(1, 0))
    table.insert(tint, bar)
    return bar
end
local function VCircle(parent, tint, color, centerX, centerY, diameter, outline)
    local circle = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(centerX, centerY),
        Size = UDim2.fromScale(diameter, diameter),
        BackgroundColor3 = color,
        BackgroundTransparency = outline and 1 or 0,
        Parent = parent,
    })
    Corner(circle, UDim.new(1, 0))
    if outline then
        table.insert(tint, Stroke(circle, color, outline, 0))
    else
        table.insert(tint, circle)
    end
    return circle
end
VectorIcons.Snowflake = function(parent, size, color)
    local glyph = BuildSnowflakeGlyph(parent, size, color)
    local tint = {}
    for _, object in ipairs(glyph:GetDescendants()) do
        if object:IsA("Frame") then
            table.insert(tint, object)
        end
    end
    return tint
end
VectorIcons.Combat = function(parent, size, color)
    local tint = {}
    for _, side in ipairs({ -1, 1 }) do
        VBar(parent, tint, color, 0.5, 0.5, 0.085, 0.9, side * 45)
        VBar(parent, tint, color, 0.5 - side * 0.21, 0.71, 0.3, 0.075, side * 45)
        VCircle(parent, tint, color, 0.5 - side * 0.3, 0.8, 0.11)
    end
    return tint
end
VectorIcons.Trolling = function(parent, size, color)
    local tint = {}
    local line = math.max(1.5, size * 0.085)
    local face = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.8, 0.88),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    Corner(face, UDim.new(0.42, 0))
    table.insert(tint, Stroke(face, color, line, 0))
    VBar(parent, tint, color, 0.34, 0.4, 0.22, 0.08, 18)
    VBar(parent, tint, color, 0.66, 0.4, 0.22, 0.08, -18)
    local mouth = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0.58),
        Size = UDim2.fromScale(0.4, 0.24),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = parent,
    })
    local arc = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, -0.333),
        Size = UDim2.fromScale(0.75, 0.833),
        BackgroundTransparency = 1,
        Parent = mouth,
    })
    Corner(arc, UDim.new(1, 0))
    table.insert(tint, Stroke(arc, color, line, 0))
    return tint
end
VectorIcons.Visuals = function(parent, size, color)
    local tint = {}
    local line = math.max(1.5, size * 0.085)
    local outer = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.92, 0.56),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    Corner(outer, UDim.new(1, 0))
    table.insert(tint, Stroke(outer, color, line, 0))
    VCircle(parent, tint, color, 0.5, 0.5, 0.28)
    return tint
end
VectorIcons.Settings = function(parent, size, color)
    local tint = {}
    VCircle(parent, tint, color, 0.5, 0.5, 0.5, math.max(1.5, size * 0.1))
    for tooth = 0, 7 do
        local angle = math.rad(tooth * 45)
        VBar(
            parent, tint, color,
            0.5 + math.sin(angle) * 0.36, 0.5 - math.cos(angle) * 0.36,
            0.13, 0.2, tooth * 45
        )
    end
    return tint
end
VectorIcons.Info = function(parent, size, color)
    local tint = {}
    VCircle(parent, tint, color, 0.5, 0.5, 0.86, math.max(1.5, size * 0.085))
    VCircle(parent, tint, color, 0.5, 0.31, 0.1)
    VBar(parent, tint, color, 0.5, 0.58, 0.09, 0.3, 0)
    return tint
end
local function BuildIcon(parent, name, size, color)
    local holder = Create("Frame", {
        Name = "Icon" .. name,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1,
        Parent = parent,
    })
    local image = Create("ImageLabel", {
        Name = "Image",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Image = Config.Icons[name] or "",
        ImageColor3 = color,
        ScaleType = Enum.ScaleType.Fit,
        Parent = holder,
    })
    local icon = { Holder = holder, Image = image, Color = color, Tint = {} }
    function icon:SetColor(newColor, info)
        self.Color = newColor
        Set(self.Image, info, { ImageColor3 = newColor })
        for _, part in ipairs(self.Tint) do
            local property = part:IsA("UIStroke") and "Color" or "BackgroundColor3"
            Set(part, info, { [property] = newColor })
        end
    end
    task.spawn(function()
        local failed = false
        local ok = pcall(function()
            ContentProvider:PreloadAsync({ image }, function(_, status)
                if status ~= Enum.AssetFetchStatus.Success then
                    failed = true
                end
            end)
        end)
        if (not ok or failed) and holder.Parent then
            image.Visible = false
            local build = VectorIcons[name]
            if build then
                icon.Tint = build(holder, size, icon.Color)
            end
        end
    end)
    return icon
end
SnowflakeIcon = function(parent, size, color)
    return BuildIcon(parent, "Snowflake", size, color).Holder
end
local Components = {}
local ROW_HEIGHT = 44
local function Row(card, height)
    local order = NextOrder(card)
    local row = Create("Frame", {
        Name = "Row",
        Size = UDim2.new(1, 0, 0, height or ROW_HEIGHT),
        BackgroundColor3 = Theme.SurfaceHigh,
        BackgroundTransparency = 1,
        LayoutOrder = order,
        Parent = card,
    })
    if order > 1 then
        Create("Frame", {
            Name = "Divider",
            Position = UDim2.fromOffset(14, 0),
            Size = UDim2.new(1, -28, 0, 1),
            BackgroundColor3 = Theme.Stroke,
            BackgroundTransparency = 0.55,
            Parent = row,
        })
    end
    row.MouseEnter:Connect(function()
        Tween(row, Tweens.Fast, { BackgroundTransparency = 0.6 })
    end)
    row.MouseLeave:Connect(function()
        Tween(row, Tweens.Fast, { BackgroundTransparency = 1 })
    end)
    return row
end
local function RowLabel(row, text, reserved)
    return Create("TextLabel", {
        Name = "Label",
        Position = UDim2.fromOffset(14, 0),
        Size = UDim2.new(1, -(reserved or 90), 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Config.Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
end
function Components.Heading(page, title, subtitle)
    local block = Create("Frame", {
        Name = "Heading",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = NextOrder(page),
        Parent = page,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = block,
    })
    Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        Text = title,
        Font = Config.Fonts.Display,
        TextSize = 30,
        TextColor3 = Theme.Frost,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 1,
        Parent = block,
    })
    Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = subtitle or "",
        Font = Config.Fonts.Body,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 2,
        Parent = block,
    })
    return block
end
function Components.Section(page, text)
    local label = Create("TextLabel", {
        Name = "Section",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = text,
        Font = Config.Fonts.Medium,
        TextSize = 12,
        TextColor3 = Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = NextOrder(page),
        Parent = page,
    })
    Padding(label, 0, 0, 0, 4)
    local textWidth = TextService:GetTextSize(text, 12, Config.Fonts.Medium, Vector2.new(1000, 18)).X
    local line = Create("Frame", {
        Name = "Line",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, textWidth + 12, 0.5, 0),
        Size = UDim2.new(1, -(textWidth + 12), 0, 1),
        BackgroundColor3 = Theme.Stroke,
        Parent = label,
    })
    Create("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.2),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = line,
    })
    return label
end
function Components.Card(page)
    local card = Create("Frame", {
        Name = "Card",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.new(1, 1, 1),
        LayoutOrder = NextOrder(page),
        Parent = page,
    })
    Gradient(card, ColorSequence.new(Color3.fromRGB(25, 35, 60), Theme.Surface), 90)
    Corner(card, UDim.new(0, 10))
    Stroke(card, Theme.Stroke, 1, 0.55)
    Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = card })
    return card
end
function Components.Note(page, text)
    local note = Create("TextLabel", {
        Name = "Note",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = text,
        Font = Config.Fonts.Body,
        TextSize = 12,
        TextColor3 = Theme.TextDim,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        LayoutOrder = NextOrder(page),
        Parent = page,
    })
    Padding(note, 0, 4, 0, 4)
    return note
end
function Components.Info(card, name, text)
    local row = Row(card)
    RowLabel(row, name, 150)
    Create("TextLabel", {
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.new(0, 140, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Config.Fonts.Body,
        TextSize = 12,
        TextColor3 = Theme.TextMuted,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    return row
end
function Components.Toggle(card, options)
    local state = options.Default == true
    local row = Row(card)
    RowLabel(row, options.Name, 90)
    local track = Create("TextButton", {
        Name = "Track",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(42, 22),
        BackgroundColor3 = Theme.Graphite,
        Text = "",
        Parent = row,
    })
    Corner(track, UDim.new(1, 0))
    Stroke(track, Theme.Stroke, 1, 0.4)
    local knob = Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Theme.TextMuted,
        Parent = track,
    })
    Corner(knob, UDim.new(1, 0))
    local function Render(info)
        Set(track, info, { BackgroundColor3 = state and Theme.AccentDeep or Theme.Graphite })
        Set(knob, info, {
            Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            Size = UDim2.fromOffset(16, 16),
            BackgroundColor3 = state and Theme.Frost or Theme.TextMuted,
        })
    end
    Render(nil)
    track.MouseButton1Down:Connect(function()
        Tween(knob, Tweens.Fast, {
            Size = UDim2.fromOffset(21, 16),
            Position = state and UDim2.new(1, -24, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        })
    end)
    track.MouseButton1Up:Connect(function()
        Render(Tweens.Fast)
    end)
    track.MouseLeave:Connect(function()
        Render(Tweens.Fast)
    end)
    track.MouseButton1Click:Connect(function()
        state = not state
        Render(Tweens.Smooth)
        if options.Callback then
            task.spawn(options.Callback, state)
        end
    end)
    local control = {
        Row = row,
        Type = "boolean",
        Default = options.Default == true,
        Get = function()
            return state
        end,
        Set = function(value)
            state = value == true
            Render(Tweens.Smooth)
        end,
        Apply = function(value)
            state = value == true
            Render(Tweens.Smooth)
            if options.Callback then
                task.spawn(options.Callback, state)
            end
        end,
    }
    if options.Flag then
        Winter.Flags[options.Flag] = control
    end
    return control
end
function Components.Button(card, options)
    local row = Row(card)
    RowLabel(row, options.Name, 120)
    local button = Create("TextButton", {
        Name = "Action",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(78, 28),
        BackgroundColor3 = Theme.SurfaceHigh,
        Text = options.Text or "Press",
        Font = Config.Fonts.Medium,
        TextSize = 12,
        TextColor3 = Theme.Frost,
        Parent = row,
    })
    Corner(button, UDim.new(0, 7))
    local outline = Stroke(button, Theme.Stroke, 1, 0.1)
    local squeeze = Create("UIScale", { Parent = button })
    button.MouseEnter:Connect(function()
        Tween(outline, Tweens.Fast, { Color = Theme.Accent })
    end)
    button.MouseLeave:Connect(function()
        Tween(outline, Tweens.Fast, { Color = Theme.Stroke })
        Tween(squeeze, Tweens.Fast, { Scale = 1 })
        Tween(button, Tweens.Fast, { BackgroundColor3 = Theme.SurfaceHigh })
    end)
    button.MouseButton1Down:Connect(function()
        Tween(squeeze, Tweens.Fast, { Scale = 0.93 })
        Tween(button, Tweens.Fast, { BackgroundColor3 = Theme.AccentDeep })
    end)
    button.MouseButton1Up:Connect(function()
        Tween(squeeze, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
        Tween(button, Tweens.Smooth, { BackgroundColor3 = Theme.SurfaceHigh })
        Tween(outline, Tweens.Smooth, { Color = Theme.Stroke })
    end)
    button.MouseButton1Click:Connect(function()
        if options.Callback then
            task.spawn(options.Callback)
        end
    end)
    return { Row = row, Button = button }
end
function Components.Slider(card, options)
    local minimum = options.Min or 0
    local maximum = options.Max or 100
    local step = options.Step or 1
    local suffix = options.Suffix or ""
    local value = minimum
    local dragging = false
    local activeInput
    local row = Row(card, 60)
    local label = RowLabel(row, options.Name)
    label.Position = UDim2.fromOffset(14, 9)
    label.Size = UDim2.new(0.6, -14, 0, 18)
    local readout = Create("TextLabel", {
        Name = "Value",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 9),
        Size = UDim2.new(0.3, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "",
        Font = Config.Fonts.Medium,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })
    local hit = Create("Frame", {
        Name = "Hit",
        Position = UDim2.new(0, 14, 0, 30),
        Size = UDim2.new(1, -28, 0, 26),
        BackgroundTransparency = 1,
        Active = true,
        Parent = row,
    })
    local track = Create("Frame", {
        Name = "Track",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 0, 6),
        BackgroundColor3 = Theme.Graphite,
        Parent = hit,
    })
    Corner(track, UDim.new(1, 0))
    local fill = Create("Frame", {
        Name = "Fill",
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = track,
    })
    Corner(fill, UDim.new(1, 0))
    Gradient(fill, ColorSequence.new(Theme.AccentDeep, Theme.Accent), 0)
    local halo = Create("Frame", {
        Name = "Halo",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 1,
        Parent = track,
    })
    Corner(halo, UDim.new(1, 0))
    local knob = Create("Frame", {
        Name = "Knob",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Theme.Frost,
        Parent = track,
    })
    Corner(knob, UDim.new(1, 0))
    Stroke(knob, Theme.AccentDeep, 2, 0)
    local function Render(newValue, info, silent)
        local snapped = math.floor((newValue - minimum) / step + 0.5) * step + minimum
        value = math.clamp(snapped, minimum, maximum)
        local alpha = (value - minimum) / (maximum - minimum)
        Set(fill, info, { Size = UDim2.fromScale(alpha, 1) })
        Set(knob, info, { Position = UDim2.fromScale(alpha, 0.5) })
        Set(halo, info, { Position = UDim2.fromScale(alpha, 0.5) })
        readout.Text = string.format("%g", value) .. suffix
        if options.Callback and not silent then
            task.spawn(options.Callback, value)
        end
    end
    local function FromPointer(x, info)
        local width = track.AbsoluteSize.X
        if width <= 0 then
            return
        end
        local alpha = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        Render(minimum + (maximum - minimum) * alpha, info)
    end
    local function Hold(active)
        dragging = active
        local scroller = row:FindFirstAncestorOfClass("ScrollingFrame")
        if scroller then
            scroller.ScrollingEnabled = not active
        end
        Tween(knob, Tweens.Fast, { Size = active and UDim2.fromOffset(18, 18) or UDim2.fromOffset(14, 14) })
        Tween(halo, Tweens.Smooth, {
            Size = active and UDim2.fromOffset(32, 32) or UDim2.fromOffset(14, 14),
            BackgroundTransparency = active and 0.8 or 1,
        })
    end
    hit.InputBegan:Connect(function(input)
        if IsPress(input) then
            activeInput = input
            Hold(true)
            FromPointer(input.Position.X, Tweens.Fast)
        end
    end)
    Winter:Track(UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        local isMouseMove = input.UserInputType == Enum.UserInputType.MouseMovement
        local isOurTouch = input.UserInputType == Enum.UserInputType.Touch and input == activeInput
        if isMouseMove or isOurTouch then
            FromPointer(input.Position.X, nil)
        end
    end))
    Winter:Track(UserInputService.InputEnded:Connect(function(input)
        if dragging and (input == activeInput or input.UserInputType == Enum.UserInputType.MouseButton1) then
            Hold(false)
        end
    end))
    Render(options.Default or minimum, nil, true)
    local control = {
        Row = row,
        Type = "number",
        Default = options.Default or minimum,
        Get = function()
            return value
        end,
        Set = function(newValue)
            Render(newValue, Tweens.Fast)
        end,
        Apply = function(newValue)
            Render(newValue, Tweens.Fast)
        end,
    }
    if options.Flag then
        Winter.Flags[options.Flag] = control
    end
    return control
end
local ButtonStyles = {
    Default = {
        Fill = Theme.SurfaceHigh, Outline = Theme.Stroke, OutlineTransparency = 0.1,
        Hover = Theme.Accent, Press = Theme.AccentDeep, Text = Theme.Frost,
    },
    Delete = {
        Fill = Theme.SurfaceHigh, Outline = Theme.Stroke, OutlineTransparency = 0.1,
        Hover = Theme.Danger, Press = Theme.DangerDeep, Text = Theme.Frost,
    },
    Danger = {
        Fill = Theme.Danger, HoverFill = Theme.DangerHover,
        Outline = Theme.DangerSoft, OutlineTransparency = 0.45,
        Hover = Theme.DangerSoft, Press = Theme.DangerDeep, Text = Theme.Snow,
    },
}
local function ActionButton(parent, options)
    local style = ButtonStyles[options.Style or "Default"]
    local idleFill = style.Fill
    local hoverFill = style.HoverFill or style.Fill
    local button = Create("TextButton", {
        Name = options.Name or "Action",
        AnchorPoint = options.AnchorPoint or Vector2.new(0, 0),
        Position = options.Position or UDim2.new(),
        Size = UDim2.fromOffset(options.Width or 78, options.Height or 28),
        BackgroundColor3 = idleFill,
        Text = options.Text or "Press",
        Font = Config.Fonts.Medium,
        TextSize = 12,
        TextColor3 = style.Text,
        Parent = parent,
    })
    Corner(button, UDim.new(0, 7))
    local outline = Stroke(button, style.Outline, 1, style.OutlineTransparency)
    local squeeze = Create("UIScale", { Parent = button })
    local hovering = false
    button.MouseEnter:Connect(function()
        hovering = true
        Tween(outline, Tweens.Fast, { Color = style.Hover })
        Tween(button, Tweens.Fast, { BackgroundColor3 = hoverFill })
    end)
    button.MouseLeave:Connect(function()
        hovering = false
        Tween(outline, Tweens.Fast, { Color = style.Outline })
        Tween(squeeze, Tweens.Fast, { Scale = 1 })
        Tween(button, Tweens.Fast, { BackgroundColor3 = idleFill })
    end)
    button.MouseButton1Down:Connect(function()
        Tween(squeeze, Tweens.Fast, { Scale = 0.93 })
        Tween(button, Tweens.Fast, { BackgroundColor3 = style.Press })
    end)
    button.MouseButton1Up:Connect(function()
        Tween(squeeze, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
        Tween(button, Tweens.Smooth, { BackgroundColor3 = hovering and hoverFill or idleFill })
    end)
    if options.Callback then
        button.MouseButton1Click:Connect(function()
            task.spawn(options.Callback)
        end)
    end
    return button
end
local function VLine(parent, x1, y1, x2, y2, thickness, color)
    local dx, dy = x2 - x1, y2 - y1
    local bar = Create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale((x1 + x2) / 2, (y1 + y2) / 2),
        Size = UDim2.fromScale(math.sqrt(dx * dx + dy * dy) + thickness, thickness),
        Rotation = math.deg(math.atan2(dy, dx)),
        BackgroundColor3 = color,
        Parent = parent,
    })
    Corner(bar, UDim.new(1, 0))
    return bar
end
local function BuildTelegramLogo(parent, size)
    if IsIconSet(Config.Icons.Telegram) then
        return Create("ImageLabel", {
            Name = "TelegramLogo",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(size, size),
            BackgroundTransparency = 1,
            Image = Config.Icons.Telegram,
            ScaleType = Enum.ScaleType.Fit,
            Parent = parent,
        })
    end
    local logo = Create("Frame", {
        Name = "TelegramLogo",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = parent,
    })
    Corner(logo, UDim.new(1, 0))
    Gradient(logo, ColorSequence.new(Color3.fromRGB(64, 180, 232), Color3.fromRGB(30, 146, 204)), 90)
    local function Point(px, py)
        return 0.25 + px / 24 * 0.5, 0.25 + py / 24 * 0.5
    end
    local outline = { { 22, 2 }, { 15, 22 }, { 11, 13 }, { 2, 9 } }
    for index = 1, #outline do
        local from, to = outline[index], outline[index % #outline + 1]
        local x1, y1 = Point(from[1], from[2])
        local x2, y2 = Point(to[1], to[2])
        VLine(logo, x1, y1, x2, y2, 0.06, Color3.new(1, 1, 1))
    end
    local x1, y1 = Point(22, 2)
    local x2, y2 = Point(11, 13)
    VLine(logo, x1, y1, x2, y2, 0.06, Color3.new(1, 1, 1))
    return logo
end
local function CopyText(text)
    local copier = (typeof(setclipboard) == "function" and setclipboard)
        or (typeof(toclipboard) == "function" and toclipboard)
        or (typeof(set_clipboard) == "function" and set_clipboard)
    if not copier then
        return false
    end
    return (pcall(copier, text))
end
function Components.TextAction(card, options)
    local buttonWidth = options.ButtonWidth or 90
    local row = Row(card, 52)
    local holder = Create("Frame", {
        Name = "InputHolder",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.new(1, -(buttonWidth + 36), 0, 30),
        BackgroundColor3 = Theme.Window,
        ClipsDescendants = true,
        Parent = row,
    })
    Corner(holder, UDim.new(0, 7))
    local outline = Stroke(holder, Theme.Stroke, 1, 0.2)
    local box = Create("TextBox", {
        Name = "Input",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = options.Placeholder or "",
        PlaceholderColor3 = Theme.TextDim,
        ClearTextOnFocus = false,
        Font = Config.Fonts.Body,
        TextSize = 13,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = holder,
    })
    Padding(box, 0, 10, 0, 10)
    box.Focused:Connect(function()
        Tween(outline, Tweens.Fast, { Color = Theme.Accent, Transparency = 0 })
    end)
    box.FocusLost:Connect(function(enterPressed)
        Tween(outline, Tweens.Fast, { Color = Theme.Stroke, Transparency = 0.2 })
        if enterPressed and options.Callback then
            task.spawn(options.Callback, box.Text, box)
        end
    end)
    if options.Filter then
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local cleaned = options.Filter(box.Text)
            if cleaned ~= box.Text then
                box.Text = cleaned
            end
        end)
    end
    local button = ActionButton(row, {
        Name = "Submit",
        Text = options.ButtonText or "OK",
        Width = buttonWidth,
        Height = 30,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Callback = function()
            if options.Callback then
                options.Callback(box.Text, box)
            end
        end,
    })
    return { Row = row, Box = box, Button = button }
end
function Components.LinkRow(card, options)
    local row = Row(card, 60)
    local hit = Create("TextButton", {
        Name = "Hit",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    local iconHolder = Create("Frame", {
        Name = "Icon",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(34, 34),
        BackgroundTransparency = 1,
        Parent = row,
    })
    if options.Icon then
        options.Icon(iconHolder, 34)
    end
    Create("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(60, 10),
        Size = UDim2.new(1, -150, 0, 18),
        BackgroundTransparency = 1,
        Text = options.Title,
        Font = Config.Fonts.Medium,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })
    Create("TextLabel", {
        Name = "Link",
        Position = UDim2.fromOffset(60, 30),
        Size = UDim2.new(1, -150, 0, 16),
        BackgroundTransparency = 1,
        Text = options.Text,
        Font = Config.Fonts.Body,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = row,
    })
    local idleText = options.ButtonText or "Copy"
    local copyButton = ActionButton(row, {
        Name = "Copy",
        Text = idleText,
        Width = 70,
        Height = 28,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
    })
    local resetToken = 0
    local function Activate()
        local ok = options.OnActivate and options.OnActivate()
        resetToken = resetToken + 1
        local token = resetToken
        copyButton.Text = ok and (options.DoneText or "Done") or "Failed"
        task.delay(1.6, function()
            if token == resetToken and copyButton.Parent then
                copyButton.Text = idleText
            end
        end)
    end
    local pressed, heldFired, pressId = false, false, 0
    hit.InputBegan:Connect(function(input)
        if not IsPress(input) then
            return
        end
        pressed, heldFired = true, false
        pressId = pressId + 1
        local id = pressId
        task.delay(0.4, function()
            if pressed and id == pressId then
                heldFired = true
                Activate()
            end
        end)
    end)
    hit.InputEnded:Connect(function(input)
        if IsPress(input) then
            pressed = false
        end
    end)
    hit.MouseButton1Click:Connect(function()
        if heldFired then
            heldFired = false
            return
        end
        Activate()
    end)
    copyButton.MouseButton1Click:Connect(Activate)
    hit.MouseEnter:Connect(function()
        Tween(row, Tweens.Fast, { BackgroundTransparency = 0.6 })
    end)
    hit.MouseLeave:Connect(function()
        Tween(row, Tweens.Fast, { BackgroundTransparency = 1 })
    end)
    return { Row = row, Button = copyButton }
end
function Components.Banner(page, text, detail)
    local banner = Create("Frame", {
        Name = "Banner",
        Size = UDim2.new(1, 0, 0, 46),
        BackgroundColor3 = Color3.new(1, 1, 1),
        LayoutOrder = NextOrder(page),
        Parent = page,
    })
    Corner(banner, UDim.new(0, 10))
    Stroke(banner, Theme.Accent, 1, 0.6)
    Gradient(banner, ColorSequence.new(Theme.SurfaceHigh, Theme.Surface), 0)
    local badge = Create("Frame", {
        Name = "Badge",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 14, 0.5, 0),
        Size = UDim2.fromOffset(22, 22),
        BackgroundColor3 = Theme.Accent,
        Parent = banner,
    })
    Corner(badge, UDim.new(1, 0))
    VLine(badge, 0.29, 0.52, 0.44, 0.67, 0.13, Theme.Midnight)
    VLine(badge, 0.44, 0.67, 0.72, 0.36, 0.13, Theme.Midnight)
    Create("TextLabel", {
        Name = "Text",
        Position = UDim2.fromOffset(48, 0),
        Size = UDim2.new(1, -110, 1, 0),
        BackgroundTransparency = 1,
        Text = text,
        Font = Config.Fonts.Medium,
        TextSize = 13,
        TextColor3 = Theme.Frost,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = banner,
    })
    if detail then
        Create("TextLabel", {
            Name = "Detail",
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -14, 0.5, 0),
            Size = UDim2.fromOffset(52, 20),
            BackgroundTransparency = 1,
            Text = detail,
            Font = Config.Fonts.Medium,
            TextSize = 12,
            TextColor3 = Theme.Accent,
            TextXAlignment = Enum.TextXAlignment.Right,
            Parent = banner,
        })
    end
    return banner
end
local function FilterConfigName(text)
    return (tostring(text):gsub("[^%w _%-]", "")):sub(1, 24)
end
local function CleanConfigName(text)
    return (FilterConfigName(text):gsub("^%s+", ""):gsub("%s+$", ""))
end
local ConfigStore = {
    Folder = "WinterConfigs",
    UsesFiles = typeof(writefile) == "function" and typeof(readfile) == "function"
        and typeof(delfile) == "function" and typeof(listfiles) == "function"
        and typeof(isfolder) == "function" and typeof(makefolder) == "function",
}
env.WinterConfigMemory = env.WinterConfigMemory or {}
ConfigStore.Memory = env.WinterConfigMemory
function ConfigStore.Path(name)
    return ConfigStore.Folder .. "/" .. name .. ".json"
end
function ConfigStore.List()
    local names = {}
    if ConfigStore.UsesFiles then
        local ok, files = pcall(function()
            if not isfolder(ConfigStore.Folder) then
                return {}
            end
            return listfiles(ConfigStore.Folder)
        end)
        if ok and type(files) == "table" then
            for _, path in ipairs(files) do
                local name = tostring(path):match("([^/\\]+)%.json$")
                if name then
                    table.insert(names, name)
                end
            end
        end
    else
        for name in pairs(ConfigStore.Memory) do
            table.insert(names, name)
        end
    end
    table.sort(names, function(a, b)
        return a:lower() < b:lower()
    end)
    return names
end
function ConfigStore.Save(name, data)
    if not ConfigStore.UsesFiles then
        ConfigStore.Memory[name] = data
        return true
    end
    return pcall(function()
        if not isfolder(ConfigStore.Folder) then
            makefolder(ConfigStore.Folder)
        end
        writefile(ConfigStore.Path(name), HttpService:JSONEncode(data))
    end)
end
function ConfigStore.Load(name)
    if not ConfigStore.UsesFiles then
        return ConfigStore.Memory[name]
    end
    local ok, data = pcall(function()
        return HttpService:JSONDecode(readfile(ConfigStore.Path(name)))
    end)
    if ok and type(data) == "table" then
        return data
    end
    return nil
end
function ConfigStore.Delete(name)
    if not ConfigStore.UsesFiles then
        ConfigStore.Memory[name] = nil
        return true
    end
    return pcall(function()
        local path = ConfigStore.Path(name)
        if typeof(isfile) ~= "function" or isfile(path) then
            delfile(path)
        end
    end)
end
local Fullbright = { Enabled = false, Level = 3, Targets = {}, Saved = {}, Atmosphere = nil }
local FULLBRIGHT_KEYS = { "Brightness", "GlobalShadows", "FogEnd", "Ambient", "OutdoorAmbient" }
local function RefreshFullbright()
    local gray = math.clamp(0.5 + Fullbright.Level * 0.1, 0, 1)
    local tone = Color3.new(gray, gray, gray)
    Fullbright.Targets = {
        Brightness = Fullbright.Level,
        GlobalShadows = false,
        FogEnd = 1e6,
        Ambient = tone,
        OutdoorAmbient = tone,
    }
end
RefreshFullbright()
local function EnforceFullbright()
    for key, value in pairs(Fullbright.Targets) do
        if Lighting[key] ~= value then
            Lighting[key] = value
        end
    end
    local saved = Fullbright.Atmosphere
    if saved and saved.Object.Parent then
        if saved.Object.Density ~= 0 then
            saved.Object.Density = 0
        end
        if saved.Object.Haze ~= 0 then
            saved.Object.Haze = 0
        end
    end
end
local function SetFullbrightLevel(level)
    Fullbright.Level = level
    RefreshFullbright()
end
local function SetFullbright(enabled)
    enabled = enabled == true
    if enabled == Fullbright.Enabled then
        return
    end
    Fullbright.Enabled = enabled
    pcall(function()
        RunService:UnbindFromRenderStep("WinterFullbright")
    end)
    if enabled then
        Fullbright.Saved = {}
        for _, key in ipairs(FULLBRIGHT_KEYS) do
            Fullbright.Saved[key] = Lighting[key]
        end
        local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
        Fullbright.Atmosphere = atmosphere
            and { Object = atmosphere, Density = atmosphere.Density, Haze = atmosphere.Haze }
            or nil
        RefreshFullbright()
        RunService:BindToRenderStep("WinterFullbright", Enum.RenderPriority.Last.Value, EnforceFullbright)
    else
        for key, value in pairs(Fullbright.Saved) do
            Lighting[key] = value
        end
        local saved = Fullbright.Atmosphere
        if saved and saved.Object.Parent then
            saved.Object.Density = saved.Density
            saved.Object.Haze = saved.Haze
        end
        Fullbright.Atmosphere = nil
    end
end
local Stretch = { Enabled = false, Amount = 0.3 }
local function StretchStep()
    local camera = Workspace.CurrentCamera
    if camera then
        camera.CFrame = camera.CFrame * CFrame.new(0, 0, 0, 1, 0, 0, 0, 1 - Stretch.Amount, 0, 0, 0, 1)
    end
end
local function SetStretchAmount(percent)
    Stretch.Amount = math.clamp(percent / 100, 0, 0.7)
end
local function SetStretch(enabled)
    enabled = enabled == true
    if enabled == Stretch.Enabled then
        return
    end
    Stretch.Enabled = enabled
    pcall(function()
        RunService:UnbindFromRenderStep("WinterStretch")
    end)
    if enabled then
        RunService:BindToRenderStep("WinterStretch", Enum.RenderPriority.Camera.Value + 1, StretchStep)
    end
end
table.insert(Winter.Cleanup, function()
    SetFullbright(false)
    SetStretch(false)
end)
local ExamplePages = {
    Combat = {
        Subtitle = "Interface preview. The controls on this page do nothing yet.",
        Toggles = {
            { Name = "Toggle one" },
            { Name = "Toggle two", Default = true },
            { Name = "Toggle three" },
        },
        Sliders = {
            { Name = "Slider one", Min = 0, Max = 100, Default = 40, Step = 1, Suffix = "%" },
            { Name = "Slider two", Min = 1, Max = 10, Default = 3, Step = 1 },
        },
        Buttons = {
            { Name = "Button one" },
            { Name = "Button two", Text = "Apply" },
        },
    },
    Trolling = {
        Subtitle = "Interface preview. The controls on this page do nothing yet.",
        Toggles = {
            { Name = "Toggle one" },
            { Name = "Toggle two" },
        },
        Sliders = {
            { Name = "Slider one", Min = 0, Max = 50, Default = 10, Step = 5, Suffix = " s" },
        },
        Buttons = {
            { Name = "Button one" },
            { Name = "Button two", Text = "Apply" },
            { Name = "Button three", Text = "Reset" },
        },
    },
}
local function BuildWindow()
    local screen = GetViewport()
    local fit = math.min(1, screen.X * 0.94 / WINDOW_WIDTH, screen.Y * 0.9 / WINDOW_HEIGHT)
    local userScale = 1
    local windowTransparency = 0
    local isOpen = true
    local busy = false
    local orbPlaced = false
    local capturingKey = false
    local toggleKeyLabel
    local configCard
    local activeConfig
    local RenderConfigList
    local function CurrentScale()
        return fit * userScale
    end
    local gui = Create("ScreenGui", {
        Name = "WinterMain",
        DisplayOrder = 500,
        IgnoreGuiInset = true,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = GuiParent,
    })
    table.insert(Winter.Guis, gui)
    local root = Create("Frame", {
        Name = "Root",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(WINDOW_WIDTH * CurrentScale(), WINDOW_HEIGHT * CurrentScale()),
        BackgroundTransparency = 1,
        Parent = gui,
    })
    local shadows = {}
    for layer = 1, 6 do
        local shadow = Create("Frame", {
            Name = "Shadow" .. layer,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 10),
            Size = UDim2.new(1, layer * 10, 1, layer * 10),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            Parent = root,
        })
        Corner(shadow, UDim.new(0, 14 + layer * 5))
        shadows[layer] = shadow
    end
    local function FadeShadow(transparency, info)
        for _, shadow in ipairs(shadows) do
            Set(shadow, info, { BackgroundTransparency = transparency })
        end
    end
    local window = Create("CanvasGroup", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT),
        BackgroundTransparency = 1,
        GroupTransparency = 1,
        Parent = root,
    })
    local windowScale = Create("UIScale", { Scale = CurrentScale() * 0.94, Parent = window })
    Corner(window, UDim.new(0, 14))
    local background = Create("Frame", {
        Name = "Background",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Active = true,
        Parent = window,
    })
    Gradient(background, ColorSequence.new(Color3.fromRGB(18, 26, 48), Color3.fromRGB(10, 14, 27)), 90)
    local topLight = Create("Frame", {
        Name = "TopLight",
        Size = UDim2.new(1, 0, 0, 130),
        BackgroundColor3 = Theme.Accent,
        Parent = window,
    })
    Create("UIGradient", { Transparency = NumberSequence.new(0.88, 1), Rotation = 90, Parent = topLight })
    local snow = Create("Frame", {
        Name = "Snow",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = not Config.IsMobile,
        Parent = window,
    })
    local snowRng = Random.new()
    for _ = 1, Config.IsMobile and 10 or 20 do
        local size = snowRng:NextInteger(2, 4)
        local flake = Create("Frame", {
            Name = "Flake",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = Theme.Snow,
            BackgroundTransparency = 0.55 + snowRng:NextNumber() * 0.3,
            Parent = snow,
        })
        Corner(flake, UDim.new(1, 0))
        task.spawn(function()
            task.wait(snowRng:NextNumber() * 6)
            while flake.Parent do
                if snow.Visible then
                    local x = snowRng:NextNumber()
                    flake.Position = UDim2.new(x, 0, 0, -6)
                    local fall = TweenService:Create(
                        flake,
                        TweenInfo.new(7 + snowRng:NextNumber() * 7, Enum.EasingStyle.Linear),
                        { Position = UDim2.new(x + (snowRng:NextNumber() - 0.5) * 0.12, 0, 1, 6) }
                    )
                    fall:Play()
                    fall.Completed:Wait()
                else
                    snow:GetPropertyChangedSignal("Visible"):Wait()
                end
            end
        end)
    end
    local header = Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
        BackgroundTransparency = 1,
        Parent = window,
    })
    Create("Frame", {
        Name = "Divider",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.fromScale(0, 1),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 0.5,
        Parent = header,
    })
    local dragArea = Create("Frame", {
        Name = "DragArea",
        Size = UDim2.new(1, -64, 1, 0),
        BackgroundTransparency = 1,
        Active = true,
        Parent = header,
    })
    local logo = BuildIcon(dragArea, "Snowflake", 22, Theme.Accent)
    logo.Holder.AnchorPoint = Vector2.new(0, 0.5)
    logo.Holder.Position = UDim2.new(0, 18, 0.5, 0)
    Create("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(52, 0),
        Size = UDim2.new(1, -52, 1, 0),
        BackgroundTransparency = 1,
        Text = Config.Name,
        Font = Config.Fonts.Display,
        TextSize = 26,
        TextColor3 = Theme.Frost,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dragArea,
    })
    local titleWidth = TextService:GetTextSize(Config.Name, 26, Config.Fonts.Display, Vector2.new(1000, 40)).X
    local versionText = "v" .. Config.Version
    local chipWidth = TextService:GetTextSize(versionText, 11, Config.Fonts.Medium, Vector2.new(1000, 20)).X + 16
    local chip = Create("TextLabel", {
        Name = "Version",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 52 + titleWidth + 10, 0.5, 2),
        Size = UDim2.fromOffset(chipWidth, 18),
        BackgroundColor3 = Theme.SurfaceHigh,
        Text = versionText,
        Font = Config.Fonts.Medium,
        TextSize = 11,
        TextColor3 = Theme.Accent,
        Parent = dragArea,
    })
    Corner(chip, UDim.new(1, 0))
    Stroke(chip, Theme.Accent, 1, 0.65)
    local minimize = Create("TextButton", {
        Name = "Minimize",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.fromOffset(36, 30),
        BackgroundColor3 = Theme.SurfaceHigh,
        BackgroundTransparency = 1,
        Text = "-",
        Font = Config.Fonts.Bold,
        TextSize = 24,
        TextColor3 = Theme.TextMuted,
        Parent = header,
    })
    Corner(minimize, UDim.new(0, 8))
    local minimizeScale = Create("UIScale", { Parent = minimize })
    local sidebar = Create("Frame", {
        Name = "Sidebar",
        Position = UDim2.fromOffset(0, HEADER_HEIGHT),
        Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -HEADER_HEIGHT),
        BackgroundColor3 = Theme.Midnight,
        BackgroundTransparency = 0.5,
        Parent = window,
    })
    Create("Frame", {
        Name = "Edge",
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.Stroke,
        BackgroundTransparency = 0.5,
        Parent = sidebar,
    })
    local indicator = Create("Frame", {
        Name = "Indicator",
        Position = UDim2.fromOffset(10, TAB_TOP),
        Size = UDim2.new(1, -21, 0, TAB_HEIGHT),
        BackgroundColor3 = Theme.SurfaceHigh,
        Parent = sidebar,
    })
    Corner(indicator, UDim.new(0, 9))
    Stroke(indicator, Theme.Accent, 1, 0.7)
    local marker = Create("Frame", {
        Name = "Marker",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 5, 0.5, 0),
        Size = UDim2.fromOffset(3, 16),
        BackgroundColor3 = Theme.Accent,
        Parent = indicator,
    })
    Corner(marker, UDim.new(1, 0))
    local tabList = Create("Frame", {
        Name = "Tabs",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = sidebar,
    })
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, TAB_GAP),
        Parent = tabList,
    })
    Padding(tabList, TAB_TOP, 11, 0, 10)
    local pages = Create("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(SIDEBAR_WIDTH, HEADER_HEIGHT),
        Size = UDim2.new(1, -SIDEBAR_WIDTH, 1, -HEADER_HEIGHT),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = window,
    })
    local rim = Create("Frame", {
        Name = "Rim",
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BackgroundTransparency = 1,
        Parent = window,
    })
    Corner(rim, UDim.new(0, 13))
    local rimStroke = Stroke(rim, Theme.Stroke, 1, 0.1)
    Gradient(rimStroke, ColorSequence.new(Theme.Accent, Theme.Stroke), 60)
    local orb = Create("CanvasGroup", {
        Name = "Orb",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromOffset(60, 60),
        Size = UDim2.fromOffset(56, 56),
        BackgroundColor3 = Theme.Surface,
        GroupTransparency = 1,
        Visible = false,
        Active = true,
        Parent = gui,
    })
    local orbScale = Create("UIScale", { Scale = 0.4, Parent = orb })
    Corner(orb, UDim.new(1, 0))
    local orbLight = Create("Frame", {
        Name = "Light",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Theme.Accent,
        Parent = orb,
    })
    Create("UIGradient", { Transparency = NumberSequence.new(0.7, 1), Rotation = 45, Parent = orbLight })
    local orbRim = Create("Frame", {
        Name = "Rim",
        Position = UDim2.fromOffset(2, 2),
        Size = UDim2.new(1, -4, 1, -4),
        BackgroundTransparency = 1,
        Parent = orb,
    })
    Corner(orbRim, UDim.new(1, 0))
    Stroke(orbRim, Theme.Accent, 1.5, 0.35)
    local orbIcon = BuildIcon(orb, "Snowflake", 28, Theme.Frost)
    TweenService:Create(
        orbIcon.Holder,
        TweenInfo.new(18, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1),
        { Rotation = 360 }
    ):Play()
    local function ApplyScale(info)
        local scale = CurrentScale()
        Set(windowScale, info, { Scale = scale })
        Set(root, info, { Size = UDim2.fromOffset(WINDOW_WIDTH * scale, WINDOW_HEIGHT * scale) })
    end
    local function ResetPosition()
        Tween(root, Tweens.Smooth, { Position = UDim2.fromScale(0.5, 0.5) })
    end
    local function PlaceOrb()
        if orbPlaced then
            return
        end
        orbPlaced = true
        local bounds = GetViewport()
        orb.Position = UDim2.fromOffset(
            math.clamp(root.AbsolutePosition.X + 44, 36, bounds.X - 36),
            math.clamp(root.AbsolutePosition.Y + 44, 36, bounds.Y - 36)
        )
    end
    local function Minimize()
        if busy or not isOpen then
            return
        end
        busy, isOpen = true, false
        Tween(window, Tweens.Fast, { GroupTransparency = 1 })
        Tween(windowScale, Tweens.Fast, { Scale = CurrentScale() * 0.92 })
        FadeShadow(1, Tweens.Fast)
        task.delay(0.18, function()
            root.Visible = false
            PlaceOrb()
            orb.Visible = true
            orb.GroupTransparency = 1
            orbScale.Scale = 0.4
            Tween(orb, Tweens.Smooth, { GroupTransparency = 0 })
            Tween(orbScale, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
            busy = false
        end)
    end
    local function Restore()
        if busy or isOpen then
            return
        end
        busy, isOpen = true, true
        Tween(orb, Tweens.Fast, { GroupTransparency = 1 })
        Tween(orbScale, Tweens.Fast, { Scale = 0.4 })
        task.delay(0.18, function()
            orb.Visible = false
            root.Visible = true
            window.GroupTransparency = 1
            windowScale.Scale = CurrentScale() * 0.92
            Tween(window, Tweens.Smooth, { GroupTransparency = windowTransparency })
            Tween(windowScale, Tweens.Smooth, { Scale = CurrentScale() })
            FadeShadow(0.93, Tweens.Smooth)
            busy = false
        end)
    end
    local function BuildPage(name)
        local group = Create("CanvasGroup", {
            Name = name .. "Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            GroupTransparency = 1,
            Visible = false,
            Parent = pages,
        })
        local scroller = Create("ScrollingFrame", {
            Name = "Scroll",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Active = true,
            CanvasSize = UDim2.new(),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Stroke,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Parent = group,
        })
        Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = scroller,
        })
        Padding(scroller, 16, 18, 20, 16)
        return group, scroller
    end
    local function FillExample(scroller, name)
        local data = ExamplePages[name]
        if not data then
            Components.Heading(scroller, name, "Empty page. Add your own controls here.")
            return
        end
        Components.Heading(scroller, name, data.Subtitle)
        Components.Section(scroller, "Toggles")
        local toggles = Components.Card(scroller)
        for _, entry in ipairs(data.Toggles) do
            Components.Toggle(toggles, entry)
        end
        Components.Section(scroller, "Sliders")
        local sliders = Components.Card(scroller)
        for _, entry in ipairs(data.Sliders) do
            Components.Slider(sliders, entry)
        end
        Components.Section(scroller, "Buttons")
        local buttons = Components.Card(scroller)
        for _, entry in ipairs(data.Buttons) do
            Components.Button(buttons, entry)
        end
    end
    local toastRest = UDim2.new(0, SIDEBAR_WIDTH + (WINDOW_WIDTH - SIDEBAR_WIDTH) / 2, 1, -16)
    local toast = Create("CanvasGroup", {
        Name = "Toast",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = toastRest,
        Size = UDim2.fromOffset(280, 34),
        BackgroundColor3 = Theme.SurfaceHigh,
        GroupTransparency = 1,
        Visible = false,
        ZIndex = 80,
        Parent = window,
    })
    Corner(toast, UDim.new(0, 9))
    local toastRim = Create("Frame", {
        Name = "Rim",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = toast,
    })
    Corner(toastRim, UDim.new(0, 9))
    local toastStroke = Stroke(toastRim, Theme.Accent, 1, 0.45)
    local toastLabel = Create("TextLabel", {
        Name = "Text",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "",
        Font = Config.Fonts.Medium,
        TextSize = 12,
        TextColor3 = Theme.Frost,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = toast,
    })
    Padding(toastLabel, 0, 12, 0, 28)
    local toastDot = Create("Frame", {
        Name = "Dot",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 12, 0.5, 0),
        Size = UDim2.fromOffset(8, 8),
        BackgroundColor3 = Theme.Accent,
        Parent = toast,
    })
    Corner(toastDot, UDim.new(1, 0))
    local toastToken = 0
    local function Toast(text, isError)
        toastToken = toastToken + 1
        local token = toastToken
        toastLabel.Text = text
        toastStroke.Color = isError and Theme.Danger or Theme.Accent
        toastDot.BackgroundColor3 = isError and Theme.Danger or Theme.Accent
        toast.Position = toastRest + UDim2.fromOffset(0, 8)
        toast.Visible = true
        Tween(toast, Tweens.Smooth, { GroupTransparency = 0, Position = toastRest })
        task.delay(2.4, function()
            if token ~= toastToken then
                return
            end
            Tween(toast, Tweens.Fast, { GroupTransparency = 1 })
            task.delay(0.2, function()
                if token == toastToken then
                    toast.Visible = false
                end
            end)
        end)
    end
    local footer = Create("TextButton", {
        Name = "Footer",
        AnchorPoint = Vector2.new(0, 1),
        Position = UDim2.new(0, 10, 1, -10),
        Size = UDim2.new(1, -21, 0, 42),
        BackgroundColor3 = Theme.SurfaceHigh,
        BackgroundTransparency = 0.6,
        Text = "",
        Parent = sidebar,
    })
    Corner(footer, UDim.new(0, 9))
    local footerStroke = Stroke(footer, Theme.Stroke, 1, 0.5)
    local footerPress = Create("UIScale", { Parent = footer })
    local footerIcon = Create("Frame", {
        Name = "Icon",
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 9, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        BackgroundTransparency = 1,
        Parent = footer,
    })
    BuildTelegramLogo(footerIcon, 26)
    Create("TextLabel", {
        Name = "Title",
        Position = UDim2.fromOffset(44, 6),
        Size = UDim2.new(1, -48, 0, 16),
        BackgroundTransparency = 1,
        Text = "Telegram",
        Font = Config.Fonts.Medium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = footer,
    })
    Create("TextLabel", {
        Name = "Hint",
        Position = UDim2.fromOffset(44, 22),
        Size = UDim2.new(1, -48, 0, 14),
        BackgroundTransparency = 1,
        Text = "Tap to copy link",
        Font = Config.Fonts.Body,
        TextSize = 11,
        TextColor3 = Theme.TextDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = footer,
    })
    footer.MouseEnter:Connect(function()
        Tween(footer, Tweens.Fast, { BackgroundTransparency = 0.3 })
        Tween(footerStroke, Tweens.Fast, { Color = Theme.Accent })
    end)
    footer.MouseLeave:Connect(function()
        Tween(footer, Tweens.Fast, { BackgroundTransparency = 0.6 })
        Tween(footerStroke, Tweens.Fast, { Color = Theme.Stroke })
        Tween(footerPress, Tweens.Fast, { Scale = 1 })
    end)
    footer.MouseButton1Down:Connect(function()
        Tween(footerPress, Tweens.Fast, { Scale = 0.96 })
    end)
    footer.MouseButton1Up:Connect(function()
        Tween(footerPress, Tweens.Smooth, { Scale = 1 })
    end)
    footer.MouseButton1Click:Connect(function()
        local ok = CopyText(Config.Telegram)
        Toast(ok and "Telegram link copied" or "Clipboard is not supported by your executor", not ok)
    end)
    local dialogOpen = false
    local pendingDelete
    local dialogOverlay = Create("Frame", {
        Name = "DialogOverlay",
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        Active = true,
        Visible = false,
        ZIndex = 100,
        Parent = window,
    })
    local dialog = Create("CanvasGroup", {
        Name = "Dialog",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(340, 160),
        BackgroundColor3 = Theme.Surface,
        GroupTransparency = 1,
        Parent = dialogOverlay,
    })
    local dialogScale = Create("UIScale", { Scale = 0.9, Parent = dialog })
    Corner(dialog, UDim.new(0, 12))
    local dialogRim = Create("Frame", {
        Name = "Rim",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = dialog,
    })
    Corner(dialogRim, UDim.new(0, 12))
    Stroke(dialogRim, Theme.Accent, 1, 0.55)
    Create("TextLabel", {
        Name = "Message",
        Position = UDim2.fromOffset(20, 22),
        Size = UDim2.new(1, -40, 0, 40),
        BackgroundTransparency = 1,
        Text = "Are you sure you want to delete this config?",
        Font = Config.Fonts.Medium,
        TextSize = 15,
        TextColor3 = Theme.Frost,
        TextWrapped = true,
        Parent = dialog,
    })
    local dialogName = Create("TextLabel", {
        Name = "ConfigName",
        Position = UDim2.fromOffset(20, 68),
        Size = UDim2.new(1, -40, 0, 18),
        BackgroundTransparency = 1,
        Text = "",
        Font = Config.Fonts.Body,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = dialog,
    })
    local function CloseDialog()
        dialogOpen = false
        pendingDelete = nil
        Tween(dialogOverlay, Tweens.Fast, { BackgroundTransparency = 1 })
        Tween(dialog, Tweens.Fast, { GroupTransparency = 1 })
        Tween(dialogScale, Tweens.Fast, { Scale = 0.92 })
        task.delay(0.2, function()
            if not dialogOpen then
                dialogOverlay.Visible = false
            end
        end)
    end
    local function ConfirmedDelete(name)
        if not ConfigStore.Delete(name) then
            Toast("Could not delete the config", true)
            return
        end
        if activeConfig == name then
            activeConfig = nil
        end
        RenderConfigList()
        Toast("Config deleted: " .. name)
    end
    ActionButton(dialog, {
        Name = "Yes",
        Text = "YES",
        Style = "Danger",
        Width = 132,
        Height = 34,
        Position = UDim2.fromOffset(34, 108),
        Callback = function()
            local name = pendingDelete
            CloseDialog()
            if name then
                ConfirmedDelete(name)
            end
        end,
    })
    ActionButton(dialog, {
        Name = "No",
        Text = "NO",
        Width = 132,
        Height = 34,
        Position = UDim2.fromOffset(174, 108),
        Callback = CloseDialog,
    })
    local function AskDelete(name)
        pendingDelete = name
        dialogName.Text = name
        dialogOpen = true
        dialogOverlay.Visible = true
        dialogScale.Scale = 0.9
        Tween(dialogOverlay, Tweens.Fast, { BackgroundTransparency = 0.4 })
        Tween(dialog, Tweens.Smooth, { GroupTransparency = 0 })
        Tween(dialogScale, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 })
    end
    local function CollectFlags()
        local flags = {}
        for flag, control in pairs(Winter.Flags) do
            local ok, value = pcall(control.Get)
            if ok and value ~= nil then
                flags[flag] = value
            end
        end
        return { Version = 1, Flags = flags }
    end
    local function ApplyFlags(data)
        local flags = type(data) == "table" and data.Flags
        if type(flags) ~= "table" then
            return false
        end
        for flag, value in pairs(flags) do
            local control = Winter.Flags[flag]
            if control and typeof(value) == control.Type then
                pcall(control.Apply, value)
            end
        end
        return true
    end
    local function SaveConfig(rawName)
        local name = CleanConfigName(rawName)
        if name == "" then
            Toast("Enter a name: letters, numbers, - or _", true)
            return false
        end
        local existed = false
        for _, saved in ipairs(ConfigStore.List()) do
            if saved:lower() == name:lower() then
                existed, name = true, saved
                break
            end
        end
        if not ConfigStore.Save(name, CollectFlags()) then
            Toast("Could not save the config", true)
            return false
        end
        activeConfig = name
        RenderConfigList()
        Toast((existed and "Config updated: " or "Config saved: ") .. name)
        return true
    end
    local function UseConfig(name)
        local data = ConfigStore.Load(name)
        if not data or not ApplyFlags(data) then
            Toast("Could not load the config", true)
            return
        end
        activeConfig = name
        RenderConfigList()
        Toast("Config loaded: " .. name)
    end
    RenderConfigList = function()
        if not configCard then
            return
        end
        for _, child in ipairs(configCard:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end
        configCard:SetAttribute("WinterOrder", 0)
        local names = ConfigStore.List()
        if #names == 0 then
            local empty = Row(configCard)
            Create("TextLabel", {
                Name = "Empty",
                Size = UDim2.fromScale(1, 1),
                BackgroundTransparency = 1,
                Text = "No saved configs yet",
                Font = Config.Fonts.Body,
                TextSize = 12,
                TextColor3 = Theme.TextDim,
                Parent = empty,
            })
            return
        end
        for _, name in ipairs(names) do
            local row = Row(configCard)
            local label = RowLabel(row, name, 160)
            if name == activeConfig then
                label.TextColor3 = Theme.Accent
            end
            ActionButton(row, {
                Name = "Use",
                Text = "Use",
                Width = 54,
                Height = 26,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -86, 0.5, 0),
                Callback = function()
                    UseConfig(name)
                end,
            })
            ActionButton(row, {
                Name = "Delete",
                Text = "Delete",
                Style = "Delete",
                Width = 64,
                Height = 26,
                AnchorPoint = Vector2.new(1, 0.5),
                Position = UDim2.new(1, -14, 0.5, 0),
                Callback = function()
                    AskDelete(name)
                end,
            })
        end
    end
    local function FillSettings(scroller)
        Components.Heading(scroller, "Settings", "Saved configs and menu options.")
        Components.Section(scroller, "Config manager")
        local createCard = Components.Card(scroller)
        Components.TextAction(createCard, {
            Placeholder = "Config name (A-Z, 0-9, - _)",
            ButtonText = "Create / Save",
            ButtonWidth = 104,
            Filter = FilterConfigName,
            Callback = function(text, box)
                if SaveConfig(text) then
                    box.Text = ""
                end
            end,
        })
        Components.Section(scroller, "Saved configs")
        configCard = Components.Card(scroller)
        RenderConfigList()
        Components.Note(scroller, ConfigStore.UsesFiles
            and ("Configs are saved in the " .. ConfigStore.Folder .. " folder of your executor.")
            or "Your executor has no file access, so configs are kept only until Roblox is closed.")
        Components.Section(scroller, "Window")
        local windowCard = Components.Card(scroller)
        Components.Slider(windowCard, {
            Name = "Menu scale", Min = 60, Max = 120, Default = 100, Step = 5, Suffix = "%",
            Flag = "Menu.Scale",
            Callback = function(percent)
                userScale = percent / 100
                ApplyScale(Tweens.Fast)
            end,
        })
        Components.Slider(windowCard, {
            Name = "Window opacity", Min = 40, Max = 100, Default = 100, Step = 5, Suffix = "%",
            Flag = "Menu.Opacity",
            Callback = function(percent)
                windowTransparency = 1 - percent / 100
                if isOpen and not busy then
                    Tween(window, Tweens.Fast, { GroupTransparency = windowTransparency })
                end
            end,
        })
        Components.Toggle(windowCard, {
            Name = "Snow effect", Default = snow.Visible, Flag = "Menu.Snow",
            Callback = function(enabled)
                snow.Visible = enabled
            end,
        })
        if not Config.IsMobile then
            local keyControl
            local listening = false
            keyControl = Components.Button(windowCard, {
                Name = "Menu key",
                Text = Config.ToggleKey.Name,
                Callback = function()
                    if listening then
                        return
                    end
                    listening, capturingKey = true, true
                    keyControl.Button.Text = "Press a key"
                    local connection
                    connection = UserInputService.InputBegan:Connect(function(input)
                        if input.UserInputType ~= Enum.UserInputType.Keyboard then
                            return
                        end
                        connection:Disconnect()
                        if input.KeyCode ~= Enum.KeyCode.Escape and input.KeyCode ~= Enum.KeyCode.Unknown then
                            Config.ToggleKey = input.KeyCode
                        end
                        keyControl.Button.Text = Config.ToggleKey.Name
                        if toggleKeyLabel then
                            toggleKeyLabel.Text = Config.ToggleKey.Name
                        end
                        listening = false
                        task.delay(0.15, function()
                            capturingKey = false
                        end)
                    end)
                    Winter:Track(connection)
                end,
            })
            keyControl.Button.Size = UDim2.fromOffset(104, 28)
        end
        Components.Section(scroller, "Actions")
        local actionCard = Components.Card(scroller)
        Components.Button(actionCard, {
            Name = "Reset window position", Text = "Reset",
            Callback = ResetPosition,
        })
        Components.Button(actionCard, {
            Name = "Reset all settings", Text = "Reset",
            Callback = function()
                for _, control in pairs(Winter.Flags) do
                    pcall(control.Apply, control.Default)
                end
                Toast("Settings reset to default")
            end,
        })
        Components.Button(actionCard, {
            Name = "Close menu", Text = "Close",
            Callback = function()
                Winter:Destroy()
            end,
        })
    end
    local function FillVisuals(scroller)
        Components.Heading(scroller, "Visuals", "Lighting and screen options. They only change your own view.")
        Components.Section(scroller, "Lighting")
        local lightingCard = Components.Card(scroller)
        Components.Toggle(lightingCard, {
            Name = "Fullbright", Flag = "Visuals.Fullbright",
            Callback = SetFullbright,
        })
        Components.Slider(lightingCard, {
            Name = "Fullbright level", Min = 1, Max = 5, Default = 3, Step = 1,
            Flag = "Visuals.FullbrightLevel",
            Callback = SetFullbrightLevel,
        })
        Components.Section(scroller, "Screen")
        local screenCard = Components.Card(scroller)
        Components.Toggle(screenCard, {
            Name = "Stretched screen", Flag = "Visuals.Stretch",
            Callback = SetStretch,
        })
        Components.Slider(screenCard, {
            Name = "Stretch amount", Min = 0, Max = 60, Default = 30, Step = 5, Suffix = "%",
            Flag = "Visuals.StretchAmount",
            Callback = SetStretchAmount,
        })
        Components.Note(scroller, "Stretched screen widens the picture by squeezing it vertically. 0% keeps the normal view.")
    end
    local function FillInfo(scroller)
        Components.Heading(scroller, "Info", "About " .. Config.Name .. " and its author.")
        Components.Banner(scroller, "You are using the latest version", "v" .. Config.Version)
        Components.Section(scroller, "About")
        local about = Components.Card(scroller)
        Components.Info(about, "Name", Config.Name)
        Components.Info(about, "Author", Config.Author)
        Components.Info(about, "Version", Config.Version)
        Components.Section(scroller, "Community")
        local community = Components.Card(scroller)
        Components.LinkRow(community, {
            Title = "Telegram",
            Text = Config.Telegram,
            ButtonText = "Copy",
            DoneText = "Copied",
            Icon = BuildTelegramLogo,
            OnActivate = function()
                local ok = CopyText(Config.Telegram)
                Toast(ok and "Telegram link copied" or "Clipboard is not supported by your executor", not ok)
                return ok
            end,
        })
        Components.Note(scroller, "Tap or hold the link to copy it, then open it in Telegram to be the first to know about new updates.")
        Components.Section(scroller, "Controls")
        local controls = Components.Card(scroller)
        Components.Info(controls, "Minimize", "Hyphen button")
        toggleKeyLabel = Components.Info(controls, "Hide or show", Config.ToggleKey.Name):FindFirstChild("Value")
        Components.Info(controls, "Move", "Drag the header")
    end
    local function FillPage(name, scroller)
        if name == "Settings" then
            FillSettings(scroller)
        elseif name == "Info" then
            FillInfo(scroller)
        elseif name == "Visuals" then
            FillVisuals(scroller)
        else
            FillExample(scroller, name)
        end
    end
    local tabs = {}
    local current = 0
    local function SelectTab(index, instant)
        if index == current then
            return
        end
        local previous = tabs[current]
        current = index
        local slow = (not instant) and Tweens.Smooth or nil
        local quick = (not instant) and Tweens.Fast or nil
        Set(indicator, slow, { Position = UDim2.fromOffset(10, TAB_TOP + (index - 1) * (TAB_HEIGHT + TAB_GAP)) })
        for position, tab in ipairs(tabs) do
            local active = position == index
            Set(tab.Label, quick, { TextColor3 = active and Theme.Frost or Theme.TextMuted })
            Set(tab.Button, quick, { BackgroundTransparency = 1 })
            tab.Icon:SetColor(active and Theme.Accent or Theme.TextMuted, quick)
        end
        if previous then
            local old = previous.Group
            Tween(old, Tweens.Fast, { GroupTransparency = 1 }).Completed:Connect(function()
                if tabs[current].Group ~= old then
                    old.Visible = false
                end
            end)
        end
        local group = tabs[index].Group
        group.Visible = true
        if instant then
            group.Position = UDim2.fromOffset(0, 0)
            group.GroupTransparency = 0
        else
            group.Position = UDim2.fromOffset(16, 0)
            Tween(group, Tweens.Smooth, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 })
        end
    end
    for index, name in ipairs(Config.Tabs) do
        local button = Create("TextButton", {
            Name = name .. "Tab",
            Size = UDim2.new(1, 0, 0, TAB_HEIGHT),
            BackgroundColor3 = Theme.SurfaceHigh,
            BackgroundTransparency = 1,
            Text = "",
            LayoutOrder = index,
            Parent = tabList,
        })
        Corner(button, UDim.new(0, 9))
        local press = Create("UIScale", { Parent = button })
        local icon = BuildIcon(button, name, 18, Theme.TextMuted)
        icon.Holder.AnchorPoint = Vector2.new(0, 0.5)
        icon.Holder.Position = UDim2.new(0, 14, 0.5, 0)
        local label = Create("TextLabel", {
            Name = "Label",
            Position = UDim2.fromOffset(44, 0),
            Size = UDim2.new(1, -50, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Config.Fonts.Medium,
            TextSize = 13,
            TextColor3 = Theme.TextMuted,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = button,
        })
        local group, scroller = BuildPage(name)
        FillPage(name, scroller)
        tabs[index] = { Name = name, Button = button, Label = label, Icon = icon, Group = group }
        button.MouseEnter:Connect(function()
            if current ~= index then
                Tween(button, Tweens.Fast, { BackgroundTransparency = 0.7 })
            end
        end)
        button.MouseLeave:Connect(function()
            Tween(button, Tweens.Fast, { BackgroundTransparency = 1 })
            Tween(press, Tweens.Fast, { Scale = 1 })
        end)
        button.MouseButton1Down:Connect(function()
            Tween(press, Tweens.Fast, { Scale = 0.96 })
        end)
        button.MouseButton1Up:Connect(function()
            Tween(press, Tweens.Smooth, { Scale = 1 })
        end)
        button.MouseButton1Click:Connect(function()
            SelectTab(index)
        end)
    end
    minimize.MouseEnter:Connect(function()
        Tween(minimize, Tweens.Fast, { BackgroundTransparency = 0.35, TextColor3 = Theme.Frost })
    end)
    minimize.MouseLeave:Connect(function()
        Tween(minimize, Tweens.Fast, { BackgroundTransparency = 1, TextColor3 = Theme.TextMuted })
        Tween(minimizeScale, Tweens.Fast, { Scale = 1 })
    end)
    minimize.MouseButton1Down:Connect(function()
        Tween(minimizeScale, Tweens.Fast, { Scale = 0.88 })
    end)
    minimize.MouseButton1Up:Connect(function()
        Tween(minimizeScale, Tweens.Smooth, { Scale = 1 })
    end)
    minimize.MouseButton1Click:Connect(Minimize)
    Winter:Track(UserInputService.InputBegan:Connect(function(input, processed)
        if processed or capturingKey or input.KeyCode ~= Config.ToggleKey then
            return
        end
        if isOpen then
            Minimize()
        else
            Restore()
        end
    end))
    MakeDraggable(dragArea, root)
    MakeDraggable(orb, orb, Restore)
    SelectTab(1, true)
    Tween(window, Tweens.Smooth, { GroupTransparency = windowTransparency })
    Tween(windowScale, Tweens.Smooth, { Scale = CurrentScale() })
    FadeShadow(0.93, Tweens.Smooth)
end
function Winter.BuildMainWindow()
    local ok, err = xpcall(BuildWindow, debug.traceback)
    if not ok then
        warn("[Winter] could not build the window:\n" .. tostring(err))
    end
end
RunBootScreen(function()
    if Winter.BuildMainWindow then
        Winter.BuildMainWindow()
    else
        print("[Winter] boot finished - main window is not added yet (Part 2)")
    end
end)
