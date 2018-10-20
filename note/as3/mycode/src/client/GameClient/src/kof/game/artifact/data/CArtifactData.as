//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact.data {

import QFLib.Foundation.CMap;
import QFLib.Utils.HtmlUtil;

import kof.data.CObjectData;
import kof.data.CObjectListData;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.character.property.CBasePropertyData;
import kof.table.ArtifactBasics;
import kof.table.ArtifactBreakthrough;
import kof.table.ArtifactColour;
import kof.table.ArtifactConstant;
import kof.table.ArtifactIntensify;
import kof.table.ArtifactQuality;
import kof.table.ArtifactSuit;

/**
 * 一个神器的动态数据结构。用类来处理，方便改动
 *@author tim
 *@create 2018-05-25 10:48
 **/
public class CArtifactData extends CObjectData {
    public function CArtifactData() {
        super();
        _data = new CMap();
        soulListData = new CObjectListData(CArtifactSoulData, CArtifactSoulData._artifactSoulID);
    }

    public function get artifactExp() : int { return _data[_artifactExp]; }
    public function get artifactID() : int { return _data[_artifactID]; }
    public function get artifactLevel() : int { return _data[_artifactLevel]; }
    private function get ArtifactSoulList() : Array {return _data[_ArtifactSoulList]; }
    public function get isLock() :Boolean { return _data[_isLock]; }
    public function get isopenConditionList() : Array { return _data[_isopenConditionList]; }//[0, 1]([解锁条件1是否达成，解条件2是否达成])，目前只受“解锁条件1（即战队等级）是否达成”影响
    public function get quality() : int { return _data[_quality]; }//对应“ArtifactQuality”表中的“ID”、值的范围是1~31

    override public function set databaseSystem(database:IDatabase) : void {
        super.databaseSystem = database;
        soulListData.databaseSystem = database;
    }

