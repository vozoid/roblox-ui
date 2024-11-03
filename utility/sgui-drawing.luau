--[=[
    Creates an artificial Drawing environment for use of the Drawing library
    in Roblox Studio specifically for UI libraries.
    
    @class Drawing
]=]

-- Services
local TextService = game:GetService("TextService")

-- Datatype aliases
local rgb, v2, ud2o, ud, font = Color3.fromRGB, Vector2.new, UDim2.fromOffset, UDim.new, Font.new

-- Fonts (replace Studio fonts with the corresponding fonts) (if you know you know >:)
local fonts = {
	font("rbxasset://fonts/families/Jura.json"), -- SegoeUI https://github.com/vozoid/roblox-ui/blob/main/fonts/SegoeUI.ttf
	font("rbxasset://fonts/families/Sarpanch.json"), -- ProggyClean https://github.com/vozoid/roblox-ui/blob/main/fonts/ProggyClean.ttf
	font("rbxasset://fonts/families/Kalam.json"), -- IBMPlex https://github.com/vozoid/roblox-ui/blob/main/fonts/IBMPlex.ttf
	font("rbxasset://fonts/families/Oswald.json"), -- SometypeMono https://github.com/vozoid/roblox-ui/blob/main/fonts/SometypeMono.ttf
}

-- Instance bases to clone
local bases = {}

bases.Square = Instance.new("Frame")
bases.Square.BackgroundColor3 = rgb(0, 0, 0)
bases.Square.BackgroundTransparency = 1
bases.Square.BorderColor3 = rgb(0, 0, 0)
bases.Square.BorderSizePixel = 0
bases.Square.Visible = false

local stroke = Instance.new("UIStroke")
stroke.Name = "stroke"
stroke.LineJoinMode = Enum.LineJoinMode.Miter
stroke.Parent = bases.Square

bases.Text = Instance.new("TextLabel")
bases.Text.Text = ""
bases.Text.TextColor3 = rgb(0, 0, 0)
bases.Text.TextXAlignment = Enum.TextXAlignment.Left
bases.Text.TextYAlignment = Enum.TextYAlignment.Top
bases.Text.FontFace = fonts[1]
bases.Text.BackgroundColor3 = rgb(0, 0, 0)
bases.Text.BorderColor3 = rgb(0, 0, 0)
bases.Text.BorderSizePixel = 0
bases.Text.Visible = false

bases.Image = Instance.new("ImageLabel")
bases.Image.BackgroundTransparency = 1
bases.Image.ImageColor3 = rgb(0, 0, 0)
bases.Image.Visible = false

-- Class defaults
-- stylua: ignore
local defaults = {
	common = { Visible = false, ZIndex = 1, Transparency = 1, Color = rgb(0, 0, 0), Position = v2(0, 0, 0) },
	Square = { Size = v2(0, 0, 0), Filled = true, Thickness = 1 },
	Text = { Text = "", Font = 1, Size = 0, Outline = false, OutlineColor = rgb(0, 0, 0), Center = false },
	Image = { Size = v2(0, 0, 0), Data = "", Rounding = 0 },
}

-- Functions
local drawCache = {}

function getrenderproperty(object, property)
	return object[property]
end

function setrenderproperty(object, property, value)
	object[property] = value
end

function isrenderobj(object)
	return typeof(object) == "table" and object.ClassName and object.ClassName == "Drawing"
end

function cleardrawcache()
	for _, drawing in drawCache do
		drawing:Remove()
	end

	table.clear(drawCache)
end

-- Drawing class
local Drawing = {}
Drawing.ClassName = "Drawing"
Drawing.Fonts = {
	UI = 1,
	System = 2,
	Plex = 3,
	Monospace = 4,
}
Drawing._parent = game.Players.LocalPlayer.PlayerGui

if not Drawing._parent:FindFirstChild("drawing") then
	Drawing._gui = Instance.new("ScreenGui")
	Drawing._gui.Name = "drawing"
	Drawing._gui.DisplayOrder = 999999999
	Drawing._gui.ScreenInsets = Enum.ScreenInsets.None
	Drawing._gui.Parent = Drawing._parent
else
	Drawing._gui = Drawing._parent.drawing
end

--[=[
    Constructs a new Drawing.
    @param class string
    @return Drawing<T>
]=]
function Drawing.new(class)
	local instance = bases[class]:Clone()
	instance.Parent = Drawing._gui

	local object = {
		_properties = {},
		_instance = instance,
		_class = class,
		_cacheIndex = #drawCache + 1,
	}

	for property, value in defaults.common do
		object._properties[property] = value
	end

	for property, value in defaults[class] do
		object._properties[property] = value
	end

	drawCache[#drawCache + 1] = object

	return setmetatable(object, Drawing)
end

--[=[
    Destroys the Drawing instance and collects the object.
]=]
function Drawing:Remove()
	self._instance:Destroy()
	drawCache[self._cacheIndex] = nil -- cant be bothered to table.remove it

	table.clear(self)
end

--[=[
    Maybe add properties here one day
]=]
function Drawing:__index(index)
	if index == "TextBounds" then
		-- Using TextService instead of instance.TextBounds due to issues with TextBounds not updating without visiblity
		local params = Instance.new("GetTextBoundsParams")
		params.Text = self.Text
		params.Font = fonts[self.Font]
		params.Size = self.Size - 1
		params.Width = math.huge

		return TextService:GetTextBoundsAsync(params)
	end

	return self._properties[index] or rawget(self, index) or rawget(Drawing, index)
end

function Drawing:__newindex(index, value)
	if index == "Visible" or index == "ZIndex" or index == "Text" then
		self._instance[index] = value
	elseif index == "Transparency" then
		if self._class == "Square" then
			if self.Filled then
				self._instance.BackgroundTransparency = 1 - value
			end
			
			self._instance.stroke.Transparency = 1 - value
		else
			-- Gives class context
			self._instance[self._class .. index] = 1 - value
		end
	elseif index == "Color" then
		if self._class == "Square" then
			self._instance.stroke.Color = value
		end

		-- Gives class context and converts to Color3
		self._instance[(if self._class == "Square" then "Background" else self._class) .. index .. "3"] = value
	elseif index == "Position" then
		self._instance[index] = ud2o(value.X, value.Y)
	elseif index == "Size" then
		if self._class == "Text" then
			self._instance.TextSize = value - 1
		else
			self._instance.Size = ud2o(value.X, value.Y)
		end
	elseif index == "Thickness" then
		if self._stroke ~= nil then
			self._stroke.Thickness = value
		end
	elseif index == "Filled" then
		self._instance.BackgroundTransparency = value and 1 - self.Transparency or 1
		self._instance.stroke.Enabled = not value
	elseif index == "Font" then
		self._instance.FontFace = fonts[value]
	elseif index == "Outline" then
		if self._tstroke == nil then
			self._tstroke = Instance.new("UIStroke")
			self._tstroke.Color = self.OutlineColor
			self._tstroke.Parent = self._instance
		end

		self._tstroke.Enabled = value
	elseif index == "OutlineColor" then
		if self._tstroke ~= nil then
			self._tstroke.Color = value
		end
	elseif index == "Center" then
		self._instance.TextXAlignment = if value then Enum.TextXAlignment.Center else Enum.TextXAlignment.Left
	elseif index == "Data" then
		self._instance.Image = value
	elseif index == "Rounding" then
		if self._corner == nil then
			self._corner = Instance.new("UICorner")
			self._corner.Parent = self._instance
		end

		self._corner.CornerRadius = ud(0, value)
	end

	rawset(self._properties, index, value)
end

return Drawing
