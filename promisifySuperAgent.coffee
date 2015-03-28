module.exports = (request) ->
  Request = request.Request
  Request::end = Promise.promisify Request::end
  request
