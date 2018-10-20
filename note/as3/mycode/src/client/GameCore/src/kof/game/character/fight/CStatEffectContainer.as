//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight {

import QFLib.Foundation;

import kof.game.core.CGameComponent;

/**
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CStatEffectContainer extends CGameComponent implements IStatEffectContainer {

    /** @private */
    private var m_listStatEffect : Vector.<IStatEffect>;
    /** @private */
    private var m_pIterator : CIterDelegate;

    public function CStatEffectContainer() {
        super( "statEffects" );
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
        if ( !m_listStatEffect )
            m_listStatEffect = new <IStatEffect>[];
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
        if ( m_listStatEffect )
            m_listStatEffect.splice( 0, m_listStatEffect.length );
        m_listStatEffect = null;
    }

    public function addStatEffect( statEffect : IStatEffect ) : void {
        if ( !statEffect )
            return;
        var pIndex : int = m_listStatEffect.indexOf( statEffect );
        if ( pIndex == -1 ) {
            m_listStatEffect.push( statEffect );
            if ( statEffect is CAbstractStatEffect )
                CAbstractStatEffect( statEffect ).setParent( this );
        } else {
            // Ignored.
            Foundation.Log.logWarningMsg( "The IStatEffect [id: " + statEffect.id + ", statEffectId: " + statEffect.statEffectId + " added dup." );
        }
    }

    public function removeStatEffect( statEffect : IStatEffect ) : void {
        if ( !statEffect )
            return;
        var pIndex : int = m_listStatEffect.indexOf( statEffect );
        if ( pIndex != -1 ) {
            m_listStatEffect.splice( pIndex, 1 );
            if ( statEffect is CAbstractStatEffect )
                CAbstractStatEffect( statEffect ).setParent( null );
        }
    }

    [Inline]
    final public function hasStatEffect( id : Number ) : Boolean {
        return null != this.getStatEffect( id );
    }

    public function getStatEffect( id : Number ) : IStatEffect {
        for each ( var statEffect : IStatEffect in m_listStatEffect ) {
            if ( statEffect && statEffect.id == id ) {
                return statEffect;
            }
        }
        return null;
    }

    final public function get size() : uint {
        return m_listStatEffect.length;
    }

    public function get iterator() : IIterable {
        if ( !m_pIterator ) {
            m_pIterator = new CIterDelegate( m_listStatEffect );
        }
        return m_pIterator;
    }

    public function update( delta : Number ) : void {
        // update all.
    }

}
}

import flash.utils.Proxy;
import flash.utils.flash_proxy;

import kof.game.character.fight.IIterable;
import kof.game.character.fight.IStatEffect;
import kof.util.CAssertUtils;

dynamic class CIterDelegate extends Proxy implements IIterable {

    private var m_pTarget : Vector.<IStatEffect>;

    function CIterDelegate( target : Vector.<IStatEffect> ) {
        this.m_pTarget = target;
        CAssertUtils.assertNotNull( m_pTarget );
    }

    override flash_proxy function nextNameIndex( index : int ) : int {
        if ( 0 > index || index >= m_pTarget.length )
            return 0;
        return index + 1;
    }

    override flash_proxy function nextName( index : int ) : String {
        if ( 0 > index || index >= m_pTarget.length )
            return "undefined";
        return index.toString();
    }

    override flash_proxy function nextValue( index : int ) : * {
        return m_pTarget[ index - 1 ];
    }

}
