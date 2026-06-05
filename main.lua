local ts = game:GetService("TweenService")
local ui = game:GetService("UserInputService")
local plr = game:GetService("Players")
local lg = game:GetService("Lighting")
local rs = game:GetService("RunService")
local gs = game:GetService("GuiService")
local hs = game:GetService("HttpService")
local lcs = game:GetService("LocalizationService")

local n = "Mithren"
local MITHREN_VERSION = "v2.0.5"
local CONFIG_SCHEMA_VERSION = "v2.0.0"
local CONFIG_ROOT = "MithrenConfigs_" .. CONFIG_SCHEMA_VERSION:gsub("[^%w_%-]", "_")

local c = {
	Background = Color3.fromRGB(10, 10, 11),
	Secondary = Color3.fromRGB(25, 25, 27),
	Border = Color3.fromRGB(47, 47, 51),
	ScrollBar = Color3.fromRGB(82, 82, 88),
	Text = Color3.fromRGB(255, 255, 255),
	TextDark = Color3.fromRGB(155, 155, 162),
	TextFade = Color3.fromRGB(42, 42, 46),
	Accent = Color3.fromRGB(255, 255, 255),
	Toggle = {
		Enabled = Color3.fromRGB(255, 255, 255),
		Disabled = Color3.fromRGB(62, 62, 68),
		Circle = Color3.fromRGB(245, 245, 247),
	},
	Notification = {
		Background = Color3.fromRGB(18, 18, 20),
		Border = Color3.fromRGB(46, 46, 50),
		Timer = Color3.fromRGB(255, 255, 255),
	},
}

local SKY_PRESETS = {
	["Sunset"] = {
		Bk = "rbxassetid://271042233",
		Dn = "rbxassetid://271042233",
		Ft = "rbxassetid://271042233",
		Lf = "rbxassetid://271042233",
		Rt = "rbxassetid://271042233",
		Up = "rbxassetid://271042596",
		Brightness = 1.5,
		ClockTime = 17,
		FogEnd = 100000,
	},
	["Starry night"] = {
		Bk = "rbxassetid://1012887",
		Dn = "rbxassetid://1012890",
		Ft = "rbxassetid://1012885",
		Lf = "rbxassetid://1012889",
		Rt = "rbxassetid://1012886",
		Up = "rbxassetid://1012888",
		StarCount = 5000,
		Brightness = 0.3,
		ClockTime = 0,
		FogEnd = 100000,
	},
	["Clear day"] = {
		Bk = "rbxassetid://600830446",
		Dn = "rbxassetid://600830446",
		Ft = "rbxassetid://600830446",
		Lf = "rbxassetid://600830446",
		Rt = "rbxassetid://600830446",
		Up = "rbxassetid://600830446",
		Brightness = 3,
		ClockTime = 14,
		FogEnd = 100000,
	},
	["Deep space"] = {
		Bk = "rbxassetid://159454286",
		Dn = "rbxassetid://159454299",
		Ft = "rbxassetid://159454293",
		Lf = "rbxassetid://159454296",
		Rt = "rbxassetid://159454300",
		Up = "rbxassetid://159454288",
		StarCount = 8000,
		Brightness = 0.1,
		ClockTime = 0,
		FogEnd = 100000,
	},
	["Soft pink"] = {
		Bk = "rbxassetid://271042596",
		Dn = "rbxassetid://271042596",
		Ft = "rbxassetid://271042596",
		Lf = "rbxassetid://271042596",
		Rt = "rbxassetid://271042596",
		Up = "rbxassetid://271042233",
		Brightness = 1.8,
		ClockTime = 18,
		FogEnd = 100000,
	},
	["Storm"] = {
		Bk = "rbxassetid://151165214",
		Dn = "rbxassetid://151165214",
		Ft = "rbxassetid://151165214",
		Lf = "rbxassetid://151165214",
		Rt = "rbxassetid://151165214",
		Up = "rbxassetid://151165214",
		Brightness = 0.8,
		ClockTime = 3,
		FogEnd = 100000,
	},
}

local SKY_OPTIONS = { "Sunset", "Starry night", "Clear day", "Deep space", "Soft pink", "Storm" }
local activeSkyOwner

local function ClonePalette(palette)
	local copy = {}
	for key, value in pairs(palette) do
		if type(value) == "table" then
			local sub = {}
			for k, v in pairs(value) do
				sub[k] = v
			end
			copy[key] = sub
		else
			copy[key] = value
		end
	end
	return copy
end

local function shallowCopyConfig(config)
	local copy = {}
	if type(config) == "table" then
		for key, value in pairs(config) do
			copy[key] = value
		end
	end
	return copy
end

local s = {
	v0rtexd = { Width = 690, Height = 446 },
	Minv0rtexd = { Width = 500, Height = 300 },
	Maxv0rtexd = { Width = 1200, Height = 800 },
	Toggle = { Width = 38, Height = 21, Circle = 13 },
	Button = { Height = 41 },
	Slider = { Height = 48 },
	Dropdown = { Height = 41, OptionHeight = 30 },
	Tab = { Width = 135, Height = 35 },
	ColorPicker = { Width = 180, Height = 160 },
	Notification = { Width = 220, Height = 70 },
	TextBox = { Height = 39, InputWidth = 150 },
}

local f = {
	Regular = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
	Bold = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
}

local textsize = {
	Title = 14,
	Normal = 14,
	Small = 13,
	Tiny = 11,
}

local animationspeed = {
	Fast = 0.1,
	Normal = 0.15,
	Slow = 0.2,
	VerySlow = 0.3,
}

local Library = {}
Library.__index = Library
Library.Lucide = nil
Library.MonochromeIcons = true

local Connections = {}

local function Track(owner, connection)
	if typeof(connection) ~= "RBXScriptConnection" then
		return connection
	end
	if type(owner) == "table" and owner._connections then
		table.insert(owner._connections, connection)
	else
		table.insert(Connections, connection)
	end
	return connection
end
local SerializeConfigValue, DeserializeConfigValue
local LucideModule = nil
local LucideIconObjects = {}
local LucideFallbackConnections = {}
local LucideIconsUrl = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"

local LucideAliases = {
	close = "x",
	cross = "x",
	minimize = "minus",
	dropdown = "chevron-down",
	arrow = "chevron-down",
	window = "app-window",
	config = "settings",
	configuration = "settings",
	text = "type",
	input = "type",
	notify = "bell",
	notification = "bell",
	resize = "grip",
	savefile = "save",
	world = "globe",
	language = "globe",
	languages = "globe",
}

local TabTransparency = {
	HoverOffset = 0.42,
}

local function CreateTween(instance, properties, duration, easingStyle, easingDirection)
	local tween = ts:Create(
		instance,
		TweenInfo.new(
			duration or animationspeed.Normal,
			easingStyle or Enum.EasingStyle.Quad,
			easingDirection or Enum.EasingDirection.Out
		),
		properties
	)
	tween:Play()
	return tween
end

local function CreateInstance(className, properties)
	local instance = Instance.new(className)
	for property, value in pairs(properties) do
		if property ~= "Parent" then
			instance[property] = value
		end
	end
	if properties.Parent then
		instance.Parent = properties.Parent
	end
	return instance
end

local function GetTabTransparency(lib, state)
	local base = (lib and lib._elementTransparency) or 0.18
	if state == "Active" then
		return base
	elseif state == "Hover" then
		return math.clamp(base + TabTransparency.HoverOffset, base, 0.95)
	end
	return 1
end

local function NormalizeLucideIconName(iconName)
	if type(iconName) ~= "string" then
		return nil
	end

	local name = iconName:gsub("^%s+", ""):gsub("%s+$", "")
	if name == "" then
		return nil
	end
	if name:match("^rbxassetid://") or name:match("^rbxthumb://") or name:match("^https?://") then
		return nil
	end

	name = name:gsub("_", "-"):gsub("%s+", "-"):lower()
	local iconPack, packedName = name:match("^([%w%-]+):(.+)$")
	if iconPack then
		if iconPack ~= "lucide" then
			return nil
		end
		name = packedName
	end
	return LucideAliases[name] or name
end

local function GetLucideModule()
	if Library.Lucide then
		if Library.Lucide.Creator and Library.Lucide.Creator.Icons then
			Library.Lucide = Library.Lucide.Creator.Icons
		elseif Library.Lucide.Icons and Library.Lucide.Icons.Icons then
			Library.Lucide = Library.Lucide.Icons
		end
		return Library.Lucide
	end
	if LucideModule then
		return LucideModule
	end
	if type(_G) == "table" and _G.WindUI and _G.WindUI.Creator and _G.WindUI.Creator.Icons then
		LucideModule = _G.WindUI.Creator.Icons
		return LucideModule
	end
	if type(_G) == "table" and _G.Lucide then
		LucideModule = _G.Lucide
		return LucideModule
	end

	local ok, module = pcall(function()
		local replicatedStorage = game:GetService("ReplicatedStorage")
		local candidate = replicatedStorage:FindFirstChild("Lucide")
		return candidate and require(candidate) or nil
	end)
	if ok and module then
		LucideModule = module
		if type(LucideModule.SetIconsType) == "function" then
			pcall(function()
				LucideModule.SetIconsType("lucide")
			end)
		end
		return LucideModule
	end

	ok, module = pcall(function()
		local sourceOk, source = pcall(function()
			return game:HttpGetAsync(LucideIconsUrl)
		end)
		if not sourceOk or type(source) ~= "string" or source == "" then
			sourceOk, source = pcall(function()
				return game:HttpGet(LucideIconsUrl)
			end)
		end
		if not sourceOk or type(source) ~= "string" or source == "" then
			sourceOk, source = pcall(function()
				return hs:GetAsync(LucideIconsUrl)
			end)
		end
		if not sourceOk or type(source) ~= "string" or source == "" then
			return nil
		end
		return source and loadstring(source)() or nil
	end)
	if ok and module then
		LucideModule = module
		if type(LucideModule.SetIconsType) == "function" then
			pcall(function()
				LucideModule.SetIconsType("lucide")
			end)
		end
		return LucideModule
	end

	return LucideModule
end

local function ReadLucideIconAsset(lucide, iconName, iconSize)
	if not lucide or not iconName then
		return nil
	end

	if type(lucide.GetAsset) == "function" then
		local ok, asset = pcall(function()
			return lucide.GetAsset(iconName, iconSize or 48)
		end)
		if ok and type(asset) == "table" then
			return {
				Image = asset.Url or (asset.Id and ("rbxassetid://" .. tostring(asset.Id))),
				ImageRectOffset = asset.ImageRectOffset,
				ImageRectSize = asset.ImageRectSize,
			}
		end
	end

	local iconData
	if type(lucide.Icon2) == "function" then
		local ok, result = pcall(function()
			return lucide.Icon2(iconName, "lucide", true)
		end)
		if ok then
			iconData = result
		end
	end
	if not iconData and type(lucide.Icon) == "function" then
		local ok, result = pcall(function()
			return lucide.Icon(iconName, "lucide", true)
		end)
		if ok then
			iconData = result
		end
	end

	if type(iconData) == "string" then
		return {
			Image = iconData,
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(0, 0),
		}
	elseif type(iconData) == "table" and iconData[1] and iconData[2] then
		local image = iconData[1]
		if type(image) == "number" then
			image = "rbxassetid://" .. tostring(image)
		end
		return {
			Image = image,
			ImageRectOffset = iconData[2].ImageRectPosition or iconData[2].ImageRectOffset or Vector2.new(0, 0),
			ImageRectSize = iconData[2].ImageRectSize or Vector2.new(0, 0),
		}
	end

	local iconSet = lucide.Icons and lucide.Icons.lucide
	local entry = iconSet and iconSet.Icons and iconSet.Icons[iconName]
	if entry then
		local image = (iconSet.Spritesheets and iconSet.Spritesheets[tostring(entry.Image)]) or entry.Image
		if type(image) == "number" then
			image = "rbxassetid://" .. tostring(image)
		end
		return {
			Image = image,
			ImageRectOffset = entry.ImageRectPosition or entry.ImageRectOffset or Vector2.new(0, 0),
			ImageRectSize = entry.ImageRectSize or Vector2.new(0, 0),
		}
	end

	return nil
end

local function ClearLucideFallback(imageObject)
	if LucideFallbackConnections[imageObject] then
		LucideFallbackConnections[imageObject]:Disconnect()
		LucideFallbackConnections[imageObject] = nil
	end
	local existing = imageObject:FindFirstChild("LucideFallback")
	if existing then
		existing:Destroy()
	end
end

local function DrawLucideLine(parent, x, y, width, thickness, rotation)
	local iconColor = parent.Parent and parent.Parent.ImageColor3 or c.TextDark
	local line = CreateInstance("Frame", {
		Name = "Line",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = iconColor,
		BorderSizePixel = 0,
		Position = UDim2.new(x, 0, y, 0),
		Rotation = rotation or 0,
		Size = UDim2.new(width, 0, 0, thickness or 2),
		ZIndex = parent.ZIndex + 1,
		Parent = parent,
	})
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 2),
		Parent = line,
	})
	return line
end

local function DrawLucideDot(parent, x, y)
	local iconColor = parent.Parent and parent.Parent.ImageColor3 or c.TextDark
	local dot = CreateInstance("Frame", {
		Name = "Dot",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = iconColor,
		BorderSizePixel = 0,
		Position = UDim2.new(x, 0, y, 0),
		Size = UDim2.new(0, 2, 0, 2),
		ZIndex = parent.ZIndex + 1,
		Parent = parent,
	})
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 10),
		Parent = dot,
	})
	return dot
end

local function DrawLucideRect(parent, x, y, width, height)
	local iconColor = parent.Parent and parent.Parent.ImageColor3 or c.TextDark
	local box = CreateInstance("Frame", {
		Name = "Box",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(x, 0, y, 0),
		Size = UDim2.new(width, 0, height, 0),
		ZIndex = parent.ZIndex + 1,
		Parent = parent,
	})
	local stroke = CreateInstance("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = iconColor,
		Thickness = 1.5,
		Parent = box,
	})
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, 2),
		Parent = box,
	})
	return box, stroke
end

local function DrawLucideCircle(parent, x, y, size)
	local iconColor = parent.Parent and parent.Parent.ImageColor3 or c.TextDark
	local circle = CreateInstance("Frame", {
		Name = "Circle",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(x, 0, y, 0),
		Size = UDim2.new(size, 0, size, 0),
		ZIndex = parent.ZIndex + 1,
		Parent = parent,
	})
	local stroke = CreateInstance("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = iconColor,
		Thickness = 1.5,
		Parent = circle,
	})
	CreateInstance("UICorner", {
		CornerRadius = UDim.new(1, 0),
		Parent = circle,
	})
	return circle, stroke
end

local function CreateLucideFallback(imageObject, iconName)
	ClearLucideFallback(imageObject)
	imageObject.Image = ""
	imageObject.ImageTransparency = 1

	local holder = CreateInstance("Frame", {
		Name = "LucideFallback",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = imageObject.ZIndex + 1,
		Parent = imageObject,
	})

	local name = NormalizeLucideIconName(iconName) or "app-window"
	if name == "x" then
		DrawLucideLine(holder, 0.5, 0.5, 0.9, 2, 45)
		DrawLucideLine(holder, 0.5, 0.5, 0.9, 2, -45)
	elseif name == "check" then
		DrawLucideLine(holder, 0.4, 0.58, 0.38, 2, 45)
		DrawLucideLine(holder, 0.62, 0.5, 0.62, 2, -45)
	elseif name == "minus" then
		DrawLucideLine(holder, 0.5, 0.5, 0.75, 2, 0)
	elseif name == "chevron-down" then
		DrawLucideLine(holder, 0.36, 0.48, 0.46, 2, 45)
		DrawLucideLine(holder, 0.64, 0.48, 0.46, 2, -45)
	elseif name == "grip" then
		for _, x in ipairs({ 0.36, 0.5, 0.64 }) do
			for _, y in ipairs({ 0.36, 0.5, 0.64 }) do
				DrawLucideDot(holder, x, y)
			end
		end
	elseif name == "save" then
		DrawLucideRect(holder, 0.5, 0.5, 0.78, 0.78)
		DrawLucideLine(holder, 0.5, 0.33, 0.44, 2, 0)
		DrawLucideLine(holder, 0.5, 0.7, 0.44, 2, 0)
	elseif name == "bell" then
		DrawLucideLine(holder, 0.5, 0.38, 0.45, 2, 0)
		DrawLucideLine(holder, 0.34, 0.53, 0.42, 2, 82)
		DrawLucideLine(holder, 0.66, 0.53, 0.42, 2, -82)
		DrawLucideLine(holder, 0.5, 0.74, 0.55, 2, 0)
		DrawLucideDot(holder, 0.5, 0.87)
	elseif name == "globe" then
		DrawLucideCircle(holder, 0.5, 0.5, 0.72)
		DrawLucideLine(holder, 0.5, 0.5, 0.72, 2, 0)
		DrawLucideLine(holder, 0.5, 0.5, 0.72, 2, 90)
		DrawLucideLine(holder, 0.5, 0.34, 0.5, 2, 0)
		DrawLucideLine(holder, 0.5, 0.66, 0.5, 2, 0)
	elseif name == "palette" then
		DrawLucideRect(holder, 0.5, 0.5, 0.78, 0.62)
		DrawLucideDot(holder, 0.35, 0.42)
		DrawLucideDot(holder, 0.5, 0.34)
		DrawLucideDot(holder, 0.64, 0.45)
	elseif name == "crosshair" then
		DrawLucideCircle(holder, 0.5, 0.5, 0.58)
		DrawLucideLine(holder, 0.5, 0.18, 0.2, 2, 90)
		DrawLucideLine(holder, 0.5, 0.82, 0.2, 2, 90)
		DrawLucideLine(holder, 0.18, 0.5, 0.2, 2, 0)
		DrawLucideLine(holder, 0.82, 0.5, 0.2, 2, 0)
		DrawLucideDot(holder, 0.5, 0.5)
	elseif name == "eye" then
		DrawLucideLine(holder, 0.36, 0.5, 0.42, 2, 28)
		DrawLucideLine(holder, 0.64, 0.5, 0.42, 2, -28)
		DrawLucideLine(holder, 0.36, 0.5, 0.42, 2, -28)
		DrawLucideLine(holder, 0.64, 0.5, 0.42, 2, 28)
		DrawLucideCircle(holder, 0.5, 0.5, 0.22)
	elseif name == "scan" then
		DrawLucideLine(holder, 0.3, 0.22, 0.28, 2, 0)
		DrawLucideLine(holder, 0.22, 0.3, 0.28, 2, 90)
		DrawLucideLine(holder, 0.7, 0.22, 0.28, 2, 0)
		DrawLucideLine(holder, 0.78, 0.3, 0.28, 2, 90)
		DrawLucideLine(holder, 0.3, 0.78, 0.28, 2, 0)
		DrawLucideLine(holder, 0.22, 0.7, 0.28, 2, 90)
		DrawLucideLine(holder, 0.7, 0.78, 0.28, 2, 0)
		DrawLucideLine(holder, 0.78, 0.7, 0.28, 2, 90)
	elseif name == "sparkles" then
		DrawLucideLine(holder, 0.42, 0.42, 0.45, 2, 0)
		DrawLucideLine(holder, 0.42, 0.42, 0.45, 2, 90)
		DrawLucideLine(holder, 0.42, 0.42, 0.36, 2, 45)
		DrawLucideLine(holder, 0.42, 0.42, 0.36, 2, -45)
		DrawLucideLine(holder, 0.72, 0.72, 0.24, 2, 0)
		DrawLucideLine(holder, 0.72, 0.72, 0.24, 2, 90)
	elseif name == "keyboard" then
		DrawLucideRect(holder, 0.5, 0.5, 0.82, 0.56)
		for _, x in ipairs({ 0.32, 0.44, 0.56, 0.68 }) do
			DrawLucideDot(holder, x, 0.42)
		end
		DrawLucideLine(holder, 0.5, 0.62, 0.42, 2, 0)
	elseif name == "type" then
		DrawLucideLine(holder, 0.5, 0.28, 0.8, 2, 0)
		DrawLucideLine(holder, 0.5, 0.55, 0.62, 2, 90)
		DrawLucideLine(holder, 0.5, 0.82, 0.38, 2, 0)
	elseif name == "blocks" then
		DrawLucideRect(holder, 0.38, 0.38, 0.34, 0.34)
		DrawLucideRect(holder, 0.62, 0.38, 0.34, 0.34)
		DrawLucideRect(holder, 0.5, 0.64, 0.34, 0.34)
	elseif name == "mouse-pointer-click" then
		DrawLucideLine(holder, 0.42, 0.48, 0.78, 2, 62)
		DrawLucideLine(holder, 0.58, 0.64, 0.34, 2, -32)
		DrawLucideLine(holder, 0.66, 0.38, 0.24, 2, 0)
	else
		DrawLucideRect(holder, 0.5, 0.5, 0.72, 0.72)
		DrawLucideLine(holder, 0.5, 0.35, 0.42, 2, 0)
	end

	local function syncColor()
		local iconColor = imageObject.ImageColor3
		for _, child in ipairs(holder:GetDescendants()) do
			if child:IsA("Frame") then
				child.BackgroundColor3 = iconColor
			elseif child:IsA("UIStroke") then
				child.Color = iconColor
			end
		end
	end
	syncColor()
	task.defer(syncColor)
	LucideFallbackConnections[imageObject] = imageObject:GetPropertyChangedSignal("ImageColor3"):Connect(syncColor)
	return false
end

local function ApplyLucideIcon(imageObject, iconName, fallbackName, iconSize, skipRegister)
	local resolvedName = NormalizeLucideIconName(iconName) or NormalizeLucideIconName(fallbackName)
	if not skipRegister then
		table.insert(LucideIconObjects, {
			Object = imageObject,
			Icon = iconName,
			Fallback = fallbackName,
			Size = iconSize,
		})
	end
	imageObject:SetAttribute("LucideIcon", resolvedName or "")
	imageObject.ImageRectOffset = Vector2.new(0, 0)
	imageObject.ImageRectSize = Vector2.new(0, 0)

	local asset
	asset = ReadLucideIconAsset(GetLucideModule(), resolvedName, iconSize)
	if not asset and resolvedName ~= NormalizeLucideIconName(fallbackName) then
		asset = ReadLucideIconAsset(GetLucideModule(), NormalizeLucideIconName(fallbackName), iconSize)
	end
	if not asset or type(asset.Image) ~= "string" or asset.Image == "" then
		return CreateLucideFallback(imageObject, resolvedName)
	end

	ClearLucideFallback(imageObject)
	imageObject.ImageTransparency = 0
	imageObject.Image = asset.Image
	if typeof(asset.ImageRectOffset) == "Vector2" then
		imageObject.ImageRectOffset = asset.ImageRectOffset
	end
	if typeof(asset.ImageRectSize) == "Vector2" then
		imageObject.ImageRectSize = asset.ImageRectSize
	end
	return true
end

local function RefreshLucideIcons()
	for index = #LucideIconObjects, 1, -1 do
		local data = LucideIconObjects[index]
		if data.Object and data.Object.Parent then
			ApplyLucideIcon(data.Object, data.Icon, data.Fallback, data.Size, true)
		else
			table.remove(LucideIconObjects, index)
		end
	end
end

local function PruneLucideRegistry()
	for index = #LucideIconObjects, 1, -1 do
		local data = LucideIconObjects[index]
		if not data.Object or not data.Object.Parent then
			table.remove(LucideIconObjects, index)
		end
	end
	for imageObject, connection in pairs(LucideFallbackConnections) do
		if not imageObject or not imageObject.Parent then
			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			end
			LucideFallbackConnections[imageObject] = nil
		end
	end
end

function Library.SetLucideModule(module)
	if module and module.Creator and module.Creator.Icons then
		module = module.Creator.Icons
	elseif module and module.Icons and module.Icons.Icons then
		module = module.Icons
	end
	Library.Lucide = module
	LucideModule = module
	if LucideModule and type(LucideModule.SetIconsType) == "function" then
		pcall(function()
			LucideModule.SetIconsType("lucide")
		end)
	end
	RefreshLucideIcons()
end

function Library.SetMonochromeIcons(enabled)
	Library.MonochromeIcons = enabled ~= false
	RefreshLucideIcons()
end

local function CreateCorner(parent, radius)
	return CreateInstance("UICorner", {
		CornerRadius = UDim.new(0, radius or 8),
		Parent = parent,
	})
end

local function CreateStroke(parent, color, transparency)
	return CreateInstance("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color or c.Border,
		Transparency = transparency or 0.35,
		Thickness = 1,
		Parent = parent,
	})
end

local function CreatePadding(parent, top, bottom, left, right)
	return CreateInstance("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		Parent = parent,
	})
end

local function CreateListLayout(parent, padding, sortOrder, direction)
	return CreateInstance("UIListLayout", {
		Padding = UDim.new(0, padding or 0),
		SortOrder = sortOrder or Enum.SortOrder.LayoutOrder,
		FillDirection = direction or Enum.FillDirection.Vertical,
		Parent = parent,
	})
end

local function ResolveElementParent(tab, config)
	config = type(config) == "table" and config or {}
	return config.Parent or (tab and tab.content)
