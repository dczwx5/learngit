//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/23.
 */
package kof.game.player.data.property {

import kof.framework.CAppSystem;
import kof.framework.IDatabase;
import kof.game.character.property.CBasePropertyData;

import morn.core.components.Label;

public class CPropertyHelp {
    // propertyString : [1:10000:0;2:200:0;3:100:0]
    // return [propertyData, numProperty]
    public static function createPropertyData(system:CAppSystem, propertyString:String) : CBasePropertyData {
        var propertyData:CBasePropertyData = new CBasePropertyData();
        propertyData.databaseSystem = system.stage.getSystem(IDatabase) as IDatabase;
        propertyString = propertyString.replace("[","");
        propertyString = propertyString.replace("]","");
        var attInfoStrList:Array = propertyString.split(";");
        for(var j:int = 0; j < attInfoStrList.length; j++) {
            var attInfoList:Array = attInfoStrList[j].split(":");
            var attrType:int = int(attInfoList[0]);
            var attrValue:int = int(attInfoList[1]);
            var attrNameEN:String = propertyData.getAttrNameEN(attrType);
            propertyData[attrNameEN] += attrValue;
        }
        return propertyData;
    }

    // 用propertyData 来 做UI的显示
    // uiPairList : [[titleUI, valueUI], [titleUI, valueUI], [titleUI, valueUI]]
    public static function showPropertyInUI(uiPairList:Array, propertyData:CBasePropertyData) : void {
        var titleUI:Label;
        var valueUI:Label;
        var pairUI:Array;
        for each (pairUI in uiPairList) {
            titleUI = pairUI[0];
            valueUI = pairUI[1];
            titleUI.visible = false;
            valueUI.visible = false;
        }

        var i:int = 0;
        var propertyUIProcess:Function = function (key:String, value:int) : void {
            if (uiPairList.length > i) {
                pairUI = uiPairList[i];
                titleUI = pairUI[0];
                valueUI = pairUI[1];
                titleUI.visible = true;
                valueUI.visible = true;
                titleUI.text = propertyData.getAttrNameCN(key);
                valueUI.text = value.toString();
            }
            i++;
        };
        propertyData.data.loop(propertyUIProcess);

    }

}
}
