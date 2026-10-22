class_name UiTheme
extends RefCounted

const BG := Color('#101012')
const GROUND := Color('#202026')
const PANEL := Color('#1b1b20')
const PANEL_LIGHT := Color('#2d2d35')
const BORDER := Color('#4a4a55')
const TEXT := Color('#f2f2f2')
const TEXT_DIM := Color('#8f8f9a')
const ACCENT := Color('#3a7bd5')
const ACCENT_DARK := Color('#1d3f73')
const WHITE := Color('#ffffff')

static func make_box(bg: Color, border: Color = Color.TRANSPARENT, border_width: int = 0, radius: int = 6, margin: float = 8.0) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.set_content_margin_all(margin)
	return box

static func build() -> Theme:
	var t := Theme.new()
	t.set_stylebox('normal', 'Button', make_box(PANEL_LIGHT, BORDER, 2))
	t.set_stylebox('hover', 'Button', make_box(ACCENT_DARK, ACCENT, 2))
	t.set_stylebox('pressed', 'Button', make_box(ACCENT, WHITE, 2))
	t.set_stylebox('disabled', 'Button', make_box(PANEL, PANEL_LIGHT, 2))
	t.set_stylebox('focus', 'Button', StyleBoxEmpty.new())
	t.set_color('font_color', 'Button', TEXT)
	t.set_color('font_hover_color', 'Button', WHITE)
	t.set_color('font_pressed_color', 'Button', WHITE)
	t.set_color('font_disabled_color', 'Button', TEXT_DIM)
	t.set_font_size('font_size', 'Button', 16)
	t.set_color('font_color', 'Label', TEXT)
	t.set_font_size('font_size', 'Label', 14)
	t.set_stylebox('panel', 'PanelContainer', make_box(PANEL, BORDER, 2, 8, 8))
	t.set_stylebox('background', 'ProgressBar', make_box(BG, BORDER, 1, 4, 0))
	t.set_stylebox('fill', 'ProgressBar', make_box(ACCENT, Color.TRANSPARENT, 0, 4, 0))
	return t
