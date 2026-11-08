-- ~/.config/awesome/rc.lua
-- AwesomeWM 4.3 para Dell Latitude E6400 (1280x800, Quadro NVS 160M / nouveau)
-- Tema oscuro, barra superior, gaps, bordes redondeados via picom.

pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- {{{ Manejo de errores
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Error al iniciar awesome",
        text = awesome.startup_errors,
    })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        if in_error then return end
        in_error = true
        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Error en awesome",
            text = tostring(err),
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Tema
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")

local bg     = "#16161e"
local bg_alt = "#1f2335"
local fg     = "#c0caf5"
local fg_dim = "#565f89"
local accent = "#7aa2f7"
local red    = "#f7768e"
local purple = "#bb9af7"

beautiful.font          = "Inter 10"
beautiful.border_width  = 2
beautiful.border_normal = bg_alt
beautiful.border_focus  = accent
beautiful.border_marked = purple
beautiful.useless_gap   = 6

beautiful.taglist_spacing = 4
beautiful.taglist_shape = gears.shape.rounded_rect
beautiful.taglist_shape_border_width = 0
beautiful.taglist_bg_focus    = accent
beautiful.taglist_fg_focus    = bg
beautiful.taglist_bg_occupied = bg_alt
beautiful.taglist_fg_occupied = fg
beautiful.taglist_bg_empty    = bg
beautiful.taglist_fg_empty    = fg_dim
beautiful.taglist_bg_urgent   = red
beautiful.taglist_fg_urgent   = bg

beautiful.tasklist_bg_normal = bg
beautiful.tasklist_fg_normal = fg_dim
beautiful.tasklist_bg_focus  = bg_alt
beautiful.tasklist_fg_focus  = fg
beautiful.tasklist_bg_urgent = red
beautiful.tasklist_fg_urgent = bg

beautiful.tooltip_bg_color     = bg_alt
beautiful.tooltip_fg_color     = fg
beautiful.tooltip_border_color = accent
beautiful.tooltip_border_width = 1
beautiful.tooltip_opacity      = 0.95

beautiful.menu_bg_normal    = bg_alt
beautiful.menu_fg_normal    = fg
beautiful.menu_bg_focus     = accent
beautiful.menu_fg_focus     = bg
beautiful.menu_border_color = accent
beautiful.menu_border_width = 0
beautiful.menu_height       = 26
beautiful.menu_width        = 210

beautiful.notification_bg           = bg_alt
beautiful.notification_fg           = fg
beautiful.notification_border_color = accent
beautiful.notification_border_width = 1
beautiful.notification_shape        = gears.shape.rounded_rect
beautiful.notification_opacity      = 0.96

beautiful.wibar_bg     = bg
beautiful.wibar_fg     = fg
beautiful.wibar_height = 30

local wallpaper = "/usr/share/backgrounds/archlinux/awesome.png"
if not gears.filesystem.file_readable(wallpaper) then
    wallpaper = gears.filesystem.get_themes_dir() .. "default/background.png"
end
beautiful.wallpaper = wallpaper
-- }}}

-- {{{ Variables
terminal   = "alacritty"
editor     = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey     = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.max,
    awful.layout.suit.fair,
    awful.layout.suit.spiral,
    awful.layout.suit.floating,
}
-- }}}

-- {{{ Menú
myawesomemenu = {
    { "Atajos", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "Manual", terminal .. " -e man awesome" },
    { "Editar config", editor_cmd .. " " .. awesome.conffile },
    { "Reiniciar", awesome.restart },
    { "Salir", function() awesome.quit() end },
}

mymainmenu = awful.menu({
    items = {
        { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "Terminal", terminal },
        { "Aplicaciones", "rofi -show drun" },
    },
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })
menubar.utils.terminal = terminal
-- }}}

-- {{{ Widgets de la barra
mytextclock = wibox.widget.textclock(" %H:%M ")

local battery = wibox.widget.textbox()
local battery_path = "/sys/class/power_supply/BAT0/capacity"
if gears.filesystem.file_readable(battery_path) then
    awful.widget.watch("cat " .. battery_path, 15, function(widget, stdout)
        widget:set_text(" BAT " .. (stdout:gsub("%s+", "")) .. "% ")
    end)
else
    battery:set_text("")
end

local volume = wibox.widget.textbox()
awful.widget.watch("pactl get-sink-volume @DEFAULT_SINK@", 2, function(widget, stdout)
    local vol = stdout:match("(%d+)%%")
    widget:set_text(" VOL " .. (vol or "?") .. "% ")
end)
-- }}}

-- {{{ Barra
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", { raise = true })
        end
    end),
    awful.button({}, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
    awful.button({}, 4, function() awful.client.focus.byidx(1) end),
    awful.button({}, 5, function() awful.client.focus.byidx(-1) end)
)

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wp = beautiful.wallpaper
        if type(wp) == "function" then wp = wp(s) end
        gears.wallpaper.maximized(wp, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)
    ))

    s.mytaglist = awful.widget.taglist({
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
    })

    s.mytasklist = awful.widget.tasklist({
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
    })

    s.mywibox = awful.wibar({
        position = "top",
        screen   = s,
        height   = beautiful.wibar_height,
        bg       = bg,
        fg       = fg,
    })

    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist,
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
            battery,
            volume,
            mytextclock,
            s.mylayoutbox,
        },
    })
end)
-- }}}

