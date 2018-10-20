//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 10:27
 */
package kof.game.talent {

    import kof.framework.CSystemHandler;
    import kof.game.talent.talentFacade.CTalentFacade;

    public class CTalentHandler extends CSystemHandler {
        private var _talentFacade:CTalentFacade = null;

        public function CTalentHandler() {
            super();
        }

        override public function dispose() : void {
            super.dispose();
            _talentFacade = null;
        }

        override protected function onSetup():Boolean
        {
            var ret:Boolean = super.onSetup();
            ret = ret&&_init();
            return ret;
        }

        private function _init():Boolean
        {
            _talentFacade = CTalentFacade.getInstance();
            _talentFacade.initTalentNetProxy();
            _talentFacade.netWork = networking;
            _talentFacade.talentAppSystem = system;
            _talentFacade.requestTalentInfoRequest();
            return true;
        }
    }
}
