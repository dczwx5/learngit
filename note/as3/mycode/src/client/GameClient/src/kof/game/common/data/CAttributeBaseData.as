//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/8/17.
 */
package kof.game.common.data {

import kof.data.CObjectData;

public class CAttributeBaseData extends CObjectData {

    /** 属性名字间距 */
    public static const NameSpace_No:int = 1;
    public static const NameSpace_Small:int = 2;
    public static const NameSpace_Big:int = 3;

    public static const Percent_hundred:int = 1;// 百分值类型
    public static const Percent_tenThousand:int = 2;// 万分值类型

    /** 属性类型 */
    private var _attrType:int;
    /** 属性英文名 */
    private var _attrNameEN:String;
    /** 属性中文名 */
    private var _attrNameCN:String;
    /** 无任何加成的基础属性值 */
    private var _attrBaseValue:int;
    /** 各种加成之后的属性值 */
    private var _attrTotalValue:int;
    /** 万分/百分值 */
    private var _attrPercent:int;
    /** 作类别区分用 */
    private var _type:int;

    public function CAttributeBaseData()
    {
    }

    /**
     * 计算单条属性战力
     */
    public function get combat():Number
    {
//        return CombatUtil.getCombatValueByName(attrNameEN,attrTotalValue);
        return 0;
    }

    /**
     * 得某个属性的中文名
     * @params spaceType 间距类型(无间距、小间距、大间距) AttributeBaseData.NameSpace_No
     */
    public function getAttrNameCN(spaceType:int = 1):String
    {
        return _attrNameCN;
    }

    public function get attrNameCN():String
    {
        return _attrNameCN;
    }

    public function set attrNameCN(value:String):void
    {
        _attrNameCN = value;
    }

    /**
     * 属性名美术字
     */
    public function get attrImgNameUrl():String
    {
        if(attrNameEN)
        {
            return "Attr_"+attrNameEN+".png";
        }

        return "";
    }

    /**
     * 属性图标
     * @return
     *
     */
    public function get attrIconUrl():String
    {
        if(attrNameEN)
        {
            return "attrIcon_"+attrNameEN+".png";
        }

        return "";
    }

    public function set attrNameEN(value:String):void
    {
        _attrNameEN = value;

//        if(_attrNameEN && !_attrType)
//        {
//            _attrType = AttributeUtil.getAttrTypeByAttrName(_attrNameEN);
//        }
    }

    public function get attrNameEN():String
    {
        return _attrNameEN;
    }

    public function set attrType(value:int):void
    {
        _attrType = value;

//        if(!_attrNameEN)
//        {
//            _attrNameEN = AttributeUtil.getAttrNameENByTypeValue(value);
//        }
    }

    public function get attrType():int
    {
        return _attrType;
    }

    public function set attrBaseValue(value:int):void
    {
        _attrBaseValue = value;
    }

    public function get attrBaseValue():int
    {
        return _attrBaseValue;
    }

    public function set attrTotalValue(value:int):void
    {
        _attrTotalValue = value;
    }

    public function get attrTotalValue():int
    {
        return _attrTotalValue;
    }

    public function get attrPercent():int
    {
        return _attrPercent;
    }

    public function set attrPercent(value:int):void
    {
        _attrPercent = value;
    }

    public function get type():int
    {
        return _type;
    }

    public function set type(value:int):void
    {
        _type = value;
    }
}
}
