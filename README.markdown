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

BookmarkMachine represents bookmarks as an object containing:

* `url` - Bookmark's url
* `name` - Page's name
* `created_at` - `Time` the bookmark was created
* `updated_at` - `Time` the bookmark was last updated
* `icon` - Either a data uri or url to an icon
* `parents` - An `Array` of the bookmark's parent folders
* `tags` - An `Array` of tags (less common)
* `description` - An extended description of the bookmark

Any fields that aren't present will be nil (as opposed to empty objects).

Warning 
-------

Honestly there are alternatives like [markio](https://github.com/spajus/markio) that are probably better. About half of this project was an exercise in doing some TDD.

Currently BookmarkMachine doesn't support writing, but it's certainly the next step.

Contact
-------
Adam Sanderson, netghost@gmail.com | http://monkeyandcrow.com
