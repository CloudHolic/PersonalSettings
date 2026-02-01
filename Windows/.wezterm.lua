local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

-- Launcher Items
local launch_items = {
    {
        label = '  PowerShell7.5',
        display = '1.   PowerShell 7.5',
        args = { 'pwsh.exe' }
    },
    {
        label = '  Arch',
        display = '2.   Arch Linux',
        args = { 'wsl.exe', '-d', 'Arch', '--cd', '~' }
    },
    {
        label = '  Kali',
        display = '3.   Kali Linux',
        args = { 'wsl.exe', '-d', 'kali-linux', '--cd', '~'}
    },
    {
        label = '  Win-KeX',
        display = '4.   Kali Linux (Win-KeX)',
        args = { 'wsl.exe', '-d', 'kali-linux', '--cd', '~', 'kex', '--wtstart', '-s'}
    },
    {
        label = '  PowerShell5.1',
        display = '5.   PowerShell 5.1',
        args = { 'PowerShell.exe' }
    },
    {
        label = '  CMD',
        display = '6.   CMD',
        args = { 'cmd.exe' }
    }
}
local default_prog_label = launch_items[1].label

-- Window Size
config.initial_cols = 120
config.initial_rows = 35

-- Fonts
config.font = wezterm.font_with_fallback({
    'D2CodingLigature Nerd Font',
    'D2Coding',
})
config.font_size = 11.0

-- Opacity & Backdrop
config.window_background_opacity = 0.85
config.win32_system_backdrop = 'Acrylic'
config.color_scheme = 'MaterialDarker'

-- Styling
config.use_fancy_tab_bar = true
config.tab_max_width = 32
config.tab_bar_at_bottom = false
config.hide_tab_bar_if_only_one_tab = false

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.window_frame = {
    font = wezterm.font({ family = 'D2CodingLigature Nerd Font', weight = 'Bold' }),
    font_size = 12.0,
    active_titlebar_bg = '#2e3440',
    inactive_titlebar_bg = '#3b4252'
}

config.window_padding = {
    left = 8,
    right = 8,
    top = 8,
    bottom = 8,
}

config.inactive_pane_hsb = {
    saturation = 0.9,
    brightness = 0.8,
}

config.colors = {
    tab_bar = {
        background = '#1e1e2e',
        active_tab = {
            bg_color = '#2e3440',
            fg_color = '#88c0d0',
            intensity = 'Bold',
        },
        inactive_tab = {
            bg_color = '#3b4252',
            fg_color = '#d8dee9',
        },
        inactive_tab_hover = {
            bg_color = '#434c5e',
            fg_color = '#eceff4',
        },
        new_tab = {
            bg_color = '#3b4252',
            fg_color = '#d8dee9',
        },
        new_tab_hover = {
            bg_color = '#434c5e',
            fg_color = '#eceff4',
        },
    },
}

config.default_cursor_style = 'SteadyBar'
config.cursor_thickness = '2px'

config.enable_scroll_bar = true

-- Animation
config.animation_fps = 60
config.max_fps = 60

-- Set Tab Name
local tab_labels = {}
local custom_tab_titles = {}

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    local pane = tab.active_pane
    local tab_id = tab.tab_id

    local title = custom_tab_titles[tab_id] or tab_labels[tab_id]

    if not title then
        local process_name = pane.foreground_process_name
        if process_name and process_name ~= '' then
            process_name = process_name:match("([^/\\]+)$") or process_name

            if process_name:lower():find('wsl') then
                title = 'WSL'
            elseif process_name == 'powershell.exe' then
                title = 'PowerShell'
            elseif process_name == 'cmd.exe' then
                title = 'CMD'
            else
                title = process_name:gsub('.exe$', '')
            end
        else
            title = 'Terminal'
        end
    end

    local index = tab.tab_index + 1

    if tab.is_active then
        return {
            { Background = { Color = '#2e3440' } },
            { Foreground = { Color = '#88c0d0' } },
            { Text = ' ' .. index .. ': ' .. title .. ' '},
        }
    else
        return {
            { Background = { Color = '#3b4252' } },
            { Foreground = { Color = '#d8dee9' } },
            { Text = ' ' .. index .. ': ' .. title .. ' '},
        }
    end
end)

-- Default program
config.default_prog = { 'pwsh.exe' }

