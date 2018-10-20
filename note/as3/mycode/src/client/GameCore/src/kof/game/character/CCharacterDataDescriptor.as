//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import avmplus.HIDE_OBJECT;

/**
 * 用于描述CGameObject的data数据的部分数据的作用性
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterDataDescriptor {

    public static const TYPE_PLAYER : int = 1;
    public static const TYPE_MONSTER : int = 2;
    public static const TYPE_MAP_OBJECT : int = 3;
    public static const TYPE_NPC : int = 4;
    public static const TYPE_BUFF : int = 5;
    public static const TYPE_MISSILE : int = 6;

    public static const TYPE_STANDBY : int = 100;

    /* @private */
    public function CCharacterDataDescriptor() {
        super();
    }

    static public function isCharacterData( data : Object, strict : Boolean = false ) : Boolean {
        // Verity data structure.
        var bStructureSupported : Boolean = false;

        if ( data && ('type' in data || data.hasOwnProperty( 'type' )) ) {
            bStructureSupported = strict ? ( data.type is Number ) : true;
        }

        if ( bStructureSupported && ('id' in data || data.hasOwnProperty( 'id' )) ) {
            bStructureSupported = strict ? (data.id is Number ) : true;
        }

        return bStructureSupported;
    }

    static public function getType( data : Object ) : int {
        if ( isCharacterData( data ) ) {
            return int( data.type );
        }
        return 0;
    }

    static public function isMonster( data : Object ) : Boolean {
        return TYPE_MONSTER == getType( data );
    }

    static public function isPlayer( data : Object ) : Boolean {
        return TYPE_PLAYER == getType( data );
    }

    static public function isMapObject( data : Object ) : Boolean {
        return TYPE_MAP_OBJECT == getType( data );
    }

    static public function isNPC( data : Object ) : Boolean {
        return TYPE_NPC == getType( data );
    }

    static public function isStandby( data : Object ) : Boolean {
        return TYPE_STANDBY == getType( data );
    }

    static public function isBuff( data : Object ) : Boolean {
        return TYPE_BUFF == getType( data );
    }

    static public function isMissile( data : Object ) : Boolean {
        return TYPE_MISSILE == getType( data );
    }

    static public function isHero( data : Object ) : Boolean {
        var ret : Boolean = isPlayer( data );
        ret = ret && getOperateSide( data ) == 1; // 1为玩家
        ret = ret && getOperateIndex( data ) == 1; // 1为当前所控制
        return ret;
    }

    static public function getRobot( data : Object ) : Boolean {
        if ( isCharacterData( data ) ) {
            return Boolean( data.isRobot );
        }

        return false;
    }

    static public function isRobot( data : Object ) : Boolean {
        var ret : Boolean = isPlayer( data );
        ret = ret && getRobot( data );
        return ret;
    }

    static public function isSummoned( data : Object ) : Boolean{
        if( data && data.hasOwnProperty("isSummoned"))
                return int( data.isSummoned);
        return false;
    }

    static public function isTeammate( data : Object ) : Boolean {
        var ret : Boolean = isPlayer( data );
        ret = ret && getOperateSide( data ) == 1;
        ret = ret && getOperateIndex( data ) != 1;
        return ret;
    }

    static public function getOperateSide( data : Object ) : int {
        if ( data && data.hasOwnProperty( 'operateSide' ) ) {
            return int( data.operateSide );
        }
        return 0;
    }

    static public function getOperateIndex( data : Object ) : int {
        if ( data && data.hasOwnProperty( 'operateIndex' ) ) {
            return int( data.operateIndex );
        }
        return 0;
    }

    /**
     * Retrieves the ID number from the specific <code>data</code> by the legal Character data structure.
     *
     * @param data The specific data op from.
     * @return the ID number from the data, NaN if data hadn't a legal structure. */
    static public function getID( data : Object ) : Number {
        if ( isCharacterData( data ) ) {
            return Number( data.id );
        }
        return NaN;
    }

    static public function getRoleID( data : Object ) : Number{
        if( isCharacterData( data ))
                return Number( data.roleID );

        return NaN;
    }

    /**
     * Retrieves the prototype ID number from the specific <code>data</code> by the legal
     * character data structure.
     */
    static public function getPrototypeID( data : Object ) : uint {
        if ( isCharacterData( data ) ) {
            return uint( data.prototypeID );
        }
        return 0;
    }

    static public function setPrototypeID( data : Object, value : uint ) : void {
        if ( isCharacterData( data ) ) {
            data.prototypeID = value;
        }
    }

    static public function getSkinName( data : Object ) : String {
        if ( isCharacterData( data ) ) {
            return ('skin' in data) ? data.skin as String : null;
        }
        return null;
    }

    static public function setSkinName( data : Object, value : String ) : void {
        if ( isCharacterData( data ) )
            data.skin = value;
    }

    public static function getNickName( data : Object ) : String {
        if ( isCharacterData( data ) )
            return ('name' in data) ? data.name as String : null;
        return null;
    }

    static public function setNickName( data : Object, value : String ) : void {
        if ( isCharacterData( data ) )
            data.name = value;
    }

    public static function getAppellation( data : Object ) : String {
        if ( isCharacterData( data ) )
            return ('appellation' in data) ? data.appellation as String : null;
        return null;
    }

    static public function setAppellation( data : Object, value : String ) : void {
        if ( isCharacterData( data ) )
            data.appellation = value;
    }

    public static function getProfession( data : Object ) : int {
        if ( isCharacterData( data ) )
            return ('profession' in data) ? int( data.profession ) : 0;
        return 0;
    }

    static public function setProfession( data : Object, value : int ) : void {
        if ( isCharacterData( data ) )
            data.profession = value;
    }

    static public function getMoveSpeed( data : Object ) : uint {
        if ( isCharacterData( data ) )
            return 'moveSpeed' in data ? int( data.moveSpeed ) : 0;
        return 0;
    }

    static public function setMoveSpeed( data : Object, value : int ) : void {
        if ( isCharacterData( data ) )
            data.moveSpeed = value;
    }

    static public function getHP( data : Object ) : uint {
        if ( isCharacterData( data ) )
            return 'hp' in data ? uint( data.hp ) : 0;
        return 0;
    }

    static public function setHP( data : Object, value : uint ) : void {
        if ( isCharacterData( data ) )
            data.hp = value;
    }

    static public function getAIID( data : Object ) : int {
        if ( isCharacterData( data ) )
            return 'aiID' in data ? int( data.aiID ) : 0;
        return 0;
    }

    static public function getEntityID( data : Object ) : int {
        if ( isCharacterData( data ) )
            return "entityID" in data ? int( data.entityID ) : 0;
        return 0;
    }

    static public function setAIID( data : Object, value : int ) : void {
        if ( isCharacterData( data ) )
            data.aiID = value;
    }

    static public function getCampID( data : Object ) : int {
        if ( isCharacterData( data ) )
            return 'campID' in data ? int( data.campID ) : 0;
        return 0;
    }

    static public function setCampID( data : Object, value : int ) : void {
        if ( isCharacterData( data ) )
            data.campID = value;
    }

    static public function getPlatformInfo( data : Object ) : String{
        if( isCharacterData( data ))
        {
            if( data.tx && data.tx.pf )
                    return data.tx.pf;
        }
        return "";
    }

    static public function getSimpleDes( data : Object ) : String {
        return "protoID : " + getPrototypeID( data ) + " NickName : " + getNickName( data ) + "(" + getSkinName( data ) + ")";
    }

} // class CCharacterDataDescriptor

}

// vim:ft=as3 tw=120
