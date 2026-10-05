extends Control

const W := 390.0
const H := 844.0
const BG := Color("#faf3e6")
const CARD := Color("#fffdf9")
const TEXT := Color("#3d3630")
const SOFT := Color("#7a7067")
const MINT := Color("#8dcc9e")
const BLUE := Color("#a8d1ed")
const AMBER := Color("#fbd07a")
const LINE := Color("#e9dfd2")
const SHELF := Color("#fdf8ef")
const STARTING_MONEY := 100

var header: Control
var content: Control
var level_label: Label
var money_label: Label
var current_screen := "menu"
var auto_save_enabled: bool = true
var sound_enabled: bool = true
var large_text_enabled: bool = false
var high_contrast_enabled: bool = false
var language: String = "en"
var ui_font: Font
const UI_FONT_PATH := "res://assets/fonts/NotoSansThai-Regular.ttf"
const SAVE_PATH := "user://daily_shopping_save.json"
const ICON_DIR := "res://assets/icons/"

func _ready() -> void:
	ui_font = load(UI_FONT_PATH) as Font
	randomize()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_base()
	_show_menu()

func _panel_style(color: Color, radius := 16, border := LINE, border_width := 1) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if high_contrast_enabled:
		# High Contrast uses a simple black/white palette so the change is
		# visible across every screen that rebuilds its panels.
		s.bg_color = Color.BLACK
		s.border_color = Color.WHITE
		s.set_border_width_all(max(border_width, 2))
	else:
		s.bg_color = color
		s.border_color = border
		s.set_border_width_all(border_width)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 8
	s.content_margin_bottom = 8
	return s

func _button_style(color: Color, radius := 14) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	if high_contrast_enabled:
		s.bg_color = Color.WHITE
		s.border_color = Color.WHITE
		s.set_border_width_all(2)
		s.set_corner_radius_all(radius)
	else:
		s = _panel_style(color, radius, Color(0, 0, 0, 0), 0)
		s.shadow_color = Color(0, 0, 0, 0.10)
		s.shadow_size = 2
		s.shadow_offset = Vector2(0, 2)
	return s

func _ui_font_size(size: int) -> int:
	if large_text_enabled:
		return int(round(float(size) * 1.10))
	return size

func _t(text: String) -> String:
	if language == "en":
		return text

	match text:
		"DAILY SHOPPING": return "ช้อปปิ้งประจำวัน"
		"Learn. Choose. Shop.\nSimple controls • No time limit • Take your time":
			return "เรียนรู้ เลือกซื้อ และช้อปปิ้ง\nควบคุมง่าย • ไม่มีจำกัดเวลา • ค่อย ๆ ทำได้"
		"Start Game": return "เริ่มเกม"
		"How to Play": return "วิธีเล่น"
		"Main Menu / Options": return "เมนูหลัก / ตัวเลือก"
		"S A V E": return "บันทึก"
		"MAIN MENU": return "เมนูหลัก"
		"Navigation Structure": return "เมนูนำทาง"
		"Continue Shopping": return "ช้อปปิ้งต่อ"
		"Level Select": return "เลือกระดับ"
		"Options and Settings": return "ตัวเลือกและการตั้งค่า"
		"Settings": return "ตั้งค่า"
		"Accessibility": return "การเข้าถึง"
		"Profile / Save Management": return "โปรไฟล์ / จัดการการบันทึก"
		"Progress is saved automatically on this device.": return "ความคืบหน้าจะถูกบันทึกอัตโนมัติบนอุปกรณ์นี้"
		"Save Progress": return "บันทึกความคืบหน้า"
		"Reset Progress": return "รีเซ็ตความคืบหน้า"
		"Back": return "ย้อนกลับ"
		"LEVEL SELECT": return "เลือกระดับ"
		"Choose a level to start a fresh challenge.": return "เลือกระดับเพื่อเริ่มภารกิจใหม่"
		"First Shopping": return "เริ่มต้นช้อปปิ้ง"
		"Smart Shopping": return "ช้อปปิ้งอย่างฉลาด"
		"Budget Challenge": return "ท้าทายงบประมาณ"
		"Hard Choices": return "การตัดสินใจที่ยากขึ้น"
		"Expert Shopping": return "ช้อปปิ้งระดับผู้เชี่ยวชาญ"
		"Shopping": return "ช้อปปิ้ง"
		"OPTIONS & SETTINGS": return "ตัวเลือกและการตั้งค่า"
		"Save Progress Now": return "บันทึกความคืบหน้าตอนนี้"
		"ACCESSIBILITY": return "การเข้าถึง"
		"Designed for predictable, low-pressure play:\n\n- No time limit\n- Large, predictable buttons\n- Clear shopping-list states\n- Clear over-budget warning\n- Cart can be changed before checkout\n- No sudden animations":
			return "ออกแบบให้เล่นได้อย่างเป็นระบบและไม่กดดัน:\n\n- ไม่มีจำกัดเวลา\n- ปุ่มขนาดใหญ่และคาดเดาได้\n- แสดงสถานะรายการซื้ออย่างชัดเจน\n- แจ้งเตือนเมื่อเกินงบประมาณอย่างชัดเจน\n- แก้ไขรถเข็นได้ก่อนชำระเงิน\n- ไม่มีแอนิเมชันที่เกิดขึ้นแบบฉับพลัน"
		"HOW TO PLAY":
			return "วิธีเล่น"
		"TODAY'S SHOPPING LIST": return "รายการซื้อของวันนี้"
		"SUPERMARKET\nSHELVES": return "ชั้นวางสินค้า\nซูเปอร์มาร์เก็ต"
		"Same shelves every level\nBlue = need • Green = exact\nOrange = over":
			return "ชั้นวางเหมือนกันทุกระดับ\nน้ำเงิน = ต้องซื้อ • เขียว = ตรงตามรายการ\nส้ม = เกินจำนวน"
		"Shopping Cart": return "รถเข็นสินค้า"
		"Hint": return "คำใบ้"
		"HINT": return "คำใบ้"
		"Your cart is empty.": return "รถเข็นของคุณว่างเปล่า"
		"Go back to the supermarket\nand pick products.": return "กลับไปที่ซูเปอร์มาร์เก็ต\nแล้วเลือกสินค้า"
		"Back to Shop": return "กลับไปที่ร้านค้า"
		"Main Menu": return "เมนูหลัก"
		"TOTAL": return "ยอดรวม"
		"MONEY": return "เงิน"
		"REMAINING": return "คงเหลือ"
		"CHECKOUT": return "ชำระเงิน"
		"Your Items": return "สินค้าของคุณ"
		"YOUR MONEY": return "เงินของคุณ"
		"Choose your payment": return "เลือกวิธีชำระเงิน"
		"Back to Cart": return "กลับไปที่รถเข็น"
		"SHOPPING COMPLETE!": return "ช้อปปิ้งเสร็จสมบูรณ์!"
		"All shopping list items purchased!": return "ซื้อสินค้าตามรายการครบแล้ว!"
		"NEXT LEVEL": return "ระดับถัดไป"
		"NEW RUN": return "เริ่มรอบใหม่"
		"MAIN MENU": return "เมนูหลัก"
		"Drinks": return "เครื่องดื่ม"
		"Bakery": return "เบเกอรี่"
		"Fruit": return "ผลไม้"
		"Snacks": return "ขนมขบเคี้ยว"
		"Other": return "อื่น ๆ"
		"Sound and interface preferences are saved on this device.\nThere is no time limit, so you can take your time.":
			return "การตั้งค่าเสียงและหน้าจอจะถูกบันทึกบนอุปกรณ์นี้\nไม่มีจำกัดเวลา คุณสามารถค่อย ๆ ทำได้"
		"Got it": return "เข้าใจแล้ว"
		"[b]1.[/b] Look at Today's Shopping List.\n[b]2.[/b] Tap products on the supermarket shelves to pick them up.\n[b]3.[/b] Open the Cart to change quantities or remove items.\n[b]4.[/b] It is okay to go over budget while shopping. Fix the cart before checkout.\n[b]5.[/b] Checkout is available when the total is affordable. Missing list items are allowed, but they reduce your final stars.\n[b]6.[/b] Pay and calculate your change.\n\nThere is no time limit. You can take your time.":
			return "[b]1.[/b] ดูรายการซื้อของวันนี้\n[b]2.[/b] แตะสินค้าบนชั้นวางเพื่อเลือกซื้อ\n[b]3.[/b] เปิดรถเข็นเพื่อเปลี่ยนจำนวนหรือนำสินค้าออก\n[b]4.[/b] ระหว่างเลือกซื้อเกินงบได้ ให้แก้ไขรถเข็นก่อนชำระเงิน\n[b]5.[/b] ชำระเงินได้เมื่อยอดรวมไม่เกินงบ รายการที่ขาดยังชำระได้ แต่จะทำให้ได้ดาวน้อยลง\n[b]6.[/b] ชำระเงินและคำนวณเงินทอน\n\nไม่มีจำกัดเวลา คุณสามารถค่อย ๆ ทำได้"

	if text.begins_with("Sound: "):
		return "เสียง: " + ("เปิด" if text.ends_with("ON") else "ปิด")
	if text.begins_with("Large Text: "):
		return "ตัวอักษรใหญ่: " + ("เปิด" if text.ends_with("ON") else "ปิด")
	if text.begins_with("Auto Save: "):
		return "บันทึกอัตโนมัติ: " + ("เปิด" if text.ends_with("ON") else "ปิด")
	if text.begins_with("High Contrast: "):
		return "คอนทราสต์สูง: " + ("เปิด" if text.ends_with("ON") else "ปิด")
	if text.begins_with("Language: "):
		return "ภาษา: " + ("ไทย" if language == "th" else "English")
	if text.begins_with("Level ") and text.find(" - ") >= 0:
		var level_parts := text.split(" - ", false, 1)
		return "ระดับ " + level_parts[0].substr(6) + " - " + _t(level_parts[1])
	if text.begins_with("Level ") and text.find("  •  ") >= 0:
		var level_parts := text.split("  •  ", false, 1)
		return "ระดับ " + level_parts[0].substr(6) + " • " + _t(level_parts[1])
	if text.begins_with("Money: $"):
		return "เงิน: $" + text.substr(8)
	if text.begins_with("Budget $"):
		return "งบประมาณ $" + text.substr(8)
	if text.begins_with("List total $"):
		var parts := text.split(" • Remaining after full list: $", false, 1)
		if parts.size() == 2:
			return "ยอดรวมรายการ $" + parts[0].substr(12) + " • เงินคงเหลือหากซื้อครบ: $" + parts[1]
	if text.begins_with("Tap to buy 1 "):
		return "แตะเพื่อซื้อ 1 " + _t(text.substr(14))
	if text.begins_with("PAY $"):
		return "จ่าย $" + text.substr(5)
	if text.begins_with("TOTAL: $"):
		return "ยอดรวม: $" + text.substr(8)
	if text.begins_with("PAID: $"):
		return "จ่ายแล้ว: $" + text.substr(6)
	if text.begins_with("CHANGE: $"):
		return "เงินทอน: $" + text.substr(8)
	if text.begins_with("LIST COMPLETION: "):
		return "รายการที่ซื้อครบ: " + text.substr(17)
	if text.begins_with("Not purchased: "):
		return "ไม่ได้ซื้อ: " + _translate_product_names(text.substr(15))
	if text.begins_with("Still missing: "):
		return "ยังขาด: " + _translate_product_names(text.substr(15))
	if text.begins_with("Over Budget! Remove items until"):
		var budget_parts := text.split("$", false, 1)
		var budget_value := ""
		if budget_parts.size() > 1:
			budget_value = budget_parts[1].split(" ", false, 1)[0]
		return "เกินงบประมาณ! นำสินค้าออกจนยอดรวมไม่เกินงบ $" + budget_value + " งบประมาณ"
	if text.begins_with("You're over budget by $"):
		var amount := text.substr(22).split(".", false, 1)[0]
		return "คุณเกินงบประมาณ $" + amount + "\n\nนำสินค้าที่ไม่จำเป็นออก\nโดยเฉพาะสินค้าราคาแพง จนยอดรวม\nอยู่ภายในงบประมาณ"
	if text.begins_with("Your list still needs:"):
		var missing_part := text.substr(23)
		return "รายการของคุณยังขาด:\n" + _translate_product_names(missing_part).replace("• ", "• ") + "\n\nคุณไม่จำเป็นต้องซื้อทุกอย่าง\nการซื้อรายการได้ครบมากขึ้นจะช่วยเพิ่มคะแนน"
	if text == "Your shopping list is complete!\n\nReview your cart, then continue to Checkout when the total is within your budget.":
		return "รายการซื้อของครบแล้ว!\n\nตรวจสอบรถเข็น แล้วไปชำระเงินเมื่อยอดรวมอยู่ภายในงบประมาณ"
	if text.begins_with("You can checkout now. Still missing:"):
		var checkout_missing := text.substr(36)
		return "คุณสามารถชำระเงินได้ แต่ยังขาด: " + _translate_product_names(checkout_missing).replace("Choosing to skip items will reduce your final score.", "การข้ามรายการจะทำให้คะแนนสุดท้ายลดลง")
	if text.begins_with("Still missing:"):
		var still_missing := text.substr(15)
		return "ยังขาด: " + _translate_product_names(still_missing).replace("\nYou can pay, but your final score will be lower.", "\nคุณสามารถชำระเงินได้ แต่คะแนนสุดท้ายจะลดลง")
	if text.begins_with("□ "):
		var detail := _translate_product_names(text)
		detail = detail.replace("Have ", "มี ").replace(" / Need ", " / ต้องการ ")
		return detail
	if text.begins_with("x") and text.length() > 1:
		return text

	return _translate_product_names(text)


