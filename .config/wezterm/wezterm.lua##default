local wezterm = require 'wezterm';

wezterm.on("update-right-status", function(window, pane)
  local date = wezterm.strftime("%Y-%m-%d %H:%M:%S");

  -- Make it italic and underlined
  window:set_right_status(wezterm.format({
    {Attribute={Underline="Single"}},
    {Attribute={Italic=true}},
    {Text="Hello "..date},
    --{Text=""},
  }));
end);

return {
  color_scheme = "iceberg-dark",
  hide_tab_bar_if_only_one_tab = true,
  enable_wayland = true,
  font = wezterm.font("DejaVu Sans Mono"),
  show_update_window = false,
  window_decorations = "RESIZE",
  warn_about_missing_glyphs = false,
}
