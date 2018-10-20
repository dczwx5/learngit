//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.state {

import flash.geom.Point;
import flash.net.registerClassAlias;
import flash.utils.ByteArray;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import kof.game.core.CGameComponent;

/**
 * 角色逻辑状态仪表
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterStateBoard extends CGameComponent {

    public static function setDefaultValue( pStateBoard : CCharacterStateBoard, state : int, value : * ) : void {
        if ( !pStateBoard )
            return;
        pStateBoard.m_pDefaultMap[ state ] = value;
        if( state in pStateBoard.m_pMapDictionary ) {
            var stateValue : StateMap = pStateBoard.m_pMapDictionary[ state ];
            if( stateValue )
                stateValue.setDefualtValue( value);
        }
    }

    static public const MOVING : int = 1;
    static public const MOVABLE : int = 2;
    static public const LYING : int = 3;
    static public const ON_GROUND : int = 4;

    static public const DEAD_SIGNED : int = 6;
    static public const DEAD : int = 7;

    /**
     * 4 Direction.
     * Y      1
     * X  -1     1
     *       -1
     */
    static public const DIRECTION : int = 10; // Point.
    // 对于输入的方向同步到StateBoard的Direction的许可标识
    static public const DIRECTION_PERMIT : int = 11;
    // 对于StateBoard的direction同步到IDisplay上的许可标识
    static public const DIRECTION_DISPLAY_PERMIT : int = 12;
    //base底层display许可

    static public const IN_ATTACK : int = 20;
    static public const IN_GUARD : int = 21;
    static public const IN_HURTING : int = 22;
    static public const IN_CONTROL : int = 23;
    static public const IN_CATCH : int = 24; // 被抓取

    static public const CAN_BE_ATTACK : int = 30;
    static public const CAN_BE_CATCH : int = 31;
    static public const CAN_BREAKER : int = 32;
    static public const CANOT_DRIVE : int = 33;//不能取消

    static public const PA_BODY : int = 40;

    static public const BOUNCE : int = 50;
    static public const COUNTER : int = 51; //被破招
    static public const CRITICAL_HIT : int = 52; //被暴击
    static public const CRITICAL_HIT_COUNTER : int = 53;//被暴击破招
    static public const CAN_BE_DO_MOTION : int = 55;//能被击飞
    static public const BAN_DODGE : int = 56;

    static public const LEGACY_NEED_UPDATE : int = 99;
    private var m_pDirtyMap : Dictionary;
    private var m_pValueMap : Dictionary;
    private var m_pDefaultMap : Dictionary;
    internal var m_bDirty : Boolean;
    private var m_pStackDictionary : Dictionary;
    private var m_pMapDictionary : Dictionary;

    public static const TAG_SKILL : int = 1;
    public static const TAG_AI : int = 2;

    /** Creates a new CCharacterStateBoard */
    public function CCharacterStateBoard() {
        super( "stateBoard" );
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        this.m_pDirtyMap = new Dictionary;
        this.m_pValueMap = new Dictionary;
        this.m_pDefaultMap = new Dictionary;
        this.m_pStackDictionary = new Dictionary;
        this.m_pMapDictionary = new Dictionary;

        this.m_pDefaultMap[ MOVING ] = false;
        this.m_pDefaultMap[ MOVABLE ] = true;
        this.m_pDefaultMap[ IN_ATTACK ] = false;
        this.m_pDefaultMap[ DIRECTION_PERMIT ] = true;
        this.m_pDefaultMap[ DIRECTION_DISPLAY_PERMIT ] = true;
        this.m_pDefaultMap[ DIRECTION ] = new Point( 1, 0 );
        this.m_pDefaultMap[ ON_GROUND ] = true;
        this.m_pDefaultMap[ IN_GUARD ] = false;
        this.m_pDefaultMap[ DEAD ] = false;
        this.m_pDefaultMap[ DEAD_SIGNED ] = false;
        this.m_pDefaultMap[ IN_HURTING ] = false;
        this.m_pDefaultMap[ CAN_BE_ATTACK ] = true;
        this.m_pDefaultMap[ PA_BODY ] = false;
        this.m_pDefaultMap[ CAN_BE_CATCH ] = true;
        this.m_pDefaultMap[ IN_CONTROL ] = true;
        this.m_pDefaultMap[ CAN_BREAKER ] = false;
        this.m_pDefaultMap[ CANOT_DRIVE ] = false;
        this.m_pDefaultMap[ BOUNCE ] = false;
        this.m_pDefaultMap[ LYING ] = false;
        this.m_pDefaultMap[ COUNTER ] = false;
        this.m_pDefaultMap[ CRITICAL_HIT ] = false;
        this.m_pDefaultMap[ CRITICAL_HIT_COUNTER ] = false;
        this.m_pDefaultMap[ IN_CATCH ] = false;
        this.m_pDefaultMap[ CAN_BE_DO_MOTION ] = true;
        this.m_pDefaultMap[ BAN_DODGE ] = false;
        this.m_pDefaultMap[ LEGACY_NEED_UPDATE ] = false;

        for ( var key : int in m_pDefaultMap ) {
            var stateStack : StateStack = new StateStack( m_pDefaultMap[ key ] );
            m_pStackDictionary[ key ] = stateStack;

            var stateMap : StateMap = new StateMap( m_pDefaultMap[ key ] );
            m_pMapDictionary[ key ] = stateMap;
        }

        this.resetValue( MOVING );
        this.resetValue( MOVABLE );
        this.resetValue( IN_ATTACK );
        this.resetValue( DIRECTION_PERMIT );
        this.resetValue( DIRECTION_DISPLAY_PERMIT );
        this.resetValue( DIRECTION );
        this.resetValue( ON_GROUND );
        this.resetValue( IN_GUARD );
        this.resetValue( DEAD );
        this.resetValue( DEAD_SIGNED );
        this.resetValue( IN_HURTING );
        this.resetValue( CAN_BE_ATTACK );
        this.resetValue( PA_BODY );
        this.resetValue( CAN_BE_CATCH );
        this.resetValue( IN_CONTROL );
        this.resetValue( CAN_BREAKER );
        this.resetValue( CANOT_DRIVE );
        this.resetValue( BOUNCE );
        this.resetValue( LYING );
        this.resetValue( IN_CATCH );
        this.resetValue( CAN_BE_DO_MOTION );
        this.resetValue( BAN_DODGE );
        this.resetValue( LEGACY_NEED_UPDATE );

        this.m_bDirty = false;
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        // ignore just now.
    }

    override public function dispose() : void {
        super.dispose();

        this.m_pDirtyMap = null;
        this.m_pValueMap = null;
        this.m_pStackDictionary = null;
        this.m_pStackDictionary = null;
    }

    public function getValue( key : int ) : * {
//## non stack
//        if ( key in m_pValueMap )
//            return m_pValueMap[ key ];
//        return undefined;
        /**Stack
         var stateStack : StateStack;
         if ( key in m_pStackDictionary ) {
            stateStack = m_pStackDictionary[ key ];
            if ( stateStack ) return stateStack.getValue();
        }
         */
        var stateMap : StateMap;
        if ( key in m_pMapDictionary ) {
            stateMap = m_pMapDictionary[ key ];
            if ( stateMap ) return stateMap.getValue();
        }

        return undefined;
    }

    public function setValue( key : int, value : *, tag : int = -1 ) : void {
//## non stack
//        var theOldVal : * = (key in m_pValueMap) ? m_pValueMap[ key ] : undefined;
//        if ( theOldVal == value )
//            return;
//        m_pValueMap[ key ] = value;
//        m_pDirtyMap[ key ] = true;
//        m_bDirty = true;
        /**stack
         var stateStack : StateStack;
         if ( key in m_pStackDictionary ) {
            stateStack = m_pStackDictionary[ key ];
            if ( stateStack ) {
                var theOldVal : * = stateStack.getValue();
                if ( theOldVal == value && !bForce )
                    return;

                stateStack.setValue( value );
                m_pDirtyMap[ key ] = true;
                m_bDirty = true;
            }
        }*/

        var stateStack : StateMap;
        if ( key in m_pMapDictionary ) {
            stateStack = m_pMapDictionary[ key ];
            if ( stateStack ) {
                var theOldVal : * = stateStack.getValue();
                stateStack.setValue( value, tag );
                if ( theOldVal == value )
                    return;

                m_pDirtyMap[ key ] = true;
                m_bDirty = true;
            }
        }
    }

    public function resetValue( key : int, tag : int = -1 ) : void {
        var pDefaultValue : * = m_pDefaultMap[ key ];
        var isPrimitiveType : Boolean = pDefaultValue is Boolean || pDefaultValue is Number || pDefaultValue is String;
        if ( !isPrimitiveType ) {
            var cls : Class = getDefinitionByName( getQualifiedClassName( pDefaultValue ) ) as Class;
            registerClassAlias( getQualifiedClassName( pDefaultValue ), cls );
            var ba : ByteArray = new ByteArray;
            ba.writeObject( pDefaultValue as cls );
            ba.position = 0;
            m_pValueMap[ key ] = ba.readObject() as cls;
            ba.clear();
        } else {
            m_pValueMap[ key ] = m_pDefaultMap[ key ];
        }
        /**
         var stateStack : StateStack = m_pStackDictionary[ key ];
         if ( stateStack ) {
            stateStack.resetValues();
        }*/
        var stateStack : StateMap = m_pMapDictionary[ key ];
        if ( stateStack ) {
            stateStack.resetValues( tag );
        }

        m_pDirtyMap[ key ] = true;
        m_bDirty = true;
    }

    [Inline]
    final public function isDirty( key : int ) : Boolean {
        return (key in m_pDirtyMap) && Boolean( m_pDirtyMap[ key ] );
    }

    [Inline]
    final public function clearDirty( key : int ) : void {
        if ( key in m_pDirtyMap ) {
            m_pDirtyMap[ key ] = false;
        }
    }

    final public function clearAllDirty() : void {
        for ( var k : int in m_pDirtyMap ) {
            m_pDirtyMap[ k ] = false;
        }

        m_bDirty = false;
    }

}
}

