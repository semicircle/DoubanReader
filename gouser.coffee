delay = (ms) ->
  defered = Promise.pending();
  setTimeout ( ()->
    defered.fulfill()
  ), ms
  defered.promise


run = ->  
  # mongo.collections.


console.log process.argv