func _translate_product_names(text: String) -> String:
	var result := text
	var pairs := [
		["Orange Juice", "น้ำส้ม"],
		["Potato Chips", "มันฝรั่งทอด"],
		["Croissant", "ครัวซองต์"],
		["Crackers", "แครกเกอร์"],
		["Cookies", "คุกกี้"],
		["Cereal", "ซีเรียล"],
		["Chicken", "ไก่"],
		["Noodles", "บะหมี่"],
		["Muffin", "มัฟฟิน"],
		["Coke", "โค้ก"],
		["Water", "น้ำ"],
		["Milk", "นม"],
		["Juice", "น้ำผลไม้"],
		["Bread", "ขนมปัง"],
		["Cake", "เค้ก"],
		["Apple", "แอปเปิล"],
		["Banana", "กล้วย"],
		["Orange", "ส้ม"],
		["Carrot", "แครอท"],
		["Chips", "มันฝรั่งทอด"],
		["Candy", "ลูกอม"],
		["Eggs", "ไข่"]
	]
	for pair in pairs:
		result = result.replace(pair[0], pair[1])
	result = result.replace("Have ", "มี ").replace(" / Need ", " / ต้องการ ")
	result = result.replace(" each", " ต่อชิ้น")
	return result


func _label(text: String, size: int, bold := false, color := TEXT) -> Label:
	var l := Label.new()
	l.text = _t(text)
	if ui_font != null:
		l.add_theme_font_override("font", ui_font)
	l.add_theme_font_size_override("font_size", _ui_font_size(size))
	l.add_theme_color_override("font_color", Color.WHITE if high_contrast_enabled else color)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if bold:
		l.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.0))
	return l

func _make_button(text: String, color: Color, size: Vector2) -> Button:
	var b := Button.new()
	b.text = _t(text)
	b.custom_minimum_size = size
	if ui_font != null:
		b.add_theme_font_override("font", ui_font)
	b.add_theme_font_size_override("font_size", _ui_font_size(17))
	var button_text_color: Color = Color.BLACK if high_contrast_enabled else TEXT
	b.add_theme_color_override("font_color", button_text_color)
	b.add_theme_color_override("font_hover_color", button_text_color)
	b.add_theme_color_override("font_pressed_color", button_text_color)
	b.add_theme_color_override("font_focus_color", button_text_color)
	b.add_theme_stylebox_override("normal", _button_style(color))
	b.add_theme_stylebox_override("hover", _button_style(color.lightened(0.03)))
	b.add_theme_stylebox_override("pressed", _button_style(color.darkened(0.03)))
	b.focus_mode = Control.FOCUS_NONE
	return b

func _icon_texture(icon_name: String) -> Texture2D:
	return load(ICON_DIR + icon_name + ".svg") as Texture2D

func _add_icon(parent: Control, icon_name: String, position: Vector2, size: Vector2) -> Node2D:
	# Use Sprite2D with an explicit scale so SVG icons ALWAYS render at the
	# exact requested pixel size. This prevents Godot Web/desktop from
	# expanding SVGs to their native 128x128 size and covering the UI.
	var texture := _icon_texture(icon_name)
	var icon := Sprite2D.new()
	icon.texture = texture
	icon.centered = false
	icon.position = position
	if texture != null:
		var tex_size := texture.get_size()
		if tex_size.x > 0.0 and tex_size.y > 0.0:
			icon.scale = Vector2(size.x / tex_size.x, size.y / tex_size.y)
	parent.add_child(icon)
	return icon

func _build_base() -> void:
	# Responsive base: the game is authored at 390x844 but all major
	# horizontal positions are derived from the current viewport width.
	var bg := ColorRect.new()
	bg.color = BG
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	move_child(bg, 0)

	var page := Panel.new()
	page.set_anchors_preset(Control.PRESET_FULL_RECT)
	page.offset_left = 10
	page.offset_top = 8
	page.offset_right = -10
	page.offset_bottom = -8
	page.add_theme_stylebox_override("panel", _panel_style(BG, 25, Color("#eee3d3"), 1))
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(page)

	header = Control.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 10
	header.offset_top = 8
	header.offset_right = -10
	header.offset_bottom = 80
	add_child(header)

	var brand := _label("DAILY SHOPPING", 28, true)
	brand.position = Vector2(10, 5)
	brand.size = Vector2(235, 38)
	brand.clip_text = false
	brand.add_theme_constant_override("outline_size", 1)
	brand.add_theme_color_override("font_outline_color", TEXT)
	header.add_child(brand)

	level_label = _label("Level 1 - First Shopping", 12, false, SOFT)
	level_label.position = Vector2(10, 40)
	level_label.size = Vector2(220, 20)
	header.add_child(level_label)

	var money_panel := Panel.new()
	money_panel.anchor_left = 1.0
	money_panel.anchor_right = 1.0
	money_panel.offset_left = -106
	money_panel.offset_right = -2
	money_panel.offset_top = 0
	money_panel.offset_bottom = 61
	money_panel.add_theme_stylebox_override("panel", _panel_style(Color("#fff8dc"), 16, Color("#f2d88d"), 2))
	header.add_child(money_panel)

	money_label = _label("Money: $100", 15, true)
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	money_label.position = Vector2(3, 3)
	money_label.size = Vector2(98, 55)
	money_label.add_theme_constant_override("outline_size", 1)
	money_label.add_theme_color_override("font_outline_color", TEXT)
	money_panel.add_child(money_label)

	content = Control.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 10
	content.offset_top = 88
	content.offset_right = -10
	content.offset_bottom = -8
	add_child(content)

func _clear_content() -> void:
	for c in content.get_children():
		c.queue_free()