import QFLib.Foundation.CMap;

class StateStack {

    var _activeValues : Array;
    var _defaultValue : *;

    public function StateStack( defauleState : * ) : void {
        _activeValues = [];
        _defaultValue = defauleState;
    }

    public function clear() : void {
        _activeValues.splice( 0, _activeValues.length );
        _activeValues = null;
    }

    public function resetValues() : void {
        _activeValues.splice( 0, _activeValues.length );
    }

    public function setValue( value : * ) : void {
        var defaultValue : Boolean;
        var bOverride : Boolean = !( value is Boolean );
        if ( !bOverride ) {
            defaultValue = Boolean( _defaultValue );
            if ( value != defaultValue ) {
                _pushActiveValue( value );
            } else {
                _popActiveValue();
            }
        } else {
            _popActiveValue();
            _pushActiveValue( value );
        }
    }

    public function getValue() : * {
        if ( _activeValues.length > 0 )
            return _activeValues[ 0 ];
        return _defaultValue;
    }

    private function _popActiveValue() : * {
        return _activeValues.pop();
    }

    private function _pushActiveValue( value : * ) : void {
        _activeValues.push( value );
    }
}

class StateMap {
    var _activeValueMap : CMap;
    var _defaultValue : *;

    public function StateMap( defaultValue : * ) : void {
        _defaultValue = defaultValue;
        _activeValueMap = new CMap();
    }