-- {{{ Botones del escritorio
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Atajos globales
globalkeys = gears.table.join(
    awful.key({ modkey }, "s", hotkeys_popup.show_help,
        { description = "ver atajos", group = "awesome" }),
    awful.key({ modkey }, "Left", awful.tag.viewprev,
        { description = "tag anterior", group = "tag" }),
    awful.key({ modkey }, "Right", awful.tag.viewnext,
        { description = "tag siguiente", group = "tag" }),
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
        { description = "volver", group = "tag" }),

    awful.key({ modkey }, "j", function() awful.client.focus.byidx(1) end,
        { description = "foco siguiente", group = "client" }),
    awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
        { description = "foco anterior", group = "client" }),
    awful.key({ modkey }, "w", function() mymainmenu:show() end,
        { description = "menú principal", group = "awesome" }),

    -- Mover / redimensionar
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "intercambiar con siguiente", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "intercambiar con anterior", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "pantalla siguiente", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "pantalla anterior", group = "screen" }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
        { description = "ir a urgente", group = "client" }),
    awful.key({ modkey }, "Tab", function()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end, { description = "historial", group = "client" }),

    -- Programas
    awful.key({ modkey }, "Return", function() awful.spawn(terminal) end,
        { description = "terminal", group = "launcher" }),
    awful.key({ modkey }, "d", function() awful.spawn("rofi -show drun") end,
        { description = "lanzador rofi", group = "launcher" }),
    awful.key({ modkey }, "r", function() awful.screen.focused().mypromptbox:run() end,
        { description = "ejecutar", group = "launcher" }),
    awful.key({ modkey }, "p", function() menubar.show() end,
        { description = "menubar", group = "launcher" }),
    awful.key({}, "Print", function() awful.spawn("flameshot gui") end,
        { description = "captura de pantalla", group = "launcher" }),

    -- Volumen y brillo
    awful.key({}, "XF86AudioRaiseVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end,
        { description = "subir volumen", group = "hardware" }),
    awful.key({}, "XF86AudioLowerVolume", function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end,
        { description = "bajar volumen", group = "hardware" }),
    awful.key({}, "XF86AudioMute", function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end,
        { description = "silenciar", group = "hardware" }),
    awful.key({}, "XF86MonBrightnessUp", function() awful.spawn("brightnessctl set +10%") end,
        { description = "subir brillo", group = "hardware" }),
    awful.key({}, "XF86MonBrightnessDown", function() awful.spawn("brightnessctl set 10%-") end,
        { description = "bajar brillo", group = "hardware" }),

    -- Multimedia (playerctl)
    awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end,
        { description = "reproducir/pausar", group = "hardware" }),
    awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next") end,
        { description = "siguiente pista", group = "hardware" }),
    awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous") end,
        { description = "pista anterior", group = "hardware" }),

    -- Awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "recargar awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "salir de awesome", group = "awesome" }),

    -- Layout
    awful.key({ modkey }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "más ancho master", group = "layout" }),
    awful.key({ modkey }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "menos ancho master", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "más masters", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "menos masters", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "más columnas", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "menos columnas", group = "layout" }),
    awful.key({ modkey }, "space", function() awful.layout.inc(1) end,
        { description = "siguiente layout", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "layout anterior", group = "layout" }),

    awful.key({ modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        if c then
            c:emit_signal("request::activate", "key.unminimize", { raise = true })
        end
    end, { description = "restaurar minimizado", group = "client" })
)

-- Atajos de cliente
clientkeys = gears.table.join(
    awful.key({ modkey }, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, { description = "pantalla completa", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
        { description = "cerrar", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "flotante", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "mover a master", group = "client" }),
    awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
        { description = "mover a otra pantalla", group = "client" }),
    awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
        { description = "siempre encima", group = "client" }),
    awful.key({ modkey }, "n", function(c) c.minimized = true end,
        { description = "minimizar", group = "client" }),
    awful.key({ modkey }, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, { description = "maximizar", group = "client" })
)

-- Tags 1..9
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then tag:view_only() end
        end, { description = "ver tag #" .. i, group = "tag" }),
        awful.key({ modkey, "Control" }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then awful.tag.viewtoggle(tag) end
        end, { description = "alternar tag #" .. i, group = "tag" }),
        awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then client.focus:move_to_tag(tag) end
            end
        end, { description = "mover cliente a tag #" .. i, group = "tag" }),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then client.focus:toggle_tag(tag) end
            end
        end, { description = "alternar cliente en tag #" .. i, group = "tag" })
    )
end

root.keys(globalkeys)
-- }}}

-- {{{ Botones de cliente
clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)
-- }}}

-- {{{ Reglas
awful.rules.rules = {
    { rule = {},
      properties = {
          border_width = beautiful.border_width,
          border_color = beautiful.border_normal,
          focus        = awful.client.focus.filter,
          raise        = true,
          keys         = clientkeys,
          buttons      = clientbuttons,
          screen       = awful.screen.preferred,
          placement    = awful.placement.no_overlap + awful.placement.no_offscreen,
      }
    },

    { rule_any = {
        instance = { "DTA", "copyq", "pinentry" },
        class = {
            "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin",
            "Sxiv", "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer",
        },
        name = { "Event Tester" },
        role = { "AlarmWindow", "ConfigManager", "pop-up" },
      }, properties = { floating = true }
    },
}
-- }}}

-- {{{ Señales
client.connect_signal("manage", function(c)
    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Autostart
-- "once" se resetea al recargar awesome; con pgrep evitamos duplicados.
awful.spawn.with_shell(
    "pgrep -x picom >/dev/null || picom --config " ..
    os.getenv("HOME") .. "/.config/picom/picom.conf"
)
awful.spawn.with_shell("pgrep -x nm-applet >/dev/null || nm-applet")
-- }}}
