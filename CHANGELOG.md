# CHANGELOG

## 2.3.1 (2012-09-13)

* Wrapped a few operations in Redis multi/exec blocks to be consistent with the rest of the library.

## 2.3.0 (2012-08-29)

* Added `deny(from_id, to_id, scope = Amico.default_scope_key)` to remove a relationship that is pending between two IDs.

Again, thanks to [Skip Baney](https://github.com/twelvelabs) for the pull request with this functionality.

## 2.2.0 (2012-08-27)

* Added `clear(id, scope = Amico.default_scope_key)` method to clear all relationships (in either direction) stored for an individual.

Added the following methods for the blocked by relationship:

* `blocked_by?(id, blocked_by_id, scope = Amico.default_scope_key)`
* `blocked_by(id, page_options = default_paging_options, scope = Amico.default_scope_key)`
* `blocked_by_count(id, scope = Amico.default_scope_key)`
* `blocked_by_page_count(id, page_size = Amico.page_size, scope = Amico.default_scope_key)`

Added the following methods for the pending with relationship:

* `pending_with?(id, blocked_by_id, scope = Amico.default_scope_key)`
* `pending_with(id, page_options = default_paging_options, scope = Amico.default_scope_key)`
* `pending_with_count(id, scope = Amico.default_scope_key)`
* `pending_with_page_count(id, page_size = Amico.page_size, scope = Amico.default_scope_key)`

Thanks to [Skip Baney](https://github.com/twelvelabs) for all the work on this release.

## 2.1.0 (2012-08-20)

* Added `count(id, type, scope = Amico.default_scope_key)` and `page_count(id, type, page_size = Amico.page_size, scope = Amico.default_scope_key)` as convenience methods for retrieving the count or the page count for the various types of relationships.

## 2.0.1 (2012-03-14)

* Added `Amico.all(id, type, scope)` to retrieve all of the individuals for a given id, type (e.g. following) and scope. Thanks to @mettadore for the initial code and inspiration.
* Clarified parameters in following, followers, blocked, reciprocated, and pending calls.

## 2.0.0 (2012-02-28)

* Added `Amico.default_scope_key` and `scope` parameter to all of the methods to allow you to scope the calls to express relationships for different types of things

## 1.2.0 (2012-02-22)

* Added pending to relationships

## 1.1.0 (2012-01-13)

* Added blocking to relationships
* Added reciprocated to relationships

## 1.0.0 (2012-01-11)

* Initial release