//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package view {

import flash.geom.Point;

import kof.ui.master.BattleTutor.BTQTEUI;


public class CQTEViewHandler extends CBattleTutorViewHandlerBase {
    public function CQTEViewHandler() {
        super(BTQTEUI);
    }
    override public function get viewClass():Array {
        return [BTQTEUI];
    }
    public function get ui():BTQTEUI {
        return getUI() as BTQTEUI;
    }
    protected override function get additionalAssets() : Array {
        return ["frameclip_xszy.swf", "frameclip_zy.swf", "frameclip_uio.swf"]; // 加载战斗引导的其他资源
    }
    override public function dispose():void {
        super.dispose();
    }
    protected override function _onAdded() : void {
        super._onAdded();

        hideUIO();

        if (_baseSkillPos == null) {
            _baseSkillPos = new Point(ui.skill.x, ui.skill.y);
        }
    }
    public function showJChip() : Boolean
    {
        ui.j_clip.visible = true;
        ui.j_clip.play();
        return true;
    }
    public function showSpaceChip() : Boolean
    {
        ui.space_clip.visible = true;
        ui.space_clip.play();
        return true;
    }
    public function showUIOByIndex(index:int) : Boolean {
        if (index == 0) showUIO(true, false, false);
        if (index == 1) showUIO(false, true, false);
        if (index >= 2) showUIO(false, false, true);
        return true;
    }
    public function showUIO(isPlayU:Boolean, isPlayI:Boolean, isPlayO:Boolean) : Boolean {
        ui.u_clip.visible = ui.i_clip.visible = ui.o_clip.visible = true;
        if (isPlayU) {
            ui.u_clip.play();
        } else {
            ui.u_clip.gotoAndStop(0);
        }

        if (isPlayI) {
            ui.i_clip.play();
        } else {
            ui.i_clip.gotoAndStop(0);
        }

        if (isPlayO) {
            ui.o_clip.play();
        } else {
            ui.o_clip.gotoAndStop(0);
        }
        return true;
    }

    public function hideUIO() : void {
        ui.u_clip.visible = ui.i_clip.visible = ui.o_clip.visible = false;
        ui.j_clip.visible = ui.space_clip.visible = false;
        ui.u_clip.stop();
        ui.i_clip.stop();
        ui.o_clip.stop();
        ui.j_clip.stop();
        ui.space_clip.stop();
    }

    public var _baseSkillPos:Point;
    public var _flyEnd:Boolean;
}
}
