-- ==============================================================
--                    DONATE SHOP v6.0  (fullproject)
--          LocalScript  >  place inside StarterGui
--   Changes vs v5.2:
--     * Mobile-optimized: responsive window size, touch-friendly
--     * OpenBtn visible and correctly positioned on mobile (right-center)
--     * ScrollingFrame works on both PC (mousewheel) and mobile (touch drag)
--     * Unlimited items in CONFIG.Items – just add more entries
--     * DESCRIPTIONS table auto-extends (no manual indexing needed)
--     * All comments in English
-- ==============================================================

local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService       = game:GetService("TweenService")
local ContentProvider    = game:GetService("ContentProvider")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local GuiService         = game:GetService("GuiService")

local player    = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==========================================================
--   ASSETS  (replace IDs with your own Texture IDs)
-- ==========================================================
local ASSET_SHOP_ICON = "rbxassetid://117910148426176"  -- shop open button icon
local ASSET_DIAMOND   = "rbxassetid://72338868935627"   -- diamond in header
local ASSET_CURSOR    = "rbxassetid://126027539230800"  -- custom mouse cursor (PC only)
local ASSET_CLOSE_BTN = "rbxassetid://137208619078836"  -- close button icon

-- ==========================================================
--   DEVICE DETECTION
-- ==========================================================
local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ==========================================================
--   ITEM DESCRIPTIONS  (shown under each item name)
--   Use \n for a new line.  Index matches CONFIG.Items order.
--   Add as many as you need – one per item.
-- ==========================================================
local DESCRIPTIONS = {
	[1] = "Access to VIP zone\nAccess to VIP server\n+50% coin bonus per minute",
	[2] = "Everything from VIP\nExclusive aura effect\n+150% bonus on VIP server",
	[3] = "Maximum status\nAll server privileges\n+300% bonus everywhere",
	-- Add more descriptions here for new items:
	-- [4] = "Description for item 4",
}

-- ==========================================================
--   CONFIG  - main settings
-- ==========================================================
local CONFIG = {
	Title    = "Roblox Shop",
	Subtitle = "Support the project and get bonuses!",

	-- Window size: auto-scales for mobile
	WinW = isMobile and math.min(360, workspace.CurrentCamera.ViewportSize.X - 24) or 540,
	WinH = isMobile and math.min(560, workspace.CurrentCamera.ViewportSize.Y - 80)  or 620,

	Theme = {
		Blue        = Color3.fromRGB(50,  140, 255),
		BlueDark    = Color3.fromRGB(30,  110, 230),
		BlueLight   = Color3.fromRGB(100, 170, 255),
		BlueBorder  = Color3.fromRGB(80,  160, 255),
		BlueShadow  = Color3.fromRGB(20,   80, 200),
		White       = Color3.fromRGB(255, 255, 255),
		OffWhite    = Color3.fromRGB(245, 248, 255),
		TextDark    = Color3.fromRGB(30,   40,  70),
		TextGrey    = Color3.fromRGB(120, 135, 160),
		CardShadow  = Color3.fromRGB(210, 225, 248),
	},

	-- ==============================================================
	--   ITEMS LIST – add as many entries as you want!
	--   ProductId must match a Developer Product on create.roblox.com
	--   ImageId   = Texture ID of your decal (NOT the Decal asset ID)
	-- ==============================================================
	Items = {
		{
			Name      = "VIP",
			Price     = 199,
			ProductId = 3570859494,
			ImageId   = "rbxassetid://135739066922575",
			Color     = Color3.fromRGB(255, 190, 30),
			Badge     = "POPULAR",
		},
		{
			Name      = "VIP PLUS",
			Price     = 399,
			ProductId = 3570859843,
			ImageId   = "rbxassetid://79139520941350",
			Color     = Color3.fromRGB(130, 80, 255),
			Badge     = "TOP CHOICE",
		},
		{
			Name      = "VIP ULTIMATE",
			Price     = 799,
			ProductId = 3570860030,
			ImageId   = "rbxassetid://106676930452284",
			Color     = Color3.fromRGB(255, 55, 95),
			Badge     = "BEST",
		},
		-- -------------------------------------------------------
		-- To add more items, copy the block below and fill it in:
		-- {
		--     Name      = "MY PASS",
		--     Price     = 999,
		--     ProductId = 0000000000,
		--     ImageId   = "rbxassetid://000000000000",
		--     Color     = Color3.fromRGB(0, 200, 120),
		--     Badge     = "NEW",       -- set to nil to hide badge
		-- },
		-- -------------------------------------------------------
	},
}