func _show_menu() -> void:
	current_screen = "menu"
	_clear_content()

	# Icon row — centered and spaced like the supplied reference.
	var icons := HBoxContainer.new()
	icons.anchor_left = 0.5
	icons.anchor_right = 0.5
	icons.offset_left = -88
	icons.offset_right = 88
	icons.offset_top = 28
	icons.offset_bottom = 62
	icons.alignment = BoxContainer.ALIGNMENT_CENTER
	icons.add_theme_constant_override("separation", 13)
	icons.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(icons)

	for icon_name in ["cart", "drink", "box", "apple", "cookie"]:
		var icon := TextureRect.new()
		icon.texture = _icon_texture(icon_name)
		icon.custom_minimum_size = Vector2(26, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icons.add_child(icon)

	# Decorative circles sit behind the information card.
	var left_dot := Panel.new()
	left_dot.position = Vector2(22, 89)
	left_dot.size = Vector2(72, 72)
	left_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	left_dot.add_theme_stylebox_override("panel", _circle_style(Color("#ffe9b5")))
	content.add_child(left_dot)

	var right_dot := Panel.new()
	right_dot.anchor_left = 1.0
	right_dot.anchor_right = 1.0
	right_dot.offset_left = -92
	right_dot.offset_right = -20
	right_dot.offset_top = 128
	right_dot.offset_bottom = 200
	right_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	right_dot.add_theme_stylebox_override("panel", _circle_style(Color("#d9eddc")))
	content.add_child(right_dot)

	var info := Panel.new()
	info.anchor_left = 0.5
	info.anchor_right = 0.5
	info.offset_left = -129
	info.offset_right = 129
	info.offset_top = 122
	info.offset_bottom = 206
	info.add_theme_stylebox_override("panel", _panel_style(Color("#fffdf9"), 17, LINE, 1))
	content.add_child(info)

	var sub := _label("Learn. Choose. Shop.\nSimple controls • No time limit • Take your time", 14, false, SOFT)
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sub.position = Vector2(8, 7)
	sub.size = Vector2(242, 70)
	info.add_child(sub)

	# Buttons are centered, wide and vertically spaced like the reference.
	var actions := VBoxContainer.new()
	actions.anchor_left = 0.5
	actions.anchor_right = 0.5
	actions.offset_left = -125
	actions.offset_right = 125
	actions.offset_top = 392
	actions.offset_bottom = 551
	actions.add_theme_constant_override("separation", 10)
	content.add_child(actions)

	var start := _make_button("Start Game", MINT, Vector2(250, 48))
	start.add_theme_font_size_override("font_size", 17)
	start.add_theme_constant_override("outline_size", 1)
	start.add_theme_color_override("font_outline_color", TEXT)
	start.pressed.connect(_show_shop)
	actions.add_child(start)

	var how := _make_button("How to Play", BLUE, Vector2(250, 48))
	how.add_theme_font_size_override("font_size", 17)
	how.add_theme_constant_override("outline_size", 1)
	how.add_theme_color_override("font_outline_color", TEXT)
	how.pressed.connect(_show_how_to_play)
	actions.add_child(how)

	var options := _make_button("Main Menu / Options", BLUE, Vector2(250, 48))
	options.add_theme_font_size_override("font_size", 17)
	options.add_theme_constant_override("outline_size", 1)
	options.add_theme_color_override("font_outline_color", TEXT)
	options.pressed.connect(_show_main_menu)
	actions.add_child(options)

	var save := _label("S A V E", 10, true, Color("#a27a3e"))
	save.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	save.anchor_left = 0.5
	save.anchor_right = 0.5
	save.offset_left = -117
	save.offset_right = 117
	save.offset_top = 744
	save.offset_bottom = 770
	content.add_child(save)

func _show_main_menu() -> void:
	current_screen = "main_menu"
	_clear_content()

	# Compact, clean layout for the 390x844 phone viewport.
	# Rows are smaller and icons are kept tiny so nothing overlaps.
	var title := _label("MAIN MENU", 26, true, TEXT)
	title.position = Vector2(18, 16)
	title.size = Vector2(340, 38)
	title.add_theme_constant_override("outline_size", 1)
	title.add_theme_color_override("font_outline_color", TEXT)
	content.add_child(title)

	# Navigation
	var navigation := _menu_section("Navigation Structure", 62, 178)
	content.add_child(navigation)

	var continue_btn := _menu_row("Continue Shopping")
	continue_btn.position = Vector2(14, 42)
	continue_btn.pressed.connect(_continue_shopping)
	navigation.add_child(continue_btn)

	var levels_btn := _menu_row("Level Select")
	levels_btn.position = Vector2(14, 88)
	levels_btn.pressed.connect(_show_level_select)
	navigation.add_child(levels_btn)

	var how_btn := _menu_row("How to Play")
	how_btn.position = Vector2(14, 134)
	how_btn.pressed.connect(_show_how_to_play)
	navigation.add_child(how_btn)

	# Options
	var settings := _menu_section("Options and Settings", 250, 132)
	content.add_child(settings)

	var settings_btn := _menu_row("Settings")
	settings_btn.position = Vector2(14, 42)
	settings_btn.pressed.connect(_show_settings)
	settings.add_child(settings_btn)

	var access_btn := _menu_row("Accessibility")
	access_btn.position = Vector2(14, 88)
	access_btn.pressed.connect(_show_accessibility)
	settings.add_child(access_btn)

	# Save / profile
	var save_section := _menu_section("Profile / Save Management", 394, 184)
	content.add_child(save_section)

	var save_info := _label("Progress is saved automatically on this device.", 10, false, SOFT)
	save_info.position = Vector2(14, 38)
	save_info.size = Vector2(316, 26)
	save_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	save_section.add_child(save_info)

	var save_btn := _menu_row("Save Progress")
	save_btn.position = Vector2(14, 68)
	save_btn.pressed.connect(_save_progress_and_refresh)
	save_section.add_child(save_btn)

	var reset_btn := _menu_row("Reset Progress")
	reset_btn.position = Vector2(14, 116)
	reset_btn.pressed.connect(_reset_progress)
	save_section.add_child(reset_btn)

	var back := _make_button("Back", BLUE, Vector2(340, 46))
	back.position = Vector2(10, 594)
	back.add_theme_font_size_override("font_size", 16)
	back.pressed.connect(_show_menu)
	content.add_child(back)


func _menu_section(title_text: String, y: float, height: float) -> Panel:
	var section := Panel.new()
	section.position = Vector2(10, y)
	section.size = Vector2(344, height)
	section.add_theme_stylebox_override("panel", _panel_style(CARD, 18, LINE, 1))

	var title := _label(title_text, 16, true, TEXT)
	title.position = Vector2(14, 9)
	title.size = Vector2(310, 28)
	section.add_child(title)
	return section


func _menu_row(text_value: String, icon_name: String = "") -> Button:
	var b := _make_button(text_value, Color("#fffdf9"), Vector2(316, 44))
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.add_theme_constant_override("content_margin_left", 34 if icon_name != "" else 12)
	b.add_theme_constant_override("content_margin_right", 8)
	b.add_theme_font_size_override("font_size", 15)
	if icon_name != "":
		_add_icon(b, icon_name, Vector2(10, 12), Vector2(18, 18))
	return b


func _continue_shopping() -> void:
	if shopping_list.is_empty():
		_load_progress()
	if shopping_list.is_empty():
		_show_shop(true)
	else:
		_show_shop(false)


func _show_level_select() -> void:
	current_screen = "level_select"
	_clear_content()

	var title := _label("LEVEL SELECT", 28, true, TEXT)
	title.position = Vector2(20, 25)
	title.size = Vector2(340, 45)
	content.add_child(title)

	var card := Panel.new()
	card.position = Vector2(10, 84)
	card.size = Vector2(344, 430)
	card.add_theme_stylebox_override("panel", _panel_style(CARD, 18, LINE, 1))
	content.add_child(card)

	var intro := _label("Choose a level to start a fresh challenge.", 13, false, SOFT)
	intro.position = Vector2(16, 14)
	intro.size = Vector2(312, 32)
	intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(intro)

	var levels := VBoxContainer.new()
	levels.position = Vector2(16, 55)
	levels.size = Vector2(312, 350)
	levels.add_theme_constant_override("separation", 8)
	card.add_child(levels)

	for i in range(1, LEVEL_COUNT + 1):
		var level_btn := _make_button(
			"Level " + str(i) + "  •  " + _level_name_for(i),
			MINT if i == current_level else BLUE,
			Vector2(312, 56)
		)
		level_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		level_btn.add_theme_constant_override("content_margin_left", 14)
		var selected_level: int = i
		level_btn.pressed.connect(func() -> void:
			current_level = selected_level
			cart.clear()
			_show_shop(true)
		)
		levels.add_child(level_btn)

	var back := _make_button("Back", BLUE, Vector2(340, 48))
	back.position = Vector2(10, 535)
	back.pressed.connect(_show_main_menu)
	content.add_child(back)


func _level_name_for(level: int) -> String:
	match level:
		1: return "First Shopping"
		2: return "Smart Shopping"
		3: return "Budget Challenge"
		4: return "Hard Choices"
		5: return "Expert Shopping"
	return "Shopping"


func _show_settings() -> void:
	current_screen = "settings"
	_clear_content()

	var title := _label("OPTIONS & SETTINGS", 28, true, TEXT)
	title.position = Vector2(20, 25)
	title.size = Vector2(340, 45)
	content.add_child(title)

	var card := Panel.new()
	card.position = Vector2(10, 84)
	card.size = Vector2(344, 480)
	card.add_theme_stylebox_override("panel", _panel_style(CARD, 18, LINE, 1))
	content.add_child(card)

	var sound_btn := _make_button(
		"Sound: " + ("ON" if sound_enabled else "OFF"),
		MINT if sound_enabled else BLUE,
		Vector2(316, 52)
	)
	sound_btn.position = Vector2(14, 48)
	sound_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	sound_btn.add_theme_constant_override("content_margin_left", 12)
	sound_btn.pressed.connect(_toggle_sound)
	card.add_child(sound_btn)

	var text_btn := _make_button(
		"Large Text: " + ("ON" if large_text_enabled else "OFF"),
		MINT if large_text_enabled else BLUE,
		Vector2(316, 52)
	)
	text_btn.position = Vector2(14, 112)
	text_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_btn.add_theme_constant_override("content_margin_left", 12)
	text_btn.pressed.connect(_toggle_large_text)
	card.add_child(text_btn)

	var auto_btn := _make_button(
		"Auto Save: " + ("ON" if auto_save_enabled else "OFF"),
		MINT if auto_save_enabled else BLUE,
		Vector2(316, 52)
	)
	auto_btn.position = Vector2(14, 176)
	auto_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	auto_btn.add_theme_constant_override("content_margin_left", 12)
	auto_btn.pressed.connect(_toggle_auto_save)
	card.add_child(auto_btn)

	var language_btn := _make_button(
		"Language: " + ("English" if language == "en" else "Thai"),
		MINT if language == "th" else BLUE,
		Vector2(316, 52)
	)
	language_btn.position = Vector2(14, 240)
	language_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	language_btn.add_theme_constant_override("content_margin_left", 12)
	language_btn.pressed.connect(_toggle_language)
	card.add_child(language_btn)

	var desc := _label(
		"Sound and interface preferences are saved on this device.\nThere is no time limit, so you can take your time.",
		12, false, SOFT
	)
	desc.position = Vector2(14, 306)
	desc.size = Vector2(316, 55)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card.add_child(desc)

	var save_now := _make_button("Save Progress Now", BLUE, Vector2(316, 48))
	save_now.position = Vector2(14, 378)
	save_now.pressed.connect(_save_progress_and_refresh)
	card.add_child(save_now)

	var back := _make_button("Back", BLUE, Vector2(340, 48))
	back.position = Vector2(10, 590)
	back.pressed.connect(_show_main_menu)
	content.add_child(back)


func _toggle_language() -> void:
	language = "th" if language == "en" else "en"
	_save_progress()
	_refresh_current_screen_after_accessibility()


func _toggle_sound() -> void:
	sound_enabled = not sound_enabled
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, not sound_enabled)
	_save_progress()
	_show_settings()


