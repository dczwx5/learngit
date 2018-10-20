//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/10.
 */
package kof.game.instance.config {

import QFLib.Utils.PathUtil;

public class CInstancePath {
    public static function getInstanceExtraNodeIcon(icon:String) : String {
        var url:String = "icon/role/ui/instance_icon_f/" + icon + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getInstanceNodeIcon(icon:String) : String {
        // big_104
        var url:String = "icon/role/ui/instance_icon/" + icon + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getInstanceBGIcon(tipsIcon:String) : String {
        // var url:String = "icon/instance/" + "big_" + instanceID + ".jpg";
        var url:String = "icon/role/big/" + tipsIcon + ".png";
        return PathUtil.getVUrl(url);
    }

    public static function getNPCSmallIcon(tipsIcon:String) : String {
        // var url:String = "icon/instance/" + "big_" + instanceID + ".jpg";
        var url:String = "icon/role/npc/" + tipsIcon + ".png";
        return PathUtil.getVUrl(url);
    }
    public static function getAudioPath(audioName:String) : String {
        var url:String = "assets/audio/pve_result/" + audioName;
        return PathUtil.getVUrl(url);
    }

    public static const PVE_RESULT_STAR_AUDIO_NAME:String = "star.mp3";
    public static const PVE_RESULT_ROLE_AUDIO_NAME:String = "role.mp3";
    public static const PVE_RESULT_BG_AUDIO_NAME:String = "bg.mp3";
    public static const PVE_RESULT_ITEM_AUDIO_NAME:String = "getItem.mp3";

}
}
