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

local bg     = "#24283b"  -- Tokyo Night Storm: barra
local bg_alt = "#1f2335"  -- menus/notificaciones
local bg_hl  = "#292e42"  -- tags ocupados / resaltados
local fg     = "#c0caf5"
local fg_dim = "#565f89"
local accent = "#7aa2f7"
local red    = "#f7768e"
local green  = "#9ece6a"
local yellow = "#e0af68"
local purple = "#bb9af7"
local cyan   = "#7dcfff"

beautiful.font          = "Inter 10"
beautiful.taglist_font  = "Inter Bold 10"
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
beautiful.taglist_bg_occupied = bg_hl
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
beautiful.wibar_height = 34

-- Fondo oscuro azulado a juego con la barra (se instala con el repo).
local wallpaper = gears.filesystem.get_configuration_dir() .. "wallpaper.png"
if not gears.filesystem.file_readable(wallpaper) then
    wallpaper = "/usr/share/backgrounds/archlinux/awesome.png"
end
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

menubar.utils.terminal = terminal
-- }}}

-- {{{ Widgets de la barra
-- "Symbols Nerd Font" (paquete ttf-nerd-fonts-symbols) incluye los glifos de
-- Font Awesome en su codepoint original: no hace falta otra fuente.
local icon_font = "Symbols Nerd Font 12"

local function make_icon(glyph, color)
    local w = wibox.widget.textbox()
    w.font   = icon_font
    w.markup = '<span foreground="' .. color .. '">' .. glyph .. "</span>"
    return w
end

local function make_label(text)
    local w = wibox.widget.textbox(text)
    w.font = beautiful.font
    return w
end

local function make_sep()
    local w = wibox.widget.textbox()
    w.font   = beautiful.font
    w.markup = '<span foreground="' .. fg_dim .. '">│</span>'
    return w
end

-- Lanzador: icono de Tux en violeta (clic = menu principal).
local launcher = make_icon("\u{f17c}", purple)
launcher:buttons(gears.table.join(
    awful.button({}, 1, function() mymainmenu:toggle() end)
))

-- Reloj: icono cian, fecha en gris y hora en negrita.
local clock = wibox.widget.textclock(
    '<span foreground="' .. cyan .. '">\u{f017}</span>  '
    .. '<span foreground="' .. fg_dim .. '">%a %d %b</span>  <b>%H:%M</b> ',
    10
)
clock.font = beautiful.font

-- Calendario al hacer clic en el reloj (awesome 4.3).
local has_calendar, calendar_popup = pcall(require, "awful.widget.calendar_popup")
if has_calendar then
    local cal = calendar_popup.month({
        font          = beautiful.font,
        spacing       = 8,
        week_numbers  = true,
        start_sunday  = false,
        long_weekdays = true,
        margin        = 8,
        bg            = bg_alt,
        position      = "tr",
        style_normal     = { fg_color = fg },
        style_focus      = { fg_color = bg, bg_color = accent, shape = gears.shape.rounded_rect },
        style_header     = { fg_color = accent },
        style_weekday    = { fg_color = fg_dim },
        style_weeknumber = { fg_color = fg_dim },
    })
    cal:attach(clock, "tr", { on_hover = false })
end

-- Volumen: clic = pavucontrol, boton central = silenciar, rueda = +/- 5%.
local vol_icon  = make_icon("\u{f028}", green)
local vol_label = make_label("--%")
local volume = wibox.widget {
    vol_icon, vol_label,
    spacing = 4,
    layout  = wibox.layout.fixed.horizontal,
}

awful.widget.watch(
    { "sh", "-c", "LC_ALL=C pactl get-sink-volume @DEFAULT_SINK@; "
        .. "LC_ALL=C pactl get-sink-mute @DEFAULT_SINK@" },
    3,
    function(_, stdout)
        local vol = tonumber(stdout:match("(%d+)%%"))
        if not vol then return end
        local muted = stdout:find("Mute: yes") ~= nil
        vol_label.text = vol .. "%"
        local glyph, color
        if muted or vol == 0 then
            glyph, color = "\u{f026}", red
        elseif vol < 50 then
            glyph, color = "\u{f027}", green
        else
            glyph, color = "\u{f028}", green
        end
        vol_icon.markup = '<span foreground="' .. color .. '">' .. glyph .. "</span>"
    end
)

volume:buttons(gears.table.join(
    awful.button({}, 1, function() awful.spawn("pavucontrol") end),
    awful.button({}, 2, function() awful.spawn("pactl set-sink-mute @DEFAULT_SINK@ toggle") end),
    awful.button({}, 4, function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%") end),
    awful.button({}, 5, function() awful.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%") end)
))

-- Bateria: busca BAT0/BAT1..., icono + % y detalles al hacer clic.
local bat_path
do
    local f = io.popen("ls -d /sys/class/power_supply/BAT* 2>/dev/null")
    if f then
        local out = f:read("*a")
        f:close()
        bat_path = out:match("(/sys/class/power_supply/BAT%d+)")
    end
end

local battery
if bat_path then
    local bat_icon  = make_icon("\u{f244}", yellow)
    local bat_label = make_label("--%")
    local bat_cap, bat_status = "?", "Desconocido"

    battery = wibox.widget {
        bat_icon, bat_label,
        spacing = 4,
        layout  = wibox.layout.fixed.horizontal,
    }

    awful.widget.watch(
        { "sh", "-c", "cat " .. bat_path .. "/capacity " .. bat_path .. "/status" },
        20,
        function(_, stdout)
            local cap = tonumber(stdout:match("(%d+)"))
            if not cap then return end
            local charging = stdout:find("Charging") ~= nil
            local full     = stdout:find("Full") ~= nil
            bat_cap    = cap
            bat_status = charging and "Cargando" or (full and "Llena" or "Descargando")
            bat_label.text = cap .. "%"

            local glyph, color
            if charging then
                glyph, color = "\u{f0e7}", green
            elseif cap >= 90 then
                glyph, color = "\u{f240}", yellow
            elseif cap >= 70 then
                glyph, color = "\u{f241}", yellow
            elseif cap >= 45 then
                glyph, color = "\u{f242}", yellow
            elseif cap >= 20 then
                glyph, color = "\u{f243}", yellow
            else
                glyph, color = "\u{f244}", red
            end
            bat_icon.markup = '<span foreground="' .. color .. '">' .. glyph .. "</span>"
        end
    )

    battery:buttons(gears.table.join(
        awful.button({}, 1, function()
            naughty.notify({
                title   = "Batería",
                text    = "Nivel: " .. bat_cap .. "%\nEstado: " .. bat_status,
                timeout = 5,
            })
        end)
    ))
end

-- Menu de energia en la barra.
local power_menu = awful.menu({
    items = {
        { "Cerrar sesión", function() awesome.quit() end },
        { "Reiniciar", "systemctl reboot" },
        { "Apagar", "systemctl poweroff" },
    },
    theme = { width = 170, height = 26 },
})

local power = make_icon("\u{f011}", red)
power:buttons(gears.table.join(
    awful.button({}, 1, function() power_menu:show() end)
))
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
        -- Pastillas con mas aire dentro (el template por defecto deja 4 px).
        widget_template = {
            {
                {
                    id     = "text_role",
                    widget = wibox.widget.textbox,
                },
                left   = 8,
                right  = 8,
                widget = wibox.container.margin,
            },
            id     = "background_role",
            widget = wibox.container.background,
        },
    })

    s.mytasklist = awful.widget.tasklist({
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
    })

    local tray = wibox.widget.systray()
    tray.base_size = 18

    local left = wibox.layout.fixed.horizontal()
    left.spacing = 6
    left:add(launcher)
    left:add(s.mytaglist)
    left:add(s.mypromptbox)
    left = wibox.container.margin(left, 8, 8)

    local right = wibox.layout.fixed.horizontal()
    right.spacing = 8
    right:add(tray)
    right:add(make_sep())
    right:add(volume)
    if battery then
        right:add(battery)
    end
    right:add(make_sep())
    right:add(clock)
    right:add(make_sep())
    right:add(s.mylayoutbox)
    right:add(power)
    right = wibox.container.margin(right, 8, 8)

    s.mywibox = awful.wibar({
        position = "top",
        screen   = s,
        height   = beautiful.wibar_height,
        bg       = bg,
        fg       = fg,
    })

    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        left,
        s.mytasklist,
        right,
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
-- Si existe ~/.config/picom/off no se lanza el compositor (pantalla
-- congelada en algunas GPUs viejas):  touch ~/.config/picom/off
if not gears.filesystem.file_readable(os.getenv("HOME") .. "/.config/picom/off") then
    awful.spawn.with_shell(
        "pgrep -x picom >/dev/null || picom --config " ..
        os.getenv("HOME") .. "/.config/picom/picom.conf"
    )
end
awful.spawn.with_shell("pgrep -x nm-applet >/dev/null || nm-applet")
-- }}}
