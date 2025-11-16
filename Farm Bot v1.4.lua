script_name('Farm Bot Remastered')
script_author('kopnev')
script_version('1.3')
script_version_number(1.3)

local se = require 'samp.events'
local sampev   = require 'lib.samp.events'
local inicfg   = require 'inicfg'
local imgui   = require 'imgui'
local simgui = require 'mimgui'
local notf = import 'lib/imgui_notf.lua'
local imadd    = require 'imgui_addons'
local effil    = require 'effil'
local memory   = require 'memory'
local rkeys    = require 'rkeys'
local vkeys    = require 'vkeys'
local encoding = require('encoding')
encoding.default = 'CP1251'
u8 = encoding.UTF8
local fa = require 'fAwesome5'
local updateid
local ffi = require('ffi')
local json = require("dkjson")

ffi.cdef [[
    typedef int BOOL;
    typedef unsigned long HANDLE;
    typedef HANDLE HWND;
    typedef int bInvert;
 
    HWND GetActiveWindow(void);
    BOOL FlashWindow(HWND hWnd, BOOL bInvert);
    BOOL ShowWindow(HWND hWnd, BOOL bInvert);
]]

local control = {
    warningseytg = imgui.ImBool(false),
    telegramNotf = imgui.ImBool(false),
    reversal = imgui.ImBool(false),
    blinking = imgui.ImBool(false),
    autoExit = imgui.ImBool(false),
    autoOff = imgui.ImBool(true),
    skipdialog = imgui.ImBool(false),
    warningsey = imgui.ImBool(false),
    skip1 = imgui.ImInt(1250),
    skip2 = imgui.ImInt(1500),
    lowhp = imgui.ImBool(false),
    golodhelp = imgui.ImBool(false),
    tractorNotify = imgui.ImBool(false),
    zastryal = imgui.ImBool(false),
    flash = imgui.ImInt(1)   
}

local vars = {
    state = false,
    playing = false,
    recording = false,
    waitingTrailer = false,
    packetCount = 0,
    font = renderCreateFont('Hero', 14, 12),
    sendToRecord = false,
    lastVehicleSended = -1,
    imguiText = {},
    packetDelay = os.clock(),
    trailerDelay = os.clock(),
    packetSended = 0,
    dataToSend = '',
    fileName = '',
    trailerSync = false,
    incarData = {
        position = {
            x = -1, y = -1, z = -1
        },
        moveSpeed = {
            x = 0, y = 0, z = 0
        },
        quaternion = {
            x = 0, y = 0, z = 0, w = 0
        },
        keysData = 0,
        leftRightKeys = 0,
        upDownKeys = 0,
        bikeLean = 0,
        time = 0
    },
    playerData = {
        timer = os.clock()
    },
    route = {
        state = false,
        name = '',
        packets = 0,
        currentPos = {
            x = -1, y = -1, z = -1
        },
        trailerId = -1,
        count = 0
    }
}

local rpcs = {
    [26] = {'int16', 'bool'},
    [50] = {'int32', 'string'},
    [83] = {'int16'},
    [101] = {'int16', 'string'},
    [106] = {'int16', 'int32', 'int32', 'int8', 'int8'},
    [118] = {'int8'},
    [131] = {'int32'},
    [154] = {'int16'},
    [168] = {'int16', 'int16', 'int16', 'int16'},
    [177] = {'bool', 'int16', 'float', 'int32', 'int32'}
}
local lowhpsent = false
local tractorsent = false
local loop = simgui.new.bool(false)
local role_idx = imgui.ImInt(0)
local vip_idx = imgui.ImInt(0)
local accessory_idx = imgui.ImInt(0)
local crash = imgui.ImBool(false)
local main_windows_state = imgui.ImBool(false)
local quest_window = imgui.ImBool(false)
local settings_window = imgui.ImBool(false)
local loop_window = imgui.ImBool(false)
local changelog_window = imgui.ImBool(false)
local var_0_10 = imgui.ImBool(false) 
local var_0_11 = imgui.ImBool(false) 

local def = {
    settings = {
        theme = 7,
        style = 1,
        vkladka = 6,
        reload = false,
        reloadR = false,
        post = 0,
        limit = true,
        lim = 30,
        limit1 = true,
        lim1 = 4,
        mode = 0,
        limit2 = false,
        lim2 = 4,
        combineActive = false,
        autoupdate = false,
        autoeat = false,
        eatmethod = 0,
        runenabled = true, 
        jumpenabled = false,
        smoothcum = false,
        eatpercent = 20,
        auto = false,
        hidedialog = false,
        bg = false,
        helptext = true,
        autochange = false,
        changeafter = 0,
        invulnerability = false,
        infinitefuel = false,
        infinitefuelengine = false,
        collision = false,
        faedit = false,
        invisible = false,
        autofarmzov = false,
        activationCommand = 'farm',
        customCommand = 'custom',
        selectedRoute = 0,
        selectedAircraft = 0
    },
    Telegram = {
        chat_id = '',
        token = '',
        warningseytg = false
    },
    AntiAdmin = {
        skip11 = 1250,
        skip22 = 1500,
        telegramNotf = false,
        reversal = false,
        blinking = false,
        autoExit = false,
        autoOff = true,
        skipdialog = false,
        warningsey = false,
        lowhp = false,
        golodhelp = false,
        tractorNotify = false,
        zastryal = false,
        flash = 1
    },
    theme9 = {
        WindowBg_r = 0.96,
        WindowBg_g = 0.84,
        WindowBg_b = 0.89,
        WindowBg_a = 1.00,
        ChildWindowBg_r = 0.98,
        ChildWindowBg_g = 0.87,
        ChildWindowBg_b = 0.91,
        ChildWindowBg_a = 0.50,
        PopupBg_r = 0.80,
        PopupBg_g = 0.60,
        PopupBg_b = 0.73,
        PopupBg_a = 0.90,
        Border_r = 1.00,
        Border_g = 0.80,
        Border_b = 0.88,
        Border_a = 0.30,
        BorderShadow_r = 0.00,
        BorderShadow_g = 0.00,
        BorderShadow_b = 0.00,
        BorderShadow_a = 0.00,
        FrameBg_r = 0.95,
        FrameBg_g = 0.75,
        FrameBg_b = 0.85,
        FrameBg_a = 1.00,
        FrameBgHovered_r = 1.00,
        FrameBgHovered_g = 0.65,
        FrameBgHovered_b = 0.80,
        FrameBgHovered_a = 0.68,
        FrameBgActive_r = 1.00,
        FrameBgActive_g = 0.65,
        FrameBgActive_b = 0.80,
        FrameBgActive_a = 1.00,
        TitleBg_r = 0.90,
        TitleBg_g = 0.70,
        TitleBg_b = 0.80,
        TitleBg_a = 0.45,
        TitleBgCollapsed_r = 0.90,
        TitleBgCollapsed_g = 0.70,
        TitleBgCollapsed_b = 0.80,
        TitleBgCollapsed_a = 0.35,
        TitleBgActive_r = 0.90,
        TitleBgActive_g = 0.70,
        TitleBgActive_b = 0.80,
        TitleBgActive_a = 0.78,
        MenuBarBg_r = 0.95,
        MenuBarBg_g = 0.75,
        MenuBarBg_b = 0.85,
        MenuBarBg_a = 0.57,
        ScrollbarBg_r = 0.95,
        ScrollbarBg_g = 0.75,
        ScrollbarBg_b = 0.85,
        ScrollbarBg_a = 1.00,
        ScrollbarGrab_r = 0.85,
        ScrollbarGrab_g = 0.55,
        ScrollbarGrab_b = 0.75,
        ScrollbarGrab_a = 0.31,
        ScrollbarGrabHovered_r = 0.85,
        ScrollbarGrabHovered_g = 0.55,
        ScrollbarGrabHovered_b = 0.75,
        ScrollbarGrabHovered_a = 0.78,
        ScrollbarGrabActive_r = 0.85,
        ScrollbarGrabActive_g = 0.55,
        ScrollbarGrabActive_b = 0.75,
        ScrollbarGrabActive_a = 1.00,
        ComboBg_r = 0.95,
        ComboBg_g = 0.75,
        ComboBg_b = 0.85,
        ComboBg_a = 1.00,
        CheckMark_r = 1.00,
        CheckMark_g = 0.60,
        CheckMark_b = 0.80,
        CheckMark_a = 1.00,
        SliderGrab_r = 0.90,
        SliderGrab_g = 0.65,
        SliderGrab_b = 0.80,
        SliderGrab_a = 0.24,
        SliderGrabActive_r = 0.90,
        SliderGrabActive_g = 0.65,
        SliderGrabActive_b = 0.80,
        SliderGrabActive_a = 1.00,
        Button_r = 0.95,
        Button_g = 0.70,
        Button_b = 0.85,
        Button_a = 0.44,
        ButtonHovered_r = 0.95,
        ButtonHovered_g = 0.70,
        ButtonHovered_b = 0.85,
        ButtonHovered_a = 0.86,
        ButtonActive_r = 1.00,
        ButtonActive_g = 0.60,
        ButtonActive_b = 0.85,
        ButtonActive_a = 1.00,
        Header_r = 0.90,
        Header_g = 0.65,
        Header_b = 0.80,
        Header_a = 0.76,
        HeaderHovered_r = 0.90,
        HeaderHovered_g = 0.65,
        HeaderHovered_b = 0.80,
        HeaderHovered_a = 0.86,
        HeaderActive_r = 0.90,
        HeaderActive_g = 0.65,
        HeaderActive_b = 0.80,
        HeaderActive_a = 1.00,
        ResizeGrip_r = 0.95,
        ResizeGrip_g = 0.75,
        ResizeGrip_b = 0.85,
        ResizeGrip_a = 0.20,
        ResizeGripHovered_r = 0.95,
        ResizeGripHovered_g = 0.75,
        ResizeGripHovered_b = 0.85,
        ResizeGripHovered_a = 0.78,
        ResizeGripActive_r = 0.95,
        ResizeGripActive_g = 0.75,
        ResizeGripActive_b = 0.85,
        ResizeGripActive_a = 1.00,
        CloseButton_r = 1.00,
        CloseButton_g = 0.90,
        CloseButton_b = 0.95,
        CloseButton_a = 0.75,
        CloseButtonHovered_r = 1.00,
        CloseButtonHovered_g = 0.80,
        CloseButtonHovered_b = 0.90,
        CloseButtonHovered_a = 0.59,
        CloseButtonActive_r = 1.00,
        CloseButtonActive_g = 0.80,
        CloseButtonActive_b = 0.90,
        CloseButtonActive_a = 1.00,
        PlotLines_r = 1.00,
        PlotLines_g = 0.85,
        PlotLines_b = 0.90,
        PlotLines_a = 0.63,
        PlotLinesHovered_r = 1.00,
        PlotLinesHovered_g = 0.65,
        PlotLinesHovered_b = 0.80,
        PlotLinesHovered_a = 1.00,
        PlotHistogram_r = 1.00,
        PlotHistogram_g = 0.85,
        PlotHistogram_b = 0.90,
        PlotHistogram_a = 0.63,
        PlotHistogramHovered_r = 1.00,
        PlotHistogramHovered_g = 0.65,
        PlotHistogramHovered_b = 0.80,
        PlotHistogramHovered_a = 1.00,
        TextSelectedBg_r = 0.95,
        TextSelectedBg_g = 0.70,
        TextSelectedBg_b = 0.85,
        TextSelectedBg_a = 0.43,
        ModalWindowDarkening_r = 0.80,
        ModalWindowDarkening_g = 0.60,
        ModalWindowDarkening_b = 0.73,
        ModalWindowDarkening_a = 0.35,
        Text_r = 1.00,
        Text_g = 1.00,
        Text_b = 1.00,
        Text_a = 1.00
    }
}

local directIni = "KopnevScripts\\Farm Bot.ini"
local ini = inicfg.load(def, directIni)
local activationCommand = imgui.ImBuffer(ini.settings.activationCommand, 32)

buffer_token = imgui.ImBuffer(tostring(ini.Telegram.token or ''), 128)
buffer_chatid = imgui.ImBuffer(tostring(ini.Telegram.chat_id or ''), 128)
chat_id = ini.Telegram.chat_id
token = ini.Telegram.token
control.warningseytg = imgui.ImBool(ini.Telegram.warningseytg)
control.skip1 = imgui.ImInt(tonumber(ini.AntiAdmin.skip11) or 1250)
control.skip2 = imgui.ImInt(tonumber(ini.AntiAdmin.skip22) or 1500)
control.telegramNotf = imgui.ImBool(ini.AntiAdmin.telegramNotf)
control.reversal = imgui.ImBool(ini.AntiAdmin.reversal)
control.blinking = imgui.ImBool(ini.AntiAdmin.blinking)
control.autoExit = imgui.ImBool(ini.AntiAdmin.autoExit)
control.autoOff = imgui.ImBool(ini.AntiAdmin.autoOff)
control.skipdialog = imgui.ImBool(ini.AntiAdmin.skipdialog)
control.lowhp = imgui.ImBool(ini.AntiAdmin.lowhp)
control.golodhelp = imgui.ImBool(ini.AntiAdmin.golodhelp)
control.tractorNotify = imgui.ImBool(ini.AntiAdmin.tractorNotify)
control.zastryal = imgui.ImBool(ini.AntiAdmin.zastryal)
control.warningsey = imgui.ImBool(ini.AntiAdmin.warningsey)
control.flash = imgui.ImInt(tonumber(ini.AntiAdmin.flash) or 1)

local theme9_colors = {
    WindowBg = imgui.ImFloat4(ini.theme9.WindowBg_r or 0.96, ini.theme9.WindowBg_g or 0.84, ini.theme9.WindowBg_b or 0.89, ini.theme9.WindowBg_a or 1.00),
    ChildWindowBg = imgui.ImFloat4(ini.theme9.ChildWindowBg_r or 0.98, ini.theme9.ChildWindowBg_g or 0.87, ini.theme9.ChildWindowBg_b or 0.91, ini.theme9.ChildWindowBg_a or 0.50),
    Text = imgui.ImFloat4(ini.theme9.Text_r or 1.0, ini.theme9.Text_g or 1.0, ini.theme9.Text_b or 1.0, ini.theme9.Text_a or 1.0),
    PopupBg = imgui.ImFloat4(ini.theme9.PopupBg_r or 0.80, ini.theme9.PopupBg_g or 0.60, ini.theme9.PopupBg_b or 0.73, ini.theme9.PopupBg_a or 0.90),
    Border = imgui.ImFloat4(ini.theme9.Border_r or 1.00, ini.theme9.Border_g or 0.80, ini.theme9.Border_b or 0.88, ini.theme9.Border_a or 0.30),
    BorderShadow = imgui.ImFloat4(ini.theme9.BorderShadow_r or 0.00, ini.theme9.BorderShadow_g or 0.00, ini.theme9.BorderShadow_b or 0.00, ini.theme9.BorderShadow_a or 0.00),
    FrameBg = imgui.ImFloat4(ini.theme9.FrameBg_r or 0.95, ini.theme9.FrameBg_g or 0.75, ini.theme9.FrameBg_b or 0.85, ini.theme9.FrameBg_a or 1.00),
    FrameBgHovered = imgui.ImFloat4(ini.theme9.FrameBgHovered_r or 1.00, ini.theme9.FrameBgHovered_g or 0.65, ini.theme9.FrameBgHovered_b or 0.80, ini.theme9.FrameBgHovered_a or 0.68),
    FrameBgActive = imgui.ImFloat4(ini.theme9.FrameBgActive_r or 1.00, ini.theme9.FrameBgActive_g or 0.65, ini.theme9.FrameBgActive_b or 0.80, ini.theme9.FrameBgActive_a or 1.00),
    TitleBg = imgui.ImFloat4(ini.theme9.TitleBg_r or 0.90, ini.theme9.TitleBg_g or 0.70, ini.theme9.TitleBg_b or 0.80, ini.theme9.TitleBg_a or 0.45),
    TitleBgCollapsed = imgui.ImFloat4(ini.theme9.TitleBgCollapsed_r or 0.90, ini.theme9.TitleBgCollapsed_g or 0.70, ini.theme9.TitleBgCollapsed_b or 0.80, ini.theme9.TitleBgCollapsed_a or 0.35),
    TitleBgActive = imgui.ImFloat4(ini.theme9.TitleBgActive_r or 0.90, ini.theme9.TitleBgActive_g or 0.70, ini.theme9.TitleBgActive_b or 0.80, ini.theme9.TitleBgActive_a or 0.78),
    MenuBarBg = imgui.ImFloat4(ini.theme9.MenuBarBg_r or 0.95, ini.theme9.MenuBarBg_g or 0.75, ini.theme9.MenuBarBg_b or 0.85, ini.theme9.MenuBarBg_a or 0.57),
    ScrollbarBg = imgui.ImFloat4(ini.theme9.ScrollbarBg_r or 0.95, ini.theme9.ScrollbarBg_g or 0.75, ini.theme9.ScrollbarBg_b or 0.85, ini.theme9.ScrollbarBg_a or 1.00),
    ScrollbarGrab = imgui.ImFloat4(ini.theme9.ScrollbarGrab_r or 0.85, ini.theme9.ScrollbarGrab_g or 0.55, ini.theme9.ScrollbarGrab_b or 0.75, ini.theme9.ScrollbarGrab_a or 0.31),
    ScrollbarGrabHovered = imgui.ImFloat4(ini.theme9.ScrollbarGrabHovered_r or 0.85, ini.theme9.ScrollbarGrabHovered_g or 0.55, ini.theme9.ScrollbarGrabHovered_b or 0.75, ini.theme9.ScrollbarGrabHovered_a or 0.78),
    ScrollbarGrabActive = imgui.ImFloat4(ini.theme9.ScrollbarGrabActive_r or 0.85, ini.theme9.ScrollbarGrabActive_g or 0.55, ini.theme9.ScrollbarGrabActive_b or 0.75, ini.theme9.ScrollbarGrabActive_a or 1.00),
    ComboBg = imgui.ImFloat4(ini.theme9.ComboBg_r or 0.95, ini.theme9.ComboBg_g or 0.75, ini.theme9.ComboBg_b or 0.85, ini.theme9.ComboBg_a or 1.00),
    CheckMark = imgui.ImFloat4(ini.theme9.CheckMark_r or 1.00, ini.theme9.CheckMark_g or 0.60, ini.theme9.CheckMark_b or 0.80, ini.theme9.CheckMark_a or 1.00),
    SliderGrab = imgui.ImFloat4(ini.theme9.SliderGrab_r or 0.90, ini.theme9.SliderGrab_g or 0.65, ini.theme9.SliderGrab_b or 0.80, ini.theme9.SliderGrab_a or 0.24),
    SliderGrabActive = imgui.ImFloat4(ini.theme9.SliderGrabActive_r or 0.90, ini.theme9.SliderGrabActive_g or 0.65, ini.theme9.SliderGrabActive_b or 0.80, ini.theme9.SliderGrabActive_a or 1.00),
    Button = imgui.ImFloat4(ini.theme9.Button_r or 0.95, ini.theme9.Button_g or 0.70, ini.theme9.Button_b or 0.85, ini.theme9.Button_a or 0.44),
    ButtonHovered = imgui.ImFloat4(ini.theme9.ButtonHovered_r or 0.95, ini.theme9.ButtonHovered_g or 0.70, ini.theme9.ButtonHovered_b or 0.85, ini.theme9.ButtonHovered_a or 0.86),
    ButtonActive = imgui.ImFloat4(ini.theme9.ButtonActive_r or 1.00, ini.theme9.ButtonActive_g or 0.60, ini.theme9.ButtonActive_b or 0.85, ini.theme9.ButtonActive_a or 1.00),
    Header = imgui.ImFloat4(ini.theme9.Header_r or 0.90, ini.theme9.Header_g or 0.65, ini.theme9.Header_b or 0.80, ini.theme9.Header_a or 0.76),
    HeaderHovered = imgui.ImFloat4(ini.theme9.HeaderHovered_r or 0.90, ini.theme9.HeaderHovered_g or 0.65, ini.theme9.HeaderHovered_b or 0.80, ini.theme9.HeaderHovered_a or 0.86),
    HeaderActive = imgui.ImFloat4(ini.theme9.HeaderActive_r or 0.90, ini.theme9.HeaderActive_g or 0.65, ini.theme9.HeaderActive_b or 0.80, ini.theme9.HeaderActive_a or 1.00),
    ResizeGrip = imgui.ImFloat4(ini.theme9.ResizeGrip_r or 0.95, ini.theme9.ResizeGrip_g or 0.75, ini.theme9.ResizeGrip_b or 0.85, ini.theme9.ResizeGrip_a or 0.20),
    ResizeGripHovered = imgui.ImFloat4(ini.theme9.ResizeGripHovered_r or 0.95, ini.theme9.ResizeGripHovered_g or 0.75, ini.theme9.ResizeGripHovered_b or 0.85, ini.theme9.ResizeGripHovered_a or 0.78),
    ResizeGripActive = imgui.ImFloat4(ini.theme9.ResizeGripActive_r or 0.95, ini.theme9.ResizeGripActive_g or 0.75, ini.theme9.ResizeGripActive_b or 0.85, ini.theme9.ResizeGripActive_a or 1.00),
    CloseButton = imgui.ImFloat4(ini.theme9.CloseButton_r or 1.00, ini.theme9.CloseButton_g or 0.90, ini.theme9.CloseButton_b or 0.95, ini.theme9.CloseButton_a or 0.75),
    CloseButtonHovered = imgui.ImFloat4(ini.theme9.CloseButtonHovered_r or 1.00, ini.theme9.CloseButtonHovered_g or 0.80, ini.theme9.CloseButtonHovered_b or 0.90, ini.theme9.CloseButtonHovered_a or 0.59),
    CloseButtonActive = imgui.ImFloat4(ini.theme9.CloseButtonActive_r or 1.00, ini.theme9.CloseButtonActive_g or 0.80, ini.theme9.CloseButtonActive_b or 0.90, ini.theme9.CloseButtonActive_a or 1.00),
    PlotLines = imgui.ImFloat4(ini.theme9.PlotLines_r or 1.00, ini.theme9.PlotLines_g or 0.85, ini.theme9.PlotLines_b or 0.90, ini.theme9.PlotLines_a or 0.63),
    PlotLinesHovered = imgui.ImFloat4(ini.theme9.PlotLinesHovered_r or 1.00, ini.theme9.PlotLinesHovered_g or 0.65, ini.theme9.PlotLinesHovered_b or 0.80, ini.theme9.PlotLinesHovered_a or 1.00),
    PlotHistogram = imgui.ImFloat4(ini.theme9.PlotHistogram_r or 1.00, ini.theme9.PlotHistogram_g or 0.85, ini.theme9.PlotHistogram_b or 0.90, ini.theme9.PlotHistogram_a or 0.63),
    PlotHistogramHovered = imgui.ImFloat4(ini.theme9.PlotHistogramHovered_r or 1.00, ini.theme9.PlotHistogramHovered_g or 0.65, ini.theme9.PlotHistogramHovered_b or 0.80, ini.theme9.PlotHistogramHovered_a or 1.00),
    TextSelectedBg = imgui.ImFloat4(ini.theme9.TextSelectedBg_r or 0.95, ini.theme9.TextSelectedBg_g or 0.70, ini.theme9.TextSelectedBg_b or 0.85, ini.theme9.TextSelectedBg_a or 0.43),
    ModalWindowDarkening = imgui.ImFloat4(ini.theme9.ModalWindowDarkening_r or 0.80, ini.theme9.ModalWindowDarkening_g or 0.60, ini.theme9.ModalWindowDarkening_b or 0.73, ini.theme9.ModalWindowDarkening_a or 0.35)
    
}
local faedit = imgui.ImBool(ini.settings.faedit)
local faico = faedit.v
if faico then
    fa = require 'fAwesome5'
    fa_font = nil
    fa_glyph_ranges = imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
end 
local lastCheckpoint = nil
local calc_window = imgui.ImBool(false)
local runEnabled = imgui.ImBool(ini.settings.runenabled)
local jumpEnabled = imgui.ImBool(ini.settings.jumpenabled)
local smoothcumpenis228 = imgui.ImBool(ini.settings.smoothcum)
local autoupdate_checkbox = imgui.ImBool(ini.settings.autoupdate)
local var_collision = imgui.ImBool(ini.settings.collision or false)
local autofarmzov = imgui.ImBool(ini.settings.autofarmzov or false)
local style = imgui.ImInt(ini.settings.style)
local tema = imgui.ImInt(ini.settings.theme)
local post = imgui.ImInt(ini.settings.post)
local limit = imgui.ImBool(ini.settings.limit)
local lim = imgui.ImInt(ini.settings.lim)
local helptext = imgui.ImBool(ini.settings.helptext)
local limit1 = imgui.ImBool(ini.settings.limit1)
local lim1 = imgui.ImInt(ini.settings.lim1)
local autochange = imgui.ImBool(ini.settings.autochange)
local changeafter = imgui.ImInt(ini.settings.changeafter)
local invisible = imgui.ImBool(ini.settings.invisible)
local selectedRoute = imgui.ImInt(ini.settings.selectedRoute)
local auto = imgui.ImBool(ini.settings.auto)
local bg = imgui.ImBool(ini.settings.bg)
local theme9_window = imgui.ImBool(false)
local var_0_12 = imgui.ImBool(ini.settings.infinitefuelengine) 
local hidedildos = imgui.ImBool(ini.settings.hidedialog or false)
value1 = 0
work = false
work1 = false
work2 = false
work3 = false
ww = false
gopay = false
zdorov = false
gou = false
num = 0
gonew = false
paused = false
pipiska = true
yasel = false
sentkyky = false

local waitingForStatsTelegram = false
local findGameActive = false
local lowgolod = false
local findGameTimer = 0
local resendInterval = 5000
local waitingForStatsTelegram = false
local scenarioText = nil
local noCollisionObjects = {3276, 19300, 12756, 12918, 3374, 1333, 3594, 1332, 1333, 1334, 1331}
local var_0_5 = false
local turnRight = false
local turnLeft = false
local infengine = false
local walking = false
local state = false
local state_taked = false
local state_harvest = false
local wheat_dist = 1.5
local step = {200, 400}
local currentCameraAngle = 0
local lerpSpeed = 0.05
local currentQuest = 0
local maxQuests = 5
local questProgress = {0,0,0,0,0}
local questMax = {15,3,3,1,0}

local satiety
local autoeat = imgui.ImBool(ini.settings.autoeat)
local eatmethod = imgui.ImInt(ini.settings.eatmethod)
local eatpercent = imgui.ImInt(ini.settings.eatpercent)
local method = {
    u8("\xD7\xE8\xEF\xF1\xFB"),
    u8("\xD0\xFB\xE1\xE0"),
    u8("\xCE\xEB\xE5\xED\xE8\xED\xE0"),
    u8("\xCC\xE5\xF8\xEE\xEA\x20\xF1\x20\xEC\xFF\xF1\xEE\xEC"),
    u8("\xC5\xE4\xE0\x20\xF1\x20\xF5\xEE\xEB\xEE\xE4\xE8\xEB\xFC\xED\xE8\xEA\xE0"),
    u8("\xC5\xE4\xE0\x20\xF1\x20\xF1\xE5\xEC\xE5\xE9\xED\xEE\xE9\x20\xEA\xE2\xE0\xF0\xF2\xE8\xF0\xFB")
}

local vkladki = {
    false,
	false,
	false,
	false,
	false,
	false,
    false,
    false
}

vkladki[ini.settings.vkladka] = true

