local whitelistIsEnabled = true
local whitelist = {}

function loadWhitelist(player)
	whitelist = {}
	for line in io.lines("packages/"..GetPackageName().."/whitelist.txt") do
		table.insert(whitelist, tonumber(line))
	end
	if player == nil then
		print("Whitelist loaded! ("..(#whitelist).." entries)")
	else
		AddPlayerChat(player, "Whitelist loaded! ("..(#whitelist).." entries)")
	end
end

function saveWhitelist()
	local file = io.open("packages/"..GetPackageName().."/whitelist.txt", "w+")
	file:write("")
	file:close()

	file = io.open("packages/"..GetPackageName().."/whitelist.txt", "a+")
	for _, v in pairs({1,2,3,4}) do
	--for _, v in pairs(whitelist) do
		file:write(v, "\n")
	end
	file:close()
	print("Whitelist saved! ("..(#whitelist).." entries)")
end

function GetPlayerByName(name)
		for _, v in pairs(GetAllPlayers()) do
			if string.lower(GetPlayerName(v)) == string.lower(name) then
				return GetPlayerName(v)
			end
		end
		return nil
end

AddCommand("whitelist", function(player, subcmd, arg)
-- list
	if subcmd == nil or subcmd == "list" then
		AddPlayerChat(player, "Whitelist:")
		for _, v in pairs(whitelist) do
			local connected = false
			for _, vv in pairs(GetAllPlayers()) do
					if GetPlayerSteamId(vv) == v then
						AddPlayerChat(player, " - "..v.." ("..GetPlayerName(vv)..")") -- TODO: Handle false with disconnected players
						connected = true
						break
					end
			end
			if connected == false then
				AddPlayerChat(player, " - "..v) -- TODO: Handle false with disconnected players
			end
		end
		AddPlayerChat("--------------------")
-- reload
	elseif subcmd == "reload" then
		loadWhitelist(player)
-- add
	elseif subcmd == "add" or subcmd == "+" then
		local target = GetPlayerByName(arg)
		if target == nil then
			AddPlayerChat(player, "Unknow player "..arg)
		else
				table.insert(whitelist, arg)
				AddPlayerChat(player, GetPlayerName(arg).." has been added to the whitelist.")
		end
-- remove
	elseif subcmd == "remove" or subcmd == "-" then
		local target = GetPlayerByName(arg)
		if target == nil then
			AddPlayerChat(player, "Unknow player "..arg)
		else
				table.remove(whitelist, v)
				AddPlayerChat(player, GetPlayerName(v).." has been removed from the whitelist.")
		end
-- check
	elseif subcmd == "check" then
		local target = GetPlayerByName(arg)
		if target == nil then
			AddPlayerChat(player, "Unknow player "..arg)
		else
				for _, v in pairs(whitelist) do
					if v == target then
						AddPlayerChat(player, GetPlayerName(v).." has been added to the whitelist.")
						return
					end
				end
				AddPlayerChat(player, GetPlayerName(v).." is not whitelisted.")
		end
	end
end )

AddEvent("OnPlayerSteamAuth", function(player)
	local steamid = GetPlayerSteamId(player)
	print("auth: "..steamid)

	if whitelistIsEnabled == true then
		for _, v in pairs(whitelist) do
			if v == steamid then
				print("whitelisted: "..v)
				break
			end
		end
		print("kick")
		KickPlayer(player, "You are not whitelisted on this server!")
	end
end )

AddEvent("OnPackageStart", loadWhitelist)
