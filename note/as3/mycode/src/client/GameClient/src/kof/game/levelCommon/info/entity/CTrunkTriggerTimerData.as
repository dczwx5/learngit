/**
 * Created by auto on 2016/7/3.
 */
package kof.game.levelCommon.info.entity {
import kof.game.levelCommon.info.base.*;

/*
 * 定时触发器
 */
public class CTrunkTriggerTimerData extends CTrunkTriggerData {
    // public var interval:int; // : 触发器间隔, 单位秒
    //public var forward:Boolean; // 触发器触发模式, true : 立即执行一次, false : 间隔时间后执行第一次
    public var countType:int; // 计时类型, 0 : 正计时, 1倒计时, 只用于显示

    public var maxEnemyCnt:int; // 如果非0, 则当怪物数量小于maxEnemyCnt时, 才会触发触发器
    public var triggerNextImmediatelyWhenNoMonster:Boolean; //  : 当怪物全死亡时，立即执行触发器
    public function CTrunkTriggerTimerData(data:Object) {
        super (data);

        // interval = data["interval"];
        //forward = (data["forward"] == "True" || data["forward"] == "true")? true : false;
        countType = data["countType"];

        maxEnemyCnt = data["maxEnemyCnt"];
        triggerNextImmediatelyWhenNoMonster = (data["triggerNextImmediatelyWhenNoMonster"] ==
            "True" || data["triggerNextImmediatelyWhenNoMonster"] == "true")? true : false;
    }
}
}