local items = {
	u8("\xD2\xB8\xEC\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xD1\xE8\xED\xE8\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xCA\xF0\xE0\xF1\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xC3\xEE\xEB\xF3\xE1\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xC7\xE5\xEB\xB8\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xCE\xF0\xE0\xED\xE6\xE5\xE2\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xD4\xE8\xEE\xEB\xE5\xF2\xEE\xE2\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
	u8("\xD2\xB8\xEC\xED\xEE\x2D\xF1\xE2\xE5\xF2\xEB\xE0\xFF\x20\xF2\xE5\xEC\xE0"),
    u8("\xCA\xE0\xF1\xF2\xEE\xEC\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0")
}

local styles = {
	u8("\xD1\xF2\xF0\xEE\xE3\xE8\xE9"),
	u8("\xCC\xFF\xE3\xEA\xE8\xE9")
}

local posts = {
	u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xFB\xE9\x20\xF4\xE5\xF0\xEC\xE5\xF0"),
	u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2"),
	u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0"),
    u8("\xC2\xEE\xE4\xE8\xF2\xE5\xEB\xFC\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0")
}

--------------------------------------------MAIN--------------------------------------------------
function goupdate(enable_autoupdate)
    gou = false
    if not enable_autoupdate then return end
    local autoupdate_loaded = false
    local Update = nil

    local updater_loaded, Updater = pcall(loadstring, [[return {
        check = function(json_url, prefix, fallback_url)
            local d = require('moonloader').download_status
            local e = os.tmpname()
            local f = os.clock()
            if doesFileExist(e) then os.remove(e) end
            downloadUrlToFile(json_url, e, function(g,h,i,j)
                if h == d.STATUSEX_ENDDOWNLOAD then
                    if doesFileExist(e) then
                        local k = io.open(e,'r')
                        if k then
                            local l = decodeJson(k:read('*a'))
                            local updatelink = l.updateurl
                            local updateversion = l.latest
                            k:close()
                            os.remove(e)
                            if updateversion ~= thisScript().version then
                                lua_thread.create(function()
                                    local m = -1
                                    SCM(prefix .. ("\xCE\xE1\xED\xE0\xF0\xF3\xE6\xE5\xED\xEE\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x2E\x20\xCF\xFB\xF2\xE0\xFE\xF1\xFC\x20\xEE\xE1\xED\xEE\xE2\xE8\xF2\xFC\xF1\xFF\x20\xF1\x20") .. thisScript().version .. ("\x20\xED\xE0\x20") .. updateversion, m)
                                    wait(250)
                                    downloadUrlToFile(updatelink, thisScript().path, function(n,o,p,q)
                                        if o == d.STATUS_DOWNLOADINGDATA then
                                            print(string.format(("\xC7\xE0\xE3\xF0\xF3\xE6\xE5\xED\xEE\x20\x25\x64\x20\xE8\xE7\x20\x25\x64\x2E"), p, q))
                                        elseif o == d.STATUS_ENDDOWNLOADDATA then
                                            print(("\xC7\xE0\xE3\xF0\xF3\xE7\xEA\xE0\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xFF\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xE0\x2E"))
                                            SCM(prefix .. ("\xCE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xEE\x21"), m)
                                            lua_thread.create(function() wait(500) thisScript():reload() end)
                                        end
                                    end)
                                end)
                            else
                                print(prefix .. ("\xCE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x20\xED\xE5\x20\xF2\xF0\xE5\xE1\xF3\xE5\xF2\xF1\xFF\x2E"))
                            end
                        end
                    end
                else
                    print(prefix .. ("\xCD\xE5\x20\xF3\xE4\xE0\xEB\xEE\xF1\xFC\x20\xEF\xF0\xEE\xE2\xE5\xF0\xE8\xF2\xFC\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x2E\x20\xCF\xF0\xEE\xE2\xE5\xF0\xFC\xF2\xE5\x20\xE2\xF0\xF3\xF7\xED\xF3\xFE\x3A\x20") .. fallback_url)
                end
            end)
        end
    }]])

    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/flupiflufi1/FarmbotRemastered/refs/heads/main/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/flupiflufi1/FarmbotRemastered"
        end
    end

    return autoupdate_loaded, Update
end
local enable_autoupdate = ini.settings.autoupdate
local autoupdate_loaded, Update = goupdate(enable_autoupdate)
function update()
    if not autoupdate_loaded and ini.settings.autoupdate then
        autoupdate_loaded, Update = goupdate(true)
    end
    if autoupdate_loaded and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    else
        SCM(("\xC0\xE2\xF2\xEE\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5\x20\xED\xE5\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\xEE\x2E"), -1)
    end
end

function main()
    math.randomseed(os.time())
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end
    getLastUpdate()
    hwin = ffi.C.GetActiveWindow()
    sampRegisterChatCommand("farm", function()
        main_windows_state.v = not main_windows_state.v
    end)
    lua_thread.create(warning)
    lua_thread.create(warning2)
    lua_thread.create(get_telegram_updates)

    sampRegisterChatCommand(ini.settings.customCommand, function()
        main_windows_state.v = not main_windows_state.v
    end)
    if doesFileExist(thisScript().path) then
		os.rename(thisScript().path, 'moonloader/Farm Bot v'..thisScript().version..'.lua')
	end
    if ini.settings.reload == true then
		SCM(("\xD3\xF1\xEF\xE5\xF8\xED\xEE\x20\xF1\xEE\xF5\xF0\xE0\xED\xE5\xED\xEE\x20\xE8\x20\xEF\xF0\xE8\xEC\xE5\xED\xE5\xED\xEE\x2E"))
		main_windows_state.v = true
		ini.settings.reload = false
		inicfg.save(def, directIni)
	end
    if ini.settings.reloadR == true then
		ini.settings.reloadR = false
		inicfg.save(def, directIni)
    end

    SCM(("\xD1\xEA\xF0\xE8\xEF\xF2\x20\xE7\xE0\xE3\xF0\xF3\xE6\xE5\xED\x2E\x20\xC0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xFF\x3A\x20\x7B\x46\x31\x43\x42\x30\x39\x7D\x2F\x66\x61\x72\x6D"))
    update()
    addEventHandler('onSendRpc', function(id, bs)
        if vars.state then
            local rpc = 'RPCS('..id..')'
            if id == 26 then
                local vehicleId = raknetBitStreamReadInt16(bs)
                local boolPassenger = raknetBitStreamReadBool(bs)
                local _, handle = sampGetCarHandleBySampVehicleId(vehicleId)
                if _ then
                    local model, color1, color2 = getCarModel(handle), getCarColours(handle)
                    vars.dataToSend = vars.dataToSend..(rpc..'['..vehicleId..'; '..(boolPassenger and '1' or '0')..'; '..model..']')..'\n'
                end
            elseif id == 83 then
                vars.dataToSend = vars.dataToSend..(rpc..'['..raknetBitStreamReadInt16(bs)..']')..'\n'
            elseif id == 50 or id == 101 then
                local trash = id == 101 and raknetBitStreamReadInt8(bs) or raknetBitStreamReadInt32(bs)
                vars.dataToSend = vars.dataToSend..(rpc..'['..raknetBitStreamReadString(bs, trash)..']')..'\n'
            elseif id == 118 then
                local interior = raknetBitStreamReadInt8(bs)
                vars.dataToSend = vars.dataToSend..(rpc..'['..interior..']')..'\n'
            elseif id == 131 then
                local pick = raknetBitStreamReadInt32(bs)
                vars.dataToSend = vars.dataToSend..(rpc..'['..pick..']')..'\n'
            elseif id == 154 then
                -- local vehicleId = raknetBitStreamReadInt16(bs)
                vars.dataToSend = vars.dataToSend..(rpc)..'\n'
            elseif id == 168 then
                local z, zov, svo, pasxalkoo = raknetBitStreamReadInt16(bs), raknetBitStreamReadInt16(bs), raknetBitStreamReadInt16(bs), raknetBitStreamReadInt16(bs)
                vars.dataToSend = vars.dataToSend..(rpc..'['..z..'; '..zov..'; '..svo..'; '..pasxalkoo..']')..'\n'
            end
        end
    end)
    addEventHandler('onReceiveRpc', function(id, bs)
        if vars.state then
            local rpc = 'RPCR('..id..')'
            if id == 26 then
                local vehicleId = raknetBitStreamReadInt16(bs)
                local boolPassenger = raknetBitStreamReadBool(bs)
                local _, handle = sampGetCarHandleBySampVehicleId(vehicleId)
                if _ then
                    local model, color1, color2 = getCarModel(handle), getCarColours(handle)
                    vars.dataToSend = vars.dataToSend..(rpc..'['..vehicleId..'; '..(boolPassenger and '1' or '0')..'; '..model..']')..'\n'
                end
            elseif id == 83 then
                vars.dataToSend = vars.dataToSend..(rpc..'['..raknetBitStreamReadInt16(bs)..']')..'\n'
            elseif id == 50 or id == 101 then
                local trash = id == 101 and raknetBitStreamReadInt8(bs) or raknetBitStreamReadInt32(bs)
                vars.dataToSend = vars.dataToSend..(rpc..'['..raknetBitStreamReadString(bs, trash)..']')..'\n'
            elseif id == 118 then
                local interior = raknetBitStreamReadInt8(bs)
                vars.dataToSend = vars.dataToSend..(rpc..'['..interior..']')..'\n'
            elseif id == 131 then
                local pick = raknetBitStreamReadInt32(bs)
                vars.dataToSend = vars.dataToSend..(rpc..'['..pick..']')..'\n'
            elseif id == 154 then
                -- local vehicleId = raknetBitStreamReadInt16(bs)
                vars.dataToSend = vars.dataToSend..(rpc)..'\n'
            elseif id == 168 then
                local z, zov, svo, pasxalkoo = raknetBitStreamReadInt16(bs), raknetBitStreamReadInt16(bs), raknetBitStreamReadInt16(bs), raknetBitStreamReadInt16(bs)
                vars.dataToSend = vars.dataToSend..(rpc..'['..z..'; '..zov..'; '..svo..'; '..pasxalkoo..']')..'\n'
            end
        end
    end)
    lua_thread.create(renderInfoBar)
    lua_thread.create(routePlayBack)
    X,Y = getScreenResolution()
    while true do
        wait(0)
        imgui.Process = main_windows_state.v or crash.v or quest_window.v

		if state then
			EngineWork()
		end
        if gou == true then
            goupdate()
        end
        if questActive then
            setGameKeyState(21, 255)
            wait(50)
            setGameKeyState(21, 0)
            wait(50)
        end
        if bg.v == true then
            WorkInBackground(true)
        else
            WorkInBackground(false)
        end
        if isCharInAnyCar(PLAYER_PED) then
            local vehicle = getCarCharIsUsing(PLAYER_PED)
            
            setCarProofs(vehicle, var_0_10.v, var_0_10.v, var_0_10.v, var_0_10.v, var_0_10.v)
            
            if var_0_11.v then
                setCarEngineOn(vehicle, true)
            end
            if var_0_12.v and infengine then
                var_0_11.v = true
            end
        end
        if ini.settings.collision ~= nil then
            toggleNoCollisionObjects(not ini.settings.collision)
        end
        if vars.state then
            if not isCharOnFoot(1) then
                vars.playerData.timer = os.clock()
            else
                vars.incarData.time = os.clock()
            end
        end
        if control.skipdialog.v then
            dialogskip = math.random(control.skip1.v, control.skip2.v)
        end 
        if satiety and autoeat.v then
            if satiety <= eatpercent.v then
                if eatmethod.v == 0 then
                    sampSendChat('/cheeps')
                    wait(3500)
                elseif eatmethod.v == 1 then
                    sampSendChat('/jfish')
                    wait(3500)
                elseif eatmethod.v == 2 then
                    sampSendChat('/jmeat')
                    wait(3500)
                elseif eatmethod.v == 3 then
                    sampSendChat('/meatbag')
                    wait(3500)
                elseif eatmethod.v == 4 then
                    sampSendChat('/home')
                    wait(900)
                    sampSendDialogResponse(7238, 1, 0, false)
                    wait(900)
                    sampSendDialogResponse(174, 1, 1, false)
                    wait(900)
                    sampSendDialogResponse(2431, 1, 2, false)
                    wait(900)
                    sampSendDialogResponse(185, 1, 6, false)
                    sampCloseCurrentDialogWithButton(0)
                elseif eatmethod.v == 5 then
                    EmulateKey(1024, false)
                    wait(100)
                    EmulateKey(1024, true)
                    wait(900)
                    sampSendDialogResponse(1825, 1, 6, false)
                end 
            end
        end
    end
end

local lower, sub, char, upper = string.lower, string.sub, string.char, string.upper
local concat = table.concat
local lu_rus, ul_rus = {}, {}
for i = 192, 223 do
    local A, a = char(i), char(i + 32)
    ul_rus[A] = a
    lu_rus[a] = A
end
local E, e = char(168), char(184)
ul_rus[E] = e
lu_rus[e] = E

function string.nlower(s)
    s = lower(s)
    local len, res = #s, {}
    for i = 1, len do
        local ch = sub(s, i, i)
        res[i] = ul_rus[ch] or ch
    end
    return concat(res)
end

function set_camera_direction(point)
	local c_pos_x, c_pos_y, c_pos_z = getActiveCameraCoordinates()
	local vect = {x = point[1] - c_pos_x, y = point[2] - c_pos_y, z = point[3] - c_pos_z}
	local ax = math.atan2(vect.y, -vect.x, vect.z)
    local pitch_offset
    if not state_harvest then
	    pitch_offset = -0.1
    else
        pitch_offset = 0
    end
	setCameraPositionUnfixed(pitch_offset, -ax)
end
function GetNearWheat(wheat)
    local table, dist
    for i, k in pairs(wheat) do
        if (not k.peds or (k.dist < wheat_dist and state_harvest)) and (table == nil or k.dist < dist) then
            table, dist = k, k.dist
        end
    end
    return table
end

function WalkEngine(bool)
    state_harvest = false
    setGameKeyState(1, -255)
    walking = bool
    if bool then
        if getCharSpeed(PLAYER_PED) > 4 and math.random(150) == 1 then
            setGameKeyState(16, runEnabled.v and 0)
            setGameKeyState(14, jumpEnabled.v and 255)
        else
            setGameKeyState(14, jumpEnabled.v and 0)
            setGameKeyState(16, runEnabled.v and 255)
        end
    end
end

function EngineWork()
    local x, y, z = getCharCoordinates(PLAYER_PED)

    if not state_taked then
        local wheat_list = {}
        for id = 0, 2047 do
            if sampIs3dTextDefined(id) then
                local str, col, x1, y1, z1 = sampGet3dTextInfoById(id)
                if str:find(("\xCA\xF3\xF1\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xE5")) then
                    table.insert(wheat_list, {
                        id = id,
                        x = x1, y = y1, z = z1,
                        peds = findAllRandomCharsInSphere(x1, y1, z1, 3, false, true),
                        dist = getDistanceBetweenCoords3d(x, y, z, x1, y1, z1)
                    })
                end
            end
        end

        if #wheat_list == 0 then return end
        local wheat = GetNearWheat(wheat_list)
        if not current_cam_angle then current_cam_angle = 0.0 end
        local target_angle = math.deg(math.atan2(wheat.y - y, wheat.x - x))
        local angle_diff = (target_angle - current_cam_angle + 180) % 360 - 180
        local smooth_factor
        if wheat.dist < 4.0 then
            smooth_factor = 1.0 
        else
            smooth_factor = 0.12 * (1 - math.exp(-wheat.dist / 20))
        end
        current_cam_angle = current_cam_angle + angle_diff * smooth_factor
        current_cam_angle = (current_cam_angle + 360) % 360
        local cam_dist = 1.0
        local camX = x + math.cos(math.rad(current_cam_angle)) * cam_dist
        local camY = y + math.sin(math.rad(current_cam_angle)) * cam_dist
        local camZ = z - 10.0
        if ini.settings.smoothcum then
            set_camera_direction({camX, camY, camZ})
        else
            setCameraPositionUnfixed(-0.3, math.rad(getHeadingFromVector2d(wheat.x-x, wheat.y-y))+4.7)
        end
        if wheat.dist > wheat_dist * 3 then
            WalkEngine(true)
        else
            WalkEngine(false)
        end
        if not state_harvest and sampGetPlayerAnimationId(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED))) == 163 then
            state_harvest = true
        end
    else
        local x1, y1, z1 = -105.60591125488, 100.61192321777, 3.1171875
        local dist = getDistanceBetweenCoords3d(x, y, z, x1, y1, z1)
        if dist > 1.5 then
            local target_angle = math.deg(math.atan2(y1 - y, x1 - x))
            local angle_diff = (target_angle - current_cam_angle + 180) % 360 - 180
            local smooth_factor = (dist < 2.0) and 1.0 or 0.12 * (1 - math.exp(-dist / 20))
            current_cam_angle = current_cam_angle + angle_diff * smooth_factor
            current_cam_angle = (current_cam_angle + 360) % 360

            local camX = x + math.cos(math.rad(current_cam_angle))
            local camY = y + math.sin(math.rad(current_cam_angle))
            local camZ = z - 10.0
            if ini.settings.smoothcum then
                set_camera_direction({camX, camY, camZ})
            else
                setCameraPositionUnfixed(-0.3, math.rad(getHeadingFromVector2d(x1-x, y1-y))+4.7)
            end
            WalkEngine(true)
        end
    end
end

lua_thread.create(function() 
	while true do
		wait(30)
		if isKeyDown(17) and isKeyDown(82) then 
			ini.settings.reloadR = true
			inicfg.save(def, directIni)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------Анти-Голод by Vetrayo---------------------------------------------------
------------------------------------------https://www.blast.hk/threads/212472/---------------------------------------------
----------------------------------------------------------------------------------------------------------------------
function EmulateKey(key, isDown)
    local data = samp_create_sync_data('player')
    if not isDown then
        data.keysData = data.keysData
    else
        data.keysData = key
    end
    data.send()
    return
end

function samp_create_sync_data(sync_type, copy_from_player)
    local ffi = require 'ffi'
    local sampfuncs = require 'sampfuncs'
    local raknet = require 'samp.raknet'
    require 'samp.synchronization'
    copy_from_player = copy_from_player or true
    local sync_traits = {
        player = {'PlayerSyncData', raknet.PACKET.PLAYER_SYNC, sampStorePlayerOnfootData},
        vehicle = {'VehicleSyncData', raknet.PACKET.VEHICLE_SYNC, sampStorePlayerIncarData},
        passenger = {'PassengerSyncData', raknet.PACKET.PASSENGER_SYNC, sampStorePlayerPassengerData},
        aim = {'AimSyncData', raknet.PACKET.AIM_SYNC, sampStorePlayerAimData},
        trailer = {'TrailerSyncData', raknet.PACKET.TRAILER_SYNC, sampStorePlayerTrailerData},
        unoccupied = {'UnoccupiedSyncData', raknet.PACKET.UNOCCUPIED_SYNC, nil},
        bullet = {'BulletSyncData', raknet.PACKET.BULLET_SYNC, nil},
        spectator = {'SpectatorSyncData', raknet.PACKET.SPECTATOR_SYNC, nil}
    }
    local sync_info = sync_traits[sync_type]
    local data_type = 'struct ' .. sync_info[1]
    local data = ffi.new(data_type, {})
    local raw_data_ptr = tonumber(ffi.cast('uintptr_t', ffi.new(data_type .. '*', data)))
    if copy_from_player then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id
            if copy_from_player == true then
                _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            else
                player_id = tonumber(copy_from_player)
            end
            copy_func(player_id, raw_data_ptr)
        end
    end
    local func_send = function()
        local bs = raknetNewBitStream()
        raknetBitStreamWriteInt8(bs, sync_info[2])
        raknetBitStreamWriteBuffer(bs, raw_data_ptr, ffi.sizeof(data))
        raknetSendBitStreamEx(bs, sampfuncs.HIGH_PRIORITY, sampfuncs.UNRELIABLE_SEQUENCED, 1)
        raknetDeleteBitStream(bs)
    end
    local mt = {
        __index = function(t, index)
            return data[index]
        end,
        __newindex = function(t, index, value)
            data[index] = value
        end
    }
    return setmetatable({send = func_send}, mt)
end
----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------PackedRedorder by xColorized---------------------------------------------------
------------------------------------------https://www.blast.hk/threads/217287/---------------------------------------------
----------------------------------------------------------------------------------------------------------------------
function emulRpc(rpcId, data, send)
    if rpcs[rpcId] then
        local need_data = rpcs[rpcId]
        local bs = raknetNewBitStream()
        if #need_data > 0 then
            if #data == #need_data then
                for i = 1, #need_data do
                    local dataType, insertData = need_data[i], data[i]
                    if dataType == 'int8' then raknetBitStreamWriteInt8(bs, insertData) elseif dataType == 'int16' then raknetBitStreamWriteInt16(bs, insertData)
                    elseif dataType == 'int32' then raknetBitStreamWriteInt32(bs, insertData) elseif dataType == 'bool' then raknetBitStreamWriteBool(bs, insertData)
                    elseif dataType == 'string' then raknetBitStreamWriteString(bs, insertData) elseif dataType == 'float' then raknetBitStreamWriteFloat(bs, insertData)
                    elseif dataType == 'encoded' then raknetBitStreamEncodeString(bs, insertData) end
                end
            end
        end
        if send then raknetSendRpc(rpcId, bs) else raknetEmulRpcReceiveBitStream(rpcId, bs) end
        raknetDeleteBitStream(bs)
        return true
    end
    return false
end

function createNewFile(directory, filename)
    if not doesFileExist(directory..'\\'..filename) then
        local file = io.open(directory..'\\'..filename, "w")
        if file == nil then
            local res = createDirectory(directory)
            if res then
                local file = io.open(directory..'\\'..filename, "w")
                file:write("")
                file:close()
            end
        else
            file:write("")
            file:close()
        end
        return true
    end
    return false
end

function sendIntoFile(directory, string)
    local file = io.open(directory, "w")
    file:write(string..'\n')
    file:close()
end

function msg(text)
    if invisible.v then
        print(text)
    else
        sampAddChatMessage('{ffffff}[{C71585}Packet Recorder{ffffff}]: ' .. text, -1)
    end
end

function sendPlayerSync(x, y, z, mx, my, mz, qx, qy, qz, qw, keys, lrk, udk, hp, ar, sk, sact, fDel, loop, lX, lY, fr, ti, reg, animId, flags)
    local data                  = samp_create_sync_data('player')
    data.position               = { tonumber(x), tonumber(y), tonumber(z) }
    data.moveSpeed              = { tonumber(mx), tonumber(my), tonumber(mz) }
    data.quaternion[0]          = tonumber(qx)
    data.quaternion[1]          = tonumber(qy)
    data.quaternion[2]          = tonumber(qz)
    data.quaternion[3]          = tonumber(qw)
    data.keysData               = tonumber(keys)
    data.leftRightKeys          = tonumber(lrk)
    data.upDownKeys             = tonumber(udk)
    data.health                 = getCharHealth(1)
    data.armor                  = getCharArmour(1)
    data.specialKey             = tonumber(sk)
    data.specialAction          = tonumber(sact)
    data.animation = {
                    frameDelta   = tonumber(fDel),
                    id           = tonumber(animId),
                    flags = {loop   = loop == '1',
                    lockX  = lX == '1',
                    lockY  = lY == '1',
                    freeze = fr == '1',
                    time   = tonumber(ti),
                    regular= reg == '1'}
    }
    data.animationId            = tonumber(animId)
    data.animationFlags         = tonumber(flags)
    data.send()
end

function sendIncarSync(x, y, z, mx, my, mz, qx, qy, qz, qw, keys, kkeys, upd, lean, trailer, tx, ty, tz, tmx, tmy, tmz, tqx, tqy, tqz, tqw, ttx, tty, ttz, trx, try, trz, tdx, tdy, tdz, tsx, tsy, tsz, unk)
    local data          = samp_create_sync_data('vehicle')
    data.position       = { tonumber(x), tonumber(y), tonumber(z) }
    data.moveSpeed      = { tonumber(mx), tonumber(my), tonumber(mz) }
    data.quaternion[0]  = tonumber(qx)
    data.quaternion[1]  = tonumber(qy)
    data.quaternion[2]  = tonumber(qz)
    data.quaternion[3]  = tonumber(qw)
    data.keysData       = tonumber(keys)
    data.leftRightKeys  = tonumber(kkeys)
    data.upDownKeys     = tonumber(upd)
    data.bikeLean       = tonumber(lean)
    if isCharInAnyCar(1) or vars.lastVehicleSended ~= -1 then
        data.vehicleId  = isCharInAnyCar(1) and select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1))) or vars.lastVehicleSended
    end
    if trailer then
        data.trailerId = trailer
        data.send()
        local sync = samp_create_sync_data('trailer')
        sync.trailerId = trailer
        sync.position = { tonumber(tx), tonumber(ty), tonumber(tz) }
        sync.moveSpeed = { tonumber(tmx), tonumber(tmy), tonumber(tmz) }
        sync.quaternion[0]  = tonumber(tqx)
        sync.quaternion[1]  = tonumber(tqy)
        sync.quaternion[2]  = tonumber(tqz)
        sync.quaternion[3]  = tonumber(tqw)
        sync.turnSpeed = { tonumber(ttx), tonumber(tty), tonumber(ttz) }
        sync.roll = { tonumber(trx), tonumber(try), tonumber(trz) }
        sync.direction = { tonumber(tdx), tonumber(tdy), tonumber(tdz) }
        sync.speed = { tonumber(tsx), tonumber(tsy), tonumber(tsz) }
        sync.unk = tonumber(unk)
        sync.send()
    else
        data.send()
    end
end

function getFilesInPath(path, ftype)
    assert(path, '"path" is required');
    assert(type(ftype) == 'table' or type(ftype) == 'string', '"ftype" must be a string or array of strings');
    local result = {};
    for _, thisType in ipairs(type(ftype) == 'table' and ftype or { ftype }) do
        local searchHandle, file = findFirstFile(path.."\\"..thisType);
        table.insert(result, file)
        while file do file = findNextFile(searchHandle) table.insert(result, file) end
    end
    return result;
end


function renderInfoBar()
    while true do wait(0)
        if vars.route.state then
            local name = string.gsub(vars.route.name, '%.route', '')
            printStringNow('I LOVE SAMPHACK. Marshryt: ~b~~h~~h~~h~  '..name..'~r~~h~~h~~h~~h~  ['..(vars.route.packets > 9999 and '9999+' or tostring(vars.route.packets))..']', 20)
        end
    end
end

local xx, yy, zz = 0, 0, 0

local odnotipnie_rpc = {83, 118, 131}