func _toggle_large_text() -> void:
	large_text_enabled = not large_text_enabled
	if level_label != null:
		level_label.add_theme_font_size_override("font_size", _ui_font_size(12))
	if money_label != null:
		money_label.add_theme_font_size_override("font_size", _ui_font_size(15))
	_save_progress()
	_show_settings()


func _toggle_auto_save() -> void:
	auto_save_enabled = not auto_save_enabled
	_save_progress()
	_show_settings()


func _show_accessibility() -> void:
	current_screen = "accessibility"
	_clear_content()

	var title := _label("ACCESSIBILITY", 28, true, TEXT)
	title.position = Vector2(20, 25)
	title.size = Vector2(340, 45)
	content.add_child(title)

	var card := Panel.new()
	card.position = Vector2(10, 84)
	card.size = Vector2(344, 430)
	card.add_theme_stylebox_override("panel", _panel_style(CARD, 18, LINE, 1))
	content.add_child(card)

	var text_btn := _make_button(
		"Large Text: " + ("ON" if large_text_enabled else "OFF"),
		MINT if large_text_enabled else BLUE,
		Vector2(316, 52)
	)
	text_btn.position = Vector2(14, 48)
	text_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	text_btn.add_theme_constant_override("content_margin_left", 12)
	text_btn.pressed.connect(_toggle_large_text)
	card.add_child(text_btn)

	var contrast_btn := _make_button(
		"High Contrast: " + ("ON" if high_contrast_enabled else "OFF"),
		MINT if high_contrast_enabled else BLUE,
		Vector2(316, 52)
	)
	contrast_btn.position = Vector2(14, 112)
	contrast_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	contrast_btn.add_theme_constant_override("content_margin_left", 12)
	contrast_btn.pressed.connect(_toggle_high_contrast)
	card.add_child(contrast_btn)

	var info := _label(
		"Designed for predictable, low-pressure play:\n\n- No time limit\n- Large, predictable buttons\n- Clear shopping-list states\n- Clear over-budget warning\n- Cart can be changed before checkout\n- No sudden animations",
		12, false, SOFT
	)
	info.position = Vector2(14, 180)
	info.size = Vector2(316, 185)
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	card.add_child(info)

	var back := _make_button("Back", BLUE, Vector2(340, 48))
	back.position = Vector2(10, 535)
	back.pressed.connect(_show_main_menu)
	content.add_child(back)


func _toggle_high_contrast() -> void:
	high_contrast_enabled = not high_contrast_enabled
	_save_progress()
	_apply_high_contrast_base()
	_refresh_current_screen_after_accessibility()


func _apply_high_contrast_base() -> void:
	# The base nodes (background, page frame, and header) are created only
	# once, so update them here when the accessibility setting changes.
	if get_child_count() > 0:
		var bg := get_child(0) as ColorRect
		if bg != null:
			bg.color = Color.BLACK if high_contrast_enabled else BG
	if get_child_count() > 1:
		var page := get_child(1) as Panel
		if page != null:
			page.add_theme_stylebox_override(
				"panel",
				_panel_style(BG, 25, Color("#eee3d3"), 1)
			)

	if header != null:
		for node in header.get_children():
			if node is Label:
				var label := node as Label
				label.add_theme_color_override("font_color", Color.WHITE if high_contrast_enabled else TEXT)
				label.add_theme_color_override("font_outline_color", Color.WHITE if high_contrast_enabled else TEXT)
			elif node is Panel:
				var panel := node as Panel
				panel.add_theme_stylebox_override(
					"panel",
					_panel_style(Color("#fff8dc"), 16, Color("#f2d88d"), 2)
				)


func _refresh_current_screen_after_accessibility() -> void:
	match current_screen:
		"menu": _show_menu()
		"main_menu": _show_main_menu()
		"settings": _show_settings()
		"accessibility": _show_accessibility()
		"how_to_play": _show_how_to_play()
		"level_select": _show_level_select()
		"shop": _show_shop(false)
		"cart": _show_cart()
		"checkout": _show_checkout()
		"complete": _show_complete()
		_: _show_main_menu()

	if high_contrast_enabled:
		_apply_high_contrast_to_content()


func _apply_high_contrast_to_content() -> void:
	# Re-apply the black/white palette to controls whose individual screen
	# builders use their own colors. This keeps High Contrast consistent
	# without changing the normal game appearance.
	if content == null:
		return
	for node in content.find_children("*", "Control", true, false):
		if node is Button:
			var button := node as Button
			button.add_theme_color_override("font_color", Color.BLACK)
			button.add_theme_color_override("font_hover_color", Color.BLACK)
			button.add_theme_color_override("font_pressed_color", Color.BLACK)
			button.add_theme_color_override("font_disabled_color", Color.BLACK)
			button.add_theme_color_override("font_focus_color", Color.BLACK)
			var normal := _button_style(Color.WHITE)
			var hover := _button_style(Color.WHITE)
			var pressed := _button_style(Color.WHITE)
			button.add_theme_stylebox_override("normal", normal)
			button.add_theme_stylebox_override("hover", hover)
			button.add_theme_stylebox_override("pressed", pressed)
			button.add_theme_stylebox_override("focus", _button_style(Color.WHITE))
		elif node is Label:
			var label := node as Label
			label.add_theme_color_override("font_color", Color.WHITE)
			label.add_theme_color_override("font_outline_color", Color.WHITE)
		elif node is RichTextLabel:
			var rich := node as RichTextLabel
			rich.add_theme_color_override("default_color", Color.WHITE)
		elif node is Panel:
			var panel := node as Panel
			panel.add_theme_stylebox_override("panel", _panel_style(Color.BLACK, 16, Color.WHITE, 2))
		elif node is HSeparator:
			var separator := node as HSeparator
			separator.modulate = Color.WHITE


func _save_progress_and_refresh() -> void:
	_save_progress()
	if current_screen == "settings":
		_show_settings()
	else:
		_show_main_menu()


func _save_progress() -> void:
	var data: Dictionary = {
		"current_level": current_level,
		"budget_amount": budget_amount,
		"cart": cart,
		"shopping_list": shopping_list,
		"auto_save_enabled": auto_save_enabled,
		"sound_enabled": sound_enabled,
		"large_text_enabled": large_text_enabled,
		"high_contrast_enabled": high_contrast_enabled,
		"language": language
	}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(data))
		file.close()


func _load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	current_level = int(parsed.get("current_level", 1))
	budget_amount = int(parsed.get("budget_amount", 75))
	cart = parsed.get("cart", {})
	shopping_list = parsed.get("shopping_list", [])
	auto_save_enabled = bool(parsed.get("auto_save_enabled", true))
	sound_enabled = bool(parsed.get("sound_enabled", true))
	large_text_enabled = bool(parsed.get("large_text_enabled", false))
	high_contrast_enabled = bool(parsed.get("high_contrast_enabled", false))
	language = str(parsed.get("language", "en"))
	if language != "th":
		language = "en"
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, not sound_enabled)
	level_label.text = _t("Level " + str(current_level) + " - " + _level_name())
	money_label.text = _t("Money: $" + str(budget_amount))


func _reset_progress() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	current_level = 1
	level_used_signatures.clear()
	cart.clear()
	shopping_list.clear()
	budget_amount = STARTING_MONEY
	auto_save_enabled = true
	sound_enabled = true
	large_text_enabled = false
	high_contrast_enabled = false
	language = "en"
	var bus_index: int = AudioServer.get_bus_index("Master")
	if bus_index >= 0:
		AudioServer.set_bus_mute(bus_index, false)
	money_label.text = _t("Money: $" + str(budget_amount))
	_show_main_menu()


func _show_how_to_play() -> void:
	current_screen = "how_to_play"
	_clear_content()

	# Match the supplied How To Play reference: title, single white
	# instruction card, then one full-width Back button.
	var title := _label("HOW TO PLAY", 28, true, TEXT)
	title.position = Vector2(20, 25)
	title.size = Vector2(W - 60, 45)
	title.add_theme_constant_override("outline_size", 1)
	title.add_theme_color_override("font_outline_color", TEXT)
	content.add_child(title)

	var card := Panel.new()
	card.position = Vector2(20, 84)
	card.size = Vector2(W - 60, 397)
	card.add_theme_stylebox_override("panel", _panel_style(CARD, 18, LINE, 1))
	content.add_child(card)

	var instructions := RichTextLabel.new()
	instructions.bbcode_enabled = true
	instructions.fit_content = false
	instructions.scroll_active = false
	instructions.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	instructions.position = Vector2(20, 18)
	instructions.size = Vector2(card.size.x - 40, 330)
	if ui_font != null:
		instructions.add_theme_font_override("normal_font", ui_font)
	instructions.add_theme_font_size_override("normal_font_size", 17)
	instructions.add_theme_color_override("default_color", TEXT)
	instructions.bbcode_text = "[b]1.[/b] Look at Today's Shopping List.\n" + \
		"[b]2.[/b] Tap products on the supermarket shelves to pick them up.\n" + \
		"[b]3.[/b] Open the Cart to change quantities or remove items.\n" + \
		"[b]4.[/b] It is okay to go over budget while shopping. Fix the cart before checkout.\n" + \
		"[b]5.[/b] Checkout is available when the total is affordable. Missing list items are allowed, but they reduce your final stars.\n" + \
		"[b]6.[/b] Pay and calculate your change.\n\n" + \
        "There is no time limit. You can take your time."
	card.add_child(instructions)

	var back := _make_button("Back", BLUE, Vector2(W - 60, 58))
	back.position = Vector2(20, 495)
	back.add_theme_font_size_override("font_size", 18)
	back.add_theme_constant_override("outline_size", 1)
	back.add_theme_color_override("font_outline_color", TEXT)
	back.pressed.connect(_show_menu)
	content.add_child(back)

func _circle_style(color: Color) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(36)
	return s

