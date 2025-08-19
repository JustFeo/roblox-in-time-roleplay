--!strict

-- Simple per-player sliding window rate limiter.

local RateLimiter = {}
RateLimiter.__index = RateLimiter

export type RateLimiter = {
	limit: number,
	windowSeconds: number,
	playerToHits: {[Player]: {timestamps: {number}}},
	allow: (self: RateLimiter, player: Player, cost: number?) -> boolean,
}

function RateLimiter.new(limit: number, windowSeconds: number): RateLimiter
	local self = setmetatable({}, RateLimiter)
	self.limit = math.max(1, limit)
	self.windowSeconds = math.max(1, windowSeconds)
	self.playerToHits = {}
	return self
end

function RateLimiter:allow(player: Player, cost: number?): boolean
	cost = cost or 1
	local now = os.clock()
	local bucket = self.playerToHits[player]
	if not bucket then
		bucket = {timestamps = {}}
		self.playerToHits[player] = bucket
	end
	-- drop old
	local keep: {number} = {}
	for _, ts in ipairs(bucket.timestamps) do
		if now - ts < self.windowSeconds then
			table.insert(keep, ts)
		end
	end
	bucket.timestamps = keep
	if #bucket.timestamps + cost > self.limit then
		return false
	end
	for _ = 1, cost do
		table.insert(bucket.timestamps, now)
	end
	return true
end

return RateLimiter


