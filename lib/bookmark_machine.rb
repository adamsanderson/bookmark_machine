require "bookmark_machine/version"
require "bookmark_machine/netscape_parser"
require "bookmark_machine/netscape_formatter"

module BookmarkMachine
  class Bookmark
    attr_accessor :url, :name, :created_at, :updated_at, :icon, :folders, :tags, :description
    
    def initialize(url, attrs=nil)
      self.url = url

      if attrs
        attrs.each{|key,value| self.send("#{key}=", value)}
      end

      self.name    ||= ""
      self.folders ||= []
    end
    
    def == other
      url         == other.url &&
      name        == other.name &&
      created_at  == other.created_at &&
      updated_at  == other.updated_at &&
      icon        == other.icon &&
      folders     == other.folders &&
      tags        == other.tags &&
      description == other.description
    end
  end
end