--!strict

export type PlayerTimeProfile = {
	UserId: number,
	DisplayName: string,
	-- remaining time in seconds
	TimeSeconds: number,
	-- time stored in bank (safe)
	BankedSeconds: number?,
	-- ISO timestamp string of last daily reward claim
	LastDailyClaimISO: string?,
	-- wanted end timestamp (os.clock-based seconds), nil if not wanted
	WantedEndClock: number?,
}

export type Mission = {
	Id: string,
	Name: string,
	Description: string,
	RewardSeconds: number,
	CooldownSeconds: number?,
}

return {}


