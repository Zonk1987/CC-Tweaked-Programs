--[[
    Spezifikation v2: Premium Boot-Assistent & Diagnose-System
    Governed by AGENTS.md
--]]

local BootAssistant = {}
BootAssistant.__index = BootAssistant

-- Theme-Paletten Definitionen
local PALETTES = {
    light = {
        [colors.white]     = 0xF5F6FA, -- Hintergrund (Canvas)
        [colors.black]     = 0x1E1E24, -- Haupttext
        [colors.gray]      = 0x7F8C8D, -- Rahmen & Skala
        [colors.blue]      = 0x3B5998, -- Header-Balken
        [colors.green]     = 0x2ECC71, -- Ladebalken / OK
        [colors.red]       = 0xE74C3C, -- Fehler / FAIL
        [colors.yellow]    = 0xF1C40F, -- Warnungen / WARN
        [colors.lightGray] = 0xE9EBF0, -- Popup-Hintergrund
    },
    dark = {
        [colors.white]     = 0x121214, -- Hintergrund (Canvas)
        [colors.black]     = 0xF5F6FA, -- Haupttext
        [colors.gray]      = 0x4A4D5A, -- Rahmen & Skala
        [colors.blue]      = 0x1F3A60, -- Header-Balken
        [colors.green]     = 0x00E676, -- Ladebalken / OK
        [colors.red]       = 0xFF5252, -- Fehler / FAIL
        [colors.yellow]    = 0xFFD740, -- Warnungen / WARN
        [colors.lightGray] = 0x1E1E24, -- Popup-Hintergrund
    }
}

