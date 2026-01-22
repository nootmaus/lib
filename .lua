local IceLibrary = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local Settings = {
    Name = "IceConfig",
    Theme = {
        Main = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(30, 30, 30),
        Stroke = Color3.fromRGB(45, 45, 45),
        Divider = Color3.fromRGB(50, 50, 50),
        Text = Color3.fromRGB(240, 240, 240),
        TextDark = Color3.fromRGB(160, 160, 160),
        Accent = Color3.fromRGB(0, 140, 255)
    }
}

local Library = {
    Flags = {},
    Toggled = true,
    OpenKey = Enum.KeyCode.RightControl
}

function IceLibrary:GetSafeGui()
    if gethui then return gethui() end
    if syn and syn.protect_gui then
        local g = Instance.new("ScreenGui")
        syn.protect_gui(g)
        g.Parent = CoreGui
        return g
    end
    return CoreGui
end

local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in next, props do
        obj[k] = v
    end
    return obj
end

local function MakeDraggable(frame, parent)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            parent.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function IceLibrary:Window(options)
    local Win = {}
    local Title = options.Title or "Ice Library"
    local ConfigName = options.Config or "IceConfig"
    
    Settings.Name = ConfigName

    local ScreenGui = Create("ScreenGui", {
        Name = Title,
        Parent = self:GetSafeGui(),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    local Main = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Settings.Theme.Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 450)
    })
    Create("UICorner", {Parent = Main, CornerRadius = UDim.new(0, 8)})
    Create("UIStroke", {Parent = Main, Color = Settings.Theme.Stroke, Thickness = 1})

    local Topbar = Create("Frame", {
        Name = "Topbar",
        Parent = Main,
        BackgroundColor3 = Settings.Theme.Main,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40)
    })
    Create("UICorner", {Parent = Topbar, CornerRadius = UDim.new(0, 8)})
    
    local TopbarFix = Create("Frame", {
        Parent = Topbar,
        BackgroundColor3 = Settings.Theme.Main,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -5),
        Size = UDim2.new(1, 0, 0, 5)
    })

    local TitleLabel = Create("TextLabel", {
        Parent = Topbar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -30, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Title,
        TextColor3 = Settings.Theme.Text,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    local TabContainer = Create("Frame", {
        Name = "Tabs",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 45),
        Size = UDim2.new(0, 140, 1, -55)
    })
    local TabLayout = Create("UIListLayout", {
        Parent = TabContainer,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local Pages = Create("Frame", {
        Name = "Pages",
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 160, 0, 45),
        Size = UDim2.new(1, -170, 1, -55)
    })
    
    local Separator = Create("Frame", {
        Parent = Main,
        BackgroundColor3 = Settings.Theme.Divider,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 155, 0, 45),
        Size = UDim2.new(0, 1, 1, -55)
    })

    MakeDraggable(Topbar, Main)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.OpenKey then
            Library.Toggled = not Library.Toggled
            ScreenGui.Enabled = Library.Toggled
        end
    end)

    local FirstTab = true

    function Win:Tab(name)
        local TabObj = {}
        
        local TabButton = Create("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Settings.Theme.Secondary,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 32),
            Font = Enum.Font.GothamMedium,
            Text = name,
            TextColor3 = Settings.Theme.TextDark,
            TextSize = 14,
            AutoButtonColor = false
        })
        Create("UICorner", {Parent = TabButton, CornerRadius = UDim.new(0, 6)})

        local Page = Create("ScrollingFrame", {
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Settings.Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Create("UIPadding", {Parent = Page, PaddingBottom = UDim.new(0, 10), PaddingRight = UDim.new(0, 10)})
        
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
        end)

        if FirstTab then
            TabButton.BackgroundTransparency = 0
            TabButton.TextColor3 = Settings.Theme.Text
            Page.Visible = true
            FirstTab = false
        end

        TabButton.MouseButton1Click:Connect(function()
            for _, v in next, TabContainer:GetChildren() do
                if v:IsA("TextButton") then
                    TweenService:Create(v, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextColor3 = Settings.Theme.TextDark}):Play()
                end
            end
            for _, v in next, Pages:GetChildren() do
                v.Visible = false
            end
            TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextColor3 = Settings.Theme.Text}):Play()
            Page.Visible = true
        end)

        function TabObj:Section(text)
            local SectionLabel = Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
                Font = Enum.Font.GothamBold,
                Text = text,
                TextColor3 = Settings.Theme.Accent,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function TabObj:Label(text)
             Create("TextLabel", {
                Parent = Page,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = text,
                TextColor3 = Settings.Theme.TextDark,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })
        end

        function TabObj:Button(text, callback)
            local Btn = Create("TextButton", {
                Parent = Page,
                BackgroundColor3 = Settings.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 36),
                AutoButtonColor = false,
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Settings.Theme.Text,
                TextSize = 13
            })
            Create("UICorner", {Parent = Btn, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Btn, Color = Settings.Theme.Stroke, Thickness = 1})

            Btn.MouseButton1Click:Connect(function()
                TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Settings.Theme.Accent}):Play()
                task.wait(0.1)
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Settings.Theme.Secondary}):Play()
                callback()
            end)
        end

        function TabObj:Toggle(text, flag, default, callback)
            Library.Flags[flag] = default
            
            local Container = Create("TextButton", {
                Parent = Page,
                BackgroundColor3 = Settings.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 36),
                AutoButtonColor = false,
                Text = ""
            })
            Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Container, Color = Settings.Theme.Stroke, Thickness = 1})

            local Label = Create("TextLabel", {
                Parent = Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Settings.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Toggler = Create("Frame", {
                Parent = Container,
                BackgroundColor3 = default and Settings.Theme.Accent or Color3.fromRGB(60, 60, 60),
                Position = UDim2.new(1, -50, 0.5, -10),
                Size = UDim2.new(0, 40, 0, 20)
            })
            Create("UICorner", {Parent = Toggler, CornerRadius = UDim.new(1, 0)})

            local Circle = Create("Frame", {
                Parent = Toggler,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })
            Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})

            Container.MouseButton1Click:Connect(function()
                Library.Flags[flag] = not Library.Flags[flag]
                local state = Library.Flags[flag]
                
                TweenService:Create(Toggler, TweenInfo.new(0.2), {BackgroundColor3 = state and Settings.Theme.Accent or Color3.fromRGB(60, 60, 60)}):Play()
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
                
                callback(state)
            end)
            if default then callback(true) end
        end

        function TabObj:Slider(text, flag, min, max, default, callback)
            Library.Flags[flag] = default
            
            local Container = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 50)
            })
            Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Container, Color = Settings.Theme.Stroke, Thickness = 1})

            local Label = Create("TextLabel", {
                Parent = Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Settings.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ValueLabel = Create("TextLabel", {
                Parent = Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -20, 0, 20),
                Font = Enum.Font.GothamBold,
                Text = tostring(default),
                TextColor3 = Settings.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderBar = Create("TextButton", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                Position = UDim2.new(0, 10, 0, 32),
                Size = UDim2.new(1, -20, 0, 6),
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = SliderBar, CornerRadius = UDim.new(1, 0)})

            local Fill = Create("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Settings.Theme.Accent,
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            })
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})

            local Dragging = false

            local function Update(input)
                local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + ((max - min) * pos))
                
                TweenService:Create(Fill, TweenInfo.new(0.1), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
                ValueLabel.Text = tostring(val)
                Library.Flags[flag] = val
                callback(val)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    Update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    Update(input)
                end
            end)
            callback(default)
        end

        function TabObj:Dropdown(text, flag, options, callback)
            local DropdownObj = {}
            local Opened = false
            
            local Container = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 36),
                ZIndex = 2
            })
            Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Container, Color = Settings.Theme.Stroke, Thickness = 1})

            local MainBtn = Create("TextButton", {
                Parent = Container,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 36),
                Font = Enum.Font.GothamMedium,
                Text = "",
                ZIndex = 2
            })

            local Label = Create("TextLabel", {
                Parent = Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text .. "...",
                TextColor3 = Settings.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })

            local Arrow = Create("ImageLabel", {
                Parent = Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -26, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://6031091004",
                ImageColor3 = Settings.Theme.TextDark,
                ZIndex = 2
            })

            local ListFrame = Create("ScrollingFrame", {
                Parent = Container,
                BackgroundColor3 = Settings.Theme.Secondary,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 0, 1, 5),
                Size = UDim2.new(1, 0, 0, 0),
                Visible = false,
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Settings.Theme.Accent,
                ZIndex = 3,
                CanvasSize = UDim2.new(0, 0, 0, 0)
            })
            Create("UICorner", {Parent = ListFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = ListFrame, Color = Settings.Theme.Stroke, Thickness = 1})
            
            local ListLayout = Create("UIListLayout", {
                Parent = ListFrame,
                Padding = UDim.new(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder
            })
            Create("UIPadding", {Parent = ListFrame, PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5)})

            local function Refresh(newOptions)
                for _, v in next, ListFrame:GetChildren() do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                
                for _, opt in ipairs(newOptions) do
                    local Item = Create("TextButton", {
                        Parent = ListFrame,
                        BackgroundColor3 = Settings.Theme.Main,
                        Size = UDim2.new(1, 0, 0, 25),
                        AutoButtonColor = false,
                        Font = Enum.Font.Gotham,
                        Text = opt,
                        TextColor3 = Settings.Theme.TextDark,
                        TextSize = 12,
                        ZIndex = 4
                    })
                    Create("UICorner", {Parent = Item, CornerRadius = UDim.new(0, 4)})
                    
                    Item.MouseButton1Click:Connect(function()
                        Opened = false
                        Label.Text = text .. ": " .. opt
                        Label.TextColor3 = Settings.Theme.Accent
                        Library.Flags[flag] = opt
                        TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                        TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                        task.wait(0.2)
                        ListFrame.Visible = false
                        Container.ZIndex = 2
                        callback(opt)
                    end)
                end
                ListFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 10)
            end

            Refresh(options)

            MainBtn.MouseButton1Click:Connect(function()
                Opened = not Opened
                if Opened then
                    Container.ZIndex = 5
                    ListFrame.Visible = true
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 180}):Play()
                    TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, math.min(150, ListLayout.AbsoluteContentSize.Y + 10))}):Play()
                else
                    TweenService:Create(Arrow, TweenInfo.new(0.2), {Rotation = 0}):Play()
                    TweenService:Create(ListFrame, TweenInfo.new(0.2), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    task.wait(0.2)
                    ListFrame.Visible = false
                    Container.ZIndex = 2
                end
            end)
            
            function DropdownObj:Update(newOpts)
                Refresh(newOpts)
            end
            return DropdownObj
        end

        function TabObj:Box(text, flag, callback)
            local Container = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 36)
            })
            Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Container, Color = Settings.Theme.Stroke, Thickness = 1})

            local Label = Create("TextLabel", {
                Parent = Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(0.6, 0, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Settings.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Box = Create("TextBox", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                Position = UDim2.new(0.65, 0, 0.5, -12),
                Size = UDim2.new(0.32, 0, 0, 24),
                Font = Enum.Font.Gotham,
                Text = "",
                PlaceholderText = "...",
                TextColor3 = Settings.Theme.Text,
                TextSize = 12
            })
            Create("UICorner", {Parent = Box, CornerRadius = UDim.new(0, 4)})

            Box.FocusLost:Connect(function(enter)
                Library.Flags[flag] = Box.Text
                if callback then callback(Box.Text, enter) end
            end)
        end

        function TabObj:ColorPicker(text, flag, default, callback)
            Library.Flags[flag] = default
            local Open = false

            local Container = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Settings.Theme.Secondary,
                Size = UDim2.new(1, 0, 0, 36)
            })
            Create("UICorner", {Parent = Container, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = Container, Color = Settings.Theme.Stroke, Thickness = 1})

            local Label = Create("TextLabel", {
                Parent = Container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.GothamMedium,
                Text = text,
                TextColor3 = Settings.Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ColorBtn = Create("TextButton", {
                Parent = Container,
                BackgroundColor3 = default,
                Position = UDim2.new(1, -40, 0.5, -10),
                Size = UDim2.new(0, 30, 0, 20),
                Text = "",
                AutoButtonColor = false
            })
            Create("UICorner", {Parent = ColorBtn, CornerRadius = UDim.new(0, 4)})
            
            local PickerFrame = Create("Frame", {
                Parent = Container,
                BackgroundColor3 = Settings.Theme.Main,
                Position = UDim2.new(1, -160, 1, 5),
                Size = UDim2.new(0, 150, 0, 150),
                Visible = false,
                ZIndex = 10
            })
            Create("UICorner", {Parent = PickerFrame, CornerRadius = UDim.new(0, 6)})
            Create("UIStroke", {Parent = PickerFrame, Color = Settings.Theme.Stroke, Thickness = 1})
            
            local ColorImg = Create("ImageButton", {
                Parent = PickerFrame,
                BackgroundColor3 = Color3.new(1,0,0),
                Position = UDim2.new(0, 10, 0, 10),
                Size = UDim2.new(0, 110, 0, 110),
                Image = "rbxassetid://4155801252",
                ZIndex = 11
            })
            
            local ColorSelect = Create("Frame", {
                Parent = ColorImg,
                BackgroundColor3 = Color3.new(1,1,1),
                Size = UDim2.new(0, 4, 0, 4),
                Position = UDim2.new(0.5, 0, 0.5, 0),
                ZIndex = 12
            })
            Create("UICorner", {Parent = ColorSelect, CornerRadius = UDim.new(1, 0)})

            local HueImg = Create("ImageButton", {
                Parent = PickerFrame,
                Position = UDim2.new(0, 130, 0, 10),
                Size = UDim2.new(0, 10, 0, 110),
                Image = "rbxassetid://4155801252",
                ZIndex = 11
            })
            local HueGradient = Create("UIGradient", {
                Parent = HueImg,
                Rotation = 90,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                })
            })

            local h, s, v = default:ToHSV()
            
            local function UpdateColor()
                local color = Color3.fromHSV(h, s, v)
                ColorBtn.BackgroundColor3 = color
                ColorImg.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                Library.Flags[flag] = color
                callback(color)
            end

            ColorBtn.MouseButton1Click:Connect(function()
                Open = not Open
                PickerFrame.Visible = Open
                Container.ZIndex = Open and 10 or 1
            end)

            ColorImg.MouseButton1Down:Connect(function()
                local dragging = true
                local input = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local x = math.clamp((input.Position.X - ColorImg.AbsolutePosition.X) / ColorImg.AbsoluteSize.X, 0, 1)
                        local y = math.clamp((input.Position.Y - ColorImg.AbsolutePosition.Y) / ColorImg.AbsoluteSize.Y, 0, 1)
                        ColorSelect.Position = UDim2.new(x, -2, y, -2)
                        s = x
                        v = 1 - y
                        UpdateColor()
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        input:Disconnect()
                    end
                end)
            end)
            
            HueImg.MouseButton1Down:Connect(function()
                local dragging = true
                local input = UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        local y = math.clamp((input.Position.Y - HueImg.AbsolutePosition.Y) / HueImg.AbsoluteSize.Y, 0, 1)
                        h = 1 - y
                        UpdateColor()
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                        input:Disconnect()
                    end
                end)
            end)
        end
        
        return TabObj
    end
    
    return Win
end

return IceLibrary
