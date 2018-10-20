/**
 * Created by auto on 2016/5/19.
 */
package kof.game.scenario.config {
import QFLib.Utils.PathUtil;

public class CScenarioPath {
    public static function getScenarioResPath(uri:String):String {
        var url:String = "assets/scenario/" + uri + ".json";
        return PathUtil.getVUrl(url);
    }

}
}
