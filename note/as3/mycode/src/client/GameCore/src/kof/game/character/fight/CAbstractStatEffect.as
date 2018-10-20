//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight {

/**
 * 抽象战斗效果
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CAbstractStatEffect implements IStatEffect {

    /** @private */
    internal static var s_nIDGen : uint = 0;

    /** @private */
    private var m_pParent : IStatEffectContainer;
    /** @private */
    private var m_nId : uint;
    /** @private */
    private var m_strName : String;
    /** @private */
    private var m_iStatEffectId : int;
    /** @private */
    private var m_iStatEffectType : int;

    public function CAbstractStatEffect( id : Number = NaN, statEffectId : int = 0 ) {
        super();
        if ( isNaN( id ) )
            m_nId = ++s_nIDGen;
        else
            m_nId = id;
        m_iStatEffectId = statEffectId;
    }

    final public function get id() : Number {
        return m_nId;
    }

    final public function set id( value : Number ) : void {
        m_nId = uint( value );
    }

    final public function get statEffectId() : int {
        return m_iStatEffectId;
    }

    final public function set statEffectId( value : int ) : void {
        m_iStatEffectId = int( value );
    }

    final public function get name() : String {
        return m_strName;
    }

    final public function set name( value : String ) : void {
        m_strName = value;
    }

    final public function get statEffectType() : int {
        return m_iStatEffectType;
    }

    final public function set statEffectType( value : int ) : void {
        m_iStatEffectType = value;
    }

    final public function get parent() : IStatEffectContainer {
        return m_pParent;
    }

    [Internal]
    final internal function setParent( value : IStatEffectContainer ) : void {
        if ( m_pParent == value )
            return;

        if ( m_pParent ) {
            // Prevent re-entrance.
            var temp : IStatEffectContainer = m_pParent;
            m_pParent = null;
            
            // remove from the pre parent first.
            temp.removeStatEffect( this );
        }

        this.m_pParent = value;
    }

    public function get isValid() : Boolean {
        return !(isNaN( m_nId ) || 0 == m_iStatEffectId);
    }

    [Inline]
    final public function removeFromParent() : Boolean {
        if ( this.parent ) {
            this.parent.removeStatEffect( this );
            return true;
        }
        return false;
    }

    public function update( delta : Number ) : void {

    }

}
}
