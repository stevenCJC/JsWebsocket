var sio=require('../app/sio.js');
var cfg= global.config;

//在线状态的使用，与session配合
//单个用户多个socket的时候？ 某个请求可能会绑定某个

var sockets=global.sockets={byId:{},bySsid:{}};
module.exports={
	init:function(io){
		io.on('connection', function(socket){
			
			var coo=socket.handshake.headers.cookie;
			if(coo) coo=coo.split('PASSKEE_SSID=')[1];
			if(coo) sockets.bySsid[coo]=socket;
			
			sockets.byId[socket.id]=socket;
			//console.log(socket.handshake);
			if(global.config&&global.config.event&&global.config.event.onSocketConnect) 
				global.config.event.onSocketConnect(socket);
			
			socket.on('disconnect', function(){
				if(global.config&&global.config.event&&global.config.event.onSocketDisconnect) 
					global.config.event.onSocketDisconnect(socket);
			});
			
			if(sio)
				for(var x in sio)
					socket.on(x, function(data){
						sio[x](socket,data);
					});
		});

	},
	maker:function(){
		return function(req,res,next){
			if(req.cookies&&req.cookies.PASSKEE_SSID&&global.sockets.bySsid[req.cookies.PASSKEE_SSID]){
				req.socket=global.sockets.bySsid[req.cookies.PASSKEE_SSID];
			}else if(req.cookies&&req.cookies.io&&global.sockets.byId[req.cookies.io]){
				req.socket=global.sockets.byId[req.cookies.io];
				if(req.cookie&&req.cookies.PASSKEE_SSID&&!global.sockets.bySsid[req.cookies.PASSKEE_SSID]){
					global.sockets.bySsid[req.cookies.PASSKEE_SSID]=res.socket;
				}
			}
			next();
		}
	}
	
}