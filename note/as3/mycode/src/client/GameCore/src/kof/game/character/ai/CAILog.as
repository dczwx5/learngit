//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/1/3.
 * Time: 17:00
 */
package kof.game.character.ai {

    import QFLib.Foundation.CLog;

    import flash.utils.Dictionary;

    import kof.game.character.property.interfaces.ICharacterProperty;

    public class CAILog {
        private static var m_pLog : CLog = null;
        private static var m_pIdNameDic : Dictionary = new Dictionary();
        public static var sIdTxt : String = "";
        public static var enabled : Boolean = true;
        public static var enabledFailLog : Boolean = false;

        public function CAILog( pLog : CLog ) {
            m_pLog = pLog;
        }

        public static function traceMsg( str : String, id : int ) : void {
            if ( sIdTxt == "" || int( sIdTxt ) != id || !enabled )return;
            m_pLog.logTraceMsg( str );
        }

        public static function logMsg( str : String, id : int ,tempEnable : Boolean = true ) : void {
            if ( sIdTxt == "" || int( sIdTxt ) != id || !enabled || !tempEnable )return;
            m_pLog.logMsg( str );
        }

        public static function warningMsg( str : String, id : int,tempEnable : Boolean = true ) : void {
            if ( sIdTxt == "" || int( sIdTxt ) != id || !enabled || !tempEnable )return;
            m_pLog.logWarningMsg( str );
        }

        public static function errorMsg( str : String, id : int ) : void {
            if ( sIdTxt == "" || int( sIdTxt ) != id || !enabled )return;
            m_pLog.logErrorMsg( str );
        }

        public static function gameObjInfo( property : ICharacterProperty, entityID : int, currentAIID : int ) : void {
            if ( m_pIdNameDic ) {
                m_pIdNameDic[ property.ID ] = "AIID:" + currentAIID + "  " + "entityID:" + entityID + "  " + "proID:" + property.prototypeID + "  " + "nick:" + property.nickName;
            }
        }

        public static function printObjID() : String {
            var str : String = "";
            for ( var key : int in m_pIdNameDic ) {
                str = str + "\n" + "ID:" + key + "   " + m_pIdNameDic[ key ];
            }
            return str;
        }

        public static function clear() : void {
            for ( var key : * in m_pIdNameDic ) {
                delete m_pIdNameDic[ key ];
                key = null;
            }
        }

        public static function logComboSkillInfo( msg : String ,id : int , skillSeq : int = 0, skillIndex : int =0 ,name : String ="",  tempEnable : Boolean = true ) : void{
            logMsg("[++" + skillSeq + "] --" + name +  "-- cast skill index :" + skillIndex + msg , id , tempEnable );
        }

        public static function logEnterInfo( type : String , id : int , msg : String , tempEnable : Boolean = true ) : void{
            logMsg("[^" + type+ "] " + msg ,  id , tempEnable );
        }

        public static function logEnterSubNodeInfo(type: String,  msg : String ,id : int , tempEnable : Boolean = true ) : void{
            logMsg("[^^" + type + "] " + msg , id , tempEnable );
        }

        public static function logExistUnSatisfyInfo(exitType : String ,  msg : String ,id : int , tempEnable : Boolean = true ) : void{
            warningMsg("[$!!" + exitType + "] " + msg , id , tempEnable );
        }

        public static function logExistInfo(exitType : String ,  msg : String ,id : int , tempEnable : Boolean = true ) : void{
            logMsg("[$" + exitType + "] " + msg , id , tempEnable );
        }

        /**AI调试信息常见符号
         * [!] warning and failed action or reminder
         * [^] enter and execute a new action
         * [^?] enter and execute a new condition
         * [++] combo skill executed
         * [$] exist an action
         * [$!!]条件不符合退出
         */
        /**用于临时调试*/
        public static function traceTemp(str:String):void{
//            trace(str);
        }

//        private static var _instance:CAILog=null;
//        public static function getInstance():CAILog{
//            if(!_instance){
//                _instance = new CAILog(null);
//            }
//            return _instance;
//        }
    }
}
