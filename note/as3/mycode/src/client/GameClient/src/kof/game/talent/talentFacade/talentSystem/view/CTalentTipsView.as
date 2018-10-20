//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/5/2.
 * Time: 16:45
 */
package kof.game.talent.talentFacade.talentSystem.view {

    import QFLib.Foundation;

    import flash.text.TextField;

    import kof.game.common.CLang;

    import kof.game.talent.talentFacade.CTalentFacade;

    import kof.game.talent.talentFacade.CTalentFacade;
import kof.game.talent.talentFacade.CTalentHelpHandler;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentColorType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentMainType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;

import kof.game.talent.talentFacade.talentSystem.enums.ETalentTipsViewType;
    import kof.game.talent.talentFacade.talentSystem.mediator.CAbstractTalentMediator;
import kof.game.talent.talentFacade.talentSystem.mediator.CTalentMediator;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentConditionData;
import kof.table.PassiveSkillPro;
    import kof.table.TalentSoul;
import kof.ui.demo.talentSys.TalentIco2UI;
import kof.ui.demo.talentSys.TalentIco3UI;
import kof.ui.demo.talentSys.TalentIcoUI;
    import kof.ui.demo.talentSys.TalentTipsUI;

    import morn.core.components.Box;
    import morn.core.components.Component;
    import morn.core.components.Label;
    import morn.core.components.List;
    import morn.core.handlers.Handler;

    public class CTalentTipsView extends CAbstractTalentView {
        private var _tipsUI : TalentTipsUI = null;

        public function CTalentTipsView( mediator : CAbstractTalentMediator ) {
            super( mediator );
            _mediator = mediator;
            _tipsUI = new TalentTipsUI();
        }

        override public function show( data : Object = null ) : void {
            var propertyUI : Box = _tipsUI.getChildByName( "property" ) as Box;
            var canEmbed : Box = _tipsUI.getChildByName( "canEmbed" ) as Box;
            _tipsUI.txt_condition1.visible = false;
            _tipsUI.txt_condition2.visible = false;
            _tipsUI.txt_condition3.visible = false;
            _tipsUI.txt_conditionValue1.visible = false;
            _tipsUI.txt_conditionValue2.visible = false;
            _tipsUI.txt_conditionValue3.visible = false;

            if ( data.data.talentTipsViewType == ETalentTipsViewType.NEXT_OPEN )
            {
                propertyUI.visible = false;
                canEmbed.visible = true;

                _tipsUI.txt_embedType.visible = true;
                _tipsUI.txt_embedType.text = data.data.talenPointTypeDesc;
                _tipsUI.txt_notOpen.visible = true;
                _tipsUI.txt_clickEmbed.visible = false;

                var conditionId:int = data.data.conditionId as int;
                var conditionArr:Array = _helper.getOpenConditionInfo(conditionId, (_mediator as CTalentMediator).talentMainView.currentPage);
                var conditionData:CTalentConditionData;
                if(conditionArr.length >= 1)
                {
                    conditionData = conditionArr[0];
                    _tipsUI.txt_condition1.visible = true;
                    _tipsUI.txt_conditionValue1.visible = true;
                    _tipsUI.txt_condition1.text = conditionData.conditionDesc;
                    _tipsUI.txt_conditionValue1.text = "(" + conditionData.currValue + "/" + conditionData.targetValue + ")";
                    _tipsUI.txt_condition1.color = conditionData.isReachTarget ? 0x00ff00 : 0xff0000;
                    _tipsUI.txt_conditionValue1.color = conditionData.isReachTarget ? 0x00ff00 : 0xff0000;
                }
                else
                {
                    _tipsUI.txt_condition1.visible = false;
                    _tipsUI.txt_conditionValue1.visible = false;
                }

                if(conditionArr.length >= 2)
                {
                    conditionData = conditionArr[1];
                    _tipsUI.txt_condition2.visible = true;
                    _tipsUI.txt_conditionValue2.visible = true;
                    _tipsUI.txt_condition2.text = conditionData.conditionDesc;
                    _tipsUI.txt_conditionValue2.text = "(" + conditionData.currValue + "/" + conditionData.targetValue + ")";
                    _tipsUI.txt_condition2.color = conditionData.isReachTarget ? 0x00ff00 : 0xff0000;
                    _tipsUI.txt_conditionValue2.color = conditionData.isReachTarget ? 0x00ff00 : 0xff0000;
                }
                else
                {
                    _tipsUI.txt_condition2.visible = false;
                    _tipsUI.txt_conditionValue2.visible = false;
                }

                if(conditionArr.length >= 3)
                {
                    conditionData = conditionArr[2];
                    _tipsUI.txt_condition3.visible = true;
                    _tipsUI.txt_conditionValue3.visible = true;
                    _tipsUI.txt_condition3.text = conditionData.conditionDesc;
                    _tipsUI.txt_conditionValue3.text = "(" + conditionData.currValue + "/" + conditionData.targetValue + ")";
                    _tipsUI.txt_condition3.color = conditionData.isReachTarget ? 0x00ff00 : 0xff0000;
                    _tipsUI.txt_conditionValue3.color = conditionData.isReachTarget ? 0x00ff00 : 0xff0000;
                }
                else
                {
                    _tipsUI.txt_condition3.visible = false;
                    _tipsUI.txt_conditionValue3.visible = false;
                }

//                canEmbed.getChildByName( "txt1" ).visible = true;
//                (canEmbed.getChildByName( "txt1" ) as Label).text = data.data.talenPointTypeDesc;
//                canEmbed.getChildByName( "txt2" ).visible = true;
//                canEmbed.getChildByName( "txt3" ).visible = true;
//                canEmbed.getChildByName( "txt4" ).visible = true;
//                (canEmbed.getChildByName( "txt4" ) as Label).text = CTalentFacade.getInstance().teamLevel + "/" + data.data.openLv;
//                if ( CTalentFacade.getInstance().teamLevel >= data.data.openLv ) {
//                    (canEmbed.getChildByName( "txt3" ) as Label).color = 0xff00;
//                    (canEmbed.getChildByName( "txt4" ) as Label).color = 0xff00;
//                } else {
//                    (canEmbed.getChildByName( "txt3" ) as Label).color = 0xff0000;
//                    (canEmbed.getChildByName( "txt4" ) as Label).color = 0xff0000;
//                }
            }
            else if ( data.data.talentTipsViewType == ETalentTipsViewType.OPEN_CAN_EMBED ) {
                propertyUI.visible = false;
                canEmbed.visible = true;
                canEmbed.getChildByName( "txt1" ).visible = true;
                (canEmbed.getChildByName( "txt1" ) as Label).text = data.data.talenPointTypeDesc;
                canEmbed.getChildByName( "txt2" ).visible = false;
                canEmbed.getChildByName( "txt3" ).visible = false;
                canEmbed.getChildByName( "txt4" ).visible = false;
                _tipsUI.txt_clickEmbed.visible = true;
            }
            else if ( data.data.talentTipsViewType == ETalentTipsViewType.OPEN_EMBED ) {
                propertyUI.visible = true;
                _tipsUI.txt_clickEmbed.visible = true;
                var soulID : int = data.data.soulConfigID;
                var mainType : int = data.data.mainType;
                var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( soulID );
                var sProperty : String = _formatStr( talentSoul.propertysAdd );
                var dataArr : Array = sProperty.split( ";" );
                var dataLen : int = dataArr.length;
                var usedNu : int = 0;
                for ( var i : int = 0; i < dataLen; i++ ) {
                    var str : String = String( dataArr[ i ] );
                    if ( !str || str == "" ) {
                        return;
                    }
                    var pro : Array = str.split( ":" );
                    var addvalue : int = int( pro[ 1 ] );
                    var percent : Number = int( pro[ 2 ] ) / 10000 * 100;
                    var passiveSkillPro : PassiveSkillPro = CTalentFacade.getInstance().getPassiveSkillProData( int( pro[ 0 ] ) );
                    if ( addvalue != 0 ) {
                        usedNu++;
                        (propertyUI.getChildByName( "ptxt" + usedNu ) as Label).text = passiveSkillPro.name;
                        (propertyUI.getChildByName( "vtxt" + usedNu ) as Label).text = "+" + addvalue;
                    }
                    if ( percent != 0 ) {
                        usedNu++;
                        (propertyUI.getChildByName( "ptxt" + usedNu ) as Label).text = passiveSkillPro.name + CLang.Get( "bafenbi" );
                        (propertyUI.getChildByName( "vtxt" + usedNu ) as Label).text = "+" + percent + "%";
                    }
                }
                for ( var j : int = usedNu + 1; j < 5; j++ ) {
                    (propertyUI.getChildByName( "ptxt" + j ) as Label).text = "";
                    (propertyUI.getChildByName( "vtxt" + j ) as Label).text = "";
                }
                (propertyUI.getChildByName( "nameTxt" ) as Label).text = CTalentFacade.getInstance().getTalentName(talentSoul.ID);
                (propertyUI.getChildByName( "nuTxt" ) as Label).text = CTalentDataManager.getInstance().getTalentPointNuForSoulID( soulID ) + "";
                var colorIndex : int = CTalentFacade.getInstance().getTalentPointColorIndexForTalentMainType( mainType );
                var talentIcoUI : Object = null;

                if((_mediator as CTalentMediator).talentMainView.currentPage==ETalentPageType.BEN_YUAN){
//                    propertyUI.getChildByName( "icoItem" ).visible = true;
//                    propertyUI.getChildByName( "icoItem1" ).visible = false;
//                    talentIcoUI = propertyUI.getChildByName( "icoItem" ) as TalentIcoUI;

                    propertyUI.getChildByName( "icoItem" ).visible = talentSoul.mainType != ETalentMainType.ONLY;
                    propertyUI.getChildByName( "icoItem1" ).visible = false;
                    _tipsUI.view_icoItem2.visible = talentSoul.mainType == ETalentMainType.ONLY;

                    if(talentSoul.mainType == ETalentMainType.ONLY)
                    {
                        talentIcoUI = propertyUI.getChildByName( "icoItem2" ) as TalentIco3UI;
                    }
                    else
                    {
                        talentIcoUI = propertyUI.getChildByName( "icoItem" ) as TalentIcoUI;
                    }
                }else{
//                    propertyUI.getChildByName( "icoItem" ).visible = false;
//                    propertyUI.getChildByName( "icoItem1" ).visible = true;
//                    talentIcoUI = propertyUI.getChildByName( "icoItem1" ) as TalentIco2UI;


                    propertyUI.getChildByName( "icoItem" ).visible = false;
                    propertyUI.getChildByName( "icoItem1" ).visible = talentSoul.mainType != ETalentMainType.ONLY;
                    _tipsUI.view_icoItem2.visible = talentSoul.mainType == ETalentMainType.ONLY;

                    if(talentSoul.mainType == ETalentMainType.ONLY)
                    {
                        talentIcoUI = propertyUI.getChildByName( "icoItem2" ) as TalentIco3UI;
                    }
                    else
                    {
                        talentIcoUI = propertyUI.getChildByName( "icoItem1" ) as TalentIco2UI;
                    }
                }

                talentIcoUI.ico.url = CTalentFacade.getInstance().getTalentIcoPath( talentSoul.icon );
                talentIcoUI.txt1.visible = false;
                talentIcoUI.txt2.visible = false;
                talentIcoUI.kuangClip.index = colorIndex;
                talentIcoUI.btn.visible = true;

                if(talentIcoUI.hasOwnProperty("lvClipWhite")) talentIcoUI.lvClipWhite.visible = false;
                if(talentIcoUI.hasOwnProperty("lvClipBlue")) talentIcoUI.lvClipBlue.visible = false;
                if(talentIcoUI.hasOwnProperty("lvClipGreen")) talentIcoUI.lvClipGreen.visible = false;
                if(talentIcoUI.hasOwnProperty("lvClipOrange")) talentIcoUI.lvClipOrange.visible = false;
                if(talentIcoUI.hasOwnProperty("lvClipPurple")) talentIcoUI.lvClipPurple.visible = false;
                if(talentIcoUI.hasOwnProperty("lvClipHuang")) talentIcoUI.lvClipHuang.visible = false;
                if(talentIcoUI.hasOwnProperty("lvClipHong")) talentIcoUI.lvClipHong.visible = false;

//                if ( colorIndex == ETalentColorType.BLUE ) {
//                    talentIcoUI.lvClipBlue.visible = false;
//                    talentIcoUI.lvClipBlue.index = talentSoul.quality - 1;
//                }
//                else if ( colorIndex == ETalentColorType.GREEN ) {
//                    talentIcoUI.lvClipGreen.visible = false;
//                    talentIcoUI.lvClipGreen.index = talentSoul.quality - 1;
//                }
//                else if ( colorIndex == ETalentColorType.ORANGE ) {
//                    talentIcoUI.lvClipOrange.visible = false;
//                    talentIcoUI.lvClipOrange.index = talentSoul.quality - 1;
//                }
//                else if ( colorIndex == ETalentColorType.PURPLE ) {
//                    talentIcoUI.lvClipPurple.visible = false;
//                    talentIcoUI.lvClipPurple.index = talentSoul.quality - 1;
//                }
//                else if ( colorIndex == ETalentColorType.COLOR_6 ) {
//                    talentIcoUI.lvClipHuang.visible = false;
//                    talentIcoUI.lvClipHuang.index = talentSoul.quality - 1;
//                }
//                else if ( colorIndex == ETalentColorType.COLOR_7 ) {
//                    talentIcoUI.lvClipHong.visible = false;
//                    talentIcoUI.lvClipHong.index = talentSoul.quality - 1;
//                }

                _tipsUI.getChildByName( "canEmbed" ).visible = false;
            }
            else {
                Foundation.Log.logErrorMsg( "TalentTips类型非法：" + data.data.talentTipsViewType );
            }
            App.tip.addChild( _tipsUI );
        }

        private function _formatStr( str : String ) : String {
            str = str.replace( "[", "" );
            str = str.replace( "]", "" );
            return str;
        }

        override public function close() : void {
             if(_tipsUI.parent){
                 _tipsUI.parent.removeChild(_tipsUI);
             }
        }

        override public function update() : void {

        }

        private function get _helper():CTalentHelpHandler
        {
            return CTalentFacade.getInstance().talentAppSystem.getHandler(CTalentHelpHandler) as CTalentHelpHandler;
        }

    }
}
