var net  = require('net');
var clients = [];

var HOST = '192.168.16.81';
var PORT = 8087;

var ByteBuffer = require('ByteBuffer');


net.createServer(function(socket) {	

	console.log('Connected: ' + socket.remoteAddress +':'+ socket.remotePort);

	clients.push(socket);

	socket.on('data', function(data) {
		
		console.log('receive data：' + data.toString());
		
		if(data.toString().indexOf('policy-file-request')>-1){
			console.log('cross!');
			broadcast('<cross-domain-policy><allow-access-from domain="*" to-ports="*"/> </cross-domain-policy>\0', socket);
			console.log('/cross!');
		}
		
		
		
	});

	socket.on('end', function() {
		console.log('Close Connected: ' + socket);		
		clients.splice(clients.indexOf(socket));
	});

	function broadcast(message, sender) {
		clients.forEach(function(client) {
			if (client === sender) {
				client.write(message);
			}
		});
	}

}).listen(PORT, HOST);


console.log(PORT);