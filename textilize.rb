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

tex_pars = {}
tex_labels = {}

def gen_label(x)
  par = "#{@section}"
  [@subsection, @subsubsection, @paragraph, @subparagraph].each do |level|
    break if level == 0
    par += ".#{level}"
  end
  label = par.gsub(/\./, '_') + '_' + to_label(x)
  @last_par = par
  @last_label = label
end

def text_puts(x = '')
  @text += x + "\n"
end

# section buffer
@text = ''

# paragraph numbering
@first_appendix = true
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
  if m.nil? or $1 == 'ref'
    # handle regular text lines
    next if line.match /\\maketitle/

    # switch to appendix
    unless line.gsub!(/\\appendix/, '').nil?
      @section = 'A'
    end

    # print list
    @text += indent + ' ' if line.slice! (/^\\item /)

    # item formatting for \begin{description}
    line.gsub!(/\\item\[(.*)\]/) { "* *#{$1}*" }

    # replace \S with §
    line.gsub! /\\S(?=\w)/, '§'
    
    # replace \& with &
    line.gsub! /\\&/, '&'

    # replace latex quotations (`` and '') with regular quotes.
    line.gsub! /``|''/, '"'

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
    if @section.is_a? Integer
      @section += 1
    else # String (appendix)
      @section.next! unless @first_appendix
      @first_appendix = false
    end
    @subsection = 0
    gen_label param
    text_puts "h2(##{@last_label}). §#{@last_par} #{param}"
    text_puts
    last_line = ''
  when 'subsection'
    @subsection += 1
    @subsubsection = 0
    gen_label param
    text_puts "h3(##{@last_label}). §#{@last_par} #{param}"
    text_puts
    last_line = ''
  when 'subsubsection'
    @subsubsection += 1
    @paragraph = 0
    gen_label param
    text_puts "h4(##{@last_label}). §#{@last_par} #{param}"
    text_puts
    last_line = ''
  when 'paragraph'
    @paragraph += 1
    @subparagraph = 0
    gen_label param
    text_puts "h5(##{@last_label}). §#{@last_par} #{param}"
    text_puts
    last_line = ''
  when 'subparagraph'
    @subparagraph += 1
    gen_label param
    text_puts "h6(##{@last_label}). §#{@last_par} #{param}"
    text_puts
    last_line = ''
  when 'label'
    tex_pars[param] = @last_par
    tex_labels[param] = @last_label
  when 'begin'
    case param
    when 'itemize'
      indent += '*'
    when 'enumerate'
      indent += '#'
    when 'document'
    when 'description'
    else
      throw "Unrecognized LaTeX environment: #{cmd}:#{param}"
    end
  when 'end'
    case param
    when 'itemize', 'enumerate'
      indent.slice! /.$/
    when 'document'
    when 'description'
    else
      throw "Unrecognized LaTeX environment: #{cmd}:#{param}"
    end
  when 'documentclass','usepackage','label'
  else
    throw "Unrecognized LaTeX command: #{cmd}:#{param}"
  end
end

# Replace references
@text.gsub! /(\\S)?\\ref{([^}]+)}/ do |match|
  throw "Error: Undefined label '#{$2}'" if tex_labels[$2].nil?
  "\"§#{tex_pars[$2]}\":##{tex_labels[$2]}"
end

# Connect paragraphs.
# Textile inserts <br/> between lines, so in order to have format which looks
# decent, all paragraphs have to be joined with a space to form a single line.
def connect_paragraphs(text)
  text.lines('').map do |paragraph|
    lines = paragraph.strip.split("\n")
    text = ""
    lines.each do |line|
      line.strip!
      # Preserve newlines for lists
      unless text.empty?
        text += (line =~ /^[*#]+ /) ? "\n" : " "
      end
      text += line
    end
    text
  end.join "\n\n"
end

# Finally output :)
out.puts connect_paragraphs @text.strip
