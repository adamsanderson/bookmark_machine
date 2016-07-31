require 'nokogiri'

module BookmarkMachine
  # Parser for the Netscape Bookmark File format.
  # Amusingly, the best documentation for it seems to come from Microsoft.
  # 
  #   https://msdn.microsoft.com/en-us/library/aa753582(v=vs.85).aspx
  #
  # We live in interesting times.
  class NetscapeParser
    attr_reader :doc
    
    def initialize(str)
      @doc = Nokogiri::HTML(str)
    end
    
    def bookmarks
      @bookmarks ||= begin
        bookmark_nodes = @doc.css("a[href]")
        bookmarks = bookmark_nodes.map{|el| convert_element(el) }
        bookmarks.select{|b| b.url && b.url =~ /^http(s)?\:/i }
      end
    end
    
    private
    
    def convert_element(el)
      bookmark = Bookmark.new(el[:href], el.text.strip)
      
      bookmark.created_at = epoch_time(el[:add_date])
      bookmark.updated_at = epoch_time((el[:last_modified] || el[:add_date]))
      bookmark.icon = el[:icon] || el[:icon_uri]
      bookmark.description = description_text(el)
      bookmark.tags = tagged_text(el[:tags])
      bookmark.parents = parent_names(el)
      
      bookmark
    end
    
    # Converts from epoch seconds to a Time object.
    # Returns nil on a nil input.
    def epoch_time(seconds)
      Time.at(seconds.to_i) if seconds
    end
    
    def tagged_text(str)
      str.split(",").map{|t| t.strip} if str
    end
     
    def description_text(el)
      sibling = el.parent.next_sibling
      
      if sibling && sibling.name == "dd"
        description = sibling.text.strip
        return description unless description == ""
      end
    end
    
    def parent_names(el)
      parents = []
      list_elements = el.ancestors("dl")
      parents = list_elements.map do |el|
        prev_el = el.previous
        folder_el = prev_el && prev_el.at_css("h3")
        folder_el && folder_el.text.strip
      end
      
      parents.compact.reverse
    end
    
  end
end