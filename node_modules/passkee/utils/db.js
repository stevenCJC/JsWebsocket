var $ = require("mongous").Mongous;
function DB(dbname,options){
	if(options) $().open(host,port);
	this.db=dbname;
}
DB.prototype.get=function(collectName){
	return $(this.db+'.'+collectName);
};

module.exports =function(dbname,options){
	return new DB(dbname,options);
};