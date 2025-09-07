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
    sampAddChatMessage(scriptName .. " Скрипт готов к работе.", 0xFFFFFF)
    sampAddChatMessage(scriptName .. " С возвращением, " .. playerName, 0xFFFFFF)
    sampAddChatMessage(betaScriptName .. " Открыть главное меню: /mtools", 0xFFFFFF)
    sampAddChatMessage(betaScriptName .. " Версия скрипта: " .. scriptVersion, 0xBFBFBF)
    --sampRegisterChatCommand('mtools', function()
    --    renderWindow[0] = not renderWindow[0]
    --end)
    downloadUrlToFile(update_url, update_path, function(id, status)
        if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            updateIni = inicfg.load(nil, update_path)
            if updateIni and updateIni.info and tonumber(updateIni.info.vers) > script_vers then
                sampAddChatMessage(scriptName .. ' Доступно обновление! Версия: ' .. updateIni.info.vers_text, -1)
                update_status = true
            else
                sampAddChatMessage(scriptName .. ' Ошибка: update.ini отсутствует или имеет неправильный формат.',
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
                    sampAddChatMessage(scriptName .. 'Скрипт успешно обновлен!', -1)
                    sampAddChatMessage(scriptName .. '==============ОБНОВЛЕНИЕ' .. scriptVersion .. '==============',
                        0x8B59FF)
                    sampAddChatMessage(scriptName .. '* Добавлено: *', -1)
                    sampAddChatMessage(scriptName .. '- Функция автообновления', -1)
                    thisScript():reload()
                end
            end)
            break
        end
    end
end
