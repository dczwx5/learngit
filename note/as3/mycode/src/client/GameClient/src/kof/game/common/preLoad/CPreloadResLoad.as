//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/18.
 */
package kof.game.common.preLoad {

import QFLib.Framework.CCharacter;
import QFLib.Framework.CFramework;
import QFLib.Graphics.Character.model.CEquipSkinsInfo;
import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.ArrayUtil;

import kof.data.CPreloadData;

import kof.data.KOFTableConstants;

import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.levelCommon.CLevelPath;
import kof.table.Aero;
import kof.table.Monster;
import kof.table.MonsterSkill;
import kof.table.PlayerBasic;
import kof.table.PlayerSkill;

public class CPreloadResLoad {
    // loadFinish : function (reloadData:CPreloadData, theCharacter:CCharacter) : void ;
    public static function load( reloadData : CPreloadData, frameWork : CFramework, database : IDatabase, loadFinish : Function ) : void {
        switch ( reloadData.resType ) {
            case EPreloadType.RES_TYPE_HERO :
                _loadHeroA( reloadData, frameWork, database, loadFinish );
                break;
            case EPreloadType.RES_TYPE_MONSTER :
                _loadMonsterA( reloadData, frameWork, database, loadFinish );
                break;
            case EPreloadType.RES_TYPE_SCENE_EFFECT :
                loadFinish( reloadData, null, null );
                break;
            default :
                loadFinish( reloadData, null, null );
                break;
        }
    }

    // A
    private static function _loadHeroA( reloadData : CPreloadData, frameWork : CFramework, database : IDatabase, loadFinish : Function ) : void {
        var playerTable : IDataTable = database.getTable( KOFTableConstants.PLAYER_BASIC );
        var heroID : int = (int)( reloadData.id );
        var heroRecord : PlayerBasic = playerTable.findByPrimaryKey( heroID ) as PlayerBasic;
        _loadCharacterB( heroRecord.SkinName, reloadData, frameWork, database, loadFinish );
    }
    // B
    private static function _loadCharacterB( skinName : String, reloadData : CPreloadData, frameWork : CFramework, database : IDatabase,loadFinish : Function ) : void {
        if ( skinName ) {
            // 找出子弹加载列表
            var missileList:Array = _getPlayerMissileListB( reloadData, database );
            missileList = ArrayUtil.clipSameItem(missileList, "MissleSpine");


            // 加载人物
            var model : CCharacter = new CCharacter( frameWork );
            model.enablePhysics = false;
            model.enabled = false;

            var jsonUrl : String = CLevelPath.getCharacterSkinPath( skinName );
            var characterPreloadData : PreloadCharacterData = new PreloadCharacterData();
            characterPreloadData.loadFinish = loadFinish;
            characterPreloadData.loadFinishCount = 0;
            characterPreloadData.loadTargetCount = 2 + missileList.length;
            characterPreloadData.preloadData = reloadData;
            characterPreloadData.character = model;
            characterPreloadData.isTraceInfo = true;
            model.loadFile( jsonUrl, null, null, ELoadingPriority.CRITICAL, _getOnCharacterLoadFinishC( characterPreloadData ), null, _getOnFXLoadFinishC( characterPreloadData ) );

            // 加载子弹
            for each (var missileInfo:Aero in missileList) {
                _loadMissile(missileInfo.MissleSpine, frameWork, characterPreloadData);
            }

            // 技能
        } else {
            if ( loadFinish ) loadFinish( reloadData, null, null );
        }
    }
    // ===========加载子弹
    private static function _getPlayerMissileListB( reloadData : CPreloadData, database : IDatabase ) : Array {
        var heroID : int = (int)( reloadData.id );
        var playerSkillTable : IDataTable = database.getTable( KOFTableConstants.PLAYER_SKILL );
        var playerSkills : PlayerSkill = playerSkillTable.findByPrimaryKey( heroID );
        var missileList:Array;
        if ( playerSkills && playerSkills.SkillID ) {
            missileList = _getSkillMissileListC( playerSkills.SkillID , database );
        }
        return missileList;
    }
        private static function _getSkillMissileListC( skills : Array, database : IDatabase ) : Array {
            var retList:Array = new Array();
            var skillMissileList:Array;

            if ( skills && skills.length != 0 ) {
                var missileTable : IDataTable = database.getTable( KOFTableConstants.AERO );
                for ( var i : int = 0; i < skills.length; i++ ) {
                    skillMissileList = null;
                    var skillID : int = skills[ i ];
                    if ( skillID > 0 ) {
                        skillMissileList = missileTable.findByProperty( "RootSkill", skillID );
                        if (skillMissileList) {
                            retList = retList.concat(skillMissileList);
                        }
//                        retList = ArrayUtil.mergeList(retList, skillMissileList, "MissleSpine");
                    }
                }
            }
            return retList;
        }

        private static function _loadMissile( skinName : String, frameWork : CFramework, missilePreloadData : PreloadCharacterData ) : void {
            if ( skinName ) {
                var model : CCharacter = new CCharacter( frameWork );
                model.enablePhysics = false;
                model.enabled = false;
                missilePreloadData.addMissile(model);

                var jsonUrl : String = CLevelPath.getMissileSkinPath( skinName );

                model.loadCharacterFile( CLevelPath.getMissileSpinPath() );
                model.loadCharacterGameFile( jsonUrl, ELoadingPriority.NORMAL, null, _getOnMissileFXLoadFinishF( missilePreloadData, jsonUrl ), null, true );

//                trace("加载子弹 " + jsonUrl);
            } else {
                missilePreloadData.addAndDoFinish();
            }
        }
    private static function _getOnMissileFXLoadFinishF( missilePreloadData : PreloadCharacterData, jsonUrl:String ) : Function {
        var func : Function = function ( theCharacter : CCharacter, iResult : int ) : void {
//            trace("子弹 加载完成 " + jsonUrl);
            missilePreloadData.addAndDoFinish();
        };
        return func;
    }

    // ===========monster
    // A
    private static function _loadMonsterA( reloadData : CPreloadData, frameWork : CFramework, database : IDatabase, loadFinish : Function ) : void {
        var monsterTable : IDataTable = database.getTable( KOFTableConstants.MONSTER );
        var monsterID : int = (int)( reloadData.id );
        var m : Monster = monsterTable.findByPrimaryKey( monsterID ) as Monster;
        _loadMonsterB( m, reloadData, frameWork, database, loadFinish );
    }

    private static function _loadMonsterB( m : Monster, reloadData : CPreloadData, frameWork : CFramework, database : IDatabase, loadFinish : Function ) : void {
        var skinName : String = m.OutsideName;
        if ( skinName == null || skinName.length == 0 ) {
            skinName = m.SkinName;
        }

        var skinData : CPreloadSkinData;
        if ( skinName && skinName.length > 0 ) {
            skinData = new CPreloadSkinData();
            skinData.skinName = m.SkinName;
            skinData.outSideSkin = m.OutsideName;
            skinData.weapon = m.weapon;
        }

        if ( skinData ) {
            var missileList:Array = _getMonsterMissileListB( reloadData, database );
            missileList = ArrayUtil.clipSameItem(missileList, "MissleSpine");

            var model : CCharacter = new CCharacter( frameWork );
            model.enablePhysics = false;
            model.enabled = false;

            var equipSkins : CEquipSkinsInfo = null;
            if ( skinData.weaponPath != null ) {
                equipSkins = new CEquipSkinsInfo();
                equipSkins.addEquip( 0, skinData.weaponPath );
            }
            var monsterPreloadData : PreloadCharacterData = new PreloadCharacterData();
            monsterPreloadData.loadFinish = loadFinish;
            monsterPreloadData.loadFinishCount = 0;
            monsterPreloadData.loadTargetCount = 1 + missileList.length;
            monsterPreloadData.character = model;
            monsterPreloadData.preloadData = reloadData;
            monsterPreloadData.isTraceInfo = true;
            model.loadFile( skinData.skinPath, skinData.outSideSkinPath, equipSkins, ELoadingPriority.NORMAL, _getOnCharacterLoadFinishC( monsterPreloadData ) );

            // 加载子弹
            for each (var missileInfo:Aero in missileList) {
                _loadMissile(missileInfo.MissleSpine, frameWork, monsterPreloadData);
            }

        } else {
            if ( loadFinish ) loadFinish( reloadData, null, null );
        }
    }

    private static function _getMonsterMissileListB( reloadData : CPreloadData, database : IDatabase ) : Array {
        var missileList:Array;
        var monsterID : int = (int)( reloadData.id );
        var monsterSkillTable : IDataTable = database.getTable( KOFTableConstants.MONSTER_SKILL );
        var monsterSkills : MonsterSkill = monsterSkillTable.findByPrimaryKey( monsterID );
        if( monsterSkills && monsterSkills.SkillID) {
            missileList = _getSkillMissileListC( monsterSkills.SkillID , database );
        }

        return missileList;
    }
    // C
    private static function _getOnCharacterLoadFinishC( characterPreloadData : PreloadCharacterData ) : Function {
        var func : Function = function ( theCharacter : CCharacter, iResult : int ) : void {
            characterPreloadData.addAndDoFinish();
        };
        return func;
    }

    // C
    private static function _getOnFXLoadFinishC( characterPreloadData : PreloadCharacterData ) : Function {
        var func : Function = function ( theCharacter : CCharacter, iResult : int ) : void {
            characterPreloadData.addAndDoFinish();
        };
        return func;
    }


    private static function _loadSceneEffectA( reloadData : CPreloadData, frameWork : CFramework, database : IDatabase, loadFinish : Function ) : void {

    }
}
}

import QFLib.Framework.CCharacter;
import kof.data.CPreloadData;

class PreloadCharacterData {
    public var missileModleList:Array;
    public var loadFinishCount : int;
    public var preloadData : CPreloadData;
    public var loadFinish : Function;
    public var loadTargetCount : int;
    public var character:CCharacter;
    public var isTraceInfo:Boolean;
    // preloadData:CPreloadData = null, character:CCharacter = null, 为了兼容loadFinish的调用
    public function addAndDoFinish(preloadData:CPreloadData = null, character:CCharacter = null) : void {
        loadFinishCount++;
        if (loadFinishCount >= loadTargetCount) {
            doFinish();
        }
    }
    public function doFinish() : void {
        if (loadFinish != null) {
            loadFinish(preloadData, character, missileModleList);
            if (isTraceInfo && preloadData) {
                trace("预加载完毕-------------------------------- : ID " + preloadData.id + " : resType  " + preloadData.resType);
            }
        }
    }
    public function addMissile(missile:CCharacter) : void {
        if (!missileModleList) {
            missileModleList = new Array();
        }
        missileModleList[missileModleList.length] = missile;
    }
}
