A library to do naughty things with
[io-streams](https://hackage.haskell.org/package/io-streams).

It let's you:

-   convert `InputStream`s to lazy lists
-   build lazy lists by feeding an `OutputStream`
-   convert `InputStream ByteString`s to lazy `ByteStrings`

This can be handy when you are interfacing with other libraries that do
the right thing in the presence of lazy IO, but don't provide an
io-streams interface. Of course, the correct solution is to contribute
the io-streams interface.