-- ==========================================================
--   PRELOAD ASSETS (background, no freeze)
-- ==========================================================
task.spawn(function()
	local assets = { ASSET_SHOP_ICON, ASSET_DIAMOND, ASSET_CURSOR, ASSET_CLOSE_BTN }
	for _, item in ipairs(CONFIG.Items) do
		table.insert(assets, item.ImageId)
	end
	for _, id in ipairs(assets) do
		local ok, err = pcall(function()
			ContentProvider:PreloadAsync({ id })
		end)
		if ok then
			print("[DonateShop] Loaded:", id)
		else
			warn("[DonateShop] Failed to load:", id, err)
		end
	end
	print("[DonateShop] All assets loaded!")
end)

-- ==========================================================
--   SCREEN GUI
-- ==========================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "DonateShopGui"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder   = 10
ScreenGui.IgnoreGuiInset = true   -- prevents top-bar offset on mobile
ScreenGui.Parent         = playerGui

-- ==========================================================
--   CUSTOM CURSOR  (PC only – hidden on mobile)
-- ==========================================================
if not isMobile then
	UserInputService.MouseIconEnabled = false
	local CursorLabel = Instance.new("ImageLabel")
	CursorLabel.Name                   = "CustomCursor"
	CursorLabel.Size                   = UDim2.new(0, 40, 0, 40)
	CursorLabel.AnchorPoint            = Vector2.new(0, 0)
	CursorLabel.BackgroundTransparency = 1
	CursorLabel.Image                  = ASSET_CURSOR
	CursorLabel.ScaleType              = Enum.ScaleType.Fit
	CursorLabel.ImageTransparency      = 0
	CursorLabel.ZIndex                 = 9999
	CursorLabel.Parent                 = ScreenGui

	local CURSOR_OFFSET_X = 0
	local CURSOR_OFFSET_Y = -10
	RunService.RenderStepped:Connect(function()
		local pos = UserInputService:GetMouseLocation()
		CursorLabel.Position = UDim2.new(
			0, pos.X + CURSOR_OFFSET_X,
			0, pos.Y + CURSOR_OFFSET_Y
		)
	end)
end

local W = CONFIG.WinW
local H = CONFIG.WinH

-- ==========================================================
--   BORDER FRAME (glowing outline)
-- ==========================================================
local BorderFrame = Instance.new("Frame")
BorderFrame.Name                   = "BorderFrame"
BorderFrame.AnchorPoint            = Vector2.new(0.5, 0.5)
BorderFrame.Size                   = UDim2.new(0, W + 4, 0, H + 4)
BorderFrame.Position               = UDim2.new(0.5, 0, 0.5, 0)
BorderFrame.BackgroundColor3       = CONFIG.Theme.BlueBorder
BorderFrame.BackgroundTransparency = 0
BorderFrame.BorderSizePixel        = 0
BorderFrame.ZIndex                 = 9
BorderFrame.Visible                = false
BorderFrame.Parent                 = ScreenGui
local BorderCorner = Instance.new("UICorner")
BorderCorner.CornerRadius = UDim.new(0, 25)
BorderCorner.Parent = BorderFrame
local BorderGrad = Instance.new("UIGradient")
BorderGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   Color3.fromRGB(120, 200, 255)),
	ColorSequenceKeypoint.new(0.4, Color3.fromRGB(60,  150, 255)),
	ColorSequenceKeypoint.new(0.7, Color3.fromRGB(160, 210, 255)),
	ColorSequenceKeypoint.new(1,   Color3.fromRGB(80,  160, 255)),
})
BorderGrad.Rotation = 135
BorderGrad.Parent = BorderFrame

-- ==========================================================
--   SHADOW
-- ==========================================================
local ShadowContainer = Instance.new("Frame")
ShadowContainer.Name                   = "ShadowContainer"
ShadowContainer.AnchorPoint            = Vector2.new(0.5, 0.5)
ShadowContainer.Size                   = UDim2.new(0, W, 0, H)
ShadowContainer.Position               = UDim2.new(0.5, 0, 0.5, 0)
ShadowContainer.BackgroundTransparency = 1
ShadowContainer.BorderSizePixel        = 0
ShadowContainer.ZIndex                 = 8
ShadowContainer.Visible                = false
ShadowContainer.Parent                 = ScreenGui
local function makeShadow(sz, pos, alpha, r)
	local s = Instance.new("Frame")
	s.AnchorPoint = Vector2.new(0.5,0.5); s.Size = sz; s.Position = pos
	s.BackgroundColor3 = Color3.fromRGB(20, 60, 140)
	s.BackgroundTransparency = alpha; s.BorderSizePixel = 0; s.ZIndex = 7
	s.Parent = ShadowContainer
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r); c.Parent = s
end
makeShadow(UDim2.new(1,32,1,32), UDim2.new(0.5,0,0.5,12), 0.78, 30)
makeShadow(UDim2.new(1,18,1,18), UDim2.new(0.5,0,0.5, 7), 0.85, 28)
makeShadow(UDim2.new(1, 8,1, 8), UDim2.new(0.5,0,0.5, 3), 0.92, 26)

