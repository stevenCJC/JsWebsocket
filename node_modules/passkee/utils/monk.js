
var db=global.config.mongodb;

module.exports= require('monk')(db.host+':'+db.port+'/'+db.dbname);