end

local function IsComponentRowParent(parent)
	return parent and parent:GetAttribute("MithrenComponentRow") == true
end

local function GetComponentRowColumns(parent)
	if not IsComponentRowParent(parent) then
		return 1
	end
	return tonumber(parent:GetAttribute("MithrenComponentRowColumns")) or 1
end

local function ResolveElementSize(config, parent, height)
	config = type(config) == "table" and config or {}
	if config.WidthScale then
		return UDim2.new(config.WidthScale, config.WidthOffset or 0, 0, height)
	end
	if IsComponentRowParent(parent) then
		return UDim2.new(1, 0, 0, height)
	end
	return UDim2.new(1, 0, 0, height)
end

local function IsCompactElement(config, parent)
	return (type(config) == "table" and config.Compact == true) or IsComponentRowParent(parent)
end

local function IsDenseCompactElement(config, parent)
	return IsCompactElement(config, parent) and GetComponentRowColumns(parent) >= 3
end

local function IsMobileDevice()
	return ui.TouchEnabled and not ui.KeyboardEnabled
end

local function ResolveKeyCode(value, fallback)
	if typeof(value) == "EnumItem" and value.EnumType == Enum.KeyCode then
		return value
	end
	if type(value) == "string" then
		local ok, keyCode = pcall(function()
			return Enum.KeyCode[value]
		end)
		if ok and keyCode then
			return keyCode
		end
	end
	return fallback or Enum.KeyCode.Unknown
end

local function ResolveKeybindInput(value, fallback)
	if typeof(value) == "EnumItem" then
		if value.EnumType == Enum.KeyCode then
			return value
		end
		if value.EnumType == Enum.UserInputType then
			local btnNum = tonumber(value.Name:match("^MouseButton(%d+)$"))
			if btnNum ~= nil and btnNum > 3 then
				return value
			end
		end
	end
	return ResolveKeyCode(value, fallback)
end

local function FormatKeyCode(keyCode)
	keyCode = ResolveKeyCode(keyCode)
	if keyCode == Enum.KeyCode.Unknown then
		return ""
	end
	return keyCode.Name
end

local function FormatKeybindInput(key)
	if not key then
		return ""
	end
	if typeof(key) == "EnumItem" then
		if key.EnumType == Enum.KeyCode then
			return FormatKeyCode(key)
		elseif key.EnumType == Enum.UserInputType then
			local n = key.Name:match("^MouseButton(%d+)$")
			return n and ("M" .. n) or key.Name
		end
	end
	return ""
end

local function GetViewportSize()
	local camera = workspace.CurrentCamera
	if camera then
		return camera.ViewportSize
	end
	return Vector2.new(800, 600)
end

local function GetResponsiveWindowMetrics()
	local viewport = GetViewportSize()
	local width = s.v0rtexd.Width
	local height = s.v0rtexd.Height
	local minWidth = s.Minv0rtexd.Width
	local minHeight = s.Minv0rtexd.Height
	local maxWidth = s.Maxv0rtexd.Width
	local maxHeight = s.Maxv0rtexd.Height

	if IsMobileDevice() then
		width = math.floor(math.clamp(viewport.X - 24, 320, s.v0rtexd.Width))
		height = math.floor(math.clamp(viewport.Y - 86, 300, s.v0rtexd.Height))
		minWidth = math.min(320, width)
		minHeight = math.min(260, height)
		maxWidth = math.max(width, math.floor(math.max(viewport.X - 16, minWidth)))
		maxHeight = math.max(height, math.floor(math.max(viewport.Y - 70, minHeight)))
	end

	return {
		Width = width,
		Height = height,
		Min = Vector2.new(minWidth, minHeight),
		Max = Vector2.new(maxWidth, maxHeight),
	}
end

local function MakeDraggable(frame, handle, owner)
	local dragging = false
	local dragInput, dragStart, startPos
	handle = handle or frame

	local function OnInputBegan(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if connection then
						connection:Disconnect()
					end
				end
			end)
		end
	end

	local function OnInputChanged(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragInput = input
		end
	end

	handle.InputBegan:Connect(OnInputBegan)
	handle.InputChanged:Connect(OnInputChanged)

	Track(
		owner,
		ui.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - dragStart
				frame.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	)
end

local function DisconnectAll(owner)
	local list = (type(owner) == "table" and owner._connections) or Connections
	for key, connection in pairs(list) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
		list[key] = nil
	end
end

local function SanitizeConfigName(value)
	local text = tostring(value or "default")
	text = text:gsub('[\\/:*?"<>|]', "_"):gsub("^%s+", ""):gsub("%s+$", "")
	if text == "" then
		text = "default"
	end
	return text
end

local function GetConfigRoot(configFolder)
	return CONFIG_ROOT .. "/" .. SanitizeConfigName(configFolder or "Mithren")
end

local function GetConfigPath(configFolder, configName)
	return GetConfigRoot(configFolder) .. "/" .. SanitizeConfigName(configName) .. ".json"
end

local function EnsureConfigFolder(configFolder)
	if isfolder and makefolder and not isfolder(CONFIG_ROOT) then
		makefolder(CONFIG_ROOT)
	end
	local root = GetConfigRoot(configFolder)
	if isfolder and makefolder and not isfolder(root) then
		makefolder(root)
	end
	return root
end

local function GetAvailableConfigs(configFolder)
	local configs = {}
	if isfolder and listfiles then
		local root = EnsureConfigFolder(configFolder)
		local files = listfiles(root)
		for _, file in ipairs(files) do
			local name = file:match("[/\\]([^/\\]+)%.json$")
			if name and name ~= "__session" then
				table.insert(configs, name)
			end
		end
	end
	return configs
end

local function NormalizeLanguageCode(language)
	local text = tostring(language or ""):lower():gsub("_", "-")
	local code = text:match("^%s*([%a][%a]?)")
	if code == "sp" then
		return "es"
	end
	return code or ""
end

local LANGUAGE_DISPLAY_NAMES = {
	ar = "Arabic",
	de = "German",
	en = "English",
	es = "Spanish",
	fr = "French",
	it = "Italian",
	ja = "Japanese",
	ko = "Korean",
	pt = "Portuguese",
	ru = "Russian",
	tr = "Turkish",
	zh = "Chinese",
}

local function GetLanguageDisplayName(value, fallback)
	local code = NormalizeLanguageCode(value)
	if code ~= "" and LANGUAGE_DISPLAY_NAMES[code] then
		return LANGUAGE_DISPLAY_NAMES[code]
	end
	return tostring(fallback or value or "")
end

local function GetSystemLanguageCode(fallback)
	local ok, locale = pcall(function()
		return lcs.SystemLocaleId
	end)
	local code = ok and NormalizeLanguageCode(locale) or ""
	if code == "" then
		code = NormalizeLanguageCode(fallback or "en")
	end
	return code ~= "" and code or "en"
end

local function NormalizeLanguageOption(option)
	if type(option) == "table" then
		local value = option.Value or option.Code or option.Id or option.Name or option.Label or option[1]
		local label = option.Label or option.Name or option.Title or value
		return {
			Label = GetLanguageDisplayName(value, label),
			Value = value ~= nil and tostring(value) or tostring(label or ""),
			Raw = option,
		}
	end
	return {
		Label = GetLanguageDisplayName(option, option),
		Value = tostring(option or ""),
		Raw = option,
	}
end

local function ResolveLanguageValue(language, options)
	local rawOption = NormalizeLanguageOption(language)
	local rawValue = rawOption.Value
	local rawLabel = rawOption.Label
	if type(options) == "table" then
		for _, option in ipairs(options) do
			local normalized = NormalizeLanguageOption(option)
			if normalized.Value == rawValue or normalized.Label == rawValue or normalized.Value == rawLabel or normalized.Label == rawLabel then
				return normalized.Value, normalized
			end
		end
	end
	return rawValue, rawOption
end

local function GetLanguageCachePath(configFolder, language)
	return GetConfigRoot(configFolder) .. "/localization_" .. SanitizeConfigName(language) .. ".json"
end

local function ReadJsonFile(path)
	if not readfile or not isfile or not isfile(path) then
		return nil
	end
	local ok, content = pcall(readfile, path)
	if not ok or type(content) ~= "string" or content == "" then
		return nil
	end
	local decodedOk, decoded = pcall(function()
		return hs:JSONDecode(content)
	end)
	return decodedOk and decoded or nil
end

local function WriteJsonFile(configFolder, path, value)
	if not writefile then
		return false
	end
	EnsureConfigFolder(configFolder)
	local ok = pcall(function()
		writefile(path, hs:JSONEncode(value))
	end)
	return ok
end

local AcrylicBlur = {}
AcrylicBlur.__index = AcrylicBlur

function AcrylicBlur.new(object)
	local self = setmetatable({
		_object = object,
		_folder = nil,
		_root = nil,
		_frame = nil,
		_dof = nil,
		_enabled = true,
		_conns = {},
	}, AcrylicBlur)
	self:_Initialize()
	return self
end

function AcrylicBlur:_CreateDepthOfField()
	local existingDOF = lg:FindFirstChild("AcrylicBlur")
	if existingDOF then
		existingDOF:Destroy()
	end
	local existingBlur = lg:FindFirstChild("AcrylicBlurEffect")
	if existingBlur then
		existingBlur:Destroy()
	end

	local dof = CreateInstance("DepthOfFieldEffect", {
		Name = "AcrylicBlur",
		FarIntensity = 0,
		FocusDistance = 0.05,
		InFocusRadius = 0.1,
		NearIntensity = 0.5,
		Parent = lg,
	})

	self._dof = dof
	return dof
end

function AcrylicBlur:_CreateFolder()
	local existingFolder = workspace.CurrentCamera:FindFirstChild("AcrylicBlur")
	if existingFolder then
		existingFolder:Destroy()
	end
	self._folder = CreateInstance("Folder", {
		Name = "AcrylicBlur",
		Parent = workspace.CurrentCamera,
	})
end

function AcrylicBlur:_CreateRoot()
	local part = CreateInstance("Part", {
		Name = "Root",
		Color = Color3.new(0, 0, 0),
		Material = Enum.Material.Glass,
		Size = Vector3.new(1, 1, 0),
		Anchored = true,
		CanCollide = false,
		CanQuery = false,
		Locked = true,
		CastShadow = false,
		Transparency = 0.95,
		Parent = self._folder,
	})
	CreateInstance("SpecialMesh", {
		MeshType = Enum.MeshType.Brick,
		Parent = part,
	})
	self._root = part
end

function AcrylicBlur:_CreateFrame()
	self._frame = CreateInstance("Frame", {
		Size = UDim2.new(1, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = self._object,
	})
end

function AcrylicBlur:_Render(distance)
	distance = distance or 0.001
	local positions = {
		top_left = Vector2.new(),
		top_right = Vector2.new(),
		bottom_right = Vector2.new(),
	}

	local function ViewportToWorld(location, dist)
		local ray = workspace.CurrentCamera:ScreenPointToRay(location.X, location.Y)
		return ray.Origin + ray.Direction * dist
	end

	local function GetOffset()
		local viewY = workspace.CurrentCamera.ViewportSize.Y
		return (viewY / 2560) * 24 + 4
	end

	local function UpdatePositions(size, position)
		positions.top_left = position
		positions.top_right = position + Vector2.new(size.X, 0)
		positions.bottom_right = position + size
	end

	local function Update()
		if not self._root or not self._enabled then
			return
		end
		local tl = ViewportToWorld(positions.top_left, distance)
		local tr = ViewportToWorld(positions.top_right, distance)
		local br = ViewportToWorld(positions.bottom_right, distance)
		local width = (tr - tl).Magnitude
		local height = (tr - br).Magnitude
		self._root.CFrame = CFrame.fromMatrix(
			(tl + br) / 2,
			workspace.CurrentCamera.CFrame.XVector,
			workspace.CurrentCamera.CFrame.YVector,
			workspace.CurrentCamera.CFrame.ZVector
		)
		self._root.Mesh.Scale = Vector3.new(width, height, 0)
	end

	local function OnChange()
		if not self._enabled then
			return
		end
		local offset = GetOffset()
		local size = self._frame.AbsoluteSize - Vector2.new(offset, offset)
		local position = self._frame.AbsolutePosition + Vector2.new(offset / 2, offset / 2)
		UpdatePositions(size, position)
		task.spawn(Update)
	end

	table.insert(self._conns, workspace.CurrentCamera:GetPropertyChangedSignal("CFrame"):Connect(Update))
	table.insert(self._conns, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(Update))
	table.insert(self._conns, workspace.CurrentCamera:GetPropertyChangedSignal("FieldOfView"):Connect(Update))
	table.insert(self._conns, self._frame:GetPropertyChangedSignal("AbsolutePosition"):Connect(OnChange))
	table.insert(self._conns, self._frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(OnChange))
	table.insert(self._conns, rs.RenderStepped:Connect(Update))
	task.spawn(OnChange)
end

function AcrylicBlur:_Initialize()
	self:_CreateDepthOfField()
	self:_CreateFolder()
	self:_CreateRoot()
	self:_CreateFrame()
	self:_Render(0.001)
end

function AcrylicBlur:SetEnabled(enabled)
	self._enabled = enabled
	if self._root then
		self._root.Transparency = enabled and 0.95 or 1
	end
	if self._dof then
		self._dof.Enabled = enabled
	end
end

function AcrylicBlur:Destroy()
	self._enabled = false
	for _, connection in ipairs(self._conns) do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		end
	end
	self._conns = {}
	if self._folder then
		self._folder:Destroy()
	end
	local dof = lg:FindFirstChild("AcrylicBlur")
	if dof then
		dof:Destroy()
	end
	local blur = lg:FindFirstChild("AcrylicBlurEffect")
	if blur then
		blur:Destroy()
	end
	self._folder = nil
	self._root = nil
	self._frame = nil
	self._dof = nil
end

local function EnsureNotificationContainer(self)
	if self._notificationContainer and self._notificationContainer.Parent then
		return self._notificationContainer
	end
	self._notificationContainer = CreateInstance("Frame", {
		Name = "NotificationContainer",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -240, 0, 20),
		Size = UDim2.new(0, 220, 1, -40),
		Parent = self.screenGui,
	})
	CreateListLayout(self._notificationContainer, 10, Enum.SortOrder.LayoutOrder, Enum.FillDirection.Vertical)
	return self._notificationContainer
end

local function ParentScreenGui(screenGui)
	local ok = pcall(function()
		if typeof(gethui) == "function" then
			screenGui.Parent = gethui()
			return
		end
		if syn and typeof(syn.protect_gui) == "function" then
			syn.protect_gui(screenGui)
			screenGui.Parent = game:GetService("CoreGui")
			return
		end
		if typeof(protect_gui) == "function" then
			protect_gui(screenGui)
			screenGui.Parent = game:GetService("CoreGui")
			return
		end
		screenGui.Parent = game:GetService("CoreGui")
	end)
	if ok and screenGui.Parent then
		return
	end
	local player = plr.LocalPlayer
	screenGui.Parent = player:WaitForChild("PlayerGui")
end

function Library.new(title, configFolder, config)
	if type(title) == "table" then
		config = title
		title = config.Title or config.Name
		configFolder = config.ConfigFolder or config.Folder
	elseif type(configFolder) == "table" then
		config = configFolder
		configFolder = config.ConfigFolder or config.Folder
	end
	config = config or {}

	local instanceKey = "MithrenLib_" .. (title or "Mithren")
	if _G[instanceKey] then
		local existing = _G[instanceKey]
		if existing.screenGui and existing.screenGui.Parent then
			if not existing._visible then
				existing:Toggle()
			end
			local noop = {}
			setmetatable(noop, {
				__index = function()
					return function()
						return noop
					end
				end,
			})
			return noop
		end
	end

	local self = setmetatable({}, Library)

	self._c = ClonePalette(c)
	self._connections = {}
	self._activeDropdown = nil
	self._activePicker = nil
	self._notificationContainer = nil
	self._capturingKeybind = false
	local metrics = GetResponsiveWindowMetrics()
	self.title = title or "Mithren"
	self.versionTag = config.VersionTag or config.Version or config.Tag
	self._instanceKey = instanceKey
	self.configFolder = configFolder or title or "Mithren"
	self.sections = {}
	self.currentTab = nil
	self.minimized = false
	self._acrylicBlur = nil
	self._acrylicBlurEnabled = false
	self._keybinds = {}
	self._toggleKey = Enum.KeyCode.RightControl
	self._visible = true
	self._originalHeight = metrics.Height
	self._windowSize = Vector2.new(metrics.Width, metrics.Height)
	self._minSize = metrics.Min
	self._maxSize = metrics.Max
	self._mobileToggle = nil
	self._configElements = {}
	self._autoSave = true
	self._currentConfig = "default"
	self._isLoading = false
	self._autoSavePending = false
	self._elementTransparency = 0.18
	self._notificationsEnabled = config.NotificationsEnabled ~= false
	local localizationConfig = config.Localization or config.I18n or config.I18nConfig
	local localizationOptions = type(localizationConfig) == "table"
			and (localizationConfig.Options or localizationConfig.Languages or localizationConfig.LanguageOptions)
		or nil
	local localizationDefault = type(localizationConfig) == "table"
			and (localizationConfig.Default or localizationConfig.DefaultLanguage or localizationConfig.Language)
		or nil
	if type(localizationConfig) == "table" and localizationConfig.AutoDetect ~= false then
		localizationDefault = GetSystemLanguageCode(localizationDefault or localizationConfig.Fallback or "en")
	end

	local languageSelector = config.LanguageSelector
	local languageOptions = config.Languages or config.LanguageOptions
	local languageDefault = config.DefaultLanguage or config.Language or localizationDefault
	if type(languageSelector) == "table" then
		languageOptions = languageSelector.Options
			or languageSelector.Languages
			or languageSelector.LanguageOptions
			or languageOptions
			or localizationOptions
		languageDefault = languageSelector.Default
			or languageSelector.DefaultLanguage
			or languageSelector.Language
			or languageDefault
		self._languageCallback = languageSelector.Callback
			or languageSelector.OnChanged
			or languageSelector.OnLanguageChanged
			or config.OnLanguageChanged
			or config.LanguageCallback
		self._languageSelectorAlwaysVisible = languageSelector.AlwaysVisible == true
		self._languageSelectorIcon = languageSelector.Icon or "globe"
	else
		self._languageCallback = config.OnLanguageChanged or config.LanguageCallback
		self._languageSelectorAlwaysVisible = config.LanguageSelectorAlwaysVisible == true
		self._languageSelectorIcon = config.LanguageSelectorIcon or "globe"
	end
	languageOptions = languageOptions or localizationOptions
	self._languageOptions = languageSelector == false and nil or languageOptions
	local savedLanguage = ReadJsonFile(GetConfigPath(self.configFolder, "__language"))
	if type(savedLanguage) == "table" and savedLanguage.Language ~= nil then
		languageDefault = savedLanguage.Language
	end
	if languageDefault ~= nil and self._languageOptions then
		languageDefault = ResolveLanguageValue(languageDefault, self._languageOptions)
	end
	self._language = languageDefault
	self._localization = nil
	self._restartConfig = config.Restart or config.Reexecute
	if type(localizationConfig) == "table" then
		self:ConfigureLocalization(localizationConfig, true)
	end
	self._theme = {
		AccentColor = c.Accent,
		BackgroundColor = c.Background,
		SecondaryColor = c.Secondary,
		BorderColor = c.Border,
		TextColor = c.Text,
		MutedTextColor = c.TextDark,
		ScrollBarColor = c.ScrollBar,
		PanelTransparency = 0.03,
		ElementTransparency = self._elementTransparency,
		BackgroundImage = "",
		BackgroundImageEnabled = false,
		BackgroundDim = 0.45,
		AcrylicBlurEnabled = self._acrylicBlurEnabled,
		SkyEnabled = false,
		SkyPreset = "Starry night",
	}
	if self._localization then
		if self._localization.Fallback and self._localization.Fallback ~= self._language then
			self:LoadLanguage(self._localization.Fallback)
		end
		self:LoadLanguage(self._language)
	end
	if readfile and isfile and DeserializeConfigValue then
		local path = GetConfigPath(self.configFolder, "__session")
		if isfile(path) then
			local success, data = pcall(function()
				return hs:JSONDecode(readfile(path))
			end)
			if success and type(data) == "table" and data.__theme then
				self:SetTheme(DeserializeConfigValue(data.__theme))
			end
			if success and type(data) == "table" and data.__window then
				local windowState = DeserializeConfigValue(data.__window)
				if type(windowState) == "table" then
					local width = tonumber(windowState.Width or windowState.width)
					local height = tonumber(windowState.Height or windowState.height)
					if width and height then
						width = math.clamp(width, self._minSize.X, self._maxSize.X)
						height = math.clamp(height, self._minSize.Y, self._maxSize.Y)
						self._windowSize = Vector2.new(width, height)
						self._originalHeight = height
					end
				end
			end
		end
	end
	self:_CreateMainv0rtexd()
	self:_CreateSystemTabs()
	self:_SetupKeybindListener()
	self:_SetupMobileSupport()
	EnsureNotificationContainer(self)
	_G[instanceKey] = self
	task.defer(function()
		if readfile and isfile then
			local path = GetConfigPath(self.configFolder, "__session")
			if isfile(path) then
				self:LoadConfig("__session", true)
			end
		end
	end)
	return self
end

function Library.Window(a, b)
	local config
	if a == Library then
		config = b
	else
		config = a
	end
	return Library.new(config)
end

function Library:Section(name)
	return self:CreateSection(name)
end

function Library:Notify(config)
	if self._isDestroying then
		return nil
	end
	if self._notificationsEnabled == false and not (type(config) == "table" and config.Force == true) then
		return nil
	end
	config = type(config) == "table" and config or {}
	local c = self._c or c
	local title = config.Title or "Notification"
	local description = config.Description or ""
	local duration = config.Duration or 3
	local icon = config.Icon or "bell"

	local notification = CreateInstance("Frame", {
		Name = "Notification",
		BackgroundColor3 = c.Notification.Background,
		Position = UDim2.new(1, 20, 0, 0),
		Size = UDim2.new(1, 0, 0, s.Notification.Height),
		ClipsDescendants = true,
		Parent = EnsureNotificationContainer(self),
	})
	CreateCorner(notification, 4)
	CreateInstance("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = c.Notification.Border,
		Thickness = 1.5,
		Parent = notification,
	})
	local titleLabel = CreateInstance("TextLabel", {
		Name = "Title",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 16),
		TextSize = textsize.Normal,
		Size = UDim2.new(1, -60, 0, 19),
		Parent = notification,
	})
	local descriptionLabel = CreateInstance("TextLabel", {
		Name = "Description",
		FontFace = f.Regular,
		TextColor3 = c.TextDark,
		Text = description,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 38),
		TextSize = textsize.Normal,
		Size = UDim2.new(1, -60, 0, 19),
		Parent = notification,
	})
	local iconImage = CreateInstance("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = c.Text,
		Position = UDim2.new(1, -33, 0, 23),
		Size = UDim2.new(0, 19, 0, 19),
		Parent = notification,
	})

	ApplyLucideIcon(iconImage, icon, "bell", 48, true)
	CreateInstance("UIAspectRatioConstraint", {
		Parent = iconImage,
	})
	local timerBar = CreateInstance("Frame", {
		Name = "Timer",
		BackgroundColor3 = c.Notification.Timer,
		Position = UDim2.new(0, 0, 1, -3),
		Size = UDim2.new(1, 0, 0, 3),
		Parent = notification,
	})
	CreateCorner(timerBar, 100)
	CreateTween(
		notification,
		{ Position = UDim2.new(0, 0, 0, 0) },
		0.3,
		Enum.EasingStyle.Back,
		Enum.EasingDirection.Out
	)
	CreateTween(timerBar, { Size = UDim2.new(0, 0, 0, 3) }, duration, Enum.EasingStyle.Linear)
	task.delay(duration, function()
		CreateTween(
			notification,
			{ Position = UDim2.new(1, 20, 0, 0) },
			0.3,
			Enum.EasingStyle.Back,
			Enum.EasingDirection.In
		)
		task.wait(0.3)
		ClearLucideFallback(iconImage)
		notification:Destroy()
	end)
	return notification
end

function Library:SetNotificationsEnabled(enabled)
	self._notificationsEnabled = enabled ~= false
end

function Library:AreNotificationsEnabled()
	return self._notificationsEnabled ~= false
end

function Library:_SetupKeybindListener()
	Track(
		self,
		ui.InputBegan:Connect(function(input, gameProcessed)
			if gameProcessed then
				return
			end
			if ui:GetFocusedTextBox() then
				return
			end

			if self._capturingKeybind then
				return
			end
			if input.KeyCode == self._toggleKey then
				self:Toggle()
			end
			for _, keybindData in pairs(self._keybinds) do
				if keybindData.enabled ~= false then
					local key = keybindData.key
					if typeof(key) == "EnumItem" then
						if key.EnumType == Enum.KeyCode and input.KeyCode == key then
							keybindData.callback()
						elseif key.EnumType == Enum.UserInputType and input.UserInputType == key then
							keybindData.callback()
						end
					end
				end
			end
		end)
	)
end

