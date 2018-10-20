//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/1/18.
 * Time: 10:20
 */
package kof.game.character.ai.methods {

    import QFLib.Foundation;

    import kof.game.character.CFacadeMediator;
    import kof.game.character.CSkillList;
    import kof.game.character.ai.CAIHandler;
    import kof.game.character.fight.skill.CSimulateSkillCaster;
    import kof.game.character.state.CCharacterInput;
    import kof.game.core.CGameObject;

    public class CFightCategory {
        private var _handler : CAIHandler = null;

        public function CFightCategory( handler : CAIHandler ) {
            this._handler = handler;
        }

        /**调用技能攻击*/
        public final function attackWithSkillID( owner : CGameObject, skillId : int ) : void {
            var input : CCharacterInput = owner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
            input.addSkillRequest( skillId );
        }

        /**调用蓄力技能攻击*/
        public final function castUpWithSkillIndex( owner : CGameObject , skillIndex : int ) : void{
            var input : CCharacterInput = owner.getComponentByClass( CCharacterInput, true ) as CCharacterInput;
            input.addSkillUpRequest( skillIndex );
        }
        /**闪避*/
        public final function dodge( owner : CGameObject ) : Boolean {
            var pFacadeMediator : CFacadeMediator = _handler.getFacadeMediator( owner );
            var attackable : CGameObject = _handler.findCurrentAttackable( owner );
            if ( !attackable )return false;
            return pFacadeMediator.dodgeSudden();
        }

        public final function dodgeIgnore(owner : CGameObject):void{
            var pSimulator : CSimulateSkillCaster = owner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
            if ( pSimulator )
                pSimulator.dodgeSuddenIgnoreRPAndCD();
        }

        /**判断和玩家的距离，是否在攻击范围内*/
        public final function judegeDistanceAttack( distanceX : Number, distanceY : Number, owner : CGameObject ) : Boolean {
            var attackable : CGameObject = _handler.findCurrentAttackable( owner );
            if ( !attackable )return false;
            var directionX : int = owner.transform.x - attackable.transform.x;
            var directionY : int = owner.transform.y - attackable.transform.y;
            distanceX = int( distanceX );
            if ( directionX > 0 )//在目标右边
            {
                if ( directionX < distanceX && Math.abs( directionY ) <= distanceY ) {
                    return true;
                }
            } else if ( directionX < 0 ) {
                if ( directionX >= -distanceX && directionY <= distanceY ) {
                    return true;
                }
            }
            return false;
        }

        /**直接调用无视消耗放技能**/
        public final function attackIgnoreWithSkillIdx( owner : CGameObject, skillIdx : int ) : void {
            var pSimulator : CSimulateSkillCaster = owner.getComponentByClass( CSimulateSkillCaster, true ) as CSimulateSkillCaster;
            if ( pSimulator )
                pSimulator.castSkillIndexIgnoreConsume( skillIdx );
        }
    }
}