-- ==========================================================
--   MAIN WINDOW
-- ==========================================================
local Win = Instance.new("Frame")
Win.Name             = "Win"
Win.AnchorPoint      = Vector2.new(0.5, 0.5)
Win.Size             = UDim2.new(0, W, 0, H)
Win.Position         = UDim2.new(0.5, 0, 0.5, 0)
Win.BackgroundColor3 = CONFIG.Theme.OffWhite
Win.BorderSizePixel  = 0
Win.ClipsDescendants = true
Win.ZIndex           = 10
Win.Visible          = false
Win.Parent           = ScreenGui
local WinCorner = Instance.new("UICorner")
WinCorner.CornerRadius = UDim.new(0, 22)
WinCorner.Parent = Win

-- ==========================================================
--   HEADER
-- ==========================================================
local headerH = isMobile and 80 or 96
local Header = Instance.new("Frame")
Header.Name = "Header"; Header.Size = UDim2.new(1, 0, 0, headerH)
Header.BackgroundColor3 = CONFIG.Theme.Blue
Header.BorderSizePixel = 0; Header.ZIndex = 11; Header.Parent = Win
local HCorner = Instance.new("UICorner")
HCorner.CornerRadius = UDim.new(0, 22); HCorner.Parent = Header
local HFix = Instance.new("Frame")
HFix.Size = UDim2.new(1,0,0,22); HFix.Position = UDim2.new(0,0,1,-22)
HFix.BackgroundColor3 = CONFIG.Theme.Blue; HFix.BorderSizePixel = 0
HFix.ZIndex = 11; HFix.Parent = Header
for _, v in ipairs({{-45,-45,140,0.90},{360,-28,95,0.91},{440,32,60,0.89}}) do
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0,v[3],0,v[3]); f.Position = UDim2.new(0,v[1],0,v[2])
	f.BackgroundColor3 = Color3.fromRGB(255,255,255); f.BackgroundTransparency = v[4]
	f.BorderSizePixel = 0; f.ZIndex = 11; f.Parent = Header
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(1,0); c.Parent = f
end
local iconSize = isMobile and 44 or 54
local HIconBg = Instance.new("Frame")
HIconBg.Size = UDim2.new(0,iconSize,0,iconSize); HIconBg.Position = UDim2.new(0,16,0.5,-iconSize/2)
HIconBg.BackgroundColor3 = Color3.fromRGB(255,255,255); HIconBg.BackgroundTransparency = 0.80
HIconBg.BorderSizePixel = 0; HIconBg.ZIndex = 12; HIconBg.Parent = Header
local HIconBgC = Instance.new("UICorner"); HIconBgC.CornerRadius = UDim.new(1,0); HIconBgC.Parent = HIconBg
local HIcon = Instance.new("ImageLabel")
HIcon.Size = UDim2.new(1,-10,1,-10); HIcon.AnchorPoint = Vector2.new(0.5,0.5)
HIcon.Position = UDim2.new(0.5,0,0.5,0); HIcon.BackgroundTransparency = 1
HIcon.Image = ASSET_DIAMOND
HIcon.ScaleType = Enum.ScaleType.Fit
HIcon.ImageTransparency = 0
HIcon.ZIndex = 13; HIcon.Parent = HIconBg
local titleX = iconSize + 26
local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size = UDim2.new(1,-titleX-50,0, isMobile and 26 or 34)
TitleLbl.Position = UDim2.new(0, titleX, 0, isMobile and 14 or 16)
TitleLbl.BackgroundTransparency = 1; TitleLbl.Text = CONFIG.Title
TitleLbl.TextColor3 = Color3.fromRGB(255,255,255); TitleLbl.TextSize = isMobile and 18 or 23
TitleLbl.Font = Enum.Font.GothamBold; TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 12; TitleLbl.Parent = Header
local SubLbl = Instance.new("TextLabel")
SubLbl.Size = UDim2.new(1,-titleX-50,0, isMobile and 16 or 20)
SubLbl.Position = UDim2.new(0, titleX, 0, isMobile and 42 or 52)
SubLbl.BackgroundTransparency = 1; SubLbl.Text = CONFIG.Subtitle
SubLbl.TextColor3 = Color3.fromRGB(195,220,255); SubLbl.TextSize = isMobile and 11 or 13
SubLbl.Font = Enum.Font.Gotham; SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.ZIndex = 12; SubLbl.Parent = Header

