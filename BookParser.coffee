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

    mongo.collections.books.updateAsync { link: url }, { $set: { tags, score, readers }}

    console.log __.intersection(tags, @niceTags)
    return unless __.intersection(tags, @niceTags).length isnt 0


    # children section

    $links = $content.find('.knnlike a')
    
    if $links.length != 0
      promises = []
      $links.each (index, elem) ->
        
        link = $(this).attr('href')
        title = __.trim $(this).text()
        
        if title isnt ""
          
          p = mongo.collections.books.findAsync { link }
          .then (any) =>
            if any.length is 0 or any[0].level is null
              console.log "insert book #{title}"
              mongo.collections.books.updateAsync { link }, { link, title, level}, upsert: true
          promises.push p

      Promise.all promises
      console.log "url done: #{url}"
    else
      console.log "not new book found in #{url}"


module.exports = BookParser