require_relative "./test_helper"

class NetscapeFormatterTest < BookmarkMachineTest
  
  def test_includes_netscape_bookmark_file_doctype
    writer = NetscapeFormatter.new([])
    
    html = writer.to_html
    doctype = html.each_line.first.chomp
    
    assert_equal "<!DOCTYPE NETSCAPE-Bookmark-file-1>", doctype
  end
  
  def test_includes_root_folder
    writer = NetscapeFormatter.new([])
    
    html = writer.to_html
    
    assert_includes html.gsub(/\s+/,""), "<DL><p>", "Should include an opening DL"
    assert_includes html.gsub(/\s+/,""), "</DL>", "Should a closing DL"
  end
  
  def test_roundtrips_a_single_bookmark_with_url
    url = "http://example.com"
    bookmark = Bookmark.new(url)
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_single_bookmark_with_name
    bookmark = Bookmark.new("http://example.com", name: "Example")
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_single_bookmark_with_timestamps
    time = Time.now.round # Round to strip off microseconds
    bookmark = Bookmark.new("http://example.com", created_at: time, updated_at: time + 1)
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_single_bookmark_with_icon_url
    bookmark = Bookmark.new("http://example.com", icon: "http://example.com/icon.ico")
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_single_bookmark_with_icon_uri
    bookmark = Bookmark.new("http://example.com", icon: "data:image/png;base64,iVBOR=")
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_single_bookmark_with_tags
    bookmark = Bookmark.new("http://example.com", tags: ["one","two"])
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_single_bookmark_with_description
    bookmark = Bookmark.new("http://example.com", description: "DESCRIPTION")
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_single_bookmark_with_folder
    bookmark = Bookmark.new("http://example.com", folders: ["Folder 1"])
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_single_bookmark_with_multipe_folders
    bookmark = Bookmark.new("http://example.com", folders: ["Folder 1", "Folder 2"])
    
    assert_round_trips(bookmark)
  end
  
  def test_roundtrips_a_multiple_bookmarks_with_multipe_folders
    bookmarks = [
      Bookmark.new("http://example.com", folders: ["Folder 1", "Folder 2"]),
      Bookmark.new("http://example.com", folders: ["Folder 1"]),
      Bookmark.new("http://example.com", folders: ["Folder 2"]),
      Bookmark.new("http://example.com", folders: ["Folder 2", "Folder 3"])
    ]
    
    assert_round_trips(bookmarks)
  end
  
  def test_can_round_trip_a_chrome_bookmark_file
    assert_round_trips_fixture("chrome.html")
  end
  
  def test_can_round_trip_a_firefox_bookmark_file
    assert_round_trips_fixture("firefox.html")
  end
  
  def test_can_round_trip_a_delicious_bookmark_file
    assert_round_trips_fixture("delicious.html")
  end
  
  private
  
  def assert_select(doc, selector, count=1, message=nil)
    actual_count = doc.css(selector).count
    
    assert_equal count, actual_count, message
  end
  
  def assert_round_trips(bookmarks)
    bookmarks = Array(bookmarks)
    
    formatter = NetscapeFormatter.new(bookmarks)
    html = formatter.to_html
    
    parser = NetscapeParser.new(html)
    parsed = parser.bookmarks
    
    assert_equal bookmarks, parsed, "Formatter produced:\n#{html}"
  end
  
  def assert_round_trips_fixture(path)
    parser = NetscapeParser.new(fixture(path))
    
    assert_round_trips(parser.bookmarks)
  end
  
end