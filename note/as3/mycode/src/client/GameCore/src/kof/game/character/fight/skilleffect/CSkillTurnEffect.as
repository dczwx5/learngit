//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight.skilleffect {

import QFLib.Foundation;

import kof.framework.events.CEventPriority;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CComponentUtility;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.state.CCharacterStateBoard;
import kof.util.CAssertUtils;

/**
 * 技能中动作转身的效果
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSkillTurnEffect extends CAbstractSkillEffect {

    private var m_fElapsedTime : Number;

    /** Creates a new CSkillTurnEffect object. */
    public function CSkillTurnEffect( id : int, startFrame : Number, hitEvent : String, type : int, description : String = null ) {
        super( id, startFrame, hitEvent, type, description );
    }

    /** @inheritDoc */
    override public function dispose() : void {
        super.dispose();

        m_fElapsedTime = NaN;

        var v_pFightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, false ) as CCharacterFightTriggle;
        if ( v_pFightTrigger )
            v_pFightTrigger.removeEventListener( CFightTriggleEvent.SPELL_SKILL_READY_END, _onSkillEnd );

//        var v_pEventMediator : CEventMediator = m_pSkillContext.owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
//        if ( v_pEventMediator ) {
//            v_pEventMediator.removeEventListener( CCharacterEvent.ANIMATION_TIME_END, _onCurrentAnimationEnd );
//        }

        if ( boStarted )
            this.delimDisplayDirectionSync( false );

        _holdTurningUntillNextFrame();

    }

    override public function initData( ... args ) : void {
        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**@CSkillTurnEffect: 初始化动作转身效果，ID：" + effectID );
        }

        if ( !args || !args.length )
            return;

        super.initData( args );

        m_fElapsedTime = 0;
    }

    /**
     * @inheritDoc
     */
    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( isNaN( m_fElapsedTime ) )
            return;

        m_fElapsedTime += delta;

        if ( effectStartTime <= m_fElapsedTime ) {
            m_fElapsedTime = NaN;

            var v_pFightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            if ( v_pFightTrigger )
                v_pFightTrigger.addEventListener( CFightTriggleEvent.SPELL_SKILL_READY_END, _onSkillEnd );

            _characterTurnDirection();
//            var v_pEventMediator : CEventMediator = m_pSkillContext.owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
//            if ( v_pEventMediator ) {
//                v_pEventMediator.addEventListener( CCharacterEvent.ANIMATION_TIME_END, _onCurrentAnimationEnd,
//                        false, CEventPriority.DEFAULT, true );
//            }

//            CAssertUtils.assertNotNull( m_pSkillContext, "Invalid m_pSkillContext." );

//            var pStateBoard : CCharacterStateBoard = m_pSkillContext.owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
//            if ( pStateBoard ) {
//                var pDirectionAxis : Object = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
//                if ( pDirectionAxis ) {
//                    pDirectionAxis.x = -pDirectionAxis.x;
//                }
//            }

            this.delimDisplayDirectionSync( true );
        }
    }

    private function _characterTurnDirection() : void {
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            var pDirectionAxis : Object = pStateBoard.getValue( CCharacterStateBoard.DIRECTION );
            if ( pDirectionAxis ) {
                pDirectionAxis.x = -pDirectionAxis.x;
            }
        }
    }

    private function _onSkillEnd( e : CFightTriggleEvent ) : void {
        var v_pFightTrigger : CCharacterFightTriggle = owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        if ( v_pFightTrigger )
            v_pFightTrigger.removeEventListener( CFightTriggleEvent.SPELL_SKILL_READY_END, _onSkillEnd );


        this.delimDisplayDirectionSync( false );

        //通常技能结束强制同步显示模型方向，不能等下一帧，否则模型方向有问题
        _holdTurningUntillNextFrame();

    }

    private function _holdTurningUntillNextFrame() : void{
        var pDisplay : IAnimation= owner.getComponentByClass(IAnimation , true ) as IAnimation;
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( pStateBoard ) {
            pStateBoard.setValue( CCharacterStateBoard.LEGACY_NEED_UPDATE , true );
            if ( pDisplay ) {
                pDisplay.inTurnning = true;
            }
        }
    }

    override public function lastUpdate( delta : Number ) : void {
        super.lastUpdate( delta );
    }

    protected function delimDisplayDirectionSync( bDelim : Boolean ) : void {
        var pStateBoard : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
        if ( !pStateBoard )
            return;

        if ( bDelim ) {
            pStateBoard.setValue( CCharacterStateBoard.DIRECTION_DISPLAY_PERMIT, false );
        } else {
            pStateBoard.resetValue( CCharacterStateBoard.DIRECTION_DISPLAY_PERMIT );
        }
    }

    private function _onCurrentAnimationEnd( event : CCharacterEvent ) : void {
        var v_pEventMediator : CEventMediator = event.character.getComponentByClass( CEventMediator, true ) as CEventMediator;
        if ( v_pEventMediator ) {
            v_pEventMediator.removeEventListener( CCharacterEvent.ANIMATION_TIME_END, _onCurrentAnimationEnd );
        }

        this.delimDisplayDirectionSync( false );
    }

}
} // package kof.game.character.fight.skilleffect
// vim:ft=as3 ts=4 sw=4 expandtab wrap tw=120
