//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/8.
 */
package kof.util {

public class CQualityColor {
    /** 品质颜色 */
    public static const QUALITY_COLOR_ARY:Array = ["#f0ecec","#70e324","#43c8ff","#ea73ff","#f37911","#ffd940","#e8210d"];
    public static const QUALITY_COLOR_STROKE_ARY:Array = ["#2d2d2d","#183a05","#052940","#2a043c","#471b03","#613018","#471603"];

    public static function getColorByQuality( quality:int ):String {
        if(quality < 0)quality = 0;
        return QUALITY_COLOR_ARY[quality];
    }
}
}
