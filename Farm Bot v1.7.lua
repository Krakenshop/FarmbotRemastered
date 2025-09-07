script_name('Farm Bot')
script_author('kopnev')
script_version('1.7')
script_version_number(17)

local sampev   = require 'lib.samp.events'
local inicfg   = require 'inicfg'
local imgui   = require 'imgui'
local imadd    = require 'imgui_addons'
local encoding = require 'encoding'
local effil    = require 'effil'
local memory   = require 'memory'
local rkeys    = require 'rkeys'
local vkeys    = require 'vkeys'
local dlstatus = require('moonloader').download_status

encoding.default = 'CP1251'
u8 = encoding.UTF8


local main_windows_state = imgui.ImBool(false)
local settings_window = imgui.ImBool(false)
local loop_window = imgui.ImBool(false)
local changelog_window = imgui.ImBool(false)


local sat_flag = false -- https://blast.hk/threads/31640/
local sat_full = false
local f_scrText_state = false
local hun = 0
local textdraw = { numb = 549.5, del = 54.5, {549.5, 60, -1436898180}, {547.5, 58, -16777216}, {549.5, 60, 1622575210} }


local def = {
	settings = {
        theme = 7,
        style = 1,
        vkladka = 5,
        reload = false,
        reloadR = false,
        post = 0,
        limit = true,
        lim = 30,
        limit1 = true,
        lim1 = 4,
        key1 = 114,
        helptext = true,
        b_loop = false,
		d_loop = 350,
        uahungry = false,
		hungry = false,
		animsuse = false,
		anims = "/anims 32",
		altbot = false,
		animsbot = false,
		chipsbot = false,
        fishbot = false,
        venisonbot = false,
        venisonbotbag = false,
        idVK = 0,
        auto = false,
        bg = false,
        faedit = false,
        invisible = false,
    },
    vk = {
        token = "",
        id = 0,
        InChat = true,
        ot = true,
        manage = false,
        active = false,
        cord = true,
        hp = true
    }
}

local directIni = "KopnevScripts\\Farm Bot.ini"

local ini = inicfg.load(def, directIni)

local faedit = imgui.ImBool(ini.settings.faedit)

local faico = faedit.v

if faico then
    fa = require 'fAwesome5'
    fa_font = nil
    fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
end

local InChat = imgui.ImBool(ini.vk.InChat)
local ot = imgui.ImBool(ini.vk.ot)
local manage = imgui.ImBool(ini.vk.manage)
local active = imgui.ImBool(ini.vk.active)
local cord = imgui.ImBool(ini.vk.cord)
local hp = imgui.ImBool(ini.vk.hp)
local style = imgui.ImInt(ini.settings.style)

local b_loop = imgui.ImBool(ini.settings.b_loop)
local d_loop = imgui.ImInt(ini.settings.d_loop)

local tema = imgui.ImInt(ini.settings.theme)
local post = imgui.ImInt(ini.settings.post)
local limit = imgui.ImBool(ini.settings.limit)
local lim = imgui.ImInt(ini.settings.lim)
local helptext = imgui.ImBool(ini.settings.helptext)

local limit1 = imgui.ImBool(ini.settings.limit1)
local lim1 = imgui.ImInt(ini.settings.lim1)

local uahungry = imgui.ImBool(ini.settings.uahungry)
local hungry = imgui.ImBool(ini.settings.hungry)
local animsuse = imgui.ImBool(ini.settings.animsuse)
local anims = imgui.ImBuffer(ini.settings.anims, 32)

local altbot = imgui.ImBool(ini.settings.altbot)
local animsbot = imgui.ImBool(ini.settings.animsbot)
local chipsbot = imgui.ImBool(ini.settings.chipsbot)
local fishbot = imgui.ImBool(ini.settings.fishbot)
local venisonbot = imgui.ImBool(ini.settings.venisonbot)
local venisonbotbag = imgui.ImBool(ini.settings.venisonbotbag)
local invisible = imgui.ImBool(ini.settings.invisible)

local auto = imgui.ImBool(ini.settings.auto)
local bg = imgui.ImBool(ini.settings.bg)

local idVK = imgui.ImInt(ini.settings.idVK)

local GroupToken = imgui.ImBuffer(ini.vk.token, 128)
local id = imgui.ImInt(ini.vk.id)

value = 0
value1 = 0
work = false
work1 = false
gopoint = false
onpoint = false
bplant = false
success = false
onpoint2 = false
ww = false
gopay = false
zdorov = false
gou = false
num = 0


local vkladki = {
    false,
		false,
		false,
		false,
		false,
		false,
}

vkladki[ini.settings.vkladka] = true

local ActiveMenu = {
	v = {ini.settings.key1,ini.settings.key2}
}
local bindID = 0
local tLastKeys = {}

local items = {
	u8"Ò¸ìíàÿ òåìà",
	u8"Ñèíèÿ òåìà",
	u8"Êðàñíàÿ òåìà",
	u8"Ãîëóáàÿ òåìà",
	u8"Çåë¸íàÿ òåìà",
	u8"Îðàíæåâàÿ òåìà",
	u8"Ôèîëåòîâàÿ òåìà",
	u8"Ò¸ìíî-ñâåòëàÿ òåìà"
}

local styles = {
	u8'Ñòðîãèé',
	u8'Ìÿãêèé'
}

local posts = {
	u8"Íà÷àëüíûé ôåðìåð",
	u8"Òðàêòîðèñò",
	u8"Êîìáàéíåð"
}

--------------------------------------------VK NOTF--------------------------------------------------
local key, server, ts

function threadHandle(runner, url, args, resolve, reject) -- îáðàáîòêà effil ïîòîêà áåç áëîêèðîâîê
	local t = runner(url, args)
	local r = t:get(0)
	while not r do
		r = t:get(0)
		wait(0)
	end
	local status = t:status()
	if status == 'completed' then
		local ok, result = r[1], r[2]
		if ok then resolve(result) else reject(result) end
	elseif err then
		reject(err)
	elseif status == 'canceled' then
		reject(status)
	end
	t:cancel(0)
end

function requestRunner() -- ñîçäàíèå effil ïîòîêà ñ ôóíêöèåé https çàïðîñà
	return effil.thread(function(u, a)
		local https = require 'ssl.https'
		local ok, result = pcall(https.request, u, a)
		if ok then
			return {true, result}
		else
			return {false, result}
		end
	end)
end

function async_http_request(url, args, resolve, reject)
	local runner = requestRunner()
	if not reject then reject = function() end end
    lua_thread.create(function()
        url = url.."?"..args
		threadHandle(runner, url, args, resolve, reject)
	end)
end


local jhg = false
potok = false

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampRegisterChatCommand("farm", function()
        main_windows_state.v = not main_windows_state.v
        print("Command triggered, main_windows_state.v:", main_windows_state.v)
    end)

    if doesFileExist(thisScript().path) then
		os.rename(thisScript().path, 'moonloader/Farm Bot v'..thisScript().version..'.lua')
	end

    if doesFileExist('moonloader/Farm-Bot v1.6.lua') then
		os.remove('moonloader/Farm-Bot v1.6.lua')
    end
    if doesFileExist('moonloader/Farm-Bot v1.5.lua') then
		os.remove('moonloader/Farm-Bot v1.5.lua')
    end
    if doesFileExist('moonloader/farmer bot.lua') then
		os.rename('moonloader/farmer bot.lua', 'moonloader/Farm-Bot v1.5.lua')
    end
    if doesFileExist('moonloader/farmer bot (NU).lua') then
		os.remove('moonloader/farmer bot (NU).lua')
	end
    
    if ini.settings.reload == true then
		SCM('Óñïåøíî ñîõðàíåíî è ïðèìåíåíî.')
		main_windows_state.v = true
		ini.settings.reload = false
		inicfg.save(def, directIni)
	end
    if ini.settings.reloadR == true then
		ini.settings.reloadR = false
		inicfg.save(def, directIni)
    end

    SCM('Ñêðèïò çàãðóæåí. Àêòèâàöèÿ: {F1CB09}')
    update()
    while true do
        wait(250)
        imgui.Process = main_windows_state.v

        if gou == true then
            goupdate()
        end

        if work then
            res, x, y, z = FindObject()
            if gopoint and res then 
                BeginToPoint(x,y,z,3,-255,true)
                gopoint = false
            end
            if onpoint then
                lua_thread.create(function() 
                    while true do
                        wait(150)
                        setGameKeyState(21, 255)
                        break
                    end
                end)
                onpoint = false
                bplant = true
            end
        end

        if bg.v == true then
            WorkInBackground(true)
        else WorkInBackground(false) end
    end
end

lua_thread.create(function() 
	while true do
		wait(30)
		if isKeyDown(17) and isKeyDown(82) then -- CTRL+R
			ini.settings.reloadR = true
			inicfg.save(def, directIni)
		end
	end
end)



