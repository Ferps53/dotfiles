------------------
---- HOSTNAME ----
------------------

local function get_hostname()
	local ok, socket = pcall(require, "socket")
	if ok and socket and socket.dns then
		return socket.dns.gethostname()
	end
	local f = io.open("/etc/hostname", "r")
	if f then
		local name = f:read("*l")
		f:close()
		return name
	end
	return ""
end

local hostname = get_hostname()

------------------
---- MONITORS ----
------------------

if hostname == "ferps-home" then
	hl.monitor({ output = "eDP-1", mode = "1920x1080@60.0000", position = "1920x0", scale = 1 })
	hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60.0000", position = "0x0", scale = 1 })
elseif hostname == "ferps-work" then
	hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60.0000", position = "0x0", scale = 1 })
end

-- Fallback for any other monitor
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-1" })

---------------------
---- MY PROGRAMS ----
---------------------

local terminal = "kitty"
local fileManager = "nautilus"
local menu = "rofi -show drun"

-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("waybar")
	hl.exec_cmd("blueman-applet")
	hl.exec_cmd("nm-applet --indicator")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("systemctl --user start hyprpolkitagent")
	hl.exec_cmd("systemctl --user start nixos-fake-graphical-session.target")
	hl.exec_cmd("hyprctl setcursor 'Bibata-Modern-Classic' 20")
	hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Modern-Classic'")
	hl.exec_cmd("~/.config/hypr/auto_hz.sh")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
---- LOOK AND FEEL ----
-----------------------

hl.config({
	cursor = {
		no_hardware_cursors = true,
		use_cpu_buffer = true,
	},

	general = {
		gaps_in = 4,
		gaps_out = 8,
		border_size = 2,
		col = {
			active_border = "rgb(8aadf4)", -- Catppuccin Macchiato blue
			inactive_border = "rgb(1e2030)", -- Catppuccin Macchiato mantle
		},
		resize_on_border = true,
		allow_tearing = true,
		layout = "dwindle",
	},

	decoration = {
		rounding = 8,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = { enabled = false },
		blur = { enabled = true, size = 4 },
	},

	animations = { enabled = true },

	dwindle = { preserve_split = true },
	master = { new_status = "master" },

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

hl.animation({ leaf = "workspaces", enabled = true, speed = 2, bezier = "default", style = "slidevert" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 2, bezier = "default", style = "gnomed" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "default", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 2, bezier = "default", style = "slide" })

---------------
---- INPUT ----
---------------

hl.config({
	input = {
		kb_layout = "us,br",
		kb_options = "grp:win_space_toggle,caps:swapescape",
		accel_profile = "flat",
		follow_mouse = 1,
		force_no_accel = true,
		sensitivity = 0,
		touchpad = { natural_scroll = true },
	},
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({
	fingers = 3,
	direction = "down",
	action = function()
		hl.exec_cmd(terminal)
	end,
})
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })

---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"
local function bind(keys, dsp, opts)
	hl.bind(keys, dsp, opts)
end
local function mod(keys)
	return mainMod .. " + " .. keys
end

bind(mod("T"), hl.dsp.exec_cmd(terminal))
bind(mod("Q"), hl.dsp.window.close())
bind(mod("M"), hl.dsp.exit())
bind(mod("E"), hl.dsp.exec_cmd(fileManager))
bind(mod("V"), hl.dsp.window.float({ action = "toggle" }))
bind(mod("R"), hl.dsp.exec_cmd(menu))
bind(mod("SHIFT + F"), hl.dsp.window.fullscreen())
bind(mod("SHIFT + B"), hl.dsp.exec_cmd("~/.config/waybar/launch.sh"))
bind(mod("SHIFT + L"), hl.dsp.exec_cmd("hyprlock"))
bind(mod("SHIFT + N"), hl.dsp.exec_cmd('bash "$HOME/.config/rofi-wifi-menu/rofi-wifi-menu.sh"'))
bind(mod("SHIFT + G"), hl.dsp.exec_cmd("~/.config/hypr/toggle_rf.sh"))

-- Move focus
bind(mod("left"), hl.dsp.focus({ direction = "left" }))
bind(mod("right"), hl.dsp.focus({ direction = "right" }))
bind(mod("up"), hl.dsp.focus({ direction = "up" }))
bind(mod("down"), hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10 (focus on current monitor / move window)
for i = 1, 10 do
	local key = i % 10
	bind(mod(key), hl.dsp.focus({ workspace = i, on_current_monitor = true }))
	bind(mod("SHIFT + " .. key), hl.dsp.window.move({ workspace = i }))
end

-- Special workspace (scratchpad)
bind(mod("S"), hl.dsp.workspace.toggle_special("magic"))
bind(mod("SHIFT + S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces
bind(mod("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
bind(mod("mouse_up"), hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mouse
bind(mod("mouse:272"), hl.dsp.window.drag(), { mouse = true })
bind(mod("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Multimedia keys
local lr = { locked = true, repeating = true }
bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), lr)
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), lr)
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), lr)
bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), lr)
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), lr)
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), lr)

-- Requires playerctl
local l = { locked = true }
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), l)
bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), l)
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), l)
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), l)

-- Screenshots
bind(mod("Print"), hl.dsp.exec_cmd("hyprshot -m window"))
bind("Print", hl.dsp.exec_cmd("hyprshot -m region --clipboard-only"))
bind("SHIFT + Print", hl.dsp.exec_cmd("hyprshot -m output"))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Firefox Picture-in-Picture
hl.window_rule({
	name = "firefox-pip",
	match = { title = "^(Picture-in-Picture)$" },
	float = true,
	pin = true,
	size = "480 270",
	move = "monitor_w-490 monitor_h-280",
})
