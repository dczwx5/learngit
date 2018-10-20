//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/9/15.
 */
package kof.game.common.preLoad {

import kof.game.levelCommon.CLevelPath;

public class CPreloadSkinData {
    public var skinName:String;
    public function get skinPath() : String {
        if (skinName == null || skinName.length == 0) return null;
        var jsonUrl:String = CLevelPath.getCharacterSkinPath(skinName);
        return jsonUrl;
    }

    public var outSideSkin:String;
    public function get outSideSkinPath() : String {
        if (outSideSkin == null || skinName == null || outSideSkin.length == 0 || skinName.length == 0) return null;
        var outsidePath:String = CLevelPath.getCharacterOutSideSkinPath(skinName, outSideSkin);
        return outsidePath;
    }

    public var weapon:String;
    public function get weaponPath() : String {
        if (weapon == null || weapon.length == 0) return null;
        var path:String = CLevelPath.getCharacterWeaponSkinPath(skinName, weapon);
        return path;
    }
}
}
