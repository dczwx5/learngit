/**
 * Created by auto on 2016/5/20.
 */
package kof.game.level.imp {
import QFLib.ResourceLoader.CJsonLoader;
import QFLib.ResourceLoader.CQsonLoader;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.ELoadingPriority;

import kof.framework.CAbstractHandler;
import kof.game.levelCommon.CLevelLog;
import kof.game.levelCommon.CLevelPath;

public class CLevelLoadFile extends CAbstractHandler {
    public function CLevelLoadFile() {
    }

    private static var _lastLevelReq:String;
    private static var _lastLevelScenarioReq:String;
    public static function loadFile(levelFileName:String, funLoadFinish:Function, isScenarioInstance:Boolean = false) : void {
        // GeneralResourceManager.cancel(_lastLevelReq, _onLoadCompleted);
        _lastLevelReq = CLevelPath.getLevelResPath(levelFileName);

        CResourceLoaders.instance().startLoadFile(_lastLevelReq, _onLoadCompleted, CQsonLoader.NAME);

        function _onLoadCompleted( loader : CJsonLoader, idErrorCode : int ) : void {

            if (idErrorCode != 0) {
                CLevelLog.addDebugLog("load level file error : " + levelFileName + ".json", true);
                return ;
            } else {
                var levelData:Object = loader.createObject();
                if( isScenarioInstance ){
                    //如果是剧情副本
                    _loadLevelScenarionFile(levelFileName, _onLoadLevelScenario); // 加载level关联的scenario文件

                    function _onLoadLevelScenario(scenarioData:Object) : void {
                        // 加载完剧情关联文件再到下一步
                        if (funLoadFinish) {
                            funLoadFinish(levelData, scenarioData);
                        }
                    };
                }else{
                    if (funLoadFinish) {
                        funLoadFinish(levelData, null);
                    }
                }
            }
        }
    }

    private static function _loadLevelScenarionFile(levelFileName:String, callback:Function) : void {
        _lastLevelScenarioReq = CLevelPath.getLevelScenarioPath(levelFileName);

        CResourceLoaders.instance().startLoadFile(_lastLevelScenarioReq, _onLoadCompleted, CJsonLoader.NAME, ELoadingPriority.NORMAL, true);

        function _onLoadCompleted(loader : CJsonLoader, idErrorCode : int) : void {
            if (idErrorCode != 0) {
                // error
                CLevelLog.addDebugLog("load level scenario file error : " + levelFileName + "_scenario.json", true);
                callback(null);
            } else {
                var data:Object = loader.createObject();
                callback(data);
            }
        };

    }

}
}
