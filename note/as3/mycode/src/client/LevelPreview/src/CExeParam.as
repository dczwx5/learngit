/**
 * Created by auto on 2016/5/18.
 * 处理外部调用参数
 */
package {
import flash.display.Sprite;
import flash.events.Event;

public class CExeParam extends Sprite {
    public static var _instance:CExeParam;

    public function CExeParam(funParseCompleted:Function) {
        _instance = this;
        _funParseCompleted = funParseCompleted;

        if ( this.stage )
            _init();
        else
            addEventListener(Event.ADDED_TO_STAGE, _init);
    }

    private function  _init( event : Event = null ) : void {
        _sParam = this.loaderInfo.parameters;
        if (_sParam == null || _sParam.length == 0) {
            _sParam.push("fbname:3333"); //  other:abcd
        }

        _funParseCompleted();
    }

//    public function get params() : Array { return this._sParam; }
    public function get fbName() : String {
        return _getValueByKey("fbname");
    }
    public function get fbID() : uint {
        return (uint)(_getValueByKey("fbname"));
    }
    public function get isLog() : Boolean {
        return _getValueByKey("log").toLowerCase() == "true";
    }
    public function get heroId() : String {
        return (String)(_getValueByKey("heroId"));
    }
    public function get isLevelEditor():Boolean{
        return _getValueByKey("isLevelEditor") == "true";
    }

    // ==============================================================
    private function _onParse() : void {


    }

    private function _getValueByKey(key:String) : String {
        for each (var param:String in _sParam) {
            var splits:Array = param.split(":");
            var paramKey:String = splits[0];
            if (paramKey == key) {
                var paramValue:String = splits[1];
                return paramValue;
            }
        }

        return null;
    }

    private var _funParseCompleted:Function;
    private var _sParam:Object;
}
}
