package 
{
	import flash.net.Socket;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.errors.*;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketErrorEvent;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	import mx.collections.ArrayCollection;

	public class JsWebsocket extends Sprite
	{
		private var websocket:WebSocket;

		private var pingCounter:uint = 0;
		private var pings:Object = {};

		[Bindable]
		private var dumbIncrementValue:int = 0;

		[Bindable]
		private var protocolList:ArrayCollection = new ArrayCollection([
		{
		label: "dumb-increment-protocol",
		value: "dumb-increment-protocol"
		},
		{
		label: "lws-mirror-protocol",
		value: "lws-mirror-protocol"
		},
		{
		label: "fraggle-protocol",
		value: "fraggle-protocol"
		}
		]);

		private var log:String = "";

		private function handleCreationComplete():void
		{
			websocket = new WebSocket("ws://localhost","*");
			loadSettings();
			var scrollToBottomTimer:Number = NaN;
			WebSocket.logger = function(text:String):void {
			trace(text);
			log += (text + "\n");
			logOutput.text = log + "\n";
			if (isNaN(scrollToBottomTimer)) {
			scrollToBottomTimer = setTimeout(function():void {
			logOutput.scroller.verticalScrollBar.value = logOutput.scroller.verticalScrollBar.maximum;
			scrollToBottomTimer = NaN;
			}, 10);
			}
			};
		}

		private function handleWindowClosing(event:Event):void
		{
			if (websocket.connected)
			{
				websocket.close();
			}
		}

		private function loadSettings():void
		{
			var sharedObject:SharedObject = SharedObject.getLocal('settings');
			urlField.text = sharedObject.data.url || 'ws://localhost:7681';
			if ('subprotocol' in sharedObject.data)
			{
				protocolSelector.selectedItem = null;
				protocolSelector.textInput.text = sharedObject.data.subprotocol;
			}
		}

		private function saveSettings():void
		{
			var sharedObject:SharedObject = SharedObject.getLocal('settings');
			sharedObject.data.url = urlField.text;
			sharedObject.data.subprotocol = protocolSelector.selectedIndex < 0 ? protocolSelector.textInput.text:protocolSelector.selectedItem['value'];
			sharedObject.flush();
		}

		private function openConnection():void
		{
			saveSettings();
			connectButton.enabled = false;
			var subprotocol:String = protocolSelector.selectedIndex < 0 ? protocolSelector.textInput.text:protocolSelector.selectedItem['value'];
			websocket = new WebSocket(urlField.text,"*",subprotocol,5000);
			websocket.debug = true;
			websocket.connect();
			websocket.addEventListener(WebSocketEvent.CLOSED, handleWebSocketClosed);
			websocket.addEventListener(WebSocketEvent.OPEN, handleWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, handleWebSocketMessage);
			websocket.addEventListener(WebSocketEvent.PONG, handlePong);
			websocket.addEventListener(IOErrorEvent.IO_ERROR, handleIOError);
			websocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleSecurityError);
			websocket.addEventListener(WebSocketErrorEvent.CONNECTION_FAIL, handleConnectionFail);
		}

		private function handleIOError(event:IOErrorEvent):void
		{
			connectButton.enabled = true;
			disconnectButton.enabled = false;
			pingButton.enabled = false;
		}

		private function handleSecurityError(event:SecurityErrorEvent):void
		{
			connectButton.enabled = true;
			disconnectButton.enabled = false;
			pingButton.enabled = false;
		}

		private function handleConnectionFail(event:WebSocketErrorEvent):void
		{
			WebSocket.logger("Connection Failure: " + event.text);
		}

		private function handleWebSocketClosed(event:WebSocketEvent):void
		{
			WebSocket.logger("Websocket closed.");
			disconnectButton.enabled = false;
			pingButton.enabled = false;
			connectButton.enabled = true;
			if (websocket.protocol === 'lws-mirror-protocol')
			{
				drawCanvas.graphics.clear();
			}
		}

		private function handleWebSocketOpen(event:WebSocketEvent):void
		{
			WebSocket.logger("Websocket Connected");
			disconnectButton.enabled = true;
			pingButton.enabled = true;
		}

		private function handleWebSocketMessage(event:WebSocketEvent):void
		{
			if (event.message.type === WebSocketMessage.TYPE_UTF8)
			{
				if (websocket.protocol === 'lws-mirror-protocol')
				{
					var commands:Array = event.message.utf8Data.split(';');
					for each (var command:String in commands)
					{
						if (command.length < 1)
						{
							continue;
						}
						var fields:Array = command.split(' ');
						var commandName:String = fields[0];
						if (commandName === 'c' || commandName === 'd')
						{
							var color:uint = parseInt(String(fields[1]).slice(1),16);
							var startX:int = parseInt(fields[2],10);
							var startY:int = parseInt(fields[3],10);
							drawCanvas.graphics.lineStyle(1, color, 1, true, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER);
							if (commandName === 'c')
							{
								// c #7A9237 487 181 14;
								var radius:int = parseInt(fields[4],10);
								drawCanvas.graphics.drawCircle(startX, startY, radius);
							}
							else if (commandName === 'd')
							{
								var endX:int = parseInt(fields[4],10);
								var endY:int = parseInt(fields[5],10);
								drawCanvas.graphics.moveTo(startX, startY);
								drawCanvas.graphics.lineTo(endX, endY);
							}

						}
						else if (commandName === 'clear')
						{
							drawCanvas.graphics.clear();
						}
						else
						{
							WebSocket.logger("Unknown Command: '" + fields.join(' ') + "'");
						}
					}
				}
				else if (websocket.protocol === 'dumb-increment-protocol')
				{
					dumbIncrementValue = parseInt(event.message.utf8Data,10);
				}
				else
				{
					WebSocket.logger(event.message.utf8Data);
				}
			}
			else if (event.message.type === WebSocketMessage.TYPE_BINARY)
			{
				WebSocket.logger("Binary message received.  Length: " + event.message.binaryData.length);
			}
		}

		private var drawing:Boolean = false;
		private var startMouseX:Number;
		private var startMouseY:Number;

		private function handleMouseDown(event:MouseEvent):void
		{
			if (websocket && websocket.connected && websocket.protocol === 'lws-mirror-protocol')
			{
				drawing = true;
				startMouseX = drawCanvas.mouseX;
				startMouseY = drawCanvas.mouseY;
				stage.addEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			}
		}

		private function handleMouseUp(event:MouseEvent):void
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, handleMouseUp);
			drawing = false;
		}

		private function handleMouseMove(event:MouseEvent):void
		{
			if (drawing && websocket.connected && websocket.protocol === 'lws-mirror-protocol')
			{
				var sx:int = startMouseX;
				var sy:int = startMouseY;
				var ex:int = startMouseX = drawCanvas.mouseX;
				var ey:int = startMouseY = drawCanvas.mouseY;
				var color:uint = 0xDD00CC;
				websocket.sendUTF(['d', '#' + color.toString(16), sx, sy, ex, ey].join(' ') + ";");
			}
		}

		private function resetCounter():void
		{
			if (websocket.connected && websocket.protocol === 'dumb-increment-protocol')
			{
				websocket.sendUTF("reset\n");
			}
		}

		private function closeConnection():void
		{
			WebSocket.logger("Disconnecting.");
			websocket.close();
		}

		private function ping():void
		{
			var id:uint = pingCounter++;
			pings[id] = new Date();
			var payload:ByteArray = new ByteArray();
			payload.writeUnsignedInt(id);
			websocket.ping(payload);
		}

		private function handlePong(event:WebSocketEvent):void
		{
			if (event.frame.length === 4)
			{
				var id:uint = event.frame.binaryPayload.readUnsignedInt();
				var startTime:Date = pings[id];
				if (startTime)
				{
					var latency:uint = (new Date()).valueOf() - startTime.valueOf();
					WebSocket.logger("Ping latency " + latency + " ms");
					delete pings[id];
				}
			}
			else
			{
				WebSocket.logger("Unsolicited pong received");
			}
		}

		private function clearCanvas():void
		{
			if (websocket.connected && websocket.protocol === 'lws-mirror-protocol')
			{
				websocket.sendUTF('clear;');
			}
		}

		private function clearLog():void
		{
			log = "";
			logOutput.text = log;
		}
	}
}