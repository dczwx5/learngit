package script {
    import laya.components.Script;
    import laya.utils.Browser;
    import laya.events.Event;
    import game.CGameStageStart;
    import game.CGameStage;
    import a_core.scene.CSceneSystem;
    import laya.display.Sprite;
    import metro.player.CPlayerSystem;
    import metro.player.EPlayerEvent;
    import ui.LobbyViewUI;
    import laya.ui.View;
    import laya.ui.Label;
    import game.view.CUISystem;
    import laya.ui.Dialog;

    public class MyControl extends Script {
        private var _curTime:Number; // ms
        public function MyControl() {
            
        }

        override public function onEnable():void {
			this._curTime = Browser.now();
            m_lobbyUI = owner.getChildByName("lobby_UI") as View;

            m_stageStart = new CGameStageStart();
    
            m_stageStart.on(Event.COMPLETE, this, _onStageStarted);

		}
        private function _onStageStarted() : void {
            var gameStage:CGameStage = m_stageStart.stage;
            var pSceneSystem:CSceneSystem = gameStage.getSystem(CSceneSystem) as CSceneSystem;
            pSceneSystem.sceneContainer = (owner as MyScene).getChildByName("sceneLayer") as Sprite;

            var uiSystem:CUISystem = gameStage.getSystem(CUISystem) as CUISystem;
            uiSystem.container = (owner as MyScene).getChildByName("uiLayer") as Sprite;

            Dialog.manager;

            var topLayer:Sprite = new Sprite();
            Laya.stage.addChild(topLayer);
            uiSystem.topLayer = topLayer;

            
            m_pPlayerSystem = gameStage.getSystem(CPlayerSystem) as CPlayerSystem;
            m_pPlayerSystem.on(EPlayerEvent.CUR_SCORE, this, _onPlayerDataHandler);
            
        }
        private function _onPlayerDataHandler() : void {
            var scoreTxt:Label = m_lobbyUI.getChildByName("score_txt") as Label;
            scoreTxt.text = m_pPlayerSystem.playerData.curScore.toString();
        }
		
		override public function onUpdate():void {
			var now:* = Browser.now();
            this._curTime = now;

			if (m_stageStart.isReady) {
                m_stageStart.update();
            }
		}
		
		override public function onStageClick(e:Event):void {
			//停止事件冒泡，提高性能，当然也可以不要
			e.stopPropagation();
            
		}

        private var m_stageStart:CGameStageStart;
        private var m_lobbyUI:View;
        private var m_pPlayerSystem:CPlayerSystem;

		
    }
}