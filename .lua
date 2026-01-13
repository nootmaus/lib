--!strict
-- // ICE LIBRARY: FIXED SETTINGS & TABS // --

local Library = {}
Library.__index = Library

local Services = {
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService"),
    CoreGui = game:GetService("CoreGui"),
    Players = game:GetService("Players")
}

local DEBOUNCE_TIME = 0.2

local DefaultTheme = {
    Background = Color3.fromRGB(18, 18, 24),
    Header = Color3.fromRGB(24, 24, 32),
    HeaderButton = Color3.fromRGB(32, 32, 42),
    Section = Color3.fromRGB(28, 28, 38),
    Text = Color3.fromRGB(240, 240, 240),
    TextDim = Color3.fromRGB(140, 140, 150),
    Accent = Color3.fromRGB(64, 200, 255),
    Stroke = Color3.fromRGB(40, 40, 50),
    Notification = Color3.fromRGB(25, 25, 35)
}

-- // UTILITY // --
local Utility = {}
local DebounceStore = {}

function Utility:GetSafeContainer()
    if gethui then return gethui() end
    if syn and syn.protect_gui then 
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        gui.Parent = Services.CoreGui
        return gui
    end
    return Services.CoreGui
end

function Utility:Debounce(id: string, func: (...any) -> any)
    if DebounceStore[id] and (tick() - DebounceStore[id]) < DEBOUNCE_TIME then return end
    DebounceStore[id] = tick()
    func()
end

function Utility:Create(class: string, props: { [string]: any })
    local inst = Instance.new(class)
    for i, v in pairs(props) do if i ~= "Parent" then inst[i] = v end end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

function Utility:Tween(instance: Instance, info: TweenInfo, props: { [string]: any })
    Services.TweenService:Create(instance, info, props):Play()
end

function Utility:MakeDraggable(frame: Frame, handle: GuiObject)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    Services.UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- // CONFIG MANAGER // --
local ConfigManager = { Settings = {}, File = "IceLib_Config.json" }

function ConfigManager:Load(fileName: string)
    self.File = fileName or "IceLib_Config.json"
    if isfile and isfile(self.File) then
        pcall(function() self.Settings = Services.HttpService:JSONDecode(readfile(self.File)) end)
    end
end

function ConfigManager:Save()
    if writefile then
        pcall(function() writefile(self.File, Services.HttpService:JSONEncode(self.Settings)) end)
    end
end

function ConfigManager:SetValue(flag: string, value: any)
    if not flag then return end
    self.Settings[flag] = value
    self:Save()
end

function ConfigManager:GetValue(flag: string, default: any)
    if not flag then return default end
    return self.Settings[flag] ~= nil and self.Settings[flag] or default
end

-- // WINDOW SYSTEM // --
local Window = {}
Window.__index = Window

local Tab = {}
Tab.__index = Tab

function Library:CreateWindow(Config: { Title: string, Size: UDim2?, Icon: string?, Theme: table?, ConfigFile: string? })
    local self = setmetatable({}, Window)
    
    self.Config = Config
    self.Theme = Config.Theme or DefaultTheme
    self.Tabs = {}
    self.IsMinimized = false
    
    ConfigManager:Load(Config.ConfigFile)

    local container = Utility:GetSafeContainer()
    local guiName = "IceLib_" .. (Config.Title:gsub("%s+", ""))
    for _, v in pairs(container:GetChildren()) do if v.Name == guiName then v:Destroy() end end

    self.Gui = Utility:Create("ScreenGui", {Name = guiName, Parent = container, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
    
    -- Исправлен дефолтный размер на более узкий
    local finalSize = Config.Size or UDim2.new(0, 320, 0, 400)
    self.OriginalHeight = finalSize.Y.Offset
    
    self.MainFrame = Utility:Create("Frame", {
        Name = "MainFrame", Parent = self.Gui,
        Size = finalSize, Position = UDim2.new(0.5, -finalSize.X.Offset/2, 0.4, 0),
        BackgroundColor3 = self.Theme.Background, BorderSizePixel = 0, ClipsDescendants = true
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = self.MainFrame})
    Utility:Create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1.5, Parent = self.MainFrame})

    self.TabContainer = Utility:Create("Frame", {
        Name = "Body", Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 1, -50), Position = UDim2.new(0, 0, 0, 50),
        BackgroundTransparency = 1
    })
    
    self.NotificationHolder = Utility:Create("Frame", {
        Name = "Notifications", Parent = self.Gui,
        Size = UDim2.new(0, 250, 1, 0), Position = UDim2.new(1, -260, 0, 20),
        BackgroundTransparency = 1
    })
    Utility:Create("UIListLayout", { Parent = self.NotificationHolder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), VerticalAlignment = Enum.VerticalAlignment.Bottom })

    self:_BuildHeader()
    return self
