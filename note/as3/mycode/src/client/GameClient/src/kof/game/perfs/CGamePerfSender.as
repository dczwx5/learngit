package kof.game.perfs {

import QFLib.Foundation.CTime;

import flash.external.ExternalInterface;

import kof.framework.CAbstractHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CGamePerfSender extends CAbstractHandler {

    private var m_pPlayerSystem : CPlayerSystem;
    private var m_pInstanceSystem : CInstanceSystem;

    /** Creates a new CGamePerfSender */
    public function CGamePerfSender() {
        super();
    }

    override public function dispose() : void {
        super.dispose();

        m_pPlayerSystem = null;
        m_pInstanceSystem = null;
    }

    override protected function onSetup() : Boolean {
        var bRet : Boolean = super.onSetup();

        if ( bRet ) {
            m_pPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
            m_pInstanceSystem = system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
        }

        return bRet;
    }

    public function send( aRecord : CGamePerfRecord, iErrTimeElapsed : uint, iType : int, theActivatedTags : Vector.<String> = null ) : void {
        var obj : Object = {};

        if ( !m_pPlayerSystem || !m_pInstanceSystem )
            return;

        var vPlayerData : CPlayerData = m_pPlayerSystem.playerData;
        var iInstanceID : int = m_pInstanceSystem.instanceContentID;

        obj.vVersionId = system.stage.configuration.getString( "build_version", "" );
        obj.iRoleId = vPlayerData.ID;
        obj.vRoleName = vPlayerData.teamData.name;
        obj.iRoleJob = 0;
        obj.iRoleGender = 0;
        obj.iRoleLevel = vPlayerData.teamData.level;
        obj.iRoleVipLevel = vPlayerData.vipData.vipLv;
        obj.vRoleElse1 = "";
        obj.vRoleElse2 = "";
        obj.iType = iType;
        obj.vSysId = theActivatedTags && theActivatedTags.length ? JSON.stringify( theActivatedTags ) : "";
        obj.vInstanceId = iInstanceID;
        obj.iMinErrFrame = Math.round( aRecord.minFrameRate );
        obj.iMaxErrFrame = Math.round( aRecord.maxFrameRate );
        obj.iAvgErrFrame = Math.round( aRecord.avgFrameRate );
        obj.vMaxErrMem = Math.round( aRecord.maxMemUsage );
        obj.vAvgErrMem = Math.round( aRecord.avgMemUsage );
        obj.iErrTime = iErrTimeElapsed;
        obj.iOnlineTime = CTime.getCurrServerTimestamp() - CTime.loginServerTimestamp;

        // call the actual sender interface.
        try {
            ExternalInterface.call( "BI_performaceErrorLog", obj );
        } catch ( e : Error ) {
            // ignore.
        }

        CONFIG::debug {
            LOG.logMsg( "BI_performaceErrorLog: " + JSON.stringify( obj ) );
        }
    }

} // class CGamePerfSender
} // package kof.game.perfs
// vim: ft=as3 tw=120 expandtab
