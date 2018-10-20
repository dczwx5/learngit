//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.Tutorial.tutorPlay.action {

import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.game.Tutorial.data.CTutorActionInfo;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.switching.CSwitchingSystem;
import kof.table.MainView;
import kof.util.CAssertUtils;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.List;
import morn.core.components.View;

public class CTutorActionSystemBundleGuideClick extends CTutorActionBase {

    private var _pView:View;
    private var m_pLists : Vector.<List>;
    private var m_sTagID : String;

    public function CTutorActionSystemBundleGuideClick( actionInfo : CTutorActionInfo, system : CAppSystem ) {
        super( actionInfo, system );
        m_pLists = new <List>[];
    }

    override public function dispose() : void {
        var comp : Component = this.holeTarget;
        super.dispose();

        if ( comp ) {
            comp.removeEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler );
        }

        if ( m_pLists && m_pLists.length ) {
            m_pLists.splice( 0, m_pLists.length );
        }
        m_pLists = null;
        _pView = null;
        m_sTagID = null;
    }

    override protected function startByUIComponent( comp : Component ) : void {
        CAssertUtils.assertNotNull( comp );

        var sTagID : String;
        for each( var sParam : String in this._info.actionParams ) {
            if ( !sParam )
                continue;
            sTagID = sParam;
            break;
        }

        if ( !sTagID ) {
            Foundation.Log.logWarningMsg( "系统功能点击引导没有配置TagID" );
            stop();
            return;
        }

        m_sTagID = sTagID;

        if (comp is View) {
            // 拳皇大赛
            _pView = comp as View;
            _processView();
        } else {
            if (comp is List) {
                m_pLists.push( comp as List );
            } else {
                var vList : List;
                for ( var i : int = 0; i < comp.numChildren; ++i ) {
                    vList = comp.getChildAt( i ) as List;
                    if ( vList )
                        m_pLists.push( vList );
                }
            }
            this.processList();
        }

    }
    protected function _processView() : void {
        if ( !m_sTagID )
            return;

        if ( !_pView )
            return;
        if ( this.holeTarget )
            this.holeTarget.removeEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler );
        this.holeTarget = _pView;

        if ( this.holeTarget ) {
            this.holeTarget.addEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler, false,
                    CEventPriority.BINDING, true );
        }
    }
    protected function processList() : void {
        if ( !m_sTagID )
            return;

        if ( !m_pLists || !m_pLists.length )
            return;

        var bFound : Boolean = false;

        for each( var pList : List in m_pLists ) {
            if ( pList ) {
                var pArray : Array = pList.dataSource as Array;
                for ( var idx : int = 0; idx < pArray.length; idx++ ) {
                    var pData : MainView = pArray[ idx ] as MainView;
                    if ( !pData )
                        continue;
                    if ( pData.Tag == m_sTagID ) {
                        // found.
                        if ( this.holeTarget )
                            this.holeTarget.removeEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler );

                        this.holeTarget = pList.getCell( idx );
                        bFound = true;
                        break;
                    }
                }

                if ( bFound )
                    break;
            }
        }

        if ( bFound && this.holeTarget ) {
            this.holeTarget.addEventListener( MouseEvent.CLICK, _comp_onMouseClickEventHandler, false,
                    CEventPriority.BINDING, true );
        }
    }

    final private function _comp_onMouseClickEventHandler( event : MouseEvent ) : void {
        event.currentTarget.removeEventListener( event.type, _comp_onMouseClickEventHandler );
        _actionValue = true;
        this.holeTarget = null;
    }

    override public virtual function update( delta : Number ) : void {
        super.update( delta );

        if ( !_actionValue ) {
            this.processList();

            if ( !_actionValue ) {
                // 如果bundle's actived is true, 则通过
                var sTagID : String = _info.actionParams[0] as String;
                var bCheckValue:Boolean = true;
                var pSystemBundleCtx : ISystemBundleContext = _system.stage.getSystem( ISystemBundleContext ) as
                        ISystemBundleContext;
                if ( pSystemBundleCtx ) {
                    var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID(sTagID) );
                    var bBundleActived:Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED );
                    if (bBundleActived == bCheckValue) {
                        _actionValue = true;
                    }
                }
            }
        }
    }

    public override function autoPassProcess() : Boolean {
        if (!(super.autoPassProcess())) {
            return false;
        }

        var sTagID : String = _info.actionParams[0] as String;
        var bCheckValue:Boolean = true;
        var isSystemOpen:Boolean = (_system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem).isSystemOpen(sTagID);
        if (!isSystemOpen) {
            return false;
        }

        var pSystemBundleCtx : ISystemBundleContext = _system.stage.getSystem( ISystemBundleContext ) as
                ISystemBundleContext;
        if ( pSystemBundleCtx ) {
            var pSystemBundle : ISystemBundle = pSystemBundleCtx.getSystemBundle( SYSTEM_ID(sTagID) );
            var bBundleActived:Boolean = pSystemBundleCtx.getUserData( pSystemBundle, CBundleSystem.ACTIVATED );
            if (bBundleActived != bCheckValue) { // 如果界面没打开。自动打开
                pSystemBundleCtx.setUserData(pSystemBundle, CBundleSystem.ACTIVATED, bCheckValue);
            }
        }
        return true;
    }
}
}

// vim:ft=as3 tw=120 sw=4 ts=4 expandtab
