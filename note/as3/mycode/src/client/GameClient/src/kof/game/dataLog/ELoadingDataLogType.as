//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/8.
 */
package kof.game.dataLog {

import kof.game.instance.enum.EInstanceType;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.table.InstanceContent;

public class ELoadingDataLogType {
    private static var _firstChapterData:CChapterData;
    private static var _firstChapterInstanceData:CChapterInstanceData;
    public static function getLoadingBefore(instanceData:CInstanceData, instanceContentRecord:InstanceContent) : int {
        var ret:int = _getLogIdByType(instanceData, instanceContentRecord, "_LOADING_BEFORE");
        return ret;
    }
    public static function getResultLoadingBefore(instanceData:CInstanceData, instanceContentRecord:InstanceContent) : int {
        var ret:int = _getLogIdByType(instanceData, instanceContentRecord, "_RESULT_LOADING_BEFORE");
        return ret;
    }
    public static function getResultLoadingEnd(instanceData:CInstanceData, instanceContentRecord:InstanceContent) : int {
        var ret:int = _getLogIdByType(instanceData, instanceContentRecord, "_RESULT_LOADING_END");
        return ret;
    }
    public static function getResultClickGetReward(instanceData:CInstanceData, instanceContentRecord:InstanceContent) : int {
        var ret:int = _getLogIdByType(instanceData, instanceContentRecord, "_CLICK_RESULT_GET_REWARD");
        return ret;
    }
    // 例 : _1_1_LOADING_BEFORE
    private static function _getLogIdByType(instanceData:CInstanceData, instanceContentRecord:InstanceContent, type:String) : int {
        var chapterIndex:int = _getChapterIndex(instanceData, instanceContentRecord);
        var instanceIndex:int = _getInstanceIndex(instanceData, instanceContentRecord);
        var ret:int = ELoadingDataLogType["_" + chapterIndex + "_" + instanceIndex + type];
        return ret;
    }
    private static function _getChapterIndex(instanceData:CInstanceData, instanceContentRecord:InstanceContent) : int {
        if (!_firstChapterData) {
            _firstChapterData = instanceData.getFirstChapterData(EInstanceType.TYPE_MAIN);
        }
        var firstChapterID:int = 1001;
        if (_firstChapterData) {
            firstChapterID = _firstChapterData.chapterID;
        }
        var chapterIndex:int = (instanceContentRecord.Chapter - firstChapterID) + 1;
        return chapterIndex;
    }
    private static function _getInstanceIndex(instanceData:CInstanceData, instanceContentRecord:InstanceContent) : int {
        if (!_firstChapterInstanceData) {
            _firstChapterInstanceData = instanceData.instanceList.getFirstInstance(EInstanceType.TYPE_MAIN);
        }
        var firstInstanceID:int = 10001;
        if (_firstChapterInstanceData) {
            firstInstanceID = _firstChapterInstanceData.instanceRecord.ID;
        }
        var instanceIndex:int = ((instanceContentRecord.ID - firstInstanceID) % 5) + 1;
        return instanceIndex;
    }

    public static function get firstChapterInstanceData() : CChapterInstanceData {
        return _firstChapterInstanceData;
    }
    public static function set firstChapterInstanceData(v:CChapterInstanceData) : void {
        _firstChapterInstanceData = v;
    }

    public static const _MAIN_CITY_LOADING_BEFORE:int = 10; // 主城loading前
    public static const _MAIN_CITY_LOADING_END:int = 20; // 主城loading完

    // 以下不是没用到. 只是动态使用了
    public static const _1_1_LOADING_BEFORE:int = 1000010; // 1-1loading前
    public static const _1_1_RESULT_LOADING_BEFORE:int = 1000011; // 	结算界面loading前
    public static const _1_1_RESULT_LOADING_END:int = 1000012; // 结算界面loading后
    public static const _1_1_CLICK_RESULT_GET_REWARD:int = 1000013; // 点击结算界面的领取奖励按钮

    public static const _1_2_LOADING_BEFORE:int = 1000020; // 1-1loading前
    public static const _1_2_RESULT_LOADING_BEFORE:int = 1000021; // 	结算界面loading前
    public static const _1_2_RESULT_LOADING_END:int = 1000022; // 结算界面loading后
    public static const _1_2_CLICK_RESULT_GET_REWARD:int = 1000023; // 点击结算界面的领取奖励按钮

    public static const _1_3_LOADING_BEFORE:int = 1000030; // 1-1loading前
    public static const _1_3_RESULT_LOADING_BEFORE:int = 1000031; // 	结算界面loading前
    public static const _1_3_RESULT_LOADING_END:int = 1000032; // 结算界面loading后
    public static const _1_3_CLICK_RESULT_GET_REWARD:int = 1000033; // 点击结算界面的领取奖励按钮

    public static const _1_4_LOADING_BEFORE:int = 1000040; // 1-1loading前
    public static const _1_4_RESULT_LOADING_BEFORE:int = 1000041; // 	结算界面loading前
    public static const _1_4_RESULT_LOADING_END:int = 1000042; // 结算界面loading后
    public static const _1_4_CLICK_RESULT_GET_REWARD:int = 1000043; // 点击结算界面的领取奖励按钮

    public static const _1_5_LOADING_BEFORE:int = 1000050; // 1-1loading前
    public static const _1_5_RESULT_LOADING_BEFORE:int = 1000051; // 	结算界面loading前
    public static const _1_5_RESULT_LOADING_END:int = 1000052; // 结算界面loading后
    public static const _1_5_CLICK_RESULT_GET_REWARD:int = 1000053; // 点击结算界面的领取奖励按钮

    public static const _2_1_LOADING_BEFORE:int = 2000010; // 1-1loading前
    public static const _2_1_RESULT_LOADING_BEFORE:int = 2000011; // 	结算界面loading前
    public static const _2_1_RESULT_LOADING_END:int = 2000012; // 结算界面loading后
    public static const _2_1_CLICK_RESULT_GET_REWARD:int = 2000013; // 点击结算界面的领取奖励按钮

    public static const _2_2_LOADING_BEFORE:int = 2000020; // 1-1loading前
    public static const _2_2_RESULT_LOADING_BEFORE:int = 2000021; // 	结算界面loading前
    public static const _2_2_RESULT_LOADING_END:int = 2000022; // 结算界面loading后
    public static const _2_2_CLICK_RESULT_GET_REWARD:int = 2000023; // 点击结算界面的领取奖励按钮

    public static const _2_3_LOADING_BEFORE:int = 2000030; // 1-1loading前
    public static const _2_3_RESULT_LOADING_BEFORE:int = 2000031; // 	结算界面loading前
    public static const _2_3_RESULT_LOADING_END:int = 2000032; // 结算界面loading后
    public static const _2_3_CLICK_RESULT_GET_REWARD:int = 2000033; // 点击结算界面的领取奖励按钮

    public static const _2_4_LOADING_BEFORE:int = 2000040; // 1-1loading前
    public static const _2_4_RESULT_LOADING_BEFORE:int = 2000041; // 	结算界面loading前
    public static const _2_4_RESULT_LOADING_END:int = 2000042; // 结算界面loading后
    public static const _2_4_CLICK_RESULT_GET_REWARD:int = 2000043; // 点击结算界面的领取奖励按钮

    public static const _2_5_LOADING_BEFORE:int = 2000050; // 1-1loading前
    public static const _2_5_RESULT_LOADING_BEFORE:int = 2000051; // 	结算界面loading前
    public static const _2_5_RESULT_LOADING_END:int = 2000052; // 结算界面loading后
    public static const _2_5_CLICK_RESULT_GET_REWARD:int = 2000053; // 点击结算界面的领取奖励按钮

    public static const _3_1_LOADING_BEFORE:int = 3000010; // 1-1loading前
    public static const _3_1_RESULT_LOADING_BEFORE:int = 3000011; // 	结算界面loading前
    public static const _3_1_RESULT_LOADING_END:int = 3000012; // 结算界面loading后
    public static const _3_1_CLICK_RESULT_GET_REWARD:int = 3000013; // 点击结算界面的领取奖励按钮

    public static const _3_2_LOADING_BEFORE:int = 3000020; // 1-1loading前
    public static const _3_2_RESULT_LOADING_BEFORE:int = 3000021; // 	结算界面loading前
    public static const _3_2_RESULT_LOADING_END:int = 3000022; // 结算界面loading后
    public static const _3_2_CLICK_RESULT_GET_REWARD:int = 3000023; // 点击结算界面的领取奖励按钮

    public static const _3_3_LOADING_BEFORE:int = 3000030; // 1-1loading前
    public static const _3_3_RESULT_LOADING_BEFORE:int = 3000031; // 	结算界面loading前
    public static const _3_3_RESULT_LOADING_END:int = 3000032; // 结算界面loading后
    public static const _3_3_CLICK_RESULT_GET_REWARD:int = 3000033; // 点击结算界面的领取奖励按钮

    public static const _3_4_LOADING_BEFORE:int = 3000040; // 1-1loading前
    public static const _3_4_RESULT_LOADING_BEFORE:int = 3000041; // 	结算界面loading前
    public static const _3_4_RESULT_LOADING_END:int = 3000042; // 结算界面loading后
    public static const _3_4_CLICK_RESULT_GET_REWARD:int = 3000043; // 点击结算界面的领取奖励按钮

    public static const _3_5_LOADING_BEFORE:int = 3000050; // 1-1loading前
    public static const _3_5_RESULT_LOADING_BEFORE:int = 3000051; // 	结算界面loading前
    public static const _3_5_RESULT_LOADING_END:int = 3000052; // 结算界面loading后
    public static const _3_5_CLICK_RESULT_GET_REWARD:int = 3000053; // 点击结算界面的领取奖励按钮
}
}
