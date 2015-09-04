require('passkee').init(__dirname+'/config/config.js');
//require('passkee').make();

/*var redis = require('redis');  
var client = redis.createClient(6379);  
  
client.set('key', 'val', function(err, reply) {  
    if (err) {  
        console.log(err);   
        return;  
    }     
    client.get('key', function(err, reply) {  
        if (err) {  
            console.log(err);  
            return;  
        }     
        console.log(reply);  
        client.quit();  
    });   
});  */