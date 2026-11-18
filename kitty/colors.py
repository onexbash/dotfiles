# Define Color Variables
c = {
    "rosewater": "#f5e0dc",
    "flamingo": "#f2cdcd",
    "pink": "#f5c2e7",
    "mauve": "#cba6f7",
    "red": "#f38ba8",
    "maroon": "#eba0ac",
    "peach": "#fab387",
    "yellow": "#f9e2af",
    "green": "#a6e3a1",
    "teal": "#94e2d5",
    "sky": "#89dceb",
    "sapphire": "#74c7ec",
    "blue": "#89b4fa",
    "lavender": "#b4befe",
    "text": "#cdd6f4",
    "subtext1": "#bac2de",
    "subtext0": "#a6adc8",
    "overlay2": "#9399b2",
    "overlay1": "#7f849c",
    "overlay0": "#6c7086",
    "surface2": "#585b70",
    "surface1": "#45475a",
    "surface0": "#313244",
    "base": "#1e1e2e",
    "mantle": "#181825",
    "crust": "#11111b",
    "black": "#11111b",
    "white": "#cdd6f4",
}

# Override Kitty config-keys with colors defined above
overrides = {
    "background": "base",
    # "foreground": "text",
    # "selection_background": "green", # overwritten by zellij
    # "selection_foreground": "text", # overwritten by zellij
    "cursor": "red",
    # "cursor_text_color": "base",
    # "scrollbar_handle_color": "overlay2", # overwritten by zellij
    # "scrollbar_track_color": "surface1", # overwritten by zellij
    "url_color": "blue",
    # "active_border_color": "mauve",
    # "inactive_border_color": "lavender",
    # "bell_border_color": "yellow",
    "active_tab_background": "mauve",
    "active_tab_foreground": "crust",
    "inactive_tab_background": "base",
    "inactive_tab_foreground": "subtext1",
    "tab_bar_background": "base",
}

# Iterate over overrides and print config-keys + color for kitty to use
for opt, name in overrides.items():
    print(f"{opt} {c.get(name, name)}")
