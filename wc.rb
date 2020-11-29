#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
opt = OptionParser.new

# コマンドの設定
command_line_option = {}
opt.on('-l') do |_v|
  command_line_option[:l] = true
end
opt.parse!(ARGV)
files = ARGV

IsInvalidBytes = [0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x20, 0x85, 0xa0].freeze

def count(content)
  target = []
  # 行数カウント
  target << content.count("\n")
  # 単語数カウント
  splitted_content = content.split(/\s+/)
  invalid_byte_count = 0
  splitted_content.each do |word|
    word_bytes = word.bytes
    word_bytes.each do |byte|
      invalid_byte_count += 1 if IsInvalidBytes.include?(byte)
    end
  end
  target << splitted_content.size + invalid_byte_count
  # ファイルサイズ
  target << content.bytesize
end

if !ARGV.empty?
  outputs = []
  files.each do |file|
    target = count(File.open(file).read)
    # ファイル名
    target << file
    outputs << target
  end
else
  outputs = []
  target = count(readlines.join)
  # ファイル名(ないので空白を入れる)
  target << ''
  outputs << target
end

#-lオプション
if command_line_option[:l]
  line_number = []
  outputs.each do |output|
    print format('%8d', output[0])
    line_number << output[0]
    print ' '
    print output[3]
    print "\n"
  end
  # 引数が２つ以上ある場合
  if outputs.size > 1
    print format('%8d', line_number.sum)
    print ' '
    print 'total'
    print "\n"
  end
else
  line_number = []
  word_number = []
  file_size = []
  outputs.each do |output|
    print format('%8d', output[0])
    line_number << output[0]
    print format('%8d', output[1])
    word_number << output[1]
    print format('%8d', output[2])
    file_size << output[2]
    print ' '
    print output[3]
    print "\n"
  end
  # 引数が２つ以上ある場合
  if outputs.size > 1
    print format('%8d', line_number.sum)
    print format('%8d', word_number.sum)
    print format('%8d', file_size.sum)
    print ' '
    print 'total'
    print "\n"
  end
end