function Library:Toggle()
	self._visible = not self._visible
	self.container.Visible = self._visible

	if self._acrylicBlur then
		self._acrylicBlur:SetEnabled(self._visible)
	end

	if self._mobileToggle then
		self._mobileToggle.Visible = not self._visible
	end
end

function Library:SetToggleKey(keyCode)
	self._toggleKey = ResolveKeyCode(keyCode, self._toggleKey)
end

function Library:GetToggleKey()
	return self._toggleKey
end

function Library:ConfigureLocalization(config, skipInitialLoad)
	config = type(config) == "table" and config or {}
	local defaultLanguage = config.Default or config.DefaultLanguage or config.Language or self._language or "en"
	local fallbackLanguage = config.Fallback or config.FallbackLanguage or defaultLanguage
	local translations = {}
	local inlineTranslations = config.Translations or config.Packs
	if type(inlineTranslations) == "table" then
		for language, pack in pairs(inlineTranslations) do
			translations[tostring(language)] = self:_NormalizeLocalizationPack(pack) or pack
		end
	end

	self._localization = {
		Default = tostring(defaultLanguage),
		Fallback = tostring(fallbackLanguage),
		Sources = config.Sources or config.Source or config.Urls or config.Url,
		BaseUrl = config.BaseUrl,
		Cache = config.Cache ~= false,
		Translations = translations,
		PromptRestart = config.PromptRestart ~= false,
		RestartOnChange = config.RestartOnChange ~= false,
		Messages = config.Messages or {},
	}
	self._restartConfig = config.Restart or config.Reexecute or self._restartConfig
	if (not self._language or self._language == "") and config.AutoDetect ~= false then
		self._language = GetSystemLanguageCode(defaultLanguage)
	end
	if not skipInitialLoad then
		self:LoadLanguage(self._language or defaultLanguage)
	end
	return self
end

function Library:_GetLocalizationMessage(key, fallback)
	local localization = self._localization
	local language = self._language or (localization and localization.Default) or "en"
	local messages = localization and localization.Messages
	local languageMessages = type(messages) == "table" and (messages[language] or messages[NormalizeLanguageCode(language)]) or nil
	if type(languageMessages) == "table" and languageMessages[key] then
		return languageMessages[key]
	end
	local fallbackMessages = type(messages) == "table" and messages[localization and localization.Fallback or "en"] or nil
	if type(fallbackMessages) == "table" and fallbackMessages[key] then
		return fallbackMessages[key]
	end
	return fallback
end

function Library:_ResolveLocalizationSource(language)
	local localization = self._localization
	if not localization then
		return nil
	end
	local sources = localization.Sources
	if type(sources) == "function" then
		return sources(language, self)
	elseif type(sources) == "table" then
		return sources[language] or sources[NormalizeLanguageCode(language)]
	elseif type(sources) == "string" then
		return sources
	end
	if type(localization.BaseUrl) == "string" and localization.BaseUrl ~= "" then
		return localization.BaseUrl:gsub("/+$", "") .. "/" .. tostring(language) .. ".json"
	end
	return nil
end

function Library:_NormalizeLocalizationPack(pack)
	if type(pack) ~= "table" then
		return nil
	end
	if type(pack.Translations) == "table" then
		return pack.Translations
	end
	if type(pack.translations) == "table" then
		return pack.translations
	end
	if type(pack.Messages) == "table" then
		return pack.Messages
	end
	return pack
end

function Library:LoadLanguage(language, forceRefresh)
	local localization = self._localization
	if not localization then
		return false
	end
	language = tostring(language or self._language or localization.Default or "en")
	if localization.Translations[language] and not forceRefresh then
		return true, localization.Translations[language]
	end

	local cachePath = GetLanguageCachePath(self.configFolder, language)
	if localization.Cache and not forceRefresh then
		local cached = self:_NormalizeLocalizationPack(ReadJsonFile(cachePath))
		if cached then
			localization.Translations[language] = cached
			return true, cached, "cache"
		end
	end

	local source = self:_ResolveLocalizationSource(language)
	local pack
	if type(source) == "table" then
		pack = source
	elseif type(source) == "function" then
		local ok, result = pcall(source, language, self)
		if ok then
			pack = result
		end
	elseif type(source) == "string" and source ~= "" then
		local ok, result = pcall(function()
			return game:HttpGet(source)
		end)
		if ok and type(result) == "string" then
			local decodedOk, decoded = pcall(function()
				return hs:JSONDecode(result)
			end)
			if decodedOk then
				pack = decoded
			end
		end
	end

	pack = self:_NormalizeLocalizationPack(pack)
	if pack then
		localization.Translations[language] = pack
		if localization.Cache then
			WriteJsonFile(self.configFolder, cachePath, pack)
		end
		return true, pack, "remote"
	end
	if localization.Cache then
		local cached = self:_NormalizeLocalizationPack(ReadJsonFile(cachePath))
		if cached then
			localization.Translations[language] = cached
			return true, cached, "cache"
		end
	end
	return false
end

function Library:T(key, fallback, ...)
	local localization = self._localization
	local language = self._language or (localization and localization.Default) or "en"
	local pack = localization and localization.Translations and localization.Translations[language]
	local fallbackPack = localization and localization.Translations and localization.Translations[localization.Fallback]
	local text = type(pack) == "table" and pack[key] or nil
	if text == nil and type(fallbackPack) == "table" then
		text = fallbackPack[key]
	end
	if text == nil then
		text = fallback ~= nil and fallback or key
	end
	if select("#", ...) > 0 then
		local ok, formatted = pcall(string.format, tostring(text), ...)
		if ok then
			return formatted
		end
	end
	return tostring(text)
end

function Library:_PromptAction(promptKey, config)
	config = type(config) == "table" and config or {}
	if promptKey and self[promptKey] and self[promptKey].Parent then
		self[promptKey]:Destroy()
	end
	local c = self._c or c
	local overlay = CreateInstance("Frame", {
		Name = config.Name or "ActionPrompt",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.42,
		Size = UDim2.fromScale(1, 1),
		ZIndex = 9000,
		Parent = self.screenGui,
	})
	local modal = CreateInstance("Frame", {
		Name = "Modal",
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = c.Notification.Background,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 330, 0, 168),
		ZIndex = 9001,
		Parent = overlay,
	})
	CreateCorner(modal, 8)
	CreateStroke(modal, c.Notification.Border, 0.08)
	CreatePadding(modal, 16, 16, 16, 16)
	CreateInstance("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		FontFace = f.Bold,
		Text = config.Title or "Confirm action",
		TextColor3 = c.Text,
		TextSize = textsize.Title,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, 0, 0, 22),
		ZIndex = 9002,
		Parent = modal,
	})
	CreateInstance("TextLabel", {
		Name = "Description",
		BackgroundTransparency = 1,
		FontFace = f.Regular,
		Text = config.Description or "",
		TextColor3 = c.TextDark,
		TextSize = textsize.Small,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Position = UDim2.new(0, 0, 0, 34),
		Size = UDim2.new(1, 0, 0, 56),
		ZIndex = 9002,
		Parent = modal,
	})
	local buttons = CreateInstance("Frame", {
		Name = "Buttons",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 1, -38),
		Size = UDim2.new(1, 0, 0, 34),
		ZIndex = 9002,
		Parent = modal,
	})
	CreateListLayout(buttons, 8, Enum.SortOrder.LayoutOrder, Enum.FillDirection.Horizontal, Enum.HorizontalAlignment.Right)
	local buttonsLayout = buttons:FindFirstChildOfClass("UIListLayout")
	if buttonsLayout then
		buttonsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	end

	local function CreateModalButton(text, filled, callback)
		local button = CreateInstance("TextButton", {
			Name = text,
			BackgroundColor3 = filled and c.Accent or c.Secondary,
			BackgroundTransparency = filled and 0 or 0.14,
			BorderSizePixel = 0,
			FontFace = f.Regular,
			Text = text,
			TextColor3 = filled and c.Background or c.Text,
			TextSize = textsize.Small,
			Size = UDim2.new(0, 112, 1, 0),
			ZIndex = 9003,
			Parent = buttons,
		})
		CreateCorner(button, 7)
		CreateStroke(button, filled and c.Accent or c.Border, filled and 0.35 or 0.22)
		button.MouseButton1Click:Connect(callback)
		return button
	end

	CreateModalButton(config.CancelText or "Later", false, function()
		overlay:Destroy()
		if type(config.OnCancel) == "function" then
			config.OnCancel()
		end
	end)
	CreateModalButton(config.ConfirmText or "Confirm", true, function()
		overlay:Destroy()
		if type(config.OnConfirm) == "function" then
			config.OnConfirm()
		end
	end)

	if promptKey then
		self[promptKey] = overlay
	end
	return overlay
end

function Library:PromptRestart(config)
	config = type(config) == "table" and config or {}
	config.Name = config.Name or "RestartPrompt"
	config.Title = config.Title or "Restart required"
	config.Description = config.Description
		or "The language changed. Restart the script to apply every label cleanly."
	config.CancelText = config.CancelText or "Later"
	config.ConfirmText = config.RestartText or config.ConfirmText or "Restart"
	config.OnConfirm = config.OnConfirm or function()
		self:Restart()
	end
	return self:_PromptAction("_restartPrompt", config)
end

function Library:PromptClose(config)
	config = type(config) == "table" and config or {}
	config.Name = config.Name or "ClosePrompt"
	config.Title = config.Title or "Close script?"
	config.Description = config.Description or "This will close the current UI and stop active runtime features."
	config.CancelText = config.CancelText or "Cancel"
	config.ConfirmText = config.ConfirmText or "Close"
	config.OnConfirm = config.OnConfirm or function()
		self:Destroy()
	end
	return self:_PromptAction("_closePrompt", config)
end

function Library:Restart()
	local restart = self._restartConfig
	local function CloseCurrentUi()
		local destroyOk, destroyError = pcall(function()
			self:Destroy()
		end)
		if destroyOk then
			return true
		end
		warn("[Mithren] Script destroy hook failed: " .. tostring(destroyError))
		local baseDestroyOk, baseDestroyError = pcall(function()
			Library.Destroy(self)
		end)
		if not baseDestroyOk then
			warn("[Mithren] Base destroy failed: " .. tostring(baseDestroyError))
			return false
		end
		return true
	end
	local function RunSource(source, closed)
		if type(source) ~= "string" or source == "" then
			warn("[Mithren] Restart source is not available. Current UI was closed.")
			return false
		end
		if not loadstring then
			warn("[Mithren] loadstring is not available. Current UI was closed.")
			return false
		end
		local runner, compileError = loadstring(source)
		if type(runner) ~= "function" then
			warn("[Mithren] Could not compile restart source: " .. tostring(compileError))
			return false
		end
		if closed ~= true and not CloseCurrentUi() then
			return false
		end
		task.defer(function()
			local ok, runError = pcall(runner)
			if not ok then
				warn("[Mithren] Restart failed: " .. tostring(runError))
			end
		end)
		return true
	end
	local closed = CloseCurrentUi()
	if not closed then
		return false
	end
	if type(restart) == "function" then
		task.defer(function()
			local ok, callbackError = pcall(restart, self)
			if not ok then
				warn("[Mithren] Restart callback failed: " .. tostring(callbackError))
			end
		end)
		return true
	elseif type(restart) == "table" then
		local callback = restart.Callback or restart.Function or restart.Reexecute
		if type(callback) == "function" then
			task.defer(function()
				local ok, callbackError = pcall(callback, self)
				if not ok then
					warn("[Mithren] Restart callback failed: " .. tostring(callbackError))
				end
			end)
			return true
		end
		local source = restart.Source or restart.Script
		local url = restart.Url or restart.SourceUrl or restart.ScriptUrl
		if type(url) == "string" and url ~= "" then
			local ok, result = pcall(function()
				return game:HttpGet(url)
			end)
			if ok and type(result) == "string" and result ~= "" and not result:lower():find("404", 1, true) then
				source = result
			end
		end
		return RunSource(source, true)
	elseif type(restart) == "string" then
		return RunSource(restart, true)
	end
	warn("[Mithren] No restart action was configured. Current UI was closed.")
	return false
end

function Library:_HandleLanguageChanged(option, fireCallback, previousLanguage)
	previousLanguage = previousLanguage ~= nil and tostring(previousLanguage) or self._language
	local language = option and option.Value or self._language
	self._language = language ~= nil and tostring(language) or self._language
	WriteJsonFile(self.configFolder, GetConfigPath(self.configFolder, "__language"), {
		Language = self._language,
	})
	if fireCallback ~= false and type(self._languageCallback) == "function" then
		pcall(self._languageCallback, self._language, option)
	end
	if self._localization then
		task.spawn(function()
			self:LoadLanguage(self._language, fireCallback ~= false)
		end)
	end
	local localization = self._localization
	if
		localization
		and fireCallback ~= false
		and self._isLoading ~= true
		and previousLanguage ~= self._language
		and localization.RestartOnChange
		and localization.PromptRestart
	then
		task.defer(function()
			if self.screenGui and self.screenGui.Parent then
				self:PromptRestart()
			end
		end)
	end
end

function Library:SetLanguage(language, fireCallback)
	local languageValue, option = ResolveLanguageValue(language, self._languageOptions)
	if self._setTopBarLanguage then
		self._setTopBarLanguage(languageValue, fireCallback ~= false)
	else
		self:_HandleLanguageChanged(option or { Value = languageValue, Label = languageValue }, fireCallback ~= false, self._language)
	end
end

function Library:GetLanguage()
	return self._language
end

function Library:SetLanguageOptions(options, defaultLanguage)
	if type(options) ~= "table" or #options == 0 then
		self._languageOptions = nil
		if self.languageSelect then
			self.languageSelect.Visible = false
		end
		return
	end
	self._languageOptions = options
	if not self.languageSelect and self.topBar then
		self:_CreateTopBarLanguageSelect()
	end
	if self._refreshTopBarLanguages then
		self._refreshTopBarLanguages(options)
	end
	self:SetLanguage(defaultLanguage or options[1], false)
end

function Library:_RegisterKeybind(id, keyCode, callback)
	if not id or type(callback) ~= "function" then
		return nil
	end
	local resolved = ResolveKeybindInput(keyCode)
	self._keybinds[id] = {
		key = resolved,
		callback = callback,
		enabled = resolved ~= Enum.KeyCode.Unknown,
	}
	return self._keybinds[id]
end

function Library:_SetRegisteredKeybind(id, keyCode)
	if not self._keybinds[id] then
		return
	end
	local resolved = ResolveKeybindInput(keyCode)
	self._keybinds[id].key = resolved
	self._keybinds[id].enabled = resolved ~= Enum.KeyCode.Unknown
end

function Library:_RefreshFloatingBubbles()
	local c = self._c or c
	if self._mobileToggle then
		self._mobileToggle.BackgroundColor3 = c.Secondary
		local stroke = self._mobileToggle:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = c.Border
			stroke.Transparency = 0.25
		end
		for _, obj in ipairs(self._mobileToggle:GetDescendants()) do
			if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				obj.ImageColor3 = c.Accent
			elseif obj:IsA("TextLabel") or obj:IsA("TextButton") then
				obj.TextColor3 = c.Text
			elseif obj:IsA("UIGradient") then
				obj.Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, c.Secondary),
					ColorSequenceKeypoint.new(1, c.Background),
				})
			end
		end
	end
	if self.screenGui then
		for _, obj in ipairs(self.screenGui:GetDescendants()) do
			if typeof(obj.Name) == "string" and obj.Name:match("^ActionBubble_") then
				local button = obj:FindFirstChild("Button")
				if button and button:IsA("TextButton") then
					local active = button:GetAttribute("MithrenBubbleActive") == true
					button.BackgroundColor3 = active and c.Accent or c.Secondary
					button.TextColor3 = active and c.Background or c.Text
					local stroke = button:FindFirstChildOfClass("UIStroke")
					if stroke then
						stroke.Color = active and c.Accent or c.Border
						stroke.Transparency = active and 0.05 or 0.25
					end
				end
			end
		end
	end
end

function Library:_SetupMobileSupport()
	local c = self._c or c
	local mobileButton = CreateInstance("Frame", {
		Name = "RestoreToggle",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.04,
		Position = UDim2.new(0.5, 0, 0, 4),
		Size = UDim2.new(0, 190, 0, 40),
		AnchorPoint = Vector2.new(0.5, 0),
		Visible = false,
		ZIndex = 10000,
		Parent = self.screenGui,
	})
	CreateCorner(mobileButton, 12)
	local mobileStroke = CreateStroke(mobileButton, c.Border, 0.25)

	CreateInstance("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, c.Secondary),
			ColorSequenceKeypoint.new(1, c.Background),
		}),
		Rotation = 90,
		Parent = mobileButton,
	})

	local mobileIcon = CreateInstance("ImageLabel", {
		Name = "Icon",
		Image = "",
		ImageColor3 = c.Accent,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0.5, -9),
		Size = UDim2.new(0, 18, 0, 18),
		ZIndex = 10001,
		Parent = mobileButton,
	})
	ApplyLucideIcon(mobileIcon, "app-window", "app-window", 48)

	local mobileLabel = CreateInstance("TextLabel", {
		Name = "Label",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = "Abrir " .. self.title,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 42, 0, 0),
		Size = UDim2.new(1, -78, 1, 0),
		TextSize = textsize.Small,
		ZIndex = 10001,
		Parent = mobileButton,
	})

	local mobileClickArea = CreateInstance("TextButton", {
		Name = "ClickArea",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 10002,
		Parent = mobileButton,
	})

	local dragging = false
	local dragMoved = false
	local dragInput, dragStart, startPos

	mobileClickArea.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragMoved = false
			dragStart = input.Position
			startPos = mobileButton.Position
			dragInput = input
		end
	end)

	mobileClickArea.InputEnded:Connect(function(input)
		if input == dragInput then
			dragging = false
			dragInput = nil
			if not dragMoved then
				self:Toggle()
			end
		end
	end)

	Track(
		self,
		ui.InputChanged:Connect(function(input)
			if
				dragging
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				local delta = input.Position - dragStart
				if delta.Magnitude > 4 then
					dragMoved = true
				end
				mobileButton.Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			end
		end)
	)

	mobileClickArea.MouseEnter:Connect(function()
		CreateTween(mobileButton, {
			BackgroundTransparency = 0,
			Size = UDim2.new(0, 202, 0, 40),
		}, animationspeed.Fast)
		CreateTween(mobileStroke, { Color = c.Accent, Transparency = 0.05 }, animationspeed.Fast)
		CreateTween(mobileIcon, { ImageColor3 = c.Accent }, animationspeed.Fast)
		CreateTween(mobileLabel, { TextColor3 = c.Accent }, animationspeed.Fast)
	end)

	mobileClickArea.MouseLeave:Connect(function()
		CreateTween(mobileButton, {
			BackgroundTransparency = 0.04,
			Size = UDim2.new(0, 190, 0, 40),
		}, animationspeed.Fast)
		CreateTween(mobileStroke, { Color = c.Border, Transparency = 0.25 }, animationspeed.Fast)
		CreateTween(mobileIcon, { ImageColor3 = c.Accent }, animationspeed.Fast)
		CreateTween(mobileLabel, { TextColor3 = c.Text }, animationspeed.Fast)
	end)

	self._mobileToggle = mobileButton

	if IsMobileDevice() then
		mobileButton.Visible = not self._visible
	end
end

function Library:_CreateMainv0rtexd()
	local c = self._c or c
	local windowWidth = self._windowSize and self._windowSize.X or s.v0rtexd.Width
	local windowHeight = self._windowSize and self._windowSize.Y or s.v0rtexd.Height

	self.screenGui = CreateInstance("ScreenGui", {
		Name = n,
		DisplayOrder = 999999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
	})

	self.container = CreateInstance("Frame", {
		Name = "Container",
		BackgroundColor3 = c.Background,
		BackgroundTransparency = 0.03,
		Position = UDim2.new(0.5, -windowWidth / 2, 0.5, -windowHeight / 2),
		BorderSizePixel = 0,
		Size = UDim2.new(0, windowWidth, 0, windowHeight),
		ClipsDescendants = false,
		Active = true,
		Parent = self.screenGui,
	})
	CreateCorner(self.container, 12)
	CreateStroke(self.container, c.Border, 0.2)

	self.backgroundImage = CreateInstance("ImageLabel", {
		Name = "CustomBackgroundImage",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Image = "",
		ImageTransparency = 1,
		ScaleType = Enum.ScaleType.Crop,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 0,
		Parent = self.container,
	})
	CreateCorner(self.backgroundImage, 12)

	self.backgroundDim = CreateInstance("Frame", {
		Name = "CustomBackgroundDim",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 0.45,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
		ZIndex = 1,
		Parent = self.container,
	})
	CreateCorner(self.backgroundDim, 12)

	self.inputBlocker = CreateInstance("TextButton", {
		Name = "InputBlocker",
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Active = true,
		ZIndex = 1,
		Parent = self.container,
	})

	self.topBar = CreateInstance("Frame", {
		Name = "TopBar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 45),
		ZIndex = 2,
		Parent = self.container,
	})

	self.titleGroup = CreateInstance("Frame", {
		Name = "TitleGroup",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 10),
		Size = UDim2.new(1, -210, 0, 25),
		ZIndex = 3,
		Parent = self.topBar,
	})
	local titleLayout = CreateListLayout(self.titleGroup, 6, Enum.SortOrder.LayoutOrder, Enum.FillDirection.Horizontal)
	titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center

	self.titleLabel = CreateInstance("TextLabel", {
		Name = "Title",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = self.title,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextSize = textsize.Title,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 1, 0),
		ZIndex = 3,
		Parent = self.titleGroup,
	})

	self.versionTagLabel = CreateInstance("TextLabel", {
		Name = "VersionTag",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = self.versionTag and tostring(self.versionTag) or "",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = self._elementTransparency,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextSize = textsize.Tiny,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.new(0, 0, 0, 20),
		Visible = self.versionTag ~= nil and tostring(self.versionTag) ~= "",
		ZIndex = 3,
		Parent = self.titleGroup,
	})
	CreateCorner(self.versionTagLabel, 6)
	self.versionTagStroke = CreateStroke(self.versionTagLabel, c.Border, 0.35)
	self.versionTagStroke.Name = "VersionTagStroke"
	CreateInstance("UIPadding", {
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
		Parent = self.versionTagLabel,
	})

	self:_Createv0rtexdControls()

	self.headerLine = CreateInstance("Frame", {
		Name = "Header",
		BackgroundColor3 = c.Border,
		Position = UDim2.new(0, 0, 0, 45),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		ZIndex = 2,
		Parent = self.container,
	})

	self:_CreateContentArea()
	MakeDraggable(self.container, self.topBar, self)

	ParentScreenGui(self.screenGui)
	self:_SetupResponsiveBounds()
end

