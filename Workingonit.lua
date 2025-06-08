--// Modern UI Library with WindUI-style syntax
getgenv().namehub = "Private"
local UserInputService = game:GetService('UserInputService')
local LocalPlayer = game:GetService('Players').LocalPlayer
local TweenService = game:GetService('TweenService')
local HttpService = game:GetService('HttpService')
local CoreGui = game:GetService('CoreGui')

local Mouse = LocalPlayer:GetMouse()

local Library = {
    connections = {},
    Flags = {},
    Enabled = true,
    slider_drag = false,
    core = nil,
    dragging = false,
    drag_position = nil,
    start_position = nil,
    windows = {}
}

if not isfolder("cac hub") then
    makefolder("cac hub")
end

function Library:disconnect()
    for _, value in Library.connections do
        if not Library.connections[value] then
            continue
        end
        Library.connections[value]:Disconnect()
        Library.connections[value] = nil
    end
end

function Library:clear()
    for _, object in CoreGui:GetChildren() do
        if object.Name ~= "cac" then
            continue
        end
        object:Destroy()
    end
end

function Library:exist()
    if not Library.core then return end
    if not Library.core.Parent then return end
    return true
end

function Library:save_flags()
    if not Library.exist() then return end
    local flags = HttpService:JSONEncode(Library.Flags)
    writefile(`cac hub/{game.GameId}.lua`, flags)
end

function Library:load_flags()
    if not isfile(`cac hub/{game.GameId}.lua`) then 
        Library.save_flags() 
        return 
    end
    local flags = readfile(`cac hub/{game.GameId}.lua`)
    if not flags then 
        Library.save_flags() 
        return 
    end
    Library.Flags = HttpService:JSONDecode(flags)
end

Library.load_flags()
Library.clear()

-- Notification System
function Library:Notification(options)
    local notification_data = {
        Title = options.Title or "Notification",
        Text = options.Text or "This is a notification",
        Duration = options.Duration or 5,
        Type = options.Type or "info" -- info, success, warning, error
    }

    -- Create notification container
    local notification = Instance.new("Frame")
    notification.Name = "Notification"
    notification.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
    notification.BorderColor3 = Color3.fromRGB(0, 0, 0)
    notification.BorderSizePixel = 0
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.Size = UDim2.new(0, 300, 0, 80)
    notification.ZIndex = 1000
    notification.Parent = Library.core or CoreGui

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notification

    -- Color coding by type
    local typeColors = {
        info = Color3.fromRGB(66, 89, 182),
        success = Color3.fromRGB(34, 197, 94),
        warning = Color3.fromRGB(251, 191, 36),
        error = Color3.fromRGB(239, 68, 68)
    }

    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = typeColors[notification_data.Type] or typeColors.info
    accent.BorderSizePixel = 0
    accent.Position = UDim2.new(0, 0, 0, 0)
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.Parent = notification

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 10)
    accentCorner.Parent = accent

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 15, 0, 8)
    titleLabel.Size = UDim2.new(1, -30, 0, 20)
    titleLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    titleLabel.Text = notification_data.Title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = notification

    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Text"
    textLabel.BackgroundTransparency = 1
    textLabel.Position = UDim2.new(0, 15, 0, 30)
    textLabel.Size = UDim2.new(1, -30, 0, 40)
    textLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular)
    textLabel.Text = notification_data.Text
    textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    textLabel.TextSize = 12
    textLabel.TextWrapped = true
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextYAlignment = Enum.TextYAlignment.Top
    textLabel.Parent = notification

    -- Slide in animation
    TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -320, 0, 20)
    }):Play()

    -- Auto dismiss
    if notification_data.Duration > 0 then
        task.wait(notification_data.Duration)
        local slideOut = TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 20)
        })
        slideOut:Play()
        slideOut.Completed:Once(function()
            notification:Destroy()
        end)
    end
end

