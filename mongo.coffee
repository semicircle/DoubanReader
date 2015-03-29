mongojs = require('mongojs')

db = mongojs 'mongodb://127.0.0.1:27017/DoubanReader'

Promise.promisifyAll mongojs

addCollection = (colName) ->
  col = db.collection colName
  db.collections._all.push col
  col

db.collections =
  _all: []

__.assign db.collections,
  books: addCollection 'books'
  records: addCollection 'records'

Promise.settle [
  db.collections.records.ensureIndex { bookId: 1, userLink: 1}, { name: 'book_user', unique: true, background: true }
  db.collections.books.ensureIndex { link: 1 }, {name: 'book', unique: true, background: true}
#  db.collections.archiveRecords.ensureIndex { archive: 1 }, { name: 'archive', unique: true, background: true }
# db.collections.archiveRecords.ensureIndex { date: 1 }, { name: 'date', background: true }
# db.collections.archiveRecords.ensureIndex { type: 1 }, { name: 'type', background: true }

# db.collections.manualCategorization.ensureIndex { packageName: 1 }, { name: 'packageName', unique: true, background: true }

# db.collections.reports.events.ensureIndex { 'time.utc': 1 }, { name: 'utcTime', background: true }
# db.collections.reports.events.ensureIndex { 'user': 1 }, { name: 'user', background: true }
# db.collections.reports.events.ensureIndex { 'event': 1 }, { name: 'event', background: true }
# db.collections.reports.events.ensureIndex { 'appId': 1 }, { name: 'appId', background: true }
# db.collections.reports.events.ensureIndex { 'version': 1 }, { name: 'version', background: true }
# db.collections.reports.events.ensureIndex { 'target': 1 }, { name: 'target', background: true, sparse: true }

# db.collections.reports.status.ensureIndex { 'time.utc': 1 }, { name: 'utcTime', bakcground: true }

# db.collections.reports.performance.ensureIndex { 'time.utc': 1 }, { name: 'utcTime', background: true }
# db.collections.reports.feedback.ensureIndex { 'time.utc': 1 }, { name: 'utcTime', background: true }

# db.collections.reports.error.ensureIndex { 'time.utc': 1 }, { name: 'utcTime', background: true }

# db.collections.appInfos.ensureIndex { packageName: 1 }, { name: 'packageName', unique: true, background: true}
]
.then (results) ->
  results.forEach (result) ->
    logger.error('Error: Failed to create index: %o', result.reason()) if result.isRejected()

module.exports = db