var budget_amount: int = 75
var cart: Dictionary = {}
var product_buttons: Dictionary = {}
var product_badges: Dictionary = {}
var list_panels: Dictionary = {}
var list_labels: Dictionary = {}
var total_label: Label
var remaining_label: Label
var shop_shelf_scroll: ScrollContainer
var current_level: int = 1
const LEVEL_COUNT := 5
var level_used_signatures: Array[String] = []

var shopping_list: Array = []
var last_payment_amount: int = 0
var last_payment_total: int = 0
var last_missing_count: int = 0
var last_missing_names: Array[String] = []
var last_score: int = 0

# The shelves stay the same, but every level receives a fresh, non-repeating
# shopping list. A level signature is remembered so a later level cannot get
# the exact same combination again.
var list_candidates: Array = [
	["bread", "noodles", "carrot"],
	["apple", "cake", "crackers"],
	["candy", "water", "crackers"],
	["milk", "banana", "cookies"],
	["juice", "bread", "orange"],
	["cereal", "chicken", "chips"],
	["croissant", "carrot", "water"],
	["muffin", "apple", "noodles"],
	["coke", "cake", "banana"],
	["orange", "cookies", "bread"]
]


var products: Array = [
	["coke", "drink", "Coke", 25],
	["water", "water", "Water", 15],
	["milk", "milk", "Milk", 25],
	["juice", "juice", "Orange Juice", 30],
	["bread", "bread", "Bread", 30],
	["croissant", "croissant", "Croissant", 35],
	["cake", "cake", "Cake", 50],
	["muffin", "muffin", "Muffin", 25],
	["apple", "apple", "Apple", 15],
	["banana", "banana", "Banana", 15],
	["orange", "orange", "Orange", 20],
	["carrot", "carrot", "Carrot", 15],
	["chips", "chips", "Potato Chips", 20],
	["cookies", "cookie", "Cookies", 25],
	["crackers", "crackers", "Crackers", 20],
	["candy", "candy", "Candy", 15],
	["eggs", "eggs", "Eggs", 40],
	["noodles", "noodles", "Noodles", 15],
	["cereal", "cereal", "Cereal", 45],
	["chicken", "chicken", "Chicken", 45]
]

func _level_name() -> String:
	match current_level:
		1:
			return "First Shopping"
		2:
			return "Smart Shopping"
		3:
			return "Budget Challenge"
		4:
			return "Hard Choices"
		5:
			return "Expert Shopping"
	return "Shopping"

func _prepare_new_level() -> void:
	# STEP 6: each level gets a fresh random list. The number of requested
	# products grows with difficulty, instead of always being exactly three.
	var pool: Array = []
	var min_items: int = 2
	var max_items: int = 3
	var min_need: int = 1
	var max_need: int = 1

	match current_level:
		1:
			pool = ["water", "milk", "bread", "apple", "banana", "carrot", "candy", "noodles"]
			min_items = 2
			max_items = 3
			min_need = 1
			max_need = 1
		2:
			pool = ["water", "milk", "bread", "apple", "banana", "carrot", "candy", "noodles", "coke", "juice", "orange", "cookies", "chips", "croissant"]
			min_items = 2
			max_items = 4
			min_need = 1
			max_need = 2
		3:
			pool = ["milk", "bread", "apple", "banana", "orange", "cookies", "chips", "croissant", "cake", "cereal", "crackers", "muffin"]
			min_items = 3
			max_items = 5
			min_need = 1
			max_need = 2
		4:
			pool = ["coke", "water", "milk", "juice", "bread", "croissant", "cake", "muffin", "apple", "banana", "orange", "carrot", "chips", "cookies", "crackers", "candy", "eggs", "noodles", "cereal", "chicken"]
			min_items = 4
			max_items = 6
			min_need = 1
			max_need = 3
		5:
			pool = ["coke", "water", "milk", "juice", "bread", "croissant", "cake", "muffin", "apple", "banana", "orange", "carrot", "chips", "cookies", "crackers", "candy", "eggs", "noodles", "cereal", "chicken"]
			min_items = 5
			max_items = 8
			min_need = 1
			max_need = 3

	var item_count: int = randi_range(min_items, max_items)
	if item_count > pool.size():
		item_count = pool.size()

	var available: Array = pool.duplicate()
	available.shuffle()
	var chosen: Array = []
	for i in range(item_count):
		chosen.append(available[i])

	var signature_parts: Array = chosen.duplicate()
	signature_parts.sort()
	var signature: String = ",".join(signature_parts)

	# Avoid repeating the same combination during the current five-level run.
	var safety: int = 0
	while level_used_signatures.has(signature) and safety < 50:
		available = pool.duplicate()
		available.shuffle()
		chosen.clear()
		for i in range(item_count):
			chosen.append(available[i])
		signature_parts = chosen.duplicate()
		signature_parts.sort()
		signature = ",".join(signature_parts)
		safety += 1

	level_used_signatures.append(signature)
	shopping_list.clear()

	var full_list_total: int = 0
	var cheapest_single: int = 999999
	for id in chosen:
		var data: Array = _product_by_id(id)
		if data.is_empty():
			continue

		var need: int = randi_range(min_need, max_need)
		var price: int = int(data[3])
		shopping_list.append({
			"id": id,
			"name": str(data[2]),
			"need": need
		})
		full_list_total += need * price
		if price < cheapest_single:
			cheapest_single = price

	# Money scales with difficulty. Early levels are comfortable; later levels
	# deliberately create trade-offs so the player may need to leave items out.
	var budget: int = full_list_total
	match current_level:
		1:
			budget += randi_range(20, 45)
		2:
			budget += randi_range(5, 25)
		3:
			budget -= randi_range(10, 35)
		4:
			budget -= randi_range(25, 55)
		5:
			budget -= randi_range(40, 75)

	if cheapest_single == 999999:
		cheapest_single = 15

	if budget < cheapest_single:
		budget = cheapest_single
	budget = int(round(float(budget) / 5.0) * 5.0)
	if budget < 20:
		budget = 20
	if budget > 180:
		budget = 180

	budget_amount = budget
	level_label.text = _t("Level " + str(current_level) + " - " + _level_name())
	money_label.text = _t("Money: $" + str(budget_amount))


func _show_shop(reset_cart: bool = true) -> void:
	current_screen = "shop"
	_clear_content()
	if reset_cart:
		cart.clear()
		_prepare_new_level()
		if auto_save_enabled:
			_save_progress()
	product_buttons.clear()
	product_badges.clear()
	list_panels.clear()
	list_labels.clear()

	var list_rows: int = int(ceil(float(shopping_list.size()) / 3.0))
	if list_rows < 1:
		list_rows = 1
	var grid_height: int = list_rows * 48 + (list_rows - 1) * 4
	var summary_y: int = 43 + grid_height + 7
	var list_card_height: int = summary_y + 34

	var list_card := Panel.new()
	list_card.position = Vector2(10, 0)
	list_card.size = Vector2(344, list_card_height)
	list_card.add_theme_stylebox_override("panel", _panel_style(CARD, 16))
	content.add_child(list_card)

	var list_title := _label("TODAY'S SHOPPING LIST", 14, true)
	list_title.position = Vector2(10, 8)
	list_title.size = Vector2(220, 24)
	list_card.add_child(list_title)

	var budget := _label("Budget $" + str(budget_amount), 13, true)
	budget.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	budget.position = Vector2(250, 7)
	budget.size = Vector2(82, 30)
	budget.add_theme_stylebox_override("normal", _panel_style(Color("#fff8dc"), 10, Color("#f2d88d"), 1))
	list_card.add_child(budget)

	var grid := GridContainer.new()
	grid.columns = 3
	grid.position = Vector2(10, 40)
	grid.size = Vector2(324, grid_height)
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	list_card.add_child(grid)

	for item in shopping_list:
		var id: String = str(item["id"])
		var need: int = int(item["need"])
		var p := Panel.new()
		p.custom_minimum_size = Vector2(104, 48)
		p.add_theme_stylebox_override("panel", _panel_style(Color("#fffdf9"), 10, LINE, 1))
		var t := _label("", 11, false, TEXT)
		t.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		t.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		t.position = Vector2(2, 2)
		t.size = Vector2(100, 44)
		t.clip_text = true
		t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		p.add_child(t)
		grid.add_child(p)
		list_panels[id] = p
		list_labels[id] = t

	var summary := Panel.new()
	summary.position = Vector2(10, summary_y)
	summary.size = Vector2(324, 28)
	summary.add_theme_stylebox_override("panel", _panel_style(Color("#f4f0e9"), 10, Color(0,0,0,0), 0))
	list_card.add_child(summary)

	total_label = _label("", 11, true)
	total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_label.position = Vector2(4, 0)
	total_label.size = Vector2(316, 28)
	summary.add_child(total_label)

	var shelf_y: int = list_card_height + 7
	# Use the full available phone viewport so the shop feels balanced
	# instead of leaving a large empty area under the shelves.
	var available_content_height: int = int(get_viewport_rect().size.y) - 96
	var bottom_y: int = available_content_height - 48
	if bottom_y < shelf_y + 420:
		bottom_y = shelf_y + 420
	var shelf_height: int = bottom_y - shelf_y - 6
	if shelf_height < 400:
		shelf_height = 400

	var shelf_card := Panel.new()
	shelf_card.position = Vector2(10, shelf_y)
	shelf_card.size = Vector2(344, shelf_height)
	shelf_card.add_theme_stylebox_override("panel", _panel_style(CARD, 16))
	content.add_child(shelf_card)

	var shelf_title := _label("SUPERMARKET\nSHELVES", 14, true)
	shelf_title.position = Vector2(9, 6)
	shelf_title.size = Vector2(145, 38)
	shelf_card.add_child(shelf_title)

	var shelf_sub := _label("Same shelves every level\nBlue = need • Green = exact\nOrange = over", 8, false, SOFT)
	shelf_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	shelf_sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	shelf_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	shelf_sub.position = Vector2(160, 5)
	shelf_sub.size = Vector2(166, 34)
	shelf_card.add_child(shelf_sub)

	shop_shelf_scroll = ScrollContainer.new()
	shop_shelf_scroll.position = Vector2(8, 44)
	shop_shelf_scroll.size = Vector2(328, shelf_height - 52)
	shop_shelf_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	shelf_card.add_child(shop_shelf_scroll)

	var shelves := VBoxContainer.new()
	shelves.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shelves.add_theme_constant_override("separation", 5)
	shop_shelf_scroll.add_child(shelves)

	var groups = [
		["Drinks", ["coke","water","milk","juice"]],
		["Bakery", ["bread","croissant","cake","muffin"]],
		["Fruit", ["apple","banana","orange","carrot"]],
		["Snacks", ["chips","cookies","crackers","candy"]],
		["Other", ["eggs","noodles","cereal","chicken"]]
	]

	for group in groups:
		var name := _label(str(group[0]), 11, true, SOFT)
		name.custom_minimum_size = Vector2(0, 19)
		shelves.add_child(name)

		var row := GridContainer.new()
		row.columns = 4
		row.custom_minimum_size = Vector2(0, 66)
		row.add_theme_constant_override("h_separation", 5)
		row.add_theme_constant_override("v_separation", 0)
		shelves.add_child(row)

		for id in group[1]:
			var data := _product_by_id(str(id))
			if data.is_empty():
				continue
			var product := Button.new()
			product.clip_contents = true
			product.custom_minimum_size = Vector2(76, 64)
			product.text = ""
			product.add_theme_color_override("font_color", TEXT)
			product.add_theme_color_override("font_hover_color", TEXT)
			product.add_theme_color_override("font_pressed_color", TEXT)
			product.add_theme_color_override("font_disabled_color", SOFT)
			product.add_theme_stylebox_override("normal", _product_style("normal"))
			product.add_theme_stylebox_override("hover", _product_style("hover"))
			product.add_theme_stylebox_override("pressed", _product_style("pressed"))
			product.focus_mode = Control.FOCUS_NONE
			product.tooltip_text = "Tap to buy 1 " + str(data[2])
			product.clip_text = true

			_add_icon(product, str(data[1]), Vector2(29, 4), Vector2(18, 18))
			var product_name := _label(str(data[2]), 8, true, TEXT)
			product_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			product_name.position = Vector2(2, 24)
			product_name.size = Vector2(72, 18)
			product_name.clip_text = true
			product.add_child(product_name)
			var product_price := _label("$" + str(data[3]), 8, false, SOFT)
			product_price.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			product_price.position = Vector2(2, 46)
			product_price.size = Vector2(72, 12)
			product.add_child(product_price)

			var badge := Label.new()
			badge.visible = false
			if ui_font != null:
				badge.add_theme_font_override("font", ui_font)
			badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			badge.add_theme_font_size_override("font_size", 8)
			badge.add_theme_color_override("font_color", Color.WHITE)
			badge.position = Vector2(57, 2)
			badge.size = Vector2(16, 16)
			badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
			product.add_child(badge)
			product.pressed.connect(_buy_product.bind(str(id)))
			row.add_child(product)
			product_buttons[str(id)] = product
			product_badges[str(id)] = badge

	var bottom := HBoxContainer.new()
	var buttons_y: int = int(get_viewport_rect().size.y) - 96 - 48
	if buttons_y < 650:
		buttons_y = 650
	bottom.position = Vector2(10, buttons_y)
	bottom.size = Vector2(344, 42)
	bottom.add_theme_constant_override("separation", 6)
	content.add_child(bottom)

	var cart_btn := _make_button("Shopping Cart", MINT, Vector2(169, 40))
	cart_btn.pressed.connect(_show_cart)
	bottom.add_child(cart_btn)

	var hint_btn := _make_button("Hint", AMBER, Vector2(169, 40))
	hint_btn.pressed.connect(_show_hint)
	bottom.add_child(hint_btn)

	_refresh_shop_ui()


