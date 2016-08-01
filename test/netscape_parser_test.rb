require_relative "./test_helper"

class NetscapeParserTest < BookmarkMachineTest
  
  def test_empty_file_returns_no_bookmarks
    parser = fixture_parser("empty.html")
    
    assert_equal [], parser.bookmarks
  end
  
  def test_file_containing_only_folders_returns_no_bookmarks
    parser = fixture_parser("no_bookmarks.html")
    
    assert_equal [], parser.bookmarks
  end
  
  def test_parsing_a_single_bookmark
    parser = fixture_parser("one_bookmark.html")
    
    bookmarks = parser.bookmarks
    
    assert_equal 1, bookmarks.length
  end
  
  def test_converts_parses_url
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/">
    SAMPLE_BOOKMARK
    
    assert_equal "http://example.com/", bookmark.url
  end
  
  def test_converts_dates_only_when_present
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/">
    SAMPLE_BOOKMARK
    
    assert_nil bookmark.created_at
    assert_nil bookmark.updated_at
  end
  
  def test_converts_dates
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/" ADD_DATE="1444432395" LAST_MODIFIED="1444432396">
    SAMPLE_BOOKMARK
    
    assert_equal Time.at(1444432395), bookmark.created_at
    assert_equal Time.at(1444432396), bookmark.updated_at
  end
  
  def test_defaults_updated_at_to_created_at
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/" ADD_DATE="1444432395">
    SAMPLE_BOOKMARK
    
    assert_equal Time.at(1444432395), bookmark.created_at
    assert_equal Time.at(1444432395), bookmark.updated_at
  end
  
  def test_parses_icon_if_present
    uri = "data:image/png;base64,iVBOR"
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/" ICON="#{uri}">
    SAMPLE_BOOKMARK
    
    assert_equal uri, bookmark.icon
  end
  
  def test_parses_icon_uri_if_present
    uri = "http://feeds.feedburner.com/favicon.ico"
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/" ICON_URI="#{uri}">
    SAMPLE_BOOKMARK
    
    assert_equal uri, bookmark.icon
  end
  
  def test_prefers_icon_over_icon_URI
    uri = "http://feeds.feedburner.com/favicon.ico"
    icon = "data:image/png;base64,iVBOR"
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/" ICON="#{icon}" ICON_URI="#{uri}">
    SAMPLE_BOOKMARK
    
    assert_equal icon, bookmark.icon
  end
  
  def test_parses_name
    name = "Example"
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/">
          #{name}
    SAMPLE_BOOKMARK
    
    assert_equal name, bookmark.name
  end
  
  def test_parses_description
    desc = "Description"
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/"> </A>
      <DD> #{desc}
    SAMPLE_BOOKMARK
    
    assert_equal desc, bookmark.description
  end
  
  def test_description_is_nil_when_blank
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/"> </A>
      <DD>
    SAMPLE_BOOKMARK
    
    assert_nil bookmark.description
  end
  
  def test_description_is_nil_when_not_present
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/"> </A>
    SAMPLE_BOOKMARK
    
    assert_nil bookmark.description
  end
  
  def test_parses_tags
    tags = ["one", "two", "three"]
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/" TAGS="#{tags.join(',')}">
    SAMPLE_BOOKMARK
    
    assert_equal tags, bookmark.tags
  end
  
  def test_tags_are_nil_when_not_present
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/">
    SAMPLE_BOOKMARK
    
    assert_nil bookmark.tags
  end
  
  def test_parents_are_empty_when_in_root
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
      <DT>
        <A HREF="http://example.com/">
    SAMPLE_BOOKMARK
    
    assert_equal [], bookmark.parents
  end
  
  def test_bookmark_can_have_single_parent
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
    <DL><p>
        <DT><H3>Folder</H3>
        <DL><p>
          <DT>
            <A HREF="http://example.com/">
    SAMPLE_BOOKMARK
    
    assert_equal ["Folder"], bookmark.parents
  end
  
  def test_bookmark_can_have_multiple_parents
    bookmark = parse_bookmark <<-SAMPLE_BOOKMARK
    <DL><p>
        <DT><H3>Folder 1</H3>
        <DL><p>
            <DT><H3>Folder 2</H3>
            <DL><p>
              <DT>
                <A HREF="http://example.com/">
    SAMPLE_BOOKMARK
    
    assert_equal ["Folder 1", "Folder 2"], bookmark.parents
  end
  
  def test_multiple_bookmarks_may_be_nested
    bookmarks = parse_bookmarks <<-SAMPLE_BOOKMARK, 4
    <DL><p>
        <DT><A HREF="http://example.com/">One</A>
        <DT><H3>Folder 1</H3>
        <DT><A HREF="http://example.com/">Two</A>
        <DL><p>
            <DT><H3>Folder 2</H3>
            <DL><p>
              <DT><A HREF="http://example.com/">Three</A>
            </DL>
            <DT><A HREF="http://example.com/">Four</A>
    SAMPLE_BOOKMARK
    
    b1, b2, b3, b4 = bookmarks
    
    assert_equal [], b1.parents
    assert_equal ["Folder 1"], b2.parents
    assert_equal ["Folder 1", "Folder 2"], b3.parents
    assert_equal ["Folder 1"], b4.parents
  end
  
  def test_parsing_a_chrome_export
    parser = fixture_parser("chrome.html")
    
    bookmarks = parser.bookmarks
    
    assert bookmarks.length > 0, "Should contain bookmarks"
    assert bookmarks.any? {|b| b.parents.length > 0 }, "Should contain folders"
  end
  
  def test_parsing_a_firefox_export
    parser = fixture_parser("firefox.html")
    
    bookmarks = parser.bookmarks
    
    assert bookmarks.length > 0, "Should contain bookmarks"
    assert bookmarks.any? {|b| b.parents.length > 0 }, "Should contain folders"
  end
  
  def test_parsing_a_delicious_export
    parser = fixture_parser("delicious.html")
    
    bookmarks = parser.bookmarks
    
    assert bookmarks.length > 0, "Should contain bookmarks"
    assert bookmarks.all? {|b| b.parents.length == 0 }, "Should not contain folders"
    assert bookmarks.any? {|b| b.tags.length > 0 }, "Should contain tagged bookmarks"
  end
  
  private
  
  def parse_bookmarks(str, count=nil)
    bookmarks = NetscapeParser.new(str).bookmarks
    if count
      assert_equal count, bookmarks.length, "Expected #{count} bookmarks from:\n#{str}\nGot:\n#{bookmarks.inspect}"
    end
    
    bookmarks
  end
  
  def parse_bookmark(str)
    bookmarks = parse_bookmarks(str, 1)
    bookmarks.first
  end
  
  def fixture_parser(path)
    NetscapeParser.new(fixture(path))
  end
end