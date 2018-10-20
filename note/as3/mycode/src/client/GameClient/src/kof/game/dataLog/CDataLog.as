//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/8.
 */
package kof.game.dataLog {

import QFLib.Foundation.CMap;

import kof.framework.CAppSystem;
import kof.game.instance.CInstanceSystem;

import kof.game.instance.enum.EInstanceType;

import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.table.InstanceContent;

// 打点
public class CDataLog {


    public static function logLoadingData(system:CAppSystem, logID:int) : void {
//        ClientLog.log(logID);
//        trace("_________________________________logID : " + logID);
        (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).netHandler.logLoadingRequest(logID);
    }

    // ===============================主城
    public static function logMainCityLoadingBefore(system:CAppSystem, instanceData:CInstanceData, instanceContent:InstanceContent) : void {
        if (!EInstanceType.isMainCity(instanceContent.Type)) {
            return ;
        }
        var dataObject:* = needLogInstanceMap.find(ELoadingDataLogType._MAIN_CITY_LOADING_BEFORE);
        if (dataObject) {
            return ;
        }
        needLogInstanceMap.add(ELoadingDataLogType._MAIN_CITY_LOADING_BEFORE, true); // 一次过后不需要再记

        if (ELoadingDataLogType.firstChapterInstanceData == null) {
            ELoadingDataLogType.firstChapterInstanceData = instanceData.instanceList.getFirstInstance(EInstanceType.TYPE_MAIN);
        }
        var secondInstanceID:int = ELoadingDataLogType.firstChapterInstanceData.instanceRecord.ID + 1;
        var secondInstanceData:CChapterInstanceData = instanceData.instanceList.getByID(secondInstanceID);
        if (!secondInstanceData) { // 未有第二关的数据, 所以应该记
            logLoadingData(system, ELoadingDataLogType._MAIN_CITY_LOADING_BEFORE);
        } else {
            if (secondInstanceData.isCompleted == false) {
                logLoadingData(system, ELoadingDataLogType._MAIN_CITY_LOADING_BEFORE);
            }
        }
    }

    public static function logMainCityLoadingEnd(system:CAppSystem, instanceData:CInstanceData, instanceContent:InstanceContent) : void {
        if (!EInstanceType.isMainCity(instanceContent.Type)) {
            return ;
        }
        var dataObject:* = needLogInstanceMap.find(ELoadingDataLogType._MAIN_CITY_LOADING_END);
        if (dataObject) {
            return ;
        }
        needLogInstanceMap.add(ELoadingDataLogType._MAIN_CITY_LOADING_END, true); // 一次过后不需要再记

        if (ELoadingDataLogType.firstChapterInstanceData == null) {
            ELoadingDataLogType.firstChapterInstanceData = instanceData.instanceList.getFirstInstance(EInstanceType.TYPE_MAIN);
        }
        var secondInstanceID:int = ELoadingDataLogType.firstChapterInstanceData.instanceRecord.ID + 1;
        var secondInstanceData:CChapterInstanceData = instanceData.instanceList.getByID(secondInstanceID);
        if (!secondInstanceData) { // 未有第二关的数据, 所以应该记
            logLoadingData(system, ELoadingDataLogType._MAIN_CITY_LOADING_END);
        } else {
            if (secondInstanceData.isCompleted == false) {
                logLoadingData(system, ELoadingDataLogType._MAIN_CITY_LOADING_END);
            }
        }
    }

    // ===============================副本
    private static var _needLogInstanceMap:CMap;
    private static function get needLogInstanceMap() : CMap {
        if (!_needLogInstanceMap) {
            _needLogInstanceMap = new CMap();
        }
        return _needLogInstanceMap;
    }

    public static function logInstanceLoadingBefore(system:CAppSystem, instanceData:CInstanceData, instanceContent:InstanceContent) : void {
        if (instanceContent.Type != EInstanceType.TYPE_MAIN) {
            return ;
        }

        var chapterInstanceData:CChapterInstanceData = instanceData.instanceList.getByID(instanceContent.ID);
        if (!chapterInstanceData) {
            return ;
        }

        if (!chapterInstanceData.isCompleted) {
            var findObject:* = needLogInstanceMap.find(instanceContent.ID);
            if (!findObject) { // 中途退出
                var logID:int = ELoadingDataLogType.getLoadingBefore(instanceData, instanceContent);
                if (logID > 0) { // 只记录有ID的
                    needLogInstanceMap.add(instanceContent.ID, true);
                    logLoadingData(system, logID);
                }
            }
        }
    }
    public static function logInstanceResultLoadingBefore(system:CAppSystem, instanceData:CInstanceData, instanceContent:InstanceContent) : void {
        if (instanceContent.Type != EInstanceType.TYPE_MAIN) {
            return ;
        }

        // 进入副本时, 存入需要记录的副本ID。在其他操作中，如果当前ID已记录，则需要记日志
        if (needLogInstanceMap.find(instanceContent.ID)) {
            var logID:int = ELoadingDataLogType.getResultLoadingBefore(instanceData, instanceContent);
            logLoadingData(system, logID);
        }
    }
    public static function logInstanceResultLoadingEnd(system:CAppSystem, instanceData:CInstanceData, instanceContent:InstanceContent) : void {
        if (instanceContent.Type != EInstanceType.TYPE_MAIN) {
            return ;
        }
        if (needLogInstanceMap.find(instanceContent.ID)) {
            var logID:int = ELoadingDataLogType.getResultLoadingEnd(instanceData, instanceContent);
            logLoadingData(system, logID);
        }
    }
    public static function logInstanceResultClickGetReward(system:CAppSystem, instanceData:CInstanceData, instanceContent:InstanceContent) : void {
        if (instanceContent.Type != EInstanceType.TYPE_MAIN) {
            return ;
        }
        if (needLogInstanceMap.find(instanceContent.ID)) {
            needLogInstanceMap.remove(instanceContent.ID);
            var logID : int = ELoadingDataLogType.getResultClickGetReward( instanceData, instanceContent );
            logLoadingData(system, logID );
        }
    }
}
}