function routePlayBack()
    while true do wait(0)
        if vars.route.state and vars.route.name ~= '' then
            local filePath = getWorkingDirectory()..'\\PacketRecorder\\'..vars.route.name..'.route'
            printStringNow('Route playback checking: '..filePath, 2000)
            if doesFileExist(filePath) then
                local file = io.open(filePath, 'r')
                local r = file:read('*all')
                local stime = 50
                local px, py, pz = 1, 1, 1
                local q_x, q_y, q_z, q_w = 1, 1, 1, 1
                if isCharInAnyCar(1) then
                    freezeCarPosition(storeCarCharIsInNoSave(1), true)
                else
                    freezeCharPosition(1, true)
                end
                for line in r:gmatch('[^\r\n]+') do
                    local v = line
                    if not v or not (vars.route.state and vars.route.name ~= '') then break end
                    if v:find('Trailer') then
                        local r1, r2 = v:match("Vehicle(.*); Trailer(.*)")
                        local x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl = r1:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); (%S+); (%S+); (%S+); (%S+)%]')
                        -- if x == nil then
                        --     x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl = r1:match('%[%((%S+); (%S+); (%S+)%);%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); (%S+); (%S+); (%S+); (%S+)%]')
                        -- end
                        local tx, ty, tz, tmx, tmy, tmz, tqx, tqy, tqz, tqw, ttx, tty, ttz, trx, try, trz, tdx, tdy, tdz, tsx, tsy, tsz, unk, timer = r2:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); (%S+); (%S+)%]')
                        px, py, pz = x, y, z
                        q_x, q_y, q_z, q_w = qx, qy, qz, qw
                        stime = timer
                        if vars.route.trailerId ~= -1 then
                            local _, veh = sampGetCarHandleBySampVehicleId(vars.route.trailerId)
                            if _ then
                                vars.trailerSync = true
                                setCarCollision(veh, false)
                                local vehid = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1)))
                                sendIncarSync(x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl, vars.route.trailerId, tx, ty, tz, tmx, tmy, tmz, tmz, tqx, tqy, tqz, tqw, ttx, tty, ttz, trx, try, trz, tdx, tdy, tdz, tsx, tsy, tsz, unk)
                                if not isTrailerAttachedToCab(storeCarCharIsInNoSave(1), veh) then
                                    attachTrailerToCab(veh, storeCarCharIsInNoSave(1))
                                end
                            end
                        end
                    elseif v:find('Vehicle') and not v:find('Trailer') then
                        local x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl, timer = v:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); (%S+); (%S+); (%S+); (%S+); (%S+)%]')
                        q_x, q_y, q_z, q_w = qx, qy, qz, qw
                        px, py, pz = x, y, z
                        stime = timer
                        sendIncarSync(x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, bl)
                    elseif v:find('Player') then
                        local x, y, z, mx, my, mz, qx, qy, qz, qw, hp, arm, spAct, spKey, anLoop, anLX, anLY, anFR, anREG, anFD, anTime, animId, animFlags, kd, lrk, udk, timer = v:match('%[%((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+); (%S+)%); %((%S+); (%S+)%); (%S+); (%S+); %((%S+); (%S+); (%S+); (%S+); (%S+); (%S+); (%S+)%); %((%S+); (%S+)%); %((%S+); (%S+); (%S+)%); (%S+)%]')
                        --Player[(1802.3238525391; -1900.3594970703; 13.402159690857); (0.16341012716293; 0.025080824270844; 0); (0.95948499441147; 0; 0; 0.28175947070122); (100; 0); 0; 0; (0; 0; 0; 0; 1; 4; 0); (1224; 32772); (8; 0; 65408); 75.000000000273]
                        px, py, pz = x, y, z
                        q_x, q_y, q_z, q_w = qx, qy, qz, qw
                        stime = timer
                        sendPlayerSync(x, y, z, mx, my, mz, qx, qy, qz, qw, kd, lrk, udk, hp, arm, spKey, spAct, anFD, anLoop, anLX, anLY, anFR, anTime, anREG, animId, animFlags)
                    elseif v:find('Aim') then
                        local cm, fx, fy, fz, px, py, pz, aimz, cez, ws, ar = v:match('%[(%S+); %((%S+); (%S+); (%S+)%); %((%S+); (%S+); (%S+)%); (%S+); (%S+); (%S+); (%S+)%]')
                        stime = -1
                        local data = samp_create_sync_data('aim')
                        data.camMode = tonumber(cm)
                        data.camFront, data.camPos = { tonumber(fx), tonumber(fy), tonumber(fz) }, { tonumber(px), tonumber(py), tonumber(pz) }
                        data.aimZ = tonumber(aimz)
                        data.camExtZoom = tonumber(cez)
                        data.weaponState = tonumber(ws)
                        data.aspectRatio = tonumber(ar)
                        data.send()
                    elseif v:find('RPC') then
                        stime = -1
                        local send = v:find('RPCS')
                        local receive = v:find('RPCR')
                        if send then
                            local rpcId = tonumber(v:match('RPCS%((%S+)%)'))
                            local dataToSend = {}
                            if rpcId == 26 then
                                local vehid, passenger, model = v:match('RPCS%(%S+%)%[(%S+); (%S+); (%S+)%]')
                                vehid, passenger, model = tonumber(vehid), (passenger == '1'), tonumber(model)
                                local _, veh = sampGetCarHandleBySampVehicleId(vehid)
                                if _ then
                                    vars.lastVehicleSended = vehid
                                    dataToSend = {vehid, passenger}
                                    warpCharIntoCar(1, veh)
                                else
                                    local id = getClosestCarWithModel(model)
                                    if id ~= -1 then
                                        warpCharIntoCar(1, select(2, sampGetCarHandleBySampVehicleId(id)))
                                        vars.lastVehicleSended = id
                                        dataToSend = {vehid, passenger}
                                    else
                                        if isCharInAnyCar(1) then
                                            vars.lastVehicleSended = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1)))
                                            dataToSend = {vars.lastVehicleSended, false}
                                        else
                                            print('error with 26 rpc(sendEnterVehicle). Vehicle = nil!')
                                        end
                                    end
                                end
                            elseif rpcId == 50 or rpcId == 101 then
                                local msg = v:match('RPCS%(%S+%)%[(%S+)%]')
                                dataToSend = {msg:len(), msg}
                            elseif rpcId == 154 then
                                -- dataToSend = {tonumber(v:match('RPCS%(%S+%)%[(%S+)%]'))}
                                dataToSend = {vars.lastVehicleSended ~= -1 and vars.lastVehicleSended or (isCharInAnyCar(1) and select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1))) or -1)}
                                warpCharFromCarToCoord(1, vars.route.currentPos.x, vars.route.currentPos.y, vars.route.currentPos.z)
                            elseif rpcId == 168 then
                                local z, zov, svo, pasxalkoo = v:match('RPCS%(%S+%)%[(%S+); (%S+); (%S+); (%S+)%]')
                                dataToSend = {tonumber(z), tonumber(zov), tonumber(svo), tonumber(pasxalkoo)}
                            else
                                for k,vl in pairs(odnotipnie_rpc) do
                                    if rpcId == vl then
                                        dataToSend = {tonumber(v:match('RPCS%(%S+%)%[(%S+)%]'))}
                                        break
                                    end
                                end
                            end
                            emulRpc(rpcId, dataToSend, true)
                        elseif receive then
                            local rpcId = tonumber(v:match('RPCR%((%S+)%)'))
                            local dataToSend = {}
                            if rpcId == 26 then
                                local vehid, passenger, model = v:match('RPCR%(%S+%)%[(%S+); (%S+); (%S+)%]')
                                vehid, passenger, model = tonumber(vehid), (passenger == '1'), tonumber(model)
                                local _, veh = sampGetCarHandleBySampVehicleId(vehid)
                                if _ then
                                    vars.lastVehicleSended = vehid
                                    dataToSend = {vehid, passenger}
                                    warpCharIntoCar(1, veh)
                                else
                                    local id = getClosestCarWithModel(model)
                                    if id ~= -1 then
                                        warpCharIntoCar(1, select(2, sampGetCarHandleBySampVehicleId(id)))
                                        vars.lastVehicleSended = id
                                        dataToSend = {vehid, passenger}
                                    else
                                        if isCharInAnyCar(1) then
                                            vars.lastVehicleSended = select(2, sampGetVehicleIdByCarHandle(storeCarCharIsInNoSave(1)))
                                            dataToSend = {vars.lastVehicleSended, false}
                                        else
                                            print('error with 26 rpc(sendEnterVehicle). Vehicle = nil!')
                                        end
                                    end
                                end
                            elseif rpcId == 50 or rpcId == 101 then
                                local msg = v:match('RPCR%(%S+%)%[(%S+)%]')
                                dataToSend = {msg:len(), msg}
                            elseif rpcId == 154 then
                                -- dataToSend = {tonumber(v:match('RPCR%(%S+%)%[(%S+)%]'))}
                                dataToSend = {vars.lastVehicleSended ~= -1 and vars.lastVehicleSended or -1}
                                warpCharFromCarToCoord(1, vars.route.currentPos.x, vars.route.currentPos.y, vars.route.currentPos.z)
                            elseif rpcId == 168 then
                                local z, zov, svo, pasxalkoo = v:match('RPCR%(%S+%)%[(%S+); (%S+); (%S+); (%S+)%]')
                                dataToSend = {tonumber(z), tonumber(zov), tonumber(svo), tonumber(pasxalkoo)}
                            else
                                for k,vl in pairs(odnotipnie_rpc) do
                                    if rpcId == vl then
                                        dataToSend = {tonumber(v:match('RPCR%(%S+%)%[(%S+)%]'))}
                                        break
                                    end
                                end
                            end
                            emulRpc(rpcId, dataToSend, false)
                        end
                    end
                    vars.route.currentPos = {x = tonumber(px), y = tonumber(py), z = tonumber(pz)}
                    if isCharInAnyCar(1) then
                        setCarCoordinatesNoOffset(storeCarCharIsInNoSave(1), vars.route.currentPos.x, vars.route.currentPos.y, vars.route.currentPos.z)
                        setVehicleQuaternion(storeCarCharIsInNoSave(1), tonumber(q_y), tonumber(q_z), tonumber(q_w), -tonumber(q_x))
                    else
                        setCharCoordinatesNoOffset(1, vars.route.currentPos.x, vars.route.currentPos.y, vars.route.currentPos.z)
                        setCharQuaternion(1, tonumber(q_y), tonumber(q_z), tonumber(q_w), -tonumber(q_x))
                    end
                    vars.route.packets = vars.route.packets + 1
                    if stime ~= -1 then
                        wait(tonumber(stime))
                    end
                end
                if vars.trailerSync then
                    vars.trailerSync = false
                    local v = select(2, sampGetCarHandleBySampVehicleId(vars.route.trailerId))
                    if doesVehicleExist(v) then
                        setCarCollision(v, true)
                    end
                end
                vars.route.packets = 0
                if not loop[0] then
                    vars.route.state = false
                    vars.route.name = ''
                    vars.route.currentPos = { x = -1, y = -1, z = -1 }
                    if isCharInAnyCar(1) then
                        freezeCarPosition(storeCarCharIsInNoSave(1), false)
                    else
                        freezeCharPosition(1, false)
                    end
                    msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEF\xF0\xEE\xE8\xE3\xF0\xE0\xED"))
                end
            else
                msg(("\xC4\xE0\xED\xED\xEE\xE3\xEE\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0\x20\xED\xE5\x20\xF1\xF3\xF9\xE5\xF1\xF2\xE2\xF3\xE5\xF2"))
                vars.route.currentPos = { x = -1, y = -1, z = -1 }
                vars.route.state = false
                vars.route.packets = 0
                vars.route.name = ''
            end
        end
    end
end

function getClosestCarWithModel(model)
    local id, dist = -1, 9999
    for i = 0, 2000 do
        local z, v = sampGetCarHandleBySampVehicleId(i)
        if z then
            local my, car = {getCharCoordinates(1)}, {getCarCoordinates(v)}
            local distan = getDistanceBetweenCoords3d(my[1], my[2], my[3], car[1], car[2], car[3])
            if getCarModel(v) == model and distan < dist then
                dist = distan
                id = i
            end
        end
    end
    return id
end

function se.onShowDialog(id, style, title, button1, button2, text)
    title = '"'..title..'"'..'. id: '..id..', style: '..style--..', btn1: '..button1..', btn2: '..button2
    -- return {id, style, title, button1, button2, text}
end

function se.onSendAimSync(data)
    if vars.state and vars.recording then
        vars.packetCount = vars.packetCount + 1
        vars.dataToSend = vars.dataToSend..('Aim['..data.camMode..'; '..'('..data.camFront.x..'; '..data.camFront.y..'; '..data.camFront.z..'); ('..data.camPos.x..'; '..data.camPos.y..'; '..data.camPos.z..
        '); '..data.aimZ..'; '..data.camExtZoom..'; '..data.weaponState..'; '..data.aspectRatio..']')..'\n'
    end
    if vars.route.state then return false end
end

function se.onSendPlayerSync(data) 
    if vars.recording then
        local timer = (os.clock() - vars.playerData.timer) * 1000
        vars.dataToSend = vars.dataToSend..('Player[('..data.position.x..'; '..data.position.y..'; '..data.position.z..'); ('..data.moveSpeed.x..'; '..data.moveSpeed.y..'; '..data.moveSpeed.z..'); '..
        '('..data.quaternion[0]..'; '..data.quaternion[1]..'; '..data.quaternion[2]..'; '..data.quaternion[3]..'); ('..data.health..'; '..data.armor..'); '..data.specialAction..'; '..data.specialKey..'; '..
        '('..(data.animation.flags.loop and '1' or '0')..'; '..(data.animation.flags.lockX and '1' or '0')..'; '..(data.animation.flags.lockY and '1' or '0')..'; '..
        (data.animation.flags.freeze and '1' or '0')..'; '..(data.animation.flags.regular and '1' or '0')..'; '..data.animation.frameDelta..'; '..data.animation.flags.time..'); ('..data.animationId..'; '..
        data.animationFlags..'); ('..data.keysData..'; '..data.leftRightKeys..'; '..data.upDownKeys..'); '..timer..']')..'\n'
        vars.playerData.timer = os.clock()
        vars.packetDelay = os.clock()
        vars.packetCount = vars.packetCount + 1
        printStringNow('Packets created(Player): ~r~'..vars.packetCount, 1000)
    end
    if vars.route.state then return false end
    if walking then
        data.upDownKeys = 65408
    end
end

function se.onSendVehicleSync(data)
    if vars.recording then
        local timer = (os.clock() - vars.packetDelay) * 1000
        if data.trailerId == 0 then
            vars.dataToSend = vars.dataToSend..('Vehicle[('..data.position.x..'; '..data.position.y..'; '..data.position.z..'); ('..data.moveSpeed.x..'; '..data.moveSpeed.y..'; '..data.moveSpeed.z..'); '..
            '('..data.quaternion[0]..'; '..data.quaternion[1]..'; '..data.quaternion[2]..'; '..data.quaternion[3]..'); '..data.keysData..'; '..data.leftRightKeys..'; '..data.upDownKeys..'; '..data.bikeLean..'; '..timer..']')..'\n'
            -- vars.dataToSend = vars.dataToSend..encrypt(('Vehicle: pos: '..data.position.x..', '..data.position.y..', '..data.position.z..
            -- '. move: '..data.moveSpeed.x..', '..data.moveSpeed.y..', '..data.moveSpeed.z..'. quat: '..data.quaternion[0]..', '..data.quaternion[1]..
            -- ', '..data.quaternion[2]..', '..data.quaternion[3]..'. keysData: '..data.keysData..'. leftRightKeys: '..data.leftRightKeys..'. upDownKeys: '..
            -- data.upDownKeys..'. bikeLean: '..data.bikeLean..'. Heading: '..getCarHeading(storeCarCharIsInNoSave(1))..'. Time: '..timer), secret_key)..'\n'
            vars.packetCount = vars.packetCount + 1
            vars.packetDelay = os.clock()
            printStringNow('Packets created(Vehicle): ~r~'..vars.packetCount, 1000)
        else
            vars.incarData = {
                position = {
                    x = data.position.x, y = data.position.y, z = data.position.z
                },
                moveSpeed = {
                    x = data.moveSpeed.x, y = data.moveSpeed.y, z = data.moveSpeed.z
                },
                quaternion = {
                    x = data.quaternion[0], y = data.quaternion[1], z = data.quaternion[2], w = data.quaternion[3]
                },
                keysData = data.keysData,
                leftRightKeys = data.leftRightKeys,
                upDownKeys = data.upDownKeys,
                bikeLean = data.bikeLean,
                time = timer
            }
            vars.packetDelay = os.clock()
            vars.waitingTrailer = true
        end
    end
    if vars.route.state then return false end
    if turnLeft then
        data.leftRightKeys = 65408
    end
    if turnRight then
        data.leftRightKeys = 128
    end
end

function se.onSendTrailerSync(data)
    if vars.recording and vars.waitingTrailer then
        vars.dataToSend = vars.dataToSend..('Vehicle[('..vars.incarData.position.x..'; '..vars.incarData.position.y..'; '..vars.incarData.position.z..'); ('..vars.incarData.moveSpeed.x..'; '..vars.incarData.moveSpeed.y..'; '..vars.incarData.moveSpeed.z..'); '..
        '('..vars.incarData.quaternion.x..'; '..vars.incarData.quaternion.y..'; '..vars.incarData.quaternion.z..'; '..vars.incarData.quaternion.w..'); '..vars.incarData.keysData..'; '..vars.incarData.leftRightKeys..'; '..vars.incarData.upDownKeys..'; '..vars.incarData.bikeLean..']; '..
        'Trailer[('..data.position.x..'; '..data.position.y..'; '..data.position.z..'); ('..data.moveSpeed.x..'; '..data.moveSpeed.y..'; '..data.moveSpeed.z..'); '..'('..data.quaternion[0]..'; '..data.quaternion[1]..'; '..data.quaternion[2]..'; '..data.quaternion[3]..'); ('..
        data.turnSpeed.x..'; '..data.turnSpeed.y..'; '..data.turnSpeed.z..'); ('..data.roll.x..'; '..data.roll.y..'; '..data.roll.z..'); ('..data.direction.x..'; '..data.direction.y..'; '..data.direction.z..'); ('..data.speed.x..'; '..data.speed.y..'; '..data.speed.z..'); '..data.unk..'; '..vars.incarData.time..']')..'\n'

        -- vars.dataToSend = vars.dataToSend..encrypt(('Trailer: pos: '..vars.incarData.position.x..', '..vars.incarData.position.y..', '..vars.incarData.position.z..
        -- '. move: '..vars.incarData.moveSpeed.x..', '..vars.incarData.moveSpeed.y..', '..vars.incarData.moveSpeed.z..'. quat: '..vars.incarData.quaternion.x..', '..
        -- vars.incarData.quaternion.y..', '..vars.incarData.quaternion.z..', '..vars.incarData.quaternion.w..'. keysData: '..vars.incarData.keysData..'. leftRightKeys: '..vars.incarData.leftRightKeys..'. upDownKeys: '..
        -- vars.incarData.upDownKeys..'. bikeLean: '..vars.incarData.bikeLean..'. Heading: '..getCarHeading(storeCarCharIsInNoSave(1))..'. Time: '..vars.incarData.time)..'. Tpos: '..
        -- data.position.x..', '..data.position.y..', '..data.position.z..'. Tmove: '..data.moveSpeed.x..', '..data.moveSpeed.y..', '..data.moveSpeed.z..'. Tquat: '..
        -- data.quaternion[0]..', '..data.quaternion[1]..', '..data.quaternion[2]..', '..data.quaternion[3]..'. Tturn: '..data.turnSpeed.x..', '..data.turnSpeed.y..
        -- ', '..data.turnSpeed.z..'. Troll: '..data.roll.x..', '..data.roll.y..', '..data.roll.z..'. Tdir: '..data.direction.x..', '..data.direction.y..', '..data.direction.z..
        -- '. Tsp: '..data.speed.x..', '..data.speed.y..', '..data.speed.z..'. Tunk: '..data.unk, secret_key)..'\n'
        vars.packetCount = vars.packetCount + 1
        vars.waitingTrailer = false
        vars.incarData = {
            position = {
                x = -1, y = -1, z = -1
            },
            moveSpeed = {
                x = 0, y = 0, z = 0
            },
            quaternion = {
                x = 0, y = 0, z = 0, w = 0
            },
            keysData = 0,
            leftRightKeys = 0,
            upDownKeys = 0,
            bikeLean = 0,
            time = 0
        }
        printStringNow('Packets created(Trailer): ~r~'..vars.packetCount, 1000)
    end
    if vars.route.state then return false end
end
function drawCalculatorWindow()
    imgui.SetNextWindowSize(imgui.ImVec2(400, 300), imgui.Cond.FirstUseEver)
    imgui.SetNextWindowPos(
        imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2),
        imgui.Cond.FirstUseEver, 
        imgui.ImVec2(0.5, 0.5)
    )
    imgui.Begin(u8("\xCA\xE0\xEA\xF3\xEB\xFF\xF2\xEE\xF0\x20\xF4\xE5\xF0\xEC\xE5\xF0\xE0"), calc_window, 0)
    local combos = {
        {label = u8("\xC2\xFB\xE1\xEE\xF0\x20\xE4\xEE\xEB\xE6\xED\xEE\xF1\xF2\xE8"), idx = role_idx, options = { u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0"), u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2"), u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0"), u8("\xC2\xEE\xE4\xE8\xF2\xE5\xEB\xFC\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0") }, assign = function(v) selectedRole = v end},
        {label = u8("\xD3\x20\xE2\xE0\xF1\x20\xE5\xF1\xF2\xFC\x20\xE2\xE8\xEF\x3F"), idx = vip_idx, options = { u8("\xCD\xE5\xF2"), u8("\xC4\xE0") }, assign = function(v) hasVip = (v == 1) end},
        {label = u8("\xCC\xEE\xEB\xEE\xF2\x20\xE2\x20\xED\xE0\xEB\xE8\xF7\xE8\xE8\x3F"), idx = accessory_idx, options = { u8("\xCD\xE5\xF2"), u8("\xC4\xE0") }, assign = function(v) hasAxe = (v == 1) end},
    }
    for _, combo in ipairs(combos) do
        if imgui.Combo(combo.label, combo.idx, combo.options, -1) then
            combo.assign(combo.idx.v)
        end
    end
    if imgui.Button(u8("\xD0\xE0\xF7\xB8\xF2\xE0\xF2\xFC\x20\xF7\xEE\x20\xEF\xEE\x20\xEF\xEE\xEB\xF3\xF7\xE8\xF2\xF1\xFF"), imgui.ImVec2(180, 30)) then
        calculateScenario(selectedRole, hasVip, hasAxe)
    end
    if scenarioText ~= nil then
        imgui.TextWrapped(scenarioText)
    end
    if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(80, 25)) then
        calc_window.v = false
        scenarioText = nil
    end
    imgui.End()
end
-----------------------------------Самп евентс---------------------------------------

function onReceiveRpc(id, bs)
	if state then
		if id == 113 then
			local playerId = raknetBitStreamReadInt16(bs)
			local index = raknetBitStreamReadInt32(bs)
			local create = raknetBitStreamReadBool(bs)
			local model = raknetBitStreamReadInt32(bs)

			if not state_taked and select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) == playerId and model == 2901 then
				state_taked = true
                findGameActive = false
			end
		elseif id == 93 then
			local color = raknetBitStreamReadInt32(bs)
			local len = raknetBitStreamReadInt32(bs)
			local str = raknetBitStreamReadString(bs, len)

			if state_taked and str:find(("\x7B\x46\x46\x36\x33\x34\x37\x7D\x20\xD2\xE5\xEF\xE5\xF0\xFC\x20\xC2\xE0\xF8\x20\xED\xE0\xE2\xFB\xEA\x20\xF4\xE5\xF0\xEC\xE5\xF0\xF1\xF2\xE2\xE0")) then
				state_taked = false
			end
		end
	end
end

function sendCustomPacket(text)
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 18)
    raknetBitStreamWriteInt16(bs, #text)
    raknetBitStreamWriteString(bs, text)
    raknetBitStreamWriteInt32(bs, 0)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end
function sendPacket_220_1_128()
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 1)
    raknetBitStreamWriteInt8(bs, 128)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end
function sendPacket_220_1_0()
    local bs = raknetNewBitStream()
    raknetBitStreamWriteInt8(bs, 220)
    raknetBitStreamWriteInt8(bs, 1)
    raknetBitStreamWriteInt8(bs, 0)
    raknetSendBitStream(bs)
    raknetDeleteBitStream(bs)
end
local questsTakenByBot = true
function onReceivePacket(id, bs)
    if id == 220 then
        raknetBitStreamIgnoreBits(bs, 8)
        local packettype = raknetBitStreamReadInt8(bs)
        
        if packettype == 17 then
            raknetBitStreamIgnoreBits(bs, 32)
            local length = raknetBitStreamReadInt16(bs)
            local encoded = raknetBitStreamReadInt8(bs)
            local str = (encoded ~= 0) and raknetBitStreamDecodeString(bs, length + encoded) or raknetBitStreamReadString(bs, length)
            if autoeat.v or pipiska then
                local satietyMatch = str:match("event%.arizonahud%.playerSatiety', `%[(%d+)%]`")
                if satietyMatch then
                    satiety = tonumber(satietyMatch)
                end
            end
            if str:find([[window%.executeEvent%('event%.setActiveView', `%["FindGame"%]`%);]]) then
                findGameActive = true
                findGameTimer = os.clock()
            
                lua_thread.create(function ()
                    for i = 1, 5 do
                        math.randomseed(os.clock() ^ i)
                        wait(math.random(step[1], step[2]))
                        sendCustomPacket('findGame.Success')
                    end
                    sendCustomPacket('findGame.finish')
                end)
                return false
            else
                local countKeys = tonumber(str:match('"miniGameKeysCount":(%d+)'))
                if countKeys then
                    lua_thread.create(function()
                        for i = 1, countKeys do
                            math.randomseed(os.clock() ^ i)
                            wait(math.random(step[1], step[2]))
                            sendCustomPacket('miniGame.DebugKeyID|74|74|true')
                        end
                        sendCustomPacket('miniGame.keyReaction.finish|' .. countKeys)
                    end)
                    return false
                end
            end
        end
    elseif id == 33 then
        control.start = false
        control.step = 0
        if control.telegramNotf.v then
            sendTelegramNotification(("\xCF\xEE\xF2\xE5\xF0\xFF\xED\xEE\x20\xF1\xEE\xE5\xE4\xE8\xED\xE5\xED\xE8\xE5\x20\xF1\x20\xF1\xE5\xF0\xE2\xE5\xF0\xEE\xEC"))
        end
    elseif id == 32 then
        control.start = false
        control.step = 0
        if control.telegramNotf.v then
            sendTelegramNotification(("\xD1\xE5\xF0\xE2\xE5\xF0\x20\xE7\xE0\xEA\xF0\xFB\xEB\x20\xF1\xEE\xE5\xE4\xE8\xED\xE5\xED\xE8\xE5"))
        end
    end
end

function sampev.onSetPlayerHealth(hp)
    zdorov = false
end
local function getInNearestTractor()
    local myX, myY, myZ = getCharCoordinates(PLAYER_PED)
    local bestVeh = nil
    local bestDist = 99999
    local vehicles = getAllVehicles()

    for i = 1, #vehicles do
        local veh = vehicles[i]
        if doesVehicleExist(veh) then
            local model = getCarModel(veh)
            if model == 531 then
                local driver = getDriverOfCar(veh)
                if not driver or driver == -1 then
                    if not isCarInWater(veh) then
                        local vx, vy, vz = getCarCoordinates(veh)
                        local dist = getDistanceBetweenCoords3d(myX, myY, myZ, vx, vy, vz)
                        if dist < 40 and dist < bestDist then
                            bestDist = dist
                            bestVeh = veh
                        end
                    end
                end
            end
        end
    end

    if not bestVeh then
        print(("\x5B\xD4\xE5\xF0\xEC\xE0\x5D\x20\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xEE\xE2\x20\xED\xE5\xF2\x2C\x20\xE6\xE4\xF3\x20\x33\x20\xF1\xE5\xEA\x2E\x2E\x2E"))
        wait(3000)
        return getInNearestTractor()
    end

    local tx, ty, tz = getCarCoordinates(bestVeh)
    --print(("\x5E\x32\x5B\xD4\xE5\xF0\xEC\xE0\x5D\x20\xC1\xC5\xC3\xD3\x20\xCA\x20\xD2\xD0\xC0\xCA\xD2\xCE\xD0\xD3\x3A\x20\x5E\x33") .. string.format("%.1f", bestDist) .. ("\xEC\x20\x5E\x37\x28\x49\x44\x3A\x20") .. bestVeh .. ")")
    if isCharInAnyCar(PLAYER_PED) then
        local oldCar = getCarCharIsUsing(PLAYER_PED)
        --print(("\x5E\x33\x5B\xD4\xE5\xF0\xEC\xE0\x5D\x20\xC2\xFB\xF5\xEE\xE4\xE8\xEC\x20\xE8\xE7\x20\xF1\xF2\xE0\xF0\xEE\xE3\xEE\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0\x2E\x2E\x2E"))
        taskLeaveCar(PLAYER_PED, oldCar)
        repeat wait(0) until not isCharInAnyCar(PLAYER_PED)
        wait(800)
    end
    local walk_done = false
    lua_thread.create(function()
        while not walk_done do
            wait(0)       
            local x, y, z = getCharCoordinates(PLAYER_PED)
		 setCameraPositionUnfixed(-0.3, math.rad(getHeadingFromVector2d(tx-x, ty-y))+4.7)
            WalkEngine(true)
        end
    end)
    while true do
        wait(50)
        myX, myY, myZ = getCharCoordinates(PLAYER_PED)
        local distNow = getDistanceBetweenCoords3d(myX, myY, myZ, tx, ty, tz)
        if distNow < 2.4 then 
            walk_done = true
            break 
        end
        if not doesVehicleExist(bestVeh) then
            walk_done = true
            return getInNearestTractor()
        end
    end
    walk_done = true
    WalkEngine(false)
    wait(500)
    warpCharIntoCar(PLAYER_PED, bestVeh)
    local timer = os.clock()
    while not isCharInCar(PLAYER_PED, bestVeh) do
        wait(0)
        if os.clock() - timer > 6 then
            print(("\x5B\xD4\xE5\xF0\xEC\xE0\x5D\x20\xCD\xE5\x20\xF1\xE5\xEB\x20\x97\x20\xE8\xF9\xF3\x20\xED\xEE\xE2\xFB\xE9\x21"))
            return getInNearestTractor()
        end
    end
    yasel = true
    if control.tractorNotify.v then
        sendTelegramNotification(("\xEF\xEE\xEB\xE5\xF2\xE5\xEB\x20\xF4\xE0\xF0\xEC\xE8\xF2\xFC\x2E\x20\xD1\xE5\xEB\x20\xE2\x20\xED\xEE\xE2\xFB\xE9\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0"))
        tractorsent = true
    else
        tractorsent = false
        yasel = false
    end
    --print(("\xEF\xEE\xEB\xE5\xF2\xE5\xEB\x20\xF4\xE0\xF0\xEC\xE8\xF2\xFC"))
    wait(800)
    work1 = true
    gonew = false
    rideToTractor(-275.32684326172, -105.43254852295, 2.9767985343933, 60) 
    rideToTractor(-118.1747, 97.4916, 3.0650, 60) 
