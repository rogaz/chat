var puerto = 3001;
var io = require('socket.io').listen(puerto);
//sys = require('sys');
//var host = 'localhost';
//var amqp = require('amqp');
//var connection = amqp.createConnection({host: host});

io.sockets.on('connection', function (socket) {
	socket.on('create_line', function(msg){
		io.sockets.emit('make_line_to_'+msg.room, msg.data);
	});
	socket.on('destroy_line', function(msg){
		io.sockets.emit('destroy_line_to_'+msg.room_id, msg.line_id);
	});
	
});

/*
socket.on ('player move', function (msg) {
    io.sockets.emit ('updatePlayer', msg);
});

connection.on('ready', function(){
	var e = connection.queue('create_line_exchange', {type: 'direct'});
	connection.queue('create_line', function(queue){
		console.log("Queue " + queue.name + " is open.");
		queue.bind(queue, "");
		queue.subscribe(function (message, headers, deliveryInfo) {
  			console.log('Got a message with routing key ' + deliveryInfo.routingKey);
		});
	});
});
*/

/*
connection.on('ready', function(){
    connection.exchange('manage_lines', {type: 'direct', autoDelete: false}, function(exchange){
        connection.queue('tmp-' + Math.random(), {exclusive: true}, function(queue){
            queue.bind('create_message', '');
            //console.log(' [*] Waiting for logs. To exit press CTRL+C')
		io.sockets.on('connection', function (socket) {
            		queue.subscribe(function(msg){
            			io.sockets.emit('manage_lines', msg.data.toString('utf-8') );
			});
                //console.log(" [x] %s", msg.data.toString('utf-8'));
		});
            });
        })
    });
});
*/
/*
connection.on('ready', function(){
    connection.exchange('destroy_message', {type: 'fanout', autoDelete: false}, function(exchange){
        connection.queue('tmp-' + Math.random(), {exclusive: true}, function(queue){
            queue.bind('destroy_message', '');
            //console.log(' [*] Waiting for logs. To exit press CTRL+C')
						io.sockets.on('connection', function (socket) {
            	queue.subscribe(function(msg){
            		io.sockets.emit('destroy_message', msg.data.toString('utf-8') );
                //console.log(" [x] %s", msg.data.toString('utf-8'));
							});
            });
        })
    });
});
*/