func _show_hint() -> void:
	# Clean, centered hint modal. It stays inside the game panel and
	# keeps the message/button separated so nothing overlaps.
	var backdrop := Panel.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.z_index = 49
	backdrop.mouse_filter = Control.MOUSE_FILTER_STOP
	backdrop.add_theme_stylebox_override(
		"panel",
		_panel_style(Color(0.15, 0.12, 0.10, 0.08), 0, Color(0, 0, 0, 0), 0)
	)
	content.add_child(backdrop)

	var overlay := Panel.new()
	overlay.position = Vector2(18, 150)
	overlay.size = Vector2(328, 335)
	overlay.z_index = 50
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	overlay.add_theme_stylebox_override(
		"panel",
		_panel_style(Color("#fffdf9"), 20, Color("#e7d8c6"), 1)
	)
	content.add_child(overlay)

	var title := _label("HINT", 20, true, TEXT)
	title.position = Vector2(18, 17)
	title.size = Vector2(292, 34)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay.add_child(title)

	var spent: int = _cart_total()
	var remaining: int = budget_amount - spent
	var missing: Array[String] = []

	for item in shopping_list:
		var need: int = int(item["need"])
		var have: int = int(cart.get(str(item["id"]), 0))
		if have < need:
			missing.append(str(item["name"]) + " x" + str(need - have))

	var hint_text: String
	if remaining < 0:
		hint_text = "You're over budget by $" + str(abs(remaining)) + ".\n\nRemove an item you don't need,\nespecially an expensive one, until\nthe total is within your budget."
	elif not missing.is_empty():
		var show_missing: Array = missing.duplicate()
		if show_missing.size() > 3:
			show_missing = show_missing.slice(0, 3)
			show_missing.append("and more...")
		hint_text = "Your list still needs:\n• " + "\n• ".join(show_missing) + "\n\nYou don't need to buy everything.\nCompleting more of the list improves your score."
	else:
		hint_text = "Your shopping list is complete!\n\nReview your cart, then continue to Checkout when the total is within your budget."

	var body := _label(hint_text, 11, false, TEXT)
	body.position = Vector2(25, 65)
	body.size = Vector2(278, 190)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	body.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	body.clip_text = false
	overlay.add_child(body)

	var close := _make_button("Got it", MINT, Vector2(180, 46))
	close.position = Vector2(74, 276)
	close.add_theme_font_size_override("font_size", 15)
	close.pressed.connect(func():
		backdrop.queue_free()
		overlay.queue_free()
	)
	overlay.add_child(close)


func _product_by_id(id: String) -> Array:
	for item in products:
		if str(item[0]) == id:
			return item
	return []

func _needed(id: String) -> int:
	for item in shopping_list:
		if str(item["id"]) == id:
			return int(item["need"])
	return 0

func _cart_total() -> int:
	var total := 0
	for id in cart:
		var data := _product_by_id(str(id))
		total += int(cart[id]) * int(data[3])
	return total

func _buy_product(id: String) -> void:
	var data := _product_by_id(id)
	if data.is_empty():
		return

	# The player may always add an item, including items that are not on the
	# shopping list. If the cart becomes over budget, Checkout is locked.
	var current := int(cart.get(id, 0))
	cart[id] = current + 1

	# A button on the Cart screen must rebuild the Cart screen itself.
	# Do not refresh the Shop UI here: those Shop controls have already been
	# freed when the Cart screen was opened.
	if auto_save_enabled:
		_save_progress()

	if current_screen == "cart":
		_show_cart()
	else:
		_refresh_shop_ui()


func _product_state(id: String) -> String:
	var q := int(cart.get(id, 0))
	var need := _needed(id)

	if q == 0:
		return "normal"
	if need > 0 and q == need:
		return "exact"
	if need > 0 and q < need:
		return "under"
	if need > 0 and q > need:
		return "over"
	return "selected"

func _product_style(state: String) -> StyleBoxFlat:
	match state:
		"exact":
			return _panel_style(Color("#eaf8ee"), 10, Color("#69c98a"), 2)
		"under":
			return _panel_style(Color("#eaf4fc"), 10, Color("#62a9dc"), 2)
		"over":
			return _panel_style(Color("#fff1df"), 10, Color("#f0a33a"), 2)
		"selected":
			return _panel_style(Color("#f5f8fb"), 10, Color("#b7c6d2"), 2)
		"hover":
			return _panel_style(Color("#fffdf9"), 10, Color("#d6c8b7"), 1)
		"pressed":
			return _panel_style(Color("#f5f8fb"), 10, Color("#8db8d7"), 2)
		_:
			return _panel_style(SHELF, 10, Color("#e2d6c7"), 1)

func _refresh_shop_ui() -> void:
	var spent := _cart_total()
	var remaining := budget_amount - spent

	var list_total := 0
	for item in shopping_list:
		var pdata := _product_by_id(str(item["id"]))
		if not pdata.is_empty():
			list_total += int(item["need"]) * int(pdata[3])
	var list_remaining := budget_amount - list_total

	if total_label:
		total_label.text = "List total $" + str(list_total) + " • Remaining after full list: $" + str(list_remaining)

	for item in shopping_list:
		var id := str(item["id"])
		var need := int(item["need"])
		var have := int(cart.get(id, 0))
		var state := _product_state(id)

		if list_panels.has(id):
			var panel: Panel = list_panels[id]
			var fill := Color("#fffdf9")
			var border := LINE
			if state == "exact":
				fill = Color("#eaf8ee")
				border = Color("#69c98a")
			elif state == "under" and have > 0:
				fill = Color("#eaf4fc")
				border = Color("#62a9dc")
			elif state == "over":
				fill = Color("#fff1df")
				border = Color("#f0a33a")
			panel.add_theme_stylebox_override("panel", _panel_style(fill, 10, border, 2 if have > 0 else 1))

		if list_labels.has(id):
			var label: Label = list_labels[id]
			label.text = "□ " + str(item["name"]) + " x" + str(need) + "\nHave " + str(have) + " / Need " + str(need)
			if state == "exact":
				label.add_theme_color_override("font_color", Color("#287a49"))
			elif state == "under" and have > 0:
				label.add_theme_color_override("font_color", Color("#286e9e"))
			elif state == "over":
				label.add_theme_color_override("font_color", Color("#a75b10"))
			else:
				label.add_theme_color_override("font_color", TEXT)

	for id in product_buttons:
		var sid := str(id)
		var b: Button = product_buttons[sid]
		var state := _product_state(sid)
		b.add_theme_stylebox_override("normal", _product_style(state))
		b.add_theme_stylebox_override("hover", _product_style(state))
		b.add_theme_stylebox_override("pressed", _product_style(state))

		var q := int(cart.get(sid, 0))
		if product_badges.has(sid):
			var badge: Label = product_badges[sid]
			badge.visible = q > 0
			badge.text = "x" + str(q)
			var badge_style := StyleBoxFlat.new()
			badge_style.set_corner_radius_all(9)
			badge_style.content_margin_left = 1
			badge_style.content_margin_right = 1
			badge_style.content_margin_top = 0
			badge_style.content_margin_bottom = 0
			if state == "exact":
				badge_style.bg_color = Color("#67bd84")
			elif state == "over":
				badge_style.bg_color = Color("#f0a33a")
			elif state == "under":
				badge_style.bg_color = Color("#78a9c9")
			else:
				badge_style.bg_color = Color("#9ca7ad")
			badge.add_theme_stylebox_override("normal", badge_style)

	money_label.text = _t("Money: $" + str(budget_amount - spent))

