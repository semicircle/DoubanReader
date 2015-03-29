require('coffee-script/register');

global.inspect = require('util').inspect;
global.__ = require('lodash');
global.Promise = require('bluebird');

global.mongo = require('./mongo');

global.UserParser = require('./UserParser')
global.BookParser = require('./BookParser')