end

function Window:SelectTab(tabName: string)
    local found = false
    for _, tab in ipairs(self.Tabs) do
        if tab.Name == tabName then
            tab.Container.Visible = true
            found = true
        else
            tab.Container.Visible = false
        end
    end
    -- Если вкладка не найдена, сообщаем об этом (для отладки)
    if not found then 
        self:Notify("System", "Tab '"..tabName.."' not found!", 2)
    end
end

function Window:_BuildHeader()
    local Header = Utility:Create("Frame", {
        Name = "Header", Parent = self.MainFrame,
        Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = self.Theme.Header, BorderSizePixel = 0
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = Header})
    
    self.HeaderFiller = Utility:Create("Frame", { 
        Parent = Header, Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = self.Theme.Header, BorderSizePixel = 0
    })
    
    Utility:MakeDraggable(self.MainFrame, Header)

    local iconId = self.Config.Icon or "rbxassetid://130389626803525"
    Utility:Create("ImageLabel", {
        Parent = Header, Size = UDim2.new(0, 28, 0, 28), Position = UDim2.new(0, 12, 0, 11),
        BackgroundTransparency = 1, Image = iconId, ImageColor3 = self.Theme.Accent
    })

    Utility:Create("TextLabel", {
        Parent = Header, Text = self.Config.Title,
        Size = UDim2.new(0, 200, 1, 0), Position = UDim2.new(0, 50, 0, 0),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBlack, TextSize = 18, TextColor3 = self.Theme.Text
    })

    local BtnContainer = Utility:Create("Frame", {
        Parent = Header, Size = UDim2.new(0, 100, 1, 0), Position = UDim2.new(1, -100, 0, 0), BackgroundTransparency = 1
    })
    local Layout = Utility:Create("UIListLayout", {
        Parent = BtnContainer, FillDirection = Enum.FillDirection.Horizontal, 
        HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 8)
    })
    Utility:Create("UIPadding", {Parent = BtnContainer, PaddingRight = UDim.new(0, 12)})

    local function CreateHeaderBtn(iconOrText: string, isText: boolean, callback)
        local Frame = Utility:Create("TextButton", { 
            Parent = BtnContainer, Size = UDim2.new(0, 32, 0, 32),
            BackgroundColor3 = self.Theme.HeaderButton, AutoButtonColor = false, Text = ""
        })
        Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = Frame})
        
        local Content
        if isText then
            Content = Utility:Create("TextLabel", {
                Parent = Frame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
                Text = iconOrText, Font = Enum.Font.GothamBold, TextSize = 20, TextColor3 = self.Theme.TextDim
            })
        else
            Content = Utility:Create("ImageLabel", {
                Parent = Frame, Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0.5, -9, 0.5, -9),
                BackgroundTransparency = 1, Image = iconOrText, ImageColor3 = self.Theme.TextDim
            })
        end

        Frame.MouseEnter:Connect(function() 
            Utility:Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.Accent})
            if isText then Utility:Tween(Content, TweenInfo.new(0.2), {TextColor3 = Color3.new(1,1,1)})
            else Utility:Tween(Content, TweenInfo.new(0.2), {ImageColor3 = Color3.new(1,1,1)}) end
        end)
        Frame.MouseLeave:Connect(function() 
            Utility:Tween(Frame, TweenInfo.new(0.2), {BackgroundColor3 = self.Theme.HeaderButton})
            if isText then Utility:Tween(Content, TweenInfo.new(0.2), {TextColor3 = self.Theme.TextDim})
            else Utility:Tween(Content, TweenInfo.new(0.2), {ImageColor3 = self.Theme.TextDim}) end
        end)
        
        Frame.MouseButton1Click:Connect(callback)
        return Content
    end

    local MinLabel = CreateHeaderBtn("−", true, function()
        self.IsMinimized = not self.IsMinimized
        if self.IsMinimized then
            self.HeaderFiller.Visible = false
            self.MainFrame:TweenSize(UDim2.new(self.MainFrame.Size.X.Scale, self.MainFrame.Size.X.Offset, 0, 50), "Out", "Quad", 0.3, true)
            MinLabel.Text = "+"
        else
            self.HeaderFiller.Visible = true
            self.MainFrame:TweenSize(UDim2.new(self.MainFrame.Size.X.Scale, self.MainFrame.Size.X.Offset, 0, self.OriginalHeight), "Out", "Quad", 0.3, true)
            MinLabel.Text = "−"
        end
    end)

    -- ИСПРАВЛЕНИЕ: Теперь кнопка вызывает функцию SelectTab("Settings")
    CreateHeaderBtn("rbxassetid://6031280882", false, function()
        self:SelectTab("Settings")
    end)
