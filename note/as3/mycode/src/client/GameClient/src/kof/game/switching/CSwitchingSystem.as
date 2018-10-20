//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching {

import kof.BIND_SYSTEM_ID;
import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.CAppStage;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.switching.CSwitchingHandler;
import kof.game.switching.triggers.CSwitchingTriggerBridge;
import kof.game.switching.validation.CSwitchingValidatorSeq;
import kof.game.switching.validation.ISwitchingValidation;
import kof.game.switching.view.CFuncNoticeDetectHandler;
import kof.game.switching.view.CFuncNoticeViewHandler;
import kof.game.switching.view.CSwitchingComingViewHandler;
import kof.game.switching.view.CSwitchingPopUpViewHandler;
import kof.table.SystemIDs;

/**
 * 系统开关（系统开放）
 *
 * @author Jeremy (jeremy@qifun.com
 */
public class CSwitchingSystem extends CBundleSystem {

    /**
     * Creates a new CSwitchingSystem.
     */
    public function CSwitchingSystem() {
        super();
    }

    override public function dispose() : void {
        super.dispose();
    }

    override public function initialize() : Boolean {

        this.addBean( new CSwitchingTriggerBridge() );
        this.addBean( new CSwitchingValidatorSeq() );
        this.addBean( new CSwitchingHandler() );
        this.addBean( new CSwitchingComingViewHandler() );
        this.addBean( new CSwitchingPopUpViewHandler() );
        this.addBean( new CFuncNoticeViewHandler() );
        this.addBean( new CFuncNoticeDetectHandler() );

        var pDB : IDatabase = stage.getSystem( IDatabase ) as IDatabase;
        if ( pDB ) {
            // Retrieves the SystemBundle config table and binding tag and ID.
            var pTable : IDataTable = pDB.getTable( KOFTableConstants.SYSTEM_IDS ) as IDataTable;
            if ( pTable ) {
                var all : Array = pTable.toArray();
                for each ( var pRow : SystemIDs in all ) {
                    BIND_SYSTEM_ID( pRow.Tag, pRow.ID );
                }
            }
        }

        BIND_SYSTEM_ID( KOFSysTags.SWITCHING, -1024 );

        if ( !super.initialize() )
            return false;

        return true;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        return ret;
    }

    /**
     * @inheritDoc
     */
    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );

    }

    override public function get bundleID() : * {
        return SYSTEM_ID( KOFSysTags.SWITCHING );
    }

    override protected function onBundleStart( ctx : ISystemBundleContext ) : void {
        for each ( var pHandler : CAbstractHandler in this.handlerIterator ) {
            if ( pHandler && pHandler.hasOwnProperty( 'onBundleStart' ) ) {
                pHandler[ 'onBundleStart' ]( ctx );
            }
        }
    }

    [Inline]
    final public function addValidator( pValidator : ISwitchingValidation ) : void {
        var pHandler : CSwitchingHandler = this.getHandler( CSwitchingHandler ) as CSwitchingHandler;
        pHandler.addValidator( pValidator );
    }

    [Inline]
    final public function removeValidator ( pValidator : ISwitchingValidation ) : void {
        var pHandler : CSwitchingHandler = this.getHandler( CSwitchingHandler ) as CSwitchingHandler;
        pHandler.removeValidator( pValidator );
    }

    [Inline]
    final public function addTrigger( pTrigger : ISwitchingTrigger ) : void {
        var pHandler : CSwitchingHandler = this.getHandler( CSwitchingHandler ) as CSwitchingHandler;
        pHandler.addTrigger( pTrigger );
    }

    [Inline]
    final public function removeTrigger( pTrigger : ISwitchingTrigger ) : void {
        var pHandler : CSwitchingHandler = this.getHandler( CSwitchingHandler ) as CSwitchingHandler;
        pHandler.removeTrigger( pTrigger );
    }

    public function isSystemOpen(sysTag:String):Boolean
    {
        return (this.getHandler(CSwitchingHandler) as CSwitchingHandler).isSystemOpen(sysTag);
    }
}
}
