/**
 * Created by auto on 2016/5/19.
 */
package kof.game.level.event {
public class CMapEvent extends CBaseEvent{

    public static const MAP_LAYER_CREATE_COMPLETE:String = "map_layer_create_complete";

    /**
     *准备切换地图
     */
    public static const CHANGE_MAP_PREPARE:String = "change_map_prepare";

    public static const CHANGE_MAP_SUCCESS:String = "change_map_success";

    public static const MAP_CLICK:String = "map_click";

    /**转场时加载界面、过场动画、回主城等全屏动画播放完毕后派发的事件*/
    public static const ALL_FULLSCREEN_FINISH:String = "all_fullscreen_finish";

    /** 转场加载界面开始淡出时 */
    public static const FULL_SCREEN_FADE_OUT_START:String = "fll_screen_fade_out_start";


    public function CMapEvent(type:String,tp:Object = null) {
        super(type, tp);
    }
}
}