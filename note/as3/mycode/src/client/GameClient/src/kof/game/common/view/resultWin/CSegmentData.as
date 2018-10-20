//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/9/29.
 */
package kof.game.common.view.resultWin {

import kof.data.CObjectData;

/**
 * 巅峰赛排位数据
 */
public class CSegmentData extends CObjectData {

    public static const _LEVEL_ID:String = "levelId";// 段位
    public static const _SUB_LEVEL_ID:String = "subLevelId";// 阶
    public static const _LEVEL_NAME:String = "levelName";// 段位名
    public static const _IS_SHOW_NAME:String = "isShowName"; // 是否显示段位名

    public function CSegmentData()
    {
        super();
    }

    public static function createObjectData(levelId:int, subLevelId:int, levelName:String, isShowName:Boolean) : Object {
        var obj:Object = new Object();
        obj[_LEVEL_ID] = levelId;
        obj[_SUB_LEVEL_ID] = subLevelId;
        obj[_LEVEL_NAME] = levelName;
        obj[_IS_SHOW_NAME] = isShowName;
        return obj;
    }

    public function get levelId() : int {return _data[_LEVEL_ID]}
    public function get subLevelId() : int {return _data[_SUB_LEVEL_ID]}
    public function get levelName() : String {return _data[_LEVEL_NAME]}
    public function get isShowName() : Boolean {return _data[_IS_SHOW_NAME]}
}
}
