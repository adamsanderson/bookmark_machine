#!/usr/bin/env ruby

# This is a quick an dirty script for anonymizing HTML while keeping the
# same general shape.
# 
# Doing this requires a handful of dirty tricks, and the output is not
# quite the same, but Nokogiri will roundtrip it back to the same structure
# anyways.
#
# It's actually pretty amazing that browsers all implement this wickedly 
# broken format.

require 'nokogiri'
require 'base64'

# A useful sampling of words; the original ipsum lorum by Lewis Carroll
WORDS = <<-JABBERWOCKY.split(/[\s\W]+/m).reject{|w| w =~ /\s+/ }.map(&:downcase)
Twas brillig, and the slithy toves
  Did gyre and gimble in the wabe:
All mimsy were the borogoves,
  And the mome raths outgrabe.

Beware the Jabberwock, my son!
  The jaws that bite, the claws that catch!
Beware the Jubjub bird, and shun
  The frumious Bandersnatch!
He took his vorpal sword in hand:
  Long time the manxome foe he sought --
So rested he by the Tumtum tree,
  And stood awhile in thought.
And, as in uffish thought he stood,
  The Jabberwock, with eyes of flame,
Came whiffling through the tulgey wood,
  And burbled as it came!
One, two! One, two! And through and through
  The vorpal blade went snicker-snack!
He left it dead, and with its head
  He went galumphing back.
And, has thou slain the Jabberwock?
  Come to my arms, my beamish boy!
O frabjous day! Callooh! Callay!'
  He chortled in his joy.

Twas brillig, and the slithy toves
  Did gyre and gimble in the wabe;
All mimsy were the borogoves,
  And the mome raths outgrabe.
  
  --Lewis Carroll
  
JABBERWOCKY

@doc = Nokogiri::HTML(ARGV.length > 0 ? IO.read(ARGV[0]) : STDIN.read)

def sub_attr(tag, attr)
  @doc.css("#{tag}[#{attr}]").each do |el|
    el[attr] = yield el[attr]
  end
end

def sub_text(tag)
  @doc.css(tag).each do |el|
    el.content = yield el.content
  end
end

def fake_url
  protocol = rand(10) > 8 ? "http" : "https"
  domain   = (rand(3)+2).times.map{ rand(2 ** 12).to_s(32) }.join(".")
  path     = words(rand(5)).join("/")
  
  "#{protocol}://#{domain}/#{path}"
end

def fake_base_64
  Base64.urlsafe_encode64(words(20).join)
end

def words(length)
  WORDS.sample(length)
end

def replace_words(text, delimiter=" ")
  count = text.split(delimiter).count
  words(count).join(delimiter)
end

def upcase_elements(node)
  # I do not know why, but the bookmark files all use a lowercase
  # p tag.
  node.name = node.name.upcase unless node.name == "p"
  
  # Make sure all the ATTRIBUTES ARE SHOUTING at you!
  node.each do |key, value| 
    node.delete(key)
    node[key.upcase] = value
  end
  node.elements.each{|el| upcase_elements(el) }
end

sub_attr("a", "href")     { fake_url }
sub_attr("a", "icon_uri") { fake_url }
sub_attr("a", "icon")     { "data:image/png;base64,#{ fake_base_64 }" }
sub_attr("a", "tags")     {|s| replace_words(s, ",") }
sub_text("a")             {|s| replace_words(s) }
sub_text("h3")            {|s| replace_words(s) }

# Now we deformat this thing back into the mess it started with:

# 1. Lower case tag names? What is this, 1998? UPCASE!
upcase_elements(@doc.root)

# 2. Strip out closing tags for DT and DD elements.
# 3. Remove the root HTML, HEAD, and BODY elements.
html = @doc.to_html(indent: 2)
  .gsub(%r(\s*</p>\s*),"")      # Do not close P tags
  .gsub(%r(\s*</DT>\s*),"")     # Do not close DT tags
  .gsub(%r(\s*</DD>\s*),"")     # Do not close DD tags
  .gsub(%r(\s*</?HTML>\s*),"")  # Strip HTML tags
  .gsub(%r(\s*</?HEAD>\s*),"")  # Strip HEAD tags
  .gsub(%r(\s*</?BODY>\s*),"")  # Strip BODY tags
  
# All done!
puts html