func _return_to_shop() -> void:
	_show_shop(false)

func _show_cart() -> void:
	current_screen = "cart"
	_clear_content()

	var title := _label("SHOPPING CART", 21, true)
	title.position = Vector2(12, 10)
	title.size = Vector2(340, 34)
	content.add_child(title)

	var card := Panel.new()
	card.position = Vector2(12, 54)
	card.size = Vector2(340, 470)
	card.add_theme_stylebox_override("panel", _panel_style(CARD, 16))
	content.add_child(card)

	var spent := _cart_total()
	var money_left := budget_amount - spent

	if cart.is_empty():
		_add_icon(card, "cart", Vector2(158, 24), Vector2(24, 24))

		var empty_title := _label("Your cart is empty.", 12, true, SOFT)
		empty_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_title.position = Vector2(20, 52)
		empty_title.size = Vector2(300, 20)
		card.add_child(empty_title)

		var empty_sub := _label("Go back to the supermarket\nand pick products.", 10, false, SOFT)
		empty_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_sub.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		empty_sub.position = Vector2(32, 75)
		empty_sub.size = Vector2(276, 34)
		empty_sub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(empty_sub)

		var inner_back := _make_button("Back to Shop", BLUE, Vector2(145, 34))
		inner_back.position = Vector2(10, 116)
		inner_back.add_theme_font_size_override("font_size", 14)
		inner_back.pressed.connect(_return_to_shop)
		card.add_child(inner_back)

		var inner_menu := _make_button("Main Menu", AMBER, Vector2(145, 34))
		inner_menu.position = Vector2(173, 116)
		inner_menu.add_theme_font_size_override("font_size", 14)
		inner_menu.pressed.connect(_show_menu)
		card.add_child(inner_menu)

		var separator := HSeparator.new()
		separator.position = Vector2(10, 185)
		separator.size = Vector2(320, 2)
		card.add_child(separator)

		var total_name := _label("TOTAL", 12, true, TEXT)
		total_name.position = Vector2(14, 197)
		total_name.size = Vector2(150, 20)
		card.add_child(total_name)

		var total_value := _label("$0", 12, true, TEXT)
		total_value.position = Vector2(175, 197)
		total_value.size = Vector2(140, 20)
		total_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		card.add_child(total_value)

		var money_name := _label("MONEY", 12, false, TEXT)
		money_name.position = Vector2(14, 219)
		money_name.size = Vector2(150, 20)
		card.add_child(money_name)

		var money_value := _label("$" + str(budget_amount), 12, false, TEXT)
		money_value.position = Vector2(175, 219)
		money_value.size = Vector2(140, 20)
		money_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		card.add_child(money_value)

		var rem_name := _label("REMAINING", 12, true, TEXT)
		rem_name.position = Vector2(14, 241)
		rem_name.size = Vector2(150, 20)
		card.add_child(rem_name)

		var rem_value := _label("$" + str(budget_amount), 12, true, MINT)
		rem_value.position = Vector2(175, 241)
		rem_value.size = Vector2(140, 20)
		rem_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		card.add_child(rem_value)

		var missing_names: Array[String] = []
		for item in shopping_list:
			var required: int = int(item["need"])
			var have: int = int(cart.get(str(item["id"]), 0))
			if have < required:
				missing_names.append(str(item["name"]) + " x" + str(required - have))

		var warning := Panel.new()
		warning.position = Vector2(14, 268)
		warning.size = Vector2(312, 42)
		warning.add_theme_stylebox_override("panel", _panel_style(Color("#fae8e5"), 10, Color(0,0,0,0), 0))
		card.add_child(warning)
		var warning_text := _label(
			"You can checkout now. Still missing: " + ", ".join(missing_names) + ".\nChoosing to skip items will reduce your final score.",
			8, true, Color("#d85d55")
		)
		warning_text.position = Vector2(8, 3)
		warning_text.size = Vector2(296, 34)
		warning_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		warning_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		card.add_child(warning)
		warning.add_child(warning_text)
	else:
		# Compact rows: small icons and controls so four or more products remain readable.
		var cart_scroll := ScrollContainer.new()
		cart_scroll.position = Vector2(10, 10)
		cart_scroll.size = Vector2(320, 188)
		cart_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		card.add_child(cart_scroll)

		var cart_lines := VBoxContainer.new()
		cart_lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cart_lines.add_theme_constant_override("separation", 1)
		cart_scroll.add_child(cart_lines)

		for id in cart:
			var q := int(cart[id])
			if q <= 0:
				continue
			var data := _product_by_id(str(id))
			if data.is_empty():
				continue

			var row := Panel.new()
			row.clip_contents = true
			row.custom_minimum_size = Vector2(0, 38)
			row.add_theme_stylebox_override("panel", _panel_style(Color("#fffdf9"), 8, Color("#e9dfd2"), 0))
			cart_lines.add_child(row)

			_add_icon(row, str(data[1]), Vector2(8, 12), Vector2(14, 14))

			var info := _label(str(data[2]) + "\n$" + str(data[3]) + " each", 9, true, TEXT)
			info.position = Vector2(26, 2)
			info.size = Vector2(108, 34)
			info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			info.clip_text = true
			row.add_child(info)

			var minus := _make_button("−", BLUE, Vector2(24, 24))
			minus.position = Vector2(145, 7)
			minus.add_theme_font_size_override("font_size", 11)
			minus.pressed.connect(_remove_one.bind(str(id)))
			row.add_child(minus)

			var qty := _label("x" + str(q), 10, true, TEXT)
			qty.position = Vector2(172, 5)
			qty.size = Vector2(28, 28)
			qty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			qty.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row.add_child(qty)

			var plus := _make_button("+", MINT, Vector2(24, 24))
			plus.position = Vector2(203, 7)
			plus.add_theme_font_size_override("font_size", 11)
			plus.pressed.connect(_buy_product.bind(str(id)))
			row.add_child(plus)

			var line_total := _label("$" + str(q * int(data[3])), 11, true, TEXT)
			line_total.position = Vector2(233, 2)
			line_total.size = Vector2(82, 34)
			line_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			line_total.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			row.add_child(line_total)

		var separator := HSeparator.new()
		separator.position = Vector2(10, 200)
		separator.size = Vector2(320, 2)
		card.add_child(separator)

		var total_name := _label("TOTAL", 12, true, TEXT)
		total_name.position = Vector2(14, 210)
		total_name.size = Vector2(150, 20)
		card.add_child(total_name)

		var total_value := _label("$" + str(spent), 14, true, TEXT)
		total_value.position = Vector2(175, 210)
		total_value.size = Vector2(140, 20)
		total_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		if money_left < 0:
			total_value.add_theme_color_override("font_color", Color("#d85d55"))
		card.add_child(total_value)

		var money_name := _label("MONEY", 12, false, TEXT)
		money_name.position = Vector2(14, 232)
		money_name.size = Vector2(150, 20)
		card.add_child(money_name)

		var money_value := _label("$" + str(budget_amount), 12, false, TEXT)
		money_value.position = Vector2(175, 232)
		money_value.size = Vector2(140, 20)
		money_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		card.add_child(money_value)

		var rem_name := _label("REMAINING", 12, true, TEXT)
		rem_name.position = Vector2(14, 254)
		rem_name.size = Vector2(150, 20)
		card.add_child(rem_name)

		var rem_value := _label("$" + str(money_left), 12, true, TEXT)
		rem_value.position = Vector2(175, 254)
		rem_value.size = Vector2(140, 20)
		rem_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		rem_value.add_theme_color_override("font_color", Color("#d85d55") if money_left < 0 else MINT)
		card.add_child(rem_value)

		if money_left < 0:
			var warning := Panel.new()
			warning.position = Vector2(14, 280)
			warning.size = Vector2(312, 38)
			warning.add_theme_stylebox_override("panel", _panel_style(Color("#fae8e5"), 10, Color(0,0,0,0), 0))
			card.add_child(warning)
			var warning_text := _label(
				"Over Budget! Remove items until the total is within your $" + str(budget_amount) + " budget.",
				8, true, Color("#d85d55")
			)
			warning_text.position = Vector2(8, 2)
			warning_text.size = Vector2(296, 34)
			warning_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			warning_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			warning.add_child(warning_text)

	var back := _make_button("Back to Shop", BLUE, Vector2(169, 40))
	back.position = Vector2(12, 650)
	back.pressed.connect(_return_to_shop)
	content.add_child(back)

	var checkout := _make_button("CHECKOUT", MINT, Vector2(169, 40))
	checkout.position = Vector2(181, 650)
	checkout.disabled = cart.is_empty() or money_left < 0
	if checkout.disabled:
		checkout.add_theme_stylebox_override("disabled", _button_style(Color("#c8d9c9")))
		checkout.add_theme_color_override("font_disabled_color", Color("#ffffff"))
	else:
		checkout.pressed.connect(_show_checkout)
	content.add_child(checkout)


