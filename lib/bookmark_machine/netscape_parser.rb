require 'nokogiri'

module BookmarkMachine
  # Parser for the Netscape Bookmark File format.
  # Amusingly, the best documentation for the format comes from Microsoft.
  # 
  #   https://msdn.microsoft.com/en-us/library/aa753582(v=vs.85).aspx
  #
  # We live in interesting times.
  class NetscapeParser
    
    def initialize(html)
      @html = html
    end
    
    # Returns an Array of Bookmark objects.
    def bookmarks
      @bookmarks ||= begin
        doc = BookmarkDocument.new
        parser = Nokogiri::HTML::SAX::Parser.new(doc)
        parser.parse(@html)
        
        doc.bookmarks
      end
    end
    
  end
  
  # :nodoc:
  # BookmarkDocument implements SAX callbacks for parsing messy bookmark files.
  # It turns out that a SAX parser is more resilient to bizarre inputs than the
  # typical Nokogiri parser since it doesn't bother itself with the document 
  # structure.
  class BookmarkDocument < Nokogiri::XML::SAX::Document
    attr_reader :bookmarks
    
    def initialize
      super
      
      @folders = []
      @bookmarks = []
      @current_bookmark = nil
      
      reset_state
    end
    
    # Only three elements have semantic meaning, A, H3, and DD,
    # representing Folder names, Bookmarks, and Descriptions.
    def start_element(name, attrs = [])
      case name
      when "a"  then start_bookmark(attrs)
      when "h3" then start_folder(attrs)
      when "dd" then start_description(attrs)
      else           done
      end
    end
    
    # Only one closing element has semantic meaning, a closed DL,
    # which indicates the end of a folder.
    def end_element(name, attrs = [])
      case name
      when "dl" then pop_folder
      else           done
      end
    end
    
    def end_document
      done
    end
    
    def characters(string)
      @text << string if @state
    end
    
    def start_bookmark(attrs)
      attrs = Hash[attrs]
      
      @current_bookmark = Bookmark.new(attrs['href'])
      @current_bookmark.created_at = epoch_time(attrs['add_date'])
      @current_bookmark.updated_at = epoch_time((attrs['last_modified'] || attrs['add_date']))
      @current_bookmark.icon = attrs['icon'] || attrs['icon_uri']
      @current_bookmark.tags = tagged_text(attrs['tags'])
      @current_bookmark.folders = @folders.clone
      
      @state = :bookmark
    end
    
    def start_folder(attrs)
      @state = :folder
    end
    
    def start_description(attrs)
      @state = :description
    end
    
    def done
      case @state
      when :bookmark
        @current_bookmark.name = @text.strip
        @bookmarks << @current_bookmark
        @current_bookmark = nil
        reset_state
        
      when :folder
        @folders << @text.strip
        reset_state
        
      when :description
        description = @text.strip
        @bookmarks.last.description = description unless description == ""
        reset_state
        
      end
    end
    
    def pop_folder
      @folders.pop
      done
    end
    
    def reset_state
      @text = ""
      @state = nil
    end
    
    # Converts from epoch seconds to a Time object.
    # Returns nil on a nil input.
    def epoch_time(seconds)
      Time.at(seconds.to_i) if seconds
    end
    
    def tagged_text(str)
      str.split(",").map{|t| t.strip} if str
    end
    
  end
  
end