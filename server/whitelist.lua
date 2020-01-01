local whitelistIsEnabled = true
local whitelist = {}

function getWhitelistLength()
	local length = 0
	for _, __ in pairs(whitelist) do
		length = length + 1
	end
	return length
end

function loadWhitelist(player)
	whitelist = {}
	for line in io.lines("packages/"..GetPackageName().."/whitelist.txt") do
		whitelist[tonumber(line)] = 1
	end
	if player == nil then
		print("[whitelist] ".."Whitelist loaded ("..(getWhitelistLength()).." entries)")
	else
		AddPlayerChat(player, "Whitelist loaded ("..(getWhitelistLength()).." entries)")
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
	print("[whitelist] ".."Whitelist saved! ("..(getWhitelistLength()).." entries)")
end

function GetPlayerFromPartialName(name)
	local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
	if name then
		for _, player in ipairs(GetAllPlayers()) do
			local playerName = GetPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
			if playerName:find(name, 1, true) then
				return player
			end
		end
	end
end

AddCommand("whitelist", function(player, subcmd, arg, ...)
-- list
	if subcmd == nil or subcmd == "list" then
		AddPlayerChat(player, "[whitelist] ".."Whitelist:")
		for k, _ in pairs(whitelist) do
			local connected = false
			for _, vv in pairs(GetAllPlayers()) do
					if GetPlayerSteamId(vv) == k then
						AddPlayerChat(player, "[whitelist] ".." - "..k.." ("..GetPlayerName(vv)..")")
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
		if #{...} > 0 then
			arg = arg.." "..table.concat({...}, " ")
		end

		if arg == nil then
			AddPlayerChat(player, "[whitelist] ".."Usage: /whitelist add <name|steamid>")
			return
		end

		local target = GetPlayerFromPartialName(arg)
		if target == nil then
			AddPlayerChat(player, "[whitelist] ".."Can't find player: "..arg)
		else
				local steamid = GetPlayerSteamId(target)
				whitelist[steamid] = 1
				AddPlayerChat(player, "[whitelist] "..steamid.." ("..GetPlayerName(target)..") has been added to the whitelist")
				saveWhitelist()
		end
-- remove
	elseif subcmd == "remove" or subcmd == "-" then
		if #{...} > 0 then
			arg = arg.." "..table.concat({...}, " ")
		end

		if arg == nil then
			AddPlayerChat(player, "[whitelist] ".."Usage: /whitelist remove <name|steamid>")
			return
		end

		local target = GetPlayerFromPartialName(arg)
		if target == nil then
			AddPlayerChat(player, "[whitelist] ".."Can't find player: "..arg)
		else
				local steamid = GetPlayerSteamId(target)
				whitelist[steamid] = nil
				AddPlayerChat(player, "[whitelist] "..steamid.." ("..GetPlayerName(target)..") has been removed from the whitelist")
				saveWhitelist()
		end
-- check
	elseif subcmd == "check" then
		if #{...} > 0 then
			arg = arg.." "..table.concat({...}, " ")
		end

		if arg == nil then
			AddPlayerChat(player, "[whitelist] ".."Usage: /whitelist check <name|steamid>")
			return
		end

		local target = GetPlayerByName(arg)
		if target == nil then
			AddPlayerChat(player, "[whitelist] ".."Can't find player: "..arg)
		else
				AddPlayerChat(player, "[whitelist] "..steamid.." ("..GetPlayerName(target)..") is "..(whitelist[GetPlayerSteamId(target)] == 1 and '' or 'NOT ').."whitelisted")
		end
	end
end )

AddEvent("OnPlayerSteamAuth", function(player)
	local steamid = GetPlayerSteamId(player)
	if whitelistIsEnabled == true then
		for k, v in pairs(whitelist) do
			if k == steamid then
				return
			end
		end
		print("[whitelist] "..GetPlayerName(player).." (SteamID "..steamid..") tried to connect but is not whitelisted, kicking ("..GetPlayerIP(player)..")")
		KickPlayer(player, "You are not whitelisted on this server!")
	end
end )

AddEvent("OnPackageStart", loadWhitelist)
