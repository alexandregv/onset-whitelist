local whitelistIsEnabled = false
local whitelist = {}

function loadWhitelist()
	for line in io.lines("packages/"..GetPackageName().."/whitelist.txt") do
		table.insert(whitelist, tonumber(line))
	end
	print("Whitelist loaded! ("..(#whitelist).." entries)")
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
		AddPlayerChat("Whitelist:")
		for _, v in pairs(whitelist) do
			AddPlayerChat(" - "..GetPlayerName(v)) -- TODO: Handle false with disconnected players
		end
		AddPlayerChat("--------------------")
-- reload
	elseif subcmd == "reload" then
		loadWhitelist()
-- add
	elseif subcmd == "add" or subcmd == "+" then
		local target = GetPlayerByName(arg)
		if target == nil then
			AddPlayerChat(player, "Unknow player "..arg)
		else
				table.insert(whitelist, v)
				AddPlayerChat(player, GetPlayerName(v).." has been added to the whitelist.")
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
	if whithelistIsEnabled then
		local steamid = GetPlayerSteamId(player)
		for k, v in pairs(whitelist) do
			if v == steamid then
				KickPlayer(player, "You are not whitelisted on this server!")
				break
			end
		end
	end
end )

AddEvent("OnPackageStart", saveWhitelist)
AddEvent("OnPackageStart", loadWhitelist)
