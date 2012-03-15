#!/usr/bin/env ruby
# coding:utf-8
#
# Script för att omvandla tex-filerna till textile för hemsidan, sweet! :)
# Beror nog en massa på huruvidare de är snyggt upplagda osv, flera
# \usepackage på samma rad lär bli fel t.ex.
#
# Skrivet av Peter Boström, pbos@kth.se, 2012-03-15

file = ARGV.length > 0 ? File.open(ARGV[0]) : STDIN
out = ARGV.length > 0 ? File.open(ARGV[0].sub(/\.tex$/, '') + '.textile', 'w') : STDOUT

@tl_table = {
  'å' => 'a',
  'ä' => 'a',
  'ö' => 'o',
  'Å' => 'a',
  'Ä' => 'a',
  'Ö' => 'o',
  ' ' => '_',
  '-' => '_',
}

def to_label(x)
  text = x.downcase
  @tl_table.each_key { |k| text.gsub! k, @tl_table[k] }
  return text.gsub /[^a-z_]/, ''
end

@labels = {}

def gen_label(x)
  label = to_label x
  STDERR.puts "Warning: duplicate label '#{label}'" if @labels[label]
  par = "#{@section}"
  [@subsection, @subsubsection, @paragraph, @subparagraph].each do |level|
    break if level == 0
    par += ".#{level}"
  end
  @labels[label] = par
  return label
end

def text_puts(x = '')
  @text += x + "\n"
end

# section buffer
@text = ''

# paragraph numbering
@section = 0
@subsection = 0
@subsubsection = 0
@paragraph = 0
@subparagraph = 0

# indentation level/types for itemize
indent = ""

# last line (to prevent more newlines than required)
last_line = ''

# process file io
file.each_line do |line|
  line.strip!
  m = line.match /^\\([a-z]+)(\[[^\]]*\])?{([^}]*)}/
  if m.nil?
    # handle regular text lines
    next if line.match /\\maketitle/

    # print list
    @text += indent + ' ' if line.slice! (/^\\item /)

    # replace \S with §
    line.gsub! /\\S(?=\w)/, '§'

    text_puts line unless last_line == '' and line == ''
    last_line = line
    next
  end
  cmd = $1
  param = $3
  case cmd
  when 'title'
    text_puts "h1. #{param}"
    text_puts
  when 'section'
    @section += 1
    @subsection = 0
    label = gen_label param
    text_puts "h2(##{label}). §#{@labels[label]} #{param}"
    text_puts
    last_line = ''
  when 'subsection'
    @subsection += 1
    @subsubsection = 0
    label = gen_label param
    text_puts "h3(##{label}). §#{@labels[label]} #{param}"
    text_puts
    last_line = ''
  when 'subsubsection'
    @subsubsection += 1
    @paragraph = 0
    label = gen_label param
    text_puts "h4(##{label}). §#{@labels[label]} #{param}"
    text_puts
    last_line = ''
  when 'paragraph'
    @paragraph += 1
    @subparagraph = 0
    label = gen_label param
    text_puts "h5(##{label}). §#{@labels[label]} #{param}"
    text_puts
    last_line = ''
  when 'subparagraph'
    @subparagraph += 1
    label = gen_label param
    text_puts "h6(##{label}). §#{@labels[label]} #{param}"
    text_puts
    last_line = ''
  when 'begin'
    case param
    when 'itemize'
      indent += '*'
    when 'enumerate'
      indent += '#'
    when 'document'
    else
      throw "Unrecognized LaTeX environment: #{cmd}:#{param}"
    end
  when 'end'
    case param
    when 'itemize', 'enumerate'
      indent.slice! /.$/
    when 'document'
    else
      throw "Unrecognized LaTeX environment: #{cmd}:#{param}"
    end
  when 'documentclass','usepackage','label'
  else
    throw "Unrecognized LaTeX command: #{cmd}:#{param}"
  end
end

# Replace references
@text.gsub! /\\ref{sec:([^}]+)}/ do |match|
  throw "Error: Undefined label '#{$1}'" if @labels[$1].nil?
  "\"§#{@labels[$1]}\":##{$1}"
end

# Finally output :)
out.puts @text.strip
