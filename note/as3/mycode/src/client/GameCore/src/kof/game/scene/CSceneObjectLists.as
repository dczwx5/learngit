//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.scene {

import QFLib.Foundation.CMap;
import QFLib.Interface.IDisposable;

import kof.game.character.CCharacterDataDescriptor;
import kof.game.core.CGameObject;
import kof.util.CAssertUtils;

/**
 * 场景对象列表，仅用于存储、查找。
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CSceneObjectLists implements IDisposable {

    public static const TYPE_PC : int = 0;
    public static const TYPE_Monsters : int = 1;
    public static const TYPE_MAP_Object : int = 2;
    public static const TYPE_NPC : int = 3;
    public static const TYPE_BUFF : int = 4;

    /** @private */
    private var m_listAll : Array;

    /** @private */
    private var m_listTypeMap : Array;

    /**
     * Creates a new CSceneObjectLists.
     */
    public function CSceneObjectLists() {
        super();

        m_listTypeMap = [
            new CMap(), // PC
            new CMap(),  // Monsters
            new CMap(),  // MapObeject
            new CMap(),  // NPC
            new CMap()
        ];

        m_listAll = [];
    }

    final public function get iterator() : Object {
        return m_listAll;
    }

    final public function getGameObject( type : int, id : Number ) : CGameObject {
        return (m_listTypeMap[ type ] as CMap).find( id ) as CGameObject;
    }

    final public function getPlayer( id : Number ) : CGameObject {
        if ( TYPE_PC in m_listTypeMap ) {
            return (m_listTypeMap[ TYPE_PC ] as CMap).find( id ) as CGameObject;
        }
        return null;
    }

    /*获取玩家列表**/
    [Inline]
    final public function getPlayerList() : Vector.<Object> {
        return m_listTypeMap[ TYPE_PC ].toVector();
    }

    [Inline]
    final public function addPlayer( id : Number, obj : CGameObject ) : void {
        m_listTypeMap[ TYPE_PC ].add( id, obj );
        m_listAll.push( obj );
    }

    [Inline]
    final public function removePlayer( id : Number ) : CGameObject {
        return this.removeObject( id, TYPE_PC );
    }

    final public function getMonster( id : Number ) : CGameObject {
        if ( TYPE_Monsters in m_listTypeMap ) {
            return (m_listTypeMap[ TYPE_Monsters ] as CMap).find( id ) as CGameObject;
        }
        return null;
    }

    final public function getMonsters() : Vector.<Object> {
        return m_listTypeMap[ TYPE_Monsters ].toVector();
    }

    [Inline]
    final public function addMonster( id : Number, obj : CGameObject ) : void {
        m_listTypeMap[ TYPE_Monsters ].add( id, obj );
        m_listAll.push( obj );
    }

    [Inline]
    final public function removeMonster( id : Number ) : CGameObject {
        return this.removeObject( id, TYPE_Monsters );
    }

    final public function getMapObject( id : Number ) : CGameObject {
        if ( TYPE_MAP_Object in m_listTypeMap ) {
            return (m_listTypeMap[ TYPE_MAP_Object ] as CMap).find( id ) as CGameObject;
        }
        return null;
    }

    final public function getMapObjects() : Vector.<Object> {
        return m_listTypeMap[ TYPE_MAP_Object ].toVector();
    }

    [Inline]
    final public function addMapObject( id : Number, obj : CGameObject ) : void {
        m_listTypeMap[ TYPE_MAP_Object ].add( id, obj );
        m_listAll.push( obj );
    }

    [Inline]
    final public function addNPC( id : Number, obj : CGameObject ) : void {
        m_listTypeMap[ TYPE_NPC ].add( id, obj );
        m_listAll.push( obj );
    }

    [Inline]
    final public function addBuff( id : Number, obj : CGameObject ) : void {
        m_listTypeMap[ TYPE_BUFF ].add( id, obj );
        m_listAll.push( obj );
    }

    [Inline]
    final public function getNPC( id : Number ) : CGameObject {
        if ( TYPE_NPC in m_listTypeMap ) {
            return (m_listTypeMap[ TYPE_NPC ] as CMap).find( id ) as CGameObject;
        }
        return null;
    }

    [Inline]
    final public function getNPCByPrototypeID( id : Number ) : CGameObject {
        var vec:Vector.<Object> = getNPCs();
        for each (var obj:Object in vec){
            if(obj.data.prototypeID == id){
                return (obj as CGameObject);
            }
        }
        return null;
    }

    final public function getNPCs() : Vector.<Object> {
        return m_listTypeMap[ TYPE_NPC ].toVector();
    }

    [Inline]
    final public function removeNPC( id : Number ) : CGameObject {
        return this.removeObject( id, TYPE_NPC );
    }

    [Inline]
    final public function removeBuff( id : Number ) : CGameObject {
        return this.removeObject( id, TYPE_BUFF );
    }

    [Inline]
    final public function removeMapObject( id : Number ) : CGameObject {
        return this.removeObject( id, TYPE_MAP_Object );
    }

    [Inline]
    final public function removeObject( id : Number, type : int ) : CGameObject {
        var map : CMap = m_listTypeMap[ type ];
        if ( map ) {
            var ret : * = map.find( id );
            map.remove( id );
            if ( ret ) {
                var idx : int = m_listAll.indexOf( ret );
                if ( idx != -1 )
                    m_listAll.splice( idx, 1 );
            }
            return ret as CGameObject;
        }
        return null;
    }

    public function clear() : void {
        if ( m_listTypeMap ) {
            for each ( var m : CMap in m_listTypeMap ) {
                if ( m ) {
                    m.clear();
                }
            }

            for each ( m in m_listTypeMap ) {
                CAssertUtils.assertEquals( 0, m.length );
            }
        }

        if ( m_listAll ) {
            m_listAll.splice( 0, m_listAll.length );
        }
    }

    public function dispose() : void {
        this.clear();
        m_listTypeMap = null;
        m_listAll = null;
    }

    public function getGroupedList( idGroup : int ) : Vector.<CGameObject> {
        var ret : Vector.<CGameObject> = null;
        var it : Object = this.getPlayerList();
        if ( it ) {
            for each ( var ply : CGameObject in it ) {
                if ( !ply )
                    continue;
                var iOperateSide : int = CCharacterDataDescriptor.getOperateSide( ply.data );
                if ( iOperateSide == idGroup ) {
                    if ( !ret )
                        ret = new <CGameObject>[];
                    ret.push( ply );
                }
            }
        }

        if ( ret && ret.length ) {
            ret.sort( function ( o1 : CGameObject, o2 : CGameObject ) : int {
                var idx1 : int = CCharacterDataDescriptor.getID( o1.data );
                var idx2 : int = CCharacterDataDescriptor.getID( o2.data );
                if ( idx1 < idx2 )
                    return -1;
                else if ( idx1 > idx2 )
                    return 1;
                return 0;
            } );
        }

        return ret;
    }

    public function getOwnHeroList() : Vector.<CGameObject> {
        return this.getGroupedList( 1 );
    }

}
}

