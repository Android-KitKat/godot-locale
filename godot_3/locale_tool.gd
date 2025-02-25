## 本地化工具
## 适用于 Godot 3
##
## https://github.com/Android-KitKat/godot-locale
class_name LocaleTool
extends Node


var config := get_config("user://locale/locale_config.gd") ## 本地化配置
var dump: TextDump ## 转储数据


func _ready() -> void:
  # 批量替换字体
  for font in config.fonts:
    font.font_data = config.font_data

  if config.dump:
    # 进行转储
    dump = TextDump.new()
    TranslationServer.clear()
    TranslationServer.add_translation(dump)
  else:
    # 批量添加翻译
    for file in find_files(config.assets_path, "*.po"):
      TranslationServer.add_translation(load(file))

    # 设置本地化语言
    if config.locale:
      TranslationServer.set_locale(config.locale)

  # 应用翻译
  get_tree().notification(NOTIFICATION_TRANSLATION_CHANGED)


func _notification(what: int) -> void:
  # 写入转储
  if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST and config.dump:
    var file := File.new()

    if file.open(config.dump_file, File.WRITE) != OK:
      print("无法写入转储文件")
      return

    dump.entries.sort()
    for entry in dump.entries:
      var text := entry.replace("\"", "\\\"").replace("\\n", "\\\\n").replace("\n", "\\n")
      var row := "msgid \"%s\"\nmsgstr \"\"\n" % text
      file.store_line(row)

    print("已转储文本到 %s" % file.get_path_absolute())
    file.close()


## 获取本地化配置
func get_config(path: String) -> LocaleConfig:
  if ResourceLoader.exists(path):
    return load(path).new()
  else:
    return LocaleConfig.new()


## 返回路径 [param path] 中匹配表达式 [param expr] 的文件
func find_files(path: String, expr := "*") -> Array:
  var dir := Directory.new()

  if dir.open(path) != OK:
    return []

  dir.list_dir_begin()

  var prefix := path if path.ends_with("/") else path + "/"
  var files: Array
  var file := dir.get_next()
  while file:
    if not dir.current_is_dir() and file.matchn(expr):
      files.append(prefix + file)

    file = dir.get_next()

  dir.list_dir_end()

  return files


## 本地化配置
class LocaleConfig:


  var locale := "" ## 本地化语言
  var assets_path := "user://locale/" ## 资源路径

  var fonts := [] ## 字体预设
  var font_data := preload("C:/Windows/Fonts/simhei.ttf") ## 字体数据

  var dump := false ## 是否进行转储
  var dump_file := assets_path + "dump.pot" ## 转储文件


## 文本转储
class TextDump:
  extends Translation


  var entries: Array ## 文本条目


  func _get_message(src_message: String) -> String:
    # 记录文本
    if src_message and not entries.has(src_message):
      entries.append(src_message)

    return ""
