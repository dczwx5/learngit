//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

import kof.framework.CAbstractHandler;

/**
 * 通用的游戏系统控制器，只用于CGameSystem Pipeline处理游戏对象，适用于ECS模式
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CGameSystemHandler extends CAbstractHandler implements IGameSystemHandler {

    /** @private */
    private var m_listSupportedComponentClass : Vector.<Class>;

    /** @private */
    private var m_bEnabled : Boolean;

    public function CGameSystemHandler( ... comps ) {
        super();
        m_listSupportedComponentClass = new <Class>[];

        for each ( var cls : Class in comps ) {
            if ( cls )
                m_listSupportedComponentClass.push( cls );
        }

        m_bEnabled = true;
    }

    public function isComponentClassSupported( clz : Class ) : Boolean {
        if ( !(clz is CGameComponent) )
            return false;
        var iIndex : int = m_listSupportedComponentClass.indexOf( clz );
        return iIndex != -1;
    }

    public function isComponentSupported( obj : CGameObject ) : Boolean {
        if ( !m_listSupportedComponentClass || m_listSupportedComponentClass.length == 0 )
            return true;
        else {
            var supported : Boolean = true;
            for each ( var clz : Class in m_listSupportedComponentClass ) {
                var comp : IGameComponent = obj.getComponentByClass( clz, true );
                if ( !comp ) {
                    supported = false;
                    break;
                }
            }

            return supported;
        }
    }

    final public function get enabled() : Boolean {
        return m_bEnabled;
    }

    final public function set enabled( value : Boolean ) : void {
        m_bEnabled = value;
        this.onEnabled( value );
    }

    protected function onEnabled( value : Boolean ) : void {

    }

    public virtual function beforeTick( delta : Number ) : void {
    }

    public virtual function tickValidate( delta : Number, obj : CGameObject ) : Boolean {
        return this.enabled;
    }

    public virtual function tickUpdate( delta : Number, obj : CGameObject ) : void {
    }

    public virtual function afterTick( delta : Number ) : void {
    }

}
}
