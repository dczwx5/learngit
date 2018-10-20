//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/9/1.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import kof.game.audio.IAudio;
import kof.game.character.audio.CAudioMediator;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;

public class CSkillAudioSupportDemo {

    public function CSkillAudioSupportDemo() {

    }

    public function set owner( powner : CGameObject) : void
    {
        m_powner = powner;
        m_player= powner.getComponentByClass( CAudioMediator , true ) as CAudioMediator;
    }

    public function get preID() : String
    {
        var iProperty : ICharacterProperty = m_powner.getComponentByClass(ICharacterProperty , true ) as ICharacterProperty;
        var pT : int  = iProperty.prototypeID;
        switch ( pT )
        {
            //lianna
            case 10:
            case 2:
                return "lianna_";
            case 1:
            case 4:
                return "cao_";
            case 17:
            case 3:
                return "wu_";
            case 59:
            case 5:
                return "lu";
        }
        return "";
    }

    public function playMotion( name: String) : void
    {
        return ;
        if( m_player )
            m_player.playAudioByName( preID + name );
    }

    private var m_player : CAudioMediator;
    private var m_powner : CGameObject;
}
}