----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------Àíòè-Ãîëîä by Hawk---------------------------------------------------
------------------------------------------https://blast.hk/threads/31640/---------------------------------------------
----------------------------------------------------------------------------------------------------------------------
lua_thread.create(function()
	while true do 
		wait(300)
		if (altbot.v or animsbot.v or chipsbot.v or fishbot.v or venisonbot.v or venisonbotbag.v) and (b_loop.v or f_scrText_state or sat_flag) then -- Àíòè-ãîëîä îò Õàâêà
            if b_loop.v then
                wait(d_loop.v*1000)
                if not b_loop.v then
                    break
                end
            elseif f_scrText_state or sat_flag then
                if potok == false and helptext.v then SCM('Ïîñïàëè, òåïåðü ìîæíî è ïîåñòü.') end
                wait(50)
            end
            if altbot.v or animsbot.v then
                sampSendChat("/house")
                wait(250)
                sampSendDialogResponse(174, 1, 1)
                wait(250)
                sampSendDialogResponse(2431, 1, 0)
                wait(250)
                sampSendDialogResponse(185, 1, 6)
                wait(250)
                sampCloseCurrentDialogWithButton(0)
                SCM('Ïîåëè, òåïåðü ìîæíî è ïîñïàòü.')
                if animsuse.v then
                    if altbot.v then
                        setGameKeyState(21, 255)--alt
                    elseif animsbot.v and chipsbot.v or fishbot.v or venisonbot.v or venisonbotbag.v then
                        sampSendChat(anims.v)
                    end
                end
            elseif chipsbot.v or fishbot.v or venisonbot.v or venisonbotbag.v then
                wait(250)
                    if potok == false then
                        lua_thread.create(function()
                            potok = true
                            if chipsbot.v  then
                                while not sat_full and chipsbot.v do
                                    sampSendChat("/cheeps")
                                    wait(100)
                                    for i=90, 99 do
                                        text = sampGetChatString(i)
                                        --print(text)
                                        if text == "Ó òåáÿ íåò ÷èïñîâ!" then
                                            SCM('Chips-bot îòêëþ÷åí.')
                                            chipsbot.v = false
                                            break
                                        end
                                    end
                                    wait(4000)
                                end
                                potok = false
                            elseif fishbot.v then
                                while not sat_full and fishbot.v do
                                    sampSendChat("/jfish")
                                    wait(100)
                                    for i=90, 99 do
                                        text = sampGetChatString(i)
                                        --print(text)
                                        if text == "Ó òåáÿ íåò æàðåíîé ðûáû!" then
                                            SCM('Fish-bot îòêëþ÷åí.')
                                            fishbot.v = false
                                            break
                                        end
                                    end
                                    wait(4000)
                                end
                                potok = false
                            elseif venisonbot.v then
                                while not sat_full and venisonbot.v do
                                    sampSendChat("/jmeat")
                                    wait(100)
                                    for i=90, 99 do
                                        text = sampGetChatString(i)
                                        --print(text)
                                        if text == "Ó òåáÿ íåò æàðåíîãî ìÿñà îëåíèíû!" then
                                            SCM('Venison-bot îòêëþ÷åí.')
                                            venisonbot.v = false
                                            break
                                        end
                                    end
                                    wait(4000)
                                end
                                potok = false
                            elseif venisonbotbag.v then
                                while not sat_full and venisonbotbag.v do
                                    sampSendChat("/meatbag")
                                    wait(100)
                                    for i=90, 99 do
                                        text = sampGetChatString(i)
                                        print(text)
                                        if string.find(text,"Ó âàñ íåò ìåøêà ñ ìÿñîì!") then
                                            SCM('Venison Bag-bot îòêëþ÷åí.')
                                            venisonbotbag.v = false
                                            break
                                        end
                                    end
                                    wait(4000)
                                end
                                potok = false
                            end
                            if animsuse.v and (chipsbot.v or fishbot.v or venisonbot.v or venisonbotbag.v) then
                                if altbot.v then
                                    setGameKeyState(21, 255)--alt
                                elseif animsbot.v or chipsbot.v or fishbot.v or venisonbot.v then
                                    sampSendChat(anims.v)
                                end
                            end
                        end)
                    end
                if sat_full and helptext.v then SCM('Ïîåëè, òåïåðü ìîæíî è ïîñïàòü.') sampCloseCurrentDialogWithButton(0) end
            end
        end
	end
end)

-----------------------------------Ñàìï åâåíòñ---------------------------------------

function sampev.onSetPlayerAttachedObject(pid, index, create, obj)
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if work and myid == pid then
        if obj.modelId == 2901 then
            lua_thread.create(function() 
          BeginToPoint(-105.7775,100.9354,3.1172, 3, -255, true)  end)
          success = true
        end
        if obj.modelId == 0 and onpoint2 then
            if ini.settings.limit == false and value == ini.settings.lim then
                lua_thread.create(function() 
                    BeginToPoint(-120.1061,88.2469,3.1172, 3, -255, true)  end)
            else gopoint = true end
        end
    end
end

function sampev.onSetPlayerHealth(hp)
    zdorov = false
end

function sampev.onApplyPlayerAnimation(pid, animLib, animName, loop)
    _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
    if pid == myid and bplant and animName == "BOM_Plant" then
        bplant = false
        success = false
        lua_thread.create(function() 
            wait(15000)
            if success == false then
                success = false
                gopoint = true
            end
        end)
    end
end

otvet = false

function sampev.onServerMessage(clr, msg)
    if work and msg:find('Ñåíà ïåðåòàùåíî:') then
        value = value + 1
    end
    if (work or work1) and msg:find('Âû óñïåøíî çàáðàëè ñâîþ çàðïëàòó â ðàçìåðå:') then
        lua_thread.create(function() 
            BeginToPoint(-92.8096, 93.2234, 3.1172, 5, -255, true)  
            work = false
            work1 = false
        end)
    end
    if (work or work1) and msg:find('Âû åùå íè÷åãî íå çàðàáîòàëè è íå ìîæåòå ïîëó÷èòü çàðïëàòó!') then
        lua_thread.create(function() 
            BeginToPoint(-92.8096, 93.2234, 3.1172, 5, -255, true)  
            work = false
            work1 = false
        end)
    end
    if msg:find('Âû òóò?') or msg:find('âû òóò?') or msg:find('îòâåòèë âàì') and ini.vk.ot then
        if ini.settings.auto then 
            lua_thread.create(function() 
                if not otvet then
                    otvet = true
                    wait(3200) 
                    sampSendChat('Äà')
                    wait(5000)
                    otvet = false
                end
            end)
        end
    end
    if work1 and msg:find('Âû óñïåøíî îòðàáîòàëè.') then
        value1 = value1 + 1
        num = 0
        if value1 >= ini.settings.lim1 and not ini.settings.limit1 then
            gopay = true
            ww = true
            lua_thread.create(function()
                rideTo(-108.5108, 119.1330, 3.0700, 50)
                rideTo(-121.1731, 85.7734, 3.0719, 50)
                rideTo(-115.0045, 79.7263, 3.0729, 50)
                rideTo(-108.6299, 76.0149, 3.0727, 50)
                rideTo(-96.1733, 75.8351, 3.0727, 20)
                rideTo(-87.7826, 74.0141, 3.0721, 10)
                sampSendChat('/engine')
                ww = false
                wait(500)
                while true do
                    wait(150)
                    setGameKeyState(15, 255)
                    break
                end
                wait(2000)
                if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then 
                    while true do
                        wait(150)
                        setGameKeyState(15, 255)
                        break
                    end
                    wait(1500)
                end
                BeginToPoint(-80.5411, 82.7958, 3.1096, 1, -255, false)
                wait(2000)
                while true do
                    wait(150)
                    setGameKeyState(21, 255)
                    break
                end
            end)
        end
    end
    if f_scrText_state and (altbot.v or animsbot.v or chipsbot.v or fishbot.v or venisonbot.v or venisonbotbag.v) then
        if string.find(msg, "Âû âçÿëè êîìïëåêñíûé îáåä. Ïîñìîòðåòü ñîñòîÿíèå ãîëîäà ìîæíî") then
            f_scrText_state = false
        end
    end
end

function sampev.onSetRaceCheckpoint(type, pos)
    if work1 and not gopay then
        num = num + 1
        sampAddChatMessage("Current checkpoint: " .. num, -1)
        lua_thread.create(function()
            if num == 19 then
                rideTo(-121.4095, -123.5240, 4.0606, 60, 3.0)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2)
            elseif num == 28 then
                rideTo(24.9672, -26.8587, 4.0216, 60, 3.0)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2)
            elseif num == 38 then
                rideTo(55.4785, 53.3833, 2.2682, 60, 3.0)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2)
            elseif num == 40 then
                rideTo(-7.5333, 30.1100, 4.0611, 60, 3.0)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2)
            elseif num == 41 then
                rideTo(-34.6055, 8.3665, 4.0636, 60, 3.0)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2)
 elseif value1 > 0 and num == 1 then
     ww = true
     sampAddChatMessage("{00FF00}[BOT]{FFFFFF} Çàïóñêàþ ìàðøðóò ñ ïåðâîãî ÷åêïîèíòà...", -1)
     rideTo(-67.9033, 25.4006, 4.0607, 60, 3.0)
     rideTo(-82.3245, 39.1356, 4.0620, 60, 3.0)
     rideTo(-106.5499, 40.5278, 4.0667, 60, 3.0)
     rideTo(-120.0644, 4.8134, 4.0575, 60, 3.0)
     rideTo(-130.6800, -43.2168, 4.0672, 60, 3.0)
     rideTo(-150.7212, -76.3725, 4.0549, 60, 3.0)
     rideTo(-164.0034, -109.4677, 4.0785, 60, 3.0)
     rideTo(-179.5366, -117.1296, 4.0603, 60, 3.0)
     rideTo(-185.1780, -84.2181, 4.0672, 45)
     sampAddChatMessage("{00FF00}[BOT]{FFFFFF} Ìàðøðóò çàâåðø¸í, âîçâðàùàþñü ê íà÷àëó.", -1)
            elseif num == 70 then
                rideTo(-119.7002, 84.2271, 3.0719, 60, 1.2)
                rideTo(pos.x, pos.y, pos.z, 60, 1.2)
            else
                rideTo(pos.x, pos.y, pos.z, 60, 1.2)
            end
        end)
    end
