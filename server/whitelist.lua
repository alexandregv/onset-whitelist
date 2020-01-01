local whitelistIsEnabled = true
local whitelist = {}

function loadWhitelist(player)
	whitelist = {}
	for line in io.lines("packages/"..GetPackageName().."/whitelist.txt") do
		table.insert(whitelist, tonumber(line))
	end
	if player == nil then
		print("[whitelist] ".."Whitelist loaded ("..(#whitelist).." entries)")
	else
		AddPlayerChat(player, "Whitelist loaded ("..(#whitelist).." entries)")
	end
end

function saveWhitelist()
	local file = io.open("packages/"..GetPackageName().."/whitelist.txt", "w+")
	file:write("")
	file:close()

	file = io.open("packages/"..GetPackageName().."/whitelist.txt", "a+")
	for k, _ in pairs(whitelist) do
		file:write(k, "\n")
	end
	file:close()
	print("[whitelist] ".."Whitelist saved! ("..(#whitelist).." entries)")
end

function GetPlayerByName(name)
		for _, v in pairs(GetAllPlayers()) do
			if string.lower(GetPlayerName(v)) == string.lower(name) then
				return v
			end
		end
		return nil
end

AddCommand("whitelist", function(player, subcmd, arg)
-- list
	if subcmd == nil or subcmd == "list" then
		AddPlayerChat(player, "[whitelist] ".."Whitelist:")
		for _, v in pairs(whitelist) do
			local connected = false
			for _, vv in pairs(GetAllPlayers()) do
					if GetPlayerSteamId(vv) == v then
						AddPlayerChat(player, "[whitelist] ".." - "..v.." ("..GetPlayerName(vv)..")")
						connected = true
						break
					end
			end
			if connected == false then
				AddPlayerChat(player, "[whitelist] ".." - "..v)
			end
		end
		AddPlayerChat(player, "[whitelist] ".."--------------------")
-- reload
	elseif subcmd == "reload" then
		loadWhitelist(player)
-- add
	elseif subcmd == "add" or subcmd == "+" then
		if arg == nil then
			AddPlayerChat(player, "[whitelist] ".."Usage: /whitelist add <name>")
			return
		end

		local target = GetPlayerByName(arg)
		if target == nil then
			AddPlayerChat(player, "[whitelist] ".."Can't find player: "..arg)
		else
				local steamid = GetPlayerSteamId(target)
				table.insert(whitelist, steamid)
				AddPlayerChat(player, "[whitelist] "..steamid.." ("..GetPlayerName(target)..") has been added to the whitelist")
				saveWhitelist()
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
	if whitelistIsEnabled == true then
		for _, v in pairs(whitelist) do
			if v == steamid then
				return
			end
		end
		print("[whitelist] "..GetPlayerName(player).." (SteamID "..steamid..") tried to connect but is not whitelisted, kicking ("..GetPlayerIP(player)..")")
		KickPlayer(player, "You are not whitelisted on this server!")
	end
end )

AddEvent("OnPackageStart", loadWhitelist)
