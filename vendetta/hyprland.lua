-- Independent Hyprland 0.56 configuration. No KDE files are sourced.
local home = os.getenv('HOME')
local cfg = home .. '/.config/hypr'
local terminal = home .. '/.local/share/end4-vendetta/repo/vendetta/kitty'
local launcher = 'wofi --conf ' .. cfg .. '/wofi/config --style ' .. cfg .. '/wofi/style.css'

hl.monitor({ output = '', mode = 'preferred', position = 'auto', scale = 'auto' })
hl.env('TERMINAL', terminal)
hl.env('ELECTRON_OZONE_PLATFORM_HINT', 'wayland')
hl.env('XCURSOR_SIZE', '24')
hl.env('HYPRCURSOR_SIZE', '24')
hl.env('XCURSOR_THEME', 'breeze_cursors')
hl.env('QT_IM_MODULE', 'fcitx')
hl.env('XMODIFIERS', '@im=fcitx')
-- Keep GPU selection automatic on this Intel/NVIDIA hybrid system.
-- No global environment, driver, kernel or power settings are modified.

hl.config({
    xwayland = { force_zero_scaling = true },
    general = {
        gaps_in = 5, gaps_out = 10, border_size = 2,
        col = {
            active_border = { colors = {'rgba(c62828ff)', 'rgba(8e1b24ff)'}, angle = 45 },
            inactive_border = 'rgba(30262b99)',
        },
        resize_on_border = true,
        allow_tearing = false,
        layout = 'dwindle',
    },
    decoration = {
        rounding = 10,
        active_opacity = 1.0, inactive_opacity = 1.0,
        blur = { enabled = true, size = 3, passes = 1 },
        shadow = { enabled = true, range = 12, render_power = 3, color = 'rgba(00000055)' },
    },
    animations = { enabled = true },
    dwindle = { preserve_split = true },
    input = {
        kb_layout = 'us', follow_mouse = 0,
        touchpad = { natural_scroll = true, tap_to_click = true },
    },
    misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 },
})
hl.on('hyprland.start', function() hl.exec_cmd(cfg .. '/session-start.sh') end)
hl.bind('SUPER + Return', hl.dsp.exec_cmd(terminal))
hl.bind('SUPER + D', hl.dsp.exec_cmd(cfg .. '/launcher.sh'))
hl.bind('SUPER + SHIFT + D', hl.dsp.exec_cmd(launcher))
hl.bind('SUPER + E', hl.dsp.exec_cmd('dolphin'))
hl.bind('SUPER + Q', hl.dsp.window.close())
hl.bind('SUPER + F', hl.dsp.window.fullscreen({ mode = 'fullscreen', action = 'toggle' }))
hl.bind('SUPER + T', hl.dsp.window.float({ action = 'toggle' }), {description='Toggle floating'})
hl.bind('SUPER + V', hl.dsp.global('quickshell:overviewClipboardToggle'), {description='Clipboard history'})
hl.bind('SUPER + J', hl.dsp.layout('togglesplit'))
hl.bind('SUPER + CTRL + M', hl.dsp.exec_cmd('plasma-systemmonitor'))
hl.bind('SUPER + SHIFT + Escape', hl.dsp.exec_cmd(cfg .. '/logout-menu.sh'))
for _, d in ipairs({'left', 'right', 'up', 'down'}) do
    hl.bind('SUPER + ' .. d, hl.dsp.focus({ direction = d }))
    hl.bind('SUPER + ALT + ' .. d, hl.dsp.window.move({ direction = d }))
