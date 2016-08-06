BookmarkMachine
===============

Parses Netscape bookmark files.  These are for better or worse the standard bookmark file format used by every browser.  This also happens to be roughly the file format that Delicious uses for liberating your bookmarks from their once adequate system.

Usage
-----

Pass `BookmarkMachine::NetscapeParser` a string, and ask it for bookmarks:

```
html = IO.read("bookmarks.html")
parser = BookmarkMachine::NetscapeParser.new(html)

bookmarks = parser.bookmarks
```

To format a collection of bookmarks, create `BookmarkMachine::NetscapeFormatter` with a collection of bookmarks:

```
bookmarks = [
  Bookmark.new("http://example.com", name: "Example")
]

formatter = BookmarkMachine::NetscapeFormatter.new(bookmarks)
html = formatter.to_s
```

BookmarkMachine represents bookmarks as an object containing:

* `url` - Bookmark's url
* `name` - Page's name, defaults to an empty string
* `created_at` - `Time` the bookmark was created
* `updated_at` - `Time` the bookmark was last updated
* `icon` - Either a data uri or url to an icon
* `folders` - An `Array` of the bookmark's parent folder names
* `tags` - An `Array` of tags (less common)
* `description` - An extended description of the bookmark

Any fields that aren't present will be `nil` unless otherwise noted.

Warning 
-------

Honestly there are alternatives like [markio](https://github.com/spajus/markio) that are probably better. About half of this project was an exercise in doing some TDD.  That said, it does support outputting nested folders if that's important to you.

TODO
----

It might be fun (in the questionable sense) to support other linked formats including Atom feeds and so forth.

Contact
-------
Adam Sanderson, netghost@gmail.com | http://monkeyandcrow.com
