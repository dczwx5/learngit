//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/1.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.action {

import kof.game.character.CCharacterDataDescriptor;
import kof.game.core.CGameObject;
import kof.message.CAbstractPackMessage;
import kof.message.Fight.HitRequest;
import kof.message.Fight.HitResponse;

public class CFighterHitAction extends CBaseFighterKeyAction {
    public function CFighterHitAction() {
        super( EFighterActionType.E_HIT_ACTION );
    }
    override public function clear() : void
    {
        super.clear();
        if( m_targetList )
                m_targetList.splice( 0 , m_targetList.length );
        m_targetList = null;
    }

    override protected function setResponseInfo( msg : CAbstractPackMessage ) : void {
        var hitResponse : HitResponse = msg as HitResponse;
        m_nHitID = hitResponse.hitId;
        m_targetList = hitResponse.targets;
    }

    override protected function setRequestInfo( msg : CAbstractPackMessage ) : void {

        var hitRequest : HitRequest = msg as HitRequest;
        m_nHitID = hitRequest.hitId;
        m_targetList = hitRequest.targets;
    }

    public function findHitTarget( target : CGameObject ) : Object{
        if ( target == null ) return false;

        var targetID : Number;
        var targetType : int;
        targetID = CCharacterDataDescriptor.getID( target.data );
        targetType = CCharacterDataDescriptor.getType( target.data );

        for each( var targetInfo : Object in m_targetList ) {
            if ( targetID == targetInfo[ "ID" ] && targetType == targetInfo[ "type" ] )
                return targetInfo;
            continue;
        }

        return null;
    }

    public function get HitID() : int{
        return m_nHitID;
    }

    private var m_nHitID : int;
    private var m_targetList : Array;
}
}
