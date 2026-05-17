std = "lua51"

read_globals = {
    -- ComputerCraft Globals
    "fs", "peripheral", "rednet", "term", "colors", "keys", "os", "rs", "textutils", 
    "write", "read", "shell", "http", "sleep", "print", "printError", "multishell",
    "redstone", "window", "parallel",
    
    -- Standard Lua Globals
    "pcall", "setmetatable", "error", "pairs", "ipairs", "tostring", "tonumber", 
    "require", "math", "table", "string", "bit32", "_G", "_ENV", "type", "assert"
}

ignore = {
    "212/self", -- Ignore unused argument 'self' (common in OOP)
    "611",      -- Ignore lines containing only whitespace
    "612",      -- Ignore lines containing trailing whitespace
    "631"       -- Ignore lines that are too long
}

exclude_files = {
    ".agents/**/*.lua",
    ".github/**/*.lua",
    ".luarocks/**/*.lua"
}
