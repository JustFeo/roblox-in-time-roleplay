In Time: Roleplay (Roblox)

Overview
- A roleplay experience inspired by the concept of the film "In Time": time is the currency. Earn time via missions, hustles, and jobs; spend time on housing, items, vehicles, areas, cosmetics, and boosts. If your time hits zero you collapse; for now, you can respawn with a small starter time.

Tech Stack
- Roblox Studio + Luau
- Rojo-style source layout for clean development workflow

Core Features (MVP)
- Time Currency: server-authoritative countdown and accrual system
- Jobs & Missions: repeatable, daily, and story missions grant time
- Shops: purchase items, perks, and access using time
- Daily Rewards & Promo Codes: retention and growth features
- UI: futuristic HUD with remaining time, mission tracker, and shop
- Anti-exploit: remotes validate on server; sanity checks for time transactions

Getting Started
1. Open Roblox Studio and create a new place.
2. Copy files from `src/` into the appropriate services (ServerScriptService, ReplicatedStorage, StarterPlayer, etc.), or use Rojo if you prefer.
3. Press Play; you should see a minimal city block, your time HUD, daily reward, a courier job, and a small shop.

Notes
- This repository is set up with plain Luau and a Rojo-like structure. You can adopt Rojo/Wally later for packages if desired.
- All time operations are validated on the server. Clients only request.

License
MIT