-- Custom launcher menu
local function custom_launcher(window, pane)
    local choices = {}
    for i, item in ipairs(launch_items) do
        table.insert(choices, {
            label = item.display,
            id = tostring(i)
        })
    end

    window:perform_action(
        act.InputSelector {
            action = wezterm.action_callback(function(inner_window, inner_pane, id, label)
                if not id or not label then
                    return
                end

                local idx = tonumber(id)
                local selected_item = launch_items[idx]
                
                if selected_item then
                    local tab, new_pane, new_window = inner_window:mux_window():spawn_tab({
                        args = selected_item.args
                    })
                    tab_labels[tab:tab_id()] = selected_item.label
                end
            end),
            title = 'New Tab',
            choices = choices,
            fuzzy = true,
            alphabet = '1234567890',
        },
        pane
    )
end

-- CenterScreen
wezterm.on('gui-startup', function(cmd)
    local tab, pane, window = wezterm.mux.spawn_window(cmd or {})

    tab_labels[tab:tab_id()] = default_prog_label

    wezterm.sleep_ms(100)
    local gui_window = window:gui_window()
    if gui_window then
        local screens = wezterm.gui.screens()
        if screens and screens.active then
            local screen = screens.active
            local screen_width = screen.width
            local screen_height = screen.height

            local dims = gui_window:get_dimensions()
            local window_width = dims.pixel_width
            local window_height = dims.pixel_height

            local x = math.floor((screen_width - window_width) / 2)
            local y = math.floor((screen_height - window_height) / 2)

            x = math.max(0, x)
            y = math.max(0, y)

            gui_window:set_position(x, y)
        else
            wezterm.log_error('Could not get screen information')
        end
    end
end)

-- Mouse Bindings
config.show_new_tab_button_in_tab_bar = true
config.mouse_bindings = {
    {
        event = { Down = { streak = 1, button = 'Middle' } },
        mods = 'NONE',
        target = 'TabScrollbar',
        action = act.CloseCurrentTab { confirm = false },
    },
}

wezterm.on('new-tab-button-click', function(window, pane, button, default_action)
    if button == 'Right' then
        custom_launcher(window, pane)
        return false
    elseif button == 'Left' then
        local tab, new_pane, new_window = window:mux_window():spawn_tab({
            args = launch_items[1].args
        })
        tab_labels[tab:tab_id()] = default_prog_label
        return false
    end

    if default_action then
        window:perform_action(default_action, pane)
    end
    return false
end)

