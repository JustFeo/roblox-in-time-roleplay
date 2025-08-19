--!strict

export type PlayerTimeProfile = {
	UserId: number,
	DisplayName: string,
	-- remaining time in seconds
	TimeSeconds: number,
	-- ISO timestamp string of last daily reward claim
	LastDailyClaimISO: string?,
}

export type Mission = {
	Id: string,
	Name: string,
	Description: string,
	RewardSeconds: number,
	CooldownSeconds: number?,
}

return {}


