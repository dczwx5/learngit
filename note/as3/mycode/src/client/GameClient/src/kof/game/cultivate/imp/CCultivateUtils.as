//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2018/4/27.
 */
package kof.game.cultivate.imp {

import kof.game.common.CLang;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.data.cultivate.CCultivateBuffData;
import kof.game.cultivate.data.cultivate.CCultivateBuffData;

import morn.core.components.Box;

import morn.core.components.Clip;
import morn.core.components.Image;
import morn.core.components.Label;

import morn.core.components.View;
import morn.core.utils.ObjectUtils;

public class CCultivateUtils {
    public static function buffViewRender(climpData:CClimpData, ui:View, showTips:Boolean) : void {
        var buffData:CCultivateBuffData = climpData.cultivateData.otherData.curBuffData;


        var buff_clip:Clip = ui["buff_clip"];
        var buff_img:Image = ui["buff_img"];
        var buff_box:Box = ui["buff_box"];

        var buff_name:Label;
        if (ui.hasOwnProperty("buff_name")) {
            buff_name = ui["buff_name"];
        }
        var buff_desc:Label;
        if (ui.hasOwnProperty("buff_desc")) {
            buff_desc = ui["buff_desc"];
        }

        var buff_whiteFrame:Image;
        if (ui.hasOwnProperty("buff_white_frame_img")) {
            buff_whiteFrame = ui["buff_white_frame_img"];
        }

        if (buffData && buffData.isDataValid()) {
            buff_clip.index = buffData.buffRecord.Appearance;

            buff_img.url = buffData.icon;
            var isBuffActive:Boolean = climpData.cultivateData.otherData.currBuffEffect > 0;
            ObjectUtils.gray(buff_box, !isBuffActive);

            var strActiveState:String;
            if (isBuffActive) {
                strActiveState = CLang.Get("common_actived");
            } else {
                strActiveState = CLang.Get("common_unActived");
            }

            if (showTips) {
                buff_img.toolTip = CLang.Get("cultivate_buff_tips", {v1:buffData.name, v2:strActiveState, v3:buffData.desc, v4:buffData.percent});
            }
            if (buff_name) buff_name.text = buffData.name;
            if (buff_desc) buff_desc.text = CLang.Get("cultivate_buff_desc", {v1:buffData.desc, v2:buffData.percent, v3:strActiveState});

            if (buff_whiteFrame) buff_whiteFrame.visible = true;

        } else {
            buff_clip.index = 0;
            buff_img.url = null;

            if ( buff_name ) buff_name.text = "";
            if ( buff_desc ) buff_desc.text = CLang.Get( "cultivate_no_buff_desc" );

            if (buff_whiteFrame) buff_whiteFrame.visible = false;
        }
    }
    public static function buffViewRenderSimple(buffData:CCultivateBuffData, ui:View) : void {

        var buff_clip:Clip = ui["buff_clip"];
        var buff_img:Image = ui["buff_img"];

        var buff_whiteFrame:Image;
        if (ui.hasOwnProperty("buff_white_frame_img")) {
            buff_whiteFrame = ui["buff_white_frame_img"];
        }

        if (buffData && buffData.isDataValid()) {
            buff_clip.index = buffData.buffRecord.Appearance;
            buff_img.url = buffData.icon;
            if (buff_whiteFrame) buff_whiteFrame.visible = true;
        }
    }
}
}