function Library:_CreateTopBarLanguageSelect()
	local c = self._c or c
	local rawOptions = self._languageOptions
	if type(rawOptions) ~= "table" or #rawOptions == 0 then
		return
	end
	if #rawOptions <= 1 and not self._languageSelectorAlwaysVisible then
		self._language = NormalizeLanguageOption(rawOptions[1]).Value
		return
	end

	local function NormalizeLanguageOptions(options)
		local normalized = {}
		for _, option in ipairs(options or {}) do
			local item = NormalizeLanguageOption(option)
			if item.Label ~= "" then
				table.insert(normalized, item)
			end
		end
		return normalized
	end

	local options = NormalizeLanguageOptions(rawOptions)
	if #options == 0 then
		return
	end
	if #options <= 1 and not self._languageSelectorAlwaysVisible then
		self._language = options[1].Value
		return
	end

	local function FindLanguageOption(language)
		local value = ResolveLanguageValue(language, options)
		for _, option in ipairs(options) do
			if option.Value == value then
				return option
			end
		end
		return options[1]
	end

	local longestLabel = 0
	for _, option in ipairs(options) do
		longestLabel = math.max(longestLabel, #option.Label)
	end
	local selectorWidth = math.clamp(longestLabel * 8 + 54, 122, 176)

	local selectedOption = FindLanguageOption(self._language)
	self._language = selectedOption.Value

	local selector = CreateInstance("Frame", {
		Name = "LanguageSelect",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.22,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -96, 0, 9),
		BorderSizePixel = 0,
		Size = UDim2.new(0, selectorWidth, 0, 27),
		ZIndex = 4,
		Parent = self.topBar,
	})
	CreateCorner(selector, 7)
	local selectorStroke = CreateStroke(selector, c.Border, 0.35)

	local globeIcon = CreateInstance("ImageLabel", {
		Name = "Icon",
		Image = "",
		ImageColor3 = c.TextDark,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, -7),
		Size = UDim2.new(0, 14, 0, 14),
		ZIndex = 5,
		Parent = selector,
	})
	ApplyLucideIcon(globeIcon, self._languageSelectorIcon or "globe", "globe", 48)

	local selectedLabel = CreateInstance("TextLabel", {
		Name = "SelectedLabel",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = selectedOption.Label,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 32, 0, 0),
		Size = UDim2.new(1, -54, 1, 0),
		TextSize = textsize.Small,
		ZIndex = 5,
		Parent = selector,
	})

	local arrow = CreateInstance("ImageLabel", {
		Name = "Arrow",
		Image = "",
		ImageColor3 = c.TextDark,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -21, 0.5, -5),
		Size = UDim2.new(0, 10, 0, 10),
		ZIndex = 5,
		Parent = selector,
	})
	ApplyLucideIcon(arrow, "chevron-down", "chevron-down", 48)

	local optionsHeight = math.min(#options * 28, 140)
	local optionsContainer = CreateInstance("Frame", {
		Name = "LanguageOptions",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.02,
		BorderSizePixel = 0,
		Size = UDim2.new(0, selectorWidth, 0, optionsHeight),
		Visible = false,
		ClipsDescendants = true,
		ZIndex = 6000,
		Parent = self.screenGui,
	})
	CreateCorner(optionsContainer, 7)
	CreateStroke(optionsContainer, c.Border, 0.2)

	local optionsScroll = CreateInstance("ScrollingFrame", {
		Name = "OptionsScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, #options * 28),
		ScrollBarThickness = #options > 5 and 3 or 0,
		ScrollBarImageColor3 = c.ScrollBar,
		ZIndex = 6001,
		Parent = optionsContainer,
	})
	CreateListLayout(optionsScroll, 0, Enum.SortOrder.LayoutOrder)

	local languageOptionButtons = {}

	local function UpdateLanguageOptionStates()
		for _, data in ipairs(languageOptionButtons) do
			local isSelected = data.Option.Value == self._language
			data.Button:SetAttribute("MithrenOptionSelected", isSelected)
			data.Button.BackgroundColor3 = c.Accent
			data.Button.BackgroundTransparency = isSelected and 0.72 or 1
			data.Button.TextColor3 = c.Text
		end
	end

	local function SetLanguage(language, fireCallback)
		local option = FindLanguageOption(language)
		local previousLanguage = self._language
		self._language = option.Value
		selectedLabel.Text = option.Label
		UpdateLanguageOptionStates()
		self:_HandleLanguageChanged(option, fireCallback, previousLanguage)
	end

	local function CloseOptions()
		optionsContainer.Visible = false
		CreateTween(arrow, { Rotation = 0 }, animationspeed.Normal)
		CreateTween(selector, { BackgroundTransparency = 0.22 }, animationspeed.Fast)
		CreateTween(selectorStroke, { Color = c.Border, Transparency = 0.35 }, animationspeed.Fast)
		CreateTween(globeIcon, { ImageColor3 = c.TextDark }, animationspeed.Fast)
		CreateTween(arrow, { ImageColor3 = c.TextDark }, animationspeed.Fast)
		if self._languageInputConn then
			self._languageInputConn:Disconnect()
			self._languageInputConn = nil
		end
	end

	local function RebuildOptions()
		languageOptionButtons = {}
		for _, child in ipairs(optionsScroll:GetChildren()) do
			if child:IsA("TextButton") then
				child:Destroy()
			end
		end
		for _, option in ipairs(options) do
			local optionText = option.Label
			local optionButton = CreateInstance("TextButton", {
				Name = optionText,
				FontFace = f.Regular,
				TextColor3 = c.Text,
				Text = optionText,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				TextSize = textsize.Small,
				Size = UDim2.new(1, 0, 0, 28),
				ZIndex = 6002,
				Parent = optionsScroll,
			})
			optionButton:SetAttribute("MithrenDropdownOption", true)
			CreateCorner(optionButton, 6)
			CreatePadding(optionButton, 0, 0, 10, 10)

			table.insert(languageOptionButtons, {
				Button = optionButton,
				Option = option,
			})
			optionButton.MouseEnter:Connect(function()
				local isSelected = option.Value == self._language
				CreateTween(optionButton, { BackgroundTransparency = isSelected and 0.6 or 0.68 }, animationspeed.Fast)
				CreateTween(optionButton, { TextColor3 = c.Text }, animationspeed.Fast)
			end)
			optionButton.MouseLeave:Connect(function()
				local isSelected = option.Value == self._language
				CreateTween(optionButton, { BackgroundTransparency = isSelected and 0.72 or 1 }, animationspeed.Fast)
				CreateTween(optionButton, { TextColor3 = c.Text }, animationspeed.Fast)
			end)
			optionButton.MouseButton1Click:Connect(function()
				SetLanguage(option.Value, true)
				CloseOptions()
			end)
		end
		UpdateLanguageOptionStates()
		optionsScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 28)
		optionsHeight = math.min(#options * 28, 140)
		optionsContainer.Size = UDim2.new(0, selectorWidth, 0, optionsHeight)
		optionsScroll.ScrollBarThickness = #options > 5 and 3 or 0
	end

	RebuildOptions()

	local toggleButton = CreateInstance("TextButton", {
		Name = "ToggleButton",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 6,
		Parent = selector,
	})

	toggleButton.MouseButton1Click:Connect(function()
		if optionsContainer.Visible then
			CloseOptions()
			return
		end
		local absPos = selector.AbsolutePosition
		local absSize = selector.AbsoluteSize
		optionsContainer.Size = UDim2.new(0, absSize.X, 0, optionsHeight)
		optionsContainer.Position = UDim2.new(0, absPos.X, 0, absPos.Y + absSize.Y + 3)
		optionsContainer.Visible = true
		CreateTween(arrow, { Rotation = 180 }, animationspeed.Normal)

		self._languageInputConn = ui.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			local mp = input.Position
			local op = optionsContainer.AbsolutePosition
			local osz = optionsContainer.AbsoluteSize
			local sp = selector.AbsolutePosition
			local ssz = selector.AbsoluteSize
			local inOptions = mp.X >= op.X and mp.X <= op.X + osz.X and mp.Y >= op.Y and mp.Y <= op.Y + osz.Y
			local inSelector = mp.X >= sp.X and mp.X <= sp.X + ssz.X and mp.Y >= sp.Y and mp.Y <= sp.Y + ssz.Y
			if not inOptions and not inSelector then
				CloseOptions()
			end
		end)
	end)

	selector.MouseEnter:Connect(function()
		CreateTween(selector, { BackgroundTransparency = 0.08 }, animationspeed.Fast)
		CreateTween(selectorStroke, { Color = c.Accent, Transparency = 0.1 }, animationspeed.Fast)
		CreateTween(globeIcon, { ImageColor3 = c.Accent }, animationspeed.Fast)
		CreateTween(arrow, { ImageColor3 = c.Text }, animationspeed.Fast)
	end)

	selector.MouseLeave:Connect(function()
		if not optionsContainer.Visible then
			CreateTween(selector, { BackgroundTransparency = 0.22 }, animationspeed.Fast)
			CreateTween(selectorStroke, { Color = c.Border, Transparency = 0.35 }, animationspeed.Fast)
			CreateTween(globeIcon, { ImageColor3 = c.TextDark }, animationspeed.Fast)
			CreateTween(arrow, { ImageColor3 = c.TextDark }, animationspeed.Fast)
		end
	end)

	self.languageSelect = selector
	self._setTopBarLanguage = SetLanguage
	self._refreshTopBarLanguages = function(newOptions)
		rawOptions = newOptions
		options = NormalizeLanguageOptions(newOptions)
		self._languageOptions = newOptions
		if #options <= 1 and not self._languageSelectorAlwaysVisible then
			selector.Visible = false
			if options[1] then
				self._language = options[1].Value
			end
			return
		end
		selector.Visible = true
		longestLabel = 0
		for _, option in ipairs(options) do
			longestLabel = math.max(longestLabel, #option.Label)
		end
		selectorWidth = math.clamp(longestLabel * 8 + 54, 122, 176)
		selector.Size = UDim2.new(0, selectorWidth, 0, 27)
		optionsContainer.Size = UDim2.new(0, selectorWidth, 0, optionsHeight)
		RebuildOptions()
		SetLanguage(self._language, false)
	end
end

function Library:_Createv0rtexdControls()
	local c = self._c or c
	self:_CreateTopBarLanguageSelect()

	local minimizeBtn = CreateInstance("ImageLabel", {
		Name = "Minimize",
		ImageColor3 = c.TextDark,
		Image = "",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -54, 0, 15),
		Size = UDim2.new(0, 16, 0, 16),
		Parent = self.topBar,
	})
	ApplyLucideIcon(minimizeBtn, "minus", "minus", 48)

	local minimizeClickArea = CreateInstance("TextButton", {
		Name = "TextButton",
		Text = "",
		Rotation = 0.01,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 30, 0, 28),
		Parent = minimizeBtn,
	})

	minimizeClickArea.MouseButton1Click:Connect(function()
		self:Toggle()
	end)

	minimizeBtn.MouseEnter:Connect(function()
		CreateTween(minimizeBtn, { ImageColor3 = c.Text }, animationspeed.Fast)
	end)

	minimizeBtn.MouseLeave:Connect(function()
		CreateTween(minimizeBtn, { ImageColor3 = c.TextDark }, animationspeed.Fast)
	end)

	local closeBtn = CreateInstance("ImageButton", {
		Name = "Close",
		ImageColor3 = c.TextDark,
		Image = "",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 15),
		Size = UDim2.new(0, 16, 0, 16),
		Parent = self.topBar,
	})
	ApplyLucideIcon(closeBtn, "x", "x", 48)

	local closeClickArea = CreateInstance("TextButton", {
		Name = "TextButton",
		Text = "",
		Rotation = 0.01,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, 30, 0, 28),
		Parent = closeBtn,
	})

	local function OpenClosePrompt()
		self:PromptClose()
	end

	closeBtn.MouseButton1Click:Connect(OpenClosePrompt)
	closeClickArea.MouseButton1Click:Connect(OpenClosePrompt)

	closeBtn.MouseEnter:Connect(function()
		CreateTween(closeBtn, { ImageColor3 = Color3.fromRGB(255, 100, 100) }, animationspeed.Fast)
	end)

	closeBtn.MouseLeave:Connect(function()
		CreateTween(closeBtn, { ImageColor3 = c.TextDark }, animationspeed.Fast)
	end)

	local resizeBtn = CreateInstance("ImageButton", {
		Name = "Resize",
		ImageColor3 = c.Accent,
		Image = "rbxassetid://120997033468887",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -5, 1, -5),
		Size = UDim2.new(0, 62, 0, 60),
		BorderSizePixel = 0,
		Parent = self.container,
	})

	self.resizeBtn = resizeBtn
	self:_SetupSmartResize(resizeBtn)
end

function Library:_CreateContentArea()
	local c = self._c or c
	self.mainContent = CreateInstance("Frame", {
		Name = "MainContent",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(1, 0, 1, -46),
		ClipsDescendants = true,
		ZIndex = 2,
		Parent = self.container,
	})

	local sidebarWidth = 175

	self.sectionsContainer = CreateInstance("ScrollingFrame", {
		Name = "SectionsContainer",
		ScrollBarThickness = 0,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, sidebarWidth, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = 2,
		Parent = self.mainContent,
	})
	CreateListLayout(self.sectionsContainer, 0, Enum.SortOrder.LayoutOrder)
	CreatePadding(self.sectionsContainer, 8, 8, 8, 8)

	self.separatorLine = CreateInstance("Frame", {
		Name = "Separator",
		BackgroundColor3 = c.Border,
		Position = UDim2.new(0, sidebarWidth, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 1, 1, 0),
		ZIndex = 2,
		Parent = self.mainContent,
	})

	self.contentContainer = CreateInstance("ScrollingFrame", {
		Name = "ContentContainer",
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = c.ScrollBar,
		BorderColor3 = c.Background,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, sidebarWidth + 1, 0, 4),
		Size = UDim2.new(1, -(sidebarWidth + 9), 1, -8),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ZIndex = 2,
		Parent = self.mainContent,
	})
	CreateListLayout(self.contentContainer, 9, Enum.SortOrder.LayoutOrder)
	CreatePadding(self.contentContainer, 12, 12, 15, 15)
end

local function CloneTheme(theme)
	local copy = {}
	for key, value in pairs(theme or {}) do
		copy[key] = value
	end
	return copy
end

function Library:SetBackgroundImage(image, enabled, dim)
	local imageValue = tostring(image or "")
	local isEnabled = enabled == true and imageValue ~= ""
	self._theme.BackgroundImage = imageValue
	self._theme.BackgroundImageEnabled = enabled == true
	self._theme.BackgroundDim = math.clamp(tonumber(dim) or self._theme.BackgroundDim or 0.45, 0, 1)

	if not self.backgroundImage or not self.backgroundDim then
		return
	end

	self.backgroundImage.Image = imageValue
	self.backgroundImage.Visible = isEnabled
	self.backgroundImage.ImageTransparency = isEnabled and 0 or 1

	self.backgroundDim.Visible = isEnabled
	self.backgroundDim.BackgroundTransparency = self._theme.BackgroundDim
end

function Library:SetPanelTransparency(transparency)
	self._theme.PanelTransparency = math.clamp(tonumber(transparency) or 0.03, 0, 0.95)
	if not self.container then
		return
	end
	self.container.BackgroundTransparency = self._theme.PanelTransparency
end

function Library:SetVersionTag(versionTag)
	self.versionTag = versionTag
	if not self.versionTagLabel then
		return
	end
	local text = versionTag ~= nil and tostring(versionTag) or ""
	self.versionTagLabel.Text = text
	self.versionTagLabel.Visible = text ~= ""
end

function Library:SetAcrylicBlurEnabled(enabled)
	self._acrylicBlurEnabled = enabled == true
	self._theme.AcrylicBlurEnabled = self._acrylicBlurEnabled

	if not self._acrylicBlurEnabled then
		if self._acrylicBlur then
			self._acrylicBlur:SetEnabled(false)
			self._acrylicBlur:Destroy()
			self._acrylicBlur = nil
		end
		return
	end

	if not self.container then
		return
	end

	if not self._acrylicBlur then
		self._acrylicBlur = AcrylicBlur.new(self.container)
	end
	self._acrylicBlur:SetEnabled(self._visible and not self.minimized)
end

function Library:_NormalizeSkyPreset(preset)
	preset = tostring(preset or "")
	local aliases = {
		["Atardecer"] = "Sunset",
		["Noche estrellada"] = "Starry night",
		["Dia claro"] = "Clear day",
		["Día claro"] = "Clear day",
		["Espacio profundo"] = "Deep space",
		["Rosa suave"] = "Soft pink",
		["Tormenta"] = "Storm",
	}
	preset = aliases[preset] or preset
	return SKY_PRESETS[preset] and preset or "Starry night"
end

function Library:_CaptureOriginalSky()
	if self._originalSkyState then
		return
	end

	self._originalSkyState = {
		Brightness = lg.Brightness,
		ClockTime = lg.ClockTime,
		FogEnd = lg.FogEnd,
		Skies = {},
	}

	for _, child in ipairs(lg:GetChildren()) do
		if child:IsA("Sky") then
			local ok, clone = pcall(function()
				return child:Clone()
			end)
			if ok and clone then
				table.insert(self._originalSkyState.Skies, clone)
			end
		end
	end
end

function Library:_ClearSkies()
	for _, child in ipairs(lg:GetChildren()) do
		if child:IsA("Sky") then
			child:Destroy()
		end
	end
end

function Library:_RestoreOriginalSky()
	if not self._originalSkyState then
		self._skyApplied = false
		if activeSkyOwner == self then
			activeSkyOwner = nil
		end
		return
	end

	self:_ClearSkies()
	lg.Brightness = self._originalSkyState.Brightness
	lg.ClockTime = self._originalSkyState.ClockTime
	lg.FogEnd = self._originalSkyState.FogEnd

	for _, sky in ipairs(self._originalSkyState.Skies) do
		local ok, clone = pcall(function()
			return sky:Clone()
		end)
		if ok and clone then
			clone.Parent = lg
		end
	end

	self._skyApplied = false
	if activeSkyOwner == self then
		activeSkyOwner = nil
	end
end

function Library:SetSky(enabled, preset)
	local presetName = self:_NormalizeSkyPreset(preset or self._theme.SkyPreset)
	local isEnabled = enabled == true
	self._theme.SkyEnabled = isEnabled
	self._theme.SkyPreset = presetName

	if not isEnabled then
		if self._skyApplied then
			self:_RestoreOriginalSky()
		end
		return
	end

	if activeSkyOwner and activeSkyOwner ~= self and type(activeSkyOwner._RestoreOriginalSky) == "function" then
		activeSkyOwner:_RestoreOriginalSky()
	end

	local skyData = SKY_PRESETS[presetName]
	if not skyData then
		return
	end

	self:_CaptureOriginalSky()
	self:_ClearSkies()

	local sky = Instance.new("Sky")
	sky.Name = "MithrenCustomSky"
	sky.SkyboxBk = skyData.Bk
	sky.SkyboxDn = skyData.Dn
	sky.SkyboxFt = skyData.Ft
	sky.SkyboxLf = skyData.Lf
	sky.SkyboxRt = skyData.Rt
	sky.SkyboxUp = skyData.Up
	sky.StarCount = skyData.StarCount or 3000
	sky.SunAngularSize = skyData.SunSize or 10
	sky.MoonAngularSize = skyData.MoonSize or 8
	sky.Parent = lg

	lg.Brightness = skyData.Brightness or 2
	lg.ClockTime = skyData.ClockTime or 12
	lg.FogEnd = skyData.FogEnd or 100000
	self._skyApplied = true
	activeSkyOwner = self
end

function Library:_RefreshCurrentTabStyle()
	local c = self._c or c
	if not self.currentTab then
		return
	end

	local tab = self.currentTab
	if tab.icon then
		tab.icon.ImageColor3 = c.Text
	end
	if tab.textLabel then
		tab.textLabel.TextColor3 = c.Text
	end
	if tab.stroke then
		tab.stroke.Color = c.Accent
		tab.stroke.Transparency = 0.35
	end
	if tab.button then
		tab.button.BackgroundColor3 = c.Secondary
		tab.button.BackgroundTransparency = GetTabTransparency(self, "Active")
	end
	if tab.textGradient then
		tab.textGradient.Enabled = false
	end
end

function Library:_RefreshSwitchStyles()
	local c = self._c or c
	if not self.container then
		return
	end

	for _, obj in ipairs(self.container:GetDescendants()) do
		if obj:IsA("Frame") and obj.Name == "SwitchBackground" then
			local isEnabled = obj:GetAttribute("Enabled") == true
			obj.BackgroundColor3 = isEnabled and c.Toggle.Enabled or c.Toggle.Disabled

			local circle = obj:FindFirstChild("Circle")
			if circle and circle:IsA("Frame") then
				circle.BackgroundColor3 = isEnabled and c.Background or c.Toggle.Circle
				circle.Position = isEnabled and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 4, 0.5, 0)
			end
		end
	end
end

function Library:SetAccentColor(color)
	local c = self._c or c
	if typeof(color) ~= "Color3" then
		return
	end

	c.Accent = color
	c.Toggle.Enabled = color
	c.Notification.Timer = color
	self._theme.AccentColor = color

	self:_RefreshCurrentTabStyle()
	task.delay(animationspeed.Fast + 0.03, function()
		self:_RefreshCurrentTabStyle()
	end)

	if self._mobileToggle then
		self:_RefreshFloatingBubbles()
	end

	if self.resizeBtn then
		self.resizeBtn.ImageColor3 = color
	end

	self:_RefreshSwitchStyles()
	task.delay(animationspeed.Normal + 0.04, function()
		self:_RefreshSwitchStyles()
	end)

	if not self.container then
		return
	end

	for _, obj in ipairs(self.container:GetDescendants()) do
		if obj:IsA("Frame") then
			if obj.Name == "SliderFill" then
				obj.BackgroundColor3 = color
			elseif obj.Name == "SwitchBackground" then
				obj.BackgroundColor3 = obj:GetAttribute("Enabled") == true and color or c.Toggle.Disabled
			end
		elseif obj:IsA("ScrollingFrame") then
			obj.ScrollBarImageColor3 = c.ScrollBar
			obj.BorderColor3 = c.Background
			if obj.Name == "ContentContainer" then
				obj.ScrollBarThickness = 3
			end
		end
	end
end

function Library:SetTheme(theme)
	local c = self._c or c
	if type(theme) ~= "table" then
		return
	end

	if typeof(theme.AccentColor) == "Color3" then
		c.Accent = theme.AccentColor
		c.Toggle.Enabled = theme.AccentColor
		c.Notification.Timer = theme.AccentColor
		self._theme.AccentColor = theme.AccentColor
	end
	if typeof(theme.BackgroundColor) == "Color3" then
		c.Background = theme.BackgroundColor
		self._theme.BackgroundColor = theme.BackgroundColor
	end
	if typeof(theme.SecondaryColor) == "Color3" then
		c.Secondary = theme.SecondaryColor
		self._theme.SecondaryColor = theme.SecondaryColor
	end
	if typeof(theme.BorderColor) == "Color3" then
		c.Border = theme.BorderColor
		self._theme.BorderColor = theme.BorderColor
	end
	if typeof(theme.TextColor) == "Color3" then
		c.Text = theme.TextColor
		self._theme.TextColor = theme.TextColor
	end
	if typeof(theme.MutedTextColor) == "Color3" then
		c.TextDark = theme.MutedTextColor
		self._theme.MutedTextColor = theme.MutedTextColor
	end
	if typeof(theme.ScrollBarColor) == "Color3" then
		c.ScrollBar = theme.ScrollBarColor
		self._theme.ScrollBarColor = theme.ScrollBarColor
	end
	c.TextFade = c.TextDark:Lerp(c.Background, 0.7)
	if theme.ElementTransparency ~= nil then
		self._elementTransparency = math.clamp(tonumber(theme.ElementTransparency) or self._elementTransparency, 0, 0.9)
		self._theme.ElementTransparency = self._elementTransparency
	end

	if theme.PanelTransparency ~= nil then
		self:SetPanelTransparency(theme.PanelTransparency)
	end

	if theme.AcrylicBlurEnabled ~= nil then
		self:SetAcrylicBlurEnabled(theme.AcrylicBlurEnabled == true)
	end

	if theme.BackgroundImage ~= nil or theme.BackgroundImageEnabled ~= nil or theme.BackgroundDim ~= nil then
		self:SetBackgroundImage(
			theme.BackgroundImage or self._theme.BackgroundImage,
			theme.BackgroundImageEnabled == true,
			theme.BackgroundDim or self._theme.BackgroundDim
		)
	end

	if theme.SkyEnabled ~= nil or theme.SkyPreset ~= nil then
		local skyEnabled = theme.SkyEnabled
		if skyEnabled == nil then
			skyEnabled = self._theme.SkyEnabled
		end
		self:SetSky(skyEnabled == true, theme.SkyPreset or self._theme.SkyPreset)
	end

	if self.container then
		self.container.BackgroundColor3 = c.Background
	end
	self:_RefreshFloatingBubbles()
	if self.headerLine then
		self.headerLine.BackgroundColor3 = c.Border
	end
	if self.separatorLine then
		self.separatorLine.BackgroundColor3 = c.Border
	end

	if self.container then
		for _, obj in ipairs(self.container:GetDescendants()) do
			if obj:IsA("Frame") then
				local name = obj.Name
				if name == "SliderFill" then
					obj.BackgroundColor3 = c.Accent
				elseif name == "SwitchBackground" then
					local isEnabled = obj:GetAttribute("Enabled") == true
					obj.BackgroundColor3 = isEnabled and c.Toggle.Enabled or c.Toggle.Disabled
					local circle = obj:FindFirstChild("Circle")
					if circle then
						circle.BackgroundColor3 = isEnabled and c.Background or c.Toggle.Circle
					end
				elseif name == "Container" then
					obj.BackgroundColor3 = c.Background
				elseif name == "Header" or name == "Separator" then
					obj.BackgroundColor3 = c.Border
				elseif name == "DividerLine" then
					obj.BackgroundColor3 = c.Border
				elseif name == "OptionsContainer" or name == "LanguageOptions" then
					obj.BackgroundColor3 = c.Secondary
					obj.BackgroundTransparency = 0.02
				elseif name == "PickerContainer" then
					obj.BackgroundColor3 = c.Secondary
					obj.BackgroundTransparency = 0.02
				elseif
					name:match("^Paragraph")
					or name:match("^Slider_")
					or name:match("^Toggle_")
					or name:match("^Button_")
					or name:match("^Dropdown_")
					or name:match("^TextBox_")
					or name:match("^ColorPicker_")
					or name:match("^Keybind_")
					or name:match("^Bubble_")
					or name == "SelectedDisplay"
					or name == "TextBoxContainer"
					or name == "LanguageSelect"
				then
					obj.BackgroundColor3 = c.Secondary
					obj.BackgroundTransparency = self._elementTransparency
				elseif name == "KeybindBox" then
					obj.BackgroundColor3 = c.Secondary
					obj.BackgroundTransparency = math.max(0.04, self._elementTransparency - 0.1)
				elseif obj.Parent and obj.Parent.Name == "TabsContainer" then
					obj.BackgroundColor3 = c.Secondary
					obj.BackgroundTransparency = self.currentTab
							and self.currentTab.button == obj
							and GetTabTransparency(self, "Active")
						or GetTabTransparency(self, "Rest")
				end
			elseif obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				if
					obj.Name == "Content"
					or obj.Name == "Section"
					or obj.Name:match("^Section_")
					or obj.Name == "DividerLabel"
					or obj.Name == "TabText"
					or obj.Name == "Label"
				then
					obj.TextColor3 = c.TextDark
				else
					obj.TextColor3 = c.Text
				end
				if obj.Name == "VersionTag" then
					obj.BackgroundColor3 = c.Secondary
					obj.BackgroundTransparency = self._elementTransparency
				end
			elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
				if obj.Name == "Resize" then
					obj.ImageColor3 = c.Accent
				elseif
					obj.Name == "Icon"
					or obj.Name == "Arrow"
					or obj.Name == "Minimize"
					or obj.Name == "Close"
					or obj.Name == "ClearButton"
				then
					obj.ImageColor3 = c.TextDark
				end
			elseif obj:IsA("UIStroke") then
				obj.Color = c.Border
				if obj.Name == "VersionTagStroke" then
					obj.Transparency = 0.35
				end
			elseif obj:IsA("UIGradient") then
				if obj.Parent and obj.Parent.Name == "TabText" then
					obj.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, c.TextDark),
						ColorSequenceKeypoint.new(0.65, c.TextDark),
						ColorSequenceKeypoint.new(1, c.TextFade),
					})
				end
			elseif obj:IsA("ScrollingFrame") then
				obj.ScrollBarImageColor3 = c.ScrollBar
				obj.BorderColor3 = c.Background
			end
		end
	end

	if self.screenGui then
		for _, obj in ipairs(self.screenGui:GetDescendants()) do
			local floatingContainer
			if obj.Name == "OptionsContainer" or obj.Name == "PickerContainer" or obj.Name == "LanguageOptions" then
				floatingContainer = obj
			else
				floatingContainer = obj:FindFirstAncestor("OptionsContainer")
					or obj:FindFirstAncestor("PickerContainer")
					or obj:FindFirstAncestor("LanguageOptions")
			end
			if floatingContainer then
				if
					obj:IsA("Frame")
					and (
						obj.Name == "OptionsContainer"
						or obj.Name == "PickerContainer"
						or obj.Name == "LanguageOptions"
					)
				then
					obj.BackgroundColor3 = c.Secondary
					obj.BackgroundTransparency = 0.02
				elseif obj:IsA("TextButton") then
					obj.TextColor3 = c.Text
					if obj:GetAttribute("MithrenDropdownOption") then
						local isSelected = obj:GetAttribute("MithrenOptionSelected") == true
						obj.BackgroundColor3 = c.Accent
						obj.BackgroundTransparency = isSelected and 0.72 or 1
					else
						obj.BackgroundColor3 = c.Secondary
					end
				elseif obj:IsA("ScrollingFrame") then
					obj.ScrollBarImageColor3 = c.ScrollBar
				elseif obj:IsA("UIStroke") then
					obj.Color = c.Border
				end
			end
		end
	end

	self:_RefreshCurrentTabStyle()
	task.delay(animationspeed.Fast + 0.03, function()
		self:_RefreshCurrentTabStyle()
	end)
	self:_RefreshSwitchStyles()
	task.delay(animationspeed.Normal + 0.04, function()
		self:_RefreshSwitchStyles()
	end)
