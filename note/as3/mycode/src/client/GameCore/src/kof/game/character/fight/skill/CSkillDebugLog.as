//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/16.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

import QFLib.Foundation;
import QFLib.Foundation.CLog;

public class CSkillDebugLog {
    public function CSkillDebugLog( ) {

    }

    public static function logMsg( msg : String ) : void
    {

        if( m_boLogSkill )
                Foundation.Log.logMsg( msg );

    }

    public static function logTraceMsg( Msg : String ) : void
    {

            if ( m_boLogSkill )
                Foundation.Log.logTraceMsg( Msg );

    }

    public static function logErrorMsg( Msg : String ) : void
    {

            if ( m_boLogSkill )
                Foundation.Log.logErrorMsg( Msg );

    }
    private static var m_boLogSkill: Boolean = true;
}
}
