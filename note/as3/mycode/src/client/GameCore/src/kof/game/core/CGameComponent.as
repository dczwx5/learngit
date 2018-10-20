//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

import QFLib.Foundation;
import QFLib.Memory.CSmartObject;

import flash.utils.getQualifiedClassName;

import kof.util.CObjectUtils;

/**
 * A basic implementation as component be using in CGameObject.
 *
 * @see kof.game.core.CGameObject
 * @author Jeremy (jeremy@qifun.com)
 */
public class CGameComponent extends CSmartObject implements IGameComponent {

    public static const STATE_CREATED : int = 0;
    public static const STATE_ENTERED : int = 1;
    public static const STATE_EXITED : int = 2;

    /** @private */
    private var m_pOwner : CGameObject;
    /** @private */
    private var m_pData : Object;
    /** @private */
    private var m_strName : String;
    /** @private */
    private var m_bBranchData : Boolean;
    /** @private */
    private var m_bEnabled : Boolean;
    /**
     * Running state.
     *  0 - created
     *  1 - entered
     *  2 - exited
     */
    private var m_iRunningState : int;

    /**
     * Creates a new CGameComponent.
     */
    public function CGameComponent( name : String = null, branchData : Boolean = false ) {
        super();
        this.m_strName = name;
        if ( null == name ) {
            // auto generated name.
            this.m_strName = getQualifiedClassName( this );
        }

        m_bBranchData = branchData;
        m_bEnabled = true;
        m_iRunningState = STATE_CREATED;
    }

    [Inline]
    final public function get name() : String {
        return m_strName;
    }

    [Inline]
    final public function set name( value : String ) : void {
        this.m_strName = value;
    }

    [Inline]
    final public function get owner() : CGameObject {
        return m_pOwner;
    }

    [Inline]
    final public function get enabled() : Boolean {
        return m_bEnabled;
    }

    public function set enabled( value : Boolean ) : void {
        m_bEnabled = value;
        this.onEnabled(value);
    }
    /**
     *2017/4/21 yili添加,获取组件禁用启用状态的改变，便于重置单个AI的状态和便于调试
     **/
    protected function onEnabled(value:Boolean):void
    {

    }

    [Inline]
    final public function get runningState() : int {
        return m_iRunningState;
    }

    final internal function setOwner( value : CGameObject ) : void {
        if ( this.m_pOwner == value )
            return;

        if ( value ) {
            m_pData = null;
            m_pOwner = value;

            if ( m_pOwner.isRunning )
                this.setEnter();
        } else {
            if ( m_pOwner && m_pOwner.isRunning )
                this.setExit();
            m_pOwner = null;
            m_pData = null;
        }
    }

    [Inline]
    final public function get transform() : ITransform {
        return owner.transform;
    }

    final internal function setEnter() : void {
        if ( this.runningState != STATE_ENTERED ) {
            if ( m_pOwner.data ) {
                try {
                    if ( m_bBranchData ) {
                        var temp : Object = {};
                        temp[ name ] = {};
                        CObjectUtils.extend( true, m_pOwner.data, temp );
                        m_pData = m_pOwner.data[ name ];
                    }
                } catch ( e : Error ) {
                    Foundation.Log.logErrorMsg( e.message );
                }
            }
            this.m_bEnabled = true;
            this.onEnter();
            this.m_iRunningState = STATE_ENTERED;
        }
    }

    [Inline]
    final internal function setExit() : void {
        if ( this.runningState == STATE_ENTERED ) {
            this.onExit();
            this.m_bEnabled = false;
            this.m_iRunningState = STATE_EXITED;
        }
    }

    [Inline]
    final internal function setDataUpdated() : void {
        this.onDataUpdated();
    }

    protected virtual function onEnter() : void {
        // NOOP.
    }

    protected virtual function onDataUpdated() : void {
        // NOOP.
    }

    protected virtual function onExit() : void {
        // NOOP.
    }

    /**
     * @inheritDoc
     */
    public function get data() : Object {
        return m_pData;
    }

    protected function extendData( data : Object ) : void {
        if ( m_pData && data ) {
            CObjectUtils.extend( true, m_pData, data );
        }
    }

    /**
     * @inheritDoc
     */
    final public function getComponent( clazz : Class, cache : Boolean = true ) : IGameComponent {
        if ( owner ) {
            return owner.getComponentByClass( clazz, cache );
        }
        return null;
    }

    /**
     * @inheritDoc
     */
    override public function dispose() : void {
        super.dispose();
        m_iRunningState = STATE_CREATED;
        m_pOwner = null;
        m_pData = null;
    }

}
}

