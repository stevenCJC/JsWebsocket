// ActionScript Document
package 
{ 
    import flash.display.Sprite; 
    import flash.external.ExternalInterface; 
     
    public class FlashCallJS extends Sprite 
    { 
        public function FlashCallJS() 
        { 
            //CuPlayer.com用CDATA特点直观的编写JS代码 
            var jsContent:String =    
                <>    
                <![CDATA[    
                    function test($str) {    
                        alert($str);    
                        return "JS result"; 
                    }    
                ]]>    
                </>; 
             
            //CuPlayer.com注册js代码 
            ExternalInterface.call("eval",jsContent); 
            //CuPlayer.com调用js方法并获取返回值 
            var result:String = ExternalInterface.call("test","Send from Flash"); 
            trace(result); 
        } 
    } 
} 