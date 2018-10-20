/**
 * Created by auto on 2016/5/19.
 */
package kof.game.level.event {

public class CSceneEvent extends CBaseEvent
{
    public static const TRUNK_UPDATE:String = "sceneTrunkUpdate";
    public static const TRUNK_COMPLETE:String = "sceneTrunkComplete";
    public static const TRUNK_PASSED:String = "sceneTrunkPassed";
    public static const TRUNK_RENDER_ENABLED_CHANGED:String = "sceneRenderEnabledChanged"; // 场景渲染开关事件 data is true 开启渲染，否则为停止渲染
    public static const TRUNK_REPEAT_UPDATE:String = "sceneTrunkRepeatUpdate";             // trunck重新锁住

    public static const ENTITY_INFO:String = "sceneEntityInfo";

    public static const MAIN_SCENE_CHANGE:String = "MAIN_SCENE_CHANGE";

    public static const SCENE_CHANGED:String = "sceneChangeEvent";

    public static const LEVEL_TRUNK_UPDATE_COM:String = "LEVEL_TRUNK_UPDATE_COM";

    public static const CHANGE_APPEAR_COMPLETE:String = "CHANGE_APPEAR_COMPLETE";

    public static const RECOVER_ZONE_ENV_INFO_COM:String = "RECOVER_ZONE_ENV_INFO_COM";

    // 场景缩放改变
    public static const SCENE_SCALE_CHANGED:String = "SCENE_SCALE_CHANGED";

    public function CSceneEvent(type:String, data:Object=null)
    {
        super(type, data);
    }
}
}