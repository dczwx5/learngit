//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/27.
 */
package kof.game.common {

import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.data.CAttributeBaseData;
import kof.table.PassiveSkillPro;

public class CAttributeUtil {
    public function CAttributeUtil()
    {
    }

    /**
     * 通用属性字符串解析方法(属性字串类型：'1:100:1000;2:200:2000' / '[1:100:1000;2:200:2000]')
     * @return
     */
    public static function parseAttrStr(attrStr:String, system:CAppSystem):Array
    {
        var resultArr:Array = [];

        var str:String = "";
        if(attrStr)
        {
            if(attrStr.indexOf("[") != -1)
            {
                str = attrStr.substring(1, attrStr.length-1);
            }
            else
            {
                str = attrStr;
            }

            var arr1:Array = str.split(";");
            for each(var str1:String in arr1)
            {
                if(str1)
                {
                    var arr2:Array = str1.split(":");

                    if(arr2 && arr2.length)
                    {
                        var attrData:CAttributeBaseData = new CAttributeBaseData();
                        attrData.attrType = arr2.length >= 1 ? int(arr2[0]) : 0;
                        attrData.attrBaseValue = arr2.length >= 2 ? int(arr2[1]) : 0;
                        attrData.attrPercent = arr2.length >= 3 ? int(arr2[2]) : 0;
                        attrData.attrNameEN = getAttrNameEnByType(attrData.attrType, system);
                        attrData.attrNameCN = getAttrNameCN(attrData.attrNameEN, system);

                        resultArr.push(attrData);
                    }
                }

            }
        }

        return resultArr;
    }

    /**
     * 得属性中文名
     * @param attrName 属性英文名
     * @param system
     * @return
     */
    public static function getAttrNameCN(attrName:String, system:CAppSystem):String
    {
        var databaseSystem:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        if(databaseSystem && attrName)
        {
            var arr:Array = databaseSystem.getTable(KOFTableConstants.PASSIVE_SKILL_PRO ).findByProperty("word",attrName);
            if(arr && arr.length)
            {
                return (arr[0] as PassiveSkillPro).name;
            }
        }

        return "";
    }

    /**
     * 通过属性类型得属性英文名
     * @param type 属性类型
     * @param system
     * @return
     */
    public static function getAttrNameEnByType(type:int, system:CAppSystem):String
    {
        var databaseSystem:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        if(databaseSystem)
        {
            var passiveSkillTable:IDataTable = databaseSystem.getTable( KOFTableConstants.PASSIVE_SKILL_PRO );
            var cfg: PassiveSkillPro = passiveSkillTable.findByPrimaryKey(type);
            if (cfg != null)
            {
                return cfg.word;
            }
        }

        return "";
    }

    /**
     * 通过属性类型得属性中文名
     * @param type 属性类型
     * @param system
     * @return
     */
    public static function getAttrNameCnByType(type:int, system:CAppSystem):String
    {
        var nameEn:String = getAttrNameEnByType(type, system);
        return getAttrNameCN(nameEn, system);
    }
}
}
