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
    
    # Bookmarks are considered equal if all attributes are equal.
    # Which is probably what you would have excpected.
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