-- ==========================================================
--   CLOSE BUTTON
-- ==========================================================
local closeBtnSize = isMobile and 34 or 38
local CloseBtn = Instance.new("ImageButton")
CloseBtn.Size = UDim2.new(0,closeBtnSize,0,closeBtnSize)
CloseBtn.Position = UDim2.new(1,-(closeBtnSize+14),0.5,-(closeBtnSize/2))
CloseBtn.BackgroundTransparency = 1
CloseBtn.Image = ASSET_CLOSE_BTN
CloseBtn.ScaleType = Enum.ScaleType.Fit
CloseBtn.ImageTransparency = 0
CloseBtn.ZIndex = 15; CloseBtn.Parent = Header
CloseBtn.MouseEnter:Connect(function()
	TweenService:Create(CloseBtn,TweenInfo.new(0.13),{
		Size=UDim2.new(0,closeBtnSize+5,0,closeBtnSize+5),
		Position=UDim2.new(1,-(closeBtnSize+17),0.5,-((closeBtnSize+5)/2))
	}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
	TweenService:Create(CloseBtn,TweenInfo.new(0.13),{
		Size=UDim2.new(0,closeBtnSize,0,closeBtnSize),
		Position=UDim2.new(1,-(closeBtnSize+14),0.5,-(closeBtnSize/2))
	}):Play()
end)

-- ==========================================================
--   DIVIDER
-- ==========================================================
local Div = Instance.new("Frame")
Div.Size = UDim2.new(1,0,0,2); Div.Position = UDim2.new(0,0,0,headerH)
Div.BackgroundColor3 = CONFIG.Theme.BlueLight; Div.BorderSizePixel = 0
Div.ZIndex = 11; Div.Parent = Win
local DivG = Instance.new("UIGradient")
DivG.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0,   CONFIG.Theme.Blue),
	ColorSequenceKeypoint.new(0.5, CONFIG.Theme.BlueLight),
	ColorSequenceKeypoint.new(1,   CONFIG.Theme.Blue),
}); DivG.Parent = Div

-- ==========================================================
--   SCROLL AREA
--   • PC:     mousewheel + drag scrollbar
--   • Mobile: touch drag (native ScrollingFrame behaviour)
-- ==========================================================
local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "ScrollFrame"
Scroll.Size = UDim2.new(1, 0, 1, -(headerH + 6))
Scroll.Position = UDim2.new(0, 0, 0, headerH + 2)
Scroll.BackgroundColor3 = CONFIG.Theme.OffWhite
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = isMobile and 4 or 3
Scroll.ScrollBarImageColor3 = CONFIG.Theme.Blue
Scroll.ScrollBarImageTransparency = 0.4
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
-- Enable elastic scroll and touch drag on mobile
Scroll.ElasticBehavior = isMobile and Enum.ElasticBehavior.Always or Enum.ElasticBehavior.WhenScrollable
Scroll.ScrollingEnabled = true
Scroll.ZIndex = 11; Scroll.Parent = Win
local SP = Instance.new("UIPadding")
SP.PaddingTop    = UDim.new(0,14)
SP.PaddingBottom = UDim.new(0,14)
SP.PaddingLeft   = UDim.new(0, isMobile and 10 or 16)
SP.PaddingRight  = UDim.new(0, isMobile and 10 or 16)
SP.Parent = Scroll
local SL = Instance.new("UIListLayout")
SL.SortOrder = Enum.SortOrder.LayoutOrder
SL.Padding = UDim.new(0, isMobile and 10 or 12)
SL.Parent = Scroll

