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
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.character.property.CBasePropertyData;
import kof.table.ArtifactColour;
import kof.table.ArtifactConstant;
import kof.table.ArtifactSoulInfo;
import kof.table.ArtifactSoulQuality;
import kof.table.Item;

/**
 * 一个神灵的动态数据结构。用类来处理，方便改动
 *@author tim
 *@create 2018-05-25 10:49
 **/
public class CArtifactSoulData extends CObjectData {
    public function CArtifactSoulData() {
        super();
        _data = new CMap();
    }

    public function get artifactID() : int { return _data[_artifactID]; }
    public function get artifactSoulID() : int { return _data[_artifactSoulID]; }
    public function get isLock() : Boolean { return _data[_isLock]; }
    public function get newPropertyValue() : Array { return _data[_newPropertyValue]; }
    public function get newScaleValue() : Array { return _data[_newScaleValue]; }
    public function get openCondition() : int { return _data[_openCondition]; }
    public function get propertyValue() : Array { return _data[_propertyValue]; }
    public function get quality() : int { return _data[_quality]; }//0~6
    public function get scaleValue() : Array { return _data[_scaleValue]; }

    //是否正在显示突破成功的界面
    public var isShowBreachResult:Boolean;

    //返回是否有新洗炼出的属性，并且没保存
    public function get hasNewProperty():Boolean {
        return newPropertyValue != null;
    }

    override public function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
    }

    //获取神灵配置
    public function get soulCfg():ArtifactSoulInfo {
        var artifactSoulInfoTable: IDataTable = _databaseSystem.getTable( KOFTableConstants.ARTIFACTSOULINFO );
        var soulInfo: ArtifactSoulInfo = (artifactSoulInfoTable.findByPrimaryKey(artifactSoulID) as ArtifactSoulInfo);
        return soulInfo;
    }

    //获取颜色配置
    public function get colorCfg(): ArtifactColour {
        var colorTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTCOLOUR);
        var result:ArtifactColour = (colorTable.findByPrimaryKey(quality + 1) as ArtifactColour);
        return result;
    }

    //获取品质配置（突破相关）
    public function get qualityCfg(): ArtifactSoulQuality {
        var qualityTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTSOULQUALITY);
        var qualityArray : Array = qualityTable.findByProperty("soulID", artifactSoulID ) as Array;
        for each( var obj: ArtifactSoulQuality in qualityArray ) {
            if (obj.soulQuality == quality) {
                return obj;
            }
        }
        return null;
    }

    //获取下一级品质配置（突破相关）
    public function get nextQualityCfg(): ArtifactSoulQuality {
        var qualityTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.ARTIFACTSOULQUALITY);
        var qualityArray : Array = qualityTable.findByProperty("soulID", artifactSoulID ) as Array;
        for each( var obj: ArtifactSoulQuality in qualityArray ) {
            if (obj.soulQuality == quality + 1) {
                return obj;
            }
        }
        return null;
    }


    //返回突破需要的物品的配置
    public function get breackCostItemCfg(): Item {
        var itemTable:IDataTable = _databaseSystem.getTable(KOFTableConstants.ITEM);
        return itemTable.findByPrimaryKey(qualityCfg.breakItem) as Item;
    }

    //返回带品质颜色的神灵名
    public function get htmlName():String {
        return HtmlUtil.color(soulCfg.name, colorCfg.colour.replace("0x", "#"));
    }

    //返回当前神灵的战力。
    public function getFighting(useNewPropertyValue:Boolean) : int {
        var propertyValueArr:Array = propertyValue;
        var propertyData : CBasePropertyData = new CBasePropertyData();
        propertyData.databaseSystem = _databaseSystem;
        for ( var i : int = 0; i < 3; i++ ) {
            var attrName : String = propertyData.getAttrNameEN(soulCfg["propertyID" + (i + 1)]);
            if ( propertyData.hasOwnProperty( attrName ) ) {
                propertyData[attrName] = useNewPropertyValue ? propertyValueArr[i] + newPropertyValue[i] : propertyValueArr[i];
            }
        }
        return propertyData.getBattleValue();
    }

    //返回该神灵属性是否达到突破要求(注意，是否可突破还受神器品质限制，这里不判断这个限制)
    public function get isCanBreakByAttr():Boolean {
        if (scaleValue == null || scaleValue.length == 0) {
            return false;
        }
        var artifactConstantTable:IDataTable = (_databaseSystem.getTable(KOFTableConstants.ARTIFACTCONSTANT));
        var constantCfg:ArtifactConstant = artifactConstantTable.findByPrimaryKey(1) as ArtifactConstant;
        var soulBreakRate:int = constantCfg.soulBreakRate * 0.01;
        for (var i:int = 0; i < scaleValue.length; i++) {
            if (scaleValue[i] < soulBreakRate) {
                return false;
            }
        }
        return true;
    }

    //返回突破后的属性比例值，客户端自己算（不能用newScaleValue，因为这个值是突破成功后才发来的，这个函数是在突破前要用）
    //公式：
    // 神灵顶级属性上限  x (属性比例上限 - 属性比例下限） = 当前品质属性上限
    //（累积属性 -  神灵顶级属性上限* 属性比例下限）/当前品质属性上限 =  当前比例
    //注意，本类中的 propertyValue 字段存的是“累积属性”
    public function get scaleValueOfNextQuality():Array {
        var result:Array = [];
        var l_pNextQualityCfg:ArtifactSoulQuality = nextQualityCfg;//下一级的品质配置
        var topValue:int;//神灵顶级属性上限
        var currMaxValue:int;//当前品质属性上限
        var currValue:int;//==（累积属性 -  神灵顶级属性上限* 属性比例下限）
        for (var i:int = 0; i < propertyValue.length; i++) {
            topValue = soulCfg["propertyValueMax" + (i + 1)];
            currMaxValue = Math.ceil(topValue * (l_pNextQualityCfg.propertyMaxRate - l_pNextQualityCfg.propertyMinRate) * 0.0001);
            currValue = propertyValue[i] - topValue * l_pNextQualityCfg.propertyMinRate * 0.0001;
            result[i] = Math.ceil((currValue / currMaxValue) * 100);
        }
        return result;
    }


    public static const _artifactID:String = "artifactID";
    public static const _artifactSoulID:String = "artifactSoulID";
    public static const _isLock:String = "isLock";
    public static const _newPropertyValue:String = "newPropertyValue";
    public static const _newScaleValue:String = "newScaleValue";
    public static const _openCondition:String = "openCondition";
    public static const _propertyValue:String = "propertyValue";
    public static const _quality:String = "quality";
    public static const _scaleValue:String = "scaleValue";
}
}
