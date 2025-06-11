AddCSLuaFile()

HYPERCAT_SCP096.DB = HYPERCAT_SCP096.DB or {}

if SERVER then
    local function setupDatabase()
        sql.Query([[
            CREATE TABLE IF NOT EXISTS hypercat_scp096_whitelist (
                steam_id TEXT PRIMARY KEY,
                added_by TEXT,
                added_at INTEGER,
                last_used INTEGER
            )
        ]])

        sql.Query([[
            CREATE TABLE IF NOT EXISTS hypercat_scp096_stats (
                steam_id TEXT,
                total_kills INTEGER DEFAULT 0,
                total_time INTEGER DEFAULT 0,
                last_played INTEGER,
                PRIMARY KEY (steam_id)
            )
        ]])

        sql.Query([[
            CREATE TABLE IF NOT EXISTS hypercat_scp096_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                action TEXT,
                steam_id TEXT,
                admin_id TEXT,
                timestamp INTEGER,
                details TEXT
            )
        ]])
    end

    hook.Add("Initialize", "HYPERCAT_SCP096_DB_Init", setupDatabase)

    function HYPERCAT_SCP096.DB.AddToWhitelist(steamID, adminID)
        if not steamID or not adminID then return false end
        
        local success = sql.Query(string.format([[
            INSERT OR REPLACE INTO hypercat_scp096_whitelist 
            (steam_id, added_by, added_at, last_used) 
            VALUES (%s, %s, %d, 0)
        ]], sql.SQLStr(steamID), sql.SQLStr(adminID), os.time()))

        if success ~= false then
            HYPERCAT_SCP096.DB.LogAction("whitelist_add", steamID, adminID)
            return true
        end
        return false
    end

    function HYPERCAT_SCP096.DB.RemoveFromWhitelist(steamID, adminID)
        if not steamID or not adminID then return false end

        local success = sql.Query(string.format([[
            DELETE FROM hypercat_scp096_whitelist 
            WHERE steam_id = %s
        ]], sql.SQLStr(steamID)))

        if success ~= false then
            HYPERCAT_SCP096.DB.LogAction("whitelist_remove", steamID, adminID)
            return true
        end
        return false
    end

    function HYPERCAT_SCP096.DB.IsWhitelisted(steamID)
        if not steamID then return false end

        local result = sql.QueryRow(string.format([[
            SELECT 1 FROM hypercat_scp096_whitelist 
            WHERE steam_id = %s
        ]], sql.SQLStr(steamID)))

        return result ~= nil
    end

    function HYPERCAT_SCP096.DB.UpdateStats(steamID, kills, playTime)
        if not steamID then return false end

        return sql.Query(string.format([[
            INSERT OR REPLACE INTO hypercat_scp096_stats 
            (steam_id, total_kills, total_time, last_played)
            VALUES (%s, 
                COALESCE((SELECT total_kills FROM hypercat_scp096_stats WHERE steam_id = %s), 0) + %d,
                COALESCE((SELECT total_time FROM hypercat_scp096_stats WHERE steam_id = %s), 0) + %d,
                %d)
        ]], sql.SQLStr(steamID), sql.SQLStr(steamID), kills or 0, sql.SQLStr(steamID), playTime or 0, os.time()))
    end

    function HYPERCAT_SCP096.DB.GetStats(steamID)
        if not steamID then return nil end

        return sql.QueryRow(string.format([[
            SELECT * FROM hypercat_scp096_stats 
            WHERE steam_id = %s
        ]], sql.SQLStr(steamID)))
    end

    function HYPERCAT_SCP096.DB.LogAction(action, targetID, adminID, details)
        return sql.Query(string.format([[
            INSERT INTO hypercat_scp096_logs 
            (action, steam_id, admin_id, timestamp, details)
            VALUES (%s, %s, %s, %d, %s)
        ]], sql.SQLStr(action), sql.SQLStr(targetID), sql.SQLStr(adminID), os.time(), sql.SQLStr(details or "")))
    end

    local whitelistCache = {}
    local cacheTimeout = 300

    function HYPERCAT_SCP096.DB.CacheWhitelist()
        local results = sql.Query([[
            SELECT steam_id FROM hypercat_scp096_whitelist
        ]])

        whitelistCache = {}
        if results then
            for _, row in ipairs(results) do
                whitelistCache[row.steam_id] = true
            end
        end

        timer.Create("HYPERCAT_SCP096_CacheUpdate", cacheTimeout, 1, HYPERCAT_SCP096.DB.CacheWhitelist)
    end

    hook.Add("Initialize", "HYPERCAT_SCP096_CacheInit", HYPERCAT_SCP096.DB.CacheWhitelist)
end 