    public var soulListData:CObjectListData;//存放神灵列表
    //重写updateDataByData方法，一旦数据有更新，soulListData也需要更新
    override public function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
        if (ArtifactSoulList != null) {
            soulListData.updateDataByData(ArtifactSoulList);
        }
        this.extendsData = data;
    }

    //通过ID，获得该神器上某个神灵的动态数据
    public function getSoulDataById(soulId:int):CArtifactSoulData
    {
        return soulListData.getByPrimary(soulId) as CArtifactSoulData;
    }

    public function getIsSoulCanUnLock(soulId:int):Boolean {
        var soul:CArtifactSoulData = getSoulDataById(soulId);
        return soul.isLock && quality >= soul.soulCfg.unlockArtifactQuality;
    }

    public function get htmlNameWithNum():String {
        var result:String = baseCfg.artifactName + qualityCfg.qualityName;
        result = HtmlUtil.color(result, colorCfg.colour.replace("0x", "#"));
        return result;
    }

    public function get htmlName():String {
        var result:String = baseCfg.artifactName;
        result = HtmlUtil.color(result, colorCfg.colour.replace("0x", "#"));
        return result;
    }

    private var _m_pTempIntensifyCfg:ArtifactIntensify;
    //返回当前神器强化配置
    public function get intensifyCfg() : ArtifactIntensify {
        if (_m_pTempIntensifyCfg != null && _m_pTempIntensifyCfg.artifactLevel == artifactLevel && _m_pTempIntensifyCfg.artifactQuality == data.quality) {
            return _m_pTempIntensifyCfg;
        }
        var artifactTable : IDataTable = _databaseSystem.getTable( KOFTableConstants.ARTIFACT );
        var artifactArray : Array = artifactTable.findByProperty( "artifactID", artifactID ) as Array;
        for each( var obj : ArtifactIntensify in artifactArray ) {
            if (obj.artifactLevel == artifactLevel && obj.artifactQuality == data.quality ) {
                _m_pTempIntensifyCfg = obj;
                return obj;
            }
        }
        return null;
    }

    //返回下一级神器强化配置（如果已达顶级返回空）
    public function get nextIntensifyCfg() : ArtifactIntensify {
        if (isMaxQualityAndLevel) {
            return  null;
        }
        var artifactTable : IDataTable = _databaseSystem.getTable( KOFTableConstants.ARTIFACT );
        return artifactTable.findByPrimaryKey(intensifyCfg.ID + 1);
    }


    //返回神器的基础配置
    public function get baseCfg():ArtifactBasics {
        var artifactBasicsTable : IDataTable = _databaseSystem.getTable( KOFTableConstants.ARTIFACTBASICS );
        return artifactBasicsTable.findByPrimaryKey(artifactID ) as ArtifactBasics;
    }

    //返回神器的突破配置 a_iQuality: 1~31
    public function getBreakThroughCfg(a_iQuality:int = -1):ArtifactBreakthrough {
        a_iQuality = a_iQuality == -1 ? quality : a_iQuality;
        var breakTable : IDataTable = _databaseSystem.getTable( KOFTableConstants.ARTIFACTBREAKTHROUGH );
        var artifactArray : Array = breakTable.findByProperty( "artifactID", artifactID ) as Array;
        for each( var obj : ArtifactBreakthrough in artifactArray ) {
            if (obj.artifactQuality == a_iQuality) {
                return obj;
            }
        }
        return null;
    }

    //获取神器当前品质对应的颜色配置
    public function get colorCfg(): ArtifactColour {
        var colorTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTCOLOUR);
        var result:ArtifactColour = (colorTable.findByPrimaryKey(int(qualityCfg.qualityColour) + 1) as ArtifactColour);
        return result;
    }

    //返回神器的品质配置
    public function get qualityCfg():ArtifactQuality {
        var qualityTable : IDataTable = _databaseSystem.getTable( KOFTableConstants.ARTIFACTQUALITY );
        return qualityTable.findByPrimaryKey(quality) as ArtifactQuality;
    }


    //返回该神器的战力（不包含神灵）
    public function get fighting() : int {
        var propertyData : CBasePropertyData = new CBasePropertyData();
        propertyData.databaseSystem = _databaseSystem;
        for ( var i : int = 0; i < 3; i++ ) {
            var attrName : String = propertyData.getAttrNameEN(baseCfg.propertyID[ i ] );
            if ( propertyData.hasOwnProperty( attrName ) ) {
                propertyData[ attrName ] = intensifyCfg.propertyValue[ i ];
            }
        }
        return propertyData.getBattleValue();
    }

    //返回已激活的神灵战力总和
    public function get soulFighting(): int {
        var soul:CArtifactSoulData;
        var result:int;
        for (var i:int = 0; i < soulListData.list.length; i++) {
            soul = soulListData.list[i];
            if (!soul.isLock) {
                result += soul.getFighting(false);
            }
        }
        return result;
    }

    //返回当前神器是否可以解锁
    public function get isCanUnLock():Boolean {
        return isLock && isopenConditionList[0];
    }

    //是否达到指定品质(a_iQuality)下的最高等级
    public function isMaxLevel(a_iQuality:int = -1): Boolean {
        if (a_iQuality == -1) {
            a_iQuality = quality;
        }
        var breakCfg:ArtifactBreakthrough = getBreakThroughCfg(a_iQuality);
        return artifactLevel >= breakCfg.qualityMaxLevel;
    }

    //返回最高品质ID，即目前是31
    public function get maxQualityID():int {
        var qualityTable : IDataTable = _databaseSystem.getTable( KOFTableConstants.ARTIFACTQUALITY );
        var lastCfg:ArtifactQuality = qualityTable.last();
        return lastCfg.ID;
    }

    //是否达到最高品质、等级
    public function get isMaxQualityAndLevel():Boolean {
        return isMaxLevel(maxQualityID);
    }

    //返回指定套装ID下，满足条件的神灵数量
    public function getSuitActivateSoulCount(a_iSuitId:int = -1):int {
        a_iSuitId = a_iSuitId == -1 ? suitID : a_iSuitId;
        if (a_iSuitId <= 0) {
            a_iSuitId = firstSuitCfg.ID;
        }
        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTSUIT);
        var a_pSuitCfg:ArtifactSuit = (table.findByPrimaryKey(a_iSuitId) as ArtifactSuit);
        var result:int = 0;
        var soul:CArtifactSoulData;
        for (var i:int = 0; i < soulListData.list.length; i++) {
            soul = soulListData.list[i];
            if (soul.quality >= a_pSuitCfg.qualityID) {
                result++;
            }
        }
        return result;
    }

    //返回当前已激活的套装配置，如果一个没激活，返回空
    public function get suitCfg():ArtifactSuit {
        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTSUIT);
        var result:ArtifactSuit = (table.findByPrimaryKey(suitID) as ArtifactSuit);
        return result;
    }

    //返回一下级套装配置，如果当前已经套装达到顶级，返回空
    public function get nextSuitCfg():ArtifactSuit {
        if (suitCfg == null) {
            return firstSuitCfg;
        }
        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTSUIT);
        var result:ArtifactSuit = (table.findByPrimaryKey(suitID + 1) as ArtifactSuit);
        return (result == null || result.artifactID != firstSuitCfg.artifactID) ? null : result;
    }

    //返回该神器第一个套装的配置，必然存在
    public function get firstSuitCfg():ArtifactSuit {
        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTSUIT);
        var arr:Array = table.findByProperty("artifactID", artifactID);
        arr.sortOn("ID", Array.NUMERIC);
        var suitCfg:ArtifactSuit = arr[0];
        return suitCfg;
    }

    //当前生效的套装ID(本来是由服务器发，但有BUG，现由客户端算。代码可以再优化下，不用每次都算)
    public function get suitID() : int {
//        return artifactID == 1 ? 0 : Math.random() * 6 + 1;
        var table:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTSUIT);
        var soul:CArtifactSoulData;
        var minQuality:int = -1;
        for (var i:int = 0; i < soulListData.list.length; i++) {
            soul = soulListData.list[i];
            minQuality = minQuality == -1 ? soul.quality : Math.min(soul.quality, minQuality);
        }

        var a_pSuitCfg:ArtifactSuit;
        var arr:Array = table.findByProperty("artifactID", artifactID);
        for (var j:int = 0; j < arr.length; j++) {
            a_pSuitCfg = arr[j];
            if (a_pSuitCfg.qualityID == minQuality) { //a_pSuitCfg.qualityID:0~6
                return a_pSuitCfg.ID;
            }
        }
        return 0;
    }

    public function get constantCfg():ArtifactConstant {
        var artifactConstantTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTCONSTANT);
        var constant:ArtifactConstant = artifactConstantTable.findByPrimaryKey(1) as ArtifactConstant;
        return constant;
    }

    //返回该神器从当前经验升级，所消耗的神器能量数量
    public function get levelUpCostItemCount():int {
        var remainExp:int = intensifyCfg.upgradeLevelExp - artifactExp;
        var reaminTimes:int = Math.ceil(remainExp / constantCfg.upLevelExp);//最少还要强化多少次，才升级
        return reaminTimes * constantCfg.onceConsume;//次数*每次消耗=总消耗
    }

    //是否显示可突破的界面（真正可突破还受战队等级限制，这里没判断，要注意下）
    public function get isCanBreak():Boolean {
        return isMaxLevel() && !isMaxQualityAndLevel && artifactExp >= intensifyCfg.upgradeLevelExp;
    }

    //返回是否有一个神灵可以突破
    public function isAnySoulCanBreak():Boolean {
        var soul:CArtifactSoulData;
        for (var i:int = 0; i < soulListData.list.length; i++) {
            soul = soulListData.list[i];
            if (soul.isCanBreakByAttr && quality >= soul.qualityCfg.artifactQuality) {
                return true;
            }
        }
        return false;
    }

    public static const _artifactExp:String = "artifactExp";
    public static const _artifactID:String = "artifactID";
    public static const _artifactLevel:String = "artifactLevel";
    public static const _ArtifactSoulList:String = "ArtifactSoulList";
    public static const _isLock:String = "isLock";
    public static const _isopenConditionList:String = "isopenConditionList";
    public static const _quality:String = "quality";
    public static const _suitID:String = "suitID";
}
}