end

function Library:GetTheme()
	return CloneTheme(self._theme)
end

function Library:_GetWindowState()
	if not self.container then
		return nil
	end
	local width = tonumber(self.container.Size.X.Offset)
	local height = tonumber((self.minimized and self._originalHeight) or self.container.Size.Y.Offset)
	if not width or not height then
		return nil
	end
	return {
		Width = math.floor(width + 0.5),
		Height = math.floor(height + 0.5),
	}
end

function Library:_ApplyWindowState(state)
	if type(state) ~= "table" or not self.container then
		return
	end
	local width = tonumber(state.Width or state.width)
	local height = tonumber(state.Height or state.height)
	if not width or not height then
		return
	end
	local metrics = GetResponsiveWindowMetrics()
	self._minSize = metrics.Min
	self._maxSize = metrics.Max
	width = math.clamp(width, self._minSize.X, self._maxSize.X)
	height = math.clamp(height, self._minSize.Y, self._maxSize.Y)
	self._windowSize = Vector2.new(width, height)
	self._originalHeight = height
	if not self.minimized then
		self.container.Size = UDim2.new(0, width, 0, height)
	end
end

function Library:ResetTheme()
	self:SetTheme({
		AccentColor = Color3.fromRGB(255, 255, 255),
		BackgroundColor = Color3.fromRGB(10, 10, 11),
		SecondaryColor = Color3.fromRGB(25, 25, 27),
		BorderColor = Color3.fromRGB(47, 47, 51),
		TextColor = Color3.fromRGB(255, 255, 255),
		MutedTextColor = Color3.fromRGB(155, 155, 162),
		ScrollBarColor = Color3.fromRGB(82, 82, 88),
		PanelTransparency = 0.03,
		ElementTransparency = 0.18,
		BackgroundImage = "",
		BackgroundImageEnabled = false,
		BackgroundDim = 0.45,
		AcrylicBlurEnabled = false,
		SkyEnabled = false,
		SkyPreset = "Starry night",
	})
end

function Library:_SetupResponsiveBounds()
	local function ApplyBounds()
		if not self.container then
			return
		end

		local metrics = GetResponsiveWindowMetrics()
		self._minSize = metrics.Min
		self._maxSize = metrics.Max

		if not IsMobileDevice() then
			return
		end

		local viewport = GetViewportSize()
		local width = math.clamp(self.container.Size.X.Offset, self._minSize.X, self._maxSize.X)
		local height = math.clamp(self.container.Size.Y.Offset, self._minSize.Y, self._maxSize.Y)

		width = math.min(width, math.max(viewport.X - 16, self._minSize.X))
		height = math.min(height, math.max(viewport.Y - 70, self._minSize.Y))

		self.container.Size = UDim2.new(0, width, 0, height)
		if not self.minimized then
			self._originalHeight = height
		end

		local absPos = self.container.AbsolutePosition
		local minX = 8
		local minY = 8
		local maxX = math.max(minX, viewport.X - width - 8)
		local maxY = math.max(minY, viewport.Y - height - 8)
		local targetX = math.clamp(absPos.X, minX, maxX)
		local targetY = math.clamp(absPos.Y, minY, maxY)

		self.container.Position = UDim2.new(0, targetX, 0, targetY)
	end

	ApplyBounds()

	if workspace.CurrentCamera then
		Track(self, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(ApplyBounds))
	end
end

function Library:_SetupSmartResize(handle)
	local c = self._c or c
	local resizing = false
	local resizeStart, startSize, startPos

	handle.MouseEnter:Connect(function()
		CreateTween(handle, { ImageColor3 = c.Text }, animationspeed.Fast)
	end)

	handle.MouseLeave:Connect(function()
		if not resizing then
			CreateTween(handle, { ImageColor3 = c.Accent }, animationspeed.Fast)
		end
	end)

	handle.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			resizing = true
			resizeStart = input.Position
			startSize = Vector2.new(self.container.Size.X.Offset, self.container.Size.Y.Offset)
			startPos = self.container.AbsolutePosition
			self._originalHeight = startSize.Y

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					resizing = false
					self:SaveConfig("__session", true)
					CreateTween(handle, { ImageColor3 = c.Accent }, animationspeed.Fast)
					if connection then
						connection:Disconnect()
					end
				end
			end)
		end
	end)

	Track(
		self,
		ui.InputChanged:Connect(function(input)
			if
				resizing
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				local delta = input.Position - resizeStart
				local newWidth = math.clamp(startSize.X + delta.X, self._minSize.X, self._maxSize.X)
				local newHeight = math.clamp(startSize.Y + delta.Y, self._minSize.Y, self._maxSize.Y)
				self.container.Size = UDim2.new(0, newWidth, 0, newHeight)
				self._originalHeight = newHeight
			end
		end)
	)
end

function Library:_ToggleMinimize()
	self.minimized = not self.minimized
	if self.minimized then
		if self._acrylicBlur then
			self._acrylicBlur:SetEnabled(false)
		end
		CreateTween(self.mainContent, { Size = UDim2.new(1, 0, 0, 0) }, animationspeed.Slow)
		CreateTween(self.container, { Size = UDim2.new(0, self.container.Size.X.Offset, 0, 45) }, animationspeed.Slow)
		if self.resizeBtn then
			self.resizeBtn.Visible = false
		end
	else
		if self._acrylicBlur and self._acrylicBlurEnabled then
			self._acrylicBlur:SetEnabled(true)
		end
		CreateTween(
			self.container,
			{ Size = UDim2.new(0, self.container.Size.X.Offset, 0, self._originalHeight) },
			animationspeed.Slow
		)
		task.delay(0.1, function()
			CreateTween(self.mainContent, { Size = UDim2.new(1, 0, 1, -46) }, animationspeed.Normal)
		end)
		if self.resizeBtn then
			self.resizeBtn.Visible = true
		end
	end
end

function Library:Destroy()
	if self._destroyStarted then
		return
	end
	self._destroyStarted = true
	self._isDestroying = true
	self:SaveConfig("__session", true)

	if self._instanceKey and _G[self._instanceKey] == self then
		_G[self._instanceKey] = nil
	end

	DisconnectAll(self)
	if self._languageInputConn then
		self._languageInputConn:Disconnect()
		self._languageInputConn = nil
	end

	if self._activeDropdown then
		self._activeDropdown()
	end
	if self._activePicker then
		self._activePicker()
	end
	if self._acrylicBlur then
		self._acrylicBlur:Destroy()
		self._acrylicBlur = nil
	end
	if self._skyApplied then
		self:_RestoreOriginalSky()
	end
	if self._notificationContainer then
		self._notificationContainer:Destroy()
		self._notificationContainer = nil
	end
	if self.screenGui then
		self.screenGui:Destroy()
	end
	PruneLucideRegistry()
end

function Library:_RegisterConfigElement(id, elementType, getValue, setValue)
	self._configElements[id] = {
		type = elementType,
		getValue = getValue,
		setValue = setValue,
	}
end

function SerializeConfigValue(value)
	if typeof(value) == "Color3" then
		return { R = value.R, G = value.G, B = value.B, _type = "Color3" }
	elseif typeof(value) == "EnumItem" then
		return { _type = "EnumItem", _enum = tostring(value.EnumType):gsub("^Enum%.", ""), _value = value.Name }
	elseif type(value) == "table" then
		local encoded = {}
		for key, item in pairs(value) do
			encoded[key] = SerializeConfigValue(item)
		end
		return encoded
	end
	return value
end

function DeserializeConfigValue(value)
	if type(value) == "table" and value._type == "Color3" then
		return Color3.new(value.R, value.G, value.B)
	elseif type(value) == "table" and value._type == "EnumItem" then
		local ok, result = pcall(function()
			local enumType = Enum[tostring(value._enum):gsub("^Enum%.", "")]
			return enumType and enumType[value._value] or nil
		end)
		return ok and result or nil
	elseif type(value) == "table" then
		local decoded = {}
		for key, item in pairs(value) do
			decoded[key] = DeserializeConfigValue(item)
		end
		return decoded
	end
	return value
end

function Library:SaveConfig(configName, silent)
	if not writefile then
		if not silent then
			self:Notify({ Title = "Error", Description = "File system is not available", Duration = 3 })
		end
		return false
	end

	EnsureConfigFolder(self.configFolder)

	local configData = {
		__theme = SerializeConfigValue(self:GetTheme()),
		__window = SerializeConfigValue(self:_GetWindowState()),
	}
	for id, element in pairs(self._configElements) do
		configData[id] = SerializeConfigValue(element.getValue())
	end

	local success = pcall(function()
		writefile(GetConfigPath(self.configFolder, configName), hs:JSONEncode(configData))
	end)

	if success then
		if configName ~= "__session" then
			self._currentConfig = configName
		end
		if not silent then
			self:Notify({
				Title = "Save saved",
				Description = '"' .. configName .. '" saved',
				Duration = 2,
				Icon = "save",
			})
		end
		return true
	else
		if not silent then
			self:Notify({ Title = "Error", Description = "Could not save", Duration = 3 })
		end
		return false
	end
end

function Library:LoadConfig(configName, silent)
	if not readfile or not isfile then
		if not silent then
			self:Notify({ Title = "Error", Description = "File system is not available", Duration = 3 })
		end
		return false
	end

	local path = GetConfigPath(self.configFolder, configName)
	if not isfile(path) then
		if not silent then
			self:Notify({ Title = "Error", Description = "Save not found: " .. configName, Duration = 3 })
		end
		return false
	end

	local success, data = pcall(function()
		return hs:JSONDecode(readfile(path))
	end)

	if not success or not data then
		if not silent then
			self:Notify({ Title = "Error", Description = "Could not load save", Duration = 3 })
		end
		return false
	end

	self._isLoading = true

	if data.__theme then
		self:SetTheme(DeserializeConfigValue(data.__theme))
	end

	if data.__window then
		self:_ApplyWindowState(DeserializeConfigValue(data.__window))
	end

	for id, value in pairs(data) do
		if id ~= "__theme" and id ~= "__window" and self._configElements[id] then
			pcall(function()
				self._configElements[id].setValue(DeserializeConfigValue(value))
			end)
		end
	end

	self._isLoading = false

	if configName ~= "__session" then
		self._currentConfig = configName
	end

	if not silent then
		self:Notify({
			Title = "Save loaded",
			Description = '"' .. configName .. '" loaded',
			Duration = 2,
			Icon = "save",
		})
	end
	return true
end

function Library:DeleteConfig(configName)
	if not delfile or not isfile then
		return false
	end

	local path = GetConfigPath(self.configFolder, configName)
	if isfile(path) then
		delfile(path)
		self:Notify({
			Title = "Config Deleted",
			Description = "Deleted: " .. configName,
			Duration = 2,
		})
		return true
	end
	return false
end

function Library:GetConfigs()
	return GetAvailableConfigs(self.configFolder)
end

function Library:SetAutoSave(enabled)
	self._autoSave = enabled
end

function Library:_AutoSaveTick()
	if self._isDestroying or self._isLoading or self._autoSavePending then
		return
	end
	self._autoSavePending = true
	task.delay(0.5, function()
		self._autoSavePending = false
		if not self._isDestroying and self.screenGui and self.screenGui.Parent then
			self:SaveConfig("__session", true)
		end
	end)
end

function Library:ExportConfig(configName)
	if not readfile or not isfile then
		self:Notify({ Title = "Export", Description = "File system is not available", Duration = 2.5 })
		return false
	end
	local path = GetConfigPath(self.configFolder, configName)
	if not isfile(path) then
		self:Notify({ Title = "Export", Description = "Save not found: " .. configName, Duration = 2.5 })
		return false
	end
	local ok, content = pcall(readfile, path)
	if ok and content and setclipboard then
		setclipboard(content)
		self:Notify({
			Title = "Export",
			Description = '"' .. configName .. '" copied to clipboard',
			Duration = 2.5,
			Icon = "save",
		})
		return true
	end
	self:Notify({ Title = "Export", Description = "Could not export", Duration = 2.5 })
	return false
end

function Library:ImportConfig(configName)
	if not getclipboard then
		self:Notify({ Title = "Import", Description = "Clipboard is not available in this executor", Duration = 2.5 })
		return false
	end
	local ok, json = pcall(getclipboard)
	if not ok or type(json) ~= "string" or json:gsub("%s", "") == "" then
		self:Notify({ Title = "Import", Description = "Clipboard is empty or invalid", Duration = 2.5 })
		return false
	end
	local ok2, data = pcall(function()
		return hs:JSONDecode(json)
	end)
	if not ok2 or type(data) ~= "table" then
		self:Notify({ Title = "Import", Description = "Invalid JSON in clipboard", Duration = 3 })
		return false
	end
	if not writefile then
		self:Notify({ Title = "Import", Description = "File system is not available", Duration = 2.5 })
		return false
	end
	EnsureConfigFolder(self.configFolder)
	local saveName = SanitizeConfigName(configName or "imported")
	local ok3 = pcall(function()
		writefile(GetConfigPath(self.configFolder, saveName), json)
	end)
	if ok3 then
		self:LoadConfig(saveName)
		return true
	end
	self:Notify({ Title = "Import", Description = "Could not save file", Duration = 3 })
	return false
end

function Library:CreateSection(name)
	local c = self._c or c
	local section = {
		name = name,
		tabs = {},
		expanded = true,
		_library = self,
	}

	local sectionFrame = CreateInstance("Frame", {
		Name = "Section_" .. name,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = self.sectionsContainer,
	})
	CreateListLayout(sectionFrame, 2, Enum.SortOrder.LayoutOrder)

	local headerContainer = CreateInstance("Frame", {
		Name = "HeaderContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 25),
		LayoutOrder = 0,
		Parent = sectionFrame,
	})

	local headerBtn = CreateInstance("TextButton", {
		Name = "Header",
		FontFace = f.Regular,
		TextColor3 = c.TextDark,
		Text = "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = headerContainer,
	})

	local headerLabel = CreateInstance("TextLabel", {
		Name = "Label",
		FontFace = f.Regular,
		TextColor3 = c.TextDark,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 5, 0, 0),
		TextSize = textsize.Small,
		Size = UDim2.new(1, -25, 1, 0),
		Parent = headerContainer,
	})

	local arrow = CreateInstance("ImageButton", {
		Name = "Arrow",
		Image = "",
		ImageColor3 = c.TextDark,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 0.5, -7),
		Size = UDim2.new(0, 15, 0, 15),
		Rotation = 0,
		Parent = headerContainer,
	})
	ApplyLucideIcon(arrow, "chevron-down", "chevron-down", 48)

	local tabsContainer = CreateInstance("Frame", {
		Name = "TabsContainer",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = false,
		LayoutOrder = 1,
		Parent = sectionFrame,
	})
	CreateListLayout(tabsContainer, 2, Enum.SortOrder.LayoutOrder)
	CreatePadding(tabsContainer, 0, 0, 2, 2)

	local function ToggleSection()
		section.expanded = not section.expanded
		CreateTween(arrow, { Rotation = section.expanded and 0 or 180 }, animationspeed.Normal)
		tabsContainer.Visible = section.expanded
	end

	headerBtn.MouseButton1Click:Connect(ToggleSection)
	arrow.MouseButton1Click:Connect(ToggleSection)

	section.frame = sectionFrame
	section.tabsContainer = tabsContainer
	table.insert(self.sections, section)

	local sectionMethods = setmetatable({}, { __index = section })

	function sectionMethods:CreateTab(tabName, icon)
		return Library._CreateTab(self, tabName, icon)
	end

	function sectionMethods:Tab(tabName, icon)
		return self:CreateTab(tabName, icon)
	end

	return sectionMethods
end

function Library._CreateTab(section, name, icon)
	local c = (section and section._library and section._library._c) or c
	local tab = {
		name = name,
		elements = {},
	}

	local tabBtn = CreateInstance("Frame", {
		Name = name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = GetTabTransparency(section._library, "Rest"),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -4, 0, s.Tab.Height),
		Parent = section.tabsContainer,
	})
	CreateCorner(tabBtn, 8)

	local tabStroke = CreateStroke(tabBtn, c.Border, 1)

	local iconLabel = CreateInstance("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = c.TextDark,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Parent = tabBtn,
	})
	ApplyLucideIcon(iconLabel, icon, "app-window", 48)

	local tabText = CreateInstance("TextLabel", {
		Name = "TabText",
		FontFace = f.Regular,
		TextColor3 = c.TextDark,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 36, 0, 0),
		Size = UDim2.new(1, -46, 1, 0),
		TextSize = textsize.Small,
		Parent = tabBtn,
	})

	CreateInstance("UIPadding", {
		PaddingRight = UDim.new(0, 9),
		Parent = tabText,
	})

	local textGradient = CreateInstance("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, c.TextDark),
			ColorSequenceKeypoint.new(0.65, c.TextDark),
			ColorSequenceKeypoint.new(1, c.TextFade),
		}),
		Enabled = false,
		Parent = tabText,
	})

	local clickBtn = CreateInstance("TextButton", {
		Name = "ClickButton",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = tabBtn,
	})

	tab.content = CreateInstance("Frame", {
		Name = name .. "_Content",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = section._library.contentContainer,
	})
	CreateListLayout(tab.content, 8, Enum.SortOrder.LayoutOrder)

	clickBtn.MouseButton1Click:Connect(function()
		Library._SelectTab(section._library, tab, tabBtn, tabStroke, iconLabel, tabText, textGradient)
	end)

	clickBtn.MouseEnter:Connect(function()
		if section._library.currentTab ~= tab then
			CreateTween(
				tabBtn,
				{ BackgroundTransparency = GetTabTransparency(section._library, "Hover") },
				animationspeed.Fast
			)
			CreateTween(tabStroke, { Color = c.Border, Transparency = 0.55 }, animationspeed.Fast)
		end
	end)

	clickBtn.MouseLeave:Connect(function()
		if section._library.currentTab ~= tab then
			CreateTween(
				tabBtn,
				{ BackgroundTransparency = GetTabTransparency(section._library, "Rest") },
				animationspeed.Fast
			)
			CreateTween(tabStroke, { Color = c.Border, Transparency = 1 }, animationspeed.Fast)
		end
	end)

	tab.button = tabBtn
	tab.stroke = tabStroke
	tab.icon = iconLabel
	tab.textLabel = tabText
	tab.textGradient = textGradient
	tab._library = section._library

	table.insert(section.tabs, tab)

	if not section._library.currentTab then
		Library._SelectTab(section._library, tab, tabBtn, tabStroke, iconLabel, tabText, textGradient)
	end

	local tabMethods = setmetatable({}, { __index = tab })

	function tabMethods:Select()
		Library._SelectTab(self._library, self, self.button, self.stroke, self.icon, self.textLabel, self.textGradient)
		return self
	end

	function tabMethods:CreateSection(sectionName)
		return Library._CreateContentSection(self, sectionName)
	end

	function tabMethods:CreateParagraph(config)
		return Library._CreateParagraph(self, config)
	end

	function tabMethods:CreateDivider(config)
		return Library._CreateDivider(self, config)
	end

	function tabMethods:CreateRow(config)
		return Library._CreateRow(self, config)
	end

	function tabMethods:CreateSlider(config)
		return Library._CreateSlider(self, config)
	end

	function tabMethods:CreateButton(config)
		return Library._CreateButton(self, config)
	end

	function tabMethods:CreateToggle(config)
		return Library._CreateToggle(self, config)
	end

	function tabMethods:CreateDropdown(config)
		return Library._CreateDropdown(self, config)
	end

	function tabMethods:CreateKeybind(config)
		return Library._CreateKeybind(self, config, section._library)
	end

	function tabMethods:CreateColorPicker(config)
		return Library._CreateColorPicker(self, config)
	end

	function tabMethods:CreateBubble(config)
		return Library._CreateBubble(self, config)
	end

	function tabMethods:CreateTextBox(config)
		return Library._CreateTextBox(self, config)
	end

	function tabMethods:CreateConfigSection(config)
		return Library._CreateConfigSection(self, config)
	end

	function tabMethods:Section(sectionName)
		return self:CreateSection(sectionName)
	end

	function tabMethods:Paragraph(title, content)
		if type(title) == "table" then
			return self:CreateParagraph(title)
		end
		return self:CreateParagraph({ Title = title, Content = content })
	end

	function tabMethods:Divider(name)
		return self:CreateDivider(name)
	end

	function tabMethods:Row(config)
		return self:CreateRow(config)
	end

	function tabMethods:Button(name, callback)
		if type(name) == "table" then
			return self:CreateButton(name)
		end
		return self:CreateButton({ Name = name, Callback = callback })
	end

	function tabMethods:Toggle(name, default, callback)
		if type(name) == "table" then
			return self:CreateToggle(name)
		end
		return self:CreateToggle({ Name = name, Default = default, Callback = callback })
	end

	function tabMethods:Slider(name, min, max, default, callback)
		if type(name) == "table" then
			return self:CreateSlider(name)
		end
		return self:CreateSlider({ Name = name, Min = min, Max = max, Default = default, Callback = callback })
	end

	function tabMethods:Dropdown(name, options, default, callback)
		if type(name) == "table" then
			return self:CreateDropdown(name)
		end
		return self:CreateDropdown({ Name = name, Options = options, Default = default, Callback = callback })
	end

	function tabMethods:MultiDropdown(name, options, default, callback)
		if type(name) == "table" then
			local config = shallowCopyConfig(name)
			config.MultiSelect = true
			return self:CreateDropdown(config)
		end
		return self:CreateDropdown({
			Name = name,
			Options = options,
			Default = default,
			MultiSelect = true,
			Callback = callback,
		})
	end

	function tabMethods:TextBox(name, placeholder, default, callback)
		if type(name) == "table" then
			return self:CreateTextBox(name)
		end
		return self:CreateTextBox({ Name = name, Placeholder = placeholder, Default = default, Callback = callback })
	end

	function tabMethods:NumberBox(name, placeholder, default, callback)
		if type(name) == "table" then
			local config = shallowCopyConfig(name)
			if config.NumbersOnly == nil then
				config.NumbersOnly = true
			end
			return self:CreateTextBox(config)
		end
		return self:CreateTextBox({
			Name = name,
			Placeholder = placeholder,
			Default = default,
			NumbersOnly = true,
			Callback = callback,
		})
	end

	function tabMethods:Keybind(name, default, callback)
		if type(name) == "table" then
			return self:CreateKeybind(name)
		end
		local handle
		handle = self:CreateKeybind({
			Name = name,
			Default = default,
			Callback = function()
				if type(callback) == "function" then
					callback(handle and handle:GetKey() or default)
				end
			end,
		})
		return handle
	end

	function tabMethods:ColorPicker(name, default, callback)
		if type(name) == "table" then
			return self:CreateColorPicker(name)
		end
		return self:CreateColorPicker({ Name = name, Default = default, Callback = callback })
	end

	function tabMethods:Bubble(name, default, activated)
		if type(name) == "table" then
			return self:CreateBubble(name)
		end
		return self:CreateBubble({ Name = name, Default = default, Activated = activated })
	end

	function tabMethods:ConfigSection(config)
		return self:CreateConfigSection(config)
	end

	return tabMethods