    public function setDefualtValue( value : * ) : void{
        _defaultValue = value;
    }

    public function clear() : void {
        _activeValueMap.clear();
        _activeValueMap = null;
    }

    public function resetValues( tag : int = -1 ) : void {
        if ( tag in _activeValueMap ) {
            delete _activeValueMap[ tag ];
        }
    }

    public function setValue( value : *, tag : int = -1 ) : void {
        if ( value == _defaultValue ) {
            if ( tag in _activeValueMap ) {
                delete  _activeValueMap[ tag ];
                return;
            }
        }else {
            if( tag in _activeValueMap ) {
                if(_activeValueMap[ tag ] == value)
                    return;
            }
            _activeValueMap[ tag ] = value;
        }
    }

    public function getValue() : * {
        var ret : *;
        var bIsBoolType : Boolean = ( _defaultValue is Boolean );
        if ( bIsBoolType ) {
            for ( var key : int in _activeValueMap ) {
                ret = _activeValueMap[ key ];
                if( ret != _defaultValue ) return ret;
            }
            return _defaultValue;
        } else {
            if ( _activeValueMap[ -1 ] )
                return _activeValueMap[ -1 ];
            return _defaultValue;
        }
    }

    public function getValueByTag( tag : int = -1 ) : * {
        return tag in _activeValueMap ? _activeValueMap[ tag ] : _defaultValue;
    }
}
