//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/3.
 */
package kof.game.Tutorial.data {

import kof.game.Tutorial.enum.ETutorActionType;
import kof.table.TutorAction;
import kof.table.TutorTxt;


// TutorAction, 表数据
public class CTutorActionInfo extends CTutorInfoBase {
    public function CTutorActionInfo(tutorData:CTutorData, groupInfo:CTutorGroupInfo, actionRecord:TutorAction) {
        super (tutorData);

        _actionRecord = actionRecord;
        _groupInfo = groupInfo;
    }

    public override function dispose() : void {
        super.dispose();
        _actionRecord = null;
        _groupInfo = null;
    }

    public function isScenarioAction() : Boolean {
        return actionID == ETutorActionType.PLAY_SCENARIO;
    }

    [Inline]
    public function get ID() : int { return _actionRecord.ID; }
    [Inline]
    public function get actionID() : int { return _actionRecord.ActionID; }
    [Inline]
    public function get nextActionID() : int { return _actionRecord.NextTutorActionID; }
    [Inline]
    public function get actionParams() : Array { return _actionRecord.ActionParams; }
    [Inline]
    public function get uiType() : int { return _actionRecord.UiType; } // 目的提示种类 1-鼠标提示；2-小框提示；3-对话提示；
    [Inline]
    public function get maskHoleType() : int { return _actionRecord.MaskHoleType; } // 指引框1-方形； 2-圆形
    [Inline]
    public function get isRectHoleMask() : Boolean { return maskHoleType == 1; }
    public function get hasMask() : Boolean {


        // 有没有蒙板
        if (_actionRecord.IsUseMask == -1) {
            return _groupInfo.hasMask;
        } else if (_actionRecord.IsUseMask == 0) {
            return false;
        } else {
            return true;
        }
    }
    // 2 : 使用强制蒙板, 无视引导隐藏规则, 必显示蒙板, 慎用, 可能会引导卡死
    public function get isForceShowMask() : Boolean {
        return _actionRecord.IsUseMask == 2;
    }
    [Inline]
    public function get dialogOffsetX() : int {
        return _actionRecord.DialogOffsetX;
    }
    [Inline]
    public function get dialogOffsetY() : int {
        return _actionRecord.DialogOffsetY;
    }
    [Inline]
    public function get holeOffsetX() : int {
        return _actionRecord.HoleOffsetX;
    }
    [Inline]
    public function get holeOffsetY() : int {
        return _actionRecord.HoleOffsetY;
    }
    [Inline]
    public function get holeOffsetWidth() : int {
        return _actionRecord.HoleOffsetWidth;
    }
    [Inline]
    public function get holeOffsetHeight() : int {
        return _actionRecord.HoleOffsetHeight;
    }
    [Inline]
    public function get circleEffectOffsetX() : int {
        return _actionRecord.CircleEffectOffsetX;
    }
    [Inline]
    public function get circleEffectOffsetY() : int {
        return _actionRecord.CircleEffectOffsetY;
    }
    [Inline]
    public function get dialogTxt() : String {
        var txtID:String = _actionRecord.DialogTxtID;
        if (txtID != null && txtID.length > 0) {
            var txtRecord:TutorTxt = _tutorData.tutorTxtTable.findByPrimaryKey(txtID) as TutorTxt;
            if (txtRecord) {
                return txtRecord.Name;
            } else {
                return "";
            }
        }

        return "";
    }
    [Inline]
    public function get hasHole() : Boolean { return maskHoleType > 0; } // 有没有洞
    [Inline]
    public function get maskHoleTargetID() : String { return _actionRecord.MaskHoleTargetID; } // 洞所在对象ID
    public function get hasMaskHoleTarget() : Boolean {
        return maskHoleTargetID && maskHoleTargetID.length > 0;
    }
    [Inline]
    public function get audioName() : String { return _actionRecord.AudioName; } // 音频名称
    [Inline]
    public function get startEventID() : int { return _actionRecord.StartEventID; } // 开始动作时, 要执行的事件ID
    [Inline]
    public function get startEventParam() : Array { return _actionRecord.StartEventParam; } // 开始事件参数
    [Inline]
    public function get finishEventID() : int { return _actionRecord.FinishEventID; } // 动作完成时, 要执行的事件ID
    [Inline]
    public function get finishEventParam() : Array { return _actionRecord.FinishEventParam; } // 动作完成事件参数
    [Inline]
    public function get actionFinishCond() : int { return _actionRecord.ActionFinishCondID; } // 动作完成条件ID
    [Inline]
    public function get finishCondParam() : Array { return _actionRecord.FinishCondParam; } // 完成条件参数

    [Inline]
    public function get isBlock() : int { return _actionRecord.IsBlock; } // 0 : no, 1 : yes阻塞, default value may be 1
    [Inline]
    public function get isRemoveByFinish() : int { return _actionRecord.RemoveByFinish; } // 0 : 完成不删, 1 : 完成删, default value may be 1
    [Inline]
    public function get systemTag() : int { return _actionRecord.SystemTag; }
    [Inline]
    public function get desc() : int { return _actionRecord.Desc; }
    [Inline]
    public function get isSurrender() : Boolean { return _actionRecord.Surrender > 0; } // 是否废弃
    [Inline]
    public function get hasNext() : Boolean {
        return nextActionID > 0;
    }

    [Inline]
    public function get isAutoPass() : Boolean { return _actionRecord.IsAutoPass > 0; } // 是否自动完成
    [Inline]
    public function get autoPassTimeOut() : int { return _actionRecord.AutoPassTimeOut; } // 自动完成时间 ms
    [Inline]
    public function get autoPassBySpace() : Boolean { return _actionRecord.AutoPassBySpace > 0; } // 按空格跳过, 并非所有动作都技能, 目前只支持了1001与5003动作

    public function get rollbackCondID() : int {
        return _actionRecord.RollBackCond;
    }
    public function get rollBackCondParam() : String {
        return _actionRecord.RollBackParam;
    }
    public function get rollbackActionID() : int {
        return _actionRecord.RollBackActionID;
    }

    // 系统自动回调 - 不回滚与上面的回滚不同
    public function get isForceNotRollback() : Boolean {
        return _actionRecord.IsForceNotRollback > 0;
    }

    [Inline]
    public function get isStopAutoForward() : Boolean { return _actionRecord.StopAutoForward > 0; } // 停止向前滚动

    [Inline]
    public function get startDelay() : int { return _actionRecord.StartDelay; } // 开始延迟, 单位毫秒
    [Inline]
    public function get groupInfo() : CTutorGroupInfo {
        return _groupInfo;
    }
    private var _actionRecord:TutorAction;
    private var _groupInfo:CTutorGroupInfo;
}
}
