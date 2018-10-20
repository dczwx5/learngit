//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/29.
 */
package tutor.actionPackage {

import action.CActionBase;
import action.CActionCommon;
import action.EKeyCode;

import com.greensock.TweenLite;

import flash.geom.Point;
import kof.ui.demo.FightUI;
import kof.util.CAssertUtils;

import morn.core.components.Component;
import morn.core.handlers.Handler;

import view.CQTEViewHandler;
import view.CViewRenderUtil;

public class CFlyUIPackage extends CActionPackageBase {
    public function CFlyUIPackage() {

    }

    public override function buildAction():CActionBase {
        CAssertUtils.assertNotNull(keyList);

        var battleTutor:CBattleTutor = tutorBase.battleTutor;
        var qteView:CQTEViewHandler = tutorBase.battleTutor.viewHelper.qteView;
        var qteAction:CActionCommon = new CActionCommon();

        var flyToUI:Function = function ():Boolean {
            qteView.ui.skill.visible = true;
            qteView._flyEnd = false;
            qteView.ui.skill.setPosition(qteView._baseSkillPos.x, qteView._baseSkillPos.y);
            var tarPos:Point = new Point(qteView.ui.skill.x, qteView.ui.skill.y);


            var flyKey:String = keyList[flyCount];
            CViewRenderUtil.renderSkillItem(tutorBase.battleTutor.system, flyKey, tutorBase.battleTutor.actorHelper.getSkillIDByKey(flyKey), qteView.ui.skill);
            var findCell:Component = battleTutor.viewHelper.getFightUiSkillItemByKey(flyKey);
            if (findCell) {
                tarPos.setTo(findCell.x, findCell.y);
                tarPos = findCell.parent.localToGlobal(tarPos);
                tarPos = qteView.ui.globalToLocal(tarPos);
            }

            TweenLite.to(qteView.ui.skill, 0.2, {
                x:tarPos.x, y:tarPos.y, onComplete:function ():void {
                    flyCount++;
                    qteView._flyEnd = true;
                }
            });
            return true;
        };
        var isFlyEnd:Function = function ():Boolean {
            return qteView._flyEnd;
        };

        var playLightEffect:Function = function ():Boolean {
            qteView.ui.light.visible = true;
            qteView.ui.light.playFromTo();
            return true;
        };
        var isLightEffectPlayEnd:Function = function ():Boolean {
            return qteView.ui.light.isPlaying == false;
        };
        // ===========================================================================================
        qteAction.addPassHandler(new Handler(playLightEffect));
        qteAction.addPassHandler(new Handler(isLightEffectPlayEnd));
        qteAction.addPassHandler(new Handler(battleTutor.instanceProcess.removeVaildKeyList, [getKeyCodeList()]));

        for (var i:int = 0; i < keyList.length; i++) {
            qteAction.addPassHandler(new Handler(flyToUI));
            qteAction.addPassHandler(new Handler(isFlyEnd));

            if (i == 0) {
                qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep1]));
                qteAction.addPassHandler(new Handler(battleTutor.instanceProcess.addVaildKey, [EKeyCode.getKeyCodeByKey(key1)]));
            } else if (i == 1) {
                qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep2]));
                qteAction.addPassHandler(new Handler(battleTutor.instanceProcess.addVaildKey, [EKeyCode.getKeyCodeByKey(key2)]));
            } else if (i == 2) {
                qteAction.addPassHandler(new Handler(battleTutor.instanceHelper.uploadData, [_uploadGuideStep3]));
                qteAction.addPassHandler(new Handler(battleTutor.instanceProcess.addVaildKey, [EKeyCode.getKeyCodeByKey(key3)]));
            }
            qteAction.addPassHandler(new Handler(battleTutor.instanceProcess.updateView));
            qteAction.addPassHandler(new Handler(battleTutor.viewHelper.showFightUI));

        }

        qteAction.addPassHandler(new Handler(battleTutor.instanceProcess.addVaildKeyList, [getKeyCodeList()]));
        qteAction.addFinishHandler(new Handler(battleTutor.instanceProcess.updateView));
        if (!forcePressKey) {
            qteAction.addFinishHandler(new Handler(battleTutor.actorHelper.setPlayerControlValueByMark));
        }

        return qteAction;
    }
}
}
