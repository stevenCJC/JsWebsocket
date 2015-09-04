
module.exports = {
	add:function(sio,data){
		console.log(data);
		sio.join(data.id);
		sio.broadcast.to(data.to).emit('news',data.msg);
	},
	
};




