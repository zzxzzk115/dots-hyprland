-- Scheme A: route new main windows once, without switching workspaces.
-- Terminal and Dolphin windows deliberately stay in the current workspace.
-- Browser tabs (Jupyter/web AI/etc.) remain in their browser's workspace.
local categories = {
    {1, 'browser', [[(?i)^(microsoft-edge(-.*)?|firefox|org.mozilla.firefox|chromium|google-chrome(-.*)?)$]]},
    {2, 'development', [[(?i)^(jetbrains-.*|code|code-oss|vscodium|codium|dev.zed.Zed|sublime_text|cmake-gui)$]]},
    {3, 'system', [[(?i)^(org.kde.plasma-systemmonitor|plasma-systemmonitor|systemsettings|org.kde.systemsettings|org.kde.kinfocenter|rustdesk|com.carriez.RustDesk|btop|htop)$]]},
    {4, 'research', [[(?i)^(zotero|org.zotero.Zotero|obsidian|md.obsidian.Obsidian|okular|org.kde.okular|texstudio|org.texstudio.TeXstudio|jabref|org.jabref.JabRef|jupyterlab)$]]},
    {5, 'graphics', [[(?i)^(godot.*|org.godotengine.*|blender|org.blender.Blender|renderdoc|qrenderdoc|.*nsight.*|ncu-ui|nsys-ui|nv-nsight-gfx)$]]},
    {6, 'ai', [[(?i)^(chatgpt|codex|claude|com.anthropic.claudefordesktop)$]]},
    {7, 'communication', [[(?i)^(wechat|weixin|com.tencent.wechat|com.tencent.weixin|qq|com.qq.QQ|discord|vesktop|feishu|bytedance-feishu|lark|slack|telegramdesktop|org.telegram.desktop)$]]},
    {8, 'office', [[(?i)^(libreoffice.*|wps.*|wpp|et|onlyoffice.*|wemeet.*|com.tencent.wemeet.*|zoom|teams.*|winboat|winboat-.*)$]]},
    {9, 'entertainment', [[(?i)^(cider|sh.cider.Cider|spotify|vlc|mpv|org.videolan.VLC|steam|steam_app_.*|lutris|heroic|com.heroicgameslauncher.hgl)$]]},
}
for _, category in ipairs(categories) do
    hl.window_rule({
        name = 'vendetta-workspace-' .. category[2],
        match = { initial_class = category[3], modal = false, float = false },
        workspace = tostring(category[1]) .. ' silent',
    })
end
-- Recognizable RemoteApp games override the office fallback at creation time.
-- Unknown Windows programs stay in workspace 8; add exact titles here as needed.
hl.window_rule({
    name = 'vendetta-workspace-winboat-game',
    match = {
        initial_class = [[(?i)^winboat-.*$]],
        initial_title = [[(?i)^Cells[ _]of[ _]Division.*$]],
        modal = false, float = false,
    },
    workspace = '9 silent',
})
-- No catch-all: unknown applications and workspace 10 remain unrestricted.

-- Keep numeric workspace IDs and shortcuts; give each category an English name.
local workspaceNames = {'Browser', 'Development', 'System', 'Research', 'Graphics',
    'AI', 'Communication', 'Office', 'Entertainment', 'Temporary'}
for id, name in ipairs(workspaceNames) do
    hl.workspace_rule({ workspace = tostring(id), default_name = name })
end