end
---118.17479705811   97.49169921875   3.0650999546051
------------------------------------------------------------------------------------------------------------------

--------------------------------------https://blast.hk/threads/31640/-------------------------------------------
function onReceiveRpc(id, bs)
    if id == 134 then
		local td = readBitstream(bs)
		if td.x == textdraw[1][1] and td.y == textdraw[1][2] and td.color == textdraw[1][3] then
			sat = td.hun
			--print(sat)
			--print(math.floor((sat/textdraw.del)*100))
            --print(tostring(sat_flag))
            hun = math.floor((sat/textdraw.del)*100)
			local tmp = math.floor((sat/textdraw.del)*100)
			if hungry.v then
				if tmp < 20 then
					sat_flag = true
					--print(tostring(sat_flag))
				else
					sat_flag = false
				end
			end
			if tmp > 99 then sat_full = true else sat_full = false end
		end
    end
end

function sampev.onDisplayGameText(style, time, text)
    if uahungry.v and (altbot.v or animsbot.v or chipsbot.v or fishbot.v or venisonbot.v or venisonbotbag.v) then
        if text:find("You are hungry!") or text:find("You are very hungry!") then
			f_scrText_state = true
		end
	end
end
-----------------------------------------------------------------------------------------------------------

function FindObject()
    local xped, yped, zped = getCharCoordinates(PLAYER_PED)

    for i = 5, 85, 1 do
        for b = 1, 3, 1 do
            res, object = findAllRandomObjectsInSphere(xped, yped, zped, i, true)

            if res and getObjectModel(object) == 864 then
                local _, x, y, z = getObjectCoordinates(object)
                local res, _ = findAllRandomCharsInSphere(x, y, z, 10, false, true)
                if res == false then
                    return true, x, y, z
                end
            end
        end
    end

    return false, 0, 0, 0

end

function ShowHelpMarker(desc)
    if faico then imgui.TextDisabled(fa.ICON_FA_QUESTION_CIRCLE) else imgui.TextDisabled(u8'(?)') end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450.0)
        imgui.TextUnformatted(desc)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function ShowCOPYRIGHT(desc)

    if faico then imgui.TextDisabled(fa.ICON_FA_QUESTION_CIRCLE) else imgui.TextDisabled(u8'(Ñ)') end
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
        imgui.PushTextWrapPos(450.0)
        imgui.TextUnformatted(desc)
        imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function imgui.BeforeDrawFrame()
    if faico then
        if fa_font == nil then
            local font_config = imgui.ImFontConfig()
            font_config.MergeMode = true
            fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 11.0, font_config, fa_glyph_ranges)
        end
    end
end

