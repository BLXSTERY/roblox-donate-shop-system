-- ã==============================================================¬
-- ¦              DONATE SHOP SERVER v5.0                        ¦
-- ¦           Script  >  place in ServerScriptService           ¦
-- ¦==============================================================¦
-- ¦  HOW TO CONFIGURE:                                          ¦
-- ¦  › ProductId values must match the LocalScript!             ¦
-- ¦    Find them: create.roblox.com > Monetization > Dev Prods  ¦
-- ¦  › To give rewards, find the REWARD SECTION below           ¦
-- ¦    Add badges, tools, gamepasses, etc. there                ¦
-- ¦  › To add a new product, add a block to the PRODUCTS table  ¦
-- ¦    [PRODUCT_ID] = { Name, CoinBonus, Reward, Tag }          ¦
-- ¦    Then create a Developer Product on create.roblox.com     ¦
-- L==============================================================-

local MarketplaceService = game:GetService("MarketplaceService")
local Players            = game:GetService("Players")

-- ==========================================================
--   DEVELOPER PRODUCTS  (must match LocalScript ProductIds)
-- ==========================================================
local PRODUCTS = {
	[3570859494] = {           -- VIP (199 R$)
		Name      = "VIP",
		CoinBonus = 1.5,       -- coin multiplier x1.5
		Reward    = 500,       -- coins given on purchase
		Tag       = "[VIP]",   -- chat tag attribute
	},
	[3570859843] = {           -- VIP PLUS (399 R$)
		Name      = "VIP PLUS",
		CoinBonus = 2.5,
		Reward    = 1500,
		Tag       = "[VIP+]",
	},
	[3570860030] = {           -- VIP ULTIMATE (799 R$)
		Name      = "VIP ULTIMATE",
		CoinBonus = 4.0,
		Reward    = 5000,
		Tag       = "[ULTIMATE]",
	},
}

-- ==========================================================
--   LEADERSTATS  (created when player joins)
-- ==========================================================
Players.PlayerAdded:Connect(function(player)
	local ls = Instance.new("Folder")
	ls.Name   = "leaderstats"
	ls.Parent = player

	local coins = Instance.new("IntValue")
	coins.Name   = "Coins"
	coins.Value  = 0
	coins.Parent = ls

	-- Passive coin income every 60 seconds (scaled by CoinBonus attribute)
	task.spawn(function()
		while player.Parent do
			task.wait(60)
			local bonus = player:GetAttribute("CoinBonus") or 1.0
			local ls2   = player:FindFirstChild("leaderstats")
			if ls2 then
				local c = ls2:FindFirstChild("Coins")
				if c then c.Value += math.floor(10 * bonus) end
			end
		end
	end)
end)

-- ==========================================================
--   PROCESS RECEIPT  (handles Developer Product purchases)
--   IMPORTANT: there must be only ONE ProcessReceipt per server!
-- ==========================================================
MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)

	if not player then
		-- Player left the server; Roblox will retry later
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local data = PRODUCTS[receiptInfo.ProductId]
	if not data then
		-- Unknown product; confirm anyway so it is not retried forever
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	-- ==============================================
	--   REWARD SECTION  < add your custom logic here
	-- ==============================================

	-- 1. Give coins on purchase
	local ls = player:FindFirstChild("leaderstats")
	if ls then
		local coins = ls:FindFirstChild("Coins")
		if coins then
			coins.Value += data.Reward
		end
	end

	-- 2. Set coin multiplier (read by the passive income loop above)
	player:SetAttribute("CoinBonus", data.CoinBonus)

	-- 3. Set chat tag attribute (read by your chat script if you have one)
	player:SetAttribute("ChatTag", data.Tag)

	-- 4. Set purchase flag (other scripts can check this)
	player:SetAttribute("Has_" .. data.Name:gsub(" ", "_"), true)

	-- 5. (optional) Give a badge:
	--    local BadgeService = game:GetService("BadgeService")
	--    BadgeService:AwardBadge(player.UserId, YOUR_BADGE_ID)

	-- 6. (optional) Give a tool from ServerStorage:
	--    local tool = game.ServerStorage:FindFirstChild("VIP_Sword")
	--    if tool then tool:Clone().Parent = player.Backpack end

	-- 7. (optional) Give a gamepass effect via a RemoteEvent:
	--    game.ReplicatedStorage.VipEffect:FireClient(player, data.Name)

	print(("[DonateShop Server] %s bought %s | +%d coins"):format(
		player.Name, data.Name, data.Reward
		))

	-- REQUIRED: without this line Roblox will keep retrying forever
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

print("[DonateShop Server] Server started successfully!")