function Library:CreateWindow(options)
    local window_data = {
        Title = options.Title or "Window",
        Size = options.Size or UDim2.new(0, 699, 0, 426),
        Theme = options.Theme or "Dark",
        tabs = {},
        current_tab = nil,
        container = nil
    }

    -- Create GUI structure
    local container = Instance.new("ScreenGui")
    container.Name = "cac"
    container.Parent = CoreGui
    Library.core = container

    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Parent = container
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Shadow.BackgroundTransparency = 1.000
    Shadow.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.BorderSizePixel = 0
    Shadow.Position = UDim2.new(0.508668244, 0, 0.5, 0)
    -- Support any percentage-based sizing
    if window_data.Size.X.Scale > 0 or window_data.Size.Y.Scale > 0 then
        -- For scale-based sizing, add relative padding for shadow effect
        Shadow.Size = UDim2.new(
            window_data.Size.X.Scale, window_data.Size.X.Offset + 77,
            window_data.Size.Y.Scale, window_data.Size.Y.Offset + 83
        )
    else
        -- For offset-based sizing, use original calculation
        Shadow.Size = UDim2.new(0, 776, 0, 509)
    end
    Shadow.ZIndex = 0
    Shadow.Image = "rbxassetid://17290899982"

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = container
    Container.AnchorPoint = Vector2.new(0.5, 0.5)
    Container.BackgroundColor3 = Color3.fromRGB(19, 20, 24)
    Container.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Position = UDim2.new(0.5, 0, 0.5, 0)
    Container.Size = window_data.Size

    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 20)
    ContainerCorner.Parent = Container

    local Top = Instance.new("ImageLabel")
    Top.Name = "Top"
    Top.Parent = Container
    Top.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Top.BackgroundTransparency = 1.000
    Top.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Top.BorderSizePixel = 0
    Top.Size = UDim2.new(0, 699, 0, 39)
    Top.Image = ""

    local Logo = Instance.new("ImageLabel")
    Logo.Name = "Logo"
    Logo.Parent = Top
    Logo.AnchorPoint = Vector2.new(0.5, 0.5)
    Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Logo.BackgroundTransparency = 1.000
    Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Logo.BorderSizePixel = 0
    Logo.Position = UDim2.new(0.0387367606, 0, 0.5, 0)
    Logo.Size = UDim2.new(0, 30, 0, 25)
    Logo.Image = ""

    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Top
    TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.BackgroundTransparency = 1.000
    TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
    TextLabel.BorderSizePixel = 0
    TextLabel.Position = UDim2.new(0.0938254446, 0, 0.496794879, 0)
    TextLabel.Size = UDim2.new(0, 75, 0, 16)
    TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    TextLabel.Text = window_data.Title
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.TextScaled = true
    TextLabel.TextSize = 14.000
    TextLabel.TextWrapped = true
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left

    local Line = Instance.new("Frame")
    Line.Name = "Line"
    Line.Parent = Container
    Line.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
    Line.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Line.BorderSizePixel = 0
    Line.Position = UDim2.new(0.296137333, 0, 0.0915492922, 0)
    Line.Size = UDim2.new(0, 2, 0, 387)

    local tabs = Instance.new("ScrollingFrame")
    tabs.Name = "Tabs"
    tabs.Active = true
    tabs.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    tabs.BackgroundTransparency = 1.000
    tabs.BorderColor3 = Color3.fromRGB(0, 0, 0)
    tabs.BorderSizePixel = 0
    tabs.Position = UDim2.new(0, 0, 0.0915492922, 0)
    tabs.Size = UDim2.new(0, 209, 0, 386)
    tabs.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
    tabs.ScrollBarThickness = 0
    tabs.Parent = Container

    local tabslist = Instance.new("UIListLayout")
    tabslist.Parent = tabs
    tabslist.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabslist.SortOrder = Enum.SortOrder.LayoutOrder
    tabslist.Padding = UDim.new(0, 9)

    local UIPadding = Instance.new("UIPadding")
    UIPadding.Parent = tabs
    UIPadding.PaddingTop = UDim.new(0, 15)

    local tabsCorner = Instance.new("UICorner")
    tabsCorner.Parent = tabs

    -- Mobile button
    local mobile_button = Instance.new("TextButton")
    mobile_button.Name = "Mobile"
    mobile_button.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
    mobile_button.BorderColor3 = Color3.fromRGB(0, 0, 0)
    mobile_button.BorderSizePixel = 0
    mobile_button.Position = UDim2.new(0.0210955422, 0, 0.91790241, 0)
    mobile_button.Size = UDim2.new(0, 122, 0, 38)
    mobile_button.AutoButtonColor = false
    mobile_button.Modal = true
    mobile_button.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    mobile_button.Text = ""
    mobile_button.TextColor3 = Color3.fromRGB(0, 0, 0)
    mobile_button.TextSize = 14.000
    mobile_button.Parent = container

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 13)
    UICorner.Parent = mobile_button

    local shadowMobile = Instance.new("ImageLabel")
    shadowMobile.Name = "Shadow"
    shadowMobile.Parent = mobile_button
    shadowMobile.AnchorPoint = Vector2.new(0.5, 0.5)
    shadowMobile.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shadowMobile.BackgroundTransparency = 1.000
    shadowMobile.BorderColor3 = Color3.fromRGB(0, 0, 0)
    shadowMobile.BorderSizePixel = 0
    shadowMobile.Position = UDim2.new(0.5, 0, 0.5, 0)
    shadowMobile.Size = UDim2.new(0, 144, 0, 58)
    shadowMobile.ZIndex = 0
    shadowMobile.Image = "rbxassetid://17183270335"
    shadowMobile.ImageTransparency = 0.200

    local State = Instance.new("TextLabel")
    State.Name = "State"
    State.Parent = mobile_button
    State.AnchorPoint = Vector2.new(0.5, 0.5)
    State.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    State.BackgroundTransparency = 1.000
    State.BorderColor3 = Color3.fromRGB(0, 0, 0)
    State.BorderSizePixel = 0
    State.Position = UDim2.new(0.646000028, 0, 0.5, 0)
    State.Size = UDim2.new(0, 64, 0, 15)
    State.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
    State.Text = "Open"
    State.TextColor3 = Color3.fromRGB(255, 255, 255)
    State.TextScaled = true
    State.TextSize = 14.000
    State.TextWrapped = true
    State.TextXAlignment = Enum.TextXAlignment.Left

    local Icon = Instance.new("ImageLabel")
    Icon.Name = "Icon"
    Icon.Parent = mobile_button
    Icon.AnchorPoint = Vector2.new(0.5, 0.5)
    Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Icon.BackgroundTransparency = 1.000
    Icon.BorderColor3 = Color3.fromRGB(0, 0, 0)
    Icon.BorderSizePixel = 0
    Icon.Position = UDim2.new(0.268000007, 0, 0.5, 0)
    Icon.Size = UDim2.new(0, 15, 0, 15)
    Icon.Image = "rbxassetid://17183279677"

    window_data.container = container
    window_data.tabs_frame = tabs
    window_data.Container = Container
    window_data.Shadow = Shadow

    -- Window methods
    local Window = {}

    function Window:open()
        Container.Visible = true
        Shadow.Visible = true
        mobile_button.Modal = true

        TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
            Size = window_data.Size
        }):Play()

        -- Calculate target shadow size for animation based on window size
        local targetShadowSize
        if window_data.Size.X.Scale > 0 or window_data.Size.Y.Scale > 0 then
            targetShadowSize = UDim2.new(
                window_data.Size.X.Scale, window_data.Size.X.Offset + 77,
                window_data.Size.Y.Scale, window_data.Size.Y.Offset + 83
            )
        else
            targetShadowSize = UDim2.new(0, 776, 0, 509)
        end

        TweenService:Create(Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
            Size = targetShadowSize
        }):Play()
    end

    function Window:close()
        TweenService:Create(Shadow, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()

        local main_tween = TweenService:Create(Container, TweenInfo.new(0.6, Enum.EasingStyle.Circular, Enum.EasingDirection.InOut), {
            Size = UDim2.new(0, 0, 0, 0)
        })

        main_tween:Play()
        main_tween.Completed:Once(function()
            if Library.Enabled then
                return
            end
            Container.Visible = false
            Shadow.Visible = false
            mobile_button.Modal = false
        end)
    end

    function Window:visible()
        Library.Enabled = not Library.Enabled
        if Library.Enabled then
            Window:open()
        else
            Window:close()
        end
    end

    function Window:Tab(options)
        local tab_data = {
            Title = options.Title or "Tab",
            Icon = options.Icon or "rbxassetid://17290697757",
            tab_button = nil,
            left_section = nil,
            right_section = nil
        }

        -- Create tab button
        local tab = Instance.new("TextButton")
        tab.Name = "Tab"
        tab.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
        tab.BorderColor3 = Color3.fromRGB(0, 0, 0)
        tab.BorderSizePixel = 0
        tab.Size = UDim2.new(0, 174, 0, 40)
        tab.ZIndex = 2
        tab.AutoButtonColor = false
        tab.Font = Enum.Font.SourceSans
        tab.Text = ""
        tab.TextColor3 = Color3.fromRGB(0, 0, 0)
        tab.TextSize = 14.000
        tab.Parent = tabs

        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 5)
        tabCorner.Parent = tab

        local TextLabel = Instance.new("TextLabel")
        TextLabel.Parent = tab
        TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.BackgroundTransparency = 1.000
        TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.BorderSizePixel = 0
        TextLabel.Position = UDim2.new(0.58965224, 0, 0.5, 0)
        TextLabel.Size = UDim2.new(0, 124, 0, 15)
        TextLabel.ZIndex = 3
        TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
        TextLabel.Text = tab_data.Title
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextScaled = true
        TextLabel.TextSize = 14.000
        TextLabel.TextTransparency = 0.300
        TextLabel.TextWrapped = true
        TextLabel.TextXAlignment = Enum.TextXAlignment.Left

        local Logo = Instance.new("ImageLabel")
        Logo.Name = "Logo"
        Logo.Parent = tab
        Logo.AnchorPoint = Vector2.new(0.5, 0.5)
        Logo.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Logo.BackgroundTransparency = 1.000
        Logo.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Logo.BorderSizePixel = 0
        Logo.Position = UDim2.new(0.130999997, 0, 0.5, 0)
        Logo.Size = UDim2.new(0, 17, 0, 17)
        Logo.ZIndex = 3
        Logo.Image = tab_data.Icon
        Logo.ImageTransparency = 0.3001

        local Glow = Instance.new("ImageLabel")
        Glow.Name = "Glow"
        Glow.Parent = tab
        Glow.AnchorPoint = Vector2.new(0.5, 0.5)
        Glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Glow.BackgroundTransparency = 1.000
        Glow.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Glow.BorderSizePixel = 0
        Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
        Glow.Size = UDim2.new(0, 190, 0, 53)
        Glow.Image = "rbxassetid://17290723539"
        Glow.ImageTransparency = 1.000

        local Fill = Instance.new("Frame")
        Fill.Name = "Fill"
        Fill.Parent = tab
        Fill.AnchorPoint = Vector2.new(0.5, 0.5)
        Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Fill.BackgroundTransparency = 1.000
        Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
        Fill.BorderSizePixel = 0
        Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
        Fill.Size = UDim2.new(0, 174, 0, 40)
        Fill.ZIndex = 2

        local UICorner_2 = Instance.new("UICorner")
        UICorner_2.CornerRadius = UDim.new(0, 10)
        UICorner_2.Parent = Fill

        local UIGradient = Instance.new("UIGradient")
        UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(66, 89, 182)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(37, 57, 137))}
        UIGradient.Rotation = 20
        UIGradient.Parent = Fill

        -- Create sections
        local left_section = Instance.new("ScrollingFrame")
        left_section.Name = "LeftSection"
        left_section.Active = true
        left_section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        left_section.BackgroundTransparency = 1.000
        left_section.BorderColor3 = Color3.fromRGB(0, 0, 0)
        left_section.BorderSizePixel = 0
        left_section.Position = UDim2.new(0.326180249, 0, 0.126760557, 0)
        left_section.Size = UDim2.new(0, 215, 0, 372)
        left_section.AutomaticCanvasSize = Enum.AutomaticSize.XY
        left_section.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        left_section.ScrollBarThickness = 0
        left_section.Parent = Container

        local leftsectionlist = Instance.new("UIListLayout")
        leftsectionlist.Parent = left_section
        leftsectionlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        leftsectionlist.SortOrder = Enum.SortOrder.LayoutOrder
        leftsectionlist.Padding = UDim.new(0, 7)

        local right_section = Instance.new("ScrollingFrame")
        right_section.Name = "RightSection"
        right_section.Active = true
        right_section.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        right_section.BackgroundTransparency = 1.000
        right_section.BorderColor3 = Color3.fromRGB(0, 0, 0)
        right_section.BorderSizePixel = 0
        right_section.Position = UDim2.new(0.662374794, 0, 0.126760557, 0)
        right_section.Size = UDim2.new(0, 215, 0, 372)
        right_section.AutomaticCanvasSize = Enum.AutomaticSize.XY
        right_section.ScrollBarImageColor3 = Color3.fromRGB(0, 0, 0)
        right_section.ScrollBarThickness = 0
        right_section.Parent = Container

        local rightsectionlist = Instance.new("UIListLayout")
        rightsectionlist.Parent = right_section
        rightsectionlist.HorizontalAlignment = Enum.HorizontalAlignment.Center
        rightsectionlist.SortOrder = Enum.SortOrder.LayoutOrder
        rightsectionlist.Padding = UDim.new(0, 7)

        tab_data.tab_button = tab
        tab_data.left_section = left_section
        tab_data.right_section = right_section

        -- Hide sections initially
        if #window_data.tabs > 0 then
            left_section.Visible = false
            right_section.Visible = false
        else
            -- First tab is active by default
            window_data.current_tab = tab_data
        end

        table.insert(window_data.tabs, tab_data)

        local Tab = {}

        function Tab:open_tab()
            -- Hide all other sections
            for _, tab_info in ipairs(window_data.tabs) do
                tab_info.left_section.Visible = false
                tab_info.right_section.Visible = false

                -- Reset tab appearance
                TweenService:Create(tab_info.tab_button.Fill, TweenInfo.new(0.4), {
                    BackgroundTransparency = 1
                }):Play()
                TweenService:Create(tab_info.tab_button.Glow, TweenInfo.new(0.4), {
                    ImageTransparency = 1
                }):Play()
                TweenService:Create(tab_info.tab_button.TextLabel, TweenInfo.new(0.4), {
                    TextTransparency = 0.5
                }):Play()
                TweenService:Create(tab_info.tab_button.Logo, TweenInfo.new(0.4), {
                    ImageTransparency = 0.5
                }):Play()
            end

            -- Show current tab sections
            left_section.Visible = true
            right_section.Visible = true
            window_data.current_tab = tab_data

            -- Activate tab appearance
            TweenService:Create(tab.Fill, TweenInfo.new(0.4), {
                BackgroundTransparency = 0
            }):Play()
            TweenService:Create(tab.Glow, TweenInfo.new(0.4), {
                ImageTransparency = 0
            }):Play()
            TweenService:Create(tab.TextLabel, TweenInfo.new(0.4), {
                TextTransparency = 0
            }):Play()
            TweenService:Create(tab.Logo, TweenInfo.new(0.4), {
                ImageTransparency = 0
            }):Play()
        end

        function Tab:Toggle(options)
            local section = (options.Section == 'right') and right_section or left_section
            local flag = options.Flag or options.Title:gsub("%s+", "_"):lower()

            local toggle = Instance.new("TextButton")
            toggle.Name = "Toggle"
            toggle.Parent = section
            toggle.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            toggle.BorderColor3 = Color3.fromRGB(0, 0, 0)
            toggle.BorderSizePixel = 0
            toggle.Size = UDim2.new(0, 215, 0, 37)
            toggle.AutoButtonColor = false
            toggle.Font = Enum.Font.SourceSans
            toggle.Text = ""
            toggle.TextColor3 = Color3.fromRGB(0, 0, 0)
            toggle.TextSize = 14.000

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = toggle

            local Checkbox = Instance.new("Frame")
            Checkbox.Name = "Checkbox"
            Checkbox.Parent = toggle
            Checkbox.AnchorPoint = Vector2.new(0.5, 0.5)
            Checkbox.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
            Checkbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Checkbox.BorderSizePixel = 0
            Checkbox.Position = UDim2.new(0.915000021, 0, 0.5, 0)
            Checkbox.Size = UDim2.new(0, 17, 0, 17)

            local UICorner_2 = Instance.new("UICorner")
            UICorner_2.CornerRadius = UDim.new(0, 4)
            UICorner_2.Parent = Checkbox

            local Glow = Instance.new("ImageLabel")
            Glow.Name = "Glow"
            Glow.Parent = Checkbox
            Glow.AnchorPoint = Vector2.new(0.5, 0.5)
            Glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Glow.BackgroundTransparency = 1.000
            Glow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Glow.BorderSizePixel = 0
            Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
            Glow.Size = UDim2.new(0, 27, 0, 27)
            Glow.Image = "rbxassetid://17290798394"
            Glow.ImageTransparency = 1.000

            local Fill = Instance.new("Frame")
            Fill.Name = "Fill"
            Fill.Parent = Checkbox
            Fill.AnchorPoint = Vector2.new(0.5, 0.5)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Fill.BackgroundTransparency = 1.000
            Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Fill.BorderSizePixel = 0
            Fill.Position = UDim2.new(0.5, 0, 0.5, 0)
            Fill.Size = UDim2.new(0, 17, 0, 17)

            local UICorner_3 = Instance.new("UICorner")
            UICorner_3.CornerRadius = UDim.new(0, 4)
            UICorner_3.Parent = Fill

            local UIGradient = Instance.new("UIGradient")
            UIGradient.Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(66, 89, 182)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(37, 57, 137))}
            UIGradient.Rotation = 20
            UIGradient.Parent = Fill

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = toggle
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 1.000
            TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.Position = UDim2.new(0.444953382, 0, 0.5, 0)
            TextLabel.Size = UDim2.new(0, 164, 0, 15)
            TextLabel.ZIndex = 2
            TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextScaled = true
            TextLabel.TextSize = 14.000
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Text = options.Title

            if not Library.Flags[flag] then
                Library.Flags[flag] = options.Default or false
            end

            local function update_toggle()
                if Library.Flags[flag] then
                    TweenService:Create(Checkbox.Fill, TweenInfo.new(0.4), {
                        BackgroundTransparency = 0
                    }):Play()
                    TweenService:Create(Checkbox.Glow, TweenInfo.new(0.4), {
                        ImageTransparency = 0
                    }):Play()
                else
                    TweenService:Create(Checkbox.Fill, TweenInfo.new(0.4), {
                        BackgroundTransparency = 1
                    }):Play()
                    TweenService:Create(Checkbox.Glow, TweenInfo.new(0.4), {
                        ImageTransparency = 1
                    }):Play()
                end
            end

            update_toggle()
            options.Callback(Library.Flags[flag])

            toggle.MouseButton1Click:Connect(function()
                Library.Flags[flag] = not Library.Flags[flag]
                Library.save_flags()
                update_toggle()
                options.Callback(Library.Flags[flag])
            end)
        end

        function Tab:Button(options)
            local section = (options.Section == 'right') and right_section or left_section

            local button = Instance.new("TextButton")
            button.Name = "Button"
            button.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            button.BorderColor3 = Color3.fromRGB(0, 0, 0)
            button.BorderSizePixel = 0
            button.Size = UDim2.new(0, 215, 0, 37)
            button.AutoButtonColor = false
            button.Font = Enum.Font.SourceSans
            button.Text = ""
            button.TextColor3 = Color3.fromRGB(0, 0, 0)
            button.TextSize = 14.000
            button.Parent = section

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = button

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = button
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 1.000
            TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
            TextLabel.Size = UDim2.new(0, 164, 0, 15)
            TextLabel.ZIndex = 2
            TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextScaled = true
            TextLabel.TextSize = 14.000
            TextLabel.TextWrapped = true
            TextLabel.Text = options.Title

            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 36, 41)
                }):Play()
            end)

            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(27, 28, 33)
                }):Play()
            end)

            button.MouseButton1Click:Connect(function()
                options.Callback()
            end)
        end

        function Tab:Paragraph(options)
            local section = (options.Section == 'right') and right_section or left_section
            local textHeight = options.Lines or 3 -- Number of text lines to display

            local paragraph = Instance.new("TextButton")
            paragraph.Name = "Paragraph"
            paragraph.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            paragraph.BorderColor3 = Color3.fromRGB(0, 0, 0)
            paragraph.BorderSizePixel = 0
            paragraph.Size = UDim2.new(0, 215, 0, 25 + (textHeight * 15))
            paragraph.AutoButtonColor = false
            paragraph.Font = Enum.Font.SourceSans
            paragraph.Text = ""
            paragraph.TextColor3 = Color3.fromRGB(0, 0, 0)
            paragraph.TextSize = 14.000
            paragraph.Parent = section

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = paragraph

            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "Title"
            TitleLabel.Parent = paragraph
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Position = UDim2.new(0, 15, 0, 8)
            TitleLabel.Size = UDim2.new(1, -30, 0, 15)
            TitleLabel.ZIndex = 2
            TitleLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TitleLabel.TextSize = 14
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Text = options.Title or "Paragraph"

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Name = "Content"
            TextLabel.Parent = paragraph
            TextLabel.BackgroundTransparency = 1
            TextLabel.Position = UDim2.new(0, 15, 0, 25)
            TextLabel.Size = UDim2.new(1, -30, 0, textHeight * 15)
            TextLabel.ZIndex = 2
            TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular)
            TextLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            TextLabel.TextSize = 12
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.TextYAlignment = Enum.TextYAlignment.Top
            TextLabel.Text = options.Text or "This is a paragraph button that can display multiple lines of text with proper wrapping."

            paragraph.MouseEnter:Connect(function()
                TweenService:Create(paragraph, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 36, 41)
                }):Play()
            end)

            paragraph.MouseLeave:Connect(function()
                TweenService:Create(paragraph, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(27, 28, 33)
                }):Play()
            end)

            if options.Callback then
                paragraph.MouseButton1Click:Connect(function()
                    options.Callback()
                end)
            end

            local Paragraph = {}
            function Paragraph:update(new_text)
                TextLabel.Text = new_text
            end
            return Paragraph
        end

        function Tab:Slider(options)
            local section = (options.Section == 'right') and right_section or left_section
            local flag = options.Flag or options.Title:gsub("%s+", "_"):lower()

            local slider = Instance.new("TextButton")
            slider.Name = "Slider"
            slider.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            slider.BorderColor3 = Color3.fromRGB(0, 0, 0)
            slider.BorderSizePixel = 0
            slider.Size = UDim2.new(0, 215, 0, 48)
            slider.AutoButtonColor = false
            slider.Font = Enum.Font.SourceSans
            slider.Text = ""
            slider.TextColor3 = Color3.fromRGB(0, 0, 0)
            slider.TextSize = 14.000
            slider.Parent = section

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = slider

            local Box = Instance.new("Frame")
            Box.Name = "Box"
            Box.Parent = slider
            Box.AnchorPoint = Vector2.new(0.5, 0.5)
            Box.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
            Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Box.BorderSizePixel = 0
            Box.Position = UDim2.new(0.508023143, 0, 0.708333313, 0)
            Box.Size = UDim2.new(0, 192, 0, 6)

            local UICorner_2 = Instance.new("UICorner")
            UICorner_2.CornerRadius = UDim.new(0, 15)
            UICorner_2.Parent = Box

            local Glow = Instance.new("ImageLabel")
            Glow.Name = "Glow"
            Glow.Parent = Box
            Glow.AnchorPoint = Vector2.new(0.5, 0.5)
            Glow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Glow.BackgroundTransparency = 1.000
            Glow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Glow.BorderSizePixel = 0
            Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
            Glow.Size = UDim2.new(0, 204, 0, 17)
            Glow.ZIndex = 2
            Glow.Image = "rbxassetid://17381990533"

            local UIGradient = Instance.new("UIGradient")
            UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.50, 0.00), NumberSequenceKeypoint.new(0.53, 1.00), NumberSequenceKeypoint.new(1.00, 1.00)}
            UIGradient.Parent = Glow

            local Fill = Instance.new("ImageLabel")
            Fill.Name = "Fill"
            Fill.Parent = Box
            Fill.AnchorPoint = Vector2.new(0, 0.5)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Fill.BackgroundTransparency = 1.000
            Fill.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Fill.BorderSizePixel = 0
            Fill.Position = UDim2.new(0, 0, 0.5, 0)
            Fill.Size = UDim2.new(0, 192, 0, 6)
            Fill.Image = "rbxassetid://17382033116"

            local UICorner_3 = Instance.new("UICorner")
            UICorner_3.CornerRadius = UDim.new(0, 4)
            UICorner_3.Parent = Fill

            local UIGradient_2 = Instance.new("UIGradient")
            UIGradient_2.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 0.00), NumberSequenceKeypoint.new(0.50, 0.00), NumberSequenceKeypoint.new(0.50, 1.00), NumberSequenceKeypoint.new(1.00, 1.00)}
            UIGradient_2.Parent = Fill

            local Hitbox = Instance.new("TextButton")
            Hitbox.Name = "Hitbox"
            Hitbox.Parent = Box
            Hitbox.AnchorPoint = Vector2.new(0.5, 0.5)
            Hitbox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Hitbox.BackgroundTransparency = 1.000
            Hitbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Hitbox.BorderSizePixel = 0
            Hitbox.Position = UDim2.new(0.5, 0, 0.5, 0)
            Hitbox.Size = UDim2.new(0, 200, 0, 13)
            Hitbox.ZIndex = 3
            Hitbox.AutoButtonColor = false
            Hitbox.Font = Enum.Font.SourceSans
            Hitbox.Text = ""
            Hitbox.TextColor3 = Color3.fromRGB(0, 0, 0)
            Hitbox.TextSize = 14.000

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = slider
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 1.000
            TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.Position = UDim2.new(0.414720833, 0, 0.375, 0)
            TextLabel.Size = UDim2.new(0, 151, 0, 15)
            TextLabel.ZIndex = 2
            TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextScaled = true
            TextLabel.TextSize = 14.000
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Text = options.Title

            local Number = Instance.new("TextLabel")
            Number.Name = "Number"
            Number.Parent = slider
            Number.AnchorPoint = Vector2.new(0.5, 0.5)
            Number.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Number.BackgroundTransparency = 1.000
            Number.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Number.BorderSizePixel = 0
            Number.Position = UDim2.new(0.854255736, 0, 0.375, 0)
            Number.Size = UDim2.new(0, 38, 0, 15)
            Number.ZIndex = 2
            Number.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            Number.TextColor3 = Color3.fromRGB(255, 255, 255)
            Number.TextScaled = true
            Number.TextSize = 14.000
            Number.TextWrapped = true
            Number.TextXAlignment = Enum.TextXAlignment.Right

            if not Library.Flags[flag] then
                Library.Flags[flag] = options.Default or options.Min or 0
            end

            local function update_slider()
                local result = math.clamp((Mouse.X - Box.AbsolutePosition.X) / Box.AbsoluteSize.X, 0, 1)
                if not result then return end

                local number = math.floor(((options.Max - options.Min) * result) + options.Min)
                local slider_size = math.clamp(result, 0.001, 0.999)

                Box.Fill.UIGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(slider_size, 0),
                    NumberSequenceKeypoint.new(math.min(slider_size + 0.001, 1), 1),
                    NumberSequenceKeypoint.new(1, 1)
                })

                Box.Glow.UIGradient.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(slider_size, 0),
                    NumberSequenceKeypoint.new(math.min(slider_size + 0.03, 1), 1),
                    NumberSequenceKeypoint.new(1, 1)
                })

                Library.Flags[flag] = number
                Number.Text = number
                options.Callback(number)
            end

            Number.Text = Library.Flags[flag]
            options.Callback(Library.Flags[flag])

            Box.Hitbox.MouseButton1Down:Connect(function()
                if Library.slider_drag then return end
                Library.slider_drag = true
                while Library.slider_drag do
                    update_slider()
                    task.wait()
                end
            end)

            UserInputService.InputEnded:Connect(function(input, process)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    Library.slider_drag = false
                    Library.save_flags()
                end
            end)
        end

        function Tab:Dropdown(options)
            local section = (options.Section == 'right') and right_section or left_section
            local flag = options.Flag or options.Title:gsub("%s+", "_"):lower()
            local list_size = 6
            local open = false

            local dropdown = Instance.new("TextButton")
            dropdown.Parent = section
            dropdown.Name = "Dropdown"
            dropdown.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            dropdown.BorderColor3 = Color3.fromRGB(0, 0, 0)
            dropdown.BorderSizePixel = 0
            dropdown.Size = UDim2.new(0, 215, 0, 36)
            dropdown.AutoButtonColor = false
            dropdown.Font = Enum.Font.SourceSans
            dropdown.Text = ""
            dropdown.TextColor3 = Color3.fromRGB(0, 0, 0)
            dropdown.TextSize = 14.000

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = dropdown

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.Parent = dropdown
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local UIPadding = Instance.new("UIPadding")
            UIPadding.Parent = dropdown
            UIPadding.PaddingTop = UDim.new(0, 6)

            local Box = Instance.new("Frame")
            Box.Name = "Box"
            Box.Parent = dropdown
            Box.AnchorPoint = Vector2.new(0.5, 0)
            Box.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
            Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Box.BorderSizePixel = 0
            Box.Position = UDim2.new(0.5, 0, 0.150000006, 0)
            Box.Size = UDim2.new(0, 202, 0, 25)
            Box.ZIndex = 2

            local UICorner_2 = Instance.new("UICorner")
            UICorner_2.CornerRadius = UDim.new(0, 6)
            UICorner_2.Parent = Box

            local Options = Instance.new("Frame")
            Options.Name = "Options"
            Options.Parent = Box
            Options.AnchorPoint = Vector2.new(0.5, 0)
            Options.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
            Options.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Options.BorderSizePixel = 0
            Options.ClipsDescendants = true
            Options.Position = UDim2.new(0.5, 0, 0.75999999, 0)
            Options.Size = UDim2.new(0, 202, 0, 0)

            local UICorner_3 = Instance.new("UICorner")
            UICorner_3.CornerRadius = UDim.new(0, 6)
            UICorner_3.Parent = Options

            local UIPadding_2 = Instance.new("UIPadding")
            UIPadding_2.Parent = Options
            UIPadding_2.PaddingLeft = UDim.new(0, 15)
            UIPadding_2.PaddingTop = UDim.new(0, 10)

            local UIListLayout_2 = Instance.new("UIListLayout")
            UIListLayout_2.Parent = Options
            UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
            UIListLayout_2.Padding = UDim.new(0, 10)

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = Box
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 1.000
            TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.Position = UDim2.new(0.430000007, 0, 0.5, 0)
            TextLabel.Size = UDim2.new(0, 151, 0, 13)
            TextLabel.ZIndex = 2
            TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextScaled = true
            TextLabel.TextSize = 14.000
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Text = options.Title

            local Arrow = Instance.new("ImageLabel")
            Arrow.Name = "Arrow"
            Arrow.Parent = Box
            Arrow.Active = true
            Arrow.AnchorPoint = Vector2.new(0.5, 0.5)
            Arrow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Arrow.BackgroundTransparency = 1.000
            Arrow.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Arrow.BorderSizePixel = 0
            Arrow.Position = UDim2.new(0.920000017, 0, 0.5, 0)
            Arrow.Size = UDim2.new(0, 12, 0, 12)
            Arrow.ZIndex = 2
            Arrow.Image = "rbxassetid://17400678941"

            if not Library.Flags[flag] then
                Library.Flags[flag] = options.Default or (options.Options and options.Options[1]) or ""
            end

            local function update_dropdown()
                for _, child in Options:GetChildren() do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                list_size = 6
                for _, value in ipairs(options.Options) do
                    list_size = list_size + 23

                    local option = Instance.new("TextButton")
                    option.Name = "Option"
                    option.Active = false
                    option.AnchorPoint = Vector2.new(0.5, 0.5)
                    option.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                    option.BackgroundTransparency = 1.000
                    option.BorderColor3 = Color3.fromRGB(0, 0, 0)
                    option.BorderSizePixel = 0
                    option.Position = UDim2.new(0.47283414, 0, 0.309523821, 0)
                    option.Selectable = false
                    option.Size = UDim2.new(0, 176, 0, 13)
                    option.ZIndex = 2
                    option.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
                    option.TextColor3 = Color3.fromRGB(255, 255, 255)
                    option.TextScaled = true
                    option.TextSize = 14.000
                    option.TextTransparency = value == Library.Flags[flag] and 0 or 0.5
                    option.TextWrapped = true
                    option.TextXAlignment = Enum.TextXAlignment.Left
                    option.Text = value
                    option.Parent = Options

                    option.MouseButton1Click:Connect(function()
                        Library.Flags[flag] = value
                        Library.save_flags()
                        options.Callback(value)

                        for _, child in Options:GetChildren() do
                            if child:IsA("TextButton") then
                                child.TextTransparency = child.Text == value and 0 or 0.5
                            end
                        end

                        if open then
                            TextLabel.Text = value
                        end
                    end)
                end
            end

            update_dropdown()
            options.Callback(Library.Flags[flag])

            dropdown.MouseButton1Click:Connect(function()
                open = not open
                if open then
                    TextLabel.Text = Library.Flags[flag]
                    TweenService:Create(Options, TweenInfo.new(0.4), {
                        Size = UDim2.new(0, 202, 0, list_size)
                    }):Play()
                    TweenService:Create(dropdown, TweenInfo.new(0.4), {
                        Size = UDim2.new(0, 215, 0, 30 + list_size)
                    }):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.4), {
                        Rotation = 180
                    }):Play()
                else
                    TextLabel.Text = options.Title
                    TweenService:Create(Options, TweenInfo.new(0.4), {
                        Size = UDim2.new(0, 202, 0, 0)
                    }):Play()
                    TweenService:Create(dropdown, TweenInfo.new(0.4), {
                        Size = UDim2.new(0, 215, 0, 36)
                    }):Play()
                    TweenService:Create(Arrow, TweenInfo.new(0.4), {
                        Rotation = 0
                    }):Play()
                end
            end)
        end

        function Tab:Input(options)
            local section = (options.Section == 'right') and right_section or left_section
            local flag = options.Flag or options.Title:gsub("%s+", "_"):lower()

            local textbox = Instance.new("TextButton")
            textbox.Name = "TextBox"
            textbox.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            textbox.BorderColor3 = Color3.fromRGB(0, 0, 0)
            textbox.BorderSizePixel = 0
            textbox.Size = UDim2.new(0, 215, 0, 36)
            textbox.AutoButtonColor = false
            textbox.Font = Enum.Font.SourceSans
            textbox.Text = ""
            textbox.TextColor3 = Color3.fromRGB(0, 0, 0)
            textbox.TextSize = 14.000
            textbox.Parent = section

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = textbox

            local UIListLayout = Instance.new("UIListLayout")
            UIListLayout.Parent = textbox
            UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
            UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

            local UIPadding = Instance.new("UIPadding")
            UIPadding.Parent = textbox
            UIPadding.PaddingTop = UDim.new(0, 6)

            local Box = Instance.new("Frame")
            Box.Name = "Box"
            Box.Parent = textbox
            Box.AnchorPoint = Vector2.new(0.5, 0)
            Box.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
            Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Box.BorderSizePixel = 0
            Box.Position = UDim2.new(0.5, 0, 0.150000006, 0)
            Box.Size = UDim2.new(0, 202, 0, 25)
            Box.ZIndex = 2

            local UICorner_2 = Instance.new("UICorner")
            UICorner_2.CornerRadius = UDim.new(0, 6)
            UICorner_2.Parent = Box

            local TextHolder = Instance.new("TextBox")
            TextHolder.Name = "TextHolder"
            TextHolder.Parent = Box
            TextHolder.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
            TextHolder.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextHolder.BorderSizePixel = 0
            TextHolder.Position = UDim2.new(0.0445544571, 0, 0.239999995, 0)
            TextHolder.Size = UDim2.new(0, 182, 0, 13)
            TextHolder.ZIndex = 2
            TextHolder.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TextHolder.Text = ""
            TextHolder.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextHolder.TextSize = 14.000
            TextHolder.TextXAlignment = Enum.TextXAlignment.Left
            TextHolder.PlaceholderText = options.Placeholder or options.Title

            if not Library.Flags[flag] then
                Library.Flags[flag] = options.Default or ""
            else
                TextHolder.Text = Library.Flags[flag]
            end

            options.Callback(Library.Flags[flag])

            TextHolder.FocusLost:Connect(function()
                Library.Flags[flag] = TextHolder.Text
                Library.save_flags()
                options.Callback(TextHolder.Text)
            end)
        end

        function Tab:Colorpicker(options)
            local section = (options.Section == 'right') and right_section or left_section
            local flag = options.Flag or options.Title:gsub("%s+", "_"):lower()

            local colorpicker = Instance.new("TextButton")
            colorpicker.Name = "ColorPicker"
            colorpicker.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            colorpicker.BorderColor3 = Color3.fromRGB(0, 0, 0)
            colorpicker.BorderSizePixel = 0
            colorpicker.Size = UDim2.new(0, 215, 0, 37)
            colorpicker.AutoButtonColor = false
            colorpicker.Font = Enum.Font.SourceSans
            colorpicker.Text = ""
            colorpicker.TextColor3 = Color3.fromRGB(0, 0, 0)
            colorpicker.TextSize = 14.000
            colorpicker.Parent = section

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = colorpicker

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = colorpicker
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 1.000
            TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.Position = UDim2.new(0.424953382, 0, 0.5, 0)
            TextLabel.Size = UDim2.new(0, 140, 0, 15)
            TextLabel.ZIndex = 2
            TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextScaled = true
            TextLabel.TextSize = 14.000
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Text = options.Title

            local ColorDisplay = Instance.new("Frame")
            ColorDisplay.Name = "ColorDisplay"
            ColorDisplay.Parent = colorpicker
            ColorDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
            ColorDisplay.BackgroundColor3 = options.Default or Color3.fromRGB(255, 255, 255)
            ColorDisplay.BorderColor3 = Color3.fromRGB(0, 0, 0)
            ColorDisplay.BorderSizePixel = 0
            ColorDisplay.Position = UDim2.new(0.915000021, 0, 0.5, 0)
            ColorDisplay.Size = UDim2.new(0, 25, 0, 25)

            local ColorCorner = Instance.new("UICorner")
            ColorCorner.CornerRadius = UDim.new(0, 4)
            ColorCorner.Parent = ColorDisplay

            if not Library.Flags[flag] then
                Library.Flags[flag] = options.Default or Color3.fromRGB(255, 255, 255)
            end

            ColorDisplay.BackgroundColor3 = Library.Flags[flag]
            options.Callback(Library.Flags[flag])

            colorpicker.MouseButton1Click:Connect(function()
                local colors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(255, 255, 255)
                }

                local currentIndex = 1
                for i, color in ipairs(colors) do
                    if Library.Flags[flag] == color then
                        currentIndex = i
                        break
                    end
                end

                currentIndex = currentIndex % #colors + 1
                Library.Flags[flag] = colors[currentIndex]
                ColorDisplay.BackgroundColor3 = Library.Flags[flag]
                options.Callback(Library.Flags[flag])
                Library.save_flags()
            end)
        end

        function Tab:Keybind(options)
            local section = (options.Section == 'right') and right_section or left_section
            local flag = options.Flag or options.Title:gsub("%s+", "_"):lower()

            local keybind = Instance.new("TextButton")
            keybind.Name = "Keybind"
            keybind.BackgroundColor3 = Color3.fromRGB(27, 28, 33)
            keybind.BorderColor3 = Color3.fromRGB(0, 0, 0)
            keybind.BorderSizePixel = 0
            keybind.Size = UDim2.new(0, 215, 0, 37)
            keybind.AutoButtonColor = false
            keybind.Font = Enum.Font.SourceSans
            keybind.Text = ""
            keybind.TextColor3 = Color3.fromRGB(0, 0, 0)
            keybind.TextSize = 14.000
            keybind.Parent = section

            local UICorner = Instance.new("UICorner")
            UICorner.CornerRadius = UDim.new(0, 10)
            UICorner.Parent = keybind

            local TextLabel = Instance.new("TextLabel")
            TextLabel.Parent = keybind
            TextLabel.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.BackgroundTransparency = 1.000
            TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel.BorderSizePixel = 0
            TextLabel.Position = UDim2.new(0.424475819, 0, 0.5, 0)
            TextLabel.Size = UDim2.new(0, 155, 0, 15)
            TextLabel.ZIndex = 2
            TextLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel.TextScaled = true
            TextLabel.TextSize = 14.000
            TextLabel.TextWrapped = true
            TextLabel.TextXAlignment = Enum.TextXAlignment.Left
            TextLabel.Text = options.Title

            local Box = Instance.new("Frame")
            Box.Name = "Box"
            Box.Parent = keybind
            Box.AnchorPoint = Vector2.new(0.5, 0.5)
            Box.BackgroundColor3 = Color3.fromRGB(22, 23, 27)
            Box.BorderColor3 = Color3.fromRGB(0, 0, 0)
            Box.BorderSizePixel = 0
            Box.Position = UDim2.new(0.875459313, 0, 0.472972959, 0)
            Box.Size = UDim2.new(0, 27, 0, 21)

            local UICorner_2 = Instance.new("UICorner")
            UICorner_2.CornerRadius = UDim.new(0, 4)
            UICorner_2.Parent = Box

            local TextLabel_2 = Instance.new("TextLabel")
            TextLabel_2.Parent = Box
            TextLabel_2.AnchorPoint = Vector2.new(0.5, 0.5)
            TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel_2.BackgroundTransparency = 1.000
            TextLabel_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
            TextLabel_2.BorderSizePixel = 0
            TextLabel_2.Position = UDim2.new(0.630466938, 0, 0.5, 0)
            TextLabel_2.Size = UDim2.new(0, 29, 0, 15)
            TextLabel_2.ZIndex = 2
            TextLabel_2.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            TextLabel_2.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextLabel_2.TextScaled = true
            TextLabel_2.TextSize = 14.000
            TextLabel_2.TextWrapped = true
            TextLabel_2.Text = options.Default or "F"

            if not Library.Flags[flag] then
                Library.Flags[flag] = options.Default or "F"
            end

            TextLabel_2.Text = Library.Flags[flag]

            keybind.MouseButton1Click:Connect(function()
                TextLabel_2.Text = '...'
                local input = UserInputService.InputBegan:Wait()
                if input.KeyCode.Name ~= 'Unknown' then
                    TextLabel_2.Text = input.KeyCode.Name
                    Library.Flags[flag] = input.KeyCode.Name
                    Library.save_flags()
                end
            end)

            UserInputService.InputBegan:Connect(function(input, processed)
                if not processed then
                    if input.KeyCode.Name == Library.Flags[flag] then
                        options.Callback(Library.Flags[flag])
                    end
                end
            end)
        end

        function Tab:Section(options)
            local section = (options.Section == 'right') and right_section or left_section

            local title = Instance.new("TextLabel")
            title.Name = "Title"
            title.AnchorPoint = Vector2.new(0.5, 0.5)
            title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            title.BackgroundTransparency = 1.000
            title.BorderColor3 = Color3.fromRGB(0, 0, 0)
            title.BorderSizePixel = 0
            title.Position = UDim2.new(0.531395316, 0, 0.139784947, 0)
            title.Size = UDim2.new(0, 201, 0, 15)
            title.ZIndex = 2
            title.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.SemiBold)
            title.TextColor3 = Color3.fromRGB(255, 255, 255)
            title.TextScaled = true
            title.TextSize = 14.000
            title.TextWrapped = true
            title.TextXAlignment = Enum.TextXAlignment.Left
            title.Text = options.Title
            title.Parent = section
        end

        function Tab:Label(options)
            local section = (options.Section == 'right') and right_section or left_section

            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.AnchorPoint = Vector2.new(0.5, 0.5)
            label.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            label.BackgroundTransparency = 1.000
            label.BorderColor3 = Color3.fromRGB(0, 0, 0)
            label.BorderSizePixel = 0
            label.Position = UDim2.new(0.531395316, 0, 0.139784947, 0)
            label.Size = UDim2.new(0, 201, 0, 12)
            label.ZIndex = 2
            label.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular)
            label.TextColor3 = Color3.fromRGB(200, 200, 200)
            label.TextScaled = true
            label.TextSize = 12.000
            label.TextWrapped = true
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Text = options.Text or "Label"
            label.Parent = section

            local Label = {}
            function Label:update(new_text)
                label.Text = new_text
            end
            return Label
        end

        tab.MouseButton1Click:Connect(function()
            Tab:open_tab()
        end)

        return Tab
    end

    -- Event handlers
    Container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            Library.dragging = true
            Library.drag_position = input.Position
            Library.start_position = Container.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    Library.dragging = false
                    Library.drag_position = nil
                    Library.start_position = nil
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if Library.dragging and Library.drag_position and Library.start_position then
                local delta = input.Position - Library.drag_position
                local position = UDim2.new(
                    Library.start_position.X.Scale, 
                    Library.start_position.X.Offset + delta.X, 
                    Library.start_position.Y.Scale, 
                    Library.start_position.Y.Offset + delta.Y
                )
                TweenService:Create(Container, TweenInfo.new(0.2), {Position = position}):Play()
                TweenService:Create(Shadow, TweenInfo.new(0.2), {Position = position}):Play()
            end
        end
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if not Library.exist() then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            Window:visible()
        end
    end)

    mobile_button.MouseButton1Click:Connect(function()
        Window:visible()
    end)

    table.insert(Library.windows, window_data)
    return Window
end

return Library