function imgui.OnDrawFrame()
	if ini.settings.style == 0 then strong_style() end
	if ini.settings.style == 1 then easy_style() end
	if ini.settings.theme == 0 then theme1() end
	if ini.settings.theme == 1 then theme2() end
	if ini.settings.theme == 2 then theme3() end
	if ini.settings.theme == 3 then theme4() end
	if ini.settings.theme == 4 then theme5() end
	if ini.settings.theme == 5 then theme6() end
	if ini.settings.theme == 6 then theme7() end
	if ini.settings.theme == 7 then theme8() end
    
    if main_windows_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(700, 340), imgui.Cond.FirstUseEver)
        imgui.Begin(thisScript().name..' | version '..thisScript().version, main_windows_state, 2)

        imgui.BeginChild('left pane', imgui.ImVec2(150, 0), true)
            if faico then 
                if imgui.Button(u8"Íàñòðîéêè áîòà  "..fa.ICON_FA_ROBOT, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[1] = true
                    ini.settings.vkladka = 1
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Àíòè-ãîëîä  "..fa.ICON_FA_UTENSILS, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[2] = true
                    ini.settings.vkladka = 2
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Óâåäîìëåíèÿ ÂÊ  "..fa.ICON_FA_INFO, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[3] = true
                    ini.settings.vkladka = 3
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Íàñòðîéêè  "..fa.ICON_FA_COGS, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[4] = true
                    ini.settings.vkladka = 4
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Èíôîðìàöèÿ  "..fa.ICON_FA_INFO_CIRCLE, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[5] = true
                    ini.settings.vkladka = 5
                    inicfg.save(def, directIni)
                end
            else
                if imgui.Button(u8"Íàñòðîéêè áîòà  ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[1] = true
                    ini.settings.vkladka = 1
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Àíòè-ãîëîä  ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[2] = true
                    ini.settings.vkladka = 2
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Óâåäîìëåíèÿ ÂÊ  ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[3] = true
                    ini.settings.vkladka = 3
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Íàñòðîéêè  ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[4] = true
                    ini.settings.vkladka = 4
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Èíôîðìàöèÿ", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[5] = true
                    ini.settings.vkladka = 5
                    inicfg.save(def, directIni)
                end
            end
        imgui.EndChild()
        imgui.SameLine()

        if vkladki[1] == true then -- Íàñòðîéêè áîòà
			imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8'Íàñòðîéêè áîòà '..fa.ICON_FA_ROBOT) else imgui.Text(u8'Íàñòðîéêè áîòà') end
			imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(30) imgui.Text(u8'Âûáîð äîëæíîñòè:') imgui.SameLine(170)
            imgui.PushItemWidth(250)
			if imgui.Combo('##dl', post, posts, -1)then
				ini.settings.post = post.v
				inicfg.save(def, directIni)
            end imgui.PopItemWidth()
            imgui.NewLine() imgui.Separator() imgui.NewLine() imgui.NewLine()
            if ini.settings.post == 0 then
                imgui.SameLine(30) imgui.Text(u8'Áåç îãðàíè÷åíèÿ:') imgui.SameLine(170) 
                if imadd.ToggleButton('##limit', limit) then
                    ini.settings.limit = limit.v
                    inicfg.save(def, directIni)
                end
                if ini.settings.limit == false then
                    imgui.NewLine() imgui.NewLine()
                    imgui.SameLine(30) imgui.Text(u8'Îãðàíè÷åíèå:') imgui.SameLine(170) 
                    imgui.PushItemWidth(250) 
                        if imgui.InputInt('##lim', lim) then
                            ini.settings.lim = lim.v
                            inicfg.save(def, directIni)
                        end
                    imgui.PopItemWidth()
                end
                imgui.SetCursorPos(imgui.ImVec2(486, 300))
                if faico then
                    if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8'  Íà÷àòü', imgui.ImVec2(100, 30)) then
                        work = true
                        gopoint = true
                    end imgui.SameLine()
                    if work == true then
                        if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8'  Ñòîï', imgui.ImVec2(100, 30)) then
                            work = false
                        end
                    end
                else
                    if imgui.Button(u8'Íà÷àòü', imgui.ImVec2(100, 30)) then
                        work = true
                        gopoint = true
                    end imgui.SameLine()
                    if work == true then
                        if imgui.Button(u8'Ñòîï', imgui.ImVec2(100, 30)) then
                            work = false
                        end
                    end
                end
            end
            if ini.settings.post == 1 then
                imgui.SameLine(30) imgui.Text(u8'Áåç îãðàíè÷åíèÿ:') imgui.SameLine(170) 
                if imadd.ToggleButton('##liimit', limit1) then
                    ini.settings.limit1 = limit1.v
                    inicfg.save(def, directIni)
                end
                if ini.settings.limit1 == false then
                    imgui.NewLine() imgui.NewLine()
                    imgui.SameLine(30) imgui.Text(u8'Îãðàíè÷åíèå:') imgui.SameLine(170) 
                    imgui.PushItemWidth(250) 
                        if imgui.InputInt('##lim', lim1) then
                            ini.settings.lim1 = lim1.v
                            inicfg.save(def, directIni)
                        end
                    imgui.PopItemWidth()
                    imgui.SameLine() ShowHelpMarker(u8'Íå ðåêîìåíäóåòñÿ ñòàâèòü áîëüøå 4, ò.ê êîí÷àåòñÿ òîïëèâî')
                end
                imgui.Text(u8"Èíôîðìàöèÿ: Àâòîð ñêðèïòà D.Kopnev")
                imgui.Text(u8"Ññûëêà íà òåìó:")
                imgui.SameLine(100)
                if imgui.Button(u8"Ïåðåéòè") then
                    os.execute('start "" "https://www.blast.hk/threads/40348/"')
                end
                imgui.SetCursorPos(imgui.ImVec2(486, 300))
                if faico then
                    if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8'  Íà÷àòü', imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 532 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work1 = true
                                gopay = false
                                value1 = 0
                                num = 1
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                    sampSendChat('/engine')
                                end
                            else SCM('Âû íå â òðàêòîðå.') end
                        else SCM('Âû íå â òðàêòîðå.') end
                        lua_thread.create(function() 
                        rideTo(-185.1780, -84.2181, 4.0672, 45) 
 end)
                    end imgui.SameLine()
                    if work1 == true then
                        if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8'  Ñòîï', imgui.ImVec2(100, 30)) then
                            work1 = false
                            gopay = false
                        end
                    end
                else
                    if imgui.Button(u8'Íà÷àòü', imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 532 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work1 = true
                                gopay = false
                                value1 = 0
                                num = 1
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                    sampSendChat('/engine')
                                end
                            else SCM('Âû íå â òðàêòîðå.') end
                        else SCM('Âû íå â òðàêòîðå.') end
                        lua_thread.create(function() 
                        rideTo(-185.1780, -84.2181, 4.0672, 45) 
end)
                    end imgui.SameLine()
                    if work1 == true then
                        if imgui.Button(u8'Ñòîï', imgui.ImVec2(100, 30)) then
                            work1 = false
                            gopay = false
                        end
                    end
                end
            end
            if ini.settings.post == 2 then
                imgui.SameLine(100) imgui.Text(u8'Êóïèòü: kscripts.ru   ')
                imgui.SameLine(290) if imgui.Button(u8'Ïåðåéòè##2') then os.execute('explorer "https://kscripts.ru"') end
            end
            imgui.EndGroup()
        end
        
        if vkladki[2] == true then -- Àíòè-ãîëîä
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200) imgui.Text(u8'Àíòè-Ãîëîä')
            imgui.SameLine() ShowCOPYRIGHT(u8'Àâòîð: James Hawk')
            imgui.NewLine() imgui.Separator() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'Âûáåðèòå òèï ðàáîòû ñêðèïòà:')
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'You are hungry: ') imgui.SameLine() if imadd.ToggleButton(u8'Yoy are hungry', uahungry) then
                hungry.v = false
                b_loop.v = false
                ini.settings.b_loop = b_loop.v
                ini.settings.hungry = hungry.v
                ini.settings.uahungry = uahungry.v
                inicfg.save(def, directIni)
            end imgui.SameLine() ShowHelpMarker(u8'You are hungry - ñðàáàòûâàåò, êîãäà íà ýêðàíå ïîÿâëÿåòñÿ êðàñíàÿ íàäïèñü \"You are hungry!\" èëè \"You are very hungry!\".') imgui.SameLine(200)
            imgui.Text(u8'Ãîëîä: ') imgui.SameLine() if imadd.ToggleButton(u8'Ãîëîä', hungry)  then
                uahungry.v = false
                b_loop.v = false
                ini.settings.b_loop = b_loop.v
                ini.settings.hungry = hungry.v
                ini.settings.uahungry = uahungry.v
                inicfg.save(def, directIni)
            end imgui.SameLine() ShowHelpMarker(u8'Ãîëîä - ñðàáàòûâàåò êîãäà çíà÷åíèå ñûòîñòè äîñòèãàåò íèæå 20 åäèíèö.') imgui.SameLine(340)
            imgui.Text(u8'Öèêëè÷íûé: ') imgui.SameLine() if imadd.ToggleButton(u8'Öèêëè÷íûé', b_loop)  then
                uahungry.v = false
                hungry.v = false
                ini.settings.b_loop = b_loop.v
                ini.settings.hungry = hungry.v
                ini.settings.uahungry = uahungry.v
                inicfg.save(def, directIni)
            end imgui.SameLine() ShowHelpMarker(u8'Öèêëè÷íûé - ñðàáàòûâàåò ÷åðåç îïðåäåë¸ííîå âðåìÿ óêàçàííîå ïîëüçîâàòåëåì') imgui.SameLine()
            if faico then
                if imgui.Button(fa.ICON_FA_SLIDERS_H) then
                    loop_window.v = true
                end
            else 
                if imgui.Button(u8'=') then
                    loop_window.v = true
                end
            end
            imgui.NewLine() imgui.Separator() imgui.NewLine() 
            imgui.SameLine(15) imgui.Text(u8'Èñïîëüçîâàòü àíèìàöèè: ') imgui.SameLine()
            if imadd.ToggleButton(u8'Èñïîëüçîâàòü àíèìàöèè', animsuse) then
                ini.settings.animsuse = animsuse.v
                inicfg.save(def, directIni)
            end
            if animsuse.v == true and not altbot.v then
                imgui.SameLine(215)  imgui.PushItemWidth(150) imgui.InputText('##anims', anims) imgui.PopItemWidth()
            end
            imgui.NewLine() imgui.Separator() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'×òîáû íà÷àòü âûáåðèòå òèï áîòà:')
            imgui.SameLine() ShowHelpMarker(u8'×òîáû èñïîëüçîâàòü àíèìàöèè, íå çàáóäüòå âêëþ÷èòü èõ, â ïóíêåò âûøå')
            imgui.NewLine()	imgui.NewLine()


            imgui.SameLine(15) imgui.Text(u8'Alt-bot:') imgui.SameLine(100) if imadd.ToggleButton('##alt', altbot) then
				chipsbot.v = false
				animsbot.v = false
				fishbot.v = false
				venisonbot.v = false
				venisonbotbag.v = false
				ini.settings.chipsbot = chipsbot.v
				ini.settings.animsbot = animsbot.v
				ini.settings.altbot = altbot.v
				ini.settings.fishbot = fishbot.v
				ini.settings.venisonbot = venisonbot.v
				ini.settings.venisonbotbag = venisonbotbag.v
				inicfg.save(def, directIni)
			end
			imgui.SameLine() ShowHelpMarker(u8'Alt-áîò: Åñò åäó èç õîëîäèëüíèêà. Ïîñëå òîãî êàê ïîåñò ïåðåõîäèò â alt àíèìàöèþ (Íàæèìàåò ALT)')


			imgui.SameLine(180) imgui.Text(u8'Chips-bot:') imgui.SameLine(265) if imadd.ToggleButton('##Chips', chipsbot) then
				altbot.v = false
				animsbot.v = false
				fishbot.v = false
				venisonbot.v = false
				venisonbotbag.v = false
				if chipsbot.v == false then potok = false end
				ini.settings.chipsbot = chipsbot.v
				ini.settings.animsbot = animsbot.v
				ini.settings.altbot = altbot.v
				ini.settings.fishbot = fishbot.v
				ini.settings.venisonbot = venisonbot.v
				ini.settings.venisonbotbag = venisonbotbag.v
				inicfg.save(def, directIni)
			end
			imgui.SameLine() ShowHelpMarker(u8'Chips-áîò: Åñò ÷èïñû. Ïîñëå òîãî êàê ïîåñò ïåðåõîäèò â àíèìàöèþ èç (/anims)')

			imgui.SameLine(355) imgui.Text(u8'Vinison-bot:') imgui.SameLine(460) if imadd.ToggleButton('##venison', venisonbot) then
				altbot.v = false
				chipsbot.v = false
				animsbot.v = false
				fishbot.v = false
				venisonbotbag.v = false
				if venisonbot.v == false then potok = false end
				ini.settings.chipsbot = chipsbot.v
				ini.settings.animsbot = animsbot.v
				ini.settings.altbot = altbot.v
				ini.settings.fishbot = fishbot.v
				ini.settings.venisonbot = venisonbot.v
				ini.settings.venisonbotbag = venisonbotbag.v
				inicfg.save(def, directIni)
			end
			imgui.SameLine() ShowHelpMarker(u8'Vinison-áîò: åñò îëåíèíó. Ïîñëå òîãî êàê ïîåñò ïåðåõîäèò â àíèìàöèþ èç (/anims)')


			imgui.NewLine()	imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'Anims-bot:') imgui.SameLine(100) if imadd.ToggleButton('##animsbot', animsbot) then
				altbot.v = false
				chipsbot.v = false
				fishbot.v = false
				venisonbot.v = false
				venisonbotbag.v = false
				ini.settings.chipsbot = chipsbot.v
				ini.settings.animsbot = animsbot.v
				ini.settings.altbot = altbot.v
				ini.settings.fishbot = fishbot.v
				ini.settings.venisonbot = venisonbot.v
				ini.settings.venisonbotbag = venisonbotbag.v
				inicfg.save(def, directIni)
			end
			imgui.SameLine() ShowHelpMarker(u8'Anims-áîò: Åñò åäó èç õîëîäèëüíèêà. Ïîñëå òîãî êàê ïîåñò ïåðåõîäèò â àíèìàöèþ èç (/anims)')


			imgui.SameLine(180) imgui.Text(u8'Fish-bot:') imgui.SameLine(265) if imadd.ToggleButton('##fish', fishbot) then
				altbot.v = false
				chipsbot.v = false
				animsbot.v = false
				venisonbot.v = false
				venisonbotbag.v = false
				if fishbot.v == false then potok = false end
				ini.settings.chipsbot = chipsbot.v
				ini.settings.animsbot = animsbot.v
				ini.settings.altbot = altbot.v
				ini.settings.venisonbot = venisonbot.v
				ini.settings.venisonbotbag = venisonbotbag.v
				inicfg.save(def, directIni)
			end
			imgui.SameLine() ShowHelpMarker(u8'Fish-áîò: åñò ðûáó. Ïîñëå òîãî êàê ïîåñò ïåðåõîäèò â àíèìàöèþ èç (/anims)')
			imgui.SameLine(355) imgui.Text(u8'Venision Bag-bot:') imgui.SameLine(460) if imadd.ToggleButton('##venisonbotbag', venisonbotbag) then
				altbot.v = false
				chipsbot.v = false
				animsbot.v = false
				venisonbot.v = false
				fishbot.v = false
				if venisonbotbag.v == false then potok = false end
				ini.settings.chipsbot = chipsbot.v
				ini.settings.animsbot = animsbot.v
				ini.settings.altbot = altbot.v
				ini.settings.venisonbot = venisonbot.v
				ini.settings.venisonbotbag = venisonbotbag.v
				inicfg.save(def, directIni)
			end
			imgui.SameLine() ShowHelpMarker(u8'Venision Bag-áîò: åñò îëåíèíó èç ìåøêà. Ïîñëå òîãî êàê ïîåñò ïåðåõîäèò â àíèìàöèþ èç (/anims)')

            imgui.EndGroup()
        end

        if vkladki[3] == true then -- Óâåä âê
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8'Óâåäîìëåíèÿ ÂÊ  '..fa.ICON_FA_INFO) else imgui.Text(u8'Óâåäîìëåíèÿ ÂÊ') end
			imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine() imgui.SameLine(15) 
            imgui.SameLine(100) imgui.Text(u8'Êóïèòü: kscripts.ru   ')
            imgui.SameLine(290) if imgui.Button(u8'Ïåðåéòè##2') then os.execute('explorer "https://kscripts.ru"') end
            imgui.EndGroup()
        end

        if vkladki[4] == true then -- Íàñòðîéêè 
            imgui.BeginGroup()
			imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200)
            if faico then imgui.Text(u8'Íàñòðîéêè  '..fa.ICON_FA_COGS) else imgui.Text(u8'Íàñòðîéêè') end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'Âûáîð òåìû: ') imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo('##theme', tema, items)then
                ini.settings.theme = tema.v
                inicfg.save(def, directIni)
            end imgui.PopItemWidth()
            imgui.SameLine(260)
            imgui.Text(u8'Âûáîð ñòèëÿ: ') imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo('##style', style, styles)then
                ini.settings.style = style.v
                inicfg.save(def, directIni)
            end imgui.PopItemWidth()
			imgui.NewLine() imgui.NewLine() imgui.SameLine(15)
			imgui.Text(u8'Àêòèâàöèÿ:      ') imgui.SameLine()
			if imadd.HotKey("##activee", ActiveMenu, tLastKeys, 100) then
                rkeys.changeHotKey(bindID, ActiveMenu.v)
                SCM("Óñïåøíî! Ñòàðîå çíà÷åíèå: " .. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. " | Íîâîå: " .. table.concat(rkeys.getKeysName(ActiveMenu.v), " + "), -1)
				ini.settings.key1 = ActiveMenu.v[1]
				ini.settings.key2 = ActiveMenu.v[2]
				inicfg.save(def, directIni)
            end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15)
            imgui.Text(u8'FA èêîíêè:') imgui.SameLine(290)
            if imadd.ToggleButton(u8'##faedit', faedit) then
                ini.settings.faedit = faedit.v
                ini.settings.reload = true
                inicfg.save(def, directIni)
                lua_thread.create(function() wait(130) thisScript():reload() end)
                
            end imgui.NewLine()
			imgui.SameLine(15)
            imgui.Text(u8'Àâòîìàòè÷åñêè îòâå÷àòü àäìèíèñòðàöèè:') imgui.SameLine(290)
            if imadd.ToggleButton(u8'##auto', auto) then
                ini.settings.auto = auto.v
                inicfg.save(def, directIni)
            end imgui.SameLine() ShowHelpMarker(u8'Îòâå÷àòü íà âîïðîñû: Âû òóò?')
            imgui.NewLine() 
			imgui.SameLine(15)
            imgui.Text(u8'Ðàáîòà â ñâ¸ðíóòîì ðåæèìå:') imgui.SameLine(290)
            if imadd.ToggleButton(u8'##bg', bg) then
                ini.settings.bg = bg.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8'Ìîæåò ðàáîòàòü íåêîððåêòíî')
            imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'Ðåæèì íåâèäèìêè:') imgui.SameLine(290)
			if imadd.ToggleButton(u8'##invisible', invisible) then
				ini.settings.invisible = invisible.v
				inicfg.save(def, directIni)
			end imgui.SameLine() ShowHelpMarker(u8'Ñîîáùåíèÿ îò Farm Bot\'a áóäóò âûâîäèòüñÿ íå â ÷àò, à â êîíñîëü')


            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) 
            if faico then
                if imgui.Button(fa.ICON_FA_UPLOAD ..  u8'   Ïðîâåðèòü îáíîâëåíèÿ') then
                    update()
                end
            else
                if imgui.Button(u8'Ïðîâåðèòü îáíîâëåíèÿ') then
                    update()
                end
            end


			if new == 1 then
				imgui.SameLine()
				if imgui.Button(u8'Îáíîâèòü') then
					gou = true
				end
            end
            
            imgui.SetCursorPos(imgui.ImVec2(560, 220))
            if imgui.Button(u8'ChangeLog', imgui.ImVec2(100, 25)) then 
                changelog_window.v = not changelog_window.v
            end
            imgui.EndGroup()
        end

        if vkladki[5] == true then -- Èíôîðìàöèÿ
			imgui.BeginGroup()
			imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200)
            if faico then imgui.Text(u8'Èíôîðìàöèÿ  '..fa.ICON_FA_INFO_CIRCLE) else imgui.Text(u8'Èíôîðìàöèÿ') end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine()
            imgui.NewLine()
			imgui.SameLine(210)
            imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), u8'Âíèìàíèå!')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8'Çà âàø àêêàóíò íåñ¸òå îòâåñòâåííîñòü òîëüêî âû!')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8'Åñëè âàñ çàáàíÿò çà áîòà, òî ýòî ÷èñòî âàøà âèíà.')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8'Ðåêîìåíäóåòñÿ íå îòõîäèòü äàëåêî îò êîìïüþòåðà...')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8'...÷òîáû âîâðåìÿ ñðåàãèðîâàòü íà îòâåòû àäìèíîâ.')
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.NewLine() imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8'Àâòîð: Äàíèèë Êîïíåâ')
			imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8'Ãðóïïà: vk.com/kscripts   ')
            imgui.SameLine(290) if imgui.Button(u8'Ïåðåéòè') then os.execute('explorer "https://vk.com/kscripts"') end
            imgui.NewLine()
            imgui.SameLine(100) imgui.Text(u8'Ñàéò: kscripts.ru   ')
            imgui.SameLine(290) if imgui.Button(u8'Ïåðåéòè##2') then os.execute('explorer "https://kscripts.ru"') end
            imgui.NewLine()
            imgui.SameLine(100) imgui.Text(u8'E-mail: support@kscripts.ru   ')
			imgui.NewLine() imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8'Âåðñèÿ ñêðèïòà: '..thisScript().version)
			if new == 1 then imgui.SameLine() imgui.Text(u8'( Äîñòóïíà íîâàÿ âåðñèÿ: '..ver..' )') else
				imgui.SameLine() imgui.Text(u8'( Ïîñëåäíÿÿ âåðñèÿ )') end
			imgui.EndGroup()
		end

        imgui.End()
    end

    if settings_window.v then
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 5, imgui.GetIO().DisplaySize.y / 7), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Íàñòðîéêà äëÿ ãðóïïû', settings_window, 64)
		imgui.Text(u8'Ââåäèòå äàííûå ãðóïïû: ')
		imgui.InputInt(u8'Ââåäèòå ID ãðóïïû', id, 0)
        imgui.InputText(u8'Ââåäèòå Token ãðóïïû', GroupToken) 
        imgui.SameLine()
		imgui.NewLine() imgui.NewLine()
        imgui.SameLine(350) if imgui.Button(u8'Ñîõðàíèòü') then
            ini.vk.token = GroupToken.v
            ini.vk.id = id.v
            inicfg.save(def, directIni)
            settings_window.v = false
        end
		imgui.End()
    end

    if loop_window.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowSize(imgui.ImVec2(350, 140), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(u8'Óñòàíîâêà çàäåðæêè', loop_window, 2)
		imgui.NewLine()
		imgui.NewLine()
		imgui.SameLine(15) imgui.Text(u8'Óñòàíîâêà çàäåðæêè:') imgui.SameLine(150) 
		imgui.PushItemWidth(190) 
		if imgui.InputInt('sec ', d_loop, 1) then
			ini.settings.d_loop = d_loop.v
			inicfg.save(def, directIni)
		end
		imgui.PopItemWidth()
		imgui.NewLine() imgui.NewLine()
		imgui.SameLine(15) imgui.Text(u8'Âñïîìîãàòåëüíûé òåêñò:') imgui.SameLine(170) 
		if imadd.ToggleButton("##helptext", helptext) then
			ini.settings.helptext = helptext.v
			inicfg.save(def, directIni)
		end
		imgui.SameLine() ShowHelpMarker(u8'Òåêñò äî èëè ïîñëå íà÷àëà ïðîöåññà óïîòðåáëåíèÿ åäû: "Ïîñïàëè, òåïåðü ìîæíî è ïîåñòü" èëè "Ïîåëè, òåïåðü ìîæíî è ïîñïàòü"')
		imgui.SetCursorPos(imgui.ImVec2(260, 110))
		if imgui.Button(u8'Çàêðûòü', imgui.ImVec2(80, 25)) then
			loop_window.v = false
		end
		imgui.End()
    end
    
    if changelog_window.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, 500), imgui.Cond.FirstUseEver)
		imgui.Begin(' ', changelog_window, 2)
		
		imgui.SameLine(150)
		imgui.Text(u8'Ñïèñîê èçìåíåíèé')
		imgui.NewLine()
		--imgui.NewLine()
		--imgui.SameLine(25)
		imgui.BeginGroup()
			
			imgui.Separator() imgui.NewLine() imgui.NewLine() imgui.SameLine(170)
			imgui.Text(u8'V 1.5') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'1. Äîðàáîòàíà ñèñòåìà Àíòè-Ãîëîä.') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'2. Ïåðåäåëàíà ñèñòåìà "Ñòèëè è Òåìû".') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'3. Âîçìîæíîñòü îòêþ÷àòü FA icons.') imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8'4. Êíîïêà "Íà÷àòü" ïåðåíåñåíà ëåâåå.') imgui.NewLine() imgui.NewLine()
            imgui.SameLine(170) imgui.Text(u8'V 1.7') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8'1. Òåõíè÷åñêèå íàñòðîéêè è îïòèìèçàöèÿ.') imgui.NewLine() imgui.NewLine()
		imgui.EndGroup()
		imgui.SetCursorPos(imgui.ImVec2(300, 460))
		if imgui.Button(u8"Çàêðûòü", imgui.ImVec2(80, 25)) then 
			changelog_window.v = false
		end
		imgui.End()
	end
