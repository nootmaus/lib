local IceLibrary = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local Theme = {
    Bg = Color3.fromRGB(10, 15, 30),
    BgGradient = Color3.fromRGB(20, 30, 50),
    Element = Color3.fromRGB(15, 25, 45),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(160, 200, 220),
    Accent = Color3.fromRGB(0, 255, 255),
    Stroke = Color3.fromRGB(0, 100, 150),
    Green = Color3.fromRGB(0, 255, 150),
    Red = Color3.fromRGB(255, 80, 80)
}

function IceLibrary:Window(title)
    local Window = {}
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IceHubUI"
    ScreenGui.ResetOnSpawn = false
    if gethui then ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = CoreGui
    else ScreenGui.Parent = CoreGui end

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 240, 0, 50)
    Main.Position = UDim2.new(0.1, 0, 0.3, 0)
    Main.BackgroundColor3 = Theme.Bg
    Main.ClipsDescendants = true
    Main.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.Stroke
    MainStroke.Thickness = 2
    MainStroke.Parent = Main

    local Header = Instance.new("TextLabel")
    Header.Size = UDim2.new(1, -40, 0, 30)
    Header.Position = UDim2.new(0, 10, 0, 10)
    Header.BackgroundTransparency = 1
    Header.Text = title
    Header.TextColor3 = Theme.Accent
    Header.Font = Enum.Font.GothamBlack
    Header.TextSize = 18
    Header.TextXAlignment = Enum.TextXAlignment.Left
    Header.Parent = Main

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 10)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Theme.TextDim
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.Parent = Main

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    RunService.RenderStepped:Connect(function()
        if dragging and dragInput then
            local delta = dragInput.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Size = UDim2.new(1, -20, 1, -50)
    Container.Position = UDim2.new(0, 10, 0, 45)
    Container.BackgroundTransparency = 1
    Container.Parent = Main

    local UIList = Instance.new("UIListLayout")
    UIList.SortOrder = Enum.SortOrder.LayoutOrder
    UIList.Padding = UDim.new(0, 6)
    UIList.Parent = Container

    local YSize = 50

    local function Resize()
        YSize = UIList.AbsoluteContentSize.Y + 60
        TweenService:Create(Main, TweenInfo.new(0.3), {Size = UDim2.new(0, 240, 0, YSize)}):Play()
    end
    UIList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(Resize)

    function Window:Button(text, callback)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(1, 0, 0, 35)
        Btn.BackgroundColor3 = Theme.Element
        Btn.Text = ""
        Btn.AutoButtonColor = false
        Btn.Parent = Container

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Btn

        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = Theme.Stroke
        BtnStroke.Thickness = 1
        BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        BtnStroke.Parent = Btn

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, 0, 1, 0)
        Title.BackgroundTransparency = 1
        Title.Text = text
        Title.TextColor3 = Theme.Text
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            pcall(callback)
            TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
            task.wait(0.1)
            TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.Element}):Play()
        end)
    end

    function Window:Toggle(text, default, callback)
        local State = default or false
        local Tgl = Instance.new("TextButton")
        Tgl.Size = UDim2.new(1, 0, 0, 35)
        Tgl.BackgroundColor3 = Theme.Element
        Tgl.Text = ""
        Tgl.AutoButtonColor = false
        Tgl.Parent = Container

        local TglCorner = Instance.new("UICorner")
        TglCorner.CornerRadius = UDim.new(0, 6)
        TglCorner.Parent = Tgl

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0.7, 0, 1, 0)
        Title.Position = UDim2.new(0, 10, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = text
        Title.TextColor3 = Theme.Text
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Tgl

        local Status = Instance.new("Frame")
        Status.Size = UDim2.new(0, 20, 0, 20)
        Status.Position = UDim2.new(1, -30, 0.5, -10)
        Status.BackgroundColor3 = State and Theme.Green or Theme.Red
        Status.Parent = Tgl
        
        Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 4)

        Tgl.MouseButton1Click:Connect(function()
            State = not State
            TweenService:Create(Status, TweenInfo.new(0.2), {BackgroundColor3 = State and Theme.Green or Theme.Red}):Play()
            pcall(callback, State)
        end)
    end

    function Window:Slider(text, min, max, callback)
        local Sld = Instance.new("Frame")
        Sld.Size = UDim2.new(1, 0, 0, 50)
        Sld.BackgroundColor3 = Theme.Element
        Sld.Parent = Container

        Instance.new("UICorner", Sld).CornerRadius = UDim.new(0, 6)

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(1, -20, 0, 20)
        Title.Position = UDim2.new(0, 10, 0, 5)
        Title.BackgroundTransparency = 1
        Title.Text = text
        Title.TextColor3 = Theme.Text
        Title.Font = Enum.Font.GothamBold
        Title.TextSize = 14
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = Sld

        local ValueLabel = Instance.new("TextLabel")
        ValueLabel.Size = UDim2.new(0, 30, 0, 20)
        ValueLabel.Position = UDim2.new(1, -40, 0, 5)
        ValueLabel.BackgroundTransparency = 1
        ValueLabel.Text = tostring(min)
        ValueLabel.TextColor3 = Theme.Accent
        ValueLabel.Font = Enum.Font.Gotham
        ValueLabel.TextSize = 12
        ValueLabel.Parent = Sld

        local BarBG = Instance.new("TextButton")
        BarBG.Size = UDim2.new(1, -20, 0, 6)
        BarBG.Position = UDim2.new(0, 10, 0, 35)
        BarBG.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
        BarBG.Text = ""
        BarBG.AutoButtonColor = false
        BarBG.Parent = Sld
        Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(0, 0, 1, 0)
        Fill.BackgroundColor3 = Theme.Accent
        Fill.Parent = BarBG
        Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

        local draggingSlider = false

        local function Update(input)
            local pos = UDim2.new(math.clamp((input.Position.X - BarBG.AbsolutePosition.X) / BarBG.AbsoluteSize.X, 0, 1), 0, 1, 0)
            Fill.Size = pos
            local val = math.floor(min + ((max - min) * pos.X.Scale))
            ValueLabel.Text = tostring(val)
            pcall(callback, val)
        end

        BarBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
                Update(input)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then
                Update(input)
            end
        end)
    end

    function Window:Notify(title, msg, dur)
        local Holder = ScreenGui:FindFirstChild("NotifyHolder")
        if not Holder then
            Holder = Instance.new("Frame")
            Holder.Name = "NotifyHolder"
            Holder.Size = UDim2.new(0, 200, 1, 0)
            Holder.Position = UDim2.new(1, -220, 0, 20)
            Holder.BackgroundTransparency = 1
            Holder.Parent = ScreenGui
            local List = Instance.new("UIListLayout")
            List.Parent = Holder
            List.SortOrder = Enum.SortOrder.LayoutOrder
            List.Padding = UDim.new(0, 5)
            List.VerticalAlignment = Enum.VerticalAlignment.Bottom
        end

        local Notif = Instance.new("Frame")
        Notif.Size = UDim2.new(1, 0, 0, 0)
        Notif.BackgroundColor3 = Theme.Bg
        Notif.ClipsDescendants = true
        Notif.Parent = Holder

        local Stroke = Instance.new("UIStroke")
        Stroke.Color = Theme.Accent
        Stroke.Thickness = 1.5
        Stroke.Parent = Notif
        Instance.new("UICorner", Notif).CornerRadius = UDim.new(0, 6)

        local Ttl = Instance.new("TextLabel")
        Ttl.Text = title
        Ttl.Size = UDim2.new(1, -10, 0, 20)
        Ttl.Position = UDim2.new(0, 5, 0, 5)
        Ttl.BackgroundTransparency = 1
        Ttl.TextColor3 = Theme.Accent
        Ttl.Font = Enum.Font.GothamBold
        Ttl.TextSize = 14
        Ttl.TextXAlignment = Enum.TextXAlignment.Left
        Ttl.Parent = Notif

        local Msg = Instance.new("TextLabel")
        Msg.Text = msg
        Msg.Size = UDim2.new(1, -10, 0, 20)
        Msg.Position = UDim2.new(0, 5, 0, 25)
        Msg.BackgroundTransparency = 1
        Msg.TextColor3 = Theme.Text
        Msg.Font = Enum.Font.Gotham
        Msg.TextSize = 12
        Msg.TextXAlignment = Enum.TextXAlignment.Left
        Msg.Parent = Notif

        TweenService:Create(Notif, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 50)}):Play()
        
        task.delay(dur or 3, function()
            TweenService:Create(Notif, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0), Transparency = 1}):Play()
            task.wait(0.3)
            Notif:Destroy()
        end)
    end

    return Window
end

return IceLibrary
