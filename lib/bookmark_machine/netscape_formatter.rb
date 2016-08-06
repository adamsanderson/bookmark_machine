require 'nokogiri'

module BookmarkMachine
  # Formatter for the Netscape Bookmark File format.
  # Amusingly, the best documentation for the format comes from Microsoft.
  # 
  #   https://msdn.microsoft.com/en-us/library/aa753582(v=vs.85).aspx
  #
  # We live in interesting times.
  class NetscapeFormatter
    attr_reader :bookmarks
    
    def initialize(bookmarks)
      @bookmarks = bookmarks
    end
    
    # Returns an Array of Bookmark objects.
    def to_html
      writer = Writer.new(StringIO.new)
      
      bookmarks.each{|b| writer << b }
      writer.done
      
      writer.io.string
    end
    
    alias_method :to_s, :to_html
    
    # :nodoc:
    # This is a simple writer for outputting bookmark appropriate HTML.
    # Since the expected HTML doesn't have a root, uses a custom doctype,
    # and doesn't close most tags, it's easier to just write the output 
    # manually rather than try to get Nokogiri to format it poorly for us.
    # 
    # Plus this is just kind of fun in a bizarre un-fun kind of way.
    class Writer
      HEADER = <<-HTML.gsub(/^        /, "")
        <!DOCTYPE NETSCAPE-Bookmark-file-1>
        <!-- This is an automatically generated file.
             It will be read and overwritten.
             DO NOT EDIT! -->
        <META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">
        <TITLE>Bookmarks</TITLE>
        <H1>Bookmarks</H1>
      HTML
      
      attr_reader :io
      attr_reader :folders
      
      def initialize(io)
        @io = io
        @folders = []
        start
      end
      
      def done
        close_all_folders
      end
      
      def << bookmark
        adjust_folders(bookmark.folders)
        write_bookmark(bookmark)
      end
      
      private
      
      def start
        io.puts HEADER
        open_collection
      end
      
      def adjust_folders(new_folders)
        # Find where the new and old folders differ:
        diverge_index = folders.zip(new_folders).find_index{|a,b| a != b} || 0

        # Close old folders after that point:
        folders[diverge_index .. -1].reverse_each do |name|
          close_folder(name)
        end
        
        # Open new folders after that point:
        new_folders[diverge_index .. -1].each do |name|
          open_folder(name)
        end
      end
      
      def close_all_folders
        folders.reverse_each{|name| close_folder(name)}
        # Close root folder
        close_collection
      end
      
      def write_bookmark(bookmark)
        open_tag(:DT)
        
        open_tag(:A) do 
          write_bookmark_attrs(bookmark)
        end
        
        write_text(bookmark.name)
        close_tag(:A)
        
        if bookmark.description
          open_tag(:DD)
          write_text(bookmark.description)
        end
      end
      
      def write_bookmark_attrs(bookmark)
        write_attr(:HREF, bookmark.url) if bookmark.url
        write_attr(:ADD_DATE, bookmark.created_at.to_i) if bookmark.created_at
        write_attr(:LAST_MODIFIED, bookmark.updated_at.to_i) if bookmark.updated_at
        write_attr(:TAGS, bookmark.tags.join(",")) if bookmark.tags
        
        icon = bookmark.icon
        if icon
          attr_name = icon.start_with?("data:") ? :ICON_URI : :ICON
          write_attr(attr_name, icon)
        end
      end
      
      def write_folder(name)
        open_tag(:DT)
        open_tag(:H3)
        write_text(name)
        close_tag(:H3)
      end
      
      def open_folder(name)
        folders.push name
        open_collection
        write_folder(name)
      end
      
      def close_folder(name)
        popped = folders.pop        
        close_collection
      end
      
      def open_collection
        open_tag(:DL)
        open_tag(:p)
      end
      
      def close_collection
        close_tag(:DL)
      end
      
      def open_tag(tag, attributes={})
        io.write("<#{tag} ")
        yield if block_given?
        io.write(">")
      end
      
      def write_attr(name, value)
        io.write(name)
        io.write('="')
        io.write(encode(value))
        io.write('" ')
      end
      
      def close_tag(tag)
        io.write("</#{tag}>")
        io.write("\n")
      end
      
      def write_text(str)
        io.write(encode(str))
      end
      
      def encode(str)
        str.to_s
          .gsub('&', "&amp;")
          .gsub('"', "&quot;")
          .gsub("'", "&apos;")
          .gsub("<", "&lt;")
          .gsub(">", "&gt;")
      end
    end
    
  end
end