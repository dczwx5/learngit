//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Cliff on 2017/9/20.
 */
package QFLib.Utils {

public class Quality {

    //特效是否使用图集
    public static var useFxAtlas:Boolean = false;

    //软件模式或版本11.6、11.7是否使用1/4png图片
    public static var isLowQualityOfRender:Boolean = false;
    public static var knifeImageManualSwitch:Boolean = true;

    private static var _isSoftwareRender:Boolean = false;

    public static function set isSoftwareRender(value:Boolean):void
    {
        _isSoftwareRender = value;

        updateState();
    }

    private static function updateState():void
    {
        isLowQualityOfRender = _isSoftwareRender || CFlashVersion.isPlayerVersionPriorTo(11, 8);
    }
}
}