end

function uu()
    for i = 0,5 do
        vkladki[i] = false
    end
end

-------------------------------Æèçíåííî íåîáõîäèìûå ïîòîêè-------------------------------------------
huy222 = true
lua_thread.create(function() 
    while true do
        wait(0)
        if ww == true then
            wait(1500)
            ww = false
        end
        if not huy228 then
            wait(5000)
            huy228 = true
        end
    end
end)

lua_thread.create(function() 
    while true do
        wait(0)
        if ww then
            lua_thread.create(function() 
            while ww do
                wait(0)
                setGameKeyState(0,255)
                setGameKeyState(14, 255)
            end end)
        end
    end
end)
-------------------------------ß çíàþ ìîæíî áûëî ïðîùå-------------------------------------------

function rideTo(x, y, z, speed, radius)
    radius = radius or 1.2
    while true do
        wait(0)
        local veh = getCarCharIsUsing(PLAYER_PED)
        local posX, posY, posZ = GetCoordinates()
        local pX, pY = x - posX, y - posY
        local targetHeading = getHeadingFromVector2d(pX, pY) 
        local carHeading = getCarHeading(veh)

        -- ñ÷èòàåì ðàçíèöó óãëîâ [0..360]
        local angsum = 360 - carHeading + targetHeading
        if angsum > 360 then
            angsum = angsum - 360
        end

        -- ðóë¸æêà
        if angsum < 180 then
            -- íàëåâî
            local diff = angsum
            if diff > 15 then
                setGameKeyState(0, -255) -- ðåçêî
            elseif diff > 5 then
                setGameKeyState(0, -120) -- ñðåäíå
            elseif diff > 1 then
                setGameKeyState(0, -40) -- ïëàâíî
            else
                setGameKeyState(0, 0) -- ïðÿìî
            end
        else
            -- íàïðàâî
            local diff = 360 - angsum
            if diff > 15 then
                setGameKeyState(0, 255)
            elseif diff > 5 then
                setGameKeyState(0, 120)
            elseif diff > 1 then
                setGameKeyState(0, 40)
            else
                setGameKeyState(0, 0)
            end
        end

        local dista = getDistanceBetweenCoords3d(x, y, z, posX, posY, z)
        local speedNow = getCarSpeed(veh)
        if dista < radius then
            print("[DEBUG] Point reached at (" .. x .. ", " .. y .. ", " .. z .. ")")
            break
        end

        -- êîððåêòèðóåì ñêîðîñòü ïî ðàññòîÿíèþ
        local targetSpeed = speed
        if dista < 35 then targetSpeed = speed * 0.15 end
        if dista < 10 then targetSpeed = speed * 0.07 end

        if speedNow < targetSpeed and not ww then
            setGameKeyState(16, 255) -- ãàç
        elseif speedNow > targetSpeed and not ww then
            setGameKeyState(6, 255) -- òîðìîç
        end
    end
