#!/usr/bin/env ruby
# coding:utf-8
#
# Script för att generera en table of contents för textile-filerna som
# genereras av textilize.rb
#
# Skrivet av Peter Boström, pbos@kth.se, 2012-03-16

file = ARGV.length > 0 ? File.open(ARGV[0]) : STDIN
out = ARGV.length > 0 ? File.open(ARGV[0].sub(/\.textile$/, '') + '.toc.textile', 'w') : STDOUT

file.each_line do |line|
  if line.match /^h([2-6])\(([^)]+)\)\.\s(.*)$/
    out.puts '#' * ($1.to_i - 1) + " \"#{$3}\":#{$2}"
  end
end
