local VoidLib = {}
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function VoidLib:CreateWindow(cfg)
    cfg = cfg or {}
    local TitleText = cfg.Title or "VOID.CC"
    local WinSize = cfg.Size or UDim2.new(0, 240, 0, 100) -- Можно менять размер окна
    local WinPos = cfg.Position or UDim2.new(0.5, -120, 0.85, -60) -- Можно менять позицию

    if gethui then
        pcall(function() gethui():FindFirstChild("VoidLib_UI"):Destroy() end)
    elseif CoreGui:FindFirstChild("VoidLib_UI") then
        CoreGui:FindFirstChild("VoidLib_UI"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VoidLib_UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.DisplayOrder = 10000
    ScreenGui.Parent = gethui and gethui() or CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Main"
    MainFrame.Size = WinSize
    MainFrame.Position = WinPos
    MainFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    MainFrame.BorderSizePixel = 0
    MainFrame.ZIndex = 10
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    
    MakeDraggable(MainFrame)

    local MainGradient = Instance.new("UIGradient")
    MainGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(15, 0, 30)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(40, 0, 80))
    }
    MainGradient.Rotation = 45
    MainGradient.Parent = MainFrame

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 8)
    UICorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 2
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame

    local StrokeGradient = Instance.new("UIGradient")
    StrokeGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(130, 0, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(130, 0, 255))
    }
    StrokeGradient.Parent = MainStroke

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -20, 0, 25)
    TitleLbl.Position = UDim2.new(0, 10, 0, 4)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = TitleText
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.Font = Enum.Font.GothamBlack
    TitleLbl.TextSize = 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 12
    TitleLbl.Parent = MainFrame

    local TitleGradient = Instance.new("UIGradient")
    TitleGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(180, 100, 255)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(180, 100, 255))
    }
    TitleGradient.Parent = TitleLbl

    task.spawn(function()
        while MainFrame.Parent do
            StrokeGradient.Rotation = (StrokeGradient.Rotation + 2) % 360
            TitleGradient.Rotation = (TitleGradient.Rotation - 2) % 360
            RunService.RenderStepped:Wait()
        end
    end)
    
    -- Контейнер для инфо (Target / Bar)
    local InfoContainer = Instance.new("Frame")
    InfoContainer.Name = "Info"
    InfoContainer.BackgroundTransparency = 1
    InfoContainer.Position = UDim2.new(0, 10, 0, 35)
    InfoContainer.Size = UDim2.new(1, -20, 0, 55)
    InfoContainer.ZIndex = 12
    InfoContainer.Parent = MainFrame

    local TargetName = Instance.new("TextLabel")
    TargetName.Name = "Target"
    TargetName.Size = UDim2.new(0.6, 0, 0, 18)
    TargetName.BackgroundTransparency = 1
    TargetName.Text = "Waiting..." 
    TargetName.TextColor3 = Color3.fromRGB(220, 180, 255)
    TargetName.Font = Enum.Font.GothamBold
    TargetName.TextSize = 12
    TargetName.TextXAlignment = Enum.TextXAlignment.Left
    TargetName.TextTruncate = Enum.TextTruncate.AtEnd
    TargetName.ZIndex = 13
    TargetName.Parent = InfoContainer

    local TargetValue = Instance.new("TextLabel")
    TargetValue.Name = "Value"
    TargetValue.Size = UDim2.new(0.4, 0, 0, 18)
    TargetValue.Position = UDim2.new(0.6, 0, 0, 0)
    TargetValue.BackgroundTransparency = 1
    TargetValue.Text = "" 
    TargetValue.TextColor3 = Color3.fromRGB(0, 255, 150)
    TargetValue.Font = Enum.Font.GothamBold
    TargetValue.TextSize = 12
    TargetValue.TextXAlignment = Enum.TextXAlignment.Right
    TargetValue.ZIndex = 13
    TargetValue.Parent = InfoContainer

    local BarBG = Instance.new("Frame")
    BarBG.Name = "BarBG"
    BarBG.Size = UDim2.new(1, 0, 0, 4)
    BarBG.Position = UDim2.new(0, 0, 0, 22)
    BarBG.BackgroundColor3 = Color3.fromRGB(20, 10, 30)
    BarBG.BorderSizePixel = 0
    BarBG.ZIndex = 13
    BarBG.Parent = InfoContainer
    Instance.new("UICorner", BarBG).CornerRadius = UDim.new(1, 0)

    local BarFill = Instance.new("Frame")
    BarFill.Name = "BarFill"
    BarFill.Size = UDim2.new(0, 0, 1, 0)
    BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    BarFill.BorderSizePixel = 0
    BarFill.ZIndex = 14
    BarFill.Parent = BarBG
    Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

    local FillGradient = Instance.new("UIGradient")
    FillGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(100, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 50, 150))
    }
    FillGradient.Parent = BarFill

    local Window = {}

    -- === ГЛАВНАЯ ФУНКЦИЯ ДОБАВЛЕНИЯ КНОПОК ===
    -- props = { Text="", Size=UDim2, Position=UDim2, Style="Purple" or "RedStroke", Callback=fn }
    function Window:AddButton(props)
        props = props or {}
        local bText = props.Text or "Button"
        local bSize = props.Size or UDim2.new(0, 60, 0, 20)
        local bPos = props.Position or UDim2.new(1, -70, 0, 5)
        local bStyle = props.Style or "Purple" -- "Purple" (как Teleport) или "RedStroke" (как Block)
        local callback = props.Callback or function() end

        local BtnObject = nil

        if bStyle == "Purple" then
            -- Стиль 1: Фиолетовая заливка (Как Teleport)
            local TPButton = Instance.new("TextButton")
            TPButton.Size = bSize
            TPButton.Position = bPos
            TPButton.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
            TPButton.Text = bText
            TPButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TPButton.Font = Enum.Font.GothamBold
            TPButton.TextSize = 9
            TPButton.AutoButtonColor = true
            TPButton.ZIndex = 15
            TPButton.Parent = MainFrame
            
            -- Если передан AnchorPoint, используем его, иначе дефолт 0,0
            if props.AnchorPoint then TPButton.AnchorPoint = props.AnchorPoint end

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = TPButton

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Thickness = 1
            BtnStroke.Color = Color3.fromRGB(150, 50, 255)
            BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            BtnStroke.Parent = TPButton
            
            TPButton.MouseButton1Click:Connect(function() callback(TPButton) end)
            BtnObject = TPButton

        elseif bStyle == "RedStroke" then
            -- Стиль 2: Прозрачная с красной обводкой (Как Block)
            local Container = Instance.new("Frame")
            Container.Size = bSize
            Container.Position = bPos
            Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Container.ZIndex = 15
            Container.Parent = MainFrame
            
            if props.AnchorPoint then Container.AnchorPoint = props.AnchorPoint end

            local ContainerCorner = Instance.new("UICorner")
            ContainerCorner.CornerRadius = UDim.new(0, 4)
            ContainerCorner.Parent = Container

            local ContainerStroke = Instance.new("UIStroke")
            ContainerStroke.Thickness = 1.5
            ContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ContainerStroke.Color = Color3.fromRGB(255, 50, 50)
            ContainerStroke.Parent = Container

            local ContainerGradient = Instance.new("UIGradient")
            ContainerGradient.Color = ColorSequence.new{
                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(200, 20, 20)),
                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(100, 10, 10))
            }
            ContainerGradient.Parent = Container

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = bText
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255) 
            Btn.Font = Enum.Font.GothamBlack
            Btn.TextSize = 10
            Btn.ZIndex = 100 
            Btn.Parent = Container
            
            Btn.MouseButton1Click:Connect(function() callback(Btn) end)
            BtnObject = Container
        end
        
        return BtnObject
    end

    function Window:UpdateStatus(name, value)
        TargetName.Text = name or ""
        TargetValue.Text = value or ""
    end

    local tweenBar = nil
    function Window:AnimateBar(duration)
        if tweenBar then tweenBar:Cancel() end
        BarFill.Size = UDim2.new(0, 0, 1, 0)
        local ti = TweenInfo.new(duration, Enum.EasingStyle.Linear)
        tweenBar = TweenService:Create(BarFill, ti, { Size = UDim2.new(1, 0, 1, 0) })
        tweenBar:Play()
        task.delay(duration, function()
            if BarFill.Size.X.Scale >= 0.99 then
                BarFill.Size = UDim2.new(0, 0, 1, 0)
            end
        end)
    end

    return Window
end

return VoidLib
