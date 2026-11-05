-- Stealth Black — Hyprland decoration.
-- Loaded by Omarchy as omarchy.current.theme.hyprland, after Omarchy's
-- defaults and before ~/.config/hypr overrides and toggles. Everything here
-- disappears when another theme is applied: no global override.
-- Layout, gaps, bindings, monitors, input and rules are left untouched.

local active_border_color = "rgb(a9b4c2)"   -- accent
local inactive_border_color = "rgb(30353d)" -- border

hl.config({
  general = {
    -- Thin silver focus ring; clearly visible at the 1.25 panel scale.
    border_size = 1,
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  decoration = {
    rounding = 5,
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
    groupbar = {
      text_color = "rgb(d7dce2)",
      text_color_inactive = "rgb(929aa5)",
      col = {
        active = "rgb(2a3038)",
        inactive = "rgb(191c21)",
      },
    },
  },

  misc = {
    -- Shown only where no wallpaper is drawn (e.g. while one loads).
    background_color = "rgb(08090b)",
  },
})

-- Short motion. Hyprland speed is in deciseconds (1 = 100 ms): ~120-180 ms.
hl.animation({ leaf = "border", enabled = true, speed = 1.5, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 1.8, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1.6, bezier = "easeOutQuint", style = "popin 92%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.2, bezier = "linear", style = "popin 92%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.2, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 1.5, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 1.6, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1.6, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.2, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.2, bezier = "almostLinear" })

-- Typography: launcher/menu, clipboard, emoji picker, polkit and reminder
-- popups read OMARCHY_MENU_FONT when the shell starts (Style.qml). Medium is
-- applied by the menu itself to row titles. The bar and notification titles
-- keep the system monospace alias (JetBrainsMono Nerd Font) with its icons.
hl.env("OMARCHY_MENU_FONT", "IBM Plex Sans")

-- Solid terminals and file manager: Omarchy's default 0.985/0.96 opacity
-- fades text on inactive windows. The Glassy toggle loads later and still wins.
o.transparent_window({ tag = "terminal" }, "1.0 1.0")
o.transparent_window("org\\.gnome\\.Nautilus", "1.0 1.0")