func _show_checkout() -> void:
	current_screen = "checkout"
	_clear_content()
	money_label.text = _t("Money: $" + str(budget_amount))

	var title := _label("CHECKOUT", 23, true)
	title.position = Vector2(12, 18)
	title.size = Vector2(340, 36)
	content.add_child(title)

	var card := Panel.new()
	card.position = Vector2(12, 62)
	card.size = Vector2(340, 590)
	card.add_theme_stylebox_override("panel", _panel_style(CARD, 17))
	content.add_child(card)

	var items_title := _label("Your Items", 15, true)
	items_title.position = Vector2(12, 10)
	items_title.size = Vector2(160, 28)
	card.add_child(items_title)

	var cart_item_count: int = 0
	for id in cart:
		if int(cart[id]) > 0:
			cart_item_count += 1

	var item_rows: int = cart_item_count
	if item_rows < 1:
		item_rows = 1
	if item_rows > 8:
		item_rows = 8
	# Give the item rows enough vertical room before the totals section.
	var items_height: int = 98 + item_rows * 32
	if items_height < 170:
		items_height = 170

	var items_box := Panel.new()
	items_box.position = Vector2(12, 45)
	items_box.size = Vector2(316, items_height)
	items_box.add_theme_stylebox_override("panel", _panel_style(Color("#fffdf9"), 12, LINE, 1))
	card.add_child(items_box)

	var y: int = 10
	for id in cart:
		var q: int = int(cart[id])
		if q <= 0:
			continue
		var data: Array = _product_by_id(str(id))
		if data.is_empty():
			continue

		var item_name := _label(str(data[2]) + " x" + str(q), 12, false, TEXT)
		item_name.position = Vector2(10, y)
		item_name.size = Vector2(210, 25)
		item_name.clip_text = true
		items_box.add_child(item_name)

		var item_total := _label("$" + str(q * int(data[3])), 12, true, TEXT)
		item_total.position = Vector2(238, y)
		item_total.size = Vector2(65, 25)
		item_total.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		items_box.add_child(item_total)
		y += 32

	var sep_y: int = items_height - 70
	var sep := HSeparator.new()
	sep.position = Vector2(10, sep_y)
	sep.size = Vector2(296, 1)
	items_box.add_child(sep)

	var spent: int = _cart_total()
	var money_left: int = budget_amount - spent

	var total_name := _label("TOTAL", 16, true)
	total_name.position = Vector2(10, sep_y + 6)
	total_name.size = Vector2(160, 26)
	items_box.add_child(total_name)

	var total_value := _label("$" + str(spent), 16, true)
	total_value.position = Vector2(225, sep_y + 6)
	total_value.size = Vector2(68, 26)
	total_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	items_box.add_child(total_value)

	var money_name := _label("YOUR MONEY", 12, false)
	money_name.position = Vector2(10, sep_y + 32)
	money_name.size = Vector2(180, 22)
	items_box.add_child(money_name)

	var money_value := _label("$" + str(budget_amount), 12, true)
	money_value.position = Vector2(225, sep_y + 32)
	money_value.size = Vector2(68, 22)
	money_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	items_box.add_child(money_value)

	var rem_name := _label("REMAINING", 12, false)
	rem_name.position = Vector2(10, sep_y + 54)
	rem_name.size = Vector2(180, 22)
	items_box.add_child(rem_name)

	var rem_value := _label("$" + str(money_left), 12, true)
	rem_value.position = Vector2(225, sep_y + 54)
	rem_value.size = Vector2(68, 22)
	rem_value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if money_left < 0:
		rem_value.add_theme_color_override("font_color", Color("#d85d55"))
	items_box.add_child(rem_value)

	var missing_names: Array[String] = []
	for item in shopping_list:
		var required: int = int(item["need"])
		var have: int = int(cart.get(str(item["id"]), 0))
		if have < required:
			missing_names.append(str(item["name"]) + " x" + str(required - have))

	var next_y: int = 45 + items_height + 12
	if not missing_names.is_empty():
		var decision_height: int = 72
		var decision := Panel.new()
		decision.position = Vector2(12, next_y)
		decision.size = Vector2(316, decision_height)
		decision.add_theme_stylebox_override("panel", _panel_style(Color("#fff1ed"), 12, Color("#f1d2ca"), 1))
		card.add_child(decision)

		var missing_display: Array = missing_names.duplicate()
		if missing_display.size() > 3:
			var extra_count: int = missing_display.size() - 3
			missing_display = missing_display.slice(0, 3)
			missing_display.append("+" + str(extra_count) + " more")
		var missing_text: String = "Still missing: " + ", ".join(missing_display) + "\nYou can pay, but your final score will be lower."
		var decision_label := _label(missing_text, 10, true, Color("#c95b52"))
		decision_label.position = Vector2(10, 7)
		decision_label.size = Vector2(296, 58)
		decision_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		decision_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		decision.add_child(decision_label)
		next_y += decision_height + 10

	var pay_title := _label("Choose your payment", 14, true)
	pay_title.position = Vector2(12, next_y)
	pay_title.size = Vector2(220, 24)
	card.add_child(pay_title)
	next_y += 30

	# If the cart total exactly matches the available money, there is only one
	# meaningful payment choice. Otherwise the player can pay the cart total or
	# hand over the full budget amount.
	if spent == budget_amount:
		var pay_exact := _make_button("PAY $" + str(spent), BLUE, Vector2(316, 48))
		pay_exact.position = Vector2(12, next_y)
		pay_exact.add_theme_font_size_override("font_size", 17)
		pay_exact.pressed.connect(_pay_cart_amount)
		card.add_child(pay_exact)
	else:
		var pay_cart := _make_button("PAY $" + str(spent), BLUE, Vector2(154, 48))
		pay_cart.position = Vector2(12, next_y)
		pay_cart.add_theme_font_size_override("font_size", 16)
		pay_cart.pressed.connect(_pay_cart_amount)
		card.add_child(pay_cart)

		var pay_full := _make_button("PAY $" + str(budget_amount), BLUE, Vector2(154, 48))
		pay_full.position = Vector2(170, next_y)
		pay_full.add_theme_font_size_override("font_size", 16)
		pay_full.pressed.connect(_pay_full_amount)
		card.add_child(pay_full)

	var back := _make_button("Back to Cart", BLUE, Vector2(340, 48))
	back.position = Vector2(12, 665)
	back.pressed.connect(_show_cart)
	content.add_child(back)


func _show_complete() -> void:
	current_screen = "complete"
	_clear_content()

	money_label.text = _t("Money: $" + str(last_payment_amount))

	var card := Panel.new()
	card.position = Vector2(10, 92)
	card.size = Vector2(344, 430)
	card.add_theme_stylebox_override("panel", _panel_style(Color("#fffdf9"), 18, LINE, 1))
	content.add_child(card)

	_add_icon(card, "check", Vector2(170, 18), Vector2(28, 28))

	var title := _label("SHOPPING COMPLETE!", 15, true, TEXT)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.position = Vector2(20, 48)
	title.size = Vector2(304, 24)
	card.add_child(title)

	var total_label_done := _label("TOTAL: $" + str(last_payment_total), 12, false, TEXT)
	total_label_done.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	total_label_done.position = Vector2(20, 82)
	total_label_done.size = Vector2(304, 20)
	card.add_child(total_label_done)

	var paid := _label("PAID: $" + str(last_payment_amount), 12, false, TEXT)
	paid.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	paid.position = Vector2(20, 104)
	paid.size = Vector2(304, 20)
	card.add_child(paid)

	var change := last_payment_amount - last_payment_total
	var change_label := _label("CHANGE: $" + str(change), 12, false, TEXT)
	change_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	change_label.position = Vector2(20, 126)
	change_label.size = Vector2(304, 20)
	card.add_child(change_label)

	var completion := _label(
		"LIST COMPLETION: " + str(shopping_list.size() - last_missing_count) + "/" + str(shopping_list.size()) + " items",
		12, false, SOFT
	)
	completion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	completion.position = Vector2(20, 150)
	completion.size = Vector2(304, 20)
	card.add_child(completion)

	var missing_text := ""
	if last_missing_names.is_empty():
		missing_text = "All shopping list items purchased!"
	else:
		missing_text = "Not purchased: " + ", ".join(last_missing_names)

	var missing := _label(missing_text, 10, false, SOFT)
	missing.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	missing.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	missing.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	missing.position = Vector2(22, 178)
	missing.size = Vector2(300, 30)
	card.add_child(missing)

	for i in range(5):
		var star_name := "star_filled" if i < last_score else "star_empty"
		_add_icon(card, star_name, Vector2(126 + i * 20, 220), Vector2(16, 16))

	var next_text := "NEXT LEVEL"
	if current_level >= LEVEL_COUNT:
		next_text = "NEW RUN"
	var next := _make_button(next_text, MINT, Vector2(140, 34))
	next.position = Vector2(102, 250)
	next.add_theme_font_size_override("font_size", 13)
	next.pressed.connect(_next_level_from_complete)
	card.add_child(next)

	var menu := _make_button("MAIN MENU", BLUE, Vector2(140, 34))
	menu.position = Vector2(102, 292)
	menu.add_theme_font_size_override("font_size", 13)
	menu.pressed.connect(_main_menu_from_complete)
	card.add_child(menu)


func _next_level_from_complete() -> void:
	if current_level >= LEVEL_COUNT:
		current_level = 1
		level_used_signatures.clear()
	else:
		current_level += 1
	cart.clear()
	_show_shop(true)


func _main_menu_from_complete() -> void:
	current_level = 1
	level_used_signatures.clear()
	cart.clear()
	budget_amount = 75
	money_label.text = _t("Money: $75")
	_show_menu()


func _pay_cart_amount() -> void:
	_finish_payment(_cart_total())


func _pay_full_amount() -> void:
	_finish_payment(budget_amount)


func _finish_payment(amount: int) -> void:
	if cart.is_empty():
		return

	var total := _cart_total()
	# Checkout already blocks an over-budget cart, but keep the guard here too.
	if total > budget_amount:
		return

	last_payment_amount = amount
	last_payment_total = total
	last_missing_names.clear()

	for item in shopping_list:
		var required := int(item["need"])
		var have := int(cart.get(str(item["id"]), 0))
		if have < required:
			last_missing_names.append(str(item["name"]) + " x" + str(required - have))

	last_missing_count = last_missing_names.size()

	# Score is based on completing the requested list. Full list + affordable
	# payment = 5 stars. Missing requested items reduce the score.
	if last_missing_count == 0:
		last_score = 5
	elif last_missing_count == 1:
		last_score = 4
	elif last_missing_count == 2:
		last_score = 3
	elif last_missing_count == 3:
		last_score = 2
	else:
		last_score = 1

	_show_complete()


func _checkout() -> void:
	# Only a cart inside the current budget can be paid for.
	if cart.is_empty() or _cart_total() > budget_amount:
		return

	if current_level < LEVEL_COUNT:
		current_level += 1
		if auto_save_enabled:
			_save_progress()
		_show_shop(true)
	else:
		# After the last level, start a fresh run with new combinations.
		current_level = 1
		level_used_signatures.clear()
		if auto_save_enabled:
			_save_progress()
		_show_shop(true)


func _remove_one(id: String) -> void:
	var q := int(cart.get(id, 0))
	if q <= 1:
		cart.erase(id)
	else:
		cart[id] = q - 1

	if auto_save_enabled:
		_save_progress()

	# Rebuild only the screen that owns the button that was pressed.
	if current_screen == "cart":
		_show_cart()
	else:
		_refresh_shop_ui()
