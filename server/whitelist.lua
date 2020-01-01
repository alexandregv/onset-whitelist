local whitelistIsEnabled = true
local whitelist = {}

-- utils

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

function GetPlayerFromSteamId(steamid)
	for _, player in ipairs(GetAllPlayers()) do
		if GetPlayerSteamId(player) == tonumber(steamid) then
			return player
		end
	end
	return nil
end

-- whitelist functions

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

-- subcommands

function list(player, arg)
	AddPlayerChat(player, "[whitelist] ".."Whitelist:")
	for k, _ in pairs(whitelist) do
		local p = GetPlayerFromSteamId(k)
		AddPlayerChat(player, "[whitelist] ".." - "..k..(p and ' ('..GetPlayerName(p)..')' or ''))
	end
	AddPlayerChat(player, "[whitelist] ".."--------------------")
end

function reload(player)
	loadWhitelist(player)
end

function add(player, arg, ...)
	if #{...} > 0 then
		arg = arg.." "..table.concat({...}, " ")
	end

	if arg == nil then
		AddPlayerChat(player, "[whitelist] ".."Usage: /whitelist add <name|steamid>")
		return
	end

	local target = nil
	if arg:match("^%d+$") ~= nil then
		AddPlayerChat(player, "ID "..arg)
		target = GetPlayerFromSteamId(arg)
	else
		target = GetPlayerFromPartialName(arg)
	end

	if target == nil then
		AddPlayerChat(player, "[whitelist] ".."Can't find player: "..arg)
	else
			local steamid = GetPlayerSteamId(target)
			whitelist[steamid] = 1
			AddPlayerChat(player, "[whitelist] "..steamid.." ("..GetPlayerName(target)..") has been added to the whitelist")
			saveWhitelist()
	end
end

function remove(player, arg, ...)
	if #{...} > 0 then
		arg = arg.." "..table.concat({...}, " ")
	end

	if arg == nil then
		AddPlayerChat(player, "[whitelist] ".."Usage: /whitelist remove <name|steamid>")
		return
	end

	local target = nil
	if arg:match("^%d+$") ~= nil then
		AddPlayerChat(player, "ID "..arg)
		target = GetPlayerFromSteamId(arg)
	else
		target = GetPlayerFromPartialName(arg)
	end

	if target == nil then
		AddPlayerChat(player, "[whitelist] ".."Can't find player: "..arg)
	else
			local steamid = GetPlayerSteamId(target)
			whitelist[steamid] = nil
			AddPlayerChat(player, "[whitelist] "..steamid.." ("..GetPlayerName(target)..") has been removed from the whitelist")
			saveWhitelist()
	end
end

function check(player, arg, ...)
	if #{...} > 0 then
		arg = arg.." "..table.concat({...}, " ")
	end

	if arg == nil then
		AddPlayerChat(player, "[whitelist] ".."Usage: /whitelist check <name|steamid>")
		return
	end

	local target = nil
	if arg:match("^%d+$") ~= nil then
		AddPlayerChat(player, "ID "..arg)
		target = GetPlayerFromSteamId(arg)
	else
		target = GetPlayerFromPartialName(arg)
	end
	if target == nil then
		AddPlayerChat(player, "[whitelist] ".."Can't find player: "..arg)
	else
			AddPlayerChat(player, "[whitelist] "..GetPlayerSteamId(target).." ("..GetPlayerName(target)..") is "..(whitelist[GetPlayerSteamId(target)] == 1 and '' or 'NOT ').."whitelisted")
	end
end

-- main command

local cmds = {
	["help"] = help,
	["h"] = help,

	["list"] = list,
	["l"] = list,

	["add"] = add,
	["+"] = add,

	["remove"] = remove,
	["-"] = remove,

	["check"] = check,
	["c"] = check,

	["reload"] = reload,
	["r"] = reload,
}

function main_command(player, cmd, arg, ...)
	local cmdfunc = cmds[cmd]
	if cmd == nil then
		cmds["help"](player)
	elseif cmdfunc then
		cmdfunc(player, arg, ...)
	else
		cmds["help"](player)
	end
end

AddCommand("whitelist", main_command)
AddCommand("wl", main_command)

-- events

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
