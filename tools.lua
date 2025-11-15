script_name("LunaTools")
script_author("HermitTech")
script_description("Luna Tools. Vers. 1")
script_version("1")

require "lib.moonloader"
require "lib.sampfuncs"
local dlstatus = require('moonloader').download_status
local inicfg = require 'inicfg'

update_status = false

local script_vers = 2
local script_vers_text = "2.00"
local cp1251_table = {
    ["А"]="\192", ["Б"]="\193", ["В"]="\194", ["Г"]="\195",
    ["Д"]="\196", ["Е"]="\197", ["Ё"]="\168", ["Ж"]="\198",
    ["З"]="\199", ["И"]="\200", ["Й"]="\201", ["К"]="\202",
    ["Л"]="\203", ["М"]="\204", ["Н"]="\205", ["О"]="\206",
    ["П"]="\207", ["Р"]="\208", ["С"]="\209", ["Т"]="\210",
    ["У"]="\211", ["Ф"]="\212", ["Х"]="\213", ["Ц"]="\214",
    ["Ч"]="\215", ["Ш"]="\216", ["Щ"]="\217", ["Ъ"]="\218",
    ["Ы"]="\219", ["Ь"]="\220", ["Э"]="\221", ["Ю"]="\222",
    ["Я"]="\223",
    ["а"]="\224", ["б"]="\225", ["в"]="\226", ["г"]="\227",
    ["д"]="\228", ["е"]="\229", ["ё"]="\184", ["ж"]="\230",
    ["з"]="\231", ["и"]="\232", ["й"]="\233", ["к"]="\234",
    ["л"]="\235", ["м"]="\236", ["н"]="\237", ["о"]="\238",
    ["п"]="\239", ["р"]="\240", ["с"]="\241", ["т"]="\242",
    ["у"]="\243", ["ф"]="\244", ["х"]="\245", ["ц"]="\246",
    ["ч"]="\247", ["ш"]="\248", ["щ"]="\249", ["ъ"]="\250",
    ["ы"]="\251", ["ь"]="\252", ["э"]="\253", ["ю"]="\254",
    ["я"]="\255"
}

-- Функция для конвертации UTF-8 в CP1251
function utf8_to_cp1251(str)
    local res = ""
    for uchar in str:gmatch(".") do
        res = res .. (cp1251_table[uchar] or uchar)
    end
    return res
end

-- Функция для конвертации CP1251 обратно в UTF-8
local rev_table = {}
for k,v in pairs(cp1251_table) do rev_table[string.byte(v)] = k end

function cp1251_to_utf8(str)
    local res = ""
    for i = 1, #str do
        local b = str:byte(i)
        res = res .. (rev_table[b] or string.char(b))
    end
    return res
end

-- Пример использования
local text = "Привет, мир!"
local encoded = utf8_to_cp1251(text)   -- в CP1251
local decoded = cp1251_to_utf8(encoded) -- обратно в UTF-8
print(decoded) -- должно вывести "Привет, мир!"

local update_url = "https://raw.githubusercontent.com/XakerTv/moontools/refs/heads/main/update.ini"
local update_path = getWorkingDirectory() .. "/update.ini"

local script_url = "https://github.com/XakerTv/moontools/raw/refs/heads/main/tools.lua"
local script_path = thisScript().path

scriptName = "{8B59FF}[ Luna Tools ]{FFFFFF}"
betaScriptName = "[ Luna | DeBug ]"
scriptVersion = "1a"

function main()
    while not isSampAvailable() do wait(0) end
    local playerId = select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))
    local playerName = sampGetPlayerNickname(playerId)
    sampAddChatMessage(scriptName .. " Ñêðèïò ãîòîâ ê ðàáîòå.", 0xFFFFFF)
    sampAddChatMessage(scriptName .. " Ñ âîçâðàùåíèåì, " .. playerName, 0xFFFFFF)
    sampAddChatMessage(betaScriptName .. " Îòêðûòü ãëàâíîå ìåíþ: /mtools", 0xFFFFFF)
    sampAddChatMessage(betaScriptName .. " Âåðñèÿ ñêðèïòà: " .. scriptVersion, 0xBFBFBF)
    --sampRegisterChatCommand('mtools', function()
    --    renderWindow[0] = not renderWindow[0]
    --end)
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if updateIni and updateIni.info and tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage(scriptName .. ' Äîñòóïíî îáíîâëåíèå! Âåðñèÿ: ' .. updateIni.info.vers_text, -1)
                update_status = true
            else
                sampAddChatMessage(scriptName .. ' Îøèáêà: update.ini îòñóòñòâóåò èëè èìååò íåïðàâèëüíûé ôîðìàò.',
                    0xFF0000)
            end
            os.remove(update_path)
        end
    end)

    while true do
        wait(0)

        if update_status then
            downloadUrlToFile(update_url, update_path, function(id, status)
                if status == dlstatus.STATUS_ENDDOWNLOADDATA then
                    sampAddChatMessage(scriptName .. 'Ñêðèïò óñïåøíî îáíîâëåí!', -1)
                    sampAddChatMessage(scriptName .. '==============ÎÁÍÎÂËÅÍÈÅ' .. scriptVersion .. '==============',
                        0x8B59FF)
                    sampAddChatMessage(scriptName .. '* Äîáàâëåíî: *', -1)
                    sampAddChatMessage(scriptName .. '- Ôóíêöèÿ àâòîîáíîâëåíèÿ', -1)
                    thisScript():reload()
                end
            end)
            break
        end
    end
end

