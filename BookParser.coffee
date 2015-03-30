request = require('superagent')
require('./promisifySuperAgent')(request)
cheerio = require('cheerio')
util = require('util')

delay = (ms) ->
  defered = Promise.pending();
  setTimeout ( ()->
    defered.fulfill()
  ), ms
  defered.promise

class BookParser extends UserParser
  constructor: (@level, @niceTags) ->

  
  # http://book.douban.com/subject/1885170/
  verifyUrl: (url) ->
    url.indexOf('subject') isnt -1

  parseResult: (url, result) ->
    console.log 'doc ready:', url

    level = @level

    html = result.res.text
    $ = cheerio.load html

    $content = $('#content')

    if $content.length == 0
      console.log "read #{url} failed: try again"
      delay 5000
      .then =>
        @startUrl url
      return
    
    # self section
    $tags = $('#db-tags-section a')
    tags = []
    $tags.each (index, elem) ->
      tags.push __.trim $(this).text()
    score = __.trim $('.rating_num').text()
    
    $readers = $('#collector .pl a')
    readers = []
    $readers.each (index, elem) ->
      readers.push __.trim $(this).text()

    bookId = url.split('/')[4]
    mongo.collections.books.updateAsync { bookId }, { $set: { tags, score, readers }}

    console.log __.intersection(tags, @niceTags)
    return unless __.intersection(tags, @niceTags).length isnt 0

    # children section

    $links = $content.find('.knnlike a')
    
    if $links.length != 0
      promises = []
      $links.each (index, elem) ->
        
        link = $(this).attr('href')
        title = __.trim $(this).text()
        bookId = link.split('/')[4]
        
        if title isnt ""
          console.log "upsert book #{title}"
          promises.push mongo.collections.books.updateAsync { bookId }, { $set: {bookId, title}, $setOnInsert: { level }}, upsert: true

      Promise.all promises
      console.log "url done: #{url}"
    else
      console.log "not new book found in #{url}"


module.exports = BookParser