-- ==========================================================
--   PC MOUSEWHEEL SCROLL (extra smooth delta)
-- ==========================================================
if not isMobile then
	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseWheel then
			local pos = Win.AbsolutePosition
			local size = Win.AbsoluteSize
			local mouse = UserInputService:GetMouseLocation()
			if mouse.X >= pos.X and mouse.X <= pos.X + size.X and
				mouse.Y >= pos.Y and mouse.Y <= pos.Y + size.Y then
				local delta = -input.Position.Z * 60  -- pixels per notch
				local newY  = math.clamp(
					Scroll.CanvasPosition.Y + delta,
					0,
					math.max(0, Scroll.AbsoluteCanvasSize.Y - Scroll.AbsoluteSize.Y)
				)
				TweenService:Create(Scroll, TweenInfo.new(0.12, Enum.EasingStyle.Quad), {
					CanvasPosition = Vector2.new(0, newY)
				}):Play()
			end
		end
	end)
end

-- ==========================================================
--   ITEM CARDS
-- ==========================================================
local cardH = isMobile and 100 or 120

local function createCard(item, index)
	local Wrap = Instance.new("Frame")
	Wrap.Size = UDim2.new(1, 0, 0, cardH)
	Wrap.BackgroundTransparency = 1; Wrap.BorderSizePixel = 0
	Wrap.LayoutOrder = index; Wrap.ZIndex = 11; Wrap.Parent = Scroll

	local Shad = Instance.new("Frame")
	Shad.AnchorPoint = Vector2.new(0.5,0.5); Shad.Size = UDim2.new(1,6,1,6)
	Shad.Position = UDim2.new(0.5,0,0.5,5)
	Shad.BackgroundColor3 = CONFIG.Theme.CardShadow
	Shad.BorderSizePixel = 0; Shad.ZIndex = 11; Shad.Parent = Wrap
	local ShC = Instance.new("UICorner"); ShC.CornerRadius = UDim.new(0,17); ShC.Parent = Shad

	local Card = Instance.new("Frame")
	Card.Name = "Card"; Card.Size = UDim2.new(1,0,1,0)
	Card.BackgroundColor3 = CONFIG.Theme.White; Card.BorderSizePixel = 0
	Card.ZIndex = 12; Card.ClipsDescendants = true; Card.Parent = Wrap
	local CardC = Instance.new("UICorner"); CardC.CornerRadius = UDim.new(0,15); CardC.Parent = Card

	local Stripe = Instance.new("Frame")
	local stripeH = isMobile and 64 or 78
	Stripe.Size = UDim2.new(0,5,0,stripeH); Stripe.Position = UDim2.new(0,isMobile and 10 or 13,0.5,-stripeH/2)
	Stripe.BackgroundColor3 = item.Color; Stripe.BorderSizePixel = 0
	Stripe.ZIndex = 13; Stripe.Parent = Card
	local StrC = Instance.new("UICorner"); StrC.CornerRadius = UDim.new(1,0); StrC.Parent = Stripe

	local imgSize = isMobile and 58 or 70
	local ImgBg = Instance.new("Frame")
	ImgBg.Size = UDim2.new(0,imgSize,0,imgSize)
	ImgBg.Position = UDim2.new(0, isMobile and 22 or 28, 0.5,-imgSize/2)
	ImgBg.BackgroundColor3 = item.Color; ImgBg.BackgroundTransparency = 0.85
	ImgBg.BorderSizePixel = 0; ImgBg.ZIndex = 13; ImgBg.Parent = Card
	local ImgBgC = Instance.new("UICorner"); ImgBgC.CornerRadius = UDim.new(1,0); ImgBgC.Parent = ImgBg
	local Img = Instance.new("ImageLabel")
	Img.Size = UDim2.new(1,-14,1,-14)
	Img.AnchorPoint = Vector2.new(0.5,0.5)
	Img.Position = UDim2.new(0.5,0,0.5,0)
	Img.BackgroundTransparency = 1
	Img.Image = item.ImageId
	Img.ScaleType = Enum.ScaleType.Fit
	Img.ImageTransparency = 0
	Img.ZIndex = 14; Img.Parent = ImgBg

	if item.Badge then
		local Badge = Instance.new("Frame")
		Badge.AnchorPoint = Vector2.new(1,0)
		Badge.Position = UDim2.new(1, isMobile and -8 or -12, 0, isMobile and 8 or 12)
		Badge.BackgroundColor3 = item.Color; Badge.BorderSizePixel = 0
		Badge.AutomaticSize = Enum.AutomaticSize.X
		Badge.Size = UDim2.new(0,0,0, isMobile and 18 or 22); Badge.ZIndex = 14; Badge.Parent = Card
		local BadC = Instance.new("UICorner"); BadC.CornerRadius = UDim.new(1,0); BadC.Parent = Badge
		local BadP = Instance.new("UIPadding")
		BadP.PaddingLeft = UDim.new(0,7); BadP.PaddingRight = UDim.new(0,7); BadP.Parent = Badge
		local BadL = Instance.new("TextLabel")
		BadL.AutomaticSize = Enum.AutomaticSize.X; BadL.Size = UDim2.new(0,0,1,0)
		BadL.BackgroundTransparency = 1; BadL.Text = item.Badge
		BadL.TextSize = isMobile and 9 or 11; BadL.Font = Enum.Font.GothamBold
		BadL.TextColor3 = Color3.fromRGB(255,255,255); BadL.ZIndex = 15; BadL.Parent = Badge
	end

	local textX = (isMobile and 22 or 28) + imgSize + 10
	local buyW  = isMobile and 88 or 106
	local buyH  = isMobile and 36 or 42

	local NameLbl = Instance.new("TextLabel")
	NameLbl.Size = UDim2.new(1,-(textX + buyW + 16),0, isMobile and 22 or 28)
	NameLbl.Position = UDim2.new(0, textX, 0.5, isMobile and -22 or -26)
	NameLbl.BackgroundTransparency = 1; NameLbl.Text = item.Name
	NameLbl.TextColor3 = CONFIG.Theme.TextDark; NameLbl.TextSize = isMobile and 14 or 17
	NameLbl.Font = Enum.Font.GothamBold; NameLbl.TextXAlignment = Enum.TextXAlignment.Left
	NameLbl.ZIndex = 13; NameLbl.Parent = Card

	local DescLbl = Instance.new("TextLabel")
	DescLbl.Size = UDim2.new(1,-(textX + buyW + 16),0, isMobile and 40 or 50)
	DescLbl.Position = UDim2.new(0, textX, 0.5, isMobile and 2 or 2)
	DescLbl.BackgroundTransparency = 1; DescLbl.Text = DESCRIPTIONS[index] or ""
	DescLbl.TextColor3 = CONFIG.Theme.TextGrey; DescLbl.TextSize = isMobile and 9 or 11
	DescLbl.Font = Enum.Font.Gotham; DescLbl.TextXAlignment = Enum.TextXAlignment.Left
	DescLbl.TextYAlignment = Enum.TextYAlignment.Top
	DescLbl.TextWrapped = true; DescLbl.ZIndex = 13; DescLbl.Parent = Card

	local Buy = Instance.new("TextButton")
	Buy.Size = UDim2.new(0, buyW, 0, buyH)
	Buy.Position = UDim2.new(1, -(buyW + 10), 0.5, -buyH/2)
	Buy.BackgroundColor3 = item.Color; Buy.BorderSizePixel = 0
	Buy.Text = "R$ "..item.Price
	Buy.TextColor3 = Color3.fromRGB(255,255,255); Buy.TextSize = isMobile and 12 or 15
	Buy.Font = Enum.Font.GothamBold; Buy.ZIndex = 14; Buy.Parent = Card
	local BuyC = Instance.new("UICorner"); BuyC.CornerRadius = UDim.new(0,11); BuyC.Parent = Buy
	local BuyG = Instance.new("UIGradient")
	BuyG.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.0),
		NumberSequenceKeypoint.new(0.5, 0.15),
		NumberSequenceKeypoint.new(1,   0.35),
	}); BuyG.Rotation = 90; BuyG.Parent = Buy

	-- Hover animations (PC only – no hover on touch)
	if not isMobile then
		Card.MouseEnter:Connect(function()
			TweenService:Create(Card,TweenInfo.new(0.18),{BackgroundColor3=Color3.fromRGB(248,251,255)}):Play()
			TweenService:Create(Shad,TweenInfo.new(0.18),{
				Position=UDim2.new(0.5,0,0.5,7), BackgroundColor3=Color3.fromRGB(180,205,245)
			}):Play()
		end)
		Card.MouseLeave:Connect(function()
			TweenService:Create(Card,TweenInfo.new(0.18),{BackgroundColor3=CONFIG.Theme.White}):Play()
			TweenService:Create(Shad,TweenInfo.new(0.18),{
				Position=UDim2.new(0.5,0,0.5,5), BackgroundColor3=CONFIG.Theme.CardShadow
			}):Play()
		end)
		Buy.MouseEnter:Connect(function()
			TweenService:Create(Buy,TweenInfo.new(0.13),{
				Size=UDim2.new(0,buyW+6,0,buyH+2), Position=UDim2.new(1,-(buyW+13),0.5,-(buyH/2+1))
			}):Play()
		end)
		Buy.MouseLeave:Connect(function()
			TweenService:Create(Buy,TweenInfo.new(0.13),{
				Size=UDim2.new(0,buyW,0,buyH), Position=UDim2.new(1,-(buyW+10),0.5,-buyH/2)
			}):Play()
		end)
	end

	Buy.MouseButton1Down:Connect(function()
		TweenService:Create(Buy,TweenInfo.new(0.08),{
			Size=UDim2.new(0,buyW-8,0,buyH-4),
			Position=UDim2.new(1,-(buyW+6),0.5,-(buyH/2-2))
		}):Play()
	end)
	Buy.MouseButton1Up:Connect(function()
		TweenService:Create(Buy,TweenInfo.new(0.10),{
			Size=UDim2.new(0,buyW,0,buyH), Position=UDim2.new(1,-(buyW+10),0.5,-buyH/2)
		}):Play()
	end)
	Buy.MouseButton1Click:Connect(function()
		local ok, err = pcall(function()
			MarketplaceService:PromptProductPurchase(player, item.ProductId)
		end)
		if not ok then warn("[DonateShop] Purchase error:", err) end
	end)