end

function Library._SelectTab(lib, tab, btn, stroke, icon, textLabel, textGradient)
	local c = (lib and lib._c) or c
	if lib.currentTab then
		lib.currentTab.content.Visible = false
		CreateTween(
			lib.currentTab.button,
			{ BackgroundTransparency = GetTabTransparency(lib, "Rest") },
			animationspeed.Fast
		)
		CreateTween(lib.currentTab.icon, { ImageColor3 = c.TextDark }, animationspeed.Fast)
		CreateTween(lib.currentTab.stroke, { Color = c.Border, Transparency = 1 }, animationspeed.Fast)
		lib.currentTab.textLabel.TextColor3 = c.TextDark

		if lib.currentTab.textGradient then
			lib.currentTab.textGradient.Enabled = false
		end
	end

	lib.currentTab = tab
	tab.content.Visible = true
	if lib.contentContainer then
		lib.contentContainer.CanvasPosition = Vector2.new(0, 0)
	end

	btn.BackgroundColor3 = c.Secondary
	CreateTween(btn, { BackgroundTransparency = GetTabTransparency(lib, "Active") }, animationspeed.Fast)
	CreateTween(icon, { ImageColor3 = c.Text }, animationspeed.Fast)
	CreateTween(stroke, { Color = c.Accent, Transparency = 0.35 }, animationspeed.Fast)

	if textGradient then
		textGradient.Enabled = false
	end
	textLabel.TextColor3 = c.Text
end

function Library._CreateContentSection(tab, name)
	local c = (tab and tab._library and tab._library._c) or c
	local section = CreateInstance("TextLabel", {
		Name = "Section_" .. name,
		FontFace = f.Regular,
		TextColor3 = c.TextDark,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		TextSize = 15,
		Size = UDim2.new(1, 0, 0, 25),
		Parent = tab.content,
	})
	return section
end

function Library._CreateDivider(tab, config)
	local c = (tab and tab._library and tab._library._c) or c
	local title = ""
	if type(config) == "table" then
		title = tostring(config.Name or config.Title or config.Text or "")
	elseif config ~= nil then
		title = tostring(config)
	end

	local frame = CreateInstance("Frame", {
		Name = "Divider",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, title ~= "" and 28 or 14),
		Parent = tab.content,
	})

	local label
	if title ~= "" then
		label = CreateInstance("TextLabel", {
			Name = "DividerLabel",
			FontFace = f.Regular,
			TextColor3 = c.TextDark,
			Text = title,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1,
			TextSize = textsize.Small,
			Size = UDim2.new(1, 0, 0, 17),
			Parent = frame,
		})
	end

	local line = CreateInstance("Frame", {
		Name = "DividerLine",
		BackgroundColor3 = c.Border,
		BackgroundTransparency = 0.25,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, title ~= "" and 23 or 7),
		Size = UDim2.new(1, 0, 0, 1),
		Parent = frame,
	})

	return {
		Frame = frame,
		SetText = function(_, newText)
			newText = tostring(newText or "")
			if not label and newText ~= "" then
				frame.Size = UDim2.new(1, 0, 0, 28)
				line.Position = UDim2.new(0, 0, 0, 23)
				label = CreateInstance("TextLabel", {
					Name = "DividerLabel",
					FontFace = f.Regular,
					TextColor3 = c.TextDark,
					Text = newText,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1,
					TextSize = textsize.Small,
					Size = UDim2.new(1, 0, 0, 17),
					Parent = frame,
				})
			elseif label then
				label.Text = newText
			end
		end,
		SetTitle = function(self, newText)
			return self:SetText(newText)
		end,
		Destroy = function()
			frame:Destroy()
		end,
	}
end

function Library._CreateRow(tab, config)
	local rowConfig = {}
	if type(config) == "number" then
		rowConfig.Columns = config
	elseif type(config) == "table" then
		rowConfig = shallowCopyConfig(config)
	end

	local columns = math.clamp(math.floor(tonumber(rowConfig.Columns or rowConfig.Count or 2) or 2), 1, 3)
	local gap = math.max(0, tonumber(rowConfig.Gap or 8) or 8)
	local widthOffset = -((gap * (columns - 1)) / columns)

	local rowFrame = CreateInstance("Frame", {
		Name = "ComponentRow",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = tab.content,
	})
	rowFrame:SetAttribute("MithrenComponentRow", true)
	rowFrame:SetAttribute("MithrenComponentRowColumns", columns)

	local layout = CreateListLayout(rowFrame, gap, Enum.SortOrder.LayoutOrder, Enum.FillDirection.Horizontal)
	layout.VerticalAlignment = Enum.VerticalAlignment.Top

	local function syncRowHeight()
		rowFrame.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y)
	end
	Track(tab._library, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncRowHeight))
	task.defer(syncRowHeight)

	local function prepareConfig(itemConfig)
		local nextConfig = type(itemConfig) == "table" and shallowCopyConfig(itemConfig) or { Name = tostring(itemConfig or "") }
		nextConfig.Parent = rowFrame
		nextConfig.WidthScale = 1 / columns
		nextConfig.WidthOffset = widthOffset
		if nextConfig.Compact == nil then
			nextConfig.Compact = true
		end
		return nextConfig
	end

	local rowMethods = {
		Frame = rowFrame,
		Columns = columns,
	}

	function rowMethods:CreateButton(itemConfig)
		return Library._CreateButton(tab, prepareConfig(itemConfig))
	end

	function rowMethods:CreateToggle(itemConfig)
		return Library._CreateToggle(tab, prepareConfig(itemConfig))
	end

	function rowMethods:CreateSlider(itemConfig)
		return Library._CreateSlider(tab, prepareConfig(itemConfig))
	end

	function rowMethods:CreateDropdown(itemConfig)
		return Library._CreateDropdown(tab, prepareConfig(itemConfig))
	end

	function rowMethods:CreateKeybind(itemConfig)
		return Library._CreateKeybind(tab, prepareConfig(itemConfig), tab._library)
	end

	function rowMethods:CreateColorPicker(itemConfig)
		return Library._CreateColorPicker(tab, prepareConfig(itemConfig))
	end

	function rowMethods:CreateBubble(itemConfig)
		return Library._CreateBubble(tab, prepareConfig(itemConfig))
	end

	function rowMethods:CreateTextBox(itemConfig)
		return Library._CreateTextBox(tab, prepareConfig(itemConfig))
	end

	function rowMethods:Button(name, callback)
		if type(name) == "table" then
			return self:CreateButton(name)
		end
		return self:CreateButton({ Name = name, Callback = callback })
	end

	function rowMethods:Toggle(name, default, callback)
		if type(name) == "table" then
			return self:CreateToggle(name)
		end
		return self:CreateToggle({ Name = name, Default = default, Callback = callback })
	end

	function rowMethods:Slider(name, min, max, default, callback)
		if type(name) == "table" then
			return self:CreateSlider(name)
		end
		return self:CreateSlider({ Name = name, Min = min, Max = max, Default = default, Callback = callback })
	end

	function rowMethods:Dropdown(name, options, default, callback)
		if type(name) == "table" then
			return self:CreateDropdown(name)
		end
		return self:CreateDropdown({ Name = name, Options = options, Default = default, Callback = callback })
	end

	function rowMethods:Keybind(name, default, callback)
		if type(name) == "table" then
			return self:CreateKeybind(name)
		end
		return self:CreateKeybind({ Name = name, Default = default, Callback = callback })
	end

	function rowMethods:ColorPicker(name, default, callback)
		if type(name) == "table" then
			return self:CreateColorPicker(name)
		end
		return self:CreateColorPicker({ Name = name, Default = default, Callback = callback })
	end

	function rowMethods:Bubble(name, default, activated)
		if type(name) == "table" then
			return self:CreateBubble(name)
		end
		return self:CreateBubble({ Name = name, Default = default, Activated = activated })
	end

	function rowMethods:TextBox(name, placeholder, default, callback)
		if type(name) == "table" then
			return self:CreateTextBox(name)
		end
		return self:CreateTextBox({ Name = name, Placeholder = placeholder, Default = default, Callback = callback })
	end

	if type(rowConfig.Elements) == "table" then
		for _, element in ipairs(rowConfig.Elements) do
			if type(element) == "table" then
				local elementType = tostring(element.Type or element.Kind or "")
				element.Type = nil
				element.Kind = nil
				if elementType == "Toggle" then
					rowMethods:CreateToggle(element)
				elseif elementType == "Slider" then
					rowMethods:CreateSlider(element)
				elseif elementType == "Dropdown" then
					rowMethods:CreateDropdown(element)
				elseif elementType == "Keybind" then
					rowMethods:CreateKeybind(element)
				elseif elementType == "ColorPicker" or elementType == "Color" then
					rowMethods:CreateColorPicker(element)
				elseif elementType == "Bubble" then
					rowMethods:CreateBubble(element)
				elseif elementType == "TextBox" or elementType == "Input" then
					rowMethods:CreateTextBox(element)
				else
					rowMethods:CreateButton(element)
				end
			end
		end
	end

	return rowMethods
end

function Library._CreateParagraph(tab, config)
	local c = (tab and tab._library and tab._library._c) or c
	local title = config.Title or "Paragraph"
	local content = config.Content or "Description text here."
	local parent = ResolveElementParent(tab, config)

	local frame = CreateInstance("Frame", {
		Name = "Paragraph",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = ResolveElementSize(config, parent, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame)
	CreatePadding(frame, 12, 12, 12, 12)

	local titleLabel = CreateInstance("TextLabel", {
		Name = "Title",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = title,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		TextSize = textsize.Normal,
		Size = UDim2.new(1, 0, 0, 21),
		Parent = frame,
	})

	local contentLabel = CreateInstance("TextLabel", {
		Name = "Content",
		FontFace = f.Regular,
		TextColor3 = c.TextDark,
		Text = content,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		BackgroundTransparency = 1,
		TextSize = textsize.Small,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = frame,
	})

	return {
		SetTitle = function(_, newTitle)
			titleLabel.Text = newTitle
		end,
		SetContent = function(_, newContent)
			contentLabel.Text = newContent
		end,
	}
end

function Library._CreateSlider(tab, config)
	local c = (tab and tab._library and tab._library._c) or c
	local name = config.Name or "Slider"
	local min = config.Min or 0
	local max = config.Max or 100
	local default = config.Default or 50
	local parent = ResolveElementParent(tab, config)
	local compact = IsCompactElement(config, parent)
	local dense = IsDenseCompactElement(config, parent)

	local range = (max - min) ~= 0 and (max - min) or 1
	local _lib = tab and tab._library
	local _origCb = config.Callback or function() end
	local callback = function(...)
		if _lib and _lib._isDestroying then
			return
		end
		_origCb(...)
		if _lib and (config.AutoSave or _lib._autoSave) then
			_lib:_AutoSaveTick()
		end
	end
	local flag = config.Flag
	local currentValue = default

	local frame = CreateInstance("Frame", {
		Name = "Slider_" .. name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = ResolveElementSize(config, parent, compact and s.Button.Height or s.Slider.Height),
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame)

	local nameLabel = CreateInstance("TextLabel", {
		Name = "Name",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 5),
		TextSize = compact and textsize.Small or textsize.Normal,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, dense and -58 or -72, 0, 20),
		Parent = frame,
	})

	local valueLabel = CreateInstance("TextLabel", {
		Name = "Value",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = tostring(currentValue),
		TextXAlignment = Enum.TextXAlignment.Right,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -60, 0, 5),
		TextSize = compact and textsize.Small or textsize.Normal,
		Size = UDim2.new(0, 50, 0, 20),
		Parent = frame,
	})

	local sliderBg = CreateInstance("Frame", {
		Name = "SliderBackground",
		BackgroundColor3 = Color3.fromRGB(8, 8, 9),
		Position = UDim2.new(0, 10, 0, compact and 28 or 29),
		BorderSizePixel = 0,
		Size = UDim2.new(1, -20, 0, compact and 5 or 6),
		Parent = frame,
	})
	CreateCorner(sliderBg, 100)

	local sliderFill = CreateInstance("Frame", {
		Name = "SliderFill",
		BackgroundColor3 = c.Accent,
		BorderSizePixel = 0,
		Size = UDim2.new(math.clamp((default - min) / range, 0, 1), 0, 1, 0),
		Parent = sliderBg,
	})
	CreateCorner(sliderFill, 100)

	local dragging = false

	local function UpdateSlider(input)
		local pos = input.Position
		local framePos = sliderBg.AbsolutePosition
		local frameSize = sliderBg.AbsoluteSize
		local relativeX = math.clamp((pos.X - framePos.X) / frameSize.X, 0, 1)
		currentValue = math.floor(min + (max - min) * relativeX)
		CreateTween(sliderFill, { Size = UDim2.new(relativeX, 0, 1, 0) }, 0.05)
		valueLabel.Text = tostring(currentValue)
		callback(currentValue)
	end

	sliderBg.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			UpdateSlider(input)
		end
	end)

	sliderBg.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = false
		end
	end)

	Track(
		_lib,
		ui.InputChanged:Connect(function(input)
			if
				dragging
				and (
					input.UserInputType == Enum.UserInputType.MouseMovement
					or input.UserInputType == Enum.UserInputType.Touch
				)
			then
				UpdateSlider(input)
			end
		end)
	)

	local methods = {
		SetValue = function(_, value)
			currentValue = math.clamp(value, min, max)
			local relativeX = (currentValue - min) / range
			sliderFill.Size = UDim2.new(relativeX, 0, 1, 0)
			valueLabel.Text = tostring(currentValue)
			callback(currentValue)
		end,
		GetValue = function()
			return currentValue
		end,
	}

	if flag and tab._library then
		tab._library:_RegisterConfigElement(flag, "Slider", function()
			return currentValue
		end, function(value)
			methods:SetValue(value)
		end)
	end

	return methods
end

local function GetActionLabel(name)
	local text = tostring(name or "A"):gsub("^%s+", ""):gsub("%s+$", "")
	local parts = {}
	for word in text:gmatch("%S+") do
		parts[#parts + 1] = word
	end
	if #parts >= 2 then
		return string.upper(string.sub(parts[1], 1, 1) .. string.sub(parts[2], 1, 1))
	end
	return string.upper(string.sub(text, 1, math.min(#text, 2)))
end

function Library._CreateBubble(tab, config)
	local lib = tab and tab._library
	local c = (lib and lib._c) or c
	local name = config.Name or "Bubble"
	local labelText = config.Label or config.Text or name
	local bubbleText = config.BubbleText or GetActionLabel(name)
	local enabled = config.Default == true
	local active = config.Active == true
	local flag = config.Flag
	local parent = ResolveElementParent(tab, config)
	local compact = IsCompactElement(config, parent)
	local onChanged = config.Callback
	local onActivated = config.Activated or config.OnActivated
	local floatingButton
	local floatingGui

	local frame = CreateInstance("Frame", {
		Name = "Bubble_" .. name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = ResolveElementSize(config, parent, s.Button.Height),
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame)

	local label = CreateInstance("TextLabel", {
		Name = "Name",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = labelText,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextSize = compact and textsize.Small or textsize.Normal,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -72, 1, 0),
		Parent = frame,
	})

	local switchBg = CreateInstance("Frame", {
		Name = "SwitchBackground",
		BackgroundColor3 = enabled and c.Toggle.Enabled or c.Toggle.Disabled,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, s.Toggle.Width, 0, s.Toggle.Height),
		Parent = frame,
	})
	switchBg:SetAttribute("Enabled", enabled == true)
	CreateCorner(switchBg, 100)

	local switchCircle = CreateInstance("Frame", {
		Name = "Circle",
		BackgroundColor3 = enabled and c.Background or c.Toggle.Circle,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = enabled and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, s.Toggle.Circle, 0, s.Toggle.Circle),
		Parent = switchBg,
	})
	CreateCorner(switchCircle, 100)

	local button = CreateInstance("TextButton", {
		Name = "Button",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = frame,
	})

	local function updateFloatingVisual()
		if not floatingButton then
			return
		end
		floatingButton:SetAttribute("MithrenBubbleActive", active == true)
		floatingButton.BackgroundColor3 = active and c.Accent or c.Secondary
		floatingButton.TextColor3 = active and c.Background or c.Text
		local stroke = floatingButton:FindFirstChildOfClass("UIStroke")
		if stroke then
			stroke.Color = active and c.Accent or c.Border
			stroke.Transparency = active and 0.05 or 0.25
		end
	end

	local function ensureFloating()
		if not enabled or not lib or not lib.screenGui then
			return
		end
		if floatingGui and floatingGui.Parent then
			updateFloatingVisual()
			return
		end
		floatingGui = CreateInstance("Frame", {
			Name = "ActionBubble_" .. tostring(name),
			BackgroundTransparency = 1,
			Position = config.Position or UDim2.new(1, -84, 0.5, -22),
			Size = UDim2.new(0, 46, 0, 46),
			ZIndex = 9998,
			Parent = lib.screenGui,
		})

		floatingButton = CreateInstance("TextButton", {
			Name = "Button",
			FontFace = f.Semi,
			Text = bubbleText,
			TextSize = textsize.Normal,
			BackgroundColor3 = c.Secondary,
			BackgroundTransparency = 0.04,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 9999,
			Parent = floatingGui,
		})
		CreateCorner(floatingButton, 100)
		CreateStroke(floatingButton, c.Border, 0.25)
		updateFloatingVisual()

		local dragging = false
		local moved = false
		local dragInput, dragStart, startPos
		floatingButton.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragging = true
				moved = false
				dragInput = input
				dragStart = input.Position
				startPos = floatingGui.Position
			end
		end)
		floatingButton.InputEnded:Connect(function(input)
			if input == dragInput then
				dragging = false
				dragInput = nil
				if not moved and type(onActivated) == "function" then
					onActivated()
				end
			end
		end)
		Track(
			lib,
			ui.InputChanged:Connect(function(input)
				if
					dragging
					and (
						input.UserInputType == Enum.UserInputType.MouseMovement
						or input.UserInputType == Enum.UserInputType.Touch
					)
				then
					local delta = input.Position - dragStart
					if delta.Magnitude > 4 then
						moved = true
					end
					floatingGui.Position = UDim2.new(
						startPos.X.Scale,
						startPos.X.Offset + delta.X,
						startPos.Y.Scale,
						startPos.Y.Offset + delta.Y
					)
				end
			end)
		)
		Track(lib, floatingGui)
	end

	local methods = {}

	function methods:SetEnabled(value)
		enabled = value == true
		switchBg:SetAttribute("Enabled", enabled == true)
		if enabled then
			CreateTween(switchBg, { BackgroundColor3 = c.Toggle.Enabled }, animationspeed.Normal)
			CreateTween(
				switchCircle,
				{ Position = UDim2.new(0, 21, 0.5, 0), BackgroundColor3 = c.Background },
				animationspeed.Normal
			)
		else
			CreateTween(switchBg, { BackgroundColor3 = c.Toggle.Disabled }, animationspeed.Normal)
			CreateTween(
				switchCircle,
				{ Position = UDim2.new(0, 4, 0.5, 0), BackgroundColor3 = c.Toggle.Circle },
				animationspeed.Normal
			)
		end
		if enabled then
			ensureFloating()
		elseif floatingGui then
			pcall(function()
				floatingGui:Destroy()
			end)
			floatingGui = nil
			floatingButton = nil
		end
	end

	function methods:GetEnabled()
		return enabled
	end

	function methods:SetActive(value)
		active = value == true
		updateFloatingVisual()
	end

	button.MouseButton1Click:Connect(function()
		methods:SetEnabled(not enabled)
		if type(onChanged) == "function" then
			onChanged(enabled)
		end
	end)

	methods:SetEnabled(enabled)

	if flag and lib then
		lib:_RegisterConfigElement(flag, "Toggle", function()
			return enabled
		end, function(value)
			methods:SetEnabled(value == true)
		end)
	end

	return methods
end

function Library._CreateButton(tab, config)
	local c = (tab and tab._library and tab._library._c) or c
	local name = config.Name or "Button"
	local callback = config.Callback or function() end
	local parent = ResolveElementParent(tab, config)
	local compact = IsCompactElement(config, parent)

	local frame = CreateInstance("Frame", {
		Name = "Button_" .. name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = ResolveElementSize(config, parent, s.Button.Height),
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame, c.Border, 0.35)

	local nameLabel = CreateInstance("TextLabel", {
		Name = "Name",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, -10),
		TextSize = compact and textsize.Small or textsize.Normal,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -86, 0, 20),
		Parent = frame,
	})

	local icon = CreateInstance("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = c.Text,
		Position = UDim2.new(1, -30, 0.5, -10),
		Size = UDim2.new(0, 20, 0, 20),
		Visible = true,
		Parent = frame,
	})
	ApplyLucideIcon(icon, config.Icon or "mouse-pointer-click", "mouse-pointer-click", 48)
	CreateInstance("UIAspectRatioConstraint", {
		Parent = icon,
	})

	local button = CreateInstance("TextButton", {
		Name = "Button",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = frame,
	})

	button.MouseButton1Click:Connect(function()
		CreateTween(frame, { BackgroundTransparency = 0.08 }, animationspeed.Fast)
		task.wait(0.1)
		CreateTween(frame, { BackgroundTransparency = 0.18 }, animationspeed.Fast)
		callback()
	end)

	local methods = {
		SetText = function(_, text)
			nameLabel.Text = text
		end,
	}

	return methods
end

function Library._CreateToggle(tab, config)
	local c = (tab and tab._library and tab._library._c) or c
	local name = config.Name or "Toggle"
	local default = config.Default or false
	local parent = ResolveElementParent(tab, config)
	local compact = IsCompactElement(config, parent)
	local _lib = tab and tab._library
	local _origCb = config.Callback or function() end
	local callback = function(...)
		if _lib and _lib._isDestroying then
			return
		end
		_origCb(...)
		if _lib and (config.AutoSave or _lib._autoSave) then
			_lib:_AutoSaveTick()
		end
	end
	local flag = config.Flag
	local enabled = default

	local frame = CreateInstance("Frame", {
		Name = "Toggle_" .. name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = ResolveElementSize(config, parent, s.Button.Height),
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame, c.Border, 0.35)

	local nameLabel = CreateInstance("TextLabel", {
		Name = "Name",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, -10),
		TextSize = compact and textsize.Small or textsize.Normal,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(1, -72, 0, 20),
		Parent = frame,
	})

	local switchBg = CreateInstance("Frame", {
		Name = "SwitchBackground",
		BackgroundColor3 = enabled and c.Toggle.Enabled or c.Toggle.Disabled,
		Position = UDim2.new(1, -52, 0.5, -10),
		BorderSizePixel = 0,
		Size = UDim2.new(0, s.Toggle.Width, 0, s.Toggle.Height),
		Parent = frame,
	})
	switchBg:SetAttribute("Enabled", enabled == true)
	CreateCorner(switchBg, 100)

	local switchCircle = CreateInstance("Frame", {
		Name = "Circle",
		BackgroundColor3 = enabled and c.Background or c.Toggle.Circle,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = enabled and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, s.Toggle.Circle, 0, s.Toggle.Circle),
		Parent = switchBg,
	})
	CreateCorner(switchCircle, 100)

	local toggleBtn = CreateInstance("TextButton", {
		Name = "ToggleButton",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = switchCircle,
	})

	local button = CreateInstance("TextButton", {
		Name = "Button",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Parent = frame,
	})

	local function UpdateToggle()
		switchBg:SetAttribute("Enabled", enabled == true)
		if enabled then
			CreateTween(switchBg, { BackgroundColor3 = c.Toggle.Enabled }, animationspeed.Normal)
			CreateTween(
				switchCircle,
				{ Position = UDim2.new(0, 21, 0.5, 0), BackgroundColor3 = c.Background },
				animationspeed.Normal
			)
		else
			CreateTween(switchBg, { BackgroundColor3 = c.Toggle.Disabled }, animationspeed.Normal)
			CreateTween(
				switchCircle,
				{ Position = UDim2.new(0, 4, 0.5, 0), BackgroundColor3 = c.Toggle.Circle },
				animationspeed.Normal
			)
		end
	end

	local function ToggleValue()
		enabled = not enabled
		UpdateToggle()
		callback(enabled)
	end

	button.MouseButton1Click:Connect(function()
		ToggleValue()
	end)

	local methods = {
		SetValue = function(_, value)
			enabled = value
			UpdateToggle()
			callback(enabled)
		end,
		GetValue = function()
			return enabled
		end,
	}

	if flag and tab._library then
		tab._library:_RegisterConfigElement(flag, "Toggle", function()
			return enabled
		end, function(value)
			methods:SetValue(value)
		end)
	end

	return methods
