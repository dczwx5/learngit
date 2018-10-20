/**
 * Created by auto on 2016/5/20.
 */
package kof.game.scenario.imp {

import QFLib.ResourceLoader.CJsonLoader;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.ELoadingPriority;

import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.config.*;

import kof.framework.CAbstractHandler;

public class CScenarioLoadFile extends CAbstractHandler {
     private static var _lastScenarioReq:String;
     public static function loadFile(scenarioFileName:String, funLoadFinish:Function) : void {
        _lastScenarioReq = CScenarioPath.getScenarioResPath(scenarioFileName);
         CResourceLoaders.instance().startLoadFile(_lastScenarioReq, _onLoadCompleted, CJsonLoader.NAME, ELoadingPriority.CRITICAL);

        function _onLoadCompleted( loader : CJsonLoader, idErrorCode : int ) : void {

            if(idErrorCode != 0){
                CLevelLog.addDebugLog("[CScenarioLoadFile] load scenario file error : " + scenarioFileName + ".json", true);
                funLoadFinish({error:true});
            }else{
                var data:Object = loader.createObject();
                if (funLoadFinish) {
                    funLoadFinish(data);
                }
            }
        }

    }
}
}
