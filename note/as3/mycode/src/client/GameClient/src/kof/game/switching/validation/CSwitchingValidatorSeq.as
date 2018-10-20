//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.switching.validation {

import QFLib.Foundation.free;

import kof.SYSTEM_TAG;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CEventPriority;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.CSystemBundleEvent;
import kof.game.bundle.ISystemBundle;
import kof.game.switching.CSwitchingHandler;
import kof.table.BundleEnable;

/**
 * 功能开启条件验证队列管理
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSwitchingValidatorSeq extends CAbstractHandler implements ISwitchingValidation {

    /** @private */
    private var m_pValidators : Vector.<ISwitchingValidation>;
    /** @private */
    private var m_pConfigData : Vector.<BundleEnable>;
    /** @private */
    private var m_pResultCache : Vector.<String>;

    /**
     * Creates a new CSwitchingValidatorSeq
     */
    public function CSwitchingValidatorSeq() {
        super();
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();

        // free Validators.
        if ( m_pValidators && m_pValidators.length ) {
            for each ( var validator : ISwitchingValidation in m_pValidators ) {
                free( validator );
            }

            m_pValidators.splice( 0, m_pValidators.length );
        }
        m_pValidators = null;
    }

    /** @inheritDoc */
    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && initialize();
        return ret;
    }

    /** @private */
    protected function initialize() : Boolean {
        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        if ( pDB ) {
            var pTable : IDataTable = pDB.getTable( KOFTableConstants.BUNDLE_ENABLE );
            if ( pTable ) {
                var arr : Array = pTable.toArray();
                for each ( var v : BundleEnable in arr ) {
                    if ( !m_pConfigData )
                        m_pConfigData = new <BundleEnable>[];
                    m_pConfigData.push( v );
                }
            }
        }

        if ( !m_pValidators ) {
            m_pValidators = new <ISwitchingValidation>[];
            m_pValidators.push( new CSwitchingStrategyValidator( system ) );
            m_pValidators.push( new CSwitchingAccountTypeIDValidator( system ) );
            m_pValidators.push( new CSwitchingMinLevelValidator( system ) );
            m_pValidators.push( new CSwitchingInstancePassValidator( system ) );
            m_pValidators.push( new CSwitchingTaskDoneValidator( system ) );
        }

        var pBundleCtx : CSystemBundleContext = system.stage.getSystem( CSystemBundleContext ) as CSystemBundleContext;
        if ( pBundleCtx ) {
            pBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_REGISTERED, _bundleCtx_bundleRegisteredEventHandler, false, CEventPriority.DEFAULT, true );
            pBundleCtx.addEventListener( CSystemBundleEvent.BUNDLE_UNREGISTERED, _bundleCtx_bundleUnRegisteredEventHandler, false, CEventPriority.DEFAULT, true );

            m_pConfigData = m_pConfigData || new <BundleEnable>[];
            for each ( var pBundle : ISystemBundle in pBundleCtx.systemBundleIterator ) {
                if ( pBundle.bundleID < 0 ) {
                    m_pConfigData.push( constructBuiltBundleConfigItem( pBundle ) );
                }
            }
        }

        sortConfigData();

        return Boolean( m_pConfigData );
    }

    override protected function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        return ret;
    }

    protected function sortConfigData() : void {
        if ( m_pConfigData ) {
            m_pConfigData.sort( function ( a : BundleEnable, b : BundleEnable ) : int {
                if ( !a && b ) return 1;
                else if ( a && !b ) return -1;
                if ( a.MinLevel > b.MinLevel ) return 1;
                else if ( a.MinLevel < b.MinLevel ) return -1;
                if ( a.OrderID > b.OrderID ) return 1;
                else if ( a.OrderID < b.OrderID ) return -1;
                if ( a.ID > b.ID ) return 1;
                else if ( a.ID < b.ID ) return -1;
                return 0;
            } );
        }
    }

    protected function constructBuiltBundleConfigItem( pBundle : ISystemBundle ) : BundleEnable {
        var vEnt : BundleEnable = new BundleEnable( {
            ID : pBundle.bundleID,
            TagID : SYSTEM_TAG( pBundle.bundleID ),
            MinLevel : 0,
            TaskDoneID : 0,
            InstancePassID : 0,
            AccountTypeID : 0,
            OrderID : -1,
            ShowType : 0,
            NoticeRequired : 0,
            NoticeDescText : null,
            IconURI : null
        } );
        return vEnt;
    }

    /** @private */
    private function _bundleCtx_bundleUnRegisteredEventHandler( event : CSystemBundleEvent ) : void {
        if ( !m_pConfigData )
            return;

        if ( event.bundle.bundleID >= 0 )
            return;

        for each ( var pItem : BundleEnable in m_pConfigData ) {
            if ( pItem.ID == event.bundle.bundleID ) {
                m_pConfigData.splice( m_pConfigData.indexOf( pItem ), 1 );
                break;
            }
        }
    }

    /** @private */
    private function _bundleCtx_bundleRegisteredEventHandler( event : CSystemBundleEvent ) : void {
        m_pConfigData = m_pConfigData || new <BundleEnable>[];

        if ( event.bundle.bundleID < 0 ) {
            m_pConfigData.push( constructBuiltBundleConfigItem( event.bundle ) );
            sortConfigData();
        }
    }

    final public function get iterator() : Object {
        return m_pValidators;
    }

    public function evaluate( ... args ) : Boolean {
        if ( !m_pConfigData || !m_pConfigData.length )
            return false;

        var vResult : Vector.<String> = m_pResultCache;

        if ( vResult && vResult.length ) {
            vResult.splice( 0, vResult.length );
        }

        for each ( var pData : BundleEnable in m_pConfigData ) {
            var bValid : Boolean = true;
            for each ( var validator : ISwitchingValidation in m_pValidators ) {
                bValid = bValid && validator.evaluate( pData );
                if ( !bValid )
                    break;
            }

            if ( bValid ) {
                vResult = vResult || new <String>[];
                vResult.push( pData.TagID );
            }
        }

        m_pResultCache = vResult;
        return vResult && vResult.length;
    }

    public function listResultAsTags() : Vector.<String> {
        return m_pResultCache;
    }

    public function queryComingShowItem() : BundleEnable {
        if ( !m_pResultCache )
            return null;

        var switchingHandler:CSwitchingHandler = system.getHandler(CSwitchingHandler) as CSwitchingHandler;
        for each ( var pData : BundleEnable in m_pConfigData ) {
            if ( m_pResultCache.indexOf( pData.TagID ) == -1 && !switchingHandler.isSystemOpen(pData.TagID)) {
                if ( pData.NoticeRequired )
                    return pData;
            }
        }

        return null;
    }

    public function getLocaleDesc( pConfigData : Object ) : String {
        return null;
    }

    public function addValidator( pValidator : ISwitchingValidation ) : void {
        if ( !pValidator )
            return;

        if ( m_pValidators.indexOf( pValidator ) == -1 ) {
            m_pValidators.push( pValidator );
        }
    }

    public function removeValidator( pValidator : ISwitchingValidation ) : void {
        if ( !pValidator )
            return;

        var idx : int = m_pValidators.indexOf( pValidator );
        if ( idx != -1 ) {
            m_pValidators.splice( idx, 1 );
        }
    }

}
}

// vim:ft=as3 tw=120 sw=4 ts=4 expandtab
