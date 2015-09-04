var _=require('underscore');
var crypto = require('crypto');
//持久化登录状态尚未支持

//var sessions=null;
function Sessions(options){
	//if(sessions) return sessions;
	//sessions=this;
	this.sessions={};
	
	this.options=_.extend({
		timespan:60000,
		timeout:15*60*1000,
	},options);
	var me=this;
	this.intervalClear();
	
}

Sessions.prototype={
	constructor:Sessions,
	maker:function(){
		var me=this;
		return function(req, res, next) {
			if(!req.cookies||!req.cookies.PASSKEE_SSID){
				var agent=req.headers['user-agent'];
				var sid = crypto.createHash('sha256').update(agent+Math.random()+(new Date).getTime()).digest('hex');
				sid = crypto.createHash('md5').update(sid+Math.random()+(new Date).getTime()).digest('hex');
				res.cookie('PASSKEE_SSID', sid);
				req.cookies=req.cookies||{};
				req.cookies.PASSKEE_SSID=sid;
			}
			var ss=me.get(req);
			if(ss) {
				req.session=ss;
				ss.refresh(me.options.timeout);
			}else
				req.session_start=function(){
					me.new(req,res);
				}
			next();
		}
	},
	new:function(req,res){
		if(!req.cookies||!req.cookies.PASSKEE_SSID||!this.sessions[req.cookies.PASSKEE_SSID]){
			req.session=this.sessions[req.cookies.PASSKEE_SSID]=new Session(req.cookies.PASSKEE_SSID,this.options.timeout);
			if(global.config&&global.config.event&&global.config.event.onSessionStart) 
				global.config.event.onSessionStart(this.sessions[req.cookies.PASSKEE_SSID]);
		}
	},
	destroy:function(req,res){
		if(arguments.length==2){
			if(req.cookies&&req.cookies.PASSKEE_SSID){
				if(global.config&&global.config.event&&global.config.event.onSessionDestroy) 
					global.config.event.onSessionDestroy(this.sessions[req.cookies.PASSKEE_SSID]);
				this.sessions[req.cookies.PASSKEE_SSID].destroy();
				delete this.sessions[req.cookies.PASSKEE_SSID];
				res.cookie('sid', null);
			}
		}else if(arguments.length==1&&req&&req.constructor==String){
			if(global.config&&global.config.event&&global.config.event.onSessionDestroy) 
				global.config.event.onSessionDestroy(this.sessions[req]);
			this.sessions[req].destroy();
			delete this.sessions[req];
		}
	},
	get:function(req){
		if(req.cookies&&req.cookies.PASSKEE_SSID&&this.sessions[req.cookies.PASSKEE_SSID])
			return this.sessions[req.cookies.PASSKEE_SSID];
	},
	intervalClear:function(){
		var me=this;
		setInterval(function(){
			for(var x in this.sessions) {
				if(this.sessions[x].deadline<=(new data()).getTime()) me.destroy(x);
			}
		},this.options.timespan);
	},
};


function Session(sid,timeout){
	this.id=sid;
	this.data={id:sid};
	this.refresh(timeout);
}

Session.prototype={
	constructor:Session,
	destroy:function(){
		this.data=null;
		this.deadline=null;
	},
	get:function(key){
		return this.data[key];
	},
	set:function(key,value){
		this.data[key] = value;
	},
	refresh:function(timeout){
		var d=new Date();
		this.deadline=d.getTime()+parseInt(timeout);
	},
	save:function(){
		//保存到
	},
	
};

















module.exports = Sessions;