end
function BeginToPoint(x, y, z, radius, move_code, isSprint)
    repeat
        wait(0)
        if not work and not work1 then break end
        local posX, posY, posZ = GetCoordinates()
        local vehHandle = nil
        vehHandle = getNearestVehicle(15)
        if vehHandle ~= nil then
            setCarCollision(vehHandle, true)
        end
        SetAngle(x, y, z)
        MovePlayer(move_code, isSprint)
        local dist = getDistanceBetweenCoords3d(x, y, z, posX, posY, posZ)
    until dist < radius 
    --Îé äåâà÷êè, ÿ â àõóå îò òàêîãî ÏÐÎ êîäà
    if x == -105.7775 and y == 100.9354 and z == 3.1172 then 
        onpoint2 = true
    else   
        if x == -120.1061 and y == 88.2469 and z == 3.1172 then -- Èä¸ò çà çï
        lua_thread.create(function() 
        BeginToPoint(-106.0395,71.8690,3.1172, 3, -255, true) end)
        else 
            if x == -106.0395 and y == 71.8690 and z == 3.1172 then
            lua_thread.create(function() 
            BeginToPoint(-80.4831,82.9485,3.1096, 1.1, -255, true) end)
            else   
                if x == -80.4831 and y == 82.9485 and z == 3.1096 then
                        lua_thread.create(function() 
                            while true do
                                wait(150)
                                setGameKeyState(21, 255) -- àëüò
                                break
                            end
                        end)
                    else
                    if x ~= -92.8096 and y ~= 93.2234 and z ~= 3.1172 then onpoint = true end
                end
            end 
        end 
    end
end -- -120.1061,88.2469,3.1172

function MovePlayer(move_code, isSprint)
    setGameKeyState(1, move_code)
    --[[255 - îáû÷íûé áåã íàçàä
       -255 - îáû÷íûé áåã âïåðåä
      65535 - èäòè øàãîì âïåðåä
     -65535 - èäòè øàãîì íàçàä]]
    if isSprint then setGameKeyState(16, 255) end
end
 
function SetAngle(x, y, z)
    local posX, posY, posZ = GetCoordinates()
    local pX = x - posX
    local pY = y - posY
    local zAngle = getHeadingFromVector2d(pX, pY)
 
    if isCharInAnyCar(playerPed) then
        local car = storeCarCharIsInNoSave(playerPed)
        setCarHeading(car, zAngle)
    else
        setCharHeading(playerPed, zAngle)
    end
 
    restoreCameraJumpcut()
end
 
function GetCoordinates()
    if isCharInAnyCar(playerPed) then
        local car = storeCarCharIsInNoSave(playerPed)
        return getCarCoordinates(car)
    else
        return getCharCoordinates(playerPed)
    end
end

function getNearestVehicle(radius)
    if not sampIsLocalPlayerSpawned() then return end

    local pVehicle = getLocalVehicle()
    local pCoords = {getCharCoordinates(PLAYER_PED)}
    local vehicles = getAllVehicles()

    -- Sort vehicles by distance to local player
    table.sort(vehicles, function(a, b)
        local aX, aY, aZ = getCarCoordinates(a)
        local bX, bY, bZ = getCarCoordinates(b)
        return getDistanceBetweenCoords3d(aX, aY, aZ, unpack(pCoords)) < getDistanceBetweenCoords3d(bX, bY, bZ, unpack(pCoords))
    end)

    -- Remove local player's vehicle and filter vehicles, whose distance exceeding radius
    for i = #vehicles, 1, -1 do
        if vehicles[i] == pVehicle then
            table.remove(vehicles, i)
        elseif radius ~= nil then
            local x, y, z = getCarCoordinates(vehicles[i])
            if getDistanceBetweenCoords3d(x, y, z, unpack(pCoords)) > radius then
                table.remove(vehicles, i)
            end
        end
    end

    return vehicles[1]
end

function getLocalVehicle()
    return isCharInAnyCar(PLAYER_PED) and storeCarCharIsInNoSave(PLAYER_PED) or nil
end

function readBitstream(bs) -- Àíòè-Ãîëîä îò Õàâêà
	local data = {}
	data.id = raknetBitStreamReadInt16(bs)
	raknetBitStreamIgnoreBits(bs, 104)
	data.hun = raknetBitStreamReadFloat(bs) - textdraw.numb
	raknetBitStreamIgnoreBits(bs, 32)
	data.color = raknetBitStreamReadInt32(bs)
	raknetBitStreamIgnoreBits(bs, 64)
	data.x = raknetBitStreamReadFloat(bs)
	data.y = raknetBitStreamReadFloat(bs)
	return data
end

function char_to_hex(str)
    return string.format("%%%02X", string.byte(str))
end
  
function url_encode(str)
    local str = string.gsub(str, "\\", "\\")
    local str = string.gsub(str, "([^%w])", char_to_hex)
    return str
end

function WorkInBackground(work)
    local memory = require 'memory'
    if work then
        memory.setuint8(7634870, 1)
        memory.setuint8(7635034, 1)
        memory.fill(7623723, 144, 8)
        memory.fill(5499528, 144, 6)
    else
        memory.setuint8(7634870, 0)
        memory.setuint8(7635034, 0)
        memory.hex2bin('5051FF1500838500', 7623723, 8)
        memory.hex2bin('0F847B010000', 5499528, 6)
    end
