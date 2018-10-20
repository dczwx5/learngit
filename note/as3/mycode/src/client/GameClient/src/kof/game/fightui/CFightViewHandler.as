//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/6/1.
 */
package kof.game.fightui {

import QFLib.Interface.IUpdatable;

import flash.display.BlendMode;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.filters.GlowFilter;
import flash.utils.clearInterval;

import kof.framework.CViewHandler;
import kof.game.character.level.CLevelMediator;
import kof.game.core.CGameObject;
import kof.game.fightui.compoment.CBossInfoViewHandler;
import kof.game.fightui.compoment.CCharacterPointViewHandler;
import kof.game.fightui.compoment.CClubBossViewHandler;
import kof.game.fightui.compoment.CCountdownViewHandler;
import kof.game.fightui.compoment.CEnemiesViewHandler;
import kof.game.fightui.compoment.CEnereyViewHandler;
import kof.game.fightui.compoment.CFighterHeadViewHandler;
import kof.game.fightui.compoment.CGoldInstanceTipsView;
import kof.game.fightui.compoment.CInstanceProcessViewHandler;
import kof.game.fightui.compoment.COtherSideEnereyViewHandler;
import kof.game.fightui.compoment.CPingPongViewHandler;
import kof.game.fightui.compoment.CPlayerInfoViewHandler;
import kof.game.fightui.compoment.CPracticeInstanceView;
import kof.game.fightui.compoment.CPveInfoViewHandler;
import kof.game.fightui.compoment.CSkillTipsOnFightUIHandler;
import kof.game.fightui.compoment.CSkillViewHandler;
import kof.game.fightui.compoment.CTeachingInstanceView;
import kof.game.fightui.compoment.CTeammateViewHandler;
import kof.game.fightui.compoment.CTrainInstanceTipsView;
import kof.game.fightui.compoment.CWarTipsViewHandler;
import kof.game.fightui.compoment.CWorldBossViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.event.CInstanceEvent;
import kof.game.scene.CSceneEvent;
import kof.game.scene.ISceneFacade;
import kof.ui.demo.FightUI;
import kof.ui.imp_common.RewardItemUI;

import morn.core.components.Box;

public class CFightViewHandler extends CViewHandler implements IUpdatable {

        private var m_fightUI : FightUI;

        public function CFightViewHandler() {
            super( true );
        }

        override public function get viewClass() : Array {
            return [ RewardItemUI, FightUI];
        }

        override protected function get additionalAssets() : Array {
            return [
                "Touxiangkuang_hong.swf",
                "Touxiangkuang_lan.swf",
                "go.swf",
                "diaoxue.swf",
                "prohibit_use_skill.swf",
                "frameclip_combo.swf",
                "Diaoxue_hong.swf",
                "dazhaotubiao_huoguang.swf",
                "huo.swf",
                "Sanjiaoguang.swf",
                "frameclip_fightfx.swf",
//                "frameclip_fightfx2.swf",
                "shanguangdeng_1.swf",
                "shanguangdeng_2.swf",
                "frameclip_rotationWroldBossDie.swf",
                "frameclip_auto2.swf",
                "frameclip_typecounter.swf",
                    "frameclip_qe.swf"
            ];
        }

        override protected function onAssetsLoadCompleted() : void {
            super.onAssetsLoadCompleted();
            this.onInitializeView();
        }

        override protected function onInitializeView() : Boolean {
            if ( !super.onInitializeView() )
                return false;

            if ( !m_fightUI ) {
                m_fightUI = new FightUI();
                m_fightUI.addEventListener( Event.REMOVED_FROM_STAGE, _fightUIRemoveFromStage );
                initUI();
            }

            addBean( new CPlayerInfoViewHandler() );
            addBean( new CBossInfoViewHandler() );
            addBean( new CSkillViewHandler( m_fightUI ) );
            addBean( new CTeammateViewHandler() );
            addBean( new CEnereyViewHandler( m_fightUI ) );
            addBean( new CEnemiesViewHandler() );
            addBean( new CWarTipsViewHandler( m_fightUI ) );
            addBean( new CPveInfoViewHandler( m_fightUI ) );
            addBean( new CCountdownViewHandler( m_fightUI ) );
            addBean( new CCharacterPointViewHandler( m_fightUI ) );
            addBean( new CFighterHeadViewHandler( m_fightUI ) );
            addBean( new CInstanceProcessViewHandler( m_fightUI ) );
            addBean( new CWorldBossViewHandler( m_fightUI ,uiCanvas) );
            addBean( new CGoldInstanceTipsView( m_fightUI ) );
            addBean( new CTrainInstanceTipsView( m_fightUI ) );
            addBean( new CPracticeInstanceView( m_fightUI ) );
            addBean( new CTeachingInstanceView( m_fightUI ) );
            addBean( new CPingPongViewHandler( m_fightUI ) );
            addBean( new COtherSideEnereyViewHandler( m_fightUI ) );
            addBean( new CClubBossViewHandler(m_fightUI,uiCanvas));
            addBean( new CSkillTipsOnFightUIHandler());
            return Boolean( m_fightUI );
        }

        override protected function onInitialize() : Boolean {
            if ( !super.onInitialize() )
                return false;

            var pSceneFacade : ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
            pSceneFacade.addEventListener( CSceneEvent.HERO_INIT, _onHeroReady );
            pSceneFacade.addEventListener( CSceneEvent.HERO_READY, _onHeroReady );
            pSceneFacade.addEventListener( CSceneEvent.HERO_REMOVED, _onHeroRemove );
            pSceneFacade.addEventListener( CSceneEvent.BOSS_APPEAR, _onBossAppear );
            _instanceSystem.addEventListener( CInstanceEvent.LEVEL_ENTER, _levelReady );
            _instanceSystem.addEventListener( CInstanceEvent.LEVEL_EXIT, _levelExit );

            return true;
        }

        private function initUI() : void {
            setEffBlendMode(
                    m_fightUI.info_left.kofframeclippro_reduce.bar,
                    m_fightUI.info_right.kofframeclippro_reduce.bar,
                    m_fightUI.info_left.kofframeclippro_hp.bar,
                    m_fightUI.info_right.kofframeclippro_hp.bar,
                    m_fightUI.frameclip_rush_eff1
            );

            m_fightUI.info_left.txt_name.filters =
                    m_fightUI.info_right.txt_name.filters =
                            [ new GlowFilter( 0, 1, 2, 2, 5, 1 ) ];
            m_fightUI.info_left.box_reduceeff.visible =
                    m_fightUI.info_left.box_redrec.visible =
                            m_fightUI.info_left.box_reducerec.visible =
                                    m_fightUI.info_right.box_reduceeff.visible =
                                            m_fightUI.info_right.box_redrec.visible =
                                                    m_fightUI.info_right.box_reducerec.visible =
                                                            m_fightUI.list_left.visible =
                                                                    m_fightUI.list_right.visible =
                                                                            m_fightUI.box_autoFight.visible = false;

            var pMaskDisplayObject : DisplayObject;
            pMaskDisplayObject = m_fightUI.info_left.getChildByName( 'mask' );
            if ( pMaskDisplayObject ) {
                m_fightUI.info_left.img.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                m_fightUI.info_left.img.mask = pMaskDisplayObject;
            }
            pMaskDisplayObject = m_fightUI.info_right.getChildByName( 'mask' );
            if ( pMaskDisplayObject ) {
                m_fightUI.info_right.img.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                m_fightUI.info_right.img.mask = pMaskDisplayObject;
            }

//            m_fightUI.exit_btn.visible = false;
            m_fightUI.gold_ui.visible = false;
        }

        private var gameObject : CGameObject;

        private function _onHeroReady( evt : CSceneEvent ) : void {

            gameObject = evt.value as CGameObject;
            if ( !gameObject )
                return;

            var pPlayerInfoViewHandler : CPlayerInfoViewHandler;
            var pBossInfoViewHandler : CBossInfoViewHandler;
            var pTeammateViewHandler : CTeammateViewHandler;
            var pEnemiesViewHandler : CEnemiesViewHandler;
            var pCPingPongViewHandler : CPingPongViewHandler;
            var pEnereyViewHandler : CEnereyViewHandler;
            var pCOtherSideEnereyViewHandler : COtherSideEnereyViewHandler;

            if ( gameObject && ( !gameObject.data.side || gameObject.data.side == CFightConst.p_1_side ) ) {//本人在左边

                pPlayerInfoViewHandler = getBean( CPlayerInfoViewHandler ) as CPlayerInfoViewHandler;
                pPlayerInfoViewHandler.setData( evt.value, m_fightUI, m_fightUI.info_left );

                pBossInfoViewHandler = getBean( CBossInfoViewHandler ) as CBossInfoViewHandler;
                pBossInfoViewHandler.setData( evt.value, m_fightUI.info_right );

                pEnereyViewHandler  = getBean( CEnereyViewHandler ) as CEnereyViewHandler;
                pEnereyViewHandler.setData( evt.value ,m_fightUI.enerey_left);

                pCOtherSideEnereyViewHandler   = getBean( COtherSideEnereyViewHandler ) as COtherSideEnereyViewHandler;
                pCOtherSideEnereyViewHandler.setData( evt.value,m_fightUI.enerey_right );

                pTeammateViewHandler = getBean( CTeammateViewHandler ) as CTeammateViewHandler;
                pTeammateViewHandler.setData( evt.value, m_fightUI.list_left, m_fightUI.team_q_img, m_fightUI.team_e_img, _instanceSystem.canQE );

                pEnemiesViewHandler = getBean( CEnemiesViewHandler ) as CEnemiesViewHandler;
                pEnemiesViewHandler.setData( evt.value, m_fightUI.list_right );

                pCPingPongViewHandler = getBean( CPingPongViewHandler ) as CPingPongViewHandler;
                pCPingPongViewHandler.setData( m_fightUI.info_left.clip_signal, m_fightUI.info_right.clip_signal );


            } else {

                pPlayerInfoViewHandler = getBean( CPlayerInfoViewHandler ) as CPlayerInfoViewHandler;
                pPlayerInfoViewHandler.setData( evt.value, m_fightUI, m_fightUI.info_right, false );

                pBossInfoViewHandler = getBean( CBossInfoViewHandler ) as CBossInfoViewHandler;
                pBossInfoViewHandler.setData( evt.value, m_fightUI.info_left, false );

                pEnereyViewHandler  = getBean( CEnereyViewHandler ) as CEnereyViewHandler;
                pEnereyViewHandler.setData( evt.value ,m_fightUI.enerey_right );

                pCOtherSideEnereyViewHandler   = getBean( COtherSideEnereyViewHandler ) as COtherSideEnereyViewHandler;
                pCOtherSideEnereyViewHandler.setData( evt.value ,m_fightUI.enerey_left);

                pTeammateViewHandler = getBean( CTeammateViewHandler ) as CTeammateViewHandler;
                pTeammateViewHandler.setData( evt.value, m_fightUI.list_right, null, null, _instanceSystem.canQE );

                pEnemiesViewHandler = getBean( CEnemiesViewHandler ) as CEnemiesViewHandler;
                pEnemiesViewHandler.setData( evt.value, m_fightUI.list_left );

                pCPingPongViewHandler = getBean( CPingPongViewHandler ) as CPingPongViewHandler;
                pCPingPongViewHandler.setData( m_fightUI.info_right.clip_signal, m_fightUI.info_left.clip_signal );
            }

            var pSkillViewHandler : CSkillViewHandler = getBean( CSkillViewHandler ) as CSkillViewHandler;
            pSkillViewHandler.updateSkillData( evt.value );


            var pWarTipsViewHandler : CWarTipsViewHandler = getBean( CWarTipsViewHandler ) as CWarTipsViewHandler;
            pWarTipsViewHandler.setData( evt.value );

            var pPveInfoViewHandler : CPveInfoViewHandler = getBean( CPveInfoViewHandler ) as CPveInfoViewHandler;
            pPveInfoViewHandler.setData( evt.value );

            var pCountdownViewHandler : CCountdownViewHandler = getBean( CCountdownViewHandler ) as CCountdownViewHandler;
            pCountdownViewHandler.setData();

            var pCharacterPointViewHandler : CCharacterPointViewHandler = getBean( CCharacterPointViewHandler ) as CCharacterPointViewHandler;
            pCharacterPointViewHandler.setData();


            //


        }

        private function _onHeroRemove( evt : CSceneEvent ) : void {
            var pBossInfoViewHandler : CBossInfoViewHandler = getBean( CBossInfoViewHandler ) as CBossInfoViewHandler;
            pBossInfoViewHandler.resetUI();
        }
        private var _isBossAppear : Boolean;
        private var _isBossAppearID : int;
        private function _onBossAppear( evt : CSceneEvent ) : void {

            var pLevelMediator : CLevelMediator = gameObject.getComponentByClass( CLevelMediator,true ) as CLevelMediator;
            if( pLevelMediator.isAttackable( evt.value as CGameObject ) ){
                var pBossInfoViewHandler : CBossInfoViewHandler = getBean( CBossInfoViewHandler ) as CBossInfoViewHandler;
                pBossInfoViewHandler.onBossAppear( evt.value as CGameObject );
            }

        }
        private function resetBossAppear():void{
            _isBossAppear = false;
            clearInterval( _isBossAppearID );
        }
        private function _levelReady( e : CInstanceEvent ) : void {
        }
        private function _levelExit( e : CInstanceEvent ) : void {
//            hide();
        }

        public function show() : void {
            if ( m_fightUI ) {
                uiCanvas.rootContainer.addChild( m_fightUI );

                var instanceProcessView : CInstanceProcessViewHandler = getBean( CInstanceProcessViewHandler ) as CInstanceProcessViewHandler;
                instanceProcessView.show();
                _addEventListeners();
                _onResize();
            }
        }

        public function update( delta : Number ) : void {
            var pSkillViewHandler : CSkillViewHandler = getBean( CSkillViewHandler ) as CSkillViewHandler;
            if ( pSkillViewHandler )
                pSkillViewHandler.update( delta );
        }

        private function setEffBlendMode( ... args ) : void {
            var i : int;
            var disObj : DisplayObject;
            for ( i = 0; i < args.length; i++ ) {
                disObj = args[ i ] as DisplayObject;
                if ( disObj )
                    disObj.blendMode = BlendMode.ADD;
            }
        }

        public function hide( removed : Boolean = true ) : void {
            if ( m_fightUI ) {
                if ( removed ) {
                    m_fightUI.remove();
                } else {
                    m_fightUI.alpha = 0;
                }
            }

            var cPlayerInfoViewHandler : CPlayerInfoViewHandler = getBean( CPlayerInfoViewHandler ) as CPlayerInfoViewHandler;
            cPlayerInfoViewHandler.hide();
            var pBossInfoViewHandler : CBossInfoViewHandler = getBean( CBossInfoViewHandler ) as CBossInfoViewHandler;
            pBossInfoViewHandler.hide();
            var pSkillViewHandler : CSkillViewHandler = getBean( CSkillViewHandler ) as CSkillViewHandler;
            pSkillViewHandler.hideView();
            var pTeammateViewHandler : CTeammateViewHandler = getBean( CTeammateViewHandler ) as CTeammateViewHandler;
            pTeammateViewHandler.hide();
            var pEnemiesViewHandler : CEnemiesViewHandler = getBean( CEnemiesViewHandler ) as CEnemiesViewHandler;
            pEnemiesViewHandler.hide();
            var pPveInfoViewHandler : CPveInfoViewHandler = getBean( CPveInfoViewHandler ) as CPveInfoViewHandler;
            pPveInfoViewHandler.hide();
            var pCountdownViewHandler : CCountdownViewHandler = getBean( CCountdownViewHandler ) as CCountdownViewHandler;
            pCountdownViewHandler.hide();
            var pCharacterPointViewHandler : CCharacterPointViewHandler = getBean( CCharacterPointViewHandler ) as CCharacterPointViewHandler;
            pCharacterPointViewHandler.hide();
            var pWarTipsViewHandler : CWarTipsViewHandler = getBean( CWarTipsViewHandler ) as CWarTipsViewHandler;
            pWarTipsViewHandler.hide();
            var pEnereyViewHandler : CEnereyViewHandler = getBean( CEnereyViewHandler ) as CEnereyViewHandler;
            pEnereyViewHandler.hide();
            var pFighterHeadViewHandler : CFighterHeadViewHandler = getBean( CFighterHeadViewHandler ) as CFighterHeadViewHandler;
            pFighterHeadViewHandler.hide();
            var instanceProcessView : CInstanceProcessViewHandler = getBean( CInstanceProcessViewHandler ) as CInstanceProcessViewHandler;
            instanceProcessView.hide();
            var pingPongViewHandler : CPingPongViewHandler = getBean( CPingPongViewHandler ) as CPingPongViewHandler;
            pingPongViewHandler.hide();
            var pCOtherSideEnereyViewHandler : COtherSideEnereyViewHandler = getBean( COtherSideEnereyViewHandler ) as COtherSideEnereyViewHandler;
            pCOtherSideEnereyViewHandler.hide();
            _removeEventListeners();

        }

        private function _onResizeHandler( evt : Event ) : void {
            _onResize();
        }

        private function _onResize(  ) : void {
            if ( system.stage.flashStage.stageWidth < 700 ) {
                m_fightUI.info_left.hp.scaleX =
                        m_fightUI.info_left.kofframeclippro_hp.scaleX =
                                m_fightUI.info_left.box_reducerec.scaleX =
                                        m_fightUI.info_left.kofframeclippro_reduce.scaleX =
                                        m_fightUI.info_left.img_hp_bg.scaleX =
                                        m_fightUI.info_left.progress_redBar.scaleX =
                                                m_fightUI.info_left.box_redrec.scaleX = 0.3;
                m_fightUI.info_right.hp.scaleX =
                        m_fightUI.info_right.kofframeclippro_hp.scaleX =
                                m_fightUI.info_right.box_reducerec.scaleX =
                                        m_fightUI.info_right.kofframeclippro_reduce.scaleX =
                                        m_fightUI.info_right.clip_bloodbg.scaleX =
                                        m_fightUI.info_right.img_hp_bg.scaleX =
                                        m_fightUI.info_right.progress_redBar.scaleX =
                                                m_fightUI.info_right.box_redrec.scaleX = -0.3;
                m_fightUI.info_left.txt_hp.x = 100;
                m_fightUI.info_right.txt_hp.x = 400;

                m_fightUI.info_left.box_def.x = 80;
                m_fightUI.info_right.box_def.x = 420;
                m_fightUI.box_maxtime.scale = 0.3;
                m_fightUI.kofnum_time.scale = 0.3;

            } else if ( system.stage.flashStage.stageWidth < 800 ) {
                m_fightUI.info_left.hp.scaleX =
                        m_fightUI.info_left.kofframeclippro_hp.scaleX =
                                m_fightUI.info_left.box_reducerec.scaleX =
                                        m_fightUI.info_left.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_left.img_hp_bg.scaleX =
                                                m_fightUI.info_left.progress_redBar.scaleX =
                                                m_fightUI.info_left.box_redrec.scaleX = 0.4;
                m_fightUI.info_right.hp.scaleX =
                        m_fightUI.info_right.kofframeclippro_hp.scaleX =
                                m_fightUI.info_right.box_reducerec.scaleX =
                                        m_fightUI.info_right.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_right.clip_bloodbg.scaleX =
                                                        m_fightUI.info_right.img_hp_bg.scaleX =
                                                        m_fightUI.info_right.progress_redBar.scaleX =
                                                m_fightUI.info_right.box_redrec.scaleX = -0.4;
                m_fightUI.info_left.txt_hp.x = 130;
                m_fightUI.info_right.txt_hp.x = 370;

                m_fightUI.info_left.box_def.x = 105;
                m_fightUI.info_right.box_def.x = 365;
                m_fightUI.box_maxtime.scale = 0.4;
                m_fightUI.kofnum_time.scale = 0.4;

            } else if ( system.stage.flashStage.stageWidth < 900 ) {
                m_fightUI.info_left.hp.scaleX =
                        m_fightUI.info_left.kofframeclippro_hp.scaleX =
                                m_fightUI.info_left.box_reducerec.scaleX =
                                        m_fightUI.info_left.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_left.img_hp_bg.scaleX =
                                                m_fightUI.info_left.progress_redBar.scaleX =
                                                m_fightUI.info_left.box_redrec.scaleX = 0.5;
                m_fightUI.info_right.hp.scaleX =
                        m_fightUI.info_right.kofframeclippro_hp.scaleX =
                                m_fightUI.info_right.box_reducerec.scaleX =
                                        m_fightUI.info_right.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_right.clip_bloodbg.scaleX =
                                                        m_fightUI.info_right.img_hp_bg.scaleX =
                                                        m_fightUI.info_right.progress_redBar.scaleX =
                                                m_fightUI.info_right.box_redrec.scaleX = -0.5;
                m_fightUI.info_left.txt_hp.x = 160;
                m_fightUI.info_right.txt_hp.x = 340;

                m_fightUI.info_left.box_def.x = 160;
                m_fightUI.info_right.box_def.x = 310;
                m_fightUI.box_maxtime.scale = 0.5;
                m_fightUI.kofnum_time.scale = 0.5;

            } else if ( system.stage.flashStage.stageWidth < 1050 ) {
                m_fightUI.info_left.hp.scaleX =
                        m_fightUI.info_left.kofframeclippro_hp.scaleX =
                                m_fightUI.info_left.box_reducerec.scaleX =
                                        m_fightUI.info_left.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_left.img_hp_bg.scaleX =
                                                m_fightUI.info_left.progress_redBar.scaleX =
                                                m_fightUI.info_left.box_redrec.scaleX = 0.6;
                m_fightUI.info_right.hp.scaleX =
                        m_fightUI.info_right.kofframeclippro_hp.scaleX =
                                m_fightUI.info_right.box_reducerec.scaleX =
                                        m_fightUI.info_right.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_right.clip_bloodbg.scaleX =
                                                        m_fightUI.info_right.img_hp_bg.scaleX =
                                                        m_fightUI.info_right.progress_redBar.scaleX =
                                                m_fightUI.info_right.box_redrec.scaleX = -0.6;
                m_fightUI.info_left.txt_hp.x = 190;
                m_fightUI.info_right.txt_hp.x = 310;

                m_fightUI.info_left.box_def.x = 230;
                m_fightUI.info_right.box_def.x = 240;
                m_fightUI.box_maxtime.scale = 0.6;
                m_fightUI.kofnum_time.scale = 0.6;

            } else if ( system.stage.flashStage.stageWidth < 1150 ) {
                m_fightUI.info_left.hp.scaleX =
                        m_fightUI.info_left.kofframeclippro_hp.scaleX =
                                m_fightUI.info_left.box_reducerec.scaleX =
                                        m_fightUI.info_left.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_left.img_hp_bg.scaleX =
                                                m_fightUI.info_left.progress_redBar.scaleX =
                                                m_fightUI.info_left.box_redrec.scaleX = 0.7;
                m_fightUI.info_right.hp.scaleX =
                        m_fightUI.info_right.kofframeclippro_hp.scaleX =
                                m_fightUI.info_right.box_reducerec.scaleX =
                                        m_fightUI.info_right.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_right.clip_bloodbg.scaleX =
                                                        m_fightUI.info_right.img_hp_bg.scaleX =
                                                        m_fightUI.info_right.progress_redBar.scaleX =
                                                m_fightUI.info_right.box_redrec.scaleX = -0.7;
                m_fightUI.info_left.txt_hp.x = 220;
                m_fightUI.info_right.txt_hp.x = 290;

                m_fightUI.info_left.box_def.x = 295;
                m_fightUI.info_right.box_def.x = 175;
                m_fightUI.box_maxtime.scale = 0.7;
                m_fightUI.kofnum_time.scale = 0.7;

            } else if ( system.stage.flashStage.stageWidth < 1250 ) {
                m_fightUI.info_left.hp.scaleX =
                        m_fightUI.info_left.kofframeclippro_hp.scaleX =
                                m_fightUI.info_left.box_reducerec.scaleX =
                                        m_fightUI.info_left.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_left.img_hp_bg.scaleX =
                                                m_fightUI.info_left.progress_redBar.scaleX =
                                                m_fightUI.info_left.box_redrec.scaleX = 0.8;
                m_fightUI.info_right.hp.scaleX =
                        m_fightUI.info_right.kofframeclippro_hp.scaleX =
                                m_fightUI.info_right.box_reducerec.scaleX =
                                        m_fightUI.info_right.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_right.clip_bloodbg.scaleX =
                                                        m_fightUI.info_right.img_hp_bg.scaleX =
                                                        m_fightUI.info_right.progress_redBar.scaleX =
                                                m_fightUI.info_right.box_redrec.scaleX = -0.8;
                m_fightUI.info_left.txt_hp.x = 250;
                m_fightUI.info_right.txt_hp.x = 260;

                m_fightUI.info_left.box_def.x = 350;
                m_fightUI.info_right.box_def.x = 120;
                m_fightUI.box_maxtime.scale = 0.8;
                m_fightUI.kofnum_time.scale = 0.8;

            }
            else if ( system.stage.flashStage.stageWidth < 1375 ) {
                m_fightUI.info_left.hp.scaleX =
                        m_fightUI.info_left.kofframeclippro_hp.scaleX =
                                m_fightUI.info_left.box_reducerec.scaleX =
                                        m_fightUI.info_left.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_left.img_hp_bg.scaleX =
                                                m_fightUI.info_left.progress_redBar.scaleX =
                                                m_fightUI.info_left.box_redrec.scaleX = 0.9;
                m_fightUI.info_right.hp.scaleX =
                        m_fightUI.info_right.kofframeclippro_hp.scaleX =
                                m_fightUI.info_right.box_reducerec.scaleX =
                                        m_fightUI.info_right.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_right.clip_bloodbg.scaleX =
                                                        m_fightUI.info_right.img_hp_bg.scaleX =
                                                        m_fightUI.info_right.progress_redBar.scaleX =
                                                m_fightUI.info_right.box_redrec.scaleX = -0.9;
                m_fightUI.info_left.txt_hp.x = 280;
                m_fightUI.info_right.txt_hp.x = 230;

                m_fightUI.info_left.box_def.x = 410;
                m_fightUI.info_right.box_def.x = 60;
                m_fightUI.box_maxtime.scale = 0.9;
                m_fightUI.kofnum_time.scale = 0.9;

            } else {
                m_fightUI.info_left.hp.scaleX =
                        m_fightUI.info_left.kofframeclippro_hp.scaleX =
                                m_fightUI.info_left.box_reducerec.scaleX =
                                        m_fightUI.info_left.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_left.img_hp_bg.scaleX =
                                                m_fightUI.info_left.progress_redBar.scaleX =
                                                m_fightUI.info_left.box_redrec.scaleX = 1;
                m_fightUI.info_right.hp.scaleX =
                        m_fightUI.info_right.kofframeclippro_hp.scaleX =
                                m_fightUI.info_right.box_reducerec.scaleX =
                                        m_fightUI.info_right.kofframeclippro_reduce.scaleX =
                                                m_fightUI.info_right.clip_bloodbg.scaleX =
                                                        m_fightUI.info_right.img_hp_bg.scaleX =
                                                        m_fightUI.info_right.progress_redBar.scaleX =
                                                m_fightUI.info_right.box_redrec.scaleX = -1;

                m_fightUI.info_left.txt_hp.x = 313;
                m_fightUI.info_right.txt_hp.x = 198;

                m_fightUI.info_left.box_def.x = 472;
                m_fightUI.info_right.box_def.x = 2;
                m_fightUI.box_maxtime.scale = 1;
                m_fightUI.kofnum_time.scale = 1;
            }

            m_fightUI.info_left.left = m_fightUI.info_right.right = 0;

        }

        private function _fightUIRemoveFromStage( evt : Event ):void{
            var pPlayerInfoViewHandler : CPlayerInfoViewHandler  = getBean( CPlayerInfoViewHandler ) as CPlayerInfoViewHandler;
            pPlayerInfoViewHandler.stopEff();

            var pBossInfoViewHandler : CBossInfoViewHandler  = getBean( CBossInfoViewHandler ) as CBossInfoViewHandler;
            pBossInfoViewHandler.stopEff();
        }

        private function _addEventListeners() : void {
            _removeEventListeners();
//            m_fightUI.addEventListener( Event.RESIZE, _onResizeHandler, false, 0, true );
            system.stage.flashStage.addEventListener( Event.RESIZE, _onResizeHandler, false, 0, true );
        }

        private function _removeEventListeners() : void {
//            m_fightUI.removeEventListener( Event.RESIZE, _onResizeHandler );
            system.stage.flashStage.removeEventListener( Event.RESIZE, _onResizeHandler );
        }
        private function get _instanceSystem():CInstanceSystem{
            return system.stage.getSystem( CInstanceSystem ) as CInstanceSystem;
        }

        [Inline]
        public function get battleTutorBox() : Box {
            if (m_fightUI) {
                return m_fightUI.battle_tutor_box;
            }
            return null;
        }
    }
}
