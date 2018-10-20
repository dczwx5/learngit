//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/5/29.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.action {

import kof.message.CAbstractPackMessage;
import kof.message.Fight.SkillCastRequest;
import kof.message.Fight.SkillCastResponse;
import kof.message.kof_message;

public class CFighterSkillAction extends CBaseFighterKeyAction{
    public function CFighterSkillAction() {
        super( EFighterActionType.E_SKILL_ACTION );
    }

    override public function clear() : void{
        m_queueID = 0 ;
        m_queueID = 0;
    }

    protected function setSkillAction( skillID : int , queueID : int ) : void{
        m_skillID = skillID;
        m_queueID = queueID ;
    }

    override protected function setAction( msg : CAbstractPackMessage ) : void
    {
        super.setAction(msg);
    }

    override protected function setRequestInfo( msg : CAbstractPackMessage ) : void{
        var reqMsg : SkillCastRequest = msg as SkillCastRequest;
            setSkillAction( reqMsg.skillID , reqMsg.queueID );
    }

    override protected function setResponseInfo( msg : CAbstractPackMessage ) : void{
         var resMsg : SkillCastResponse = msg as SkillCastResponse;
            setSkillAction( resMsg.skillID , resMsg.queueID )
    }

    override public function replay() : void{

    }

    private var m_skillID : int;
    private var m_queueID : int;

}
}
