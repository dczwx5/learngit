//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/1/17.
 * Time: 10:46
 */
package kof.game.character.ai.methods {

    import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Math.CVector2;
    import QFLib.Math.CVector3;

    import flash.geom.Point;

    import kof.game.character.CCharacterDataDescriptor;
    import kof.game.character.CFacadeMediator;
    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAIHandler;
    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.actions.CMoveToAction;
    import kof.game.character.ai.paramsTypeEnum.EFleeType;
    import kof.game.character.ai.paramsTypeEnum.ERoleType;
import kof.game.character.display.IDisplay;
import kof.game.character.property.CMonsterProperty;
    import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.core.CGameObject;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
    import kof.table.Monster.EMonsterType;

import spine.Bone;

public class CMoveCategory {
        private var handler : CAIHandler = null;

        public function CMoveCategory( handler : CAIHandler ) {
            this.handler = handler;
        }

        /**引怪*/
        public function moveAttractMonster( owner : CGameObject, ptArr : Array, offsetX : Number, offsetY : Number, moveEndCallBack : Function ) : Boolean {
            var pFacadeMediator : CFacadeMediator = handler.getFacadeMediator( owner );
            if ( ptArr && ptArr.length > 0 ) {
                var vec : Vector.<CVector2> = new Vector.<CVector2>();
                for ( var i : int = 0; i < ptArr.length; i++ ) {
                    vec.push( new CVector2( int( ptArr[ i ].x + offsetX ), int( ptArr[ i ].y + offsetY ) ) );
                }
                return pFacadeMediator.moveToPixel3D( vec, moveEndCallBack );
            }
            else {
                return pFacadeMediator.moveToPixel3D( Vector.<CVector2>( [ new CVector2( int( owner.transform.x + offsetX ), int( owner.transform.y + offsetY ) ) ] ), moveEndCallBack );
            }
            return false;
        }

        /**相对自己移动*/
        public function move( owner : CGameObject, ptArr : Array, offsetX : Number, offsetY : Number, moveEndCallBack : Function ) : Boolean {
            var pFacadeMediator : CFacadeMediator = handler.getFacadeMediator( owner );
            if ( ptArr && ptArr.length > 0 ) {
                var vec : Vector.<CVector2> = new Vector.<CVector2>();
                for ( var i : int = 0; i < ptArr.length; i++ ) {
                    vec.push( new CVector2( int( ptArr[ i ].x + offsetX ), int( ptArr[ i ].y + offsetY ) ) );
                }
                return pFacadeMediator.moveToPixel( vec, moveEndCallBack );
            }
            else {
                var bool:Boolean = pFacadeMediator.moveToPixel( Vector.<CVector2>( [ new CVector2( int( owner.transform.x + offsetX ), int( owner.transform.y + offsetY ) ) ] ), moveEndCallBack );
                return bool;
            }
            return false;
        }

        /**相对目标移动*/
        public function moveTo( owner : CGameObject, distanceX : Number, distanceY : Number, targetPosition : Point, movetoEndCallBack : Function, type : String, isFarawayAttack : Boolean = false, fleeType : String = "", axesType : String = "" ) : Boolean {
            if ( distanceX == 0 && targetPosition.x == 0 && targetPosition.y == 0 ) {
                movetoEndCallBack.apply();
                return false;
            }
            var pFacadeMediator : CFacadeMediator = handler.getFacadeMediator( owner );
            var attackTarget : CGameObject = handler.findCurrentAttackable( owner );
            if(targetPosition&&(targetPosition.x!=0||targetPosition.y!=0)){
                var boolpt:Boolean = pFacadeMediator.moveTo( new CVector2( targetPosition.x, targetPosition.y ), movetoEndCallBack );
                return boolpt;
            }
            if ( !attackTarget || !owner || !attackTarget.transform || !owner.transform )return false;
            var directionX : int = owner.transform.x - attackTarget.transform.x;
            var directionY : int = owner.transform.y - attackTarget.transform.y;
            var bool : Boolean;
            distanceX = int( distanceX );
            if ( !handler.getLevelCurTrunk() ) { //单机AI的简单处理，单机没有trunk
                if ( directionX > 0 )//在目标右边
                {
                    if ( Math.abs( directionX ) <= distanceX && Math.abs( directionY ) <= distanceY && !isFarawayAttack ) {
                        return false;
                    }
                    return pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x + distanceX ), attackTarget.transform.y ), movetoEndCallBack );
                } else {
                    if ( Math.abs( directionX ) <= distanceX && Math.abs( directionY ) <= distanceY && !isFarawayAttack ) {
                        return false;
                    }
                    return pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x - distanceX ), attackTarget.transform.y ), movetoEndCallBack );
                }
            }
                if ( type == CMoveToAction.TO_ATTACK ) {
                    if ( directionX > 0 )//自己在目标右边
                    {
                        if ( Math.abs( directionX ) <= distanceX && Math.abs( directionY ) <= distanceY && !isFarawayAttack ) {
                            return false;
                        }
                        else {
                            if ( directionY > 0 )//在目标下方
                            {
                                if ( Math.abs( directionX ) < distanceX ) {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        return false;
                                    } else {
                                        if(int(owner.transform.y)==int(attackTarget.transform.y + distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,owner.transform.x,attackTarget.transform.y+distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                                } else {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        if(int(owner.transform.x)==int(attackTarget.transform.x + distanceX)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,attackTarget.transform.x+distanceX,owner.transform.y,attackTarget.transform.z,movetoEndCallBack);
                                    } else {
                                        if(int(owner.transform.x)==int(attackTarget.transform.x + distanceX)&&int(owner.transform.y)==int(attackTarget.transform.y + distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,attackTarget.transform.x+distanceX,attackTarget.transform.y+distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                                }
                            } else if ( directionY <= 0 )//在目标上方
                            {
                                if ( Math.abs( directionX ) < distanceX ) {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        return false;
                                    } else {
                                        if(int(owner.transform.y)==int(attackTarget.transform.y - distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,owner.transform.x,attackTarget.transform.y-distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                                } else {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        if(int(owner.transform.x)==int(attackTarget.transform.x + distanceX)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,attackTarget.transform.x+distanceX,owner.transform.y,attackTarget.transform.z,movetoEndCallBack);
                                    } else {
                                        if(int(owner.transform.x)==int(attackTarget.transform.x + distanceX)&&int(owner.transform.y)==int(attackTarget.transform.y - distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,attackTarget.transform.x+distanceX,attackTarget.transform.y-distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                                }
                            }
                        }
                    } else if ( directionX < 0 ) {
                        if ( Math.abs( directionX ) <= distanceX && Math.abs( directionY ) <= distanceY && !isFarawayAttack ) {
                            return false;
                        }
                        else {
                            if ( directionY > 0 )//在目标下方
                            {
                                if ( Math.abs( directionX ) < distanceX ) {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        return false;
                                    } else {
                                        if(int(owner.transform.y)==int(attackTarget.transform.y + distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,owner.transform.x,attackTarget.transform.y+distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                                } else {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        if(int(owner.transform.x)==int(attackTarget.transform.x - distanceX)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,attackTarget.transform.x-distanceX,owner.transform.y,attackTarget.transform.z,movetoEndCallBack)
                                    } else {
                                        if(int(owner.transform.x)==int(attackTarget.transform.x - distanceX)&&int(owner.transform.y)==int(attackTarget.transform.y + distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,attackTarget.transform.x-distanceX,attackTarget.transform.y+distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                                }
                            } else if ( directionY <= 0 )//在目标上方
                            {
                                if ( Math.abs( directionX ) < distanceX ) {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        return false;
                                    } else {
                                        if(int(owner.transform.y)==int(attackTarget.transform.y - distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,owner.transform.x,attackTarget.transform.y-distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                                } else {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        if(int(owner.transform.x)==int(attackTarget.transform.x - distanceX)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,attackTarget.transform.x-distanceX,owner.transform.y,attackTarget.transform.z,movetoEndCallBack);
                                    } else {
                                        if(int(owner.transform.x)==int(attackTarget.transform.x - distanceX)&&int(owner.transform.y)==int(attackTarget.transform.y - distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,attackTarget.transform.x-distanceX,attackTarget.transform.y-distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                                }
                            }
                        }
                    }else{//x轴上的距离为0的情况
                        if ( Math.abs( directionX ) <= distanceX && Math.abs( directionY ) <= distanceY && !isFarawayAttack ) {
                            return false;
                        }
                        else {
                            if ( directionY > 0 )//在目标下方
                            {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        return false;
                                    } else {
                                        if(int(owner.transform.y)==int(attackTarget.transform.y + distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,owner.transform.x,attackTarget.transform.y+distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                            } else if ( directionY < 0 )//在目标上方
                            {
                                    if ( Math.abs( directionY ) < distanceY ) {
                                        return false;
                                    } else {
                                        if(int(owner.transform.y)==int(attackTarget.transform.y - distanceY)){
                                            return false;
                                        }
                                        return _moveToNearPos(owner,owner.transform.x,attackTarget.transform.y-distanceY,attackTarget.transform.z,movetoEndCallBack);
                                    }
                            }
                        }
                    }
                }
                else if ( type == CMoveToAction.TO_BACK ) {

                    if ( directionX > 0 ) {
                        return pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) - distanceX, attackTarget.transform.y ), movetoEndCallBack );

                    }
                    if ( directionX < 0 ) {
                        return pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) + distanceX, attackTarget.transform.y ), movetoEndCallBack );
                    }
                }
                else if ( type == CMoveToAction.TO_FLEE ) {
                    if ( fleeType == EFleeType.RNDOM ) {
                        var offsetX : Number = 0;
                        var offsetY : Number = 0;
                        var rand1 : Number = 0;
                        var rand2 : Number = 0;
                        if ( rand1 > 0.5 ) {
                            offsetX = -offsetX;
                        }
                        if ( rand2 > 0.5 ) {
                            offsetY = -offsetY;
                        }
                        for ( var i : int = 0; i < 5; i++ ) {
                            offsetX = Math.random() * 800;
                            rand1 = Math.random();
                            if ( rand1 > 0.5 ) {
                                offsetX = -offsetX;
                            }
                            if ( int( attackTarget.transform.x ) + offsetX < handler.getLevelCurTrunk().x + 50 ) {
                                continue;
                            }
                            if ( int( attackTarget.transform.x ) + offsetX > handler.getLevelCurTrunk().x + handler.getLevelCurTrunk().width - 50 ) {
                                continue;
                            }
                            break;
                        }

                        for ( var j : int = 0; j < 5; j++ ) {
                            offsetY = Math.random() * 200;
                            rand1 = Math.random();
                            if ( rand2 > 0.5 ) {
                                offsetY = -offsetY;
                            }
                            if ( int( attackTarget.transform.y ) + offsetY < handler.getLevelCurTrunk().y + 50 ) {
                                continue;
                            }
                            if ( int( attackTarget.transform.y ) + offsetY > handler.getLevelCurTrunk().y + handler.getLevelCurTrunk().height - 50 ) {
                                continue;
                            }
                            break;
                        }
                        return pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) + offsetX, attackTarget.transform.y + offsetY ), movetoEndCallBack );
                    }
                    else if ( fleeType == EFleeType.FARAWAY ) {
                        if ( directionX > 0 )//向右远离
                        {
                            return bool = pFacadeMediator.moveTo( new CVector2( handler.getLevelCurTrunk().x + handler.getLevelCurTrunk().width - 10 + offsetX, owner.transform.y + offsetY ), movetoEndCallBack );
                        }
                        else if ( directionX < 0 )//向左远离
                        {
                            return pFacadeMediator.moveTo( new CVector2( handler.getLevelCurTrunk().x + 10 + offsetX, owner.transform.y + offsetY ), movetoEndCallBack );
                        }
                    }
                    else if ( fleeType == EFleeType.DISTANCE )//与目标保持一定距离
                    {
                        var trunkHeigh : Number = handler.getLevelCurTrunk().height * 0.3;
                        var yOffset : Number = trunkHeigh / 2;//distanceX*0.3
                        if ( directionX >= 0 ) {
                            //往右边远离
                            //分为右上,y方向区distanceX的0.3
                            //右上
                            bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) + distanceX, attackTarget.transform.y- yOffset ), movetoEndCallBack );
                            if(!bool){
                                //右下
                                bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) + distanceX, attackTarget.transform.y+ yOffset), movetoEndCallBack );
                            }
                            //右上、右下都不能走，就直接往右走
                            if(!bool){
                                bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) + distanceX, attackTarget.transform.y ), movetoEndCallBack );
                            }
                            if ( bool == false && int( attackTarget.transform.x ) + distanceX <= owner.transform.x ) {
                                return false;
                            }
                            if ( bool ) {
                                return bool
                            }
                            else {
                                //往左
                                //左上
                                bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) - distanceX, attackTarget.transform.y- yOffset ), movetoEndCallBack );
                                if(!bool){
                                    //左下
                                    bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) - distanceX, attackTarget.transform.y+ yOffset ), movetoEndCallBack );
                                }
                                if(!bool){
                                    bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) - distanceX, attackTarget.transform.y ), movetoEndCallBack );
                                }
                            }
                            if ( bool ) {
                                return bool;
                            }
                            else {
                                //往左跑到trunk的边界位
                                //左上
                                bool = pFacadeMediator.moveTo( new CVector2( handler.getLevelCurTrunk().left + 20, attackTarget.transform.y- yOffset  ), movetoEndCallBack );
                                if(!bool){
                                    //左下
                                    bool = pFacadeMediator.moveTo( new CVector2( handler.getLevelCurTrunk().left + 20, attackTarget.transform.y+ yOffset ), movetoEndCallBack );
                                }
                                if(!bool){
                                    bool = pFacadeMediator.moveTo( new CVector2( handler.getLevelCurTrunk().left + 20, attackTarget.transform.y ), movetoEndCallBack );
                                }
                                return bool;
                            }
                        }
                        else if ( directionX < 0 ) {
                            //往左边远离
                            //左下
                            bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) - distanceX, attackTarget.transform.y+ yOffset), movetoEndCallBack );
                            if(!bool){
                                //左上
                                bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) - distanceX, attackTarget.transform.y- yOffset ), movetoEndCallBack );
                            }
                            if(!bool){
                                bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) - distanceX, attackTarget.transform.y ), movetoEndCallBack );
                            }
                            if ( bool == false && int( attackTarget.transform.x ) - distanceX >= owner.transform.x ) {
                                return false;
                            }
                            if ( bool ) {
                                return bool;
                            }
                            else {
                                //左下
                                bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) + distanceX, attackTarget.transform.y+ yOffset), movetoEndCallBack );
                                if(!bool){
                                    bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) + distanceX, attackTarget.transform.y- yOffset), movetoEndCallBack );
                                }
                                if(!bool){
                                    bool = pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ) + distanceX, attackTarget.transform.y ), movetoEndCallBack );
                                }
                            }
                            if ( bool ) {
                                return bool;
                            }
                            else {
                                //跑到右边trunk边界
                                //右下
                                bool = pFacadeMediator.moveTo( new CVector2( handler.getLevelCurTrunk().right - 20, attackTarget.transform.y + yOffset ), movetoEndCallBack );
                                if(!bool){
                                    bool = pFacadeMediator.moveTo( new CVector2( handler.getLevelCurTrunk().right - 20, attackTarget.transform.y - yOffset ), movetoEndCallBack );
                                }
                                if(!bool){
                                    bool = pFacadeMediator.moveTo( new CVector2( handler.getLevelCurTrunk().right - 20, attackTarget.transform.y ), movetoEndCallBack );
                                }
                                return bool;
                            }
                        }
                    }
                }
                else if ( type == CMoveToAction.TO_AXES )//与player的Z轴相同
                {
                    if ( axesType == "X" ) {
                        return pFacadeMediator.moveTo( new CVector2( int( attackTarget.transform.x ), int( owner.transform.y ) ), movetoEndCallBack );
                    }
                    else if ( axesType == "Y" ) {
//                    return pFacadeMediator.moveTo( new CVector2( int(owner.transform.x), int(attackTarget.transform.y) ), movetoEndCallBack );
                        return false;
                    }
                    else if ( axesType == "Z" ) {
                        return pFacadeMediator.moveTo( new CVector2( int( owner.transform.x ), int( attackTarget.transform.y ) ), movetoEndCallBack );
                    }
                }
                else if ( type == CMoveToAction.TO_OFFSET ) {

                }
            return false;
        }

        private function _moveToNearPos(owner:CGameObject,targetX:Number,targetY:Number,targetZ:Number,callBack:Function):Boolean{
            if (!owner || !owner.transform )return false;
            var pDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
            targetZ = 0;//目标点不计算高度
            var vec3 : CVector3 = new CVector3(targetX,targetZ,targetY);
            var scene : CScene = ((handler.m_system.stage.getSystem( CSceneSystem ) as CSceneSystem).getBean( CSceneRendering ) as CSceneRendering).scene;
            vec3 = scene.findNearbyGridPosition3D( vec3.x, vec3.y, vec3.z, vec3 );
            var nearX : Number = vec3.x;
            var nearY : Number = vec3.z;
//            var nearX : Number = targetX;
//            var nearY : Number = targetY;
            return moveToPos( owner, new Point( nearX, nearY ), callBack );
        }

        public final function moveToPos( owner : CGameObject, targetPosition : Point, movetoEndCallBack : Function ) : Boolean {
            if (!owner || !owner.transform )return false;
            var pFacadeMediator : CFacadeMediator = handler.getFacadeMediator( owner );
            return pFacadeMediator.moveTo( new CVector2( targetPosition.x, targetPosition.y ), movetoEndCallBack );
        }

        /**跟随玩家*/
        public function follow( owner : CGameObject, movetoEndCallBack : Function, offsetX : Number = 100, offsetY : Number = 20, followDistance : Number = 600, followType : String = "", followBoolDistance : Boolean = false ) : Boolean {
            var master : CGameObject = null;
            var pFacadeMediator : CFacadeMediator = handler.getFacadeMediator( owner );
            var dis : Number = 0;
            if ( (owner.getComponentByClass( CAIComponent, true ) as CAIComponent).currentMaster ) {
                master = (owner.getComponentByClass( CAIComponent, true ) as CAIComponent).currentMaster;
            }
            else {
                switch ( followType ) {
                    case ERoleType.PLAYER:
                        master = handler.getFacadeMediator( owner ).filterPlayerObject();
                        break;
                    case ERoleType.BOSS:
                    case ERoleType.ELITE:
                    case ERoleType.SOLDIER:
                        master = _followFilterRole( followType );
                        break;
                }
                (owner.getComponentByClass( CAIComponent, true ) as CAIComponent).currentMaster = master;
            }
            if ( !master ) {
                (owner.getComponentByClass( CAIComponent, true ) as CAIComponent).currentMaster = null;
                CAILog.logMsg( "跟随目标类型：" + followType + "找不到，无法跟随,本次跟随行为结束", (owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty).ID );
                return false;
            }
            if ( followDistance ) {
//                if ( Point.distance( new Point( owner.transform.x, owner.transform.y ), new Point( master.transform.x, master.transform.y ) ) <= followDistance ) {
//                    return false;
//                }
//                else {
//                    CAILog.logMsg( "距离大于：" + followDistance + "返回主人身边", (owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty).ID );
//                }
                CAILog.logMsg( "距离大于：" + followDistance + "返回主人身边", (owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty).ID );
            }
            dis = owner.transform.x - master.transform.x;
            var bool : Boolean;
            if ( dis > 0 ) {
                bool = pFacadeMediator.moveTo( new CVector2( master.transform.x + offsetX, master.transform.y + offsetY ), movetoEndCallBack );
                if ( bool ) {
                    return bool;
                }
                return pFacadeMediator.moveTo( new CVector2( master.transform.x + offsetX, master.transform.y - offsetY ), movetoEndCallBack );
            }
            if ( dis < 0 ) {
                bool = pFacadeMediator.moveTo( new CVector2( master.transform.x - offsetX, master.transform.y + offsetY ), movetoEndCallBack );
                if ( bool ) {
                    return bool;
                }
                return pFacadeMediator.moveTo( new CVector2( master.transform.x - offsetX, master.transform.y - offsetY ), movetoEndCallBack );
            }
            CAILog.logMsg( "跟随距离:" + followDistance + "，目前距离:" + Math.abs( dis ) + "，不用移动，本次跟随结束", (owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty).ID )
            return false;
        }

        private function _followFilterRole( type : String ) : CGameObject {
            var iType : int = -1;
            if ( type == ERoleType.BOSS ) {
                iType = EMonsterType.BOSS;
            }
            else if ( type == ERoleType.ELITE ) {
                iType = EMonsterType.UNIQUE;
            }
            else if ( type == ERoleType.SOLDIER ) {
                iType = EMonsterType.NORMAL;
            }
            var all : Object = (handler.system.stage.getSystem( CSceneSystem ) as CSceneSystem).allGameObjectIterator;
            if ( !all )return null;
            for each ( var obj : CGameObject  in all ) {
                if ( !obj.isRunning || handler.isDead( obj ) )
                    continue;
                if ( CCharacterDataDescriptor.isMonster( obj.data ) ) {
                    var pFacadeProperty : CMonsterProperty = obj.getComponentByClass( CMonsterProperty, true ) as CMonsterProperty;
                    if ( pFacadeProperty.monsterType == iType ) {
                        return obj;
                    }
                }
            }
            return null;
        }
    }
}
