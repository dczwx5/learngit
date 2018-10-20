//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/5/19.
 */
package kof.game.levelCommon {

import QFLib.Foundation.CPath;
import QFLib.Utils.PathUtil;

public class CLevelPath {
    public static var LEVEL_RES_PATH:String = "assets/level/";
    public static function getLevelResPath(uri:String):String {
        var url:String = LEVEL_RES_PATH + uri + ".json";
        return PathUtil.getVUrl(url);
    }
    public static function getLevelScenarioPath(uri:String):String {
        var url:String = "assets/level/level_scerario/" + uri + "_scenario.json";
        return PathUtil.getVUrl(url);
    }

    public static function getVideoPath(videoName:String) : String {
        var ext:String = videoName.substr(videoName.length-3, 3); // ext : swf/flv/f4v
        var url:String = "assets/video/" + ext + "/" + videoName;

        return PathUtil.getVUrl(url);
    }
    public static function getMusicPath(musicName:String) : String {
        var url:String = "assets/audio/music/" + musicName;
        if (musicName.indexOf(".mp3") == -1) url += ".mp3";
        return PathUtil.getVUrl(url);
    }
    public static function getAudioPath(audioName:String) : String {
        var url:String = "assets/audio/scene_sound/" + audioName + ".mp3";
        return PathUtil.getVUrl(url);
    }

    public static function getCharacterSkinPath(skin:String) : String {
        var fileName : String = new CPath( skin ).name;
        var url:String = "assets/character/" + skin + '/' + fileName + ".json";
        return PathUtil.getVUrl(url);
    }

    public static function getMissileSpinPath() : String {
        return "assets/character/missile/missile.json";
    }

    public static function getMissileSkinPath( skin : String ) : String {
        var fileName : String = new CPath( skin ).name;
        var url : String = "assets/character/missile/" + skin + "/" + fileName + ".json";
        return PathUtil.getVUrl( url );
    }
    public static function getCharacterOutSideSkinPath(skinName:String, outsideSkinName:String) : String {
        var subOutSideName:String = new CPath(outsideSkinName).name;
        var outSidePath:String = "assets/character/" + skinName + '/' + subOutSideName;
        return outSidePath;
    }
    public static function getCharacterWeaponSkinPath(skinName:String, weapon:String) : String {
        var weaponName:String = new CPath(weapon).name;
        var path:String = "assets/character/" + skinName + '/' + weaponName;
        return path;
    }
    public static function getImgPath(skin:String):String{
        var url:String = "assets/picture/" + skin;
        return PathUtil.getVUrl(url);
    }
}
}
