seeds = [
    title: '哥德尔、艾舍尔、巴赫'
    link: 'http://book.douban.com/subject/1291204/'
    level: 0
  ,
    title: '计算机程序设计艺术'
    link: 'http://book.douban.com/subject/1130500/'
    level: 0
  ,
    title: '计算机程序的构造和解释'
    link: 'http://book.douban.com/subject/1148282/'
    level: 0
  ,
    title: '算法导论'
    link: 'http://book.douban.com/subject/1885170/'
    level: 0
  ,
    title: '算法导论'
    link: 'http://book.douban.com/subject/20432061/'
    level: 0
  ,
    title: '代码大全'
    link: 'http://book.douban.com/subject/1477390/'
    level: 0
  ,
    title: '编程珠玑'
    link: 'http://book.douban.com/subject/1230206/'
    level: 0
  ,
    title: '重构'
    link: 'http://book.douban.com/subject/1229923/'
    level: 0
  ,
    title: '重构'
    link: 'http://book.douban.com/subject/4262627/'
    level: 0
  ,
    title: '编写可读代码的艺术'
    link: 'http://book.douban.com/subject/10797189/'
    level: 0
  ,
    title: '程序员修炼之道'
    link: 'http://book.douban.com/subject/1152111/'
    level: 0
  ,
    title: '程序员修炼之道'
    link: 'http://book.douban.com/subject/5387402/'
    level: 0
  ,
    title: '3D游戏编程大师技巧'
    link: 'http://book.douban.com/subject/1321769/'
    level: 0
  ,
    title: '游戏引擎架构'
    link: 'http://book.douban.com/subject/25815142/'
    level: 0
  ,
    title: '暗时间'
    link: 'http://book.douban.com/subject/6709809/'
    level: 0
  ,
    title: 'UNIX环境高级编程'
    link: 'http://book.douban.com/subject/1788421/'
    level: 0
  ,
    title: 'TCP/IP详解 卷1：协议'
    link: 'http://book.douban.com/subject/1088054/'
    level: 0
  ,
    title: 'CLR via C#'
    link: 'http://book.douban.com/subject/4924165/'
    level: 0
  ,
    title: 'COM本质论'
    link: 'http://book.douban.com/subject/1231481/'
    level: 0
  ,
    title: '程序员的呐喊'
    link: 'http://book.douban.com/subject/25884108/'
    level: 0
]

niceTags = [
  '计算机', '编程', '算法', '互联网', '设计', '心理学', '数学', '经典', '创业', '思维', '时间管理',
  '游戏开发', '游戏', '游戏编程', '游戏引擎', '计算机科学', '自我管理', '程序设计'
]

delay = (ms) ->
  defered = Promise.pending();
  setTimeout ( ()->
    defered.fulfill()
  ), ms
  defered.promise

showbook = (level=4) ->
  console.log 'showbook:', level
  mongo.collections.books.findAsync {level: {$lt: level}}
  .then (results) ->
    results.forEach (item) ->
      console.log item.level, item.title, item.score, item.readers
    console.log "total: #{results.length}"

expand = (level) ->
  mongo.collections.books.findAsync { level }
  .then (results) ->
    ps = []
    results.forEach (item, index) ->
      console.log 'expand', level, item.title, item.link
      ps.push (delay(index*1500)
      .then ->
        new BookParser(level + 1, niceTags).startUrl(item.link))
    Promise.all ps
  .then ->
    showbook(level - 1)
    console.log 'done'

seed = (level) ->
  promises = []
  seeds.forEach (item) ->
    console.log 'insert seed:', item
    promises.push mongo.collections.books.updateAsync {link: item.link}, item, upsert: true
  Promise.all promises
  .then ->
    console.log 'done'

clearbook = ->
  mongo.collections.books.drop()

showusage = ->
  console.log 'Usage: seed/parsebook/showbook/clearbook]'

parseuser = (level) ->
  mongo.collections.books.findAsync {level : {$lt: level}}
  .then (results) ->
    # ps = []
    # results.forEach (item, index) ->
    #   ps.push (delay(index*5000)
    #   .then ->
    #     new UserParser().startUrl(item.link+'collections'))
    # Promise.all ps
    
    next = (index) ->
      if index < results.length
        new UserParser().startUrl(results[index].link + 'collections')
        .then ->
          next(index + 1)
    next(0)

  .then ->
    console.log 'done'

showrecord = ->
  mongo.collections.record.findAsync()
  .then (results) ->
    results.forEach (item, index) ->
      console.log item.bookname, item.name

if process.argv.length < 3
  
else 
  cmd = process.argv[2]
  arg1 = process.argv[3]
  
  switch cmd
    when 'parsebook' then expand parseInt(arg1)
    when 'seed' then seed()
    when 'showbook' then showbook parseInt(arg1)
    when 'clearbook' then clearbook()
    when 'parseuser' then parseuser parseInt(arg1)
    when 'showrecord' then showrecord()
    else showusage()
