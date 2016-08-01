require "bookmark_machine/version"
require "bookmark_machine/netscape_parser"

module BookmarkMachine
  class Bookmark
    attr_accessor :url, :name, :created_at, :updated_at, :icon, :folders, :tags, :description
    
    def initialize(url, name="")
      self.url = url
      self.name = name
    end
  end
end

