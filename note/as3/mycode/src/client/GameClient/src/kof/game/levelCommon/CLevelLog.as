/**
 * Created by auto on 2016/6/2.
 */
package kof.game.levelCommon {

    import QFLib.Foundation;
    import QFLib.Utils.HtmlUtil;

    public class CLevelLog {
    public static function Log(str:String) : void {
        if (CLevelConfig.IS_LOG) Foundation.Log.logMsg("________________________________" + str);
    }

    private static var s_debug_log:Array = new Array();
    public static function get debugLog() : Array {
        return s_debug_log;
    }
    public static function addDebugLog(s:String, isError:Boolean = false) : void {
        if (!(CLevelConfig.IS_LOG)) return ;
        if (isError) {
            Foundation.Log.logErrorMsg(s);
            s = HtmlUtil.getHtmlText(s, "#ff0000");
        }
        s_debug_log.push(s);
    }
    public static function flushDebugLog() : String {
        var ret:String = s_debug_log.join("\n");
        s_debug_log = new Array();
        return ret;
    }
    public static function reverseLog() : void {
        if (s_debug_log && s_debug_log.length > 1) {
            s_debug_log = s_debug_log.reverse();
        }
    }
}
}