end

function Library._CreateDropdown(tab, config)
	local c = (tab and tab._library and tab._library._c) or c
	local name = config.Name or "Dropdown"
	local options = config.Options or { "Option 1", "Option 2", "Option 3" }
	local default = config.Default or options[1]
	local multiSelect = config.MultiSelect or false
	local parent = ResolveElementParent(tab, config)
	local compact = IsCompactElement(config, parent)
	local dense = IsDenseCompactElement(config, parent)
	local _lib = tab and tab._library
	local _origCb = config.Callback or function() end
	local callback = function(...)
		if _lib and _lib._isDestroying then
			return
		end
		_origCb(...)
		if _lib and (config.AutoSave or _lib._autoSave) then
			_lib:_AutoSaveTick()
		end
	end
	local flag = config.Flag
	local selected = multiSelect and {} or default
	local expanded = false

	local dropScrollConn, dropInputConn
	local CloseDropdown

	local activeHolder = _lib or Library

	if multiSelect and type(default) == "table" then
		selected = {}
		for _, v in ipairs(default) do
			table.insert(selected, v)
		end
	elseif multiSelect then
		selected = {}
	end

	local frame = CreateInstance("Frame", {
		Name = "Dropdown_" .. name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = ResolveElementSize(config, parent, s.Dropdown.Height),
		ClipsDescendants = false,
		ZIndex = 1,
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame)

	local nameLabel = CreateInstance("TextLabel", {
		Name = "Name",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 10),
		TextSize = compact and textsize.Small or textsize.Normal,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = not dense,
		Size = compact and UDim2.new(1, -132, 0, 20) or UDim2.new(0, 200, 0, 20),
		ZIndex = 1,
		Parent = frame,
	})

	local compactIcon = CreateInstance("ImageLabel", {
		Name = "CompactIcon",
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = c.TextDark,
		Position = UDim2.new(0, 12, 0.5, -8),
		Size = UDim2.new(0, 16, 0, 16),
		Visible = dense,
		ZIndex = 2,
		Parent = frame,
	})
	ApplyLucideIcon(compactIcon, config.Icon or "list-filter", "list-filter", 48)

	local selectedDisplay = CreateInstance("Frame", {
		Name = "SelectedDisplay",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.08,
		Position = dense and UDim2.new(0, 34, 0, 6)
			or (compact and UDim2.new(1, -122, 0, 6) or UDim2.new(1, -145, 0, 6)),
		BorderSizePixel = 0,
		Size = dense and UDim2.new(1, -44, 0, 26)
			or (compact and UDim2.new(0, 112, 0, 26) or UDim2.new(0, 135, 0, 26)),
		ZIndex = 2,
		Parent = frame,
	})
	CreateCorner(selectedDisplay, 8)
	CreateStroke(selectedDisplay)

	local selectedLabel = CreateInstance("TextLabel", {
		Name = "SelectedLabel",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = multiSelect and (#selected > 0 and table.concat(selected, ", ") or "None") or tostring(selected),
		TextTruncate = Enum.TextTruncate.AtEnd,
		BackgroundTransparency = 1,
		TextSize = textsize.Small,
		Size = UDim2.new(1, -30, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 2,
		Parent = selectedDisplay,
	})

	local arrow = CreateInstance("ImageLabel", {
		Name = "Arrow",
		Image = "",
		ImageColor3 = c.TextDark,
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -20, 0.5, -5),
		Size = UDim2.new(0, 10, 0, 10),
		Rotation = 0,
		ZIndex = 2,
		Parent = selectedDisplay,
	})
	ApplyLucideIcon(arrow, "chevron-down", "chevron-down", 48)

	local maxVisibleOptions = 5
	local containerHeight = math.min(#options * s.Dropdown.OptionHeight, maxVisibleOptions * s.Dropdown.OptionHeight)
	local dropdownPopupWidth = compact and 112 or 135

	local screenGui = tab.content:FindFirstAncestorOfClass("ScreenGui") or tab.content

	local optionsContainer = CreateInstance("Frame", {
		Name = "OptionsContainer",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.02,
		Position = UDim2.new(0, 0, 0, 0),
		BorderSizePixel = 0,
		Size = UDim2.new(0, dropdownPopupWidth, 0, containerHeight),
		Visible = false,
		ZIndex = 5000,
		ClipsDescendants = true,
		Parent = screenGui,
	})
	CreateCorner(optionsContainer, 8)
	CreateStroke(optionsContainer)

	local optionsScroll = CreateInstance("ScrollingFrame", {
		Name = "OptionsScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, #options * s.Dropdown.OptionHeight),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = c.ScrollBar,
		ZIndex = 5001,
		Parent = optionsContainer,
	})
	CreateListLayout(optionsScroll, 0, Enum.SortOrder.LayoutOrder)

	local optionButtons = {}

	local function IsOptionSelected(option)
		if multiSelect then
			return table.find(selected, option) ~= nil
		end
		return selected == option
	end

	local function UpdateOptionStates()
		for _, data in ipairs(optionButtons) do
			local isSelected = IsOptionSelected(data.Option)
			data.Button:SetAttribute("MithrenOptionSelected", isSelected)
			data.Button.BackgroundColor3 = c.Accent
			data.Button.BackgroundTransparency = isSelected and 0.72 or 1
			data.Button.TextColor3 = c.Text
		end
	end

	local function UpdateSelectedText()
		if multiSelect then
			selectedLabel.Text = #selected > 0 and table.concat(selected, ", ") or "None"
		else
			selectedLabel.Text = selected ~= nil and tostring(selected) or "None"
		end
		UpdateOptionStates()
	end

	local function CreateOptionButton(option)
		local optionText = tostring(option)
		local optionBtn = CreateInstance("TextButton", {
			Name = optionText,
			FontFace = f.Regular,
			TextColor3 = c.Text,
			Text = optionText,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			TextSize = textsize.Small,
			Size = UDim2.new(1, 0, 0, s.Dropdown.OptionHeight),
			ZIndex = 5002,
			Parent = optionsScroll,
		})
		optionBtn:SetAttribute("MithrenDropdownOption", true)
		CreateCorner(optionBtn, 6)
		CreatePadding(optionBtn, 0, 0, 10, 10)

		table.insert(optionButtons, {
			Button = optionBtn,
			Option = option,
		})

		optionBtn.MouseEnter:Connect(function()
			local isSelected = IsOptionSelected(option)
			CreateTween(optionBtn, { BackgroundTransparency = isSelected and 0.6 or 0.68 }, animationspeed.Fast)
			CreateTween(optionBtn, { TextColor3 = c.Text }, animationspeed.Fast)
		end)

		optionBtn.MouseLeave:Connect(function()
			local isSelected = IsOptionSelected(option)
			CreateTween(optionBtn, { BackgroundTransparency = isSelected and 0.72 or 1 }, animationspeed.Fast)
			CreateTween(optionBtn, { TextColor3 = c.Text }, animationspeed.Fast)
		end)

		optionBtn.MouseButton1Click:Connect(function()
			if multiSelect then
				local index = table.find(selected, option)
				if index then
					table.remove(selected, index)
				else
					table.insert(selected, option)
				end
				UpdateSelectedText()
				callback(selected)
			else
				selected = option
				UpdateSelectedText()
				callback(selected)
				if CloseDropdown then
					CloseDropdown()
				else
					expanded = false
					optionsContainer.Visible = false
					CreateTween(arrow, { Rotation = 0 }, animationspeed.Normal)
				end
			end
		end)

		UpdateOptionStates()
		return optionBtn
	end

	for _, option in ipairs(options) do
		CreateOptionButton(option)
	end

	local toggleBtn = CreateInstance("TextButton", {
		Name = "ToggleBtn",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 3,
		Parent = selectedDisplay,
	})

	local function UpdateDropdownPosition()
		local scrollFrame = tab.content.Parent
		local sfPos = scrollFrame.AbsolutePosition
		local sfSize = scrollFrame.AbsoluteSize
		local absPos = selectedDisplay.AbsolutePosition
		local absSize = selectedDisplay.AbsoluteSize
		local midY = absPos.Y + absSize.Y / 2
		if midY < sfPos.Y or midY > sfPos.Y + sfSize.Y then
			CloseDropdown()
			return
		end
		local viewport = workspace.CurrentCamera.ViewportSize
		local targetX = absPos.X
		local targetY = absPos.Y + absSize.Y + 2
		if targetY + containerHeight > viewport.Y then
			targetY = absPos.Y - containerHeight - 2
		end
		optionsContainer.Size = UDim2.new(0, absSize.X, 0, containerHeight)
		optionsContainer.Position = UDim2.new(0, targetX, 0, targetY)
	end

	CloseDropdown = function()
		expanded = false
		optionsContainer.Visible = false
		CreateTween(arrow, { Rotation = 0 }, animationspeed.Normal)
		if activeHolder._activeDropdown == CloseDropdown then
			activeHolder._activeDropdown = nil
		end
		if dropScrollConn then
			dropScrollConn:Disconnect()
			dropScrollConn = nil
		end
		if dropInputConn then
			dropInputConn:Disconnect()
			dropInputConn = nil
		end
	end

	toggleBtn.MouseButton1Click:Connect(function()
		expanded = not expanded
		if expanded then
			if activeHolder._activeDropdown then
				activeHolder._activeDropdown()
			end
			activeHolder._activeDropdown = CloseDropdown

			UpdateDropdownPosition()
			optionsContainer.Visible = true
			CreateTween(arrow, { Rotation = 180 }, animationspeed.Normal)

			dropScrollConn =
				tab.content.Parent:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdateDropdownPosition)

			dropInputConn = ui.InputBegan:Connect(function(input)
				if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
					return
				end
				local mp = input.Position
				local cp = optionsContainer.AbsolutePosition
				local cs = optionsContainer.AbsoluteSize
				local tp = selectedDisplay.AbsolutePosition
				local trgSz = selectedDisplay.AbsoluteSize
				local inContainer = mp.X >= cp.X and mp.X <= cp.X + cs.X and mp.Y >= cp.Y and mp.Y <= cp.Y + cs.Y
				local inTrigger = mp.X >= tp.X and mp.X <= tp.X + trgSz.X and mp.Y >= tp.Y and mp.Y <= tp.Y + trgSz.Y
				if not inContainer and not inTrigger then
					CloseDropdown()
				end
			end)
		else
			CloseDropdown()
		end
	end)

	local methods = {
		SetValue = function(_, value)
			if multiSelect and type(value) == "table" then
				selected = {}
				for _, v in ipairs(value) do
					table.insert(selected, v)
				end
			elseif not multiSelect then
				selected = value
			end
			UpdateSelectedText()
			callback(selected)
		end,
		GetValue = function()
			return selected
		end,
		Refresh = function(_, newOptions)
			options = newOptions or {}
			optionButtons = {}
			for _, child in ipairs(optionsScroll:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end
			for _, option in ipairs(options) do
				CreateOptionButton(option)
			end

			if multiSelect then
				local pruned = {}
				for _, value in ipairs(selected) do
					if table.find(options, value) then
						table.insert(pruned, value)
					end
				end
				selected = pruned
			elseif selected ~= nil and not table.find(options, selected) then
				selected = options[1]
			end

			optionsScroll.CanvasSize = UDim2.new(0, 0, 0, #options * s.Dropdown.OptionHeight)
			containerHeight = math.min(#options * s.Dropdown.OptionHeight, maxVisibleOptions * s.Dropdown.OptionHeight)
			optionsContainer.Size = UDim2.new(0, optionsContainer.Size.X.Offset, 0, containerHeight)
			UpdateSelectedText()
		end,
	}

	if flag and tab._library then
		tab._library:_RegisterConfigElement(flag, "Dropdown", function()
			return selected
		end, function(value)
			methods:SetValue(value)
		end)
	end

	return methods
end

function Library._CreateKeybind(tab, config, lib)
	local c = (lib and lib._c) or c
	local name = config.Name or "Keybind"
	local default = ResolveKeyCode(config.Default, Enum.KeyCode.Unknown)
	local callback = config.Callback or function() end
	local flag = config.Flag
	local parent = ResolveElementParent(tab, config)
	local compact = IsCompactElement(config, parent)
	local dense = IsDenseCompactElement(config, parent)
	local currentKey = default
	local listening = false

	local frame = CreateInstance("Frame", {
		Name = "Keybind_" .. name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = ResolveElementSize(config, parent, s.Button.Height),
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame)

	local nameLabel = CreateInstance("TextLabel", {
		Name = "Name",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, -10),
		TextSize = compact and textsize.Small or textsize.Normal,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = not dense,
		Size = UDim2.new(1, compact and -104 or -145, 0, 20),
		Parent = frame,
	})

	local compactIcon = CreateInstance("ImageLabel", {
		Name = "CompactIcon",
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = c.TextDark,
		Position = UDim2.new(0, 12, 0.5, -8),
		Size = UDim2.new(0, 16, 0, 16),
		Visible = dense,
		Parent = frame,
	})
	ApplyLucideIcon(compactIcon, config.Icon or "keyboard", "keyboard", 48)

	local keybindBox = CreateInstance("Frame", {
		Name = "KeybindBox",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.08,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BorderSizePixel = 0,
		Size = dense and UDim2.new(1, -44, 0, 26) or UDim2.new(0, compact and 72 or 78, 0, 26),
		Parent = frame,
	})
	CreateCorner(keybindBox, 8)
	CreateStroke(keybindBox)

	local keyLabel = CreateInstance("TextLabel", {
		Name = "KeyLabel",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = "",
		TextXAlignment = Enum.TextXAlignment.Center,
		BackgroundTransparency = 1,
		TextSize = textsize.Normal,
		Position = UDim2.new(0, 6, 0, 0),
		Size = UDim2.new(1, -34, 1, 0),
		Parent = keybindBox,
	})

	local clearButton = CreateInstance("ImageButton", {
		Name = "ClearButton",
		Image = "",
		ImageColor3 = c.TextDark,
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -7, 0.5, 0),
		Size = UDim2.new(0, 14, 0, 14),
		Parent = keybindBox,
	})
	ApplyLucideIcon(clearButton, "x", "x", 48)

	local button = CreateInstance("TextButton", {
		Name = "Button",
		Text = "",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -28, 1, 0),
		Parent = keybindBox,
	})

	local keybindId = name .. "_" .. tostring(tick())
	local previousKey = currentKey

	if config.Register ~= false then
		lib._keybinds[keybindId] = {
			key = currentKey,
			callback = callback,
			enabled = currentKey ~= Enum.KeyCode.Unknown,
		}
	end

	local function UpdateKeyDisplay()
		if listening then
			keyLabel.Text = "..."
			clearButton.Visible = true
			keyLabel.Size = UDim2.new(1, -34, 1, 0)
			button.Size = UDim2.new(1, -28, 1, 0)
			keybindBox.Size = dense and UDim2.new(1, -44, 0, 26) or UDim2.new(0, 74, 0, 26)
		else
			local keyName = FormatKeybindInput(currentKey)
			if keyName == "" then
				keyName = "Ninguno"
			end
			clearButton.Visible = currentKey ~= Enum.KeyCode.Unknown
			keyLabel.Size = clearButton.Visible and UDim2.new(1, -34, 1, 0) or UDim2.new(1, -12, 1, 0)
			button.Size = clearButton.Visible and UDim2.new(1, -28, 1, 0) or UDim2.new(1, 0, 1, 0)
			if dense then
				keybindBox.Size = UDim2.new(1, -44, 0, 26)
			else
				local maxWidth = compact and 96 or 130
				local textWidth = math.clamp(#keyName * 9 + (clearButton.Visible and 44 or 24), 72, maxWidth)
				keybindBox.Size = UDim2.new(0, textWidth, 0, 26)
			end
			keyLabel.Text = keyName
		end
	end

	local function SetCurrentKey(key, fireChanged)
		if typeof(key) == "EnumItem" and key.EnumType == Enum.UserInputType then
			currentKey = key
		else
			currentKey = ResolveKeyCode(key)
		end
		if lib._keybinds[keybindId] then
			lib._keybinds[keybindId].key = currentKey
			lib._keybinds[keybindId].enabled = currentKey ~= Enum.KeyCode.Unknown
		end
		UpdateKeyDisplay()
		if fireChanged and not (lib and lib._isDestroying) and type(config.Changed) == "function" then
			config.Changed(currentKey)
		end
	end

	UpdateKeyDisplay()

	local function setListening(state)
		listening = state
		if lib then
			if state then
				lib._capturingKeybind = true
			else
				task.defer(function()
					lib._capturingKeybind = false
				end)
			end
		end
	end

	button.MouseButton1Click:Connect(function()
		previousKey = currentKey
		setListening(true)
		UpdateKeyDisplay()
	end)

	local inputConnection
	inputConnection = ui.InputBegan:Connect(function(input, gameProcessed)
		if not listening then
			return
		end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
			currentKey = previousKey
			setListening(false)
			UpdateKeyDisplay()
			return
		end
		local isKeyboard = input.UserInputType == Enum.UserInputType.Keyboard
		local btnNum = tonumber(input.UserInputType.Name:match("^MouseButton(%d+)$"))
		local isSideMouseBtn = btnNum ~= nil and btnNum > 3
		if isKeyboard then
			currentKey = input.KeyCode
		elseif isSideMouseBtn then
			currentKey = input.UserInputType
		else
			return
		end
		setListening(false)
		SetCurrentKey(currentKey, true)
	end)

	Track(lib, inputConnection)
	UpdateKeyDisplay()

	clearButton.MouseButton1Click:Connect(function()
		if listening then
			currentKey = previousKey
			setListening(false)
			UpdateKeyDisplay()
		else
			setListening(false)
			SetCurrentKey(Enum.KeyCode.Unknown, true)
		end
	end)

	clearButton.MouseEnter:Connect(function()
		CreateTween(clearButton, { ImageColor3 = c.Text }, animationspeed.Fast)
	end)

	clearButton.MouseLeave:Connect(function()
		CreateTween(clearButton, { ImageColor3 = c.TextDark }, animationspeed.Fast)
	end)

	local methods = {
		SetKey = function(_, keyCode)
			SetCurrentKey(keyCode, true)
		end,
		GetKey = function()
			return currentKey
		end,
	}

	if flag and lib then
		lib:_RegisterConfigElement(flag, "Keybind", function()
			return currentKey
		end, function(value)
			methods:SetKey(value)
		end)
	end

	return methods
end

function Library._CreateColorPicker(tab, config)
	local c = (tab and tab._library and tab._library._c) or c
	local name = config.Name or "Color Picker"
	local default = config.Default or Color3.fromRGB(255, 255, 255)
	local _lib = tab and tab._library
	local _origCb = config.Callback or function() end
	local callback = function(...)
		if _lib and _lib._isDestroying then
			return
		end
		_origCb(...)
		if _lib and (config.AutoSave or _lib._autoSave) then
			_lib:_AutoSaveTick()
		end
	end
	local flag = config.Flag
	local currentColor = default
	local hue, sat, val = currentColor:ToHSV()
	local expanded = false
	local parent = ResolveElementParent(tab, config)
	local compact = IsCompactElement(config, parent)

	local frame = CreateInstance("Frame", {
		Name = "ColorPicker_" .. name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = config.WidthScale and ResolveElementSize(config, parent, s.Button.Height)
			or (compact and UDim2.new(0, 118, 0, 34) or UDim2.new(1, 0, 0, s.Button.Height)),
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame)

	local nameLabel = CreateInstance("TextLabel", {
		Name = "Name",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = compact and UDim2.new(0, 14, 0, 0) or UDim2.new(0, 10, 0, 0),
		TextSize = compact and textsize.Small or textsize.Normal,
		Size = compact and UDim2.new(1, -48, 1, 0) or UDim2.new(1, -50, 1, 0),
		Parent = frame,
	})

	local colorPreview = CreateInstance("Frame", {
		Name = "ColorPreview",
		BackgroundColor3 = currentColor,
		AnchorPoint = compact and Vector2.new(1, 0.5) or Vector2.new(0, 0),
		Position = compact and UDim2.new(1, -14, 0.5, 0) or UDim2.new(1, -48, 0.5, -9),
		Size = compact and UDim2.new(0, 22, 0, 14) or UDim2.new(0, 38, 0, 18),
		ZIndex = 2,
		Parent = frame,
	})
	CreateCorner(colorPreview, compact and 4 or 6)
	CreateStroke(colorPreview)

	local previewBtn = CreateInstance("TextButton", {
		Text = "",
		BackgroundTransparency = 1,
		Size = compact and UDim2.new(1, 0, 1, 0) or UDim2.new(1, 0, 1, 0),
		ZIndex = 3,
		Parent = compact and frame or colorPreview,
	})

	local pickerContainer = CreateInstance("Frame", {
		Name = "PickerContainer",
		BackgroundColor3 = c.Secondary,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 160, 0, 115),
		Visible = false,
		ZIndex = 3000,
		Parent = tab.content:FindFirstAncestorOfClass("ScreenGui") or tab.content,
	})
	CreateCorner(pickerContainer, 8)

	local containerStroke = CreateInstance("UIStroke", {
		Color = Color3.fromRGB(40, 40, 40),
		Thickness = 1,
		Parent = pickerContainer,
	})

	local svPicker = CreateInstance("Frame", {
		Name = "SVPicker",
		BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
		Position = UDim2.new(0, 8, 0, 8),
		Size = UDim2.new(1, -16, 0, 85),
		ZIndex = 3001,
		Parent = pickerContainer,
	})
	CreateCorner(svPicker, 4)

	local whiteLayer = CreateInstance("Frame", {
		BackgroundColor3 = Color3.new(1, 1, 1),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 3002,
		Parent = svPicker,
	})
	CreateCorner(whiteLayer, 4)

	local whiteGrad = CreateInstance("UIGradient", {
		Color = ColorSequence.new(Color3.new(1, 1, 1)),
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1),
		}),
		Parent = whiteLayer,
	})

	local blackLayer = CreateInstance("Frame", {
		BackgroundColor3 = Color3.new(0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 3003,
		Parent = svPicker,
	})
	CreateCorner(blackLayer, 4)

	local blackGrad = CreateInstance("UIGradient", {
		Color = ColorSequence.new(Color3.new(0, 0, 0)),
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0),
		}),
		Parent = blackLayer,
	})

	local svCursor = CreateInstance("Frame", {
		Name = "Cursor",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(sat, 0, 1 - val, 0),
		Size = UDim2.new(0, 10, 0, 10),
		ZIndex = 3005,
		Parent = svPicker,
	})

	local svCursorStroke = CreateInstance("UIStroke", {
		Thickness = 1.5,
		Color = Color3.new(1, 1, 1),
		Parent = svCursor,
	})
	CreateCorner(svCursor, 100)

	local hueSlider = CreateInstance("Frame", {
		Name = "HueSlider",
		Position = UDim2.new(0, 8, 0, 98),
		Size = UDim2.new(1, -16, 0, 8),
		ZIndex = 3001,
		Parent = pickerContainer,
	})
	CreateCorner(hueSlider, 100)

	local hueGrad = CreateInstance("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
			ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
			ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
			ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
			ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
			ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
		}),
		Parent = hueSlider,
	})

	local hueCursor = CreateInstance("Frame", {
		Name = "HueCursor",
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(hue, 0, 0.5, 0),
		Size = UDim2.new(0, 10, 0, 10),
		ZIndex = 3005,
		Parent = hueSlider,
	})
	CreateCorner(hueCursor, 100)
	CreateInstance("UIStroke", {
		Thickness = 1,
		Color = Color3.fromRGB(20, 20, 20),
		Parent = hueCursor,
	})

	local function UpdateColor()
		currentColor = Color3.fromHSV(hue, sat, val)
		colorPreview.BackgroundColor3 = currentColor
		svPicker.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
		svCursor.Position = UDim2.new(sat, 0, 1 - val, 0)
		hueCursor.Position = UDim2.new(hue, 0, 0.5, 0)
		callback(currentColor)
	end

	local svDragging, hueDragging = false, false

	local function ProcessInput(input)
		if not pickerContainer.Visible then
			return
		end

		if svDragging then
			local size = svPicker.AbsoluteSize
			local pos = svPicker.AbsolutePosition
			sat = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
			val = 1 - math.clamp((input.Position.Y - pos.Y) / size.Y, 0, 1)
			UpdateColor()
		elseif hueDragging then
			local size = hueSlider.AbsoluteSize
			local pos = hueSlider.AbsolutePosition
			hue = math.clamp((input.Position.X - pos.X) / size.X, 0, 1)
			UpdateColor()
		end
	end

	svPicker.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			svDragging = true
			ProcessInput(input)
		end
	end)

	hueSlider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			hueDragging = true
			ProcessInput(input)
		end
	end)

	Track(
		_lib,
		ui.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				ProcessInput(input)
			end
		end)
	)

	Track(
		_lib,
		ui.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				svDragging = false
				hueDragging = false
			end
		end)
	)

	local pickerScrollConn, pickerInputConn
	local ClosePicker

	local activeHolder = _lib or Library

	local function UpdatePickerPosition()
		local scrollFrame = tab.content.Parent
		local sfPos = scrollFrame.AbsolutePosition
		local sfSize = scrollFrame.AbsoluteSize
		local btnPos = colorPreview.AbsolutePosition
		local btnSize = colorPreview.AbsoluteSize
		local midY = btnPos.Y + btnSize.Y / 2
		if midY < sfPos.Y or midY > sfPos.Y + sfSize.Y then
			ClosePicker()
			return
		end
		local viewport = workspace.CurrentCamera.ViewportSize
		local targetX = btnPos.X - 170
		local targetY = btnPos.Y
		if targetY + 115 > viewport.Y then
			targetY = viewport.Y - 125
		end
		if targetX < 0 then
			targetX = btnPos.X + 50
		end
		pickerContainer.Position = UDim2.new(0, targetX, 0, targetY)
	end

	ClosePicker = function()
		pickerContainer.Visible = false
		expanded = false
		if activeHolder._activePicker == ClosePicker then
			activeHolder._activePicker = nil
		end
		if pickerScrollConn then
			pickerScrollConn:Disconnect()
			pickerScrollConn = nil
		end
		if pickerInputConn then
			pickerInputConn:Disconnect()
			pickerInputConn = nil
		end
	end

	local function OpenPicker()
		if activeHolder._activePicker then
			activeHolder._activePicker()
		end
		activeHolder._activePicker = ClosePicker

		UpdatePickerPosition()
		pickerContainer.Visible = true
		expanded = true

		pickerScrollConn = tab.content.Parent:GetPropertyChangedSignal("CanvasPosition"):Connect(UpdatePickerPosition)

		pickerInputConn = ui.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
				return
			end
			if svDragging or hueDragging then
				return
			end
			local mp = input.Position
			local pp = pickerContainer.AbsolutePosition
			local ps = pickerContainer.AbsoluteSize
			local bp = colorPreview.AbsolutePosition
			local bsz = colorPreview.AbsoluteSize
			local inPicker = mp.X >= pp.X and mp.X <= pp.X + ps.X and mp.Y >= pp.Y and mp.Y <= pp.Y + ps.Y
			local inBtn = mp.X >= bp.X and mp.X <= bp.X + bsz.X and mp.Y >= bp.Y and mp.Y <= bp.Y + bsz.Y
			if not inPicker and not inBtn then
				ClosePicker()
			end
		end)
	end

	previewBtn.MouseButton1Click:Connect(function()
		if expanded then
			ClosePicker()
		else
			OpenPicker()
		end
	end)

	local methods = {
		SetColor = function(_, color)
			currentColor = color
			hue, sat, val = color:ToHSV()
			UpdateColor()
		end,
		GetColor = function()
			return currentColor
		end,
	}

	if flag and tab._library then
		tab._library:_RegisterConfigElement(flag, "ColorPicker", function()
			return currentColor
		end, function(value)
			methods:SetColor(value)
		end)
	end

	return methods
