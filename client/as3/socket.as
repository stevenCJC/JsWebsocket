// ActionScript Document
package 
{
	import flash.net.Socket;
	import flash.events.*;
	import flash.display.Sprite;
	import flash.errors.*;
	import flash.display.SimpleButton;
	public class Client extends Sprite
	{
		private var mysocket:Socket;
		private var host:String="localhost";
		private var port:int=8001;
		public function Client()
		{
			btn.addEventListener(MouseEvent.CLICK,SendData);
			mysocket=new Socket();
			mysocket.addEventListener(Event.CONNECT,OnConnect);
			mysocket.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			mysocket.addEventListener(ProgressEvent.SOCKET_DATA , receivedata);
			//mysocket.addEventListener(SecurityError
			mysocket.connect(host,port);
		}
		private function OnConnect(e:Event):void
		{
			trace("连接成功");
			mysocket.writeUTFBytes("Test successful2/n");
			mysocket.flush();//发送数据
		}
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			trace("连接失败");
		}
		private function receivedata(e:ProgressEvent):void
		{
			trace("收到的字节数"+mysocket.bytesAvailable);
			var msg:String;
			while (mysocket.bytesAvailable)
			{
				msg+=mysocket.readMultiByte(mysocket.bytesAvailable,"utf8");
				trace(msg);
			}
		}
		private function SendData(e:MouseEvent):void
		{
			trace("发送");
			mysocket.writeUTFBytes("i am flash/n");
			mysocket.flush();//发送数据
		}
	}
}