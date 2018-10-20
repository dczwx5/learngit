//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/18.
 * Time: 10:12
 */
package kof.game.talent.talentFacade.talentSystem.mediator {

    import kof.game.talent.talentFacade.talentSystem.view.CAbstractTalentView;
    import kof.game.talent.talentFacade.talentSystem.view.CTalentBagView;
    import kof.game.talent.talentFacade.talentSystem.view.CTalentFastSellView;
    import kof.game.talent.talentFacade.talentSystem.view.CTalentMainView;
    import kof.game.talent.talentFacade.talentSystem.view.CTalentPointSelectView;
    import kof.game.talent.talentFacade.talentSystem.view.CTalentSellView;
import kof.game.talent.talentFacade.talentSystem.view.CTalentSuitTipsView;
import kof.game.talent.talentFacade.talentSystem.view.CTalentTipsView;
    import kof.game.talent.talentFacade.talentSystem.enums.ETalentViewType;

    public class CTalentMediator extends CAbstractTalentMediator {
        private var _talentMainView : CTalentMainView = null;
        private var _talentTipsView : CTalentTipsView = null;
        private var _talentPointSelectView : CTalentPointSelectView = null;
        private var _talentBagView : CTalentBagView = null;
        private var _talentSellView : CTalentSellView = null;
        private var _talentFastSellView : CTalentFastSellView = null;
        private var _talentSuitTipsView : CTalentSuitTipsView = null;

        public function CTalentMediator() {

        }

        public final function set talentFastSellView( fastSellView : CTalentFastSellView ) : void {
            _talentFastSellView = fastSellView;
        }

        public final function set talentSellView( sellView : CTalentSellView ) : void {
            _talentSellView = sellView;
        }

        public final function set talentBagView( bagView : CTalentBagView ) : void {
            _talentBagView = bagView;
        }

        public final function set talentMainView( mainView : CTalentMainView ) : void {
            _talentMainView = mainView;
        }

        public final function set talentTipsView( tipsView : CTalentTipsView ) : void {
            _talentTipsView = tipsView;
        }

        public final function set talentSuitTipsView( tipsView : CTalentSuitTipsView ) : void {
            _talentSuitTipsView = tipsView;
        }

        public final function set talentSelectPointView( selectPointView : CTalentPointSelectView ) : void {
            _talentPointSelectView = selectPointView;
        }

        public final function get talentMainView():CTalentMainView{
            return _talentMainView;
        }

        public final function get talentSelectPointView():CTalentPointSelectView{
            return _talentPointSelectView;
        }

        //视图间的交互
        override public final function contact( talentView : CAbstractTalentView, viewType : String, data : Object = null ) : void {
            if ( viewType == ETalentViewType.TIPS ) {
                _talentTipsView.show( {talentView : talentView, data : data} );
            }
            if ( viewType == ETalentViewType.SUIT_TIPS ) {
                _talentSuitTipsView.show( {talentView : talentView, data : data} );
            }
            if ( viewType == ETalentViewType.SELECT ) {
                _talentPointSelectView.show( {talentView : talentView, data : data} )
            }
            if ( viewType == ETalentViewType.BAG ) {
                _talentBagView.show( null );
            }
            if ( viewType == ETalentViewType.SELL ) {
//                _talentSellView.show( data );
            }
            if ( viewType == ETalentViewType.FAST_SELL ) {
                _talentFastSellView.show( data );
            }
        }
    }
}
