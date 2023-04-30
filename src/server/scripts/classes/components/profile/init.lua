local players = game:GetService("Players")

local profileService = require(script.profileService)

local config = {
	id = {
		prefix = "player",
		suffix = "",
		seperator = "_"
	}
}

local profile = {}
profile.interface = {
	active = {},
	config = config
}
profile.schema = {}
profile.metatable = {__index = profile.schema}

local function createIdForPlayer(player: Player)
	local idSettings = profile.interface.config.id
	local seperator = idSettings.seperator
	return idSettings.prefix..seperator..player.UserId..seperator..idSettings.suffix
end

local function load(self: profile)
	local _profile = self._profile
	local player = self.player
	local activeProfiles = profile.interface.active
	if _profile ~= nil then
		_profile:AddUserId(player.UserId) -- GDPR compliance
		_profile:Reconcile() -- Fill in missing variables from ProfileTemplate (optional)
		_profile:ListenToRelease(function()
			activeProfiles[player]:destroy()
			-- The profile could've been loaded on another Roblox server:
			player:Kick()
		end)
		if player:IsDescendantOf(players) == true then
			return true
			-- A profile has been successfully loaded:
		else
			-- Player left before the profile loaded:
			_profile:Release()
		end
	else
		-- The profile couldn't be loaded possibly due to other
		--   Roblox servers trying to load this profile at the same time:
		player:Kick() 
	end
	return false
end

function profile.interface.new(player: Player)
	local self = setmetatable({}, profile.metatable)
	self.player = player
	self.id = createIdForPlayer(player)
	self._profile = profile.interface.store:LoadProfileAsync(self.id)
	self.data = self._profile.Data
	if load(self) then
		profile.interface.active[player] = profile
	else
		warn("Failed to load profile for user `"..player.UserId.."` AKA `"..player.Name.."`")
		self:destroy()
	end
	return self
end

function profile.schema.destroy(self: profile)
	local activeProfiles = profile.interface.active
	if activeProfiles[self.player] then
		activeProfiles[self.player] = nil
	end
end

type profile = typeof(profile.interface.new(...))
type profileStore = typeof(profileService.GetProfileStore())

return function(store: string, template)
	local interface = profile.interface
	interface.store = profileService.GetProfileStore(
		store,
		template
	)
	return profile.interface
end