package kof.util
{
/**
 * TextField的输入长度控制，以一个英文字母长度为单位
 * 其中一个中文长度 等于 2个英文字母长度
 *
 */
public class CTextFieldInputUtil
{
    /**
     *  该方法用于验证中文和字母混合的字符串的长度
     */
    public static function getTextCount(text:String):uint{
        var count:uint=0;
        var pattern:RegExp= /^[\u4E00-\u9FA5\uF900-\uFA2D]+$/  //验证中文
        var str:String;
        for(var i:int=0;i<text.length;i++){

            str=text.charAt(i);
            if(pattern.test(str)){
                //trace("中文")
                count+=2;
            }else{
                //trace("其他")
                count+=1;
            }
        }
        return count;
    }


    /**
     *  该方法用于验证中文和字母混合的字符串的长度，并返回指定长度的字符串
     */
    public static function getSubTextByLength(text:String,length:int):String{
        var count:uint=0;
        var pattern:RegExp= /^[\u4E00-\u9FA5\uF900-\uFA2D]+$/  //验证中文
        var index:int;
        var str:String;
        for(index = 0; index < text.length; index++){

            str=text.charAt(index);

            if(pattern.test(str)){
                //trace("中文")
                count+=2;
            }else{
                //trace("其他")
                count+=1;
            }
            if(count >= length) {
                if(count > length) {
                    index --;
                }
                break;
            }
        }
        return text.substring(0,index+1);
    }


}
}