-- Hilfsfunktion: Text zentrieren
local function drawCenteredText(win, y, text, textColor, bgColor)
    local w, _ = win.getSize()
    local x = math.max(1, math.floor((w - #text) / 2) + 1)
    win.setCursorPos(x, y)
    win.setTextColor(textColor)
    win.setBackgroundColor(bgColor)
    win.write(text)
end

-- Konstruktor
function BootAssistant.new(options)
    local self = setmetatable({}, BootAssistant)
    self.config = options or {}
    self.config.title = self.config.title or "Boot Assistent"
    self.config.theme = self.config.theme or "dark"
    self.config.enable_logging = self.config.enable_logging == true
    self.config.log_file = self.config.log_file or "logs/boot.log"

    self.steps = {}
    self.state = "STATE_NORMAL" -- "STATE_NORMAL", "STATE_POPUP", "STATE_DIAGNOSTICS"
    self.logBuffer = {}
    self.logOffset = 0
    self.helpOffset = 0
    self.activeFailure = nil

    -- Diagnose-State Variablen
    self.diagPeripherals = {}
    self.selectedPeripheralIdx = 1
    self.peripheralOffset = 0
    self.methodOffset = 0

    -- Erstellung eines flackerfreien Windows
    local w, h = term.getSize()
    self.win = window.create(term.current(), 1, 1, w, h, true)

    -- Backup der alten Palette
    self.oldPalette = {}
    for _, color in pairs(colors) do
        if type(color) == "number" then
            local r, g, b = term.getPaletteColor(color)
            self.oldPalette[color] = { r, g, b }
        end
    end

    -- Theme anwenden
    self:applyPalette()

    self:log("INFO", "Boot-Assistent gestartet...")
    return self
end

-- Palette live setzen
function BootAssistant:applyPalette()
    local palette = PALETTES[self.config.theme] or PALETTES.dark
    for color, hex in pairs(palette) do
        term.setPaletteColor(color, hex)
    end
end

-- Palette restaurieren
function BootAssistant:restorePalette()
    for color, rgb in pairs(self.oldPalette) do
        term.setPaletteColor(color, rgb[1], rgb[2], rgb[3])
    end
end

-- Loggen (in Memory und optional auf Disk)
function BootAssistant:log(lvl, msg, stepId)
    local entry = {
        time = os.date("%H:%M:%S"),
        level = lvl,
        text = msg,
        stepId = stepId
    }
    table.insert(self.logBuffer, entry)

    -- Optional in Datei schreiben
    if self.config.enable_logging then
        local ok, err = pcall(function()
            local dir = fs.getDir(self.config.log_file)
            if dir and dir ~= "" and not fs.exists(dir) then
                fs.makeDir(dir)
            end
            local file = fs.open(self.config.log_file, "a")
            if file then
                file.writeLine(string.format("[%s] [%s] %s", entry.time, entry.level, entry.text))
                file.close()
            end
        end)
        if not ok then
            -- Fallback: Geräuschlos ignorieren um Abstürze zu verhindern
        end
    end

    -- Auto-Scroll zum Ende bei neuen Einträgen
    local _, h = self.win.getSize()
    local maxVisibleLogs = h - 11
    if #self.logBuffer > maxVisibleLogs then
        self.logOffset = #self.logBuffer - maxVisibleLogs
    end
end

-- Fügt eine Hardware- oder Software-Prüfung hinzu
function BootAssistant:addStep(id, title, checkFunc, advice)
    table.insert(self.steps, {
        id = id,
        title = title,
        check = checkFunc,
        advice = advice or { "Keine spezifische Hilfe verfuegbar." },
        status = "PENDING"
    })
end

-- Prüft, ob alle Schritte erfolgreich abgeschlossen wurden
function BootAssistant:isBootComplete()
    for _, step in ipairs(self.steps) do
        if step.status ~= "OK" and step.status ~= "WARN" then
            return false
        end
    end
    return true
end

-- Führt die Diagnose-Checks der Reihe nach aus
function BootAssistant:runChecks()
    local anyFailed = false

    for _, step in ipairs(self.steps) do
        if anyFailed then
            step.status = "PENDING"
        else
            if step.status == "PENDING" or step.status == "FAIL" or step.status == "WARN" then
                local ok, res, detail = pcall(step.check)
                if not ok then
                    step.status = "FAIL"
                    self:log("FAIL", "Fehler in Check '" .. step.title .. "': " .. tostring(res), step.id)
                    anyFailed = true
                elseif res == true then
                    if step.status ~= "OK" then
                        step.status = "OK"
                        self:log("OK", step.title .. " geladen.", step.id)
                    end
                elseif res == "WARN" or detail == "WARN" then
                    if step.status ~= "WARN" then
                        step.status = "WARN"
                        self:log("WARN", step.title .. ": " .. tostring(detail or "Warnung"), step.id)
                    end
                else
                    step.status = "FAIL"
                    self:log("FAIL", step.title .. " fehlgeschlagen: " .. tostring(detail or "Nicht gefunden"), step.id)
                    anyFailed = true
                end
            end
        end
    end
end

-- Scannt Peripheriegeräte für das Diagnose-Untermenü
function BootAssistant:scanPeripherals()
    self.diagPeripherals = {}
    local list = peripheral.getNames()
    for _, name in ipairs(list) do
        local pType = peripheral.getType(name)
        local pMethods = peripheral.getMethods(name) or {}
        table.insert(self.diagPeripherals, {
            name = name,
            type = pType,
            methods = pMethods
        })
    end
end

-- Hauptschleife
function BootAssistant:run()
    self:runChecks()

    while true do
        self:draw()

        if self:isBootComplete() and self.state == "STATE_NORMAL" then
            break
        end

        local eventData = { os.pullEvent() }
        self:handleEvent(eventData)

        local eventType = eventData[1]
        if eventType == "peripheral" or eventType == "peripheral_detach" or eventType == "redstone" then
            self:runChecks()
            if self.state == "STATE_DIAGNOSTICS" then
                self:scanPeripherals()
            end
        end
    end

    -- Aufräumen
    self:restorePalette()
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1, 1)
end

-- Event-Handling
function BootAssistant:handleEvent(eventData)
    local eventType = eventData[1]

    if eventType == "mouse_click" then
        local button, x, y = eventData[2], eventData[3], eventData[4]
        if button == 1 then
            self:handleClick(x, y)
        end
    elseif eventType == "mouse_scroll" then
        local direction = eventData[2]
        self:handleScroll(direction)
    end
end

-- Scroll-Handling
function BootAssistant:handleScroll(dir)
    local _, h = self.win.getSize()
    if self.state == "STATE_NORMAL" then
        local maxVisibleLogs = h - 11
        if #self.logBuffer > maxVisibleLogs then
            self.logOffset = math.max(0, math.min(self.logOffset + dir, #self.logBuffer - maxVisibleLogs))
        end
    elseif self.state == "STATE_POPUP" and self.activeFailure then
        local maxVisibleAdvice = 7
        local adviceCount = #self.activeFailure.advice
        if adviceCount > maxVisibleAdvice then
            self.helpOffset = math.max(0, math.min(self.helpOffset + dir, adviceCount - maxVisibleAdvice))
        end
    elseif self.state == "STATE_DIAGNOSTICS" then
        -- Scrollen im Diagnose-Menü
        local maxPeripherals = h - 7
        if #self.diagPeripherals > maxPeripherals then
            self.peripheralOffset = math.max(0, math.min(self.peripheralOffset + dir, #self.diagPeripherals - maxPeripherals))
        end
    end
end

-- Klick-Handling
function BootAssistant:handleClick(x, y)
    local w, h = self.win.getSize()

    if self.state == "STATE_NORMAL" then
        -- Klick auf System-Info Button im Footer (Zeile h)
        if y == h and x >= 2 and x <= 17 then
            self:scanPeripherals()
            self.selectedPeripheralIdx = 1
            self.peripheralOffset = 0
            self.methodOffset = 0
            self.state = "STATE_DIAGNOSTICS"
            return
        end

        -- Klick auf Log-Zeilen (Zeilen 10 bis h - 2)
        local logStartRow = 10
        local logEndRow = h - 2
        if y >= logStartRow and y <= logEndRow then
            local idx = y - logStartRow + 1 + self.logOffset
            local entry = self.logBuffer[idx]
            if entry and entry.level == "FAIL" then
                -- Finde zugehörigen Schritt
                for _, step in ipairs(self.steps) do
                    if step.id == entry.stepId then
                        self.activeFailure = step
                        self.helpOffset = 0
                        self.state = "STATE_POPUP"
                        break
                    end
                end
            end
        end

    elseif self.state == "STATE_POPUP" then
        -- Klick auf Close Button [ X ]
        -- Modal Größe: Breite 40, Höhe 11
        local modalW, modalH = 40, 11
        local startX = math.floor((w - modalW) / 2) + 1
        local startY = math.floor((h - modalH) / 2) + 1

        local closeX = startX + modalW - 4
        local closeY = startY + 1

        if x >= closeX and x <= closeX + 2 and y == closeY then
            self.state = "STATE_NORMAL"
            self.activeFailure = nil
        end

    elseif self.state == "STATE_DIAGNOSTICS" then
        -- Klick auf [ Zurueck ] Button im Footer
        if y == h and x >= 2 and x <= 13 then
            self.state = "STATE_NORMAL"
            return
        end

        -- Klick auf Peripherie-Liste (Spalten 3 bis 22, Zeilen 5 bis h - 3)
        if x >= 3 and x <= 22 and y >= 5 and y <= (h - 3) then
            local idx = y - 5 + 1 + self.peripheralOffset
            if idx >= 1 and idx <= #self.diagPeripherals then
                self.selectedPeripheralIdx = idx
                self.methodOffset = 0
            end
        end
    end
end

-- Zeichnen-Manager
function BootAssistant:draw()
    self.win.setVisible(false)
    self.win.setBackgroundColor(colors.white)
    self.win.clear()

    -- 1. Header (Immer sichtbar)
    self:drawHeader()

    if self.state == "STATE_NORMAL" or self.state == "STATE_POPUP" then
        -- 2. Progress-Bar & Skala
        self:drawProgressBar()

        -- 3. Log-Box
        self:drawLogBox()

        -- 4. Footer
        self:drawFooterNormal()

        -- 5. Popup Overlay falls aktiv
        if self.state == "STATE_POPUP" then
            self:drawPopup()
        end
    elseif self.state == "STATE_DIAGNOSTICS" then
        -- Diagnose Untermenü
        self:drawDiagnostics()
    end

    self.win.setVisible(true)
end

-- Zeichnet den Standard-Header
function BootAssistant:drawHeader()
    local w, _ = self.win.getSize()
    self.win.setBackgroundColor(colors.blue)
    self.win.setTextColor(colors.white)

    -- Zeile 1
    self.win.setCursorPos(1, 1)
    self.win.write(string.rep(" ", w))
    -- Zeile 2
    self.win.setCursorPos(1, 2)
    self.win.write(string.rep(" ", w))
    drawCenteredText(self.win, 2, self.config.title, colors.white, colors.blue)
    -- Zeile 3
    self.win.setCursorPos(1, 3)
    self.win.write(string.rep(" ", w))
end

-- Zeichnet die Progress-Bar
function BootAssistant:drawProgressBar()
    local w, _ = self.win.getSize()
    local barWidth = w - 16 -- Flexibel basierend auf Breite
    local total = #self.steps
    local okCount = 0

    for _, step in ipairs(self.steps) do
        if step.status == "OK" or step.status == "WARN" then
            okCount = okCount + 1
        end
    end

    local progress = total > 0 and (okCount / total) or 0
    local filledWidth = math.floor(progress * barWidth)

    -- Ladebalken Zeichnen (Zeile 5)
    self.win.setCursorPos(3, 5)
    self.win.setBackgroundColor(colors.white)
    self.win.setTextColor(colors.gray)
    self.win.write("[")

    self.win.setBackgroundColor(colors.green)
    self.win.write(string.rep(" ", filledWidth))

    self.win.setBackgroundColor(colors.white)
    self.win.setTextColor(colors.gray)
    self.win.write(string.rep("-", barWidth - filledWidth))
    self.win.write("]")

    -- Prozentanzeige
    self.win.setTextColor(colors.black)
    self.win.write(string.format(" %3d%%", math.floor(progress * 100)))

    -- Skala-Beschriftung (Zeile 6)
    self.win.setTextColor(colors.gray)
    self.win.setCursorPos(3, 6)
    self.win.write("0%")
    
    local x25 = math.floor(barWidth * 0.25) + 3
    self.win.setCursorPos(x25, 6)
    self.win.write("25%")

    local x50 = math.floor(barWidth * 0.50) + 3
    self.win.setCursorPos(x50, 6)
    self.win.write("50%")

    local x75 = math.floor(barWidth * 0.75) + 3
    self.win.setCursorPos(x75, 6)
    self.win.write("75%")

    self.win.setCursorPos(barWidth + 2, 6)
    self.win.write("100%")
end

-- Zeichnet die Log-Box
function BootAssistant:drawLogBox()
    local w, h = self.win.getSize()
    local boxTop = 9
    local boxBottom = h - 2
    local boxLeft = 3
    local boxRight = w - 2

    self.win.setTextColor(colors.black)
    self.win.setBackgroundColor(colors.white)
    self.win.setCursorPos(boxLeft, boxTop - 1)
    self.win.write("Boot-Log:")

    -- Log-Rahmen oben & unten
    self.win.setTextColor(colors.gray)
    self.win.setCursorPos(boxLeft, boxTop)
    self.win.write("+" .. string.rep("-", boxRight - boxLeft - 1) .. "+")
    self.win.setCursorPos(boxLeft, boxBottom)
    self.win.write("+" .. string.rep("-", boxRight - boxLeft - 1) .. "+")

    -- Log-Seitenränder
    for y = boxTop + 1, boxBottom - 1 do
        self.win.setCursorPos(boxLeft, y)
        self.win.write("|")
        self.win.setCursorPos(boxRight, y)
        self.win.write("|")
    end

    -- Zeilen-Rendering
    local maxVisibleLogs = boxBottom - boxTop - 1
    for i = 1, maxVisibleLogs do
        local logIdx = i + self.logOffset
        local entry = self.logBuffer[logIdx]
        if entry then
            local y = boxTop + i
            self.win.setCursorPos(boxLeft + 2, y)

            -- Level-Tag zeichnen
            if entry.level == "OK" then
                self.win.setTextColor(colors.green)
                self.win.write("[  OK  ] ")
            elseif entry.level == "WARN" then
                self.win.setTextColor(colors.yellow)
                self.win.write("[ WARN ] ")
            elseif entry.level == "FAIL" then
                self.win.setTextColor(colors.red)
                self.win.write("[ FAIL ] ")
            else
                self.win.setTextColor(colors.gray)
                self.win.write("[ INFO ] ")
            end

            -- Text zeichnen
            self.win.setTextColor(colors.black)
            local availWidth = boxRight - boxLeft - 13
            local txt = entry.text
            if #txt > availWidth then
                txt = string.sub(txt, 1, availWidth - 3) .. "..."
            end
            self.win.write(txt)
        end
    end
end

-- Standard-Footer (STATE_NORMAL)
function BootAssistant:drawFooterNormal()
    local _, h = self.win.getSize()
    self.win.setCursorPos(2, h)
    self.win.setBackgroundColor(colors.lightGray)
    self.win.setTextColor(colors.black)
    self.win.write(" [ System-Info ] ")
    self.win.setBackgroundColor(colors.white)
end

-- Zeichnet das Modal-Popup (STATE_POPUP)
function BootAssistant:drawPopup()
    local w, h = self.win.getSize()
    local step = self.activeFailure
    if not step then return end

    local modalW, modalH = 42, 12
    local startX = math.floor((w - modalW) / 2) + 1
    local startY = math.floor((h - modalH) / 2) + 1

    -- Hintergrund schattieren/zeichnen
    self.win.setBackgroundColor(colors.lightGray)
    for y = startY, startY + modalH - 1 do
        self.win.setCursorPos(startX, y)
        self.win.write(string.rep(" ", modalW))
    end

    -- Rahmen
    self.win.setTextColor(colors.gray)
    self.win.setCursorPos(startX, startY)
    self.win.write("+" .. string.rep("-", modalW - 2) .. "+")
    self.win.setCursorPos(startX, startY + modalH - 1)
    self.win.write("+" .. string.rep("-", modalW - 2) .. "+")
    for y = startY + 1, startY + modalH - 2 do
        self.win.setCursorPos(startX, y)
        self.win.write("|")
        self.win.setCursorPos(startX + modalW - 1, y)
        self.win.write("|")
    end

    -- Header & Close-Button
    self.win.setCursorPos(startX + 2, startY + 1)
    self.win.setTextColor(colors.red)
    self.win.write("HILFE & EMPFEHLUNG")
    self.win.setCursorPos(startX + modalW - 5, startY + 1)
    self.win.setBackgroundColor(colors.red)
    self.win.setTextColor(colors.white)
    self.win.write("[X]")
    self.win.setBackgroundColor(colors.lightGray)

    -- Advice Text rendern
    local maxVisibleAdvice = 7
    self.win.setTextColor(colors.black)
    for i = 1, maxVisibleAdvice do
        local lineIdx = i + self.helpOffset
        local line = step.advice[lineIdx]
        if line then
            local y = startY + 2 + i
            self.win.setCursorPos(startX + 2, y)
            local cleanLine = string.sub(line, 1, modalW - 4)
            self.win.write(cleanLine)
        end
    end
end

-- Zeichnet das Diagnose & Peripherie-Untermenü (STATE_DIAGNOSTICS)
function BootAssistant:drawDiagnostics()
    local w, h = self.win.getSize()
    local splitCol = 24
    local bottomRow = h - 2

    -- 1. Splitter-Linie
    self.win.setTextColor(colors.gray)
    for y = 5, bottomRow do
        self.win.setCursorPos(splitCol, y)
        self.win.write("|")
    end

    -- 2. Linke Spalte: Peripheriegeräte & System-Monitor
    self.win.setTextColor(colors.black)
    self.win.setCursorPos(3, 4)
    self.win.write("System-Komponenten:")

    local maxVisiblePeripherals = bottomRow - 5 + 1
    for i = 1, maxVisiblePeripherals do
        local pIdx = i + self.peripheralOffset
        local p = self.diagPeripherals[pIdx]
        if p then
            local y = 4 + i
            self.win.setCursorPos(3, y)
            if pIdx == self.selectedPeripheralIdx then
                self.win.setBackgroundColor(colors.blue)
                self.win.setTextColor(colors.white)
            else
                self.win.setBackgroundColor(colors.white)
                self.win.setTextColor(colors.black)
            end
            
            -- Kürzen falls nötig
            local displayName = p.name .. " (" .. p.type .. ")"
            if #displayName > (splitCol - 5) then
                displayName = string.sub(displayName, 1, splitCol - 8) .. "..."
            end
            self.win.write(displayName)
        end
    end
    self.win.setBackgroundColor(colors.white)

    -- 3. Rechte Spalte: Methoden-Verzeichnis & System-Monitor Info
    self.win.setTextColor(colors.black)
    local selectedP = self.diagPeripherals[self.selectedPeripheralIdx]
    if selectedP then
        self.win.setCursorPos(splitCol + 2, 4)
        self.win.write("Methoden fuer " .. selectedP.name .. ":")

        -- Scrollbare Methodenliste
        for i = 1, maxVisiblePeripherals do
            local mIdx = i + self.methodOffset
            local method = selectedP.methods[mIdx]
            if method then
                local y = 4 + i
                self.win.setCursorPos(splitCol + 2, y)
                self.win.write(" - " .. method .. "()")
            end
        end
    else
        -- Falls keine Peripheriegeräte, System-Monitor Info rechts rendern
        self.win.setCursorPos(splitCol + 2, 4)
        self.win.write("System-Spezifikationen:")

        local ramKb = math.floor(collectgarbage("count"))
        local freeSpace = fs.getFreeSpace("/")
        local compId = os.computerID()
        local compLabel = os.computerLabel() or "Kein Name"

        self.win.setCursorPos(splitCol + 2, 6)
        self.win.write("ID: " .. compId)
        self.win.setCursorPos(splitCol + 2, 7)
        self.win.write("Label: " .. compLabel)
        self.win.setCursorPos(splitCol + 2, 9)
        self.win.write("RAM Auslastung:")
        self.win.setCursorPos(splitCol + 2, 10)
        self.win.write(" -> " .. ramKb .. " KB")
        self.win.setCursorPos(splitCol + 2, 12)
        self.win.write("Freier Speicher:")
        self.win.setCursorPos(splitCol + 2, 13)
        self.win.write(" -> " .. math.floor(freeSpace / 1024) .. " KB")
    end

    -- 4. Footer (STATE_DIAGNOSTICS)
    self.win.setCursorPos(2, h)
    self.win.setBackgroundColor(colors.lightGray)
    self.win.setTextColor(colors.black)
    self.win.write(" [ Zurueck ] ")
    self.win.setBackgroundColor(colors.white)
end

return BootAssistant
