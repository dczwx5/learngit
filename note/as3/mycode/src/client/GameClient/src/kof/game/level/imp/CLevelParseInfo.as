/**
 * Created by auto on 2016/5/20.
 */
package kof.game.level.imp {
import kof.framework.CAbstractHandler;
import kof.game.levelCommon.Enum.EMapType;
import kof.game.levelCommon.info.CLevelConfigInfo;

public class CLevelParseInfo extends CAbstractHandler{
    public static function parseJsonData(data:Object) : CLevelConfigInfo {
        var levelData:Object = data;
        if (!levelData.hasOwnProperty("type")) {
            levelData["type"] = EMapType.INSTANCE;
        }

        if(!levelData.hasOwnProperty("originalPosition")) {
            levelData["originalPosition"] = new Object();
            levelData["originalPosition"]["x"] = 7.5;
            levelData["originalPosition"]["y"] = 4.5;
        }

        var levelCfgInfo:CLevelConfigInfo = new CLevelConfigInfo(levelData);

        return levelCfgInfo;
    }
}
}