end

otvet = false
local answerWords = {("\xE2\xFB\x20\xF2\xF3\xF2\x3F"),("\xC2\xFB\x20\xF2\xF3\xF2\x3F")}

sampev.onServerMessage = function(color, text)
    if text:find(("\xE3\xEE\xE2\xEE\xF0\xE8\xF2")) then
        if control.warningseytg.v then
            sendTelegramNotification(("\xCF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE5\x20\xED\xE0\x20\xEE\xE1\xF9\xE5\xED\xE8\xE5\x3A\x20") .. text)
        end
        if control.warningsey.v then
            warn2 = true
        end
    end
    if text:find(("\xCD\xE5\xEE\xE1\xF5\xEE\xE4\xE8\xEC\xEE\x20\xE7\xE0\xEB\xE8\xF2\xFC\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE\x20\xE2\x20\xE4\xE0\xED\xED\xEE\xE5\x20\xF2\xF0\xE0\xED\xF1\xEF\xEE\xF0\xF2\xED\xEE\xE5\x20\xF1\xF0\xE5\xE4\xF1\xF2\xE2\xEE")) and (work1 or work2) then
        --SCM(("\xFF\xEA\xEE\xFB\xE1\x20\xE2\xEA\xEB\xFE\xF7\xE0\xE5\xEC"))
        infengine = true
        sendTelegramNotification(("\xE2\x20\xEC\xE0\xF8\xEE\xED\xEA\xE5\x20\xE7\xE0\xEA\xEE\xED\xF7\xE8\xEB\xEE\xF1\xFC\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE"))
    end
    if currentQuest == 0 and state and text:find(("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xE0\xED\xEE")) then
        questProgress[1] = math.min(15, (questProgress[1] or 0) + 1)
    end
    if currentQuest == 1 and work1 and text:find(("\xC2\xFB\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xEE\xF2\xF0\xE0\xE1\xEE\xF2\xE0\xEB\xE8\x2E")) then
        questProgress[2] = math.min(15, (questProgress[2] or 0) + 1)
    end
    if currentQuest == 2 and work2 and text:find(("\xC2\xFB\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xEE\xF2\xF0\xE0\xE1\xEE\xF2\xE0\xEB\xE8\x2E")) then
        questProgress[3] = math.min(15, (questProgress[3] or 0) + 1)
    end
    if currentQuest == 3 and work3 and text:find(("\xC2\xFB\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xEE\xF2\xF0\xE0\xE1\xEE\xF2\xE0\xEB\xE8\x2E")) then
        questProgress[4] = math.min(15, (questProgress[4] or 0) + 1)
    end
    if autofarmzov.v then
        if currentQuest >= maxQuests then
            --print(("\xC2\xF1\xE5\x20\xEA\xE2\xE5\xF1\xF2\xFB\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xFB\x2C\x20\xEE\xF1\xF2\xE0\xED\xE0\xE2\xEB\xE8\xE2\xE0\xE5\xEC\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
            autofarmzov.v = false
            questActive = false
            questsTakenByBot = false
            return
        end
        if text:find(("\xC4\xEB\xFF\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xE8\xFF\x20\xE7\xE0\xE4\xE0\xED\xE8\xFF")) then
            questActive = true
            currentQuest = currentQuest + 1
            --print(("\xCF\xF0\xE8\xED\xFF\xF2\xE8\xE5\x20\xEA\xE2\xE5\xF1\xF2\xEE\xE2\x20\xE0\xEA\xF2\xE8\xE2\xED\xEE\x2C\x20\xED\xE0\xF7\xE8\xED\xE0\xE5\xEC\x20\xF1\xEF\xE0\xEC\x20\x41\x6C\x74\x20\x28\xEA\xE2\xE5\xF1\xF2\x20\x23") .. currentQuest .. ")")
        elseif text:find(("\xE7\xE0\xE4\xE0\xED\xE8\xE9\x20\xEE\xF2\x20\xF4\xE5\xF0\xEC\xE5\xF0\xE0\x20\xC0\xED\xE0\xF2\xEE\xEB\xE8\xFF")) then
            questActive = false
            --print(("\xCF\xF0\xE8\xED\xFF\xF2\xE8\xE5\x20\xEA\xE2\xE5\xF1\xF2\xEE\xE2\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xEE\x2C\x20\xF1\xEF\xE0\xEC\x20\x41\x6C\x74\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
        elseif text:find(("\x25\x5B\xCE\xF8\xE8\xE1\xEA\xE0\x25\x5D\x20\x7B\x46\x46\x46\x46\x46\x46\x7D\xC8\xF1\xEF\xEE\xEB\xFC\xE7\xF3\xE9\xF2\xE5\x20\x2F\x71\x75\x65\x73\x74\x21")) then
            questActive = true
            currentQuest = currentQuest + 1
            --print(("\xCE\xF8\xE8\xE1\xEA\xE0\x3A\x20\xE8\xF1\xEF\xEE\xEB\xFC\xE7\xF3\xE9\xF2\xE5\x20\x2F\x71\x75\x65\x73\x74\x21\x20\xCF\xE5\xF0\xE5\xF5\xEE\xE4\xE8\xEC\x20\xEA\x20\xF1\xEB\xE5\xE4\xF3\xFE\xF9\xE5\xEC\xF3\x20\xEA\xE2\xE5\xF1\xF2\xF3\x20\x28\xEA\xE2\xE5\xF1\xF2\x20\x23") .. currentQuest .. ")")
        elseif text:find(("\xC2\xFB\x20\xF3\xE6\xE5\x20\xE2\xFB\xEF\xEE\xEB\xED\xFF\xEB\xE8\x20\xF3\x20\xEC\xE5\xED\xFF\x20\xFD\xF2\xEE\x20\xE7\xE0\xE4\xE0\xED\xE8\xE5\x21")) then
            questActive = true
            currentQuest = currentQuest + 1
            --print(("\xCA\xE2\xE5\xF1\xF2\x20\xF3\xE6\xE5\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\x2C\x20\xEF\xE5\xF0\xE5\xF5\xEE\xE4\xE8\xEC\x20\xEA\x20\xF1\xEB\xE5\xE4\xF3\xFE\xF9\xE5\xEC\xF3\x20\xEA\xE2\xE5\xF1\xF2\xF3\x20\x28\xEA\xE2\xE5\xF1\xF2\x20\x23") .. currentQuest .. ")")
        end
        if currentQuest >= maxQuests then
            --print(("\xC2\xF1\xE5\x20\xEA\xE2\xE5\xF1\xF2\xFB\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE5\xED\xFB\x2C\x20\xEE\xF1\xF2\xE0\xED\xE0\xE2\xEB\xE8\xE2\xE0\xE5\xEC\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
            questActive = false
            questsTakenByBot = false
        end
    end
    if (text:find(("\xE0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF2\xEE\xF0")) or text:find(("\xEE\xF2\xE2\xE5\xF2\xE8\xEB\x20\xE2\xE0\xEC")) or text:find(("\xC0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF2\xEE\xF0\x20\x28\x2E\x2B\x29\x20\xEE\xF2\xE2\xE5\xF2\xE8\xEB\x20\xE2\xE0\xEC\x25\x3A")) or text:find(("\x25\x28\x25\x28\x20\xC0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF2\xEE\xF0\x20\x28\x2E\x2B\x29\x25\x5B\x25\x64\x2B\x25\x5D\x25\x3A")) or text:find(("\x25\x28\x25\x28\x20\xE0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF2\xEE\xF0\x20\x2E\x2B\x25\x5B\x28\x25\x64\x2B\x29\x25\x5D\x25\x3A"))) and color ~= -2686721 then
        if control.autoOff.v then
            if state then
                state = false
                state_taked = false
                walking = false
                SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
            elseif work1 then
                work1 = false
                gopay = false
                gonew = false
            elseif work2 then
                work2 = false

            elseif work3 then
                work3 = false
                vars.route.state = false
                vars.route.name = ''
                vars.route.packets = 0
                vars.route.currentPos = { x = -1, y = -1, z = -1 }
                var_0_10.v = false
                if isCharInAnyCar(PLAYER_PED) then
                    freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                else
                    freezeCharPosition(PLAYER_PED, false)
                end
            end
        end
        if control.telegramNotf.v then
            sendTelegramNotification(("\xCF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE5\x20\xED\xE0\x20\xE0\xE4\xEC\xE8\xED\xE0\x3A\x20") .. text)
        end
        if control.reversal.v then
            ffi.C.ShowWindow(hwin, 3)
        end
        if control.blinking.v then
            if control.flash.v == 1 then
                warn = true
            end
            if control.flash.v == 2 then
                warn2 = true
            end
        end
        if control.autoExit.v then
            readMemory(0, 1)
            sendTelegramNotification(("\xCA\xF0\xE0\xF8\xED\xF3\xEB\x20\xE8\xE3\xF0\xF3"))
        end
    end
    local t = string.nlower(text:gsub('{......}', ''))
    for _, word in ipairs(answerWords) do
        if t:find(word)
        and not t:find(("\xE3\xEE\xE2\xEE\xF0\xE8\xF2"))
        and not t:find('vip')
        and not t:find('forever')
        and not t:find('admin')
        and not t:find('premium') then
            if ini.settings.auto then
                lua_thread.create(function()
                    if not otvet then
                        otvet = true
                        wait(math.random(2000, 3000))
                        sendPacket_220_1_128()
                        wait(500)
                        sendPacket_220_1_0()
                        sampSendChat(("\xC4\xE0"))
                        wait(math.random(1000, 5000))
                        otvet = false
                    end
                end)
            end
            break
        end
    end
    if control.lowhp.v then
        local health = getCharHealth(PLAYER_PED)
        if health <= 10 and not lowhpsent then
            sendTelegramNotification(("\xC1\xF0\xE0\xF2\x20\xF5\xEF\x20\xEC\xE0\xEB\xE0\x20\xEF\xEE\xEF\xEE\xEB\xED\xE8\x20\xEF\xE6"))
            lowhpsent = true
        else
            lowhpsent = false
        end
    end
    if text:find(("\xC2\xE0\xF8\x20\xF3\xF0\xEE\xE2\xE5\xED\xFC\x20\xF1\xFB\xF2\xEE\xF1\xF2\xE8\x20\xED\xE8\xE6\xE5")) then
        if control.golodhelp.v then
            if not lowgolod then
                sendTelegramNotification(("\xCC\xE0\xEB\xEE\x20\xE3\xEE\xEB\xEE\xE4\xE0\x20\xEF\xEE\xEA\xEE\xF0\xEC\xE8"))
                lowgolod = true
            else
                lowgolod = false
            end
        end
    end
    if work1 and text:find(("\xC2\xFB\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xEE\xF2\xF0\xE0\xE1\xEE\xF2\xE0\xEB\xE8\x2E")) then
        value1 = value1 + 1
        num = 0
        if ini.settings.autochange and value1 >= ini.settings.changeafter and not gopay then
            gonew = true
            --print(gonew)
            ww = true
            --print(("\x5E\x33\x5B\xD4\xE5\xF0\xEC\xE0\x5D\x20\xC4\xEE\xF1\xF2\xE8\xE3\xED\xF3\xF2\xEE\x20")..value1..("\x20\xEA\xF0\xF3\xE3\xEE\xE2\x20\x97\x20\xEC\xE5\xED\xFF\xE5\xEC\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\x21"))
            lua_thread.create(function()
                rideToTractor(-281.87548828125, -100.08025360107, 2.5294334888458, 50)
                ww = false
                getInNearestTractor()
            end)
            value1 = 0
        else
        ww = true 
        end
        if value1 >= ini.settings.lim1 and not ini.settings.limit1 and not gonew then
            gopay = true
            ww = true
            lua_thread.create(function()
                rideToTractor(-108.5108,119.1330,3.0700, 50)
                rideToTractor(-121.1731,85.7734,3.0719, 50)
                rideToTractor(-115.0045,79.7263,3.0729, 50)
                rideToTractor(-108.6299,76.0149,3.0727, 50)
                rideToTractor(-96.1733,75.8351,3.0727, 20)
                rideToTractor(-87.7826,74.0141,3.0721, 10)
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
                wait(2000)
                while true do
                    wait(150)
                    setGameKeyState(21, 255)
                    break
                end
            end)
        else
        ww = true 
        end
    end
    if work2 and text:find(("\xC2\xFB\x20\xF3\xF1\xEF\xE5\xF8\xED\xEE\x20\xEE\xF2\xF0\xE0\xE1\xEE\xF2\xE0\xEB\xE8\x2E")) then
        value1 = value1 + 1
        num = 0
    end
end

local function formatNumber(num)
    local formatted = tostring(num)
    while true do
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

sampev.onShowDialog = function(dialogId, style, title, button1, button2, text)
    if waitingForStatsTelegram and dialogId == 235 then
        waitingForStatsTelegram = false

        local money = text:match("%$([%d,]+)")
        if money then
            local cleanMoney = money:gsub(",", "")
            local formattedMoney = formatNumber(cleanMoney)
            sendTelegramNotification(("\xD3\x20\xF2\xE5\xE1\xFF\x20\x24") .. formattedMoney)
        else
            sendTelegramNotification(("\xCD\xE5\x20\xF3\xE4\xE0\xEB\xEE\xF1\xFC\x20\xED\xE0\xE9\xF2\xE8\x20\xF1\xF3\xEC\xEC\xF3\x20\xE4\xE5\xED\xE5\xE3\x2E"))
        end

        sampSendDialogResponse(dialogId, 0, 0, "")
        return false
    end
    if autofarmzov.v and questsTakenByBot then
        if dialogId == 7971 then
            sampSendDialogResponse(dialogId, 1, currentQuest, "")
            return false
        elseif dialogId == 7972 then
            sampSendDialogResponse(dialogId, 1, 65535, "")
            return false
        end
    end
    if hidedildos.v then
        if dialogId == 0 then
            if text:find(("\xC2\x20\xFD\xF2\xEE\xEC\x20\xEC\xE5\xF1\xF2\xE5")) or text:find(("\xCE\xF2\xEF\xF0\xE0\xE2\xEB\xFF\xE9\xF2\xE5\xF1\xFC\x20\xEF\xEE\x20\xF7\xE5\xEA\xEF\xEE\xE8\xED\xF2\xE0\xEC\x20\xE4\xEB\xFF\x20\xE2\xFB\xEF\xEE\xEB\xED\xE5\xED\xE8\xFF\x20\xF1\xE2\xEE\xE5\xE9\x20\xF0\xE0\xE1\xEE\xF2\xFB")) then
                return false
            end
        end
        if dialogId == 1234 then
            return false
        end
    end
    if dialogId == 15039 then
        if control.autoOff.v then
            if state then
                state = false
                state_taked = false
                walking = false
                SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
            elseif work1 then
                work1 = false
                gopay = false
                gonew = false
            elseif work2 then
                work2 = false

            elseif work3 then
                work3 = false
                vars.route.state = false
                vars.route.name = ''
                vars.route.packets = 0
                vars.route.currentPos = { x = -1, y = -1, z = -1 }
                var_0_10.v = false
                if isCharInAnyCar(PLAYER_PED) then
                    freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                else
                    freezeCharPosition(PLAYER_PED, false)
                end
            end
        end

        if control.skipdialog.v then
            lua_thread.create(function()
                wait(dialogskip)
                setVirtualKeyDown(27, true)
                wait(50)
                setVirtualKeyDown(27, false)
            end)
        end
        if control.telegramNotf.v then
            sendTelegramNotification(("\xCF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE5\x20\xED\xE0\x20\xE0\xE4\xEC\xE8\xED\xE0\x3A\x20") .. text)
        end
        if control.reversal.v then
            ffi.C.ShowWindow(hwin, 3)
        end
        if control.blinking.v then
            if control.flash.v == 1 then
                warn = true
            end
            if control.flash.v == 2 then
                warn2 = true
            end
        end
        if control.autoExit.v then
            readMemory(0, 1)
            sendTelegramNotification(("\xCA\xF0\xE0\xF8\xED\xF3\xEB\x20\xE8\xE3\xF0\xF3"))
        end
    end
end

function sampev.onSetRaceCheckpoint(type, pos)
    lastCheckpoint = {x = pos.x, y = pos.y, z = pos.z}
    --print("[CP] work1:", work1, "gopay:", gopay, "gonew:", gonew, "num:", num)
    if work1 and not (gopay or gonew) then
        num = num + 1
        lua_thread.create(function() 
            if num == 70 then 
                rideToTractor(-119.7002, 84.2271, 3.0719, 60) 
                rideToTractor(pos.x,pos.y,pos.z, 60)
            else
                rideToTractor(pos.x,pos.y,pos.z, 60) 
            end 
        end)
    end
    if control.zastryal.v then
        if work1 or work2 then
            lua_thread.create(function() 
                if num == num then 
                    wait(20000)
                    sentkyky = true
                end 
            end)
            if sentkyky then
                sendTelegramNotification(("\xCA\xE0\xE6\xE5\xF2\xF1\xFF\x20\xE1\xEE\xF2\x20\xE7\xE0\xF1\xF2\xF0\xFF\xEB\x2E"))
                sentkyky = false
            end
        end
    end
    if work2 then
        num = num + 1
        --sampAddChatMessage(("\xE5\xF2\xEE\xF2\x20\xF7\xE5\xEA\xEF\xEE\xE8\xED\xF2\x20\xED\xEE\xEC\xE5\xF0\x3A\x20") .. num, -1)
        lua_thread.create(function()
            if num == 19 then
                rideToCombine(-121.4095, -123.5240, 4.0606, 60, 3.0)
                rideToCombine(pos.x, pos.y, pos.z, 60, 1.2)
            elseif num == 28 then
                rideToCombine(24.9672, -26.8587, 4.0216, 60, 3.0)
                rideToCombine(pos.x, pos.y, pos.z, 60, 1.2)
            elseif num == 38 then
                rideToCombine(55.4785, 53.3833, 2.2682, 60, 3.0)
                rideToCombine(pos.x, pos.y, pos.z, 60, 1.2)
            elseif num == 40 then
                rideToCombine(-7.5333, 30.1100, 4.0611, 60, 3.0)
                rideToCombine(pos.x, pos.y, pos.z, 60, 1.2)
            elseif num == 41 then
                rideToCombine(-34.6055, 8.3665, 4.0636, 60, 3.0)
                rideToCombine(pos.x, pos.y, pos.z, 60, 1.2)
            elseif value1 > 0 and num == 1 then
                ww = true
                rideToCombine(-69.6392 ,25.7182, 4.0604, 60, 3.0)
                rideToCombine(-78.4467, 29.7232, 4.0623, 60, 3.0)
                rideToCombine(-94.5337, 38.7752, 4.0630, 60, 3.0)
                rideToCombine(-114.7506, 19.9177, 4.0578, 60, 3.0)
                rideToCombine(-120.0644, 4.8134, 4.0575, 60, 3.0)
                rideToCombine(-130.6800, -43.2168, 4.0672, 60, 3.0)
                rideToCombine(-150.7212, -76.3725, 4.0549, 60, 3.0)
                rideToCombine(-164.0034, -109.4677, 4.0785, 60, 3.0)
                rideToCombine(-179.5366, -117.1296, 4.0603, 60, 3.0)
                rideToCombine(-185.1780, -84.2181, 4.0672, 45)
            else
                rideToCombine(pos.x, pos.y, pos.z, 60, 1.2)
            end
        end)
    end
end
-- -118.17479705811   97.49169921875   3.0650999546051
------------------------------------------------------------------------------------------------------------------

--------------------------------------https://blast.hk/threads/31640/-------------------------------------------

-----------------------------------------------------------------------------------------------------------

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
    if faico then imgui.TextDisabled(fa.ICON_FA_QUESTION_CIRCLE) else imgui.TextDisabled(u8("\x28\xD1\x29")) end
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
    if not texture then
        local path = 'moonloader/resource/background.png'
        if doesFileExist(path) then
            local success, tex = pcall(function()
                return imgui.CreateTextureFromFile(path)
            end)
            if success and tex then
                texture = tex
            else
                sampAddChatMessage(("\xCE\xF8\xE8\xE1\xEA\xE0\x20\xE7\xE0\xE3\xF0\xF3\xE7\xEA\xE8\x20\x62\x61\x63\x6B\x67\x72\x6F\x75\x6E\x64\x2E\x70\x6E\x67"), -1)
                texture = nil
            end
        else
            texture = nil
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
    if ini.settings.theme == 8 then theme9() end
    if main_windows_state.v then
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(760, 380), imgui.Cond.FirstUseEver)
        imgui.Begin(thisScript().name..' | version '..thisScript().version, main_windows_state, 2)
        local win_pos = imgui.GetWindowPos()
        local win_size = imgui.GetWindowSize()
        if texture and ini.settings.theme == 8 then
            local draw_list = imgui.GetWindowDrawList()
            local uv0 = imgui.ImVec2(0, 0)
            local uv1 = imgui.ImVec2(1, 1)
            local color = 0xFFFFFFFF
            
            local bottom_offset = 0
            if ini.settings.style == 1 then
                bottom_offset = 4
            end

            draw_list:AddImage(
                texture,
                imgui.ImVec2(win_pos.x, win_pos.y),
                imgui.ImVec2(win_pos.x + win_size.x, win_pos.y + win_size.y - bottom_offset),
                uv0,
                uv1,
                color
            )
        end
        imgui.BeginChild('left pane', imgui.ImVec2(150, 0), true)
            if faico then 
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xE1\xEE\xF2\xE0\x20\x20")..fa.ICON_FA_ROBOT, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[1] = true
                    ini.settings.vkladka = 1
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC0\xED\xF2\xE8\x2D\xE3\xEE\xEB\xEE\xE4\x20\x20")..fa.ICON_FA_UTENSILS, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[2] = true
                    ini.settings.vkladka = 2
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC4\xEE\xEF\x2E\x20\xF4\xF3\xED\xEA\xF6\xE8\xE8\x20\x20")..fa.ICON_FA_INFO, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[3] = true
                    ini.settings.vkladka = 3
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xE0\x20\x20")..fa.ICON_FA_PLANE, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[4] = true
                    ini.settings.vkladka = 4
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Telegram  "..fa.ICON_FA_PAPER_PLANE, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[5] = true
                    ini.settings.vkladka = 5
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"AntiAdmin  "..fa.ICON_FA_USER_SLASH, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[6] = true
                    ini.settings.vkladka = 6
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\x20")..fa.ICON_FA_COGS, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[7] = true
                    ini.settings.vkladka = 7
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x20\x20")..fa.ICON_FA_INFO_CIRCLE, imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[8] = true
                    ini.settings.vkladka = 8
                    inicfg.save(def, directIni)
                end
            else
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xE1\xEE\xF2\xE0\x20\x20"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[1] = true
                    ini.settings.vkladka = 1
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC0\xED\xF2\xE8\x2D\xE3\xEE\xEB\xEE\xE4\x20\x20"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[2] = true
                    ini.settings.vkladka = 2
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC4\xEE\xEF\x2E\x20\xF4\xF3\xED\xEA\xF6\xE8\xE8\x20\x20"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[3] = true
                    ini.settings.vkladka = 3
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xE0"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[4] = true
                    ini.settings.vkladka = 4
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"Telegram", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[5] = true
                    ini.settings.vkladka = 5
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8"AntiAdmin", imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[6] = true
                    ini.settings.vkladka = 6
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\x20"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[7] = true
                    ini.settings.vkladka = 7
                    inicfg.save(def, directIni)
                end
                if imgui.Button(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF"), imgui.ImVec2(133, 35)) then
                    uu()
                    vkladki[8] = true
                    ini.settings.vkladka = 8
                    inicfg.save(def, directIni)
                end
            end
        imgui.EndChild()
        imgui.SameLine()

        if vkladki[1] == true then -- Настройки бота
			imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xE1\xEE\xF2\xE0\x20")..fa.ICON_FA_ROBOT) else imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xE1\xEE\xF2\xE0")) end
			imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(30) imgui.Text(u8("\xC2\xFB\xE1\xEE\xF0\x20\xE4\xEE\xEB\xE6\xED\xEE\xF1\xF2\xE8\x3A")) imgui.SameLine(140)
            imgui.PushItemWidth(250)
			if imgui.Combo('##dl', post, posts, -1)then
				ini.settings.post = post.v
				inicfg.save(def, directIni)
            end imgui.PopItemWidth()
            imgui.NewLine() imgui.Separator() imgui.NewLine() 
            imgui.NewLine()
            if ini.settings.post == 0 then -- Начальный фермер
                imgui.SameLine() imgui.Text(u8("\xC2\xEA\xEB\x2F\xE2\xFB\xEA\xEB\x20\xE1\xE5\xE3\x3A")) imgui.SameLine(95) 
                if imadd.ToggleButton('##runenabled', runEnabled) then
                    ini.settings.runenabled = runEnabled.v
                    inicfg.save(def, directIni)
                    if runEnabled.v then
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xE5\xE3\x20\x7B\x35\x35\x46\x46\x30\x30\x7D\xE2\xEA\xEB\xFE\xF7\xE5\xED"))
                    else
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xE5\xE3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED"))
                    end
                end
                imgui.SameLine(140) imgui.Text(u8("\xC2\xEA\xEB\x2F\xE2\xFB\xEA\xEB\x20\xEF\xF0\xFB\xE6\xEE\xEA\x3A")) imgui.SameLine(255) 
                if imadd.ToggleButton('##jumpenabled', jumpEnabled) then
                    ini.settings.jumpenabled = jumpEnabled.v
                    inicfg.save(def, directIni)
                    if jumpEnabled.v then
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xCF\xF0\xFB\xE6\xEE\xEA\x20\x7B\x35\x35\x46\x46\x30\x30\x7D\xE2\xEA\xEB\xFE\xF7\xE5\xED"))
                    else
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xCF\xF0\xFB\xE6\xEE\xEA\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED"))
                    end
                end
                imgui.SameLine(300) imgui.Text(u8("\xC2\xEA\xEB\x2F\xE2\xFB\xEA\xEB\x20\xEF\xEB\xE0\xE2\xED\xF3\xFE\x20\xEA\xE0\xEC\xE5\xF0\xF3\x3A")) imgui.SameLine(465) 
                if imadd.ToggleButton('##smoothcamera', smoothcumpenis228) then
                    ini.settings.smoothcum = smoothcumpenis228.v
                    inicfg.save(def, directIni)
                    if smoothcumpenis228.v then
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xCF\xEB\xE0\xE2\xED\xF3\xFE\x20\xEA\xE0\xEC\xE5\xF0\xE0\x20\x7B\x35\x35\x46\x46\x30\x30\x7D\xE2\xEA\xEB\xFE\xF7\xE5\xED\xE0"))
                        pritn()
                    else
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xCF\xEB\xE0\xE2\xED\xF3\xFE\x20\xEA\xE0\xEC\xE5\xF0\xE0\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\xE0"))
                    end
                end
                imgui.NewLine()
                imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x3A\x20\xC0\xE2\xF2\xEE\xF0\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x20\x4B\x6F\x6E\x74\x69\x78"))
                
                imgui.Text(u8("\xD1\xF1\xFB\xEB\xEA\xE0\x20\xED\xE0\x20\xF2\xE5\xEC\xF3\x3A"))
                imgui.SameLine(100)
                if imgui.Button(u8("\xCF\xE5\xF0\xE5\xE9\xF2\xE8")) then
                    os.execute('start "" "https://www.blast.hk/threads/236168/"')
                end
                imgui.NewLine()
                
                if imgui.Button(u8("\xCF\xF0\xEE\xE9\xF2\xE8\x20\xEC\xE8\xED\xE8\x2D\xE8\xE3\xF0\xF3"), imgui.ImVec2(150, 20)) then
                    sendCustomPacket('findGame.finish')
                end
                
                if findGameActive then
                    local elapsed = (os.clock() - findGameTimer) * 1000
                    local progress = math.min(elapsed / resendInterval, 1.0)
                
                    imgui.Text(u8("\xCF\xEE\xE8\xF1\xEA\x20\xE8\xE3\xF0\xFB\x20\xE0\xEA\xF2\xE8\xE2\xE5\xED\x2E\x2E\x2E"))
                    imgui.ProgressBar(progress, imgui.ImVec2(300, 20), string.format(u8("\x25\x2E\x31\x66\x20\xF1\xE5\xEA"), (resendInterval - elapsed) / 1000))
                
                    if elapsed >= resendInterval then
                        sendCustomPacket('findGame.finish')
                        findGameTimer = os.clock()
                    end
                end
                imgui.SetCursorPos(imgui.ImVec2(546, 345))
                if faico then
                    if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                        state = not state
                        state_taked = false
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x35\x35\x46\x46\x30\x30\x7D\xED\xE0\xF7\xE0\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
                    end
                    imgui.SameLine()
                    if state then
                        if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                            state = false
                            state_taked = false
                            findGameActive = false
                            walking = false
                            SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
                        end
                    end
                else
                    if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                        state = not state
                        state_taked = false
                        SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x35\x35\x46\x46\x30\x30\x7D\xED\xE0\xF7\xE0\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
                    end
                    imgui.SameLine()
                    if state then
                        if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                            state = false
                            state_taked = false
                            findGameActive = false
                            walking = false
                            SCM(("\x7B\x44\x44\x45\x43\x46\x46\x7D\xC1\xEE\xF2\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xF3\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\x20\xF0\xE0\xE1\xEE\xF2\xF3"))
                        end
                    end
                end
            end
            if ini.settings.post == 1 then -- Тракторист
                imgui.SameLine(30) imgui.Text(u8("\xC1\xE5\xE7\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xE8\xFF\x3A")) imgui.SameLine(170) 
                if imadd.ToggleButton('##liimit', limit1) then
                    ini.settings.limit1 = limit1.v
                    inicfg.save(def, directIni)
                end
                if ini.settings.limit1 == false then
                    imgui.NewLine() imgui.NewLine()
                    imgui.SameLine(30) imgui.Text(u8("\xCE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xE8\xE5\x3A")) imgui.SameLine(170) 
                    imgui.PushItemWidth(250) 
                        if imgui.InputInt('##lim', lim1) then
                            ini.settings.lim1 = lim1.v
                            inicfg.save(def, directIni)
                        end
                    imgui.PopItemWidth()
                    imgui.SameLine() ShowHelpMarker(u8("\xCD\xE5\x20\xF0\xE5\xEA\xEE\xEC\xE5\xED\xE4\xF3\xE5\xF2\xF1\xFF\x20\xF1\xF2\xE0\xE2\xE8\xF2\xFC\x20\xE1\xEE\xEB\xFC\xF8\xE5\x20\x34\x2C\x20\xF2\x2E\xEA\x20\xEA\xEE\xED\xF7\xE0\xE5\xF2\xF1\xFF\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE"))
                end
                imgui.NewLine() imgui.NewLine()
                imgui.SameLine(30)
                imgui.Text(u8("\xC0\xE2\xF2\xEE\xF1\xEC\xE5\xED\xE0\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0\x3A"))
                imgui.SameLine(170)
                if imadd.ToggleButton('##autochange', autochange) then
                    ini.settings.autochange = autochange.v
                    inicfg.save(def, directIni)
                end
                if ini.settings.autochange then
                    imgui.NewLine() imgui.NewLine()
                    imgui.SameLine(30)
                    imgui.Text(u8("\xD1\xEC\xE5\xED\xE8\xF2\xFC\x20\xF7\xE5\xF0\xE5\xE7\x3A"))
                    imgui.SameLine(170)
                    imgui.PushItemWidth(250)
                    if imgui.InputInt('##changeafter', changeafter) then
                        ini.settings.changeafter = math.max(1, changeafter.v)
                        inicfg.save(def, directIni)
                    end
                    imgui.PopItemWidth()
                    imgui.SameLine()
                    ShowHelpMarker(u8("\xCF\xEE\xF1\xEB\xE5\x20\xF3\xEA\xE0\xE7\xE0\xED\xED\xEE\xE3\xEE\x20\xEA\xEE\xEB\xE8\xF7\xE5\xF1\xF2\xE2\xE0\x20\xEA\xF0\xF3\xE3\xEE\xE2\x20\xE1\xEE\xF2\x20\xF1\xE0\xEC\x20\xE2\xFB\xE9\xE4\xE5\xF2\x20\xE8\xE7\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0\x20\xE8\x20\xF1\xFF\xE4\xE5\xF2\x20\xE2\x20\xE1\xEB\xE8\xE6\xE0\xE9\xF8\xE8\xE9\x20\xF1\xE2\xEE\xE1\xEE\xE4\xED\xFB\xE9\x2E"))
                end
                imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x3A\x20\xC0\xE2\xF2\xEE\xF0\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x20\x44\x2E\x4B\x6F\x70\x6E\x65\x76"))
                imgui.Text(u8("\xD1\xF1\xFB\xEB\xEA\xE0\x20\xED\xE0\x20\xF2\xE5\xEC\xF3\x3A"))
                imgui.SameLine(100)
                if imgui.Button(u8("\xCF\xE5\xF0\xE5\xE9\xF2\xE8")) then
                    os.execute('start "" "https://www.blast.hk/threads/40348/"')
                end
                if faico then
                    imgui.SetCursorPos(imgui.ImVec2(436, 345))
                    if work1 == true or paused == true then
                        if imgui.Button(fa.ICON_FA_PAUSE_CIRCLE..u8("\x20\x20\xCF\xE0\xF3\xE7\xE0"), imgui.ImVec2(100, 30)) then
                            work1 = false
                            gopay = false
                            paused = true
                        end
                    end imgui.SameLine()
                    imgui.SetCursorPos(imgui.ImVec2(546, 345))
                    if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 531 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work1 = true
                                gopay = false
                                value1 = 0
                                num = 0
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) and not infinitefuel then
                                    sampSendChat('/engine')
                                end
                            else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) end
                        else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) end

                        if paused then
                            work1 = true
                            gopay = false
                            paused = false
                            if lastCheckpoint then
                                lua_thread.create(function()
                                    rideToTractor(lastCheckpoint.x, lastCheckpoint.y, lastCheckpoint.z, 60)
                                end)
                            else
                                lua_thread.create(function()
                                    rideToTractor(-118.1747, 97.4916, 3.0650, 60)
                                end)
                            end
                        else
                            lua_thread.create(function()
                                rideToTractor(-118.1747, 97.4916, 3.0650, 60)
                            end)
                        end
                    end imgui.SameLine()
                    if work1 == true then
                        if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                            work1 = false
                            gopay = false
                        end
                    end
                else
                    imgui.SetCursorPos(imgui.ImVec2(436, 345))
                    if work1 == true or paused == true then
                        if imgui.Button(u8("\xCF\xE0\xF3\xE7\xE0"), imgui.ImVec2(100, 30)) then
                            work1 = false
                            gopay = false
                            paused = true
                        end
                    end imgui.SameLine()
                    imgui.SetCursorPos(imgui.ImVec2(546, 345))
                    if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 531 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work1 = true
                                gopay = false
                                value1 = 0
                                num = 0
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) and not infinitefuel then
                                    sampSendChat('/engine')
                                end
                            else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) end
                        else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) end

                        if paused then
                            work1 = true
                            gopay = false
                            paused = false
                            if lastCheckpoint then
                                lua_thread.create(function()
                                    rideToTractor(lastCheckpoint.x, lastCheckpoint.y, lastCheckpoint.z, 60)
                                end)
                            else
                                lua_thread.create(function()
                                    rideToTractor(-118.1747, 97.4916, 3.0650, 60)
                                end)
                            end
                        else
                            lua_thread.create(function()
                                rideToTractor(-118.1747, 97.4916, 3.0650, 60)
                            end)
                        end
                    end imgui.SameLine()
                    if work1 == true then
                        if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                            work1 = false
                            gopay = false
                        end
                    end
                end
            end
            if ini.settings.post == 2 then
                imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x3A\x20\xF5\xEE\xF2\xFC\x20\xF7\xF2\xEE\x2D\xF2\xEE\x20\xEF\xF0\xE0\xEA\xF2\xE8\xF7\xE5\xF1\xEA\xE8\x20\xF1\xE4\xE5\xEB\xE0\xED\xEE\x20\xEC\xED\xEE\xE9"))
                imgui.SameLine()
                imgui.PushItemWidth(150)
                imgui.PopItemWidth()
                if faico then
                    imgui.SetCursorPos(imgui.ImVec2(436, 345))
                    if work2 == true or paused == true then
                        if imgui.Button(fa.ICON_FA_PAUSE_CIRCLE..u8("\x20\x20\xCF\xE0\xF3\xE7\xE0"), imgui.ImVec2(100, 30)) then
                            work2 = false
                            paused = true
                        end
                    end imgui.SameLine()
                    imgui.SetCursorPos(imgui.ImVec2(546, 345))
                    if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 532 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work2 = true
                                value1 = 0
                                num = 1
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) and not infinitefuel then
                                    sampSendChat('/engine')
                                end
                            else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) end
                        else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) end

                        if paused then
                            work2 = true
                            paused = false
                            if lastCheckpoint then
                                lua_thread.create(function()
                                    rideToCombine(lastCheckpoint.x, lastCheckpoint.y, lastCheckpoint.z, 60)
                                end)
                            else
                                lua_thread.create(function()
                                    rideToCombine(-185.1780, -84.2181, 4.0672, 45) 
                                end)
                            end
                        else
                            lua_thread.create(function()
                                rideToCombine(-185.1780, -84.2181, 4.0672, 45) 
                            end)
                        end
                    end imgui.SameLine()
                    if work2 == true then
                        if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                            work2 = false
                        end
                    end
                else
                    imgui.SetCursorPos(imgui.ImVec2(436, 345))
                    if work2 == true or paused == true then
                        if imgui.Button(u8("\xCF\xE0\xF3\xE7\xE0"), imgui.ImVec2(100, 30)) then
                            work2 = false
                            paused = true
                        end
                    end imgui.SameLine()
                    imgui.SetCursorPos(imgui.ImVec2(546, 345))
                    if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 532 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work2 = true
                                value1 = 0
                                num = 1
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) and not infinitefuel then
                                    sampSendChat('/engine')
                                end
                            else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) end
                        else SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) end
                        if paused then
                            work2 = true
                            paused = false
                            if lastCheckpoint then
                                lua_thread.create(function()
                                    rideToCombine(lastCheckpoint.x, lastCheckpoint.y, lastCheckpoint.z, 60)
                                end)
                            else
                                lua_thread.create(function()
                                    rideToCombine(-185.1780, -84.2181, 4.0672, 45) 
                                end)
                            end
                        else
                            lua_thread.create(function()
                                rideToCombine(-185.1780, -84.2181, 4.0672, 45) 
                            end)
                        end
                    end imgui.SameLine()
                    if work2 == true then
                        if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                            work2 = false
                        end
                    end
                end
            end
            if ini.settings.post == 3 then -- Водитель кукурузника
                local routes = { u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x31"), u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x32"), u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x33"), u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x34") }
                local selectedRoute = imgui.ImInt(ini.settings.selectedRoute)
                imgui.Text(u8("\xC2\xFB\xE1\xE5\xF0\xE8\xF2\xE5\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x3A"))
                imgui.SameLine()
                imgui.PushItemWidth(150)
                if imgui.Combo(u8"##RouteSelection", selectedRoute, routes, #routes) then
                    ini.settings.selectedRoute = selectedRoute.v
                    inicfg.save(def, directIni)
                end
                imgui.PopItemWidth()
                imgui.SetCursorPos(imgui.ImVec2(546, 345))
                local letiCompleted = false
                local function startRoute(routeName)
                    vars.route.state = true
                    vars.route.name = routeName
                    vars.route.packets = 0
                    vars.route.currentPos = { x = -1, y = -1, z = -1 }
                    var_0_10.v = true
                    local filePath = getWorkingDirectory()..'\\PacketRecorder\\'..routeName..'.route'
                    if doesFileExist(filePath) then
                        msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE0\xE9\xE4\xE5\xED\x20\xEF\xEE\x20\xEF\xF3\xF2\xE8\x20")..filePath)
                        while vars.route.state and work3 do
                            wait(100)
                        end
                    else
                        msg(("\xCE\xF8\xE8\xE1\xEA\xE0\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE5\x20\xED\xE0\xE9\xE4\xE5\xED\x20\xEF\xEE\x20\xEF\xF3\xF2\xE8\x20")..filePath)
                        work3 = false
                    end
                end
                if faico then
                    if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 512 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work3 = true
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                    sampSendChat('/engine')
                                end
                                if selectedRoute.v == 0 then
                                    lua_thread.create(function()
                                        startRoute("leti")
                                        letiCompleted = true
                                        while work3 do
                                            startRoute("leti3")
                                        end
                                    end)
                                else
                                    msg(("\xC2\xF0\xE5\xEC\xE5\xED\xED\xEE\x20\xED\xE5\xF2\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0\x20\xE4\xEB\xFF\x20\xE2\xFB\xE1\xF0\xE0\xED\xED\xEE\xE3\xEE\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0\x2E"))
                                    work3 = false
                                end
                            else
                                SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                            end
                        else
                            SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                        end
                    end
                    imgui.SameLine()
                    if work3 and selectedRoute.v == 0 then
                        if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                            work3 = false
                            vars.route.state = false
                            vars.route.name = ''
                            vars.route.packets = 0
                            vars.route.currentPos = { x = -1, y = -1, z = -1 }
                            if isCharInAnyCar(PLAYER_PED) then
                                freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                            else
                                freezeCharPosition(PLAYER_PED, false)
                            end
                            msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
                        end
                    end
                else
                    if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                            if 512 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                work3 = true
                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                    sampSendChat('/engine')
                                end
                                if selectedRoute.v == 0 then
                                    lua_thread.create(function()
                                        startRoute("leti")
                                        letiCompleted = true
                                        while work3 do
                                            startRoute("leti3")
                                        end
                                    end)
                                else
                                    msg(("\xC2\xF0\xE5\xEC\xE5\xED\xED\xEE\x20\xED\xE5\xF2\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0\x20\xE4\xEB\xFF\x20\xE2\xFB\xE1\xF0\xE0\xED\xED\xEE\xE3\xEE\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0\x2E"))
                                    work3 = false
                                end
                            else
                                SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                            end
                        else
                            SCM(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                        end
                    end
                    imgui.SameLine()
                    if work3 and selectedRoute.v == 0 then
                        if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                            work3 = false
                            vars.route.state = false
                            vars.route.name = ''
                            vars.route.packets = 0
                            vars.route.currentPos = { x = -1, y = -1, z = -1 }
                            if isCharInAnyCar(PLAYER_PED) then
                                freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                            else
                                freezeCharPosition(PLAYER_PED, false)
                            end
                            msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
                        end
                    end
                end
            end
            imgui.EndGroup()
        end

        if vkladki[2] == true then -- Анти-голод
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200) imgui.Text(u8("\xC0\xED\xF2\xE8\x2D\xC3\xEE\xEB\xEE\xE4"))
            imgui.SameLine() ShowCOPYRIGHT(u8("\xC0\xE2\xF2\xEE\xF0\x3A\x20\x56\x65\x74\x72\x61\x79\x6F"))
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\xC0\xE2\xF2\xEE\xEC\xE0\xF2\xE8\xF7\xE5\xF1\xEA\xE8\x20\xE5\xF1\xF2\xFC\x20\xEF\xF0\xE8\x20\xE3\xEE\xEB\xEE\xE4\xE5\x3A")) imgui.SameLine(210) 
            if imadd.ToggleButton('##autoeat', autoeat) then
                ini.settings.autoeat = autoeat.v
                inicfg.save(def, directIni)
            end
            if autoeat.v then
                imgui.NewLine() imgui.NewLine()
                imgui.SameLine(15) imgui.Text(u8("\xD1\xEF\xEE\xF1\xEE\xE1\x20\xE5\xE4\xFB\x3A")) imgui.SameLine(170)
                imgui.PushItemWidth(250)
                if imgui.Combo('##eatmethod', eatmethod, method, -1) then
                    ini.settings.eatmethod = eatmethod.v
                    inicfg.save(def, directIni)
                end
                imgui.PopItemWidth()
                imgui.NewLine() imgui.NewLine()
                imgui.SameLine(15) imgui.Text(u8("\xC5\xF1\xF2\xFC\x20\xEF\xF0\xE8\x20\xF1\xFB\xF2\xEE\xF1\xF2\xE8\x20\xED\xE8\xE6\xE5\x3A")) imgui.SameLine(170)
                imgui.PushItemWidth(250)
                if imgui.SliderInt('##eatpercent', eatpercent, 1, 99) then
                    ini.settings.eatpercent = eatpercent.v
                    inicfg.save(def, directIni)
                end
                imgui.PopItemWidth()
            end
            imgui.EndGroup()
        end

        if vkladki[3] == true then --  ("\xC4\xEE\xEF\x2E\xF4\xF3\xED\xEA\xF6\xE8\xE8")
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8("\xC7\xE0\xF9\xE8\xF2\xE0\x20\xEC\xE0\xF8\xE8\xED\xFB\x20\x20")..fa.ICON_FA_SHIELD_ALT) else imgui.Text(u8("\xC7\xE0\xF9\xE8\xF2\xE0\x20\xEC\xE0\xF8\xE8\xED\xFB")) end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(30) imgui.Text(u8("\xCD\xE5\xF3\xFF\xE7\xE2\xE8\xEC\xEE\xF1\xF2\xFC\x20\xEC\xE0\xF8\xE8\xED\xFB\x3A")) imgui.SameLine(170) 
            if imadd.ToggleButton('##invulnerability', var_0_10) then
                ini.settings.invulnerability = var_0_10.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC4\xE5\xEB\xE0\xE5\xF2\x20\xE2\xE0\xF8\xF3\x20\xEC\xE0\xF8\xE8\xED\xF3\x20\xED\xE5\xF3\xFF\xE7\xE2\xE8\xEC\xEE\xE9\x20\xEA\x20\xEB\xFE\xE1\xFB\xEC\x20\xEF\xEE\xE2\xF0\xE5\xE6\xE4\xE5\xED\xE8\xFF\xEC")) imgui.SameLine(340)
            imgui.SameLine(305) imgui.Text(u8("\xC0\xE2\xF2\xEE\xE2\xE7\xFF\xF2\xE8\xE5\x20\xEA\xE2\xE5\xF1\xF2\xEE\xE2\x3A")) imgui.SameLine(430)
            if imadd.ToggleButton(u8'##autofarmzov', autofarmzov) then
                ini.settings.autofarmzov = autofarmzov.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCF\xEE\xE4\xEE\xE9\xE4\xE8\x20\xEA\x20\xED\xEF\xF1\x20\xE8\x20\xED\xE0\xE6\xEC\xE8\x20\xE0\xEB\xFC\xF2")) imgui.SameLine(510)
            imgui.NewLine() imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(30) imgui.Text(u8("\xC1\xE5\xF1\xEA\xEE\xED\xE5\xF7\xED\xEE\xE5\x20\xF2\xEE\xEF\xEB\xE8\xE2\xEE\x3A")) imgui.SameLine(170) 
            if imadd.ToggleButton('##infinitefuel', var_0_11) then
                ini.settings.infinitefuel = var_0_11.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCC\xE0\xF8\xEE\xED\xEA\xE0\x20\xEC\xEE\xE6\xE5\xF2\x20\xE5\xE7\xE4\xE8\xF2\xFC\x20\xF1\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\xED\xFB\xEC\x20\xE4\xE2\xE8\xE3\xE0\xF2\xE5\xEB\xE5\xEC")) imgui.SameLine(340)
            imgui.SameLine(305) imgui.Text(u8("\xC0\xE2\xF2\xEE\xF2\xEE\xEF\xEB\xE8\xE2\xEE\x3A")) imgui.SameLine(390) 
            if imadd.ToggleButton('##infinitefuelengine', var_0_12) then
                ini.settings.infinitefuelengine = var_0_12.v
                inicfg.save(def, directIni)
                if not var_0_12.v then
                    infengine = false
                end
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC0\xE2\xF2\xEE\xEC\xE0\xF2\xE8\xF7\xE5\xF1\xEA\xE8\x20\xE2\xEA\xEB\xFE\xF7\xE5\xF2\x20\xE4\xE2\xE8\xE6\xEE\xEA\x20\xE1\xE5\xE7\x20\xF2\xEE\xEF\xEB\xE8\xE2\xE0")) imgui.SameLine(510)
            imgui.NewLine() imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(30) imgui.Text(u8("\xCA\xEE\xEB\xEB\xE8\xE7\xE8\xFF\x20\xED\xE0\x20\xEE\xE1\xFA\xE5\xE4\xEA\xE8\x3A")) imgui.SameLine(170) 
            if imadd.ToggleButton('##collisiondebris', var_collision) then
                ini.settings.collision = var_collision.v
                inicfg.save(def, directIni)
                toggleNoCollisionObjects(not var_collision.v)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xE1\xE0\xE3\xE0\xED\xED\xE0\xFF\x20\xEA\xEE\xEB\xEB\xE8\xE7\xE8\xFF\x20\xED\xE0\x20\xEE\xE1\xFA\xE5\xEA\xF2\xFB\x20\xE2\xEA\xEB\xFE\xF7\xE8\xF8\xFC\x20\xF0\xE0\xE7\x2C\x20\xED\xE5\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE0\xE9")) imgui.SameLine(340)
            imgui.SameLine(305) imgui.Text(u8("\xD1\xEA\xF0\xFB\xF2\xFC\x20\xE4\xE8\xE0\xEB\xEE\xE3\xE8\x3A")) imgui.SameLine(410) 
            if imadd.ToggleButton('##hidedialogesis', hidedildos) then
                ini.settings.hidedialog = hidedildos.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD1\xEA\xF0\xEE\xE5\xF2\x20\xED\xE5\xEA\xEE\xF2\xEE\xF0\xFB\xE5\x20\xE4\xE8\xE0\xEB\xEE\xE3\xE8\x20\xED\xE0\x20\xF4\xE5\xF0\xEC\xE5")) imgui.SameLine(510)
            imgui.NewLine() imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(30)
            if faico then imgui.Text(u8("\xCA\xE0\xEA\xF3\xEB\xFF\xF2\xEE\xF0\x20\xF0\xE0\xE1\xEE\xF2\xFB\x20\x20")..fa.ICON_FA_CALCULATOR) else imgui.Text(u8'') end
            imgui.SameLine(300)
            if faico then imgui.Text(u8("\xD1\xF2\xE0\xF2\xE8\xF1\xF2\xE8\xEA\xE0\x20\xEA\xE2\xE5\xF1\xF2\xE8\xEA\xEE\xE2\x20\x20")..fa.ICON_FA_LIST) else imgui.Text(u8'') end
            imgui.NewLine() 
            imgui.SameLine(15)
            if imgui.Button(u8("\xCF\xEE\xF1\xF7\xE5\xF2\xE0\xF2\xFC"), imgui.ImVec2(150, 30)) then
                calc_window.v = true
            end
            imgui.SameLine(300)
            if imgui.Button(u8("\xCD\xE0\xE6\xEC\xE8\x20\xEC\xE5\xED\xFF"), imgui.ImVec2(150, 30)) then
                quest_window.v = true
            end
            imgui.EndGroup()
        end
        if vkladki[4] == true then -- Авиашкола
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8("\xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xE0\x20\x20")..fa.ICON_FA_PLANE) else imgui.Text(u8("\xC0\xE2\xE8\xE0\xF8\xEA\xEE\xEB\xE0\x20")) end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            local aircrafts = { u8("\xD1\xE0\xEC\xEE\xEB\xE5\xF2\x20\x31"), u8("\xD1\xE0\xEC\xEE\xEB\xE5\xF2\x20\x32"), u8("\xD1\xE0\xEC\xEE\xEB\xE5\xF2\x20\x33"), u8("\xD1\xE0\xEC\xEE\xEB\xE5\xF2\x20\x34") }
            local selectedAircraft = imgui.ImInt(ini.settings.selectedAircraft or 0)
            imgui.Text(u8("\xC2\xFB\xE1\xE5\xF0\xE8\xF2\xE5\x20\xF1\xE0\xEC\xEE\xEB\xE5\xF2\x3A"))
            imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo(u8"##AircraftSelection", selectedAircraft, aircrafts, #aircrafts) then
                ini.settings.selectedAircraft = selectedAircraft.v
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
            imgui.NewLine()
            if selectedAircraft.v ~= 0 then
                imgui.TextColored(imgui.ImVec4(1.0, 0.5, 0.0, 1.0), u8("\xC4\xEB\xFF\x20\xE2\xFB\xE1\xF0\xE0\xED\xED\xEE\xE3\xEE\x20\xF1\xE0\xEC\xEE\xEB\xE5\xF2\xE0\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xE2\xF0\xE5\xEC\xE5\xED\xED\xEE\x20\xED\xE5\xE4\xEE\xF1\xF2\xF3\xEF\xE5\xED"))
            end
            imgui.SetCursorPos(imgui.ImVec2(546, 345))
            local function startRoute(routeName)
                vars.route.state = true
                vars.route.name = routeName
                vars.route.packets = 0
                vars.route.currentPos = { x = -1, y = -1, z = -1 }
                var_0_10.v = true
                local filePath = getWorkingDirectory()..'\\PacketRecorder\\'..routeName..'.route'
                if doesFileExist(filePath) then
                    msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE0\xE9\xE4\xE5\xED"))
                else
                    msg(("\xCE\xF8\xE8\xE1\xEA\xE0\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE5\x20\xED\xE0\xE9\xE4\xE5\xED"))
                    vars.route.state = false
                end
            end
            if faico then
                if imgui.Button(fa.ICON_FA_PLAY_CIRCLE..u8("\x20\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    if selectedAircraft.v == 0 then
                        startRoute("lol3")
                    else
                        msg(("\xC2\xF0\xE5\xEC\xE5\xED\xED\xEE\x20\xED\xE5\xF2\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0\x20\xE4\xEB\xFF\x20\xE2\xFB\xE1\xF0\xE0\xED\xED\xEE\xE3\xEE\x20\xF1\xE0\xEC\xEE\xEB\xE5\xF2\xE0"))
                    end
                end
                if vars.route.state and vars.route.name == "lol3" then
                    imgui.SameLine()
                    if imgui.Button(fa.ICON_FA_STOP_CIRCLE..u8("\x20\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        vars.route.state = false
                        vars.route.name = ''
                        vars.route.packets = 0
                        vars.route.currentPos = { x = -1, y = -1, z = -1 }
                        var_0_10.v = false
                        if isCharInAnyCar(PLAYER_PED) then
                            freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                        else
                            freezeCharPosition(PLAYER_PED, false)
                        end
                        
                        msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
                    end
                end
            else
                if imgui.Button(u8("\xCD\xE0\xF7\xE0\xF2\xFC"), imgui.ImVec2(100, 30)) then
                    if selectedAircraft.v == 0 then
                        startRoute("lol3")
                    else
                        msg(("\xC2\xF0\xE5\xEC\xE5\xED\xED\xEE\x20\xED\xE5\xF2\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0\x20\xE4\xEB\xFF\x20\xE2\xFB\xE1\xF0\xE0\xED\xED\xEE\xE3\xEE\x20\xF1\xE0\xEC\xEE\xEB\xE5\xF2\xE0"))
                    end
                end
                if vars.route.state and vars.route.name == "lol3" then
                    imgui.SameLine()
                    if imgui.Button(u8("\xD1\xF2\xEE\xEF"), imgui.ImVec2(100, 30)) then
                        vars.route.state = false
                        vars.route.name = ''
                        vars.route.packets = 0
                        vars.route.currentPos = { x = -1, y = -1, z = -1 }
                        var_0_10.v = false
                        if isCharInAnyCar(PLAYER_PED) then
                            freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                        else
                            freezeCharPosition(PLAYER_PED, false)
                        end
                        msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEB\xE5\xED"))
                    end
                end
            end
            imgui.EndGroup()
        end
        if vkladki[5] == true then -- Telegram
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xFF\x20\x54\x65\x6C\x65\x67\x72\x61\x6D\x20\x20")..fa.ICON_FA_PAPER_PLANE) else imgui.Text(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xFF\x20\x54\x65\x6C\x65\x67\x72\x61\x6D")) end
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            imgui.NewLine()
            imgui.SameLine(0) imgui.Text(u8'TOKEN:')
            imgui.SameLine(90)
            imgui.PushItemWidth(300)
            if imgui.InputText('##token', buffer_token, imgui.InputTextFlags.Password) then
            end
            imgui.PopItemWidth()
            imgui.NewLine()
            imgui.SameLine(0) imgui.Text(u8'USER ID:')
            imgui.SameLine(90)
            imgui.PushItemWidth(300)
            if imgui.InputText('##chatid', buffer_chatid) then
            end
            imgui.PopItemWidth()
            imgui.SetCursorPos(imgui.ImVec2(560, 100))
            if imgui.Button(u8("\xD2\xE5\xF1\xF2"), imgui.ImVec2(100, 50)) then
                sendTelegramNotification(("\xD2\xE5\xF1\xF2\xEE\xE2\xEE\xE5\x20\xF1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x21"))
            end
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            local texts = {
                ("\x21\x73\x65\x6E\x64\x20\x2D\x20\xEE\xF2\xEF\xF0\xE0\xE2\xE8\xF2\xFC\x20\xF1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x20\xE2\x20\xF7\xE0\xF2"),
                ("\x21\x73\x74\x61\x74\x73\x20\x2D\x20\xF1\xF2\xE0\xF2\xE8\xF1\xF2\xE8\xEA\xE0\x20\xF0\xE0\xE1\xEE\xF2\xFB"),
                ("\x21\x73\x74\x61\x72\x74\x20\x2D\x20\xE2\xEA\xEB\xFE\xF7\xE8\xF2\xFC\x20\xE1\xEE\xF2\xE0"),
                ("\x21\x65\x78\x69\x74\x20\x2D\x20\xE2\xFB\xE9\xF2\xE8\x20\xE8\xE7\x20\xE8\xE3\xF0\xFB"),
                ("\x21\x73\x74\x6F\x70\x20\x2D\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE8\xF2\xFC\x20\xE1\xEE\xF2\xE0"),
                ("\x21\x63\x6C\x6F\x73\x65\x20\x2D\x20\xE7\xE0\xEA\xF0\xFB\xF2\xFC\x20\xE4\xE8\xE0\xEB\xEE\xE3\x20\xF7\xE5\xEA\x20\xE1\xEE\xF2\xE0\x28\xE0\xE4\xEC\xE8\xED\xE0\x29"),
                ("\x21\x63\x72\x61\x73\x68\x20\x2D\x20\xEA\xF0\xE0\xF8\xED\xF3\xF2\xFC\x20\xE8\xE3\xF0\xF3"),
            }
            for i, txt in ipairs(texts) do
                if i % 2 == 1 then
                    imgui.SameLine(0)
                    imgui.Text(u8(txt))
                else
                    imgui.SameLine(270)
                    imgui.Text(u8(txt))
                    imgui.NewLine()
                end
            end
            imgui.NewLine()
            imgui.SameLine(0)
            if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xFF\x20\xEF\xF0\xE8\x20\xEF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE8\x20\xED\xE0\x20\xEE\xE1\xF9\xE5\xED\xE8\xE5"), control.warningseytg) then
                ini.Telegram.warningseytg = control.warningseytg.v
                inicfg.save(def, directIni)
            end
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(210)
            if imgui.Button(u8("\xD1\xEE\xF5\xF0\xE0\xED\xE8\xF2\xFC"), imgui.ImVec2(150, 30)) then
                ini.Telegram.chat_id = tostring(buffer_chatid.v)
                ini.Telegram.token = tostring(buffer_token.v)
                local success, err = pcall(function()
                    inicfg.save(ini, directIni)
                end)
                if success then
                    if notf then notf.addNotification(("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\xF2\xE5\xEB\xE5\xE3\xF0\xE0\xEC\xEC\xE0\x20\xF1\xEE\xF5\xF0\xE0\xED\xE5\xED\xFB\x21"), 5, 10) end
                    chat_id = ini.Telegram.chat_id
                    token = ini.Telegram.token
                else
                    print(("\xCE\xF8\xE8\xE1\xEA\xE0\x20\xF1\xEE\xF5\xF0\xE0\xED\xE5\xED\xE8\xFF\x20\x54\x65\x6C\x65\x67\x72\x61\x6D\x20\xED\xE0\xF1\xF2\xF0\xEE\xE5\xEA\x3A\x20") .. tostring(err))
                end
            end
            imgui.EndGroup()
        end

        if vkladki[6] == true then -- AntiAdmin
            imgui.BeginGroup()
            imgui.NewLine()
            imgui.NewLine()
            imgui.SameLine(210)
            if faico then imgui.Text(u8("\x41\x6E\x74\x69\x2D\x41\x64\x6D\x69\x6E\x20\xE7\xE0\xF9\xE8\xF2\xE0\x20\x20")..fa.ICON_FA_USER_SLASH) else imgui.Text(u8("\x41\x6E\x74\x69\x2D\x41\x64\x6D\x69\x6E\x20\xE7\xE0\xF9\xE8\xF2\xE0")) end
            imgui.NewLine()
            imgui.Separator()
            imgui.NewLine()
            imgui.SetCursorPos(imgui.ImVec2(170.8, 90));
            if imgui.Checkbox(u8("\xC2\xFB\xEA\xEB\xFE\xF7\xE5\xED\xE8\xE5\x20\xE1\xEE\xF2\xE0"), control.autoOff) then
                ini.AntiAdmin.autoOff = control.autoOff.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC2\xFB\xEA\xEB\xFE\xF7\xE0\xE5\xF2\x20\xE1\xEE\xF2\xE0\x2C\x20\xE5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED")) imgui.SameLine(180)
            imgui.SetCursorPos(imgui.ImVec2(170.8, 120));
            if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xE5\x20\xE2\x20\x54\x47"), control.telegramNotf) then
                ini.AntiAdmin.telegramNotf = control.telegramNotf.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED\x2C\x20\xEF\xF0\xE8\xF8\xEB\xB8\xF2\x20\xF3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xE5")) imgui.SameLine(180)
            imgui.SetCursorPos(imgui.ImVec2(360, 90));
            if imgui.Checkbox(u8("\xD0\xE0\xE7\xE2\xEE\xF0\xEE\xF2\x20\xE8\xE3\xF0\xFB"), control.reversal) then
                ini.AntiAdmin.reversal = control.reversal.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD0\xE0\xE7\xE2\xE5\xF0\xED\xB8\xF2\x20\xE8\xE3\xF0\xF3\x2C\x20\xE5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED")) imgui.SameLine(370)
            imgui.SetCursorPos(imgui.ImVec2(540, 90));    
            if imgui.Checkbox(u8("\xCC\xE8\xE3\xE0\xED\xE8\xE5\x20\xFD\xEA\xF0\xE0\xED\xEE\xEC"), control.blinking) then
                ini.AntiAdmin.blinking = control.blinking.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC1\xF3\xE4\xE5\xF2\x20\xEC\xE8\xE3\xE0\xF2\xFC\x20\xFD\xEA\xF0\xE0\xED\x2C\x20\xE5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED")) imgui.SameLine(550)
            imgui.SetCursorPos(imgui.ImVec2(505, 120));
            if imgui.RadioButton(u8("\x33\x35\x30\x20\xEC\xF1"), control.flash, 1) then
                ini.AntiAdmin.flash = 1
                inicfg.save(def, directIni)
            end
            imgui.SetCursorPos(imgui.ImVec2(585, 120));
            if imgui.RadioButton(u8("\x35\x30\x30\x20\xEC\xF1"), control.flash, 2) then
                ini.AntiAdmin.flash = 2
                inicfg.save(def, directIni)
            end
            imgui.SetCursorPos(imgui.ImVec2(360, 120));
            if imgui.Checkbox(u8("\xCA\xF0\xE0\xF8\xED\xF3\xF2\xFC\x20\xE8\xE3\xF0\xF3"), control.autoExit) then
                ini.AntiAdmin.autoExit = control.autoExit.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCA\xF0\xE0\xF8\xED\xE5\xF2\x20\xE8\xE3\xF0\xF3\x2C\x20\xE5\xF1\xEB\xE8\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB\x20\xE0\xE4\xEC\xE8\xED")) imgui.SameLine(370)
            imgui.SetCursorPos(imgui.ImVec2(540, 150));    
            if imgui.Checkbox(u8("\xD1\xEA\xE8\xEF\x20\xE4\xE8\xE0\xEB\xEE\xE3\xE0"), control.skipdialog) then
                ini.AntiAdmin.skipdialog = control.skipdialog.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD1\xEA\xE8\xEF\xED\xE5\xF2\x20\xE4\xE8\xE0\xEB\xEE\xE3\x20\x2F\x70\x6D")) imgui.SameLine(550)
            imgui.SetCursorPos(imgui.ImVec2(170.8, 150));
            if imgui.Checkbox(u8("\xCC\xE8\xE3\xE0\xF2\xFC\x20\xFD\xEA\xF0\xE0\xED\xEE\xEC\x20\xEF\xF0\xE8\x20\xEF\xEE\xE4\xEE\xE7\xF0\xE5\xED\xE8\xE8\x20\xED\xE0\x20\xEE\xE1\xF9\xE5\xED\xE8\xE5"), control.warningsey) then
                ini.AntiAdmin.warningsey = control.warningsey.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCC\xE8\xE3\xE0\xE5\xF2\x20\xFD\xEA\xF0\xE0\xED\x2C\x20\xE5\xF1\xEB\xE8\x20\xEA\xF2\xEE\x2D\xF2\xEE\x20\xED\xE0\xEF\xE8\xF1\xE0\xEB")) imgui.SameLine(180)
            imgui.SetCursorPos(imgui.ImVec2(340, 183));
            imgui.Text(u8("\xD1\xEA\xE8\xEF\xE0\xF2\xFC\x20\xE7\xE0\x20\xF1\xEB\xF3\xF7\xE0\xE9\xED\xEE\xE5\x20\xE2\xF0\xE5\xEC\xFF\x20\xEE\xF2"))
            imgui.SetCursorPos(imgui.ImVec2(540, 180));
            imgui.PushItemWidth(103)
            if imgui.InputInt(u8("\xE4\xEE"), control.skip1) then
                ini.AntiAdmin.skip11 = tonumber(control.skip1.v) or 1250
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
            imgui.SetCursorPos(imgui.ImVec2(540, 210));
            imgui.PushItemWidth(103)
            if imgui.InputInt(u8("\xEC\xF1"), control.skip2) then
                ini.AntiAdmin.skip22 = tonumber(control.skip2.v) or 1500
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
    imgui.SetCursorPos(imgui.ImVec2(170.8, 250))
    if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\x2E\x20\xE5\xF1\xEB\xE8\x20\xF2\x2F\xF1\x20\xE7\xE0\xF1\xF2\xF0\xFF\xEB"), control.zastryal) then
        ini.AntiAdmin.zastryal = control.zastryal.v
        inicfg.save(def, directIni)
    end
    imgui.SameLine() ShowHelpMarker(u8("\xC1\xF3\xE4\xE5\xF2\x20\xEF\xF0\xE8\xF1\xFB\xEB\xE0\xF2\xFC\x20\xF3\xE2\xE5\xE4\xEE\xEC\xEB\xE5\xED\xE8\xFF\x20\xE5\xF1\xEB\xE8\x20\xF2\xEE\xF7\xEA\xE0\x20\xED\xE5\x20\xEC\xE5\xED\xFF\xE5\xF2\xF1\xFF\x28\x32\x30\x20\xF1\xE5\xEA\x29\x2E\x28\xCD\xEE\xF0\xEC\x20\xF0\xE0\xE1\xEE\xF2\xE0\xE5\xF2\x20\xFD\xF2\xEE\x2C\x20\xE5\xF1\xEB\xE8\x20\xF7\xE5\xEA\xEF\xEE\xE8\xED\xF2\x20\xE1\xE5\xF0\xB8\xF2\xF1\xFF\x29"))

    imgui.SetCursorPos(imgui.ImVec2(170.8, 280))
    if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\x2E\x20\xEF\xF0\xE8\x20\xED\xE8\xE7\xEA\xEE\xEC\x20\x48\x50"), control.lowhp) then
        ini.AntiAdmin.lowhp = control.lowhp.v
        inicfg.save(def, directIni)
    end
    imgui.SameLine() ShowHelpMarker(u8("\xD1\xEF\xE0\xEC\xE8\xF2\x20\xE5\xF1\xEB\xE8\x20\xF3\x20\xE2\xE0\xF1\x20\xF5\xEF\x20\xEC\xE5\xED\xFC\xF8\xE5\x20\xE8\xEB\xE8\x20\xF0\xE0\xE2\xED\xEE\x20\x31\x30"))
    imgui.SetCursorPos(imgui.ImVec2(170.8, 310))
    if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\x20\xE5\xF1\xEB\xE8\x20\xF3\x20\xE2\xE0\xF1\x20\xE3\xEE\xEB\xEE\xE4"), control.golodhelp) then
        ini.AntiAdmin.golodhelp = control.golodhelp.v
        inicfg.save(def, directIni)
    end
    imgui.SameLine() ShowHelpMarker(u8("\xD3\xE2\xE5\xE4\x20\xE5\xF1\xEB\xE8\x20\xF3\x20\xE2\xE0\xF1\x20\xE3\xEE\xEB\xEE\xE4\x20\xEC\xE5\xED\xFC\xF8\xE5\x20\x32\x30\x25"))
    imgui.SetCursorPos(imgui.ImVec2(170.8, 340))
    if imgui.Checkbox(u8("\xD3\xE2\xE5\xE4\x20\xEF\xF0\xE8\x20\xF1\xEC\xE5\xED\xE5\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0"), control.tractorNotify) then
        ini.AntiAdmin.tractorNotify = control.tractorNotify.v
        inicfg.save(def, directIni)
    end
    imgui.SameLine() ShowHelpMarker(u8("\xD3\xE2\xE5\xE4\xEE\xEC\xE8\xF2\x20\xE2\x20\x54\x65\x6C\x65\x67\x72\x61\x6D\x20\xEF\xF0\xE8\x20\xF1\xEC\xE5\xED\xE5\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE0"))
            imgui.EndGroup()
        end
        if vkladki[7] == true then -- Настройки
            imgui.BeginGroup()
            imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200)
            if faico then imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8\x20\x20")..fa.ICON_FA_COGS) else imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE8")) end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\xC2\xFB\xE1\xEE\xF0\x20\xF2\xE5\xEC\xFB\x3A\x20")) imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo('##theme', tema, items) then
                ini.settings.theme = tema.v
                inicfg.save(def, directIni)
            end
            imgui.PopItemWidth()
            imgui.SameLine(260)
            imgui.Text(u8("\xC2\xFB\xE1\xEE\xF0\x20\xF1\xF2\xE8\xEB\xFF\x3A\x20")) imgui.SameLine()
            imgui.PushItemWidth(150)
            if imgui.Combo('##style', style, styles) then
                ini.settings.style = style.v
                inicfg.save(def, directIni)
            end
            imgui.NewLine()
            imgui.SameLine(15)
            if ini.settings.theme == 8 then
                if imgui.Button(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE8\xF2\xFC\x20\xF2\xE5\xEC\xF3\x20\x39"), imgui.ImVec2(150, 30)) then
                    theme9_window.v = not theme9_window.v
                end
            end
            imgui.PopItemWidth()
            imgui.NewLine() imgui.NewLine() imgui.SameLine(15)
            imgui.Text(u8("\xCE\xE1\xFF\xE7\xE0\xF2\xE5\xEB\xFC\xED\xE0\xFF\x20\xEA\xEE\xEC\xE0\xED\xE4\xE0\x20\xE0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xE8\x3A\x20")) imgui.SameLine()
            imgui.Text(u8'/farm')
            imgui.NewLine() imgui.SameLine(15)
            imgui.Text(u8("\xCF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xF2\xE5\xEB\xFC\xF1\xEA\xE0\xFF\x20\xEA\xEE\xEC\xE0\xED\xE4\xE0\x20\xE0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xE8\x3A\x20")) imgui.SameLine()
            imgui.PushItemWidth(100)
            local customCommand = imgui.ImBuffer(ini.settings.customCommand, 32)
            if imgui.InputText('##customCommand', customCommand) then
                ini.settings.customCommand = customCommand.v
            end
            imgui.PopItemWidth()
            imgui.SameLine()
            if imgui.Button(u8("\xC7\xE0\xE3\xF0\xF3\xE7\xE8\xF2\xFC"), imgui.ImVec2(80, 20)) then
                ini.settings.customCommand = customCommand.v
                inicfg.save(def, directIni)
                SCM(("\xCF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xF2\xE5\xEB\xFC\xF1\xEA\xE0\xFF\x20\xEA\xEE\xEC\xE0\xED\xE4\xE0\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE0\x20\xED\xE0\x3A\x20") .. customCommand.v)
                ini.settings.reload = true
                inicfg.save(def, directIni)
                thisScript():reload()
            end
            imgui.SameLine() ShowHelpMarker(u8("\xC2\xE2\xE5\xE4\xE8\xF2\xE5\x20\xEF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xF2\xE5\xEB\xFC\xF1\xEA\xF3\xFE\x20\xEA\xEE\xEC\xE0\xED\xE4\xF3\x20\xE4\xEB\xFF\x20\xE0\xEA\xF2\xE8\xE2\xE0\xF6\xE8\xE8\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x20\xE1\xE5\xE7\x20\x2F"))
            imgui.NewLine()        
            imgui.Separator() imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15)
            imgui.Text(u8("\x46\x41\x20\xE8\xEA\xEE\xED\xEA\xE8\x3A")) imgui.SameLine(290)
            if imadd.ToggleButton(u8'##faedit', faedit) then
                ini.settings.faedit = faedit.v
                ini.settings.reload = true
                inicfg.save(def, directIni)
                lua_thread.create(function() wait(130) thisScript():reload() end)
            end
            imgui.NewLine()
            imgui.SameLine(15)
            imgui.Text(u8("\xC0\xE2\xF2\xEE\xEC\xE0\xF2\xE8\xF7\xE5\xF1\xEA\xE8\x20\xEE\xF2\xE2\xE5\xF7\xE0\xF2\xFC\x20\xE0\xE4\xEC\xE8\xED\xE8\xF1\xF2\xF0\xE0\xF6\xE8\xE8\x3A")) imgui.SameLine(290)
            if imadd.ToggleButton(u8'##auto', auto) then
                ini.settings.auto = auto.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCE\xF2\xE2\xE5\xF7\xE0\xF2\xFC\x20\xED\xE0\x20\xE2\xEE\xEF\xF0\xEE\xF1\xFB\x3A\x20\xC2\xFB\x20\xF2\xF3\xF2\x3F"))
            imgui.NewLine()
            imgui.SameLine(15)
            imgui.Text(u8("\xD0\xE0\xE1\xEE\xF2\xE0\x20\xE2\x20\xF1\xE2\xB8\xF0\xED\xF3\xF2\xEE\xEC\x20\xF0\xE5\xE6\xE8\xEC\xE5\x3A")) imgui.SameLine(290)
            if imadd.ToggleButton(u8'##bg', bg) then
                ini.settings.bg = bg.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xCC\xE0\xEB\xFF\xF1\xFC\x20\xE1\xF3\xE4\xE5\xF2\x20\xEF\xEB\xEE\xF5\xEE\x20\xF0\xE0\xE1\xEE\xF2\xE0\xF2\xFC"))
            imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\xD0\xE5\xE6\xE8\xEC\x20\xED\xE5\xE2\xE8\xE4\xE8\xEC\xEA\xE8\x3A")) imgui.SameLine(290)
            if imadd.ToggleButton(u8'##invisible', invisible) then
                ini.settings.invisible = invisible.v
                inicfg.save(def, directIni)
            end
            imgui.SameLine() ShowHelpMarker(u8("\xD1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xFF\x20\xEE\xF2\x20'\x46\x61\x72\x6D\x20\x42\x6F\x74'\x20\xE1\xF3\xE4\xF3\xF2\x20\xE2\xFB\xE2\xEE\xE4\xE8\xF2\xFC\xF1\xFF\x20\xED\xE5\x20\xE2\x20\xF7\xE0\xF2\x2C\x20\xE0\x20\xE2\x20\xEA\xEE\xED\xF1\xEE\xEB\xFC"))
            if faico then
                if imgui.Button(fa.ICON_FA_UPLOAD .. u8("\x20\x20\x20\xCF\xF0\xEE\xE2\xE5\xF0\xE8\xF2\xFC\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xFF")) then
                    update()
                end
            else
                if imgui.Button(u8("\xCF\xF0\xEE\xE2\xE5\xF0\xE8\xF2\xFC\x20\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xFF")) then
                    update()
                end
            end 
            imgui.SameLine()
            if imgui.Checkbox(u8("\xC0\xE2\xF2\xEE\xEE\xE1\xED\xEE\xE2\xEB\xE5\xED\xE8\xE5"), autoupdate_checkbox) then
                ini.settings.autoupdate = autoupdate_checkbox.v
                inicfg.save(ini, directIni)
                enable_autoupdate = ini.settings.autoupdate
                if enable_autoupdate and not autoupdate_loaded then
                    autoupdate_loaded, Update = goupdate(true)
                elseif not enable_autoupdate and Update then
                    Update = nil
                    autoupdate_loaded = false
                end
            end            
            imgui.SetCursorPos(imgui.ImVec2(560, 280))
            if imgui.Button(u8'ChangeLog', imgui.ImVec2(100, 25)) then
                changelog_window.v = not changelog_window.v
            end
            imgui.EndGroup()
        end

        if vkladki[8] == true then -- Информация
			imgui.BeginGroup()
			imgui.NewLine() imgui.NewLine()
            imgui.SameLine(200)
            if faico then imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF\x20\x20")..fa.ICON_FA_INFO_CIRCLE) else imgui.Text(u8("\xC8\xED\xF4\xEE\xF0\xEC\xE0\xF6\xE8\xFF")) end
            imgui.NewLine()
            imgui.Separator() imgui.NewLine()
            imgui.NewLine()
			imgui.SameLine(210)
            imgui.TextColored(imgui.ImVec4(1, 0, 0, 1), u8("\xC2\xED\xE8\xEC\xE0\xED\xE8\xE5\x21"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8("\xC7\xE0\x20\xE2\xE0\xF8\x20\xE0\xEA\xEA\xE0\xF3\xED\xF2\x20\xED\xE5\xF1\xB8\xF2\xE5\x20\xEE\xF2\xE2\xE5\xF1\xF2\xE2\xE5\xED\xED\xEE\xF1\xF2\xFC\x20\xF2\xEE\xEB\xFC\xEA\xEE\x20\xE2\xFB\x21"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8("\xC5\xF1\xEB\xE8\x20\xE2\xE0\xF1\x20\xE7\xE0\xE1\xE0\xED\xFF\xF2\x20\xE7\xE0\x20\xE1\xEE\xF2\xE0\x2C\x20\xF2\xEE\x20\xFD\xF2\xEE\x20\xF7\xE8\xF1\xF2\xEE\x20\xE2\xE0\xF8\xE0\x20\xE2\xE8\xED\xE0\x2E"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8("\xD0\xE5\xEA\xEE\xEC\xE5\xED\xE4\xF3\xE5\xF2\xF1\xFF\x20\xED\xE5\x20\xEE\xF2\xF5\xEE\xE4\xE8\xF2\xFC\x20\xE4\xE0\xEB\xE5\xEA\xEE\x20\xEE\xF2\x20\xEA\xEE\xEC\xEF\xFC\xFE\xF2\xE5\xF0\xE0\x2E\x2E\x2E"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.Text(u8("\x2E\x2E\x2E\xF7\xF2\xEE\xE1\xFB\x20\xE2\xEE\xE2\xF0\xE5\xEC\xFF\x20\xF1\xF0\xE5\xE0\xE3\xE8\xF0\xEE\xE2\xE0\xF2\xFC\x20\xED\xE0\x20\xEE\xF2\xE2\xE5\xF2\xFB\x20\xE0\xE4\xEC\xE8\xED\xEE\xE2\x2E"))
            imgui.NewLine()
			imgui.SameLine(100)
            imgui.NewLine() imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8("\xC0\xE2\xF2\xEE\xF0\x20\xEE\xF0\xE8\xE3\xE8\xED\xE0\xEB\xFC\xED\xEE\xE3\xEE\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x3A\x20\xC4\xE0\xED\xE8\xE8\xEB\x20\xCA\xEE\xEF\xED\xE5\xE2"))
			imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8("\xC3\xF0\xF3\xEF\xEF\xE0\x3A\x20\x76\x6B\x2E\x63\x6F\x6D\x2F\x6B\x73\x63\x72\x69\x70\x74\x73\x20\x20\x20"))
            imgui.SameLine(290) if imgui.Button(u8("\xCF\xE5\xF0\xE5\xE9\xF2\xE8")) then os.execute('explorer "https://vk.com/kscripts"') end
            imgui.NewLine()
            imgui.SameLine(100) imgui.Text(u8("\xC0\xE2\xF2\xEE\xF0\x20\xEF\xE5\xF0\xE5\xE4\xE5\xEB\xEA\xE8\x3A\x20\x66\x6C\x75\x70\x69\x66\x6C\x75\x66\x69\x20\x20\x20"))
            imgui.NewLine()
            imgui.SameLine(100) imgui.Text(u8("\xC5\xF1\xEB\xE8\x20\xE5\xF1\xF2\xFC\x20\xE2\xEE\xEF\xF0\xEE\xF1\xFB\x20\xEF\xE8\xF8\xE8\xF2\xE5\x20\xE2\x20\xF2\xE5\xEC\xF3"))
			imgui.NewLine() imgui.NewLine()
			imgui.SameLine(100) imgui.Text(u8("\xC2\xE5\xF0\xF1\xE8\xFF\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x3A\x20")..thisScript().version)
		    imgui.SameLine() imgui.Text(u8("\x28\x20\xCD\xE0\xE2\xE5\xF0\xED\xEE\x20\xEF\xEE\xF1\xEB\xE5\xE4\xED\xFF\xFF\x20\xE2\xE5\xF0\xF1\xE8\xFF\x20\x29"))
			imgui.EndGroup()
		end
        imgui.End()
    end
    if theme9_window.v then
        imgui.SetNextWindowSize(imgui.ImVec2(600, 700), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2),
                               imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xEA\xE0\x20\xF2\xE5\xEC\xFB\x20\x39"), theme9_window, 0)
        imgui.Text(u8("\xCD\xE0\xF1\xF2\xF0\xEE\xE9\xF2\xE5\x20\xF6\xE2\xE5\xF2\xE0\x20\xE4\xEB\xFF\x20\xF2\xE5\xEC\xFB\x20\x39"))
        imgui.Separator()
        imgui.PushItemWidth(200)
    
        local color_names = {
            {key = "WindowBg", label = u8("\xD4\xEE\xED\x20\xEE\xEA\xED\xE0")},
            {key = "ChildWindowBg", label = u8("\xD4\xEE\xED\x20\xE4\xEE\xF7\xE5\xF0\xED\xE5\xE3\xEE\x20\xEE\xEA\xED\xE0")},
            {key = "Text", label = u8("\xD6\xE2\xE5\xF2\x20\xF2\xE5\xEA\xF1\xF2\xE0")},
            {key = "PopupBg", label = u8("\xD4\xEE\xED\x20\xE2\xF1\xEF\xEB\xFB\xE2\xE0\xFE\xF9\xE5\xE3\xEE\x20\xEE\xEA\xED\xE0")},
            {key = "Border", label = u8("\xC3\xF0\xE0\xED\xE8\xF6\xE0")},
            {key = "BorderShadow", label = u8("\xD2\xE5\xED\xFC\x20\xE3\xF0\xE0\xED\xE8\xF6\xFB")},
            {key = "FrameBg", label = u8("\xD4\xEE\xED\x20\xF0\xE0\xEC\xEA\xE8")},
            {key = "FrameBgHovered", label = u8("\xD4\xEE\xED\x20\xF0\xE0\xEC\xEA\xE8\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "FrameBgActive", label = u8("\xD4\xEE\xED\x20\xE0\xEA\xF2\xE8\xE2\xED\xEE\xE9\x20\xF0\xE0\xEC\xEA\xE8")},
            {key = "TitleBg", label = u8("\xD4\xEE\xED\x20\xE7\xE0\xE3\xEE\xEB\xEE\xE2\xEA\xE0")},
            {key = "TitleBgCollapsed", label = u8("\xD4\xEE\xED\x20\xF1\xE2\xE5\xF0\xED\xF3\xF2\xEE\xE3\xEE\x20\xE7\xE0\xE3\xEE\xEB\xEE\xE2\xEA\xE0")},
            {key = "TitleBgActive", label = u8("\xD4\xEE\xED\x20\xE0\xEA\xF2\xE8\xE2\xED\xEE\xE3\xEE\x20\xE7\xE0\xE3\xEE\xEB\xEE\xE2\xEA\xE0")},
            {key = "MenuBarBg", label = u8("\xD4\xEE\xED\x20\xEC\xE5\xED\xFE")},
            {key = "ScrollbarBg", label = u8("\xD4\xEE\xED\x20\xF1\xEA\xF0\xEE\xEB\xEB\xE1\xE0\xF0\xE0")},
            {key = "ScrollbarGrab", label = u8("\xD5\xE2\xE0\xF2\x20\xF1\xEA\xF0\xEE\xEB\xEB\xE1\xE0\xF0\xE0")},
            {key = "ScrollbarGrabHovered", label = u8("\xD5\xE2\xE0\xF2\x20\xF1\xEA\xF0\xEE\xEB\xEB\xE1\xE0\xF0\xE0\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "ScrollbarGrabActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xFB\xE9\x20\xF5\xE2\xE0\xF2\x20\xF1\xEA\xF0\xEE\xEB\xEB\xE1\xE0\xF0\xE0")},
            {key = "ComboBg", label = u8("\xD4\xEE\xED\x20\xEA\xEE\xEC\xE1\xEE\xE1\xEE\xEA\xF1\xE0")},
            {key = "CheckMark", label = u8("\xD7\xE5\xEA\xEC\xE0\xF0\xEA\xE0")},
            {key = "SliderGrab", label = u8("\xCF\xEE\xEB\xE7\xF3\xED\xEE\xEA")},
            {key = "SliderGrabActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xFB\xE9\x20\xEF\xEE\xEB\xE7\xF3\xED\xEE\xEA")},
            {key = "Button", label = u8("\xCA\xED\xEE\xEF\xEA\xE0")},
            {key = "ButtonHovered", label = u8("\xCA\xED\xEE\xEF\xEA\xE0\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "ButtonActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xE0\xFF\x20\xEA\xED\xEE\xEF\xEA\xE0")},
            {key = "Header", label = u8("\xC7\xE0\xE3\xEE\xEB\xEE\xE2\xEE\xEA")},
            {key = "HeaderHovered", label = u8("\xC7\xE0\xE3\xEE\xEB\xEE\xE2\xEE\xEA\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "HeaderActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xFB\xE9\x20\xE7\xE0\xE3\xEE\xEB\xEE\xE2\xEE\xEA")},
            {key = "ResizeGrip", label = u8("\xC3\xF0\xE8\xEF\x20\xE4\xEB\xFF\x20\xE8\xE7\xEC\xE5\xED\xE5\xED\xE8\xFF\x20\xF0\xE0\xE7\xEC\xE5\xF0\xE0")},
            {key = "ResizeGripHovered", label = u8("\xC3\xF0\xE8\xEF\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "ResizeGripActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xFB\xE9\x20\xE3\xF0\xE8\xEF")},
            {key = "CloseButton", label = u8("\xCA\xED\xEE\xEF\xEA\xE0\x20\xE7\xE0\xEA\xF0\xFB\xF2\xE8\xFF")},
            {key = "CloseButtonHovered", label = u8("\xCA\xED\xEE\xEF\xEA\xE0\x20\xE7\xE0\xEA\xF0\xFB\xF2\xE8\xFF\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "CloseButtonActive", label = u8("\xC0\xEA\xF2\xE8\xE2\xED\xE0\xFF\x20\xEA\xED\xEE\xEF\xEA\xE0\x20\xE7\xE0\xEA\xF0\xFB\xF2\xE8\xFF")},
            {key = "PlotLines", label = u8("\xC3\xF0\xE0\xF4\xE8\xEA\x20\xEB\xE8\xED\xE8\xE9")},
            {key = "PlotLinesHovered", label = u8("\xC3\xF0\xE0\xF4\xE8\xEA\x20\xEB\xE8\xED\xE8\xE9\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "PlotHistogram", label = u8("\xC3\xE8\xF1\xF2\xEE\xE3\xF0\xE0\xEC\xEC\xE0")},
            {key = "PlotHistogramHovered", label = u8("\xC3\xE8\xF1\xF2\xEE\xE3\xF0\xE0\xEC\xEC\xE0\x20\xEF\xF0\xE8\x20\xED\xE0\xE2\xE5\xE4\xE5\xED\xE8\xE8")},
            {key = "TextSelectedBg", label = u8("\xC2\xFB\xE4\xE5\xEB\xE5\xED\xE8\xE5\x20\xF2\xE5\xEA\xF1\xF2\xE0")},
            {key = "ModalWindowDarkening", label = u8("\xC7\xE0\xF2\xE5\xEC\xED\xE5\xED\xE8\xE5\x20\xEC\xEE\xE4\xE0\xEB\xFC\xED\xEE\xE3\xEE\x20\xEE\xEA\xED\xE0")}
        }
        
        for i, color in ipairs(color_names) do
            imgui.Separator()
            imgui.Text(color.label)
            local col = imgui.ImFloat4(
                ini.theme9[color.key .. "_r"] or 1.0,
                ini.theme9[color.key .. "_g"] or 1.0,
                ini.theme9[color.key .. "_b"] or 1.0,
                ini.theme9[color.key .. "_a"] or 1.0
            )
        
            if imgui.ColorEdit4(color.key, col) then
                ini.theme9[color.key .. "_r"] = col.v[1]
                ini.theme9[color.key .. "_g"] = col.v[2]
                ini.theme9[color.key .. "_b"] = col.v[3]
                ini.theme9[color.key .. "_a"] = col.v[4]
                inicfg.save(def, directIni)
                --print("[DEBUG] "..color.key.." changed: ", col.v[1], col.v[2], col.v[3], col.v[4])
            end
        end  
        imgui.PopItemWidth()
        imgui.SetCursorPos(imgui.ImVec2(500, 660))
        if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(80, 25)) then
            theme9_window.v = false
        end
        imgui.End()
    end
    
    if changelog_window.v then
		imgui.ShowCursor = true
		imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.SetNextWindowSize(imgui.ImVec2(400, 500), imgui.Cond.FirstUseEver)
		imgui.Begin(' ', changelog_window, 2)
		imgui.SameLine(150)
		imgui.Text(u8("\xD1\xEF\xE8\xF1\xEE\xEA\x20\xE8\xE7\xEC\xE5\xED\xE5\xED\xE8\xE9"))
		imgui.NewLine()
		imgui.BeginGroup()		
			imgui.Separator() imgui.NewLine() imgui.NewLine() imgui.SameLine(170)
			imgui.Text(u8'V 1.3') imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8("\x31\x2E\x20\xD1\xE4\xE5\xEB\xE0\xEB\x20\xEA\xF0\xF3\xF2\xEE\xE9\x20\xEC\xE5\xF2\xEE\xE4\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\xE0\x22\x2E")) imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8("\x32\x2E\x20\xCA\xEE\xEB\xEB\xE8\xE7\xE8\xFF\x20\xEE\xE1\xFA\xE5\xEA\xF2\xEE\xE2\x20\xF0\xE0\xE4\xE8\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\xE0\x2E")) imgui.NewLine() imgui.NewLine()
			imgui.SameLine(15) imgui.Text(u8("\x33\x2E\x20\xCF\xEE\xEB\xED\xE0\xFF\x20\xEB\xE5\xE3\xE8\xF2\xED\xEE\xF1\xF2\xFC\x20\xE2\xF1\xE5\xF5\x20\xF0\xE0\xE1\xEE\xF2\x28\xEE\xF2\xE2\xE5\xF7\xE0\xFE\x29\x2E")) imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\x34\x2E\x20\xC4\xEE\xE1\xE0\xE2\xEB\xE5\xED\xE0\x20\xEA\xE0\xF1\xF2\xEE\xEC\xED\xE0\xFF\x20\xF2\xE5\xEC\xE0")) imgui.NewLine() imgui.NewLine()
            imgui.SameLine(15) imgui.Text(u8("\x35\x2E\x20\xC2\xF1\xFF\xEA\xF3\xFE\x20\xF5\xF0\xE5\xED\xFC\x20\xE4\xEE\xE1\xE0\xE2\xE8\xEB\x20\xF7\xE8\xF1\xF2\xEE\x20\xE4\xEB\xFF\x20\xEA\xF0\xE0\xF1\xEE\xF2\xFB")) imgui.NewLine() imgui.NewLine()
		imgui.EndGroup()
		imgui.SetCursorPos(imgui.ImVec2(300, 460))
		if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(80, 25)) then 
			changelog_window.v = false
		end
		imgui.End()
	end
    if crash.v then
        imgui.Begin(' ', crash, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
    end

    if quest_window.v then
        imgui.SetNextWindowSize(imgui.ImVec2(400, 250), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowPos(
            imgui.ImVec2(imgui.GetIO().DisplaySize.x/2, imgui.GetIO().DisplaySize.y/2),
            imgui.Cond.FirstUseEver,
            imgui.ImVec2(0.5, 0.5)
        )
        imgui.ShowCursor = main_windows_state.v
        imgui.Begin(u8("\xD1\xF2\xE0\xF2\xE8\xF1\xF2\xE8\xEA\xE0\x20\xEA\xE2\xE5\xF1\xF2\xEE\xE2"), quest_window, 0)
        if not questsTakenByBot then
            for i = 1, 4 do
                local progress = questProgress[i] or 0
                local maxProg = questMax[i] or 1
                imgui.Text(u8("\xCA\xE2\xE5\xF1\xF2\x20")..i..": "..progress.."/"..maxProg)
                if maxProg > 0 then
                    imgui.ProgressBar(progress / maxProg, imgui.ImVec2(-1, 20))
                end
            end
        else
            imgui.Text(u8("\xC1\xEE\xF2\x20\xED\xE5\x20\xE0\xEA\xF2\xE8\xE2\xE5\xED\x20\xE8\xEB\xE8\x20\xEA\xE2\xE5\xF1\xF2\xFB\x20\xE2\xE7\xFF\xF2\xFB\x20\xE2\xF0\xF3\xF7\xED\xF3\xFE\x2E"))
        end
        if imgui.Button(u8("\xC7\xE0\xEA\xF0\xFB\xF2\xFC"), imgui.ImVec2(80, 25)) then
            quest_window.v = false
        end
        imgui.End()
    end

    if calc_window.v then
        drawCalculatorWindow()
    end
end

function uu()
    for i = 0,8 do
        vkladki[i] = false
    end
end

function calculateScenario(roleIdx, vip, axe)
    local result = ''
    if roleIdx == 0 then -- Начальная ферма
        if vip and axe then
            result = u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x31\x33\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x2E\x32\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x31\x32\x35\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x33\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x35\x30\x2E\x30\x30\x30\x24")
        elseif vip and not axe then
            result = u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x31\x33\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x35\x30\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x31\x32\x35\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x33\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x35\x2E\x36\x30\x30\x24")
        elseif not vip and axe then
            result = u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x31\x33\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x2E\x32\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x35\x30\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x36\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x35\x30\x2E\x30\x30\x30\x24")
        else
            result = u8("\xCD\xE0\xF7\xE0\xEB\xFC\xED\xE0\xFF\x20\xF4\xE5\xF0\xEC\xE0\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x31\x33\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x34\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x35\x30\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x36\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x35\x30\x2E\x30\x30\x30\x24")
        end
    elseif roleIdx == 1 then -- Тракторист
        if vip and axe then
            result = u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x39\x37\x35\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x33\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x32\x20\xF7\xE0\xF1\xE0\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x32\x32\x2E\x34\x32\x35\x2E\x30\x30\x30\x24")
        elseif vip and not axe then
            result = u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x33\x32\x35\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x33\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x32\x20\xF7\xE0\xF1\xE0\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x37\x2E\x34\x37\x35\x2E\x30\x30\x30\x24")
        elseif not vip and axe then
            result = u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x39\x37\x35\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x34\x36\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x34\x20\xF7\xE0\xF1\xE0\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x34\x34\x2E\x38\x35\x30\x2E\x30\x30\x30\x24")
        else
            result = u8("\xD2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x33\x37\x35\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x34\x36\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x34\x20\xF7\xE0\xF1\xE0\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x37\x2E\x32\x35\x30\x2E\x30\x30\x30\x24")
        end
    elseif roleIdx == 2 then -- Комбайнер
        if vip and axe then
            result = u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x34\x20\xEC\xE8\xED\xF3\xF2\xFB\x20\x31\x35\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x33\x37\x34\x2E\x34\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x32\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x31\x20\xF7\xE0\xF1\x20\x33\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x38\x2E\x32\x32\x39\x2E\x30\x30\x30\x24")
        elseif vip and not axe then
            result = u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x34\x20\xEC\xE8\xED\xF3\xF2\xFB\x20\x31\x35\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x39\x33\x2E\x36\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x32\x32\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x31\x20\xF7\xE0\xF1\x20\x33\x35\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x32\x2E\x30\x35\x39\x2E\x32\x30\x30\x24")
        elseif not vip and axe then
            result = u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x34\x20\xEC\xE8\xED\xF3\xF2\xFB\x20\x31\x35\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x33\x37\x34\x2E\x34\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x34\x34\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x33\x20\xF7\xE0\xF1\xE0\x20\x31\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x36\x2E\x34\x35\x36\x2E\x30\x30\x30\x24")
        else
            result = u8("\xCA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x34\x20\xEC\xE8\xED\xF3\xF2\xFB\x20\x31\x35\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x39\x33\x2E\x36\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\x34\x34\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\x33\x20\xF7\xE0\xF1\xE0\x20\x31\x30\x20\xEC\xE8\xED\xF3\xF2\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x34\x2E\x31\x31\x38\x2E\x34\x30\x30\x24")
        end
    elseif roleIdx == 3 then -- Водитель кукурузника
        if vip and axe then
            result = u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x36\x20\xEC\xE8\xED\xF3\xF2\x20\x34\x30\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x38\x33\x37\x2E\x32\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\xED\xE5\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xED\xEE\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\xD2\xFB\x20\xE8\x20\xF2\xE0\xEA\x20\x62\x6F\x73\x73\x20\x6F\x66\x20\x74\x68\x69\x73\x20\x67\x79\x6D\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x30\x20\xF0\xE5\xE9\xF1\xEE\xE2\x3D\x38\x2E\x33\x37\x32\x2E\x30\x30\x30\x24")
        elseif vip and not axe then
            result = u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x2B\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x36\x20\xEC\xE8\xED\xF3\xF2\x20\x34\x30\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x32\x38\x30\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\xED\xE5\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xED\xEE\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\xD2\xFB\x20\xE8\x20\xF2\xE0\xEA\x20\x62\x6F\x73\x73\x20\x6F\x66\x20\x74\x68\x69\x73\x20\x67\x79\x6D\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x30\x20\xF0\xE5\xE9\xF1\xEE\xE2\x3D\x32\x2E\x38\x30\x30\x2E\x30\x30\x30\x24")
        elseif not vip and axe then
            result = u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xC0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x36\x20\xEC\xE8\xED\xF3\xF2\x20\x34\x30\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x38\x33\x37\x2E\x32\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\xED\xE5\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xED\xEE\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\xD2\xFB\x20\xE8\x20\xF2\xE0\xEA\x20\x62\x6F\x73\x73\x20\x6F\x66\x20\x74\x68\x69\x73\x20\x67\x79\x6D\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x30\x20\xF0\xE5\xE9\xF1\xEE\xE2\x3D\x38\x2E\x33\x37\x32\x2E\x30\x30\x30\x24")
        else
            result = u8("\xCA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\x20\x2B\x20\xE1\xE5\xE7\x20\x56\x49\x50\x20\x2B\x20\xE1\xE5\xE7\x20\xE0\xEA\xF1\xE5\xF1\xF1\xF3\xE0\xF0\xE0\x3A\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xF0\xE5\xE9\xF1\xE0\x3A\x20\x36\x20\xEC\xE8\xED\xF3\xF2\x20\x34\x30\x20\xF1\xE5\xEA\xF3\xED\xE4\n") ..
                     u8("\xC7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x32\x38\x30\x2E\x30\x30\x30\x24\n") ..
                     u8("\xC2\xF1\xE5\xE3\xEE\x20\xF0\xE5\xE9\xF1\xEE\xE2\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x3A\x20\xED\xE5\x20\xEE\xE3\xF0\xE0\xED\xE8\xF7\xE5\xED\xED\xEE\n") ..
                     u8("\xC2\xF0\xE5\xEC\xFF\x20\xE4\xEE\x20\xEF\xEE\xE2\xFB\xF8\xE5\xED\xE8\xFF\x20\xED\xE0\xE2\xFB\xEA\xE0\x3A\x20\xD2\xFB\x20\xE8\x20\xF2\xE0\xEA\x20\x62\x6F\x73\x73\x20\x6F\x66\x20\x74\x68\x69\x73\x20\x67\x79\x6D\n") ..
                     u8("\xC2\xE5\xF1\xFC\x20\xE7\xE0\xF0\xE0\xE1\xEE\xF2\xEE\xEA\x3A\x20\x31\x30\x20\xF0\xE5\xE9\xF1\xEE\xE2\x3D\x32\x2E\x38\x30\x30\x2E\x30\x30\x30\x24")
        end
    end
    scenarioText = result
end
-------------------------------Жизненно необходимые потоки-------------------------------------------
huy222 = true
lua_thread.create(function() 
    while true do
        wait(0)
        if ww == true then
            wait(2000)
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
            end setGameKeyState(0,0) setGameKeyState(14, 0)end)
        end
    end
end)
-------------------------------Я знаю можно было проще-------------------------------------------
function rideToTractor(x, y, z, speed, radius)
    radius = radius or 1.2
    turnRight = false
    turnLeft = false
    while true do
        wait(0)
        if not work1 then
            turnRight = false
            turnLeft = false
            break
        end
        local veh = getCarCharIsUsing(PLAYER_PED)
        if not isCharInCar(PLAYER_PED, veh) then
            turnRight = false
            turnLeft = false
            break
        end
        local posX, posY, posZ = GetCoordinates()
        local pX, pY = x - posX, y - posY
        local targetHeading = getHeadingFromVector2d(pX, pY)
        local carHeading = getCarHeading(veh)
        local angsum = 360 - carHeading + targetHeading
        if angsum > 360 then
            angsum = angsum - 360
        end
        if angsum < 180 then
            local diff = angsum
            if diff > 15 then
                setGameKeyState(0, -255) -- Резко влево
                turnLeft = true
                turnRight = false
            elseif diff > 5 then
                setGameKeyState(0, -120) -- Средне влево
                turnLeft = true
                turnRight = false
            elseif diff > 1 then
                setGameKeyState(0, -40) -- Плавно влево
                turnLeft = true
                turnRight = false
            else
                setGameKeyState(0, 0) -- Прямо
                turnLeft = false
                turnRight = false
            end
        else
            local diff = 360 - angsum
            if diff > 15 then
                setGameKeyState(0, 255) -- Резко вправо
                turnRight = true
                turnLeft = false
            elseif diff > 5 then
                setGameKeyState(0, 120) -- Средне вправо
                turnRight = true
                turnLeft = false
            elseif diff > 1 then
                setGameKeyState(0, 40) -- Плавно вправо
                turnRight = true
                turnLeft = false
            else
                setGameKeyState(0, 0) -- Прямо
                turnRight = false
                turnLeft = false
            end
        end
        local dista = getDistanceBetweenCoords3d(x, y, z, posX, posY, z)
        local speedNow = getCarSpeed(veh)
        if dista < radius then
            turnRight = false
            turnLeft = false
            setGameKeyState(6, 0)
            setGameKeyState(16, 0)
            break
        end
        local targetSpeed = speed
        if dista < 15 then targetSpeed = speed * 0.15 end
        if speedNow < targetSpeed and not ww then
            setGameKeyState(6, 0)
            setGameKeyState(16, 255) -- Газ
        elseif speedNow > targetSpeed and not ww then
            setGameKeyState(16, 0)
            setGameKeyState(6, 255) -- Тормоз
        end
    end
end

function rideToCombine(x, y, z, speed, radius)
    radius = radius or 1.2
    turnRight = false
    turnLeft = false
    while true do
        wait(0)
        if not work2 then
            turnRight = false
            turnLeft = false
            break
        end
        local veh = getCarCharIsUsing(PLAYER_PED)
        if not isCharInCar(PLAYER_PED, veh) then
            turnRight = false
            turnLeft = false
            break
        end
        local posX, posY, posZ = GetCoordinates()
        local pX, pY = x - posX, y - posY
        local targetHeading = getHeadingFromVector2d(pX, pY)
        local carHeading = getCarHeading(veh)
        local angsum = 360 - carHeading + targetHeading
        if angsum > 360 then
            angsum = angsum - 360
        end
        if angsum < 180 then
            local diff = angsum
            if diff > 15 then
                setGameKeyState(0, -255) -- Резко влево
                turnLeft = true
                turnRight = false
            elseif diff > 5 then
                setGameKeyState(0, -120) -- Средне влево
                turnLeft = true
                turnRight = false
            elseif diff > 1 then
                setGameKeyState(0, -40) -- Плавно влево
                turnLeft = true
                turnRight = false
            else
                setGameKeyState(0, 0) -- Прямо
                turnLeft = false
                turnRight = false
            end
        else
            local diff = 360 - angsum
            if diff > 15 then
                setGameKeyState(0, 255) -- Резко вправо
                turnRight = true
                turnLeft = false
            elseif diff > 5 then
                setGameKeyState(0, 120) -- Средне вправо
                turnRight = true
                turnLeft = false
            elseif diff > 1 then
                setGameKeyState(0, 40) -- Плавно вправо
                turnRight = true
                turnLeft = false
            else
                setGameKeyState(0, 0) -- Прямо
                turnRight = false
                turnLeft = false
            end
        end
        local dista = getDistanceBetweenCoords3d(x, y, z, posX, posY, z)
        local speedNow = getCarSpeed(veh)
        if dista < radius then
            turnRight = false
            turnLeft = false
            setGameKeyState(6, 0)
            setGameKeyState(16, 0)
            break
        end
        local targetSpeed = speed
        if dista < 35 then targetSpeed = speed * 0.15 end
        if dista < 10 then targetSpeed = speed * 0.07 end

        if speedNow < targetSpeed and not ww then
            setGameKeyState(6, 0)
            setGameKeyState(16, 255) -- Газ
        elseif speedNow > targetSpeed and not ww then
            setGameKeyState(16, 0)
            setGameKeyState(6, 255) -- Тормоз
        end

    end
end

local function startRoute(routeName)
    vars.route.state = true
    vars.route.name = routeName
    vars.route.packets = 0
    vars.route.currentPos = { x = -1, y = -1, z = -1 }
    var_0_10.v = true
    local filePath = getWorkingDirectory()..'\\PacketRecorder\\'..routeName..'.route'
    if doesFileExist(filePath) then
        msg(("\xCC\xE0\xF0\xF8\xF0\xF3\xF2\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE0\xE9\xE4\xE5\xED\x20\xEF\xEE\x20\xEF\xF3\xF2\xE8\x20")..filePath)
        while vars.route.state and work3 do
            wait(100)
        end
    else
        msg(("\xCE\xF8\xE8\xE1\xEA\xE0\x3A\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20")..routeName..("\x20\xED\xE5\x20\xED\xE0\xE9\xE4\xE5\xED\x20\xEF\xEE\x20\xEF\xF3\xF2\xE8\x20")..filePath)
        work3 = false
    end
end
function toggleNoCollisionObjects(enableCollision)
    for _, handle in ipairs(getAllObjects()) do
        if doesObjectExist(handle) then
            local model = getObjectModel(handle)
            for _, objId in ipairs(noCollisionObjects) do
                if model == objId then
                    setObjectCollision(handle, enableCollision)
                end
            end
        end
    end
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
    table.sort(vehicles, function(a, b)
        local aX, aY, aZ = getCarCoordinates(a)
        local bX, bY, bZ = getCarCoordinates(b)
        return getDistanceBetweenCoords3d(aX, aY, aZ, unpack(pCoords)) < getDistanceBetweenCoords3d(bX, bY, bZ, unpack(pCoords))
    end)
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
        sampShowDialog(6405, ("\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x20\x7B\x46\x46\x30\x30\x30\x30\x7D\xCF\xF0\xEE\xE8\xE7\xEE\xF8\xEB\xE0\x20\xEE\xF8\xE8\xE1\xEA\xE0\x21"), ("\x7B\x46\x46\x46\x46\x46\x46\x7D\xDD\xF2\xEE\xF2\x20\xF1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x20\xEC\xEE\xE6\xE5\xF2\x20\xE1\xFB\xF2\xFC\x20\xEB\xEE\xE6\xED\xFB\xEC\x2C\x20\xE5\xF1\xEB\xE8\x20\xE2\xFB\x20\n\xE8\xF1\xEF\xEE\xEB\xFC\xE7\xEE\xE2\xE0\xEB\xE8\x20\xF1\xEA\xF0\xE8\xEF\xF2\x20\x41\x75\x74\x6F\x52\x65\x62\x6F\x6F\x74\x20\n\xCA\x20\xF1\xEE\xE6\xE0\xEB\xE5\xED\xE8\xFE\x20\xF1\xEA\xF0\xE8\xEF\xF2\x20\x7B\x46\x31\x43\x42\x30\x39\x7D\x46\x61\x72\x6D\x2D\x42\x6F\x74\x7B\x46\x46\x46\x46\x46\x46\x7D\x20\xE7\xE0\xE2\xE5\xF0\xF8\xE8\xEB\xF1\xFF\x20\xED\xE5\xF3\xE4\xE0\xF7\xED\xEE\n\xC5\xF1\xEB\xE8\x20\xE2\xFB\x20\xF5\xEE\xF2\xE8\xF2\xE5\x20\xEF\xEE\xEC\xEE\xF7\xFC\x20\xF0\xE0\xE7\xF0\xE0\xE1\xEE\xF2\xF7\xE8\xEA\xF3\n\xD2\xEE\x20\xEC\xEE\xE6\xE5\xF2\xE5\x20\xEE\xEF\xE8\xF1\xE0\xF2\xFC\x20\xEF\xF0\xE8\x20\xEA\xE0\xEA\xEE\xEC\x20\xE4\xE5\xE9\xF1\xF2\xE2\xE8\xE8\x20\xEF\xF0\xEE\xE8\xE7\xEE\xF8\xEB\xE0\x20\xEE\xF8\xE8\xE1\xEA\xE0\n\xD2\xE5\xEC\xE0\x20\xF1\xEA\xF0\xE8\xEF\xF2\xE0\x3A\x20\x7B\x30\x30\x39\x39\x43\x43\x7D\x68\x74\x74\x70\x73\x3A\x2F\x2F\x77\x77\x77\x2E\x62\x6C\x61\x73\x74\x2E\x68\x6B\x2F\x74\x68\x72\x65\x61\x64\x73\x2F\x32\x33\x37\x32\x31\x39"), ("\xCE\xCA"), "", DIALOG_STYLE_MSGBOX)
        SCM(("\xCF\xF0\xEE\xE8\xE7\xEE\xF8\xEB\xE0\x20\xEE\xF8\xE8\xE1\xEA\xE0"))
        showCursor(false, false)
    end
end

function SCM(arg1)
    if invisible.v then
        print(arg1)
    else
        sampAddChatMessage("[Farm-bot]: {FFFFFF}"..arg1, 0xF1CB09)
    end
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
--------------------------------------------------------TELEGRAM----------------------------------------------------

---------------------------------------------https://youtu.be/XZF91nSs7wA-------------------------------------------

--------------------------------------------------------------------------------------------------------------------
function threadHandle(runner, url, args, resolve, reject)
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
    elseif status == 'canceled' then
        reject(status)
    else
        reject('unknown error')
    end

    t:cancel(0)
end
function requestRunner()
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
        threadHandle(runner, url, args, resolve, reject)
    end)
end

function encodeUrl(str)
    str = str:gsub(' ', '%+')
    str = str:gsub('\n', '%%0A')
    return u8:encode(str, 'CP1251')
end

function sendTelegramNotification(msg)
    msg = msg:gsub('{......}', '')
    msg = encodeUrl(msg)
    async_http_request('https://api.telegram.org/bot' .. token .. '/sendMessage?chat_id=' .. chat_id .. '&text=' .. msg, '', function(result)
    end)
end

function get_telegram_updates()
    while not updateid do wait(1) end
    local runner = requestRunner()
    local reject = function() end
    local args = ''
    while true do
        url = 'https://api.telegram.org/bot'..token..'/getUpdates?chat_id='..chat_id..'&offset=-1'
        threadHandle(runner, url, args, processing_telegram_messages, reject)
        wait(0)
    end
end

function processing_telegram_messages(result)
    if result then
        local proc_table = decodeJson(result)
        if proc_table.ok then
            if #proc_table.result > 0 then
                local res_table = proc_table.result[1]
                if res_table then
                    if res_table.update_id ~= updateid then
                        updateid = res_table.update_id
                        local message_from_user = res_table.message.text
                        if message_from_user then
                            local text = u8:decode(message_from_user) .. ' '
                            if text:match('^!stats') then
                                waitingForStatsTelegram = true
                                sampSendChat("/stats")

                            elseif text:match('^!send') then
                                local sendMessageTelegram = text:match('^!send (.+)')
                                sampSendChat(sendMessageTelegram)
                                sendTelegramNotification(("\xD1\xEE\xEE\xE1\xF9\xE5\xED\xE8\xE5\x20\xEE\xF2\xEF\xF0\xE0\xE2\xEB\xE5\xED\xEE\x20\xE2\x20\xF7\xE0\xF2\x20\xE8\xE3\xF0\xFB\x3A\x20") .. sendMessageTelegram)

                            elseif text:match('^!exit') then
                                sampProcessChatInput('/q')
                                sendTelegramNotification(("\xC2\xFB\xF8\xE5\xEB\x21"))
                            elseif text:match('^!hp') then
                                local health = getCharHealth(PLAYER_PED)
                                sendTelegramNotification(("\xC2\xE0\xF8\xE5\x20\xF5\xEF\x3A\x20")..health)
                            elseif text:match('^!start') then
                                local job = text:match('^!start (%a+)')
                                if job then
                                    if job == "ferma" then
                                        if not state then
                                            state = true
                                            state_taked = false
                                            sendTelegramNotification(("\xC1\xEE\xF2\x20\xED\xE0\xF7\xE0\xEB\xFC\xED\xEE\xE9\x20\xF4\xE5\xF0\xEC\xFB\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                        else
                                            sendTelegramNotification(("\xC1\xEE\xF2\x20\xF3\xE6\xE5\x20\xF0\xE0\xE1\xEE\xF2\xE0\xE5\xF2\x21"))
                                        end

                                    elseif job == "traktorist" then
                                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                                            if 531 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                                work1 = true
                                                gopay = false
                                                value1 = 0
                                                num = 0
                                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                                    sampSendChat('/engine')
                                                end
                                                sendTelegramNotification(("\xC1\xEE\xF2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\xE0\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                    
                                                lua_thread.create(function() 
                                                    rideToTractor(-118.1747, 97.4916, 3.0650, 60)
                                                end)
                                            else
                                                sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) 
                                            end
                                        else
                                            sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE5\x2E")) 
                                        end                                    
                                    elseif job == "kombainer" then
                                        if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                                            if 532 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                                work2 = true
                                                value1 = 0
                                                num = 0
                                                if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                                    sampSendChat('/engine')
                                                end
                                                sendTelegramNotification(("\xC1\xEE\xF2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                    
                                                lua_thread.create(function() 
                                                    rideToCombine(-185.1780, -84.2181, 4.0672, 45) 
                                                end)
                                            else
                                                sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) 
                                            end
                                        else
                                            sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\x2E")) 
                                        end 
                                    elseif job == "kukuruznik" then
                                        local route = text:match('^!start kukuruznik (%d+)')
                                        if route then
                                            route = tonumber(route)
                                            if isCharInCar(PLAYER_PED, getCarCharIsUsing(PLAYER_PED)) then
                                                if 512 == getCarModel(getCarCharIsUsing(PLAYER_PED)) then
                                                    work3 = true
                                                    if not isCarEngineOn(getCarCharIsUsing(PLAYER_PED)) then
                                                        sampSendChat('/engine')
                                                    end
                                                    if route == 1 then
                                                        lua_thread.create(function()
                                                            startRoute("leti")
                                                            letiCompleted = true
                                                            while work3 do
                                                                startRoute("leti3")
                                                            end
                                                        end)
                                                        sendTelegramNotification(("\xC1\xEE\xF2\x20\xE2\xEE\xE4\xE8\xF2\xE5\xEB\xFF\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0\x20\xE2\xEA\xEB\xFE\xF7\xE5\xED\x20\xF1\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xEE\xEC\x20\x31\x21"))
                                                    else
                                                        sendTelegramNotification(("\xC2\xF0\xE5\xEC\xE5\xED\xED\xEE\x20\xED\xE5\xF2\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\xE0\x20\xE4\xEB\xFF\x20\xE2\xFB\xE1\xF0\xE0\xED\xED\xEE\xE3\xEE\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0\x2E"))
                                                        work3 = false
                                                    end
                                                else
                                                    sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                                                end
                                            else
                                                sendTelegramNotification(("\xC2\xFB\x20\xED\xE5\x20\xE2\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE5\x2E"))
                                            end
                                        else
                                            sendTelegramNotification(("\xD3\xEA\xE0\xE6\xE8\xF2\xE5\x20\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x20\xE4\xEB\xFF\x20\xE2\xEE\xE4\xE8\xF2\xE5\xEB\xFF\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0\x3A\x20\x21\x73\x74\x61\x72\x74\x20\x6B\x75\x6B\x75\x72\x75\x7A\x6E\x69\x6B\x20\x31"))
                                        end
                                    else
                                        sendTelegramNotification(("\xCD\xE5\xE2\xE5\xF0\xED\xE0\xFF\x20\xF0\xE0\xE1\xEE\xF2\xE0\x2E\x20\xC4\xEE\xF1\xF2\xF3\xEF\xED\xFB\xE5\x20\xF0\xE0\xE1\xEE\xF2\xFB\x3A\x20\x66\x65\x72\x6D\x61\x2C\x20\x74\x72\x61\x6B\x74\x6F\x72\x69\x73\x74\x2C\x20\x6B\x6F\x6D\x62\x61\x69\x6E\x65\x72\x2C\x20\x6B\x75\x6B\x75\x72\x75\x7A\x6E\x69\x6B\x20\x3C\xEC\xE0\xF0\xF8\xF0\xF3\xF2\x3E"))
                                    end
                                else
                                    sendTelegramNotification(("\xD3\xEA\xE0\xE6\xE8\xF2\xE5\x20\xF0\xE0\xE1\xEE\xF2\xF3\x3A\x20\x21\x73\x74\x61\x72\x74\x20\x3C\xF0\xE0\xE1\xEE\xF2\xE0\x3E"))
                                end

                            elseif text:match('^!stop') then
                                if state then
                                    state = false
                                    state_taked = false
                                    walking = false
                                    sendTelegramNotification(("\xC1\xEE\xF2\x20\xED\xE0\xF7\xE0\xEB\xFC\xED\xEE\xE9\x20\xF4\xE5\xF0\xEC\xFB\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                elseif work1 then
                                    work1 = false
                                    gopay = false
                                    sendTelegramNotification(("\xC1\xEE\xF2\x20\xF2\xF0\xE0\xEA\xF2\xEE\xF0\xE8\xF1\xF2\xE0\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                elseif work2 then
                                    work2 = false
                                    sendTelegramNotification(("\xC1\xEE\xF2\x20\xEA\xEE\xEC\xE1\xE0\xE9\xED\xE5\xF0\xE0\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                elseif work3 then
                                    work3 = false
                                    vars.route.state = false
                                    vars.route.name = ''
                                    vars.route.packets = 0
                                    vars.route.currentPos = { x = -1, y = -1, z = -1 }
                                    var_0_10.v = false
                                    if isCharInAnyCar(PLAYER_PED) then
                                        freezeCarPosition(storeCarCharIsInNoSave(PLAYER_PED), false)
                                    else
                                        freezeCharPosition(PLAYER_PED, false)
                                    end
                                    sendTelegramNotification(("\xC1\xEE\xF2\x20\xE2\xEE\xE4\xE8\xF2\xE5\xEB\xFF\x20\xEA\xF3\xEA\xF3\xF0\xF3\xE7\xED\xE8\xEA\xE0\x20\xE2\xFB\xEA\xEB\xFE\xF7\xE5\xED\x21"))
                                else
                                    sendTelegramNotification(("\xCD\xE5\xF2\x20\xE0\xEA\xF2\xE8\xE2\xED\xEE\xE3\xEE\x20\xE1\xEE\xF2\xE0\x20\xE4\xEB\xFF\x20\xEE\xF1\xF2\xE0\xED\xEE\xE2\xEA\xE8\x2E"))
                                end

                            elseif text:match('^!close') then
                                lua_thread.create(function()
                                    wait(math.random(control.skip1.v, control.skip2.v))
                                    setVirtualKeyDown(27, true)
                                    wait(50)
                                    setVirtualKeyDown(27, false)
                                end)
                                sendTelegramNotification(("\xC4\xE8\xE0\xEB\xEE\xE3\x20\xE7\xE0\xEA\xF0\xFB\xF2\x21"))

                            elseif text:match('^!crash') then
                                crash.v = not crash.v
                                sendTelegramNotification(("\xCA\xF0\xE0\xF8\xED\xF3\xEB\x21"))

                            else
                                sendTelegramNotification(("\xCD\xE5\xE8\xE7\xE2\xE5\xF1\xF2\xED\xE0\xFF\x20\xEA\xEE\xEC\xE0\xED\xE4\xE0\x21"))
                            end
                        end
                    end
                end
            end
        end
    end
end

function getLastUpdate()
    async_http_request('https://api.telegram.org/bot' .. token .. '/getUpdates?chat_id=' .. chat_id .. '&offset=-1', '', function(result)
        if result then
            local proc_table = decodeJson(result)
            if proc_table and proc_table.ok then
                if #proc_table.result > 0 then
                    updateid = proc_table.result[1].update_id
                else
                    updateid = 1
                end
            end
        end
    end)
end
function decodeJson(jsonString)
    local success, result = pcall(function() return json.decode(jsonString) end)
    if success then
        return result
    else
        return nil
    end
end
function warning2()
    while true do wait(0)
      if warn2 then
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80170038)
          wait(10)
          renderDrawBox(0, 0, X, Y, 0x80ff0037)
          wait(10)
          warn2 = false
      end
    end 
  end
function warning()
  while true do wait(0)
    if warn then
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80170038)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        renderDrawBox(0, 0, X, Y, 0x80ff0037)
        wait(10)
        warn = false
    end
  end 
end

--------------------------------------------------------THEME----------------------------------------------------
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
    style.Colors[clr.TextDisabled] = ImVec4(0.500, 0.500, 0.500, 1.000)
    style.Colors[clr.WindowBg] = ImVec4(0.000, 0.000, 0.000, 0.895)
    style.Colors[clr.ChildWindowBg] = ImVec4(0.00, 0.00, 0.00, 0.00)
    style.Colors[clr.PopupBg] = ImVec4(0.07, 0.07, 0.09, 1.00)
    style.Colors[clr.Border] = ImVec4(0.184, 0.878, 0.000, 0.500)
    style.Colors[clr.BorderShadow] = ImVec4(1.00, 1.00, 1.00, 0.10)
    style.Colors[clr.TitleBg] = ImVec4(0.026, 0.597, 0.000, 1.000)
    style.Colors[clr.TitleBgCollapsed] = ImVec4(0.099, 0.315, 0.000, 0.000)
    style.Colors[clr.TitleBgActive] = ImVec4(0.026, 0.597, 0.000, 1.000)
    style.Colors[clr.MenuBarBg] = ImVec4(0.16, 0.16, 0.16, 1.00)
    style.Colors[clr.ScrollbarBg] = ImVec4(0.000, 0.000, 0.000, 0.801)
    style.Colors[clr.ScrollbarGrab] = ImVec4(0.238, 0.238, 0.238, 1.000)
    style.Colors[clr.ScrollbarGrabHovered] = ImVec4(0.238, 0.238, 0.238, 1.000)
    style.Colors[clr.ScrollbarGrabActive] = ImVec4(0.004, 0.381, 0.000, 1.000)
    style.Colors[clr.CheckMark] = ImVec4(0.009, 0.845, 0.000, 1.000)
    style.Colors[clr.SliderGrab] = ImVec4(0.139, 0.508, 0.000, 1.000)
    style.Colors[clr.SliderGrabActive] = ImVec4(0.139, 0.508, 0.000, 1.000)
    style.Colors[clr.Button] = ImVec4(0.026, 0.597, 0.000, 1.000)
    style.Colors[clr.ButtonHovered] = ImVec4(0.000, 0.800, 0.000, 1.000)
    style.Colors[clr.ButtonActive] = ImVec4(0.000, 1.000, 0.000, 1.000)
    style.Colors[clr.FrameBg] = ImVec4(0.026, 0.597, 0.000, 0.541)
    style.Colors[clr.FrameBgHovered] = ImVec4(0.000, 0.800, 0.000, 0.400)
    style.Colors[clr.FrameBgActive] = ImVec4(0.000, 1.000, 0.000, 0.671)
    style.Colors[clr.Header] = ImVec4(0.026, 0.597, 0.000, 0.541)
    style.Colors[clr.HeaderHovered] = ImVec4(0.000, 0.800, 0.000, 0.800)
    style.Colors[clr.HeaderActive] = ImVec4(0.000, 1.000, 0.000, 1.000)
    style.Colors[clr.ResizeGrip] = ImVec4(0.000, 1.000, 0.221, 0.597)
    style.Colors[clr.ResizeGripHovered] = ImVec4(0.000, 0.800, 0.000, 0.67)
    style.Colors[clr.ResizeGripActive] = ImVec4(0.000, 1.000, 0.000, 0.95)
    style.Colors[clr.PlotLines] = ImVec4(0.000, 0.700, 0.000, 1.00)
    style.Colors[clr.PlotLinesHovered] = ImVec4(0.000, 1.000, 0.000, 1.00)
    style.Colors[clr.PlotHistogram] = ImVec4(0.000, 0.600, 0.000, 1.00)
    style.Colors[clr.PlotHistogramHovered] = ImVec4(0.000, 0.800, 0.000, 1.00)
    style.Colors[clr.TextSelectedBg] = ImVec4(0.000, 0.400, 0.000, 0.35)
    style.Colors[clr.ModalWindowDarkening] = ImVec4(0.20, 0.20, 0.20, 0.35)
    style.Colors[clr.PopupBg] = ImVec4(0.07, 0.17, 0.07, 0.92)
    style.Colors[clr.Text] = ImVec4(1.000, 1.000, 1.000, 1.000)
    style.Colors[clr.CloseButton] = ImVec4(0.40, 0.39, 0.38, 0.16)
    style.Colors[clr.CloseButtonHovered] = ImVec4(0.40, 0.39, 0.38, 0.39)
    style.Colors[clr.CloseButtonActive] = ImVec4(0.40, 0.39, 0.38, 1.00)
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

function theme9()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

    colors[clr.WindowBg] = ImVec4(
        ini.theme9.WindowBg_r or 0.96,
        ini.theme9.WindowBg_g or 0.84,
        ini.theme9.WindowBg_b or 0.89,
        ini.theme9.WindowBg_a or 1.00
    )
    colors[clr.ChildWindowBg] = ImVec4(
        ini.theme9.ChildWindowBg_r or 0.98,
        ini.theme9.ChildWindowBg_g or 0.87,
        ini.theme9.ChildWindowBg_b or 0.91,
        ini.theme9.ChildWindowBg_a or 0.50
    )
    colors[clr.Text] = ImVec4(
        ini.theme9.Text_r or 1.00,
        ini.theme9.Text_g or 1.00,
        ini.theme9.Text_b or 1.00,
        ini.theme9.Text_a or 1.00
    )
    
    colors[clr.PopupBg] = ImVec4(
        ini.theme9.PopupBg_r or 0.80,
        ini.theme9.PopupBg_g or 0.60,
        ini.theme9.PopupBg_b or 0.73,
        ini.theme9.PopupBg_a or 0.90
    )
    colors[clr.Border] = ImVec4(
        ini.theme9.Border_r or 1.00,
        ini.theme9.Border_g or 0.80,
        ini.theme9.Border_b or 0.88,
        ini.theme9.Border_a or 0.30
    )
    colors[clr.BorderShadow] = ImVec4(
        ini.theme9.BorderShadow_r or 0.00,
        ini.theme9.BorderShadow_g or 0.00,
        ini.theme9.BorderShadow_b or 0.00,
        ini.theme9.BorderShadow_a or 0.00
    )
    colors[clr.FrameBg] = ImVec4(
        ini.theme9.FrameBg_r or 0.95,
        ini.theme9.FrameBg_g or 0.75,
        ini.theme9.FrameBg_b or 0.85,
        ini.theme9.FrameBg_a or 1.00
    )
    colors[clr.FrameBgHovered] = ImVec4(
        ini.theme9.FrameBgHovered_r or 1.00,
        ini.theme9.FrameBgHovered_g or 0.65,
        ini.theme9.FrameBgHovered_b or 0.80,
        ini.theme9.FrameBgHovered_a or 0.68
    )
    colors[clr.FrameBgActive] = ImVec4(
        ini.theme9.FrameBgActive_r or 1.00,
        ini.theme9.FrameBgActive_g or 0.65,
        ini.theme9.FrameBgActive_b or 0.80,
        ini.theme9.FrameBgActive_a or 1.00
    )
    colors[clr.TitleBg] = ImVec4(
        ini.theme9.TitleBg_r or 0.90,
        ini.theme9.TitleBg_g or 0.70,
        ini.theme9.TitleBg_b or 0.80,
        ini.theme9.TitleBg_a or 0.45
    )
    colors[clr.TitleBgCollapsed] = ImVec4(
        ini.theme9.TitleBgCollapsed_r or 0.90,
        ini.theme9.TitleBgCollapsed_g or 0.70,
        ini.theme9.TitleBgCollapsed_b or 0.80,
        ini.theme9.TitleBgCollapsed_a or 0.35
    )
    colors[clr.TitleBgActive] = ImVec4(
        ini.theme9.TitleBgActive_r or 0.90,
        ini.theme9.TitleBgActive_g or 0.70,
        ini.theme9.TitleBgActive_b or 0.80,
        ini.theme9.TitleBgActive_a or 0.78
    )
    colors[clr.MenuBarBg] = ImVec4(
        ini.theme9.MenuBarBg_r or 0.95,
        ini.theme9.MenuBarBg_g or 0.75,
        ini.theme9.MenuBarBg_b or 0.85,
        ini.theme9.MenuBarBg_a or 0.57
    )
    colors[clr.ScrollbarBg] = ImVec4(
        ini.theme9.ScrollbarBg_r or 0.95,
        ini.theme9.ScrollbarBg_g or 0.75,
        ini.theme9.ScrollbarBg_b or 0.85,
        ini.theme9.ScrollbarBg_a or 1.00
    )
    colors[clr.ScrollbarGrab] = ImVec4(
        ini.theme9.ScrollbarGrab_r or 0.85,
        ini.theme9.ScrollbarGrab_g or 0.55,
        ini.theme9.ScrollbarGrab_b or 0.75,
        ini.theme9.ScrollbarGrab_a or 0.31
    )
    colors[clr.ScrollbarGrabHovered] = ImVec4(
        ini.theme9.ScrollbarGrabHovered_r or 0.85,
        ini.theme9.ScrollbarGrabHovered_g or 0.55,
        ini.theme9.ScrollbarGrabHovered_b or 0.75,
        ini.theme9.ScrollbarGrabHovered_a or 0.78
    )
    colors[clr.ScrollbarGrabActive] = ImVec4(
        ini.theme9.ScrollbarGrabActive_r or 0.85,
        ini.theme9.ScrollbarGrabActive_g or 0.55,
        ini.theme9.ScrollbarGrabActive_b or 0.75,
        ini.theme9.ScrollbarGrabActive_a or 1.00
    )
    colors[clr.ComboBg] = ImVec4(
        ini.theme9.ComboBg_r or 0.95,
        ini.theme9.ComboBg_g or 0.75,
        ini.theme9.ComboBg_b or 0.85,
        ini.theme9.ComboBg_a or 1.00
    )
    colors[clr.CheckMark] = ImVec4(
        ini.theme9.CheckMark_r or 1.00,
        ini.theme9.CheckMark_g or 0.60,
        ini.theme9.CheckMark_b or 0.80,
        ini.theme9.CheckMark_a or 1.00
    )
    colors[clr.SliderGrab] = ImVec4(
        ini.theme9.SliderGrab_r or 0.90,
        ini.theme9.SliderGrab_g or 0.65,
        ini.theme9.SliderGrab_b or 0.80,
        ini.theme9.SliderGrab_a or 0.24
    )
    colors[clr.SliderGrabActive] = ImVec4(
        ini.theme9.SliderGrabActive_r or 0.90,
        ini.theme9.SliderGrabActive_g or 0.65,
        ini.theme9.SliderGrabActive_b or 0.80,
        ini.theme9.SliderGrabActive_a or 1.00
    )
    colors[clr.Button] = ImVec4(
        ini.theme9.Button_r or 0.95,
        ini.theme9.Button_g or 0.70,
        ini.theme9.Button_b or 0.85,
        ini.theme9.Button_a or 0.44
    )
    colors[clr.ButtonHovered] = ImVec4(
        ini.theme9.ButtonHovered_r or 0.95,
        ini.theme9.ButtonHovered_g or 0.70,
        ini.theme9.ButtonHovered_b or 0.85,
        ini.theme9.ButtonHovered_a or 0.86
    )
    colors[clr.ButtonActive] = ImVec4(
        ini.theme9.ButtonActive_r or 1.00,
        ini.theme9.ButtonActive_g or 0.60,
        ini.theme9.ButtonActive_b or 0.85,
        ini.theme9.ButtonActive_a or 1.00
    )
    colors[clr.Header] = ImVec4(
        ini.theme9.Header_r or 0.90,
        ini.theme9.Header_g or 0.65,
        ini.theme9.Header_b or 0.80,
        ini.theme9.Header_a or 0.76
    )
    colors[clr.HeaderHovered] = ImVec4(
        ini.theme9.HeaderHovered_r or 0.90,
        ini.theme9.HeaderHovered_g or 0.65,
        ini.theme9.HeaderHovered_b or 0.80,
        ini.theme9.HeaderHovered_a or 0.86
    )
    colors[clr.HeaderActive] = ImVec4(
        ini.theme9.HeaderActive_r or 0.90,
        ini.theme9.HeaderActive_g or 0.65,
        ini.theme9.HeaderActive_b or 0.80,
        ini.theme9.HeaderActive_a or 1.00
    )
    colors[clr.ResizeGrip] = ImVec4(
        ini.theme9.ResizeGrip_r or 0.95,
        ini.theme9.ResizeGrip_g or 0.75,
        ini.theme9.ResizeGrip_b or 0.85,
        ini.theme9.ResizeGrip_a or 0.20
    )
    colors[clr.ResizeGripHovered] = ImVec4(
        ini.theme9.ResizeGripHovered_r or 0.95,
        ini.theme9.ResizeGripHovered_g or 0.75,
        ini.theme9.ResizeGripHovered_b or 0.85,
        ini.theme9.ResizeGripHovered_a or 0.78
    )
    colors[clr.ResizeGripActive] = ImVec4(
        ini.theme9.ResizeGripActive_r or 0.95,
        ini.theme9.ResizeGripActive_g or 0.75,
        ini.theme9.ResizeGripActive_b or 0.85,
        ini.theme9.ResizeGripActive_a or 1.00
    )
    colors[clr.CloseButton] = ImVec4(
        ini.theme9.CloseButton_r or 1.00,
        ini.theme9.CloseButton_g or 0.90,
        ini.theme9.CloseButton_b or 0.95,
        ini.theme9.CloseButton_a or 0.75
    )
    colors[clr.CloseButtonHovered] = ImVec4(
        ini.theme9.CloseButtonHovered_r or 1.00,
        ini.theme9.CloseButtonHovered_g or 0.80,
        ini.theme9.CloseButtonHovered_b or 0.90,
        ini.theme9.CloseButtonHovered_a or 0.59
    )
    colors[clr.CloseButtonActive] = ImVec4(
        ini.theme9.CloseButtonActive_r or 1.00,
        ini.theme9.CloseButtonActive_g or 0.80,
        ini.theme9.CloseButtonActive_b or 0.90,
        ini.theme9.CloseButtonActive_a or 1.00
    )
    colors[clr.PlotLines] = ImVec4(
        ini.theme9.PlotLines_r or 1.00,
        ini.theme9.PlotLines_g or 0.85,
        ini.theme9.PlotLines_b or 0.90,
        ini.theme9.PlotLines_a or 0.63
    )
    colors[clr.PlotLinesHovered] = ImVec4(
        ini.theme9.PlotLinesHovered_r or 1.00,
        ini.theme9.PlotLinesHovered_g or 0.65,
        ini.theme9.PlotLinesHovered_b or 0.80,
        ini.theme9.PlotLinesHovered_a or 1.00
    )
    colors[clr.PlotHistogram] = ImVec4(
        ini.theme9.PlotHistogram_r or 1.00,
        ini.theme9.PlotHistogram_g or 0.85,
        ini.theme9.PlotHistogram_b or 0.90,
        ini.theme9.PlotHistogram_a or 0.63
    )
    colors[clr.PlotHistogramHovered] = ImVec4(
        ini.theme9.PlotHistogramHovered_r or 1.00,
        ini.theme9.PlotHistogramHovered_g or 0.65,
        ini.theme9.PlotHistogramHovered_b or 0.80,
        ini.theme9.PlotHistogramHovered_a or 1.00
    )
    colors[clr.TextSelectedBg] = ImVec4(
        ini.theme9.TextSelectedBg_r or 0.95,
        ini.theme9.TextSelectedBg_g or 0.70,
        ini.theme9.TextSelectedBg_b or 0.85,
        ini.theme9.TextSelectedBg_a or 0.43
    )
    colors[clr.ModalWindowDarkening] = ImVec4(
        ini.theme9.ModalWindowDarkening_r or 0.80,
        ini.theme9.ModalWindowDarkening_g or 0.60,
        ini.theme9.ModalWindowDarkening_b or 0.73,
        ini.theme9.ModalWindowDarkening_a or 0.35
    )
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