-- Key Bindings
config.leader = { key = '`', mods = 'NONE', timeout_milliseconds = 1000 }
config.keys = {
    -- `` = Write `
    {
        key = '`',
        mods = 'LEADER',
        action = act.SendKey({ key = '`' }),
    },

    -- LEADER + 1~6 = Spawn each profiles
    {
        key = '1',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            local item = launch_items[1]
            local tab, new_pane, new_window = window:mux_window():spawn_tab({
                args = item.args
            })
            tab_labels[tab:tab_id()] = item.label
        end),
    },    
    {
        key = '2',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            local item = launch_items[2]
            local tab, new_pane, new_window = window:mux_window():spawn_tab({
                args = item.args
            })
            tab_labels[tab:tab_id()] = item.label
        end),
    },    
    {
        key = '3',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            local item = launch_items[3]
            local tab, new_pane, new_window = window:mux_window():spawn_tab({
                args = item.args
            })
            tab_labels[tab:tab_id()] = item.label
        end),
    },
    {
        key = '4',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            local item = launch_items[4]
            local tab, new_pane, new_window = window:mux_window():spawn_tab({
                args = item.args
            })
            tab_labels[tab:tab_id()] = item.label
        end),
    },    
    {
        key = '5',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            local item = launch_items[5]
            local tab, new_pane, new_window = window:mux_window():spawn_tab({
                args = item.args
            })
            tab_labels[tab:tab_id()] = item.label
        end),
    },    
    {
        key = '6',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            local item = launch_items[6]
            local tab, new_pane, new_window = window:mux_window():spawn_tab({
                args = item.args
            })
            tab_labels[tab:tab_id()] = item.label
        end),
    },

    -- LEADER + N = New Workspace
    {
        key = 'n',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            window:perform_action(
                act.PromptInputLine({
                    description = wezterm.format({
                        { Attribute = { Intensity = 'Bold' } },
                        { Foreground = { AnsiColor = 'Cyan' } },
                        { Text = 'New workspace:' },
                    }),
                    action = wezterm.action_callback(function(inner_window, inner_pane, line)
                        if line and line ~= '' then
                            inner_window:perform_action(
                                act.SwitchToWorkspace({
                                    name = line,
                                }),
                                inner_pane
                            )
                        end
                    end),
                }),
                pane
            )
        end),
    },

    -- LEADER + S = Workspace
    {
        key = 's',
        mods = 'LEADER',
        action = wezterm.action_callback(function(window, pane)
            window:perform_action(
                act.ShowLauncherArgs({
                    flags = 'FUZZY|WORKSPACES',
                }),
                pane
            )
        end),
    },

    -- CTRL + SHIFT + L = Open Launcher Menu
    { 
        key = 'L',
        mods = 'CTRL|SHIFT', 
        action = wezterm.action_callback(custom_launcher),
    },

    -- CTRL + SHIFT + R = Rename tab name
    {
        key = 'R',
        mods = 'CTRL|SHIFT',
        action = wezterm.action_callback(function(window, pane)
            local tab = window:mux_window():active_tab()
            window:perform_action(
                act.PromptInputLine({
                    description = 'Rename tab name:',
                    action = wezterm.action_callback(function(window, pane, line)
                        if line then
                            custom_tab_titles[tab:tab_id()] = line
                            tab:set_title(line)
                        end
                    end),
                }),
                pane
            )
        end),
    },

    -- LEADER + - = Vertical split
    {
        key = '-',
        mods = 'LEADER',
        action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },

    -- LEADER + \ = Horizontal split
    {
        key = '\\',
        mods = 'LEADER',
        action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },

    -- ALT + Arrows = Move between panel
    {
        key = 'LeftArrow',
        mods = 'ALT',
        action = act.ActivatePaneDirection('Left'),
    },
    {
        key = 'RightArrow',
        mods = 'ALT',
        action = act.ActivatePaneDirection('Right'),
    },
    {
        key = 'UpArrow',
        mods = 'ALT',
        action = act.ActivatePaneDirection('Up'),
    },
    {
        key = 'DownArrow',
        mods = 'ALT',
        action = act.ActivatePaneDirection('Down'),
    },

    -- LEADER + Arrows = Adjust panel size (5)
    {
        key = 'LeftArrow',
        mods = 'LEADER',
        action = act.AdjustPaneSize({ 'Left', 5 }),
    },
    {
        key = 'RightArrow',
        mods = 'LEADER',
        action = act.AdjustPaneSize({ 'Right', 5 }),
    },
    {
        key = 'UpArrow',
        mods = 'LEADER',
        action = act.AdjustPaneSize({ 'Up', 5 }),
    },
    {
        key = 'DownArrow',
        mods = 'LEADER',
        action = act.AdjustPaneSize({ 'Down', 5 }),
    },

    -- LEADER + W = Close current panel
    {
        key = 'W',
        mods = 'LEADER',
        action = act.CloseCurrentPane({ confirm = false })
    },

    -- LEADER + Z = Toggle panel zoom
    {
        key = 'Z',
        mods = 'LEADER',
        action = act.TogglePaneZoomState,
    },

    -- LEADER + [ = Toggle copy mode
    {
        key = '[',
        mods = 'LEADER',
        action = act.ActivateCopyMode,
    },

    -- LEADER + Space = Toggle Quick selection mode
    {
        key = 'Space',
        mods = 'LEADER',
        action = act.QuickSelect,
    },

    -- CTRL + SHIFT + F = Search
    {
        key = 'F',
        mods = 'CTRL|SHIFT',
        action = act.Search({ CaseSensitiveString = '' }),
    },
    
    -- CTRL + SHIFT + C/V = Copy & Paste
    {
        key = 'C',
        mods = 'CTRL|SHIFT',
        action = act.CopyTo('Clipboard'),
    },
    {
        key = 'V',
        mods = 'CTRL|SHIFT',
        action = act.PasteFrom('Clipboard'),
    },

    -- CTRL (+ SHIFT) + Tab = Move Tab
    {
        key = 'Tab',
        mods = 'CTRL',
        action = act.MoveTabRelative(1),
    },
    {
        key = 'Tab',
        mods = 'CTRL|SHIFT',
        action = act.MoveTabRelative(-1),
    },

    -- CTRL + SHIFT + P = Command palette
    {
        key = 'P',
        mods = 'CTRL|SHIFT',
        action = act.ActivateCommandPalette,
    },
}

-- Statusbar (show leaderkey)
wezterm.on('update-right-status', function(window, pane)
    local leader = ""
    if window:leader_is_active() then
        leader = " ⚡ LEADER "
    end

    window:set_right_status(wezterm.format({
        { Background = { Color = '#bf616a' } },
        { Foreground = { Color = '#2e3440' } },
        { Attribute = { Intensity = 'Bold' } },
        { Text = leader },
    }))
end)

-- Etc
config.scrollback_lines = 10000
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.audible_bell = 'Disabled'

return config