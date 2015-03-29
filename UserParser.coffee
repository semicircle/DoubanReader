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

class UserParser
  constructor: (@bookname) ->

  verifyUrl: (url) ->
    url.indexOf('collections') isnt -1

  startUrl: (url) ->
    return Promise.resolve() unless @verifyUrl(url)
    
    console.log 'startUrl', url

    request
    .get url
    .timeout 5000
    .set 'User-Agent': 'User-Agent Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/600.4.10 (KHTML, like Gecko) Version/8.0.4 Safari/600.4.10'
    .set 'Accept': 'Accept  text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    .set 'Cache-Control': 'max-age=0'
    .set 'Accept-Encoding': 'gzip, deflate, sdch'
    .set 'Accept-Language': 'en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4,zh-TW;q=0.2,ko;q=0.2'
    .set 'Cookie': 'bid="MdlTgs8CUpk";ll="108258"; _ga=GA1.2.1259268483.1422584998; dt=1; ue="semicircle21@gmail.com"; ct=y; ap=1; dbcl2="3985660:ccR6ic4PS78"; ck="_K6d"; _pk_ref.100001.8cb4=%5B%22%22%2C%22%22%2C1427540689%2C%22http%3A%2F%2Faccounts.douban.com%2Flogin%3Fuid%3D3985660%26alias%3Dsemicircle21%2540gmail.com%26redir%3Dhttp%253A%252F%252Fwww.douban.com%252F%26source%3Dindex_nav%26error%3D1027%22%5D; push_noty_num=0; push_doumail_num=0; _pk_id.100001.8cb4=53b4d80fe470472b.1422584967.143.1427541402.1427532739.; __utma=30149280.1259268483.1422584998.1427531232.1427539034.82; __utmc=30149280; __utmz=30149280.1427237474.71.9.utmcsr=douban.com|utmccn=(referral)|utmcmd=referral|utmcct=/; __utmv=30149280.398'
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
    bookname = @bookname
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
        data = {index, bookId, bookname, name, city, date, userLink}

        promises.push mongo.collections.records.updateAsync { userLink, bookId } , data, upsert: true

      Promise.all promises
      .then =>
        next = $('.next').first().children().first().attr('href')
        delay 1500
        .then =>
          @startUrl next if next? 

module.exports = UserParser

