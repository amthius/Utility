--!strict
local InviteOptions = Instance.new("ExperienceInviteOptions")

local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Social = {}

function Social.InviteSpecific(reciever: number, message: string): boolean
	InviteOptions.InviteUser = reciever
	InviteOptions.PromptMessage = message
	
	local success: boolean, sendable: boolean = pcall(function()
		return SocialService:CanSendGameInviteAsync(LocalPlayer, reciever)
	end)
	
	if success and sendable then
		local sent: boolean = pcall(function()
			SocialService:PromptGameInvite(LocalPlayer, InviteOptions)
		end)
		
		return sent 
	else
		return false
	end
	
end

function Social.InviteAll(message: string): boolean
	InviteOptions.PromptMessage = message

	local success: boolean, sendable: boolean = pcall(function()
		return SocialService:CanSendGameInviteAsync(LocalPlayer)
	end)
	
	if success and sendable then
		local sent: boolean = pcall(function()
			SocialService:PromptGameInvite(LocalPlayer, InviteOptions)
		end)

		return sent 
	else
		return false
	end
	
end

return Social