require('coffee-script/register');

global.inspect = require('util').inspect;
global.__ = require('lodash');
global.Promise = require('bluebird');

global.mongo = require('./mongo');