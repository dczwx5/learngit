//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character {

import QFLib.Framework.CFramework;
import QFLib.Interface.IDisposable;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.core.CGameObject;
import kof.table.MapObject;
import kof.table.MapObjectSkill;
import kof.util.CAssertUtils;

/**
 * 基于CharacterBuilder之上构建MapObject的GameObject结构
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CMapObjectBuilder implements IDisposable {

    private var m_pCharacterBuilder : CCharacterBuilder;

    public function CMapObjectBuilder( pCharacterBuilder : CCharacterBuilder = null ) {
        m_pCharacterBuilder = pCharacterBuilder;
    }

    public function dispose() : void {
        m_pCharacterBuilder = null;
    }

    final public function get characterBuilder() : CCharacterBuilder {
        return m_pCharacterBuilder;
    }

    final public function set characterBuilder( value : CCharacterBuilder ) : void {
        m_pCharacterBuilder = value;
    }

    final public function get database() : IDatabase {
        return this.characterBuilder.database;
    }

    final public function get graphicFramework() : CFramework {
        return this.characterBuilder.graphicsFramework;
    }

    /**
     * Build the specific <code>obj</code>:CGameObject as a MapObject.
     *
     * @param obj the specific obj to build.
     * @return true if built successfully, false otherwise.
     */
    public function build( obj : CGameObject ) : Boolean {
        if ( !CCharacterDataDescriptor.isMapObject( obj.data ) ) {
            // isn't a valid mapobject data.
            CCharacterBuilder.LOG.logErrorMsg( "The specific data of CGameObject hasn't a legal data structure!" );
            return false;
        }

        CAssertUtils.assertNotNull( this.characterBuilder, "A CCharacterBuilder is required by CMapObjectBuilder." );

        // Building the base components specify for Character.
        var ret : Boolean = true;

        ret = ret && this.buildProperties( obj );
        ret = ret && this.buildBasic( obj );
        ret = ret && this.buildInput( obj );
        ret = ret && this.buildState( obj );
        ret = ret && this.buildSkill( obj );
        ret = ret && this.buildRendering( obj );
        ret = ret && this.buildAnimation( obj );
        ret = ret && this.buildOther( obj );
        ret = ret && this.buildNetworking( obj );

        return ret;
    }

    protected function buildProperties( obj : CGameObject ) : Boolean {
        // Nothing specific
        return true;
    }

    protected function buildBasic( obj : CGameObject ) : Boolean {
        this.characterBuilder.addBaseComponents( obj );
        this.characterBuilder.buildEventSupported( obj );
        return true;
    }

    protected function buildState( obj : CGameObject ) : Boolean {
        // Nothing specific
        this.characterBuilder.buildStateSupported( obj );
        return true;
    }

    protected function buildSkill( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildSkillSupported( obj );

        // Retrieves a skillList from the table "MapObjectSkill".
        var pTableMapObjectSkill : IDataTable = this.database.getTable( KOFTableConstants.MAP_OBJECT_SKILL );

        CAssertUtils.assertNotNull( pTableMapObjectSkill, "DataTable \"MapObject\" required from CMapObjectBuilder." );

        var prototypeID : int = CCharacterDataDescriptor.getPrototypeID( obj.data );
        CAssertUtils.assertNotEquals( 0, prototypeID, "A MapObject's data has illegal prototypeID." );

        var pMapObjectSkill : MapObjectSkill = pTableMapObjectSkill.findByPrimaryKey( prototypeID );
        if ( pMapObjectSkill ) {
            var pSkillList : CSkillList = obj.getComponentByClass( CSkillList, false ) as CSkillList;
            if ( pSkillList ) {
                var i : int = 0, l : int = pMapObjectSkill.SkillID.length;
                for ( ; i < l; ++i ) {
                    var nSkillID : int = int( pMapObjectSkill.SkillID[ i ] );
                    if ( nSkillID == 0 )
                        continue;

                    pSkillList.setSkillIDByIndex( i, nSkillID );
                }
            }
        }

        return true;
    }

    public function updateSkin( obj : CGameObject, bForced : Boolean = true ) : Boolean {
        var ret : Boolean = false;
        // Determines the skin in the obj.
        var sSkinName : String = CCharacterDataDescriptor.getSkinName( obj.data );
        if ( bForced || !sSkinName || sSkinName.length == 0 ) {
            // doesn't contains a valid skin, query the configure skin in the database.
            const pTable : IDataTable = this.database.getTable( KOFTableConstants.MAP_OBJECT );
            if ( pTable ) {
                var iMapObjectID : int = CCharacterDataDescriptor.getPrototypeID( obj.data );
                CAssertUtils.assertNotEquals( 0, iMapObjectID, "A MapObject's data has  illegal prototypeID." );

                var pMapObjectObject : MapObject = pTable.findByPrimaryKey( iMapObjectID ) as MapObject;
                if ( pMapObjectObject ) {
                    sSkinName = pMapObjectObject.SkinName;
                    ret = true;
                }
            }
        }

        CAssertUtils.assertTrue( sSkinName && sSkinName.length > 0, "Builing a MapObject hadn't a valid skin, will can't be rendering correctly." );
        CCharacterDataDescriptor.setSkinName( obj.data, sSkinName );

        return ret;
    }

    protected function buildRendering( obj : CGameObject ) : Boolean {
        this.updateSkin( obj );
        this.characterBuilder.buildRenderingSupported( obj );

        return true;
    }

    protected function buildAnimation( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildPhysicalSupported( obj );

        /**
        var pTableActionSeq : IDataTable = this.database.getTable( KOFTableConstants.ACTION_SEQ );
        CAssertUtils.assertNotNull( pTableActionSeq, "DataTable \"ActionSeq\" required from CMapObjectBuilder." );

        // Resolves the "ActionSeq", make an unconflict animation list.
        var pSkillList : CSkillList = obj.getComponentByClass( CSkillList, false ) as CSkillList;
        var pAnimation : IAnimation = obj.getComponentByClass( IAnimation, false ) as IAnimation;

        for ( var i : int = 0, l : int = pSkillList.size; i < l; ++i ) {
            var nSkillID : int = pSkillList.getSkillIDByIndex( i );
            if ( 0 == nSkillID )
                continue;

            var pActionSeq : ActionSeq = pTableActionSeq.findByPrimaryKey( nSkillID );
            // FIXME: Log warning needed?
            if ( !pActionSeq )
                continue;

            for each ( var sAnimationName : String in pActionSeq.AnimationName ) {
                if ( !sAnimationName || !sAnimationName.length )
                    continue;
                sAnimationName = StringUtil.trim( sAnimationName );
                if ( !sAnimationName.length )
                    continue;
                pAnimation.addSkillAnimationState( sAnimationName.toUpperCase(), sAnimationName );
            }
        }*/

        return true;
    }

    protected function buildInput( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildInputSupported( obj );
        return true;
    }

    protected function buildOther( obj : CGameObject ) : Boolean {
        this.characterBuilder.buildOtherSupported( obj );
        return true;
    }

    protected function buildNetworking( obj : CGameObject ) : Boolean {
        // this.characterBuilder.buildNetworkingSupported( obj );
        return true;
    }

} // class CMapObjectBuilder

} // package kof.game.character

// vim:ft=as3 tw=120
