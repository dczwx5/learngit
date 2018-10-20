//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.validation {

import kof.framework.CAppSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.BundleEnable;

/**
 * 功能开启最小等级验证
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingMinLevelValidator implements ISwitchingValidation {

    private var m_pSystemRef : CAppSystem;

    /** Creates a new CSwitchingMinLevelValidator. */
    public function CSwitchingMinLevelValidator( pSystemRef : CAppSystem ) {
        super();
        this.m_pSystemRef = pSystemRef;
    }

    /** @inheritDoc */
    public function dispose() : void {
        m_pSystemRef = null;
    }

    /** @inheritDoc */
    public function evaluate( ... args ) : Boolean {
        var pData : BundleEnable = args[ 0 ] as BundleEnable;

        if ( pData ) {
            var vStatusQuery : Array = args.length > 1 ? args[ 1 ] as Array : [];
            if ( vStatusQuery.length == 0 )
                vStatusQuery.push( 0 );

            const vMinLevel : int = pData.MinLevel;
            if ( vMinLevel > 0 ) {
                vStatusQuery[ 0 ] = -1;
                // compare with player's level.
                var pPlayerSystem : CPlayerSystem = m_pSystemRef.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
                if ( !pPlayerSystem )
                    return false;
                var vPlayerData : CPlayerData = pPlayerSystem.playerData;
                if ( !vPlayerData )
                    return false;
                vStatusQuery[ 0 ] = 0;
                return vMinLevel <= vPlayerData.teamData.level;
            }

            vStatusQuery[ 0 ] = -1;
        }

        return true;
    }

    public function getLocaleDesc( configData : Object ) : String {
        var pData : BundleEnable = configData as BundleEnable;
        if ( !pData )
            return null;
        return "战队等级<font color='{}'>" + pData.MinLevel + "级</font>";
    }
}
}
