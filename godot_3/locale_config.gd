## 本地化配置
## 适用于 Godot 3
##
## https://github.com/Android-KitKat/godot-locale
class_name LocaleConfig


## 字体预设
var fonts := [
  #preload("res://ui/default_theme.tres").default_font,
  #preload("res://ui/fonts/ParagraphFont.tres")
]

var font_data := preload("C:/Windows/Fonts/simhei.ttf") ## 字体数据

var assets_path := "user://locale/" ## 资源路径
var locale := "" ## 本地化语言

var dump_mode := false ## 是否进行转储
var dump_path := assets_path + "dump.pot" ## 转储路径
