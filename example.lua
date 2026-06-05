local Library
local MITHREN_LATEST_URL = "https://raw.githubusercontent.com/Ryshub/Mithren/main/main.lua"

do
	local ok, result = pcall(function()
		if type(_G) == "table" and type(_G.MithrenLibrary) == "table" then
			return _G.MithrenLibrary
		end
		return loadstring(game:HttpGet(MITHREN_LATEST_URL))()
	end)
	if ok and type(result) == "table" then
		Library = result
	end
end

assert(Library, "Mithren library could not be loaded")
local function RunMithrenExample()
	pcall(function()
		local oldWindow = rawget(_G, "MithrenExampleWindow")
		if oldWindow and type(oldWindow.Destroy) == "function" then
			oldWindow:Destroy()
		end
	end)

	local testAccent = Color3.fromRGB(79, 195, 247)
	local window = Library:Window({
		Title = "Mithren Example",
		ConfigFolder = "MithrenExample",
		Version = "row-test",
	})

	_G.MithrenExampleWindow = window
	window:SetToggleKey(Enum.KeyCode.RightControl)

	local principal = window:CreateSection("Principal")

	local rows = principal:CreateTab("Filas", "columns-3")

	local function addTestElement(row, itemType, suffix)
		if itemType == "Button" then
			row:CreateButton({
				Name = "Boton",
				Icon = "play",
				Callback = function()
					window:Notify({
						Title = "Mithren",
						Description = "Boton de test",
						Duration = 2,
						Icon = "check",
					})
				end,
			})
		elseif itemType == "Toggle" then
			row:CreateToggle({
				Name = "Toggle",
				Default = false,
				Flag = "mithren_test_toggle_" .. suffix,
				Callback = function() end,
			})
		elseif itemType == "Slider" then
			row:CreateSlider({
				Name = "Slider",
				Min = 0,
				Max = 100,
				Default = 35,
				Flag = "mithren_test_slider_" .. suffix,
				Callback = function() end,
			})
		elseif itemType == "Dropdown" then
			row:CreateDropdown({
				Name = "Select",
				Options = { "Uno", "Dos", "Tres" },
				Default = "Uno",
				Flag = "mithren_test_dropdown_" .. suffix,
				Callback = function() end,
			})
		elseif itemType == "Keybind" then
			row:CreateKeybind({
				Name = "Keybind",
				Default = Enum.KeyCode.F,
				Flag = "mithren_test_keybind_" .. suffix,
				Callback = function() end,
			})
		elseif itemType == "ColorPicker" then
			row:CreateColorPicker({
				Name = "Color",
				Default = testAccent,
				Flag = "mithren_test_color_" .. suffix,
				Callback = function(color)
					window:SetAccentColor(color)
				end,
			})
		elseif itemType == "Bubble" then
			row:CreateBubble({
				Name = "Bubble",
				Default = true,
				Flag = "mithren_test_bubble_" .. suffix,
				BubbleText = "B",
				Activated = function() end,
			})
		elseif itemType == "TextBox" then
			row:CreateTextBox({
				Name = "Texto",
				Default = "",
				Placeholder = "Input",
				Flag = "mithren_test_textbox_" .. suffix,
				Callback = function() end,
			})
		end
	end

	local function addComponentRows(columns, title, suffix)
		rows:CreateSection(title)
		local items = {
			"Button",
			"Toggle",
			"Slider",
			"Dropdown",
			"Keybind",
			"ColorPicker",
			"Bubble",
			"TextBox",
		}

		local index = 1
		while index <= #items do
			local row = rows:CreateRow(columns)
			for _ = 1, columns do
				local itemType = items[index]
				if itemType then
					addTestElement(row, itemType, suffix .. "_" .. tostring(index))
				end
				index += 1
			end
		end
	end

	addComponentRows(1, "1 componente por fila", "one")
	addComponentRows(2, "2 componentes por fila", "two")
	addComponentRows(3, "3 componentes por fila", "three")

	return window
end
return RunMithrenExample()
