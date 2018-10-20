//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2018/3/8.
//----------------------------------------------------------------------
package kof.game.character.ai.conditions {

import QFLib.AI.BaseNode.CBaseNodeCondition;
import QFLib.AI.CAIObject;

public class CSwitchCondition extends CBaseNodeCondition {

    private var m_pBT : CAIObject = null;
    private var m_status : String = SwitchType.Close;

    public function CSwitchCondition( pBt : Object = null, nodeName : String = null, nodeIndex : int = -1 ) {
        super();
        this.m_pBT = pBt as CAIObject;
        if ( nodeIndex > -1 ) {
            setTemplateIndex( nodeIndex );
            setName( nodeIndex + "_" + nodeName );
        }
        else {
            setName( nodeName );
        }
        initData();
    }

    private function initData() : void {

        var name : String = getName();
        if ( name == null )return;
        if ( m_pBT.cacheParamsDic[ name + ".switchStatus" ] ) {
            m_status = m_pBT.cacheParamsDic[ name + ".switchStatus" ];
        }
    }

    override protected final function externalCondition(inputData : Object ) : Boolean{
        if( m_status == SwitchType.Open )
                return true;
        return false
    }


}
}

class SwitchType{
    public static const Close : String ="Close";
    public static const Open : String ="Open";

}
