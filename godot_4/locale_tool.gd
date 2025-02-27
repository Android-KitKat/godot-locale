## 本地化工具
## 适用于 Godot 4
##
## https://github.com/Android-KitKat/godot-locale
class_name LocaleTool
extends Node


const PO_TEMPLATE = """# LANGUAGE Generated by Godot Locale.
#
# https://github.com/Android-KitKat/godot-locale
#
# FIRST AUTHOR <EMAIL@ADDRESS>, YEAR.
#
#, fuzzy
msgid \"\"
msgstr \"\"
\"Project-Id-Version: \\n\"
\"POT-Creation-Date: \\n\"
\"PO-Revision-Date: \\n\"
\"MIME-Version: 1.0\\n\"
\"Content-Type: text/plain; charset=UTF-8\\n\"
\"Content-Transfer-Encoding: 8-bit\\n\"
\"X-Generator: Godot Locale\\n\"
"""

var config := load_config("user://locale/locale_config.gd") ## 本地化配置
var dump: TextDump ## 转储数据


func _ready() -> void:
  # 添加回退字体
  var fonts := config.modify_fonts.duplicate()

  for scene in config.modify_scenes:
    for variant in scene._bundled["variants"]:
      if variant is Font:
        fonts.append(variant)

  for font in fonts:
    font.fallbacks.append(config.font)

  if config.dump:
    # 转储文本
    dump = TextDump.new()
    TranslationServer.clear()
    TranslationServer.add_translation(dump)
  else:
    # 批量添加翻译
    for file in find_files(config.assets_path, "*.po"):
      TranslationServer.add_translation(load(file))

    # 设置本地化代码
    if config.locale:
      TranslationServer.set_locale(config.locale)

  # 应用翻译
  get_tree().notification(NOTIFICATION_TRANSLATION_CHANGED)

  # 合并文本
  if config.merge:
    var base := load(config.merge_base)
    generate_po(config.merge_file, base.get_message_list(), true)


func _notification(what: int) -> void:
  # 写入转储
  if what == NOTIFICATION_WM_CLOSE_REQUEST and config.dump:
    generate_po(config.dump_file, dump.entries)


## 加载本地化配置
func load_config(path: String) -> LocaleConfig:
  if ResourceLoader.exists(path):
    return load(path).new()
  else:
    return LocaleConfig.new()


## 返回路径 [param path] 中匹配表达式 [param expr] 的文件
func find_files(path: String, expr := "*") -> Array[String]:
  var files: Array[String]

  var prefix := path if path.ends_with("/") else path + "/"
  for file in DirAccess.get_files_at(path):
    if file.matchn(expr):
      files.append(prefix + file)

  return files


## 返回文本 [param text] 编码后的内容
func encode_text(text: String) -> String:
  return text.replace("\"", "\\\"").replace("\\n", "\\\\n").replace("\n", "\\n")


## 在路径 [param path] 生成 PO 文件
## [param entries] 为文本条目
## [param with_tr] 为是否翻译文本
func generate_po(path: String, entries: Array[String], with_tr := false) -> void:
  var file := FileAccess.open(path, FileAccess.WRITE)

  if file.get_error() != OK:
    print("无法写入文本到 \"%s\"" % path)
    return

  file.store_line(PO_TEMPLATE)

  entries.sort()
  for entry in entries:
    var msgid := encode_text(entry)
    var msgstr := encode_text(tr(entry)) if with_tr else ""

    if msgstr == msgid:
      msgstr = ""

    var row := "msgid \"%s\"\nmsgstr \"%s\"\n" % [msgid, msgstr]
    file.store_line(row)

  print("已写入文本到 \"%s\"" % file.get_path_absolute())
  file.close()


## 本地化配置
class LocaleConfig:


  var locale := "" ## 本地化代码
  var assets_path := "user://locale/" ## 资源路径

  var font := SystemFont.new() ## 回退字体
  var modify_fonts: Array[Font] ## 需要修改的字体
  var modify_scenes: Array[PackedScene] ## 需要修改字体的场景

  var dump := false ## 是否转储文本
  var dump_file := assets_path + "dump.pot" ## 转储文件

  var merge := false ## 是否合并文本
  var merge_base := assets_path + "base.po" ## 合并基础
  var merge_file := assets_path + "merge.po" ## 合并文件


  func _init() -> void:
    # 使用系统字体
    font.font_names = ["Microsoft YaHei", "SimHei"]


## 文本转储
class TextDump:
  extends Translation


  var entries: Array[String] ## 文本条目


  func _get_message(src_message: StringName, context := &"") -> StringName:
    # 记录文本
    if src_message and not entries.has(src_message):
      entries.append(src_message)

    return &""