end

function Library._CreateTextBox(tab, config)
	local c = (tab and tab._library and tab._library._c) or c
	local name = config.Name or "TextBox"
	local default = config.Default or ""
	local placeholder = config.Placeholder or "Enter text..."
	local parent = ResolveElementParent(tab, config)
	local compact = IsCompactElement(config, parent)
	local dense = IsDenseCompactElement(config, parent)
	local _lib = tab and tab._library
	local _origCb = config.Callback or function() end
	local callback = function(...)
		if _lib and _lib._isDestroying then
			return
		end
		_origCb(...)
		if _lib and (config.AutoSave or _lib._autoSave) then
			_lib:_AutoSaveTick()
		end
	end
	local clearOnFocus = config.ClearOnFocus or false
	local numbersOnly = config.NumbersOnly or false
	local flag = config.Flag
	local currentText = default

	local frame = CreateInstance("Frame", {
		Name = "TextBox_" .. name,
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.18,
		BorderSizePixel = 0,
		Size = ResolveElementSize(config, parent, compact and s.Button.Height or s.TextBox.Height),
		Parent = parent,
	})
	CreateCorner(frame, 8)
	CreateStroke(frame)

	local nameLabel = CreateInstance("TextLabel", {
		Name = "Name",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		Text = name,
		TextXAlignment = Enum.TextXAlignment.Left,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0.5, -10),
		TextSize = compact and textsize.Small or textsize.Normal,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Visible = not dense,
		Size = compact and UDim2.new(1, -122, 0, 20) or UDim2.new(0, 150, 0, 20),
		Parent = frame,
	})

	local icon = CreateInstance("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		Image = "",
		ImageColor3 = c.TextDark,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = dense and UDim2.new(0, 28, 0.5, 0)
			or (compact and UDim2.new(1, -118, 0.5, 0) or UDim2.new(1, -165, 0.5, 0)),
		Size = UDim2.new(0, 18, 0, 18),
		Parent = frame,
	})
	ApplyLucideIcon(icon, config.Icon or "type", "type", 48)

	local textBoxContainer = CreateInstance("Frame", {
		Name = "TextBoxContainer",
		BackgroundColor3 = c.Secondary,
		BackgroundTransparency = 0.08,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		BorderSizePixel = 0,
		Size = dense and UDim2.new(1, -44, 0, 26)
			or (compact and UDim2.new(0, 96, 0, 26) or UDim2.new(0, s.TextBox.InputWidth, 0, 26)),
		ClipsDescendants = true,
		Parent = frame,
	})
	CreateCorner(textBoxContainer, 8)
	local textBoxStroke = CreateStroke(textBoxContainer)

	local textBox = CreateInstance("TextBox", {
		Name = "Input",
		FontFace = f.Regular,
		TextColor3 = c.Text,
		PlaceholderText = placeholder,
		PlaceholderColor3 = c.TextDark,
		Text = currentText,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.None,
		BackgroundTransparency = 1,
		TextSize = textsize.Small,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.new(0, 8, 0, 0),
		ClearTextOnFocus = clearOnFocus,
		Parent = textBoxContainer,
	})

	textBox.Focused:Connect(function()
		CreateTween(textBoxContainer, { BackgroundTransparency = 0 }, animationspeed.Fast)
		CreateTween(textBoxStroke, { Color = c.Accent }, animationspeed.Fast)
		CreateTween(icon, { ImageColor3 = c.Text }, animationspeed.Fast)
	end)

	textBox.FocusLost:Connect(function(enterPressed)
		CreateTween(textBoxContainer, { BackgroundTransparency = 0.04 }, animationspeed.Fast)
		CreateTween(textBoxStroke, { Color = c.Border }, animationspeed.Fast)
		CreateTween(icon, { ImageColor3 = c.TextDark }, animationspeed.Fast)

		if numbersOnly then
			local numValue = tonumber(textBox.Text)
			if numValue then
				currentText = tostring(numValue)
				textBox.Text = currentText
			else
				textBox.Text = currentText
			end
		else
			currentText = textBox.Text
		end

		callback(currentText, enterPressed)
	end)

	if numbersOnly then
		textBox:GetPropertyChangedSignal("Text"):Connect(function()
			local text = textBox.Text
			local filtered = text:gsub("[^%d%.%-]", "")
			if text ~= filtered then
				textBox.Text = filtered
			end
		end)
	end

	local methods = {
		SetText = function(_, text)
			currentText = tostring(text)
			textBox.Text = currentText
		end,
		GetText = function()
			return currentText
		end,
		SetPlaceholder = function(_, newPlaceholder)
			textBox.PlaceholderText = newPlaceholder
		end,
		Focus = function()
			textBox:CaptureFocus()
		end,
	}

	if flag and tab._library then
		tab._library:_RegisterConfigElement(flag, "TextBox", function()
			return currentText
		end, function(value)
			methods:SetText(value)
		end)
	end

	return methods
end

function Library:_CreateSystemTabs()
	if self.systemTabs then
		return self.systemTabs
	end

	local section = self:CreateSection("Settings")
	if section.frame then
		section.frame.LayoutOrder = 9999
	end
	local settingsTab = section:CreateTab("Settings", "settings")
	local themeTab = section:CreateTab("Theme", "palette")

	self.systemTabs = {
		Section = section,
		Settings = settingsTab,
		Theme = themeTab,
		Saves = settingsTab,
	}

	Library._CreateContentSection(settingsTab, "Settings")

	Library._CreateKeybind(settingsTab, {
		Name = "Open/close UI",
		Default = self:GetToggleKey(),
		Flag = "mithren_system_toggle_keybind",
		Register = false,
		Changed = function(keyCode)
			self:SetToggleKey(keyCode)
		end,
	}, self)

	Library._CreateToggle(settingsTab, {
		Name = "Notifications",
		Default = self:AreNotificationsEnabled(),
		Flag = "mithren_system_notifications_enabled",
		Callback = function(enabled)
			self:SetNotificationsEnabled(enabled == true)
		end,
	})

	Library._CreateContentSection(themeTab, "Theme")

	local themePresets = {
		Default = {
			AccentColor = Color3.fromRGB(255, 255, 255),
			BackgroundColor = Color3.fromRGB(10, 10, 11),
			SecondaryColor = Color3.fromRGB(25, 25, 27),
			BorderColor = Color3.fromRGB(47, 47, 51),
			TextColor = Color3.fromRGB(255, 255, 255),
			MutedTextColor = Color3.fromRGB(155, 155, 162),
			ScrollBarColor = Color3.fromRGB(82, 82, 88),
		},
		Blue = {
			AccentColor = Color3.fromRGB(74, 171, 255),
			BackgroundColor = Color3.fromRGB(9, 12, 18),
			SecondaryColor = Color3.fromRGB(18, 27, 42),
			BorderColor = Color3.fromRGB(48, 72, 105),
			TextColor = Color3.fromRGB(240, 247, 255),
			MutedTextColor = Color3.fromRGB(148, 170, 198),
			ScrollBarColor = Color3.fromRGB(92, 133, 178),
		},
		Crimson = {
			AccentColor = Color3.fromRGB(255, 68, 96),
			BackgroundColor = Color3.fromRGB(14, 10, 12),
			SecondaryColor = Color3.fromRGB(32, 18, 23),
			BorderColor = Color3.fromRGB(83, 43, 52),
			TextColor = Color3.fromRGB(255, 244, 246),
			MutedTextColor = Color3.fromRGB(190, 143, 151),
			ScrollBarColor = Color3.fromRGB(150, 76, 90),
		},
		Green = {
			AccentColor = Color3.fromRGB(80, 220, 145),
			BackgroundColor = Color3.fromRGB(8, 13, 11),
			SecondaryColor = Color3.fromRGB(16, 31, 25),
			BorderColor = Color3.fromRGB(42, 82, 64),
			TextColor = Color3.fromRGB(238, 255, 247),
			MutedTextColor = Color3.fromRGB(140, 184, 164),
			ScrollBarColor = Color3.fromRGB(82, 150, 116),
		},
		Amber = {
			AccentColor = Color3.fromRGB(255, 190, 72),
			BackgroundColor = Color3.fromRGB(15, 12, 8),
			SecondaryColor = Color3.fromRGB(33, 26, 16),
			BorderColor = Color3.fromRGB(91, 70, 36),
			TextColor = Color3.fromRGB(255, 249, 235),
			MutedTextColor = Color3.fromRGB(198, 172, 126),
			ScrollBarColor = Color3.fromRGB(168, 124, 58),
		},
		Violet = {
			AccentColor = Color3.fromRGB(168, 118, 255),
			BackgroundColor = Color3.fromRGB(12, 9, 18),
			SecondaryColor = Color3.fromRGB(25, 18, 39),
			BorderColor = Color3.fromRGB(72, 55, 111),
			TextColor = Color3.fromRGB(248, 244, 255),
			MutedTextColor = Color3.fromRGB(174, 156, 207),
			ScrollBarColor = Color3.fromRGB(124, 94, 184),
		},
		Cyan = {
			AccentColor = Color3.fromRGB(63, 220, 230),
			BackgroundColor = Color3.fromRGB(7, 13, 15),
			SecondaryColor = Color3.fromRGB(14, 31, 35),
			BorderColor = Color3.fromRGB(35, 87, 96),
			TextColor = Color3.fromRGB(235, 253, 255),
			MutedTextColor = Color3.fromRGB(133, 190, 198),
			ScrollBarColor = Color3.fromRGB(70, 158, 170),
		},
		Rose = {
			AccentColor = Color3.fromRGB(255, 111, 171),
			BackgroundColor = Color3.fromRGB(16, 9, 14),
			SecondaryColor = Color3.fromRGB(35, 18, 30),
			BorderColor = Color3.fromRGB(94, 47, 76),
			TextColor = Color3.fromRGB(255, 242, 249),
			MutedTextColor = Color3.fromRGB(202, 147, 176),
			ScrollBarColor = Color3.fromRGB(171, 82, 128),
		},
		Slate = {
			AccentColor = Color3.fromRGB(170, 185, 205),
			BackgroundColor = Color3.fromRGB(10, 12, 15),
			SecondaryColor = Color3.fromRGB(22, 26, 32),
			BorderColor = Color3.fromRGB(57, 65, 77),
			TextColor = Color3.fromRGB(242, 246, 250),
			MutedTextColor = Color3.fromRGB(156, 166, 180),
			ScrollBarColor = Color3.fromRGB(101, 115, 133),
		},
		Mono = {
			AccentColor = Color3.fromRGB(245, 245, 245),
			BackgroundColor = Color3.fromRGB(8, 8, 8),
			SecondaryColor = Color3.fromRGB(20, 20, 20),
			BorderColor = Color3.fromRGB(58, 58, 58),
			TextColor = Color3.fromRGB(250, 250, 250),
			MutedTextColor = Color3.fromRGB(170, 170, 170),
			ScrollBarColor = Color3.fromRGB(118, 118, 118),
		},
	}

	local themeColorPickers = {}
	local themeSkyControls = {}
	local function syncThemeColorPickers(theme)
		theme = theme or self:GetTheme()
		local pickerMap = {
			AccentColor = themeColorPickers.AccentColor,
			BackgroundColor = themeColorPickers.BackgroundColor,
			SecondaryColor = themeColorPickers.SecondaryColor,
			BorderColor = themeColorPickers.BorderColor,
			TextColor = themeColorPickers.TextColor,
			MutedTextColor = themeColorPickers.MutedTextColor,
			ScrollBarColor = themeColorPickers.ScrollBarColor,
		}
		for key, picker in pairs(pickerMap) do
			if picker and typeof(theme[key]) == "Color3" and type(picker.SetColor) == "function" then
				picker:SetColor(theme[key])
			end
		end
	end
	local function syncThemeSkyControls(theme)
		theme = theme or self:GetTheme()
		if themeSkyControls.Enabled and type(themeSkyControls.Enabled.SetValue) == "function" then
			themeSkyControls.Enabled:SetValue(theme.SkyEnabled == true)
		end
		if themeSkyControls.Preset and type(themeSkyControls.Preset.SetValue) == "function" then
			themeSkyControls.Preset:SetValue(self:_NormalizeSkyPreset(theme.SkyPreset))
		end
	end

	Library._CreateDropdown(themeTab, {
		Name = "Preset",
		Options = { "Default", "Blue", "Crimson", "Green", "Amber", "Violet", "Cyan", "Rose", "Slate", "Mono" },
		Default = "Default",
		Flag = "mithren_system_theme_preset",
		Callback = function(selected)
			local presetName = type(selected) == "table" and selected[1] or selected
			local preset = themePresets[tostring(presetName or "")]
			if preset then
				self:SetTheme(preset)
				syncThemeColorPickers(preset)
			end
		end,
	})

	local colorRowA = Library._CreateRow(themeTab, { Columns = 3 })
	themeColorPickers.AccentColor = colorRowA:CreateColorPicker({
		Name = "Primary",
		Default = self._theme.AccentColor,
		Flag = "mithren_system_accent_color",
		Callback = function(color)
			self:SetTheme({ AccentColor = color })
		end,
	})
	themeColorPickers.BackgroundColor = colorRowA:CreateColorPicker({
		Name = "Background",
		Default = self._theme.BackgroundColor,
		Flag = "mithren_system_background_color",
		Callback = function(color)
			self:SetTheme({ BackgroundColor = color })
		end,
	})
	themeColorPickers.SecondaryColor = colorRowA:CreateColorPicker({
		Name = "Panel",
		Default = self._theme.SecondaryColor,
		Flag = "mithren_system_secondary_color",
		Callback = function(color)
			self:SetTheme({ SecondaryColor = color })
		end,
	})

	local colorRowB = Library._CreateRow(themeTab, { Columns = 3 })
	themeColorPickers.BorderColor = colorRowB:CreateColorPicker({
		Name = "Borders",
		Default = self._theme.BorderColor,
		Flag = "mithren_system_border_color",
		Callback = function(color)
			self:SetTheme({ BorderColor = color })
		end,
	})
	themeColorPickers.TextColor = colorRowB:CreateColorPicker({
		Name = "Text",
		Default = self._theme.TextColor,
		Flag = "mithren_system_text_color",
		Callback = function(color)
			self:SetTheme({ TextColor = color })
		end,
	})
	themeColorPickers.MutedTextColor = colorRowB:CreateColorPicker({
		Name = "Muted text",
		Default = self._theme.MutedTextColor,
		Flag = "mithren_system_muted_text_color",
		Callback = function(color)
			self:SetTheme({ MutedTextColor = color })
		end,
	})

	themeColorPickers.ScrollBarColor = Library._CreateColorPicker(themeTab, {
		Name = "Scroll",
		Default = self._theme.ScrollBarColor,
		Flag = "mithren_system_scroll_color",
		Callback = function(color)
			self:SetTheme({ ScrollBarColor = color })
		end,
	})

	local transparencyRow = Library._CreateRow(themeTab, { Columns = 2 })
	transparencyRow:CreateSlider({
		Name = "Panel transparency",
		Min = 0,
		Max = 90,
		Default = math.floor((self._theme.PanelTransparency or 0.03) * 100 + 0.5),
		Flag = "mithren_system_panel_transparency",
		Callback = function(value)
			self:SetTheme({ PanelTransparency = (tonumber(value) or 0) / 100 })
		end,
	})
	transparencyRow:CreateSlider({
		Name = "Element transparency",
		Min = 0,
		Max = 90,
		Default = math.floor((self._theme.ElementTransparency or self._elementTransparency or 0.18) * 100 + 0.5),
		Flag = "mithren_system_element_transparency",
		Callback = function(value)
			self:SetTheme({ ElementTransparency = (tonumber(value) or 0) / 100 })
		end,
	})

	Library._CreateContentSection(themeTab, "Background")
	local backgroundRow = Library._CreateRow(themeTab, { Columns = 2 })
	backgroundRow:CreateToggle({
		Name = "Background image",
		Default = self._theme.BackgroundImageEnabled == true,
		Flag = "mithren_system_background_enabled",
		Callback = function(enabled)
			self:SetTheme({ BackgroundImageEnabled = enabled == true })
		end,
	})
	backgroundRow:CreateSlider({
		Name = "Darken",
		Min = 0,
		Max = 90,
		Default = math.floor((self._theme.BackgroundDim or 0.45) * 100 + 0.5),
		Flag = "mithren_system_background_dim",
		Callback = function(value)
			self:SetTheme({ BackgroundDim = (tonumber(value) or 0) / 100 })
		end,
	})

	Library._CreateTextBox(themeTab, {
		Name = "Image",
		Default = self._theme.BackgroundImage or "",
		Placeholder = "rbxassetid://...",
		Flag = "mithren_system_background_image",
		Callback = function(text)
			self:SetTheme({ BackgroundImage = tostring(text or "") })
		end,
	})

	Library._CreateToggle(themeTab, {
		Name = "Acrylic blur",
		Default = self._theme.AcrylicBlurEnabled == true,
		Flag = "mithren_system_acrylic_blur",
		Callback = function(enabled)
			self:SetTheme({ AcrylicBlurEnabled = enabled == true })
		end,
	})

	Library._CreateContentSection(themeTab, "Sky")
	local skyRow = Library._CreateRow(themeTab, { Columns = 2 })
	themeSkyControls.Enabled = skyRow:CreateToggle({
		Name = "Custom sky",
		Default = self._theme.SkyEnabled == true,
		Flag = "mithren_system_sky_enabled",
		Callback = function(enabled)
			self:SetTheme({ SkyEnabled = enabled == true })
		end,
	})
	themeSkyControls.Preset = skyRow:CreateDropdown({
		Name = "Sky preset",
		Options = SKY_OPTIONS,
		Default = self:_NormalizeSkyPreset(self._theme.SkyPreset),
		Flag = "mithren_system_sky_preset",
		Callback = function(selected)
			local presetName = type(selected) == "table" and selected[1] or selected
			self:SetTheme({ SkyPreset = presetName })
		end,
	})

	Library._CreateButton(themeTab, {
		Name = "Reset theme",
		Icon = "rotate-ccw",
		Callback = function()
			self:ResetTheme()
			syncThemeColorPickers()
			syncThemeSkyControls()
		end,
	})

	Library._CreateConfigSection(settingsTab, {
		Title = "Saves",
		ShowHelp = false,
		ShowAdvanced = true,
		ShowAutoSave = false,
		ShowUiKeybind = false,
	})

	return self.systemTabs
end

function Library._CreateConfigSection(tab, config)
	local lib = tab._library
	config = config or {}

	Library._CreateContentSection(tab, config.Title or "Saves")

	if config.ShowHelp == true and config.HelpTitle ~= nil and config.HelpContent ~= nil then
		Library._CreateParagraph(tab, {
			Title = config.HelpTitle,
			Content = config.HelpContent,
		})
	end

	local configNameBox = Library._CreateTextBox(tab, {
		Name = config.NameLabel or "Save name",
		Default = lib._currentConfig or "default",
		Placeholder = config.NamePlaceholder or "default",
		Callback = function(text)
			lib._currentConfig = SanitizeConfigName(text)
		end,
	})

	local savedConfigs = lib:GetConfigs()
	if #savedConfigs == 0 then
		savedConfigs = { lib._currentConfig or "default" }
	end
	local selectedConfig = lib._currentConfig or savedConfigs[1]
	local selectedConfigExists = false
	for _, configName in ipairs(savedConfigs) do
		if configName == selectedConfig then
			selectedConfigExists = true
			break
		end
	end
	if not selectedConfigExists then
		selectedConfig = savedConfigs[1]
	end

	local configDropdown
	configDropdown = Library._CreateDropdown(tab, {
		Name = config.SelectLabel or "Select save",
		Options = savedConfigs,
		Default = selectedConfig,
		Callback = function(selected)
			local selectedName = SanitizeConfigName(selected)
			configNameBox:SetText(selectedName)
			lib._currentConfig = selectedName
		end,
	})

	Library._CreateButton(tab, {
		Name = config.SaveLabel or "Save",
		Callback = function()
			local configName = SanitizeConfigName(configNameBox:GetText())
			if configName and configName ~= "" then
				lib:SaveConfig(configName)
				configDropdown:Refresh(lib:GetConfigs())
			end
		end,
	})

	Library._CreateButton(tab, {
		Name = config.LoadLabel or "Load",
		Callback = function()
			local configName = SanitizeConfigName(configNameBox:GetText())
			if configName and configName ~= "" then
				lib:LoadConfig(configName)
			end
		end,
	})

	Library._CreateButton(tab, {
		Name = config.DeleteLabel or "Delete",
		Callback = function()
			local configName = SanitizeConfigName(configNameBox:GetText())
			if configName and configName ~= "" then
				lib:DeleteConfig(configName)
				configDropdown:Refresh(lib:GetConfigs())
			end
		end,
	})

	if config.ShowAdvanced == true then
		Library._CreateButton(tab, {
			Name = config.RefreshLabel or "Refresh list",
			Callback = function()
				configDropdown:Refresh(lib:GetConfigs())
				lib:Notify({ Title = "Saves", Description = "List refreshed", Duration = 2, Icon = "save" })
			end,
		})

		Library._CreateButton(tab, {
			Name = config.ExportLabel or "Export save",
			Callback = function()
				local configName = SanitizeConfigName(configNameBox:GetText())
				if configName and configName ~= "" then
					lib:SaveConfig(configName, true)
					lib:ExportConfig(configName)
				end
			end,
		})

		Library._CreateButton(tab, {
			Name = config.ImportLabel or "Import save",
			Callback = function()
				local configName = SanitizeConfigName(configNameBox:GetText())
				if configName and configName ~= "" then
					lib:ImportConfig(configName)
					configDropdown:Refresh(lib:GetConfigs())
				end
			end,
		})
	end

	if config.ShowUiKeybind ~= false then
		Library._CreateKeybind(tab, {
			Name = config.UiKeybindLabel or "UI key",
			Default = lib:GetToggleKey(),
			Flag = config.UiKeybindFlag or "mithren_toggle_ui_keybind",
			Register = false,
			Changed = function(keyCode)
				lib:SetToggleKey(keyCode)
			end,
		}, lib)
	end

	return {
		RefreshConfigs = function()
			configDropdown:Refresh(lib:GetConfigs())
		end,
	}
end

_G.MithrenLibrary = Library
_G.AcrylicLibrary = Library

return Library