end

function onScriptTerminate(LuaScript, quitGame)
	if LuaScript == thisScript() and not quitGame and not ini.settings.reload and not ini.settings.reloadR then
		sampShowDialog(6405, "                                        {FF0000}Ïðîèçîøëà îøèáêà!", "{FFFFFF}Ýòîò ñîîáùåíèå ìîæåò áûòü ëîæíûì, åñëè âû \nèñïîëüçîâàëè ñêðèïò AutoReboot \n\nÊ ñîæàëåíèþ ñêðèïò {F1CB09}Farm-Bot{FFFFFF} çàâåðøèëñÿ íåóäà÷íî\nÅñëè âû õîòèòå ïîìî÷ü ðàçðàáîò÷èêó\nÒî ìîæåòå îïèñàòü ïðè êàêîì äåéñòâèè ïðîèçîøëà îøèáêà\nÍàøà ãðóïïà: {0099CC}vk.com/kscripts", "ÎÊ", "", DIALOG_STYLE_MSGBOX)
		SCM('Ïðîèçîøëà îøèáêà')
		showCursor(false, false)
	end
end

function update()
    async_http_request('https://kscripts.ru/scripts/version.php', "script="..toSendGet("Farm Bot"), function(res)
        if res then
            if res:sub(1,1) == '{' then
                result = decodeJson(res)
                if result.num > thisScript().version_num then
                    new = 1
                    ver = result.version
                    SCM('Äîñòóïíî îáíîâëåíèå.')
                    if result.setup then 
                        goupdate()
                    end
                else SCM("Ó Âàñ óñòàíîâëåíà ïîñëåäíÿÿ âåðñèÿ") end
            else sampAddChatMessage("[Connect Tool] Âíóòðåííÿÿ îøèáêà. Ïîïðîáóéòå ïîçæå", 0xFF0000) end
        end
    end)
end
  
function goupdate()
    gou = false
    SCM('Îáíàðóæåíî îáíîâëåíèå. AutoReload ìîæåò êîíôëèêòîâàòü. Îáíîâëÿþñü...')
    SCM('Òåêóùàÿ âåðñèÿ: '..thisScript().version..". Íîâàÿ âåðñèÿ: "..ver)
    wait(300)
    downloadUrlToFile("https://kscripts.ru/scripts/download.php?script=Farm Bot&src=true", thisScript().path, function(id, status, p1, p2)
    	if status == dlstatus.STATUS_ENDDOWNLOADDATA then
            thisScript():reload()
        end
    end)
end

function SCM(arg1)
	if not invisible.v then
		sampAddChatMessage("[Farm-bot]: {FFFFFF}"..arg1, 0xF1CB09)
	else print(arg1) end
end

function toSendGet(msg)
	return urlencode(u8:encode(msg, "CP1251"))
end

function urlencode(arg)
	return arg and string.gsub(string.gsub(string.gsub(arg, "\n", "\r\n"), "([^%w ])", function (arg)
		return string.format("%%%02X", string.byte(arg))
	end), " ", "+")
end

function char_to_hex(str)
    return string.format("%%%02X", string.byte(str))
end
  
function url_encode(str)
    local str = string.gsub(str, "\\", "\\")
    local str = string.gsub(str, "([^%w])", char_to_hex)
    return str
end

