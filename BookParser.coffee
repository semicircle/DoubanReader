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

class BookParser
  constructor: ->

  startUrl: (url) ->
    return Promise.resolve() if url.indexOf('collections') is -1
    console.log 'startUrl', url
    request
    .get url
    .timeout 5000
    .set 'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36'
    .end()
    .then ((result) =>
      @parseResult(url, result)
    ), (err) =>
      console.log "Error on get '#{url}', try again"
      delay 5000
      .then =>
        @startUrl url

  parseResult: (url, result) ->
    console.log 'doc ready:', url
    html = result.res.text
    $ = cheerio.load html
  
    $content = $('#content')
    if $content.length == 0
      #TODO: handle retry
      console.log "read #{url} failed: $content.length is 0 , try again. "
      #console.log $content
      #console.log html
      delay 5000
      .then =>
        @startUrl url
      return
  
    $collectionsTab = $content.find('#collections_tab')
    $usersDiv = $collectionsTab.find('.pl2 a')
    if $usersDiv.length != 0
      promises = []
      $usersDiv.each (index, elem) ->
        userLink = $(this).attr('href')
        spans = $(this).find('span')
        name = spans.first().text()
        city = __.trim spans.last().text(), '()'
        date = __.trim $(this).parent().parent().find('.pl').children().first().text()
        bookId = url.split('/')[4]

        
        console.log index, bookId, name, city, date, userLink
        data = {index, bookId, name, city, date, userLink}

        promises.push mongo.collections.records.updateAsync { userLink, bookId } , data, upsert: true

      Promise.all promises
      .then =>
        next = $('.next').first().children().first().attr('href')
        delay 1500
        .then =>
          @startUrl next if next? 

module.exports = BookParser