end

for i, item in ipairs(CONFIG.Items) do createCard(item, i) end

-- ==========================================================
--   OPEN BUTTON  –  right side, vertically centred
--   Visible on BOTH PC and mobile (was missing on mobile)
-- ==========================================================
local openBtnSize = isMobile and 64 or 72
local OpenBtn = Instance.new("ImageButton")
OpenBtn.Name             = "OpenBtn"
OpenBtn.AnchorPoint      = Vector2.new(1, 0.5)
OpenBtn.Size             = UDim2.new(0, openBtnSize, 0, openBtnSize)
OpenBtn.Position = UDim2.new(1, 0, 0.5, 0)
OpenBtn.BackgroundTransparency = 1
OpenBtn.BorderSizePixel  = 0
OpenBtn.Image            = ASSET_SHOP_ICON
OpenBtn.ScaleType        = Enum.ScaleType.Fit
OpenBtn.ImageTransparency = 0
OpenBtn.ZIndex           = 20
OpenBtn.Parent           = ScreenGui

if not isMobile then
	OpenBtn.MouseEnter:Connect(function()
		TweenService:Create(OpenBtn, TweenInfo.new(0.18), {
			Size = UDim2.new(0, openBtnSize+10, 0, openBtnSize+10)
		}):Play()
	end)
	OpenBtn.MouseLeave:Connect(function()
		TweenService:Create(OpenBtn, TweenInfo.new(0.18), {
			Size = UDim2.new(0, openBtnSize, 0, openBtnSize)
		}):Play()
	end)