function theme1()
	local style = imgui.GetStyle()
	local Colors = style.Colors
    local ImVec4 = imgui.ImVec4
		    Colors[imgui.Col.Text] = ImVec4(0.80, 0.80, 0.83, 1.00)
		    Colors[imgui.Col.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
		    Colors[imgui.Col.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		    Colors[imgui.Col.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
		    Colors[imgui.Col.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
		    Colors[imgui.Col.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
		    Colors[imgui.Col.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		    Colors[imgui.Col.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.TitleBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
		    Colors[imgui.Col.TitleBgActive] = ImVec4(0.07, 0.07, 0.09, 1.00)
		    Colors[imgui.Col.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		    Colors[imgui.Col.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
		    Colors[imgui.Col.CheckMark] = ImVec4(0.80, 0.80, 0.83, 0.31)
		    Colors[imgui.Col.SliderGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
		    Colors[imgui.Col.SliderGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
		    Colors[imgui.Col.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
		    Colors[imgui.Col.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
		    Colors[imgui.Col.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
		    Colors[imgui.Col.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
		    Colors[imgui.Col.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
		    Colors[imgui.Col.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
		    Colors[imgui.Col.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
		    Colors[imgui.Col.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
		    Colors[imgui.Col.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		    Colors[imgui.Col.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
		    Colors[imgui.Col.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
		    Colors[imgui.Col.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
		    Colors[imgui.Col.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function theme2()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function theme3()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.FrameBg]                = ImVec4(0.48, 0.16, 0.16, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.48, 0.16, 0.16, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.88, 0.26, 0.24, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Button]                 = ImVec4(0.98, 0.26, 0.26, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.98, 0.06, 0.06, 1.00)
    colors[clr.Header]                 = ImVec4(0.98, 0.26, 0.26, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.98, 0.26, 0.26, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.98, 0.26, 0.26, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.75, 0.10, 0.10, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.75, 0.10, 0.10, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.98, 0.26, 0.26, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.98, 0.26, 0.26, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.98, 0.26, 0.26, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.98, 0.26, 0.26, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function theme4()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.FrameBg]                = ImVec4(0.16, 0.48, 0.42, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.48, 0.42, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    colors[clr.CheckMark]              = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.88, 0.77, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.98, 0.85, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.98, 0.82, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.98, 0.85, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.98, 0.85, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.98, 0.85, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.10, 0.75, 0.63, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.10, 0.75, 0.63, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.98, 0.85, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.98, 0.85, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.98, 0.85, 0.95)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.81, 0.35, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.98, 0.85, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end

function theme5()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
	style.Alpha = 1.0
	style.Colors[clr.Text] = ImVec4(1.000, 1.000, 1.000, 1.000)
	style.Colors[clr.TextDisabled] = ImVec4(0.000, 0.543, 0.983, 1.000)
	style.Colors[clr.WindowBg] = ImVec4(0.000, 0.000, 0.000, 0.895)
	style.Colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
	style.Colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	style.Colors[clr.Border] = ImVec4(0.184, 0.878, 0.000, 0.500)
	style.Colors[clr.BorderShadow] = ImVec4(1.00, 1.00, 1.00, 0.10)
	style.Colors[clr.TitleBg] = ImVec4(0.026, 0.597, 0.000, 1.000)
	style.Colors[clr.TitleBgCollapsed] = ImVec4(0.099, 0.315, 0.000, 0.000)
	style.Colors[clr.TitleBgActive] = ImVec4(0.026, 0.597, 0.000, 1.000)
	style.Colors[clr.MenuBarBg] = ImVec4(0.86, 0.86, 0.86, 1.00)
	style.Colors[clr.ScrollbarBg] = ImVec4(0.000, 0.000, 0.000, 0.801)
	style.Colors[clr.ScrollbarGrab] = ImVec4(0.238, 0.238, 0.238, 1.000)
	style.Colors[clr.ScrollbarGrabHovered] = ImVec4(0.238, 0.238, 0.238, 1.000)
	style.Colors[clr.ScrollbarGrabActive] = ImVec4(0.004, 0.381, 0.000, 1.000)
	style.Colors[clr.CheckMark] = ImVec4(0.009, 0.845, 0.000, 1.000)
	style.Colors[clr.SliderGrab] = ImVec4(0.139, 0.508, 0.000, 1.000)
	style.Colors[clr.SliderGrabActive] = ImVec4(0.139, 0.508, 0.000, 1.000)
	style.Colors[clr.Button] = ImVec4(0.000, 0.000, 0.000, 0.400)
	style.Colors[clr.ButtonHovered] = ImVec4(0.000, 0.619, 0.014, 1.000)
	style.Colors[clr.ButtonActive] = ImVec4(0.06, 0.53, 0.98, 1.00)
	style.Colors[clr.Header] = ImVec4(0.26, 0.59, 0.98, 0.31)
	style.Colors[clr.HeaderHovered] = ImVec4(0.26, 0.59, 0.98, 0.80)
	style.Colors[clr.HeaderActive] = ImVec4(0.26, 0.59, 0.98, 1.00)
	style.Colors[clr.ResizeGrip] = ImVec4(0.000, 1.000, 0.221, 0.597)
	style.Colors[clr.ResizeGripHovered] = ImVec4(0.26, 0.59, 0.98, 0.67)
	style.Colors[clr.ResizeGripActive] = ImVec4(0.26, 0.59, 0.98, 0.95)
	style.Colors[clr.PlotLines] = ImVec4(0.39, 0.39, 0.39, 1.00)
	style.Colors[clr.PlotLinesHovered] = ImVec4(1.00, 0.43, 0.35, 1.00)
	style.Colors[clr.PlotHistogram] = ImVec4(0.90, 0.70, 0.00, 1.00)
	style.Colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	style.Colors[clr.TextSelectedBg] = ImVec4(0.26, 0.59, 0.98, 0.35)
	style.Colors[clr.ModalWindowDarkening] = ImVec4(0.20, 0.20, 0.20, 0.35)

	style.ScrollbarSize = 16.0
	style.GrabMinSize = 8.0
	style.WindowRounding = 0.0

	style.AntiAliasedLines = true
end

function theme6()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	colors[clr.Text] = ImVec4(0.90, 0.90, 0.90, 1.00)
	colors[clr.TextDisabled] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.WindowBg] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ChildWindowBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
	colors[clr.Border] = ImVec4(0.80, 0.80, 0.83, 0.88)
	colors[clr.BorderShadow] = ImVec4(0.92, 0.91, 0.88, 0.00)
	colors[clr.FrameBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.FrameBgHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.FrameBgActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.TitleBg] = ImVec4(0.76, 0.31, 0.00, 1.00)
	colors[clr.TitleBgCollapsed] = ImVec4(1.00, 0.98, 0.95, 0.75)
	colors[clr.TitleBgActive] = ImVec4(0.80, 0.33, 0.00, 1.00)
	colors[clr.MenuBarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarBg] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ScrollbarGrab] = ImVec4(0.80, 0.80, 0.83, 0.31)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ScrollbarGrabActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ComboBg] = ImVec4(0.19, 0.18, 0.21, 1.00)
	colors[clr.CheckMark] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrab] = ImVec4(1.00, 0.42, 0.00, 0.53)
	colors[clr.SliderGrabActive] = ImVec4(1.00, 0.42, 0.00, 1.00)
	colors[clr.Button] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.ButtonHovered] = ImVec4(0.24, 0.23, 0.29, 1.00)
	colors[clr.ButtonActive] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.Header] = ImVec4(0.10, 0.09, 0.12, 1.00)
	colors[clr.HeaderHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.HeaderActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.ResizeGrip] = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.ResizeGripHovered] = ImVec4(0.56, 0.56, 0.58, 1.00)
	colors[clr.ResizeGripActive] = ImVec4(0.06, 0.05, 0.07, 1.00)
	colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
	colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
	colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
	colors[clr.PlotLines] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotLinesHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.PlotHistogram] = ImVec4(0.40, 0.39, 0.38, 0.63)
	colors[clr.PlotHistogramHovered] = ImVec4(0.25, 1.00, 0.00, 1.00)
	colors[clr.TextSelectedBg] = ImVec4(0.25, 1.00, 0.00, 0.43)
	colors[clr.ModalWindowDarkening] = ImVec4(1.00, 0.98, 0.95, 0.73)
end

function theme7()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    colors[clr.WindowBg]              = ImVec4(0.14, 0.12, 0.16, 1.00);
    colors[clr.ChildWindowBg]         = ImVec4(0.30, 0.20, 0.39, 0.00);
    colors[clr.PopupBg]               = ImVec4(0.05, 0.05, 0.10, 0.90);
    colors[clr.Border]                = ImVec4(0.89, 0.85, 0.92, 0.30);
    colors[clr.BorderShadow]          = ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[clr.FrameBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.FrameBgHovered]        = ImVec4(0.41, 0.19, 0.63, 0.68);
    colors[clr.FrameBgActive]         = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TitleBg]               = ImVec4(0.41, 0.19, 0.63, 0.45);
    colors[clr.TitleBgCollapsed]      = ImVec4(0.41, 0.19, 0.63, 0.35);
    colors[clr.TitleBgActive]         = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.MenuBarBg]             = ImVec4(0.30, 0.20, 0.39, 0.57);
    colors[clr.ScrollbarBg]           = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.ScrollbarGrab]         = ImVec4(0.41, 0.19, 0.63, 0.31);
    colors[clr.ScrollbarGrabHovered]  = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ScrollbarGrabActive]   = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ComboBg]               = ImVec4(0.30, 0.20, 0.39, 1.00);
    colors[clr.CheckMark]             = ImVec4(0.56, 0.61, 1.00, 1.00);
    colors[clr.SliderGrab]            = ImVec4(0.41, 0.19, 0.63, 0.24);
    colors[clr.SliderGrabActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.Button]                = ImVec4(0.41, 0.19, 0.63, 0.44);
    colors[clr.ButtonHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.ButtonActive]          = ImVec4(0.64, 0.33, 0.94, 1.00);
    colors[clr.Header]                = ImVec4(0.41, 0.19, 0.63, 0.76);
    colors[clr.HeaderHovered]         = ImVec4(0.41, 0.19, 0.63, 0.86);
    colors[clr.HeaderActive]          = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.ResizeGrip]            = ImVec4(0.41, 0.19, 0.63, 0.20);
    colors[clr.ResizeGripHovered]     = ImVec4(0.41, 0.19, 0.63, 0.78);
    colors[clr.ResizeGripActive]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.CloseButton]           = ImVec4(1.00, 1.00, 1.00, 0.75);
    colors[clr.CloseButtonHovered]    = ImVec4(0.88, 0.74, 1.00, 0.59);
    colors[clr.CloseButtonActive]     = ImVec4(0.88, 0.85, 0.92, 1.00);
    colors[clr.PlotLines]             = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotLinesHovered]      = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.PlotHistogram]         = ImVec4(0.89, 0.85, 0.92, 0.63);
    colors[clr.PlotHistogramHovered]  = ImVec4(0.41, 0.19, 0.63, 1.00);
    colors[clr.TextSelectedBg]        = ImVec4(0.41, 0.19, 0.63, 0.43);
	colors[clr.ModalWindowDarkening]  = ImVec4(0.20, 0.20, 0.20, 0.35);
end

function theme8()
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00)
    colors[clr.TextDisabled]           = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.ChildWindowBg]          = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.PopupBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.Border]                 = ImVec4(0.82, 0.77, 0.78, 1.00)
    colors[clr.BorderShadow]           = ImVec4(0.35, 0.35, 0.35, 0.66)
    colors[clr.FrameBg]                = ImVec4(1.00, 1.00, 1.00, 0.28)
    colors[clr.FrameBgHovered]         = ImVec4(0.68, 0.68, 0.68, 0.67)
    colors[clr.FrameBgActive]          = ImVec4(0.79, 0.73, 0.73, 0.62)
    colors[clr.TitleBg]                = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.46, 0.46, 0.46, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 1.00)
    colors[clr.MenuBarBg]              = ImVec4(0.00, 0.00, 0.00, 0.80)
    colors[clr.ScrollbarBg]            = ImVec4(0.00, 0.00, 0.00, 0.60)
    colors[clr.ScrollbarGrab]          = ImVec4(1.00, 1.00, 1.00, 0.87)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(1.00, 1.00, 1.00, 0.79)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.80, 0.50, 0.50, 0.40)
    colors[clr.ComboBg]                = ImVec4(0.24, 0.24, 0.24, 0.99)
    colors[clr.CheckMark]              = ImVec4(0.99, 0.99, 0.99, 0.52)
    colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.42)
    colors[clr.SliderGrabActive]       = ImVec4(0.76, 0.76, 0.76, 1.00)
    colors[clr.Button]                 = ImVec4(0.51, 0.51, 0.51, 0.60)
    colors[clr.ButtonHovered]          = ImVec4(0.68, 0.68, 0.68, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.67, 0.67, 0.67, 1.00)
    colors[clr.Header]                 = ImVec4(0.72, 0.72, 0.72, 0.54)
    colors[clr.HeaderHovered]          = ImVec4(0.92, 0.92, 0.95, 0.77)
    colors[clr.HeaderActive]           = ImVec4(0.82, 0.82, 0.82, 0.80)
    colors[clr.Separator]              = ImVec4(0.73, 0.73, 0.73, 1.00)
    colors[clr.SeparatorHovered]       = ImVec4(0.81, 0.81, 0.81, 1.00)
    colors[clr.SeparatorActive]        = ImVec4(0.74, 0.74, 0.74, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.80, 0.80, 0.80, 0.30)
    colors[clr.ResizeGripHovered]      = ImVec4(0.95, 0.95, 0.95, 0.60)
    colors[clr.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90)
    colors[clr.CloseButton]            = ImVec4(0.45, 0.45, 0.45, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.70, 0.70, 0.90, 0.60)
    colors[clr.CloseButtonActive]      = ImVec4(0.70, 0.70, 0.70, 1.00)
    colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextSelectedBg]         = ImVec4(1.00, 1.00, 1.00, 0.35)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.88, 0.88, 0.88, 0.35)
end

function easy_style()
	imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    style.WindowPadding = imgui.ImVec2(9, 14)
    style.WindowRounding = 10
    style.ChildWindowRounding = 10
    style.FramePadding = imgui.ImVec2(5, 3)
    style.FrameRounding = 6.0
    style.ItemSpacing = imgui.ImVec2(9.0, 3.0)
    style.ItemInnerSpacing = imgui.ImVec2(9.0, 3.0)
    style.IndentSpacing = 21
    style.ScrollbarSize = 6.0
    style.ScrollbarRounding = 13
    style.GrabMinSize = 17.0
    style.GrabRounding = 16.0

    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
end

function strong_style()
	imgui.SwitchContext()
    local style = imgui.GetStyle()

    style.WindowPadding = imgui.ImVec2(8, 8)
    style.WindowRounding = 2
    style.ChildWindowRounding = 2
    style.FramePadding = imgui.ImVec2(4, 3)
    style.FrameRounding = 2
    style.ItemSpacing = imgui.ImVec2(5, 4)
    style.ItemInnerSpacing = imgui.ImVec2(4, 4)
    style.IndentSpacing = 21
    style.ScrollbarSize = 13
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8
    style.GrabRounding = 1

    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
end