end
for i = 1, 9 do
    hl.bind('SUPER + ' .. i, hl.dsp.focus({ workspace = i }))
    hl.bind('SUPER + SHIFT + ' .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
for _, r in ipairs({{'left',-30,0},{'right',30,0},{'up',0,-30},{'down',0,30}}) do
    hl.bind('SUPER + SHIFT + ' .. r[1], hl.dsp.window.resize({x=r[2], y=r[3], relative=true}), {repeating=true})
end
hl.bind('SUPER + mouse:272', hl.dsp.window.drag(), { mouse = true })
hl.bind('SUPER + mouse:273', hl.dsp.window.resize(), { mouse = true })
hl.bind('XF86AudioRaiseVolume', hl.dsp.exec_cmd('wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+'), {repeating=true})
hl.bind('XF86AudioLowerVolume', hl.dsp.exec_cmd('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'), {repeating=true})
hl.bind('XF86AudioMute', hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'))
-- XDG desktop autostart is handled by session-start.sh.

-- end-4 shell controls; existing window/navigation bindings remain available.
hl.bind('SUPER + Tab', hl.dsp.global('quickshell:overviewWorkspacesToggle'))
hl.bind('SUPER + N', hl.dsp.global('quickshell:sidebarRightToggle'))
hl.bind('SUPER + A', hl.dsp.global('quickshell:sidebarLeftToggle'))
hl.bind('SUPER + I', hl.dsp.exec_cmd(home .. '/.local/share/end4-vendetta/repo/vendetta/qs -p ' .. home .. '/.local/share/end4-vendetta/repo/dots/.config/quickshell/ii/settings.qml'))

-- Familiar ML4W application and window shortcuts.
hl.bind('SUPER + B', hl.dsp.exec_cmd(cfg .. '/browser.sh'), {description='Open browser (Edge)'})
hl.bind('SUPER + CTRL + Return', hl.dsp.exec_cmd(cfg .. '/launcher.sh'), {description='Application launcher'})
hl.bind('SUPER + Space', hl.dsp.exec_cmd(cfg .. '/launcher.sh'), {description='Application launcher'})
hl.bind('SUPER + C', hl.dsp.exec_cmd('kcalc'), {description='Calculator'})
hl.bind('SUPER + M', hl.dsp.window.fullscreen({mode='maximized', action='toggle'}), {description='Maximize'})
hl.bind('SUPER + CTRL + K', hl.dsp.exec_cmd(cfg .. '/keybindings.sh'), {description='Keyboard shortcuts'})
hl.bind('SUPER + CTRL + R', hl.dsp.exec_cmd('hyprctl reload'), {description='Reload configuration'})
hl.bind('SUPER + CTRL + P', hl.dsp.global('quickshell:sessionToggle'), {description='Power menu'})
hl.bind('SUPER + CTRL + L', hl.dsp.global('quickshell:lock'), {description='Lock screen'})
hl.bind('SUPER + CTRL + B', hl.dsp.global('quickshell:barToggle'), {description='Toggle bar'})
hl.bind('SUPER + CTRL + E', hl.dsp.global('quickshell:overviewEmojiToggle'), {description='Emoji picker'})
hl.bind('SUPER + Print', hl.dsp.global('quickshell:regionScreenshot'), {description='Screenshot region'})
hl.bind('SUPER + 0', hl.dsp.focus({workspace=10}))
hl.bind('SUPER + SHIFT + 0', hl.dsp.window.move({workspace=10, follow=false}))
for _, event in ipairs({'hyprland.start', 'config.reloaded', 'monitor.added', 'monitor.removed'}) do
    hl.on(event, function() hl.exec_cmd(cfg .. '/monitors.py') end)
end

hl.on('hyprland.shutdown', function() hl.exec_cmd('systemctl --user stop hyprland-app-autostart.target') end)

-- Application workspace categories (scheme A).
dofile(cfg .. '/workspace-rules.lua')

-- Screenshot: region UI, window picker, and focused monitor.
hl.bind('SUPER + SHIFT + Print', hl.dsp.global('quickshell:windowScreenshot'), {description='Screenshot window'})
hl.bind('SUPER + CTRL + Print', hl.dsp.global('quickshell:screenScreenshot'), {description='Screenshot current screen'})
