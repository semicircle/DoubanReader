BookParser = require('./BookParser')

test = new BookParser()
test.startUrl('http://book.douban.com/subject/2969555/collections')
.then ->
  test.startUrl('http://book.douban.com/subject/6021440/collections')
.then ->
  console.log '[done]'