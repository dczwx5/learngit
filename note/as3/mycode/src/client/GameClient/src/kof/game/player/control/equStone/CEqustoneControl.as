//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/25.
 * Time: 14:19
 */
package kof.game.player.control.equStone {

    import kof.game.common.view.event.CViewEvent;
    import kof.game.player.CPlayerHandler;
    import kof.game.player.control.CPlayerControler;
    import kof.game.player.enum.EPlayerWndType;
    import kof.game.player.view.equipmentTrain.CEquipmentTrainViewHandler;
    import kof.game.player.view.event.EPlayerViewEventType;
    import kof.game.player.view.player.CPlayerHeroView;

    public class CEqustoneControl extends CPlayerControler {
        public function CEqustoneControl() {
            super();
        }

        public override function dispose() : void {
            _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

        }
        public override function create() : void {
            _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);

        }

        private function _onUIEvent(e:CViewEvent) : void {
            var uiEvent:String = e.subEvent;
            var stoneIndex:int;
            switch (uiEvent) {
                case EPlayerViewEventType.EVENT_EQUIP_STONE:
                    stoneIndex = e.data.id;
                    var playerHeroView:CPlayerHeroView = uiHandler.getWindow(EPlayerWndType.WND_HERO_MAIN) as CPlayerHeroView;
                    if(playerHeroView)
                    {
                        playerHeroView.equipTrainsView.updateStone(stoneIndex);
                    }
                    break;
            }
        }

        private function get _playerHandler() : CPlayerHandler {
            return _system.getBean(CPlayerHandler) as CPlayerHandler;
        }
    }
}
