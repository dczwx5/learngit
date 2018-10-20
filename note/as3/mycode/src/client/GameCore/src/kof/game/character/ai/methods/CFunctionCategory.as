//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/1/17.
 * Time: 12:14
 */
package kof.game.character.ai.methods {

    import QFLib.Framework.CObject;
    import QFLib.Graphics.RenderCore.starling.display.DisplayObject;
    import QFLib.Graphics.RenderCore.starling.display.Quad;
    import QFLib.Math.CVector2;
    import QFLib.Math.CVector3;

    import flash.geom.Point;
    import flash.geom.Rectangle;

    import kof.game.character.CCharacterDataDescriptor;
    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAIHandler;
    import kof.game.character.ai.paramsTypeEnum.EBaseOnRole;
    import kof.game.character.ai.paramsTypeEnum.ECampType;
    import kof.game.character.ai.paramsTypeEnum.EPropertyFilterCondtions;
    import kof.game.character.ai.paramsTypeEnum.ERoleType;
    import kof.game.character.animation.IAnimation;
    import kof.game.character.display.CBaseDisplay;
import kof.game.character.fight.CTargetCriteriaComponet;
import kof.game.character.level.CLevelMediator;
    import kof.game.character.property.CMonsterProperty;
    import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.core.CGameObject;
    import kof.game.scene.CSceneSystem;
    import kof.table.Monster.EMonsterType;

    public class CFunctionCategory {
        private var handler : CAIHandler = null;

        public function CFunctionCategory( handler : CAIHandler ) {
            this.handler = handler;
        }

        /**返回玩家*/
        public final function getPlayer( aiOwnerObj : CGameObject ) : CGameObject {
            var playerList : Vector.<Object> = (handler.system.stage.getSystem( CSceneSystem ) as CSceneSystem).findAllPlayer();
            for each( var obj : Object in playerList ) {
                var tempObj : CGameObject = obj as CGameObject;
                if ( this.handler.isHero( tempObj ) ) {
                    return tempObj;
                }
            }
            return null;
        }

        public final function findAttackableByCriteriaId( owner : CGameObject, criteriaId : int) : CGameObject{
            var targetList : Object = _sceneAllFilter();
            var filterList : Array;
            var pCriteriaComp : CTargetCriteriaComponet = owner.getComponentByClass( CTargetCriteriaComponet , true ) as CTargetCriteriaComponet;
            if( pCriteriaComp ) {
                 filterList = pCriteriaComp.getTargetPerCriteriaID( targetList as Array , criteriaId );
            }

            if( filterList != null && filterList.length > 0)
                return filterList[ 0 ];

            return null;
        }

        /**获取AI可以攻击的对象*/
        public final function findAttackable( owner : CGameObject, campType : String, roleType : String, filterCondtion : String, baseOnRole : String, campID : String, serialID : String ) : CGameObject {
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            var _campID : int = int( campID );
            var _serialID : int = int( serialID );
            if ( _campID != -1 ) {
                return this.filterCampID( _campID, owner );
            }
            if ( _serialID != -1 ) {
                return this.filterSerialID( _serialID, owner );
            }
            if ( baseOnRole == EBaseOnRole.SELF ) {
                return this.filterProperty( filterCondtion, campType, roleType, owner );
            }
            else if ( baseOnRole == EBaseOnRole.ENEMYBOSS ) {
                var gameObjVec : Vector.<CGameObject> = this.filterCamp( campType, owner );
                var obj : CGameObject = null;
                for each( obj in gameObjVec ) {
                    if ( CCharacterDataDescriptor.isMonster( obj.data ) ) {
                        var pFacadeProperty : CMonsterProperty = obj.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
                        if ( pFacadeProperty.monsterType == EMonsterType.BOSS || pFacadeProperty.monsterType == EMonsterType.WORLD_BOSS ) {
                            return this.filterProperty( filterCondtion, campType, roleType, obj );
                        }
                    }
                }
            }
            else if ( baseOnRole == EBaseOnRole.MASTER ) {
                return this.filterProperty( filterCondtion, campType, roleType, pAIComponent.currentMaster );
            }
            else if ( baseOnRole == EBaseOnRole.Target ) {
                return this.filterProperty( filterCondtion, campType, roleType, pAIComponent.currentAttackable );
            }
            return null;
        }

        private var isFirst : Boolean = true;

        /**
         * 是否触发警戒范围
         *
         * @return true触发警戒，false没有触发
         *
         *
         * */
        public final function isTriggerWarnRange( owner : CGameObject, warnObj : Object ) : Boolean {
            var frontFaceNu : Object = warnObj.frontDistance;
            var backFaceNu : Object = warnObj.backDistance;
            var direction : int = (owner.getComponentByClass( CBaseDisplay, true ) as CBaseDisplay).direction;
            CONFIG::debug{
                var bool : Boolean = (owner.getComponentByClass( CAIComponent, true ) as CAIComponent).isDrawWarningRange;
                if ( bool ) {
                    (owner.getComponentByClass( IAnimation, true ) as IAnimation).showQuaq( graphicsWarnRect( new Rectangle( 0, 0, frontFaceNu.x, frontFaceNu.y * 0.4 ) ), true );
                    (owner.getComponentByClass( CAIComponent, true ) as CAIComponent).isDrawWarningRange = false;
                }
            }

            var all : Object = (handler.system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
            if ( !all ) {
                return null;
            }

            var objPos2D : CVector3 = new CVector3();
            var ownerPos2D : CVector3 = new CVector3();

            CObject.get2DPositionFrom3D( owner.transform.x, owner.transform.z, owner.transform.y, ownerPos2D );

            for each( var obj : CGameObject in all ) {
                if ( !obj.isRunning || handler.isDead( obj ) || obj == owner )
                    continue;
                var levelMediator : CLevelMediator = owner.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
                if ( levelMediator.isAttackable( obj ) ) {
                    CObject.get2DPositionFrom3D( obj.transform.x, obj.transform.z, obj.transform.y, objPos2D );
                    var zfRange : Number = (frontFaceNu.y) >> 1;
                    var zbRange : Number = (backFaceNu.y) >> 1;
                    if ( direction > 0 ) {
                        if ( (objPos2D.x > ownerPos2D.x - backFaceNu.x && objPos2D.x < ownerPos2D.x
                                && objPos2D.y < ownerPos2D.y + zbRange && objPos2D.y > ownerPos2D.y - zbRange)
                                || (objPos2D.x < ownerPos2D.x + frontFaceNu.x && objPos2D.x > ownerPos2D.x
                                && objPos2D.y < ownerPos2D.y + zfRange && objPos2D.y > ownerPos2D.y - zfRange) ) {
                            return true
                        }
                    }
                    else {
                        if ( (objPos2D.x > ownerPos2D.x - frontFaceNu.x && objPos2D.x < ownerPos2D.x
                                && objPos2D.y < ownerPos2D.y + zfRange && objPos2D.y > ownerPos2D.y - zfRange)
                                || (objPos2D.x < ownerPos2D.x + backFaceNu.x && objPos2D.x > ownerPos2D.x
                                && objPos2D.y < ownerPos2D.y + zbRange && objPos2D.y > ownerPos2D.y - zbRange) ) {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        private final function graphicsWarnRect( warnRect : Rectangle ) : DisplayObject {
            var quad : Quad = new Quad( warnRect.width, warnRect.height, 0 );
            quad.x = 0;
            quad.y = -warnRect.height >> 1;
            quad.alpha = 0.5;
            return quad;
        }

        /**
         *按场景中角色序号筛选
         *
         * 获取指定角色序号距离最近的目标
         **/
        public final function filterSerialID( serialID : int, gameObj : CGameObject ) : CGameObject {
            var gameObjVec : Vector.<CGameObject> = new Vector.<CGameObject>();
            var all : Object = _sceneAllFilter();//(handler.system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
            if ( !all )return null;
            var obj : CGameObject = null;
            for each ( obj  in all ) {
                if ( !obj.isRunning || handler.isDead( obj ) )
                    continue;
                var id : int = CCharacterDataDescriptor.getID( obj.data );
                if ( serialID == id ) {
                    return obj;
                }
            }
            return null;
        }

        /**
         *按阵营ID筛选
         * 获取指定阵营ID的对象
         **/
        public final function filterCampID( campID : int, gameObj : CGameObject ) : CGameObject {
            var all : Object = _sceneAllFilter(); //(handler.system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
            if ( !all )return null;
            var obj : CGameObject = null;
            for each ( obj  in all ) {
                if ( !obj.isRunning || handler.isDead( obj ) )
                    continue;
                var id : int = CCharacterDataDescriptor.getCampID( obj.data );
                if ( campID == id ) {
                    return obj;
                }
            }
            return null;
        }

        public function _sceneAllFilter() : Object{
            var all : Object = (handler.system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
            var ret : Object = all.filter( function f(obj : CGameObject , index : int , arr : Array): Boolean{
                 return obj.isRunning &&
                         !isAiIgnoreTarget( obj ) &&
                         !CCharacterDataDescriptor.isBuff( obj.data )&&
                         !CCharacterDataDescriptor.isMissile( obj.data );
            });

            return ret;
        }


        private function isAiIgnoreTarget(obj :  CGameObject ) : Boolean{
            var pMonsterProperty : CMonsterProperty = obj.getComponentByClass( CMonsterProperty , true ) as CMonsterProperty;
            if( pMonsterProperty != null && CCharacterDataDescriptor.isMonster( obj.data )) {
                return pMonsterProperty.BeTargeted == 0;
            }
            return false;
        }
        /**按阵营筛选
         *
         * 取出当前场景的全部gameObj，再按阵营筛选
         *
         * */
        public final function filterCamp( type : String, gameObj : CGameObject ) : Vector.<CGameObject> {
            var gameObjVec : Vector.<CGameObject> = new Vector.<CGameObject>();
            var all : Object = _sceneAllFilter();//(handler.system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
            if ( !all )return null;
            var obj : CGameObject = null;

            //敌方阵营
            if ( type == ECampType.ENEMY ) {
                for each ( obj  in all ) {
                    var isIgnore : Boolean = isAiIgnoreTarget( obj );

                    if ( !obj.isRunning || handler.isDead( obj ) || CCharacterDataDescriptor.getID( obj.data ) == CCharacterDataDescriptor.getID( gameObj.data ) || isIgnore )
                        continue;
                    var isAttackableObj : CLevelMediator = gameObj.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
                    if ( isAttackableObj.isAttackable( obj ) ) {
                        gameObjVec.push( obj );
                    }
                }
                return gameObjVec;
            }
            else if ( type == ECampType.FRIENDY || type == ECampType.NEUTRALUNITS )//目前把中立也算在友方
            {
                for each ( obj in all ) {
                    if ( !obj.isRunning || handler.isDead( obj ) )
                        continue;
                    var isFriendlyObj : CLevelMediator = gameObj.getComponentByClass( CLevelMediator, true ) as CLevelMediator;
                    if ( isFriendlyObj.isFriendly( obj ) ) {
                        gameObjVec.push( obj );
                    }
                }
                return gameObjVec;
            }
            else if ( type == ECampType.ALL )//全阵营
            {
                for each ( obj in all ) {
                    if ( !obj.isRunning || handler.isDead( obj ) )
                        continue;
                    gameObjVec.push( obj );
                }
                return gameObjVec;
            }
            return null;
        }

        /**筛选角色
         *
         * 内部逻辑：
         * 拿到阵营筛选的结果，再进行角色类型筛选
         *
         * */
        public final function filterRole( campType : String, roleType : String, gameObj : CGameObject ) : Vector.<CGameObject> {
            //筛选阵营
            var campObjVec : Vector.<CGameObject> = this.filterCamp( campType, gameObj );
            var gameObjVec : Vector.<CGameObject> = new Vector.<CGameObject>();
            var obj : CGameObject = null;
            if ( roleType == ERoleType.BOSS )//boss
            {
                _findBoss( campObjVec, gameObjVec );
                return gameObjVec;
            }
            else if ( roleType == ERoleType.ELITE )//精英
            {
                _findElite( campObjVec, gameObjVec );
                return gameObjVec;
            }
            else if ( roleType == ERoleType.SOLDIER )//小怪
            {
                _findSoldier( campObjVec, gameObjVec );
                return gameObjVec;
            }
            else if ( roleType == ERoleType.PLAYER )//玩家
            {
                for each ( obj  in campObjVec ) {
                    if ( !obj.isRunning || handler.isDead( obj ) )
                        continue;
                    if ( CCharacterDataDescriptor.isPlayer( obj.data ) ) {
                        gameObjVec.push( obj );
                    }
                }
                return gameObjVec;
            }
            else if ( roleType == ERoleType.ALL )//全角色
            {
                return campObjVec;
            }
            else if ( roleType == ERoleType.BOSS_TO_SOLDIER )//boss到小怪
            {
                _findBoss( campObjVec, gameObjVec );
                if ( gameObjVec.length > 0 ) {
                    return gameObjVec;
                } else {
                    _findElite( campObjVec, gameObjVec );
                    if ( gameObjVec.length > 0 ) {
                        return gameObjVec;
                    } else {
                        _findSoldier( campObjVec, gameObjVec );
                        return gameObjVec;
                    }
                }
            }
            return null;
        }

        private function _findBoss( campObjVec : Vector.<CGameObject>, gameObjVec : Vector.<CGameObject> ) : Vector.<CGameObject> {
            var obj : CGameObject = null;
            for each ( obj  in campObjVec ) {
                if ( !obj.isRunning || handler.isDead( obj ) )
                    continue;
                if ( CCharacterDataDescriptor.isMonster( obj.data ) ) {
                    var pFacadeProperty : CMonsterProperty = obj.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
                    if ( pFacadeProperty.monsterType == EMonsterType.BOSS || pFacadeProperty.monsterType == EMonsterType.WORLD_BOSS ) {
                        gameObjVec.push( obj );
                    }
                }
            }
            return gameObjVec;
        }

        private function _findElite( campObjVec : Vector.<CGameObject>, gameObjVec : Vector.<CGameObject> ) : Vector.<CGameObject> {
            var obj : CGameObject = null;
            for each ( obj  in campObjVec ) {
                if ( !obj.isRunning || handler.isDead( obj ) )
                    continue;
                if ( CCharacterDataDescriptor.isMonster( obj.data ) ) {
                    var pFacadeProperty : CMonsterProperty = obj.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
                    if ( pFacadeProperty.monsterType == EMonsterType.UNIQUE ) {
                        gameObjVec.push( obj );
                    }
                }
            }
            return gameObjVec;
        }

        private function _findSoldier( campObjVec : Vector.<CGameObject>, gameObjVec : Vector.<CGameObject> ) : Vector.<CGameObject> {
            var obj : CGameObject = null;
            for each ( obj  in campObjVec ) {
                if ( !obj.isRunning || handler.isDead( obj ) )
                    continue;
                if ( CCharacterDataDescriptor.isMonster( obj.data ) ) {
                    var pFacadeProperty : CMonsterProperty = obj.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
                    if ( pFacadeProperty.monsterType == EMonsterType.NORMAL ) {
                        gameObjVec.push( obj );
                    }
                }
            }
            return gameObjVec;
        }

        /**按属性筛选
         *
         * 内部逻辑：
         *  拿到角色筛选的结果，再按属性筛选
         *
         * */
        public final function filterProperty( type : String, campType : String, roleType : String, gameObj : CGameObject ) : CGameObject {
            var roleVec : Vector.<CGameObject> = this.filterRole( campType, roleType, gameObj );
            var obj : CGameObject = null;
            var curObj : CGameObject = null;
            var pFacadeProperty : ICharacterProperty = null;
            if ( type == EPropertyFilterCondtions.SHORT_DISTANCE )//距离最短
            {
                var dis : Number = 0;
                var curDis : Number = Number.MAX_VALUE;
                for each ( obj  in roleVec ) {
                    if ( !obj.isRunning || handler.isDead( obj ) )
                        continue;
                    dis = Math.abs( obj.transform.x - gameObj.transform.x );
                    if ( curDis > dis ) {
                        curDis = dis;
                        curObj = obj;
                    }
                }
                return curObj;
            }
            else if ( type == EPropertyFilterCondtions.HIGH_ATTACK )//攻击最高
            {
                var attack : Number = 0;
                var curAttack : Number = Number.MIN_VALUE;
                for each ( obj  in roleVec ) {
                    if ( !obj.isRunning || handler.isDead( obj ) )
                        continue;
                    pFacadeProperty = obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                    attack = pFacadeProperty.AttackPower;
                    if ( curAttack <= attack ) {
                        curAttack = attack;
                        curObj = obj;
                    }
                }
                return curObj;
            }
            else if ( type == EPropertyFilterCondtions.LEAST_LIFE )//生命值最低
            {
                var life : Number = 0;
                var curLife : Number = Number.MAX_VALUE;
                for each ( obj  in roleVec ) {
                    if ( !obj.isRunning || handler.isDead( obj ) )
                        continue;
                    pFacadeProperty = obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                    life = pFacadeProperty.HP;
                    if ( curLife > life ) {
                        curLife = life;
                        curObj = obj;
                    }
                }
                return curObj;
            }
            else if ( type == EPropertyFilterCondtions.LOWEST_DEFENSE )//防御最低
            {
                var defense : Number = 0;
                var curDefense : Number = Number.MAX_VALUE;
                for each ( obj  in roleVec ) {
                    if ( !obj.isRunning || handler.isDead( obj ) )
                        continue;
                    pFacadeProperty = obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                    defense = pFacadeProperty.DefensePower;
                    if ( curDefense > defense ) {
                        curDefense = defense;
                        curObj = obj;
                    }
                }
                return curObj;
            }
            else if ( type == EPropertyFilterCondtions.HIGH_HATRED )//仇恨最高
            {

            }
            return null;
        }

        public function findTeamate() : Vector.<CGameObject> {
            var all : Object = _sceneAllFilter();//(handler.system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
            var gameObjVec : Vector.<CGameObject> = new <CGameObject>[];
            if ( !all )return null;
            var obj : CGameObject = null;
            for each ( obj  in all ) {
                if ( !obj.isRunning || handler.isDead( obj ) )
                    continue;
                if ( CCharacterDataDescriptor.isTeammate( obj.data ) ) {
                    gameObjVec.push( obj );
                }
            }
            return gameObjVec;
        }
    }
}