end

-- ==========================================================
--   OPEN / CLOSE LOGIC
-- ==========================================================
local isOpen, animating = false, false

local function setVisible(state)
	Win.Visible             = state
	ShadowContainer.Visible = state
	BorderFrame.Visible     = state
end

local function openShop()
	if animating or isOpen then return end
	animating = true; isOpen = true
	setVisible(true)
	Win.Size             = UDim2.new(0, W, 0, 0)
	ShadowContainer.Size = UDim2.new(0, W, 0, 0)
	BorderFrame.Size     = UDim2.new(0, W+4, 0, 0)
	local tw = TweenService:Create(Win,
		TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size=UDim2.new(0,W,0,H) })
	TweenService:Create(ShadowContainer,
		TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size=UDim2.new(0,W,0,H) }):Play()
	TweenService:Create(BorderFrame,
		TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
		{ Size=UDim2.new(0,W+4,0,H+4) }):Play()
	tw:Play()
	tw.Completed:Connect(function() animating = false end)
end

local function closeShop()
	if animating or not isOpen then return end
	animating = true; isOpen = false
	local tw = TweenService:Create(Win,
		TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{ Size=UDim2.new(0,W,0,0) })
	TweenService:Create(ShadowContainer,
		TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{ Size=UDim2.new(0,W,0,0) }):Play()
	TweenService:Create(BorderFrame,
		TweenInfo.new(0.30, Enum.EasingStyle.Back, Enum.EasingDirection.In),
		{ Size=UDim2.new(0,W+4,0,0) }):Play()
	tw:Play()
	tw.Completed:Connect(function() setVisible(false); animating = false end)
end

OpenBtn.MouseButton1Click:Connect(openShop)
CloseBtn.MouseButton1Click:Connect(closeShop)