end

function Window:AddTab(name: string)
    local newTab = setmetatable({}, Tab)
    newTab.Window = self
    newTab.Name = name
    
    newTab.Container = Utility:Create("ScrollingFrame", {
        Name = name, Parent = self.TabContainer,
        Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1, ScrollBarThickness = 4, BorderSizePixel = 0,
        ScrollBarImageColor3 = self.Theme.Accent, Visible = (#self.Tabs == 0)
    })
    
    Utility:Create("UIListLayout", { Parent = newTab.Container, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
    Utility:Create("UIPadding", {Parent = newTab.Container, PaddingBottom = UDim.new(0, 10)})
    
    table.insert(self.Tabs, newTab)
    return newTab
end

function Window:Notify(title: string, text: string, duration: number)
    local frame = Utility:Create("Frame", {
        Parent = self.NotificationHolder, Size = UDim2.new(1, 0, 0, 60),
        BackgroundColor3 = self.Theme.Notification, BackgroundTransparency = 0.1,
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = frame})
    Utility:Create("UIStroke", {Color = self.Theme.Stroke, Thickness = 1, Parent = frame})
    
    local bar = Utility:Create("Frame", { Parent = frame, Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = self.Theme.Accent })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = bar})
    
    Utility:Create("TextLabel", {
        Parent = frame, Text = title, Size = UDim2.new(1, -15, 0, 20), Position = UDim2.new(0, 15, 0, 8),
        BackgroundTransparency = 1, Font = Enum.Font.GothamBlack, TextSize = 14, 
        TextColor3 = self.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    Utility:Create("TextLabel", {
        Parent = frame, Text = text, Size = UDim2.new(1, -15, 0, 20), Position = UDim2.new(0, 15, 0, 28),
        BackgroundTransparency = 1, Font = Enum.Font.Gotham, TextSize = 12, 
        TextColor3 = self.Theme.TextDim, TextXAlignment = Enum.TextXAlignment.Left
    })
    
    task.delay(duration or 3, function()
        Utility:Tween(frame, TweenInfo.new(0.5), {BackgroundTransparency = 1})
        frame:Destroy()
    end)
end

function Tab:AddToggle(text: string, flag: string, callback: (...any) -> any)
    local defaultState = ConfigManager:GetValue(flag, false)
    
    local Frame = Utility:Create("Frame", {
        Parent = self.Container, Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.Window.Theme.Section, BackgroundTransparency = 0
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Frame})
    Utility:Create("UIStroke", {Color = self.Window.Theme.Stroke, Thickness = 1, Parent = Frame})

    Utility:Create("TextLabel", {
        Parent = Frame, Text = text, Size = UDim2.new(0.7, 0, 1, 0), Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = self.Window.Theme.Text
    })

    local Switch = Utility:Create("TextButton", {
        Parent = Frame, Text = "", Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -52, 0.5, -10),
        BackgroundColor3 = defaultState and self.Window.Theme.Accent or self.Window.Theme.Stroke, AutoButtonColor = false
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Switch})
    
    local Circle = Utility:Create("Frame", {
        Parent = Switch, Size = UDim2.new(0, 16, 0, 16),
        Position = defaultState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
        BackgroundColor3 = Color3.new(1,1,1)
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Circle})

    local currentState = defaultState
    if currentState and callback then task.spawn(callback, true) end

    Switch.MouseButton1Click:Connect(function()
        Utility:Debounce(flag or text, function()
            currentState = not currentState
            ConfigManager:SetValue(flag, currentState)
            local targetPos = currentState and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            local targetColor = currentState and self.Window.Theme.Accent or self.Window.Theme.Stroke
            Utility:Tween(Circle, TweenInfo.new(0.2), {Position = targetPos})
            Utility:Tween(Switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor})
            if callback then callback(currentState) end
        end)
    end)
end

function Tab:AddButton(text: string, callback: (...any) -> any)
    local Button = Utility:Create("TextButton", {
        Parent = self.Container, Text = text,
        Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = self.Window.Theme.Section,
        Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = self.Window.Theme.Text, AutoButtonColor = false
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Button})
    local Stroke = Utility:Create("UIStroke", {Parent = Button, Color = self.Window.Theme.Stroke, Thickness = 1, Transparency = 0})

    Button.MouseButton1Click:Connect(function()
        Utility:Debounce("Btn_"..text, function()
            Utility:Tween(Stroke, TweenInfo.new(0.1), {Color = self.Window.Theme.Accent})
            Utility:Tween(Button, TweenInfo.new(0.1), {TextColor3 = self.Window.Theme.Accent})
            task.wait(0.1)
            Utility:Tween(Stroke, TweenInfo.new(0.3), {Color = self.Window.Theme.Stroke})
            Utility:Tween(Button, TweenInfo.new(0.3), {TextColor3 = self.Window.Theme.Text})
            if callback then callback() end
        end)
    end)
end

function Tab:AddSlider(text: string, flag: string, min: number, max: number, default: number, callback: (...any) -> any)
    local savedVal = ConfigManager:GetValue(flag, default)
    
    local Frame = Utility:Create("Frame", {
        Parent = self.Container, Size = UDim2.new(1, 0, 0, 55),
        BackgroundColor3 = self.Window.Theme.Section, BackgroundTransparency = 0
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = Frame})
    Utility:Create("UIStroke", {Color = self.Window.Theme.Stroke, Thickness = 1, Parent = Frame})

    Utility:Create("TextLabel", {
        Parent = Frame, Text = text,
        Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamMedium, TextSize = 13, TextColor3 = self.Window.Theme.Text
    })

    local ValueLabel = Utility:Create("TextLabel", {
        Parent = Frame, Text = tostring(savedVal),
        Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0, 8),
        BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamBold, TextSize = 13, TextColor3 = self.Window.Theme.Accent
    })

    local SlideBar = Utility:Create("TextButton", {
        Parent = Frame, Text = "", AutoButtonColor = false,
        Size = UDim2.new(1, -24, 0, 6), Position = UDim2.new(0, 12, 0, 36),
        BackgroundColor3 = self.Window.Theme.Stroke
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = SlideBar})
    
    local Fill = Utility:Create("Frame", {
        Parent = SlideBar, Size = UDim2.new((savedVal - min)/(max - min), 0, 1, 0),
        BackgroundColor3 = self.Window.Theme.Accent, BorderSizePixel = 0
    })
    Utility:Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Fill})

    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - SlideBar.AbsolutePosition.X) / SlideBar.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * pos)
        ValueLabel.Text = tostring(val)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        ConfigManager:SetValue(flag, val)
        if callback then callback(val) end
    end
    
    SlideBar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true Update(input) end end)
    Services.UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    Services.UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end end)
    
    if savedVal and callback then callback(savedVal) end
end

return Library
