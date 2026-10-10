-- Scheme A: route new main windows once, without switching workspaces.
-- Terminal and Dolphin windows deliberately stay in the current workspace.
-- Browser tabs (Jupyter/web AI/etc.) remain in their browser's workspace.
local categories = {
    {2, 'browser', [[(?i)^(microsoft-edge(-.*)?|firefox|org.mozilla.firefox|chromium|google-chrome(-.*)?)$]]},
    {1, 'development', [[(?i)^(jetbrains-.*|code|code-oss|vscodium|codium|dev.zed.Zed|sublime_text|cmake-gui)$]]},
    {6, 'system', [[(?i)^(org.kde.plasma-systemmonitor|plasma-systemmonitor|systemsettings|org.kde.systemsettings|org.kde.kinfocenter|rustdesk|com.carriez.RustDesk|btop|htop)$]]},
    {7, 'research', [[(?i)^(zotero|org.zotero.Zotero|obsidian|md.obsidian.Obsidian|okular|org.kde.okular|texstudio|org.texstudio.TeXstudio|jabref|org.jabref.JabRef|jupyterlab)$]]},
    {8, 'graphics', [[(?i)^(godot.*|org.godotengine.*|blender|org.blender.Blender|renderdoc|qrenderdoc|.*nsight.*|ncu-ui|nsys-ui|nv-nsight-gfx)$]]},
    {3, 'ai', [[(?i)^(chatgpt|codex|claude|com.anthropic.claudefordesktop)$]]},
    {5, 'communication', [[(?i)^(wechat|weixin|com.tencent.wechat|com.tencent.weixin|qq|com.qq.QQ|discord|vesktop|feishu|bytedance-feishu|lark|slack|telegramdesktop|org.telegram.desktop)$]]},
    {9, 'office', [[(?i)^(libreoffice.*|wps.*|wpp|et|onlyoffice.*|wemeet.*|com.tencent.wemeet.*|zoom|teams.*|winboat|winboat-.*)$]]},
    {4, 'entertainment', [[(?i)^(cider|sh.cider.Cider|spotify|com.spotify.Client|yesplaymusic|vlc|mpv|org.videolan.VLC|steam|steam_app_.*|lutris|heroic|com.heroicgameslauncher.hgl)$]]},
}
-- Opening a project is an explicit navigation action: move Neovide to the
-- development workspace, switch there, and give the new window keyboard focus.
hl.window_rule({
    name = 'neovide-development-focused',
    match = { initial_class = [[(?i)^neovide$]], modal = false },
    workspace = '1',
    no_initial_focus = false,
})
for _, category in ipairs(categories) do
    hl.window_rule({
        name = 'vendetta-workspace-' .. category[2],
        match = { initial_class = category[3], modal = false, float = false },
        workspace = tostring(category[1]) .. ' silent',
    })
end
-- Recognizable RemoteApp games override the office fallback at creation time.
-- Unknown Windows programs stay in workspace 9; add exact titles here as needed.
hl.window_rule({
    name = 'vendetta-workspace-winboat-game',
    match = {
        initial_class = [[(?i)^winboat-.*$]],
        initial_title = [[(?i)^Cells[ _]of[ _]Division.*$]],
        modal = false, float = false,
    },
    workspace = '4 silent',
})
-- No catch-all: unknown applications and workspace 10 remain unrestricted.

-- Keep numeric workspace IDs and shortcuts; give each category an English name.
local workspaceNames = {'Development', 'Browser', 'AI', 'Entertainment', 'Communication', 'System', 'Research', 'Graphics', 'Office', 'Temporary'}
for id, name in ipairs(workspaceNames) do
    hl.workspace_rule({ workspace = tostring(id), default_name = name })
end

-- Monado simulated headset: keep its compositor on the development workspace.
hl.window_rule({
    name = 'monado-simulated-workspace1',
    match = { initial_class = '^openxr$', initial_title = '^(Monado|OpenXR application)$' },
    workspace = '1 silent',
    float = true,
    no_initial_focus = true,
})