-- ==========================================================
--   PURCHASE NOTIFICATION
-- ==========================================================
local function showNotif(name, color)
	local N = Instance.new("Frame")
	local notifW = isMobile and 280 or 330
	N.AnchorPoint = Vector2.new(0.5,0); N.Size = UDim2.new(0,notifW,0, isMobile and 62 or 72)
	N.Position = UDim2.new(0.5,0,0,-90)
	N.BackgroundColor3 = CONFIG.Theme.White
	N.BorderSizePixel = 0; N.ZIndex = 100; N.Parent = ScreenGui
	local NC = Instance.new("UICorner"); NC.CornerRadius = UDim.new(0,14); NC.Parent = N
	local NBord = Instance.new("Frame")
	NBord.AnchorPoint = Vector2.new(0.5,0.5); NBord.Size = UDim2.new(1,3,1,3)
	NBord.Position = UDim2.new(0.5,0,0.5,0)
	NBord.BackgroundColor3 = color; NBord.BackgroundTransparency = 0.6
	NBord.BorderSizePixel = 0; NBord.ZIndex = 99; NBord.Parent = N
	local NBC = Instance.new("UICorner"); NBC.CornerRadius = UDim.new(0,16); NBC.Parent = NBord
	local NS = Instance.new("Frame")
	NS.AnchorPoint = Vector2.new(0.5,0.5); NS.Size = UDim2.new(1,12,1,12)
	NS.Position = UDim2.new(0.5,0,0.5,4)
	NS.BackgroundColor3 = CONFIG.Theme.CardShadow
	NS.BorderSizePixel = 0; NS.ZIndex = 98; NS.Parent = N
	local NSC = Instance.new("UICorner"); NSC.CornerRadius = UDim.new(0,18); NSC.Parent = NS
	local NStr = Instance.new("Frame")
	NStr.Size = UDim2.new(0,4,0,46); NStr.Position = UDim2.new(0,13,0.5,-23)
	NStr.BackgroundColor3 = color; NStr.BorderSizePixel = 0; NStr.ZIndex = 101; NStr.Parent = N
	local NSTC = Instance.new("UICorner"); NSTC.CornerRadius = UDim.new(1,0); NSTC.Parent = NStr
	local NDia = Instance.new("ImageLabel")
	NDia.Size = UDim2.new(0,24,0,24); NDia.Position = UDim2.new(0,24,0,12)
	NDia.BackgroundTransparency = 1; NDia.Image = ASSET_DIAMOND
	NDia.ScaleType = Enum.ScaleType.Fit; NDia.ImageTransparency = 0
	NDia.ZIndex = 102; NDia.Parent = N
	local NT = Instance.new("TextLabel")
	NT.Size = UDim2.new(1,-65,0,26); NT.Position = UDim2.new(0,54,0,12)
	NT.BackgroundTransparency = 1; NT.Text = "Purchase successful!"
	NT.TextColor3 = CONFIG.Theme.TextDark; NT.TextSize = isMobile and 13 or 15
	NT.Font = Enum.Font.GothamBold; NT.TextXAlignment = Enum.TextXAlignment.Left
	NT.ZIndex = 102; NT.Parent = N
	local ND = Instance.new("TextLabel")
	ND.Size = UDim2.new(1,-65,0,22); ND.Position = UDim2.new(0,54,0,38)
	ND.BackgroundTransparency = 1; ND.Text = "You bought: "..name
	ND.TextColor3 = CONFIG.Theme.TextGrey; ND.TextSize = isMobile and 10 or 12
	ND.Font = Enum.Font.Gotham; ND.TextXAlignment = Enum.TextXAlignment.Left
	ND.ZIndex = 102; ND.Parent = N
	TweenService:Create(N, TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{Position=UDim2.new(0.5,0,0,16)}):Play()
	task.delay(3.5, function()
		if N and N.Parent then
			TweenService:Create(N,TweenInfo.new(0.28),{Position=UDim2.new(0.5,0,0,-90)}):Play()
			task.delay(0.3, function() if N then N:Destroy() end end)
		end
	end)
end

MarketplaceService.PromptProductPurchaseFinished:Connect(function(uid, pid, bought)
	if not bought or uid ~= player.UserId then return end
	for _, item in ipairs(CONFIG.Items) do
		if item.ProductId == pid then showNotif(item.Name, item.Color); break end
	end
end)

print("[DonateShop] Client loaded successfully! Mobile:", isMobile)
