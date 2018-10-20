//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/8.
 * Time: 16:30
 */
package kof.game.talent.talentFacade.talentSystem.view {

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Point;
    import flash.utils.setTimeout;

    import kof.game.common.CLang;

    import kof.game.talent.talentFacade.CTalentFacade;
    import kof.game.talent.talentFacade.talentSystem.enums.ETalentColorType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentMainType;
import kof.game.talent.talentFacade.talentSystem.enums.ETalentPageType;
    import kof.game.talent.talentFacade.talentSystem.enums.ETalentPointStateType;
    import kof.game.talent.talentFacade.talentSystem.enums.ETalentPointTakeOffType;
    import kof.game.talent.talentFacade.talentSystem.mediator.CAbstractTalentMediator;
import kof.game.talent.talentFacade.talentSystem.mediator.CTalentMediator;
import kof.game.talent.talentFacade.talentSystem.proxy.CTalentDataManager;
    import kof.game.talent.talentFacade.talentSystem.proxy.data.CTalentWarehouseData;
    import kof.table.PassiveSkillPro;
    import kof.table.TalentSoul;
import kof.ui.demo.talentSys.TalentIco2UI;
import kof.ui.demo.talentSys.TalentIco3UI;
import kof.ui.demo.talentSys.TalentIcoUI;
    import kof.ui.demo.talentSys.TalentItemUI;
    import kof.ui.demo.talentSys.TalentSelectUI;

    import morn.core.components.Box;
    import morn.core.components.Button;
    import morn.core.components.Component;
    import morn.core.components.Label;
    import morn.core.components.List;
    import morn.core.events.DragEvent;
    import morn.core.handlers.Handler;

    import spine.animation.EventTimeline;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/8
     */
    public class CTalentPointSelectView extends CAbstractTalentView {
        private var _talentSelectUI : TalentSelectUI = null;
        private var _parentContainer : Sprite = null;
        private var _selectList : List = null;
        private var _pointID : int = 0;
        private var _mainViewSelectSoulConfigId : Number = 0;

        public function CTalentPointSelectView( mediator : CAbstractTalentMediator ) {
            super( mediator );
            _mediator = mediator;
            _talentSelectUI = new TalentSelectUI();
            _selectList = (_talentSelectUI.getChildByName( "select" ) as Box).getChildByName( "list" ) as List;
            _selectList.renderHandler = new Handler( _onRender );
            if ( !_talentSelectUI.stage ) {
                _talentSelectUI.addEventListener( Event.ADDED_TO_STAGE, _addStage );
            } else {
                _addStage( null );
            }
        }

        private function _addStage( e : Event ) : void {
            _talentSelectUI.removeEventListener( Event.ADDED_TO_STAGE, _addStage );
            _talentSelectUI.stage.addEventListener( MouseEvent.MOUSE_MOVE, _onMove );
            _talentSelectUI.stage.addEventListener( Event.REMOVED_FROM_STAGE, _onRemove );
        }

        private function _onRemove( e : Event ) : void {
            _talentSelectUI.stage.removeEventListener( MouseEvent.MOUSE_MOVE, _onMove );
            _talentSelectUI.stage.removeEventListener( Event.REMOVED_FROM_STAGE, _onRemove );
        }

        private function _onMove( e : MouseEvent ) : void {
            if ( _parentContainer ) {
                var pt : Point = _parentContainer.localToGlobal( new Point( _talentSelectUI.x, _talentSelectUI.y ) );
                var w : Number = pt.x + _talentSelectUI.width;
                var h : Number = pt.y + _talentSelectUI.height;
                if ( !_talentSelectUI.stage ) {
                    return;
                }
                var stageW : Number = _talentSelectUI.stage.stageWidth;
                var stageH : Number = _talentSelectUI.stage.stageHeight;
                var stageX : Number = 0;
                var stageY : Number = 0;
                if ( pt.x > 0 && pt.y > 0 && w < stageW && h < stageH ) {
                    return;
                }
                if ( pt.x < 0 ) {
                    stageX = 0;
                    pt = _parentContainer.globalToLocal( new Point( stageX, pt.y ) );
                    _talentSelectUI.x = pt.x;
                    _talentSelectUI.y = pt.y;
                }
                if ( pt.y < 0 ) {
                    stageY = 0;
                    pt = _parentContainer.globalToLocal( new Point( pt.x, stageY ) );
                    _talentSelectUI.x = pt.x;
                    _talentSelectUI.y = pt.y;
                }
                if ( pt.x < 0 && pt.y < 0 ) {
                    stageX = 0;
                    stageY = 0;
                    pt = _parentContainer.globalToLocal( new Point( stageX, stageY ) );
                    _talentSelectUI.x = pt.x;
                    _talentSelectUI.y = pt.y;
                }
                if ( w > stageW ) {
                    stageX = stageW - _talentSelectUI.width;
                    pt = _parentContainer.globalToLocal( new Point( stageX, pt.y ) );
                    _talentSelectUI.x = pt.x;
                    _talentSelectUI.y = pt.y;
                }
                if ( h > stageH ) {
                    stageY = stageH - _talentSelectUI.height;
                    pt = _parentContainer.globalToLocal( new Point( pt.x, stageY ) );
                    _talentSelectUI.x = pt.x;
                    _talentSelectUI.y = pt.y;
                }
                if ( w > stageW && h > stageH ) {
                    stageX = stageW - _talentSelectUI.width;
                    stageY = stageH - _talentSelectUI.height;
                    pt = _parentContainer.globalToLocal( new Point( stageX, stageY ) );
                    _talentSelectUI.x = pt.x;
                    _talentSelectUI.y = pt.y;
                }
            }
        }

        private function _onRender( item : Component, idx : int ) : void {
            var talentWarehouseData : CTalentWarehouseData = item.dataSource as CTalentWarehouseData;
            if ( !talentWarehouseData ) {
                return;
            }
            var talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( talentWarehouseData.soulConfigID );
            var talentItem : TalentItemUI = item as TalentItemUI;
            (talentItem.getChildByName( "nuTxt" ) as Label).text = talentWarehouseData.soulNum + "";
            (talentItem.getChildByName( "nameTxt" ) as Label).text = CTalentFacade.getInstance().getTalentName(talentSoul.ID);
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
                    (talentItem.getChildByName( "ptxt" + usedNu ) as Label).text = passiveSkillPro.name;
                    (talentItem.getChildByName( "vtxt" + usedNu ) as Label).text = "+" + addvalue;
                }
                if ( percent != 0 ) {
                    usedNu++;
                    (talentItem.getChildByName( "ptxt" + usedNu ) as Label).text = passiveSkillPro.name + CLang.Get( "bafenbi" );
                    (talentItem.getChildByName( "vtxt" + usedNu ) as Label).text = "+" + percent + "%";
                }
            }
            for ( var j : int = usedNu + 1; j < 5; j++ ) {
                (talentItem.getChildByName( "ptxt" + j ) as Label).text = "";
                (talentItem.getChildByName( "vtxt" + j ) as Label).text = "";
            }
            (talentItem.getChildByName( "btn" ) as Button).clickHandler = new Handler( _embedTalentPoint, [ talentWarehouseData.soulConfigID ] );
            var icoItem : Object = null;
            if((_mediator as CTalentMediator).talentMainView.currentPage==ETalentPageType.BEN_YUAN){
//                item.getChildByName( "icoItem" ).visible = _pointID < 31;
//                item.getChildByName( "icoItem1" ).visible = false;
//                icoItem = item.getChildByName( "icoItem" ) as TalentIcoUI;

                item.getChildByName( "icoItem" ).visible = talentSoul.mainType != ETalentMainType.ONLY;
                item.getChildByName( "icoItem1" ).visible = false;
                talentItem.view_iconItem2.visible = talentSoul.mainType == ETalentMainType.ONLY;

                if(talentSoul.mainType == ETalentMainType.ONLY)
                {
                    icoItem = item.getChildByName( "icoItem2" ) as TalentIco3UI;
                }
                else
                {
                    icoItem = item.getChildByName( "icoItem" ) as TalentIcoUI;
                }

            }else{
//                item.getChildByName( "icoItem" ).visible = false;
//                item.getChildByName( "icoItem1" ).visible = _pointID < 31;
//                icoItem = item.getChildByName( "icoItem1" ) as TalentIco2UI;

                item.getChildByName( "icoItem" ).visible = false;
                item.getChildByName( "icoItem1" ).visible = talentSoul.mainType != ETalentMainType.ONLY;
                talentItem.view_iconItem2.visible = talentSoul.mainType == ETalentMainType.ONLY;

                if(talentSoul.mainType == ETalentMainType.ONLY)
                {
                    icoItem = item.getChildByName( "icoItem2" ) as TalentIco3UI;
                }
                else
                {
                    icoItem = item.getChildByName( "icoItem1" ) as TalentIco2UI;
                }
            }

            icoItem.btn.visible = false;
            icoItem.txt1.visible = false;
            icoItem.txt2.visible = false;
            icoItem.kuangClip.visible = false;
            if(icoItem.hasOwnProperty("frameClip_around"))
            {
                icoItem.frameClip_around.autoPlay = false;
                icoItem.frameClip_around.visible = false;
            }

            if(icoItem.hasOwnProperty("frameClip_lock"))
            {
                icoItem.frameClip_lock.autoPlay = false;
                icoItem.frameClip_lock.visible = false;
            }

            icoItem.ico.url = CTalentFacade.getInstance().getTalentIcoPath( talentSoul.icon );
            var colorIndex : int = CTalentFacade.getInstance().getTalentPointColorIndexForTalentMainType( talentSoul.mainType );
            icoItem.kuangClip.index = colorIndex;
            _visibleLvClip( icoItem );
//            icoItem.lvClipWhite.visible = false;
//            if ( colorIndex == ETalentColorType.BLUE ) {
//                _visibleLvClip( icoItem );
//                icoItem.lvClipBlue.visible = false;
//                icoItem.lvClipBlue.index = talentSoul.quality - 1;
//            }
//            else if ( colorIndex == ETalentColorType.GREEN ) {
//                _visibleLvClip( icoItem );
//                icoItem.lvClipGreen.visible = false;
//                icoItem.lvClipGreen.index = talentSoul.quality - 1;
//            }
//            else if ( colorIndex == ETalentColorType.ORANGE ) {
//                _visibleLvClip( icoItem );
//                icoItem.lvClipOrange.visible = false;
//                icoItem.lvClipOrange.index = talentSoul.quality - 1;
//            }
//            else if ( colorIndex == ETalentColorType.PURPLE ) {
//                _visibleLvClip( icoItem );
//                icoItem.lvClipPurple.visible = false;
//                icoItem.lvClipPurple.index = talentSoul.quality - 1;
//            }
//            else if ( colorIndex == ETalentColorType.COLOR_6 ) {
//                _visibleLvClip( icoItem );
//                icoItem.lvClipHuang.visible = false;
//                icoItem.lvClipHuang.index = talentSoul.quality - 1;
//            }
//            else if ( colorIndex == ETalentColorType.COLOR_7 ) {
//                _visibleLvClip( icoItem );
//                icoItem.lvClipHong.visible = false;
//                icoItem.lvClipHong.index = talentSoul.quality - 1;
//            }
        }

        private function _formatStr( str : String ) : String {
            str = str.replace( "[", "" );
            str = str.replace( "]", "" );
            return str;
        }

        private function _visibleLvClip( icoItem : Object ) : void
        {
            if(icoItem.hasOwnProperty("lvClipWhite")) icoItem.lvClipWhite.visible = false;
            if(icoItem.hasOwnProperty("lvClipBlue")) icoItem.lvClipBlue.visible = false;
            if(icoItem.hasOwnProperty("lvClipGreen")) icoItem.lvClipGreen.visible = false;
            if(icoItem.hasOwnProperty("lvClipOrange")) icoItem.lvClipOrange.visible = false;
            if(icoItem.hasOwnProperty("lvClipPurple")) icoItem.lvClipPurple.visible = false;
            if(icoItem.hasOwnProperty("lvClipHuang")) icoItem.lvClipHuang.visible = false;
            if(icoItem.hasOwnProperty("lvClipHong")) icoItem.lvClipHong.visible = false;
        }

        private function _embedTalentPoint( soulID : int ) : void {
//            _mediator.contact( this, ETalentViewType.MAIN , {} )
            _talentSelectUI.visible = false;
            var id:Number = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage(_pointID,CTalentMediator(_mediator).talentMainView.currentPage).ID;
            CTalentFacade.getInstance().requestMosaicReplace( id, soulID );
        }

        private function _valRender( item : Component, idx : int ) : void {
            var str : String = String( item.dataSource );
            var pro : Array = str.split( ":" );
            var box : Box = item as Box;
            (box.getChildByName( "txt" ) as Label).text = CTalentFacade.getInstance().getPassiveSkillProData( int( pro[ 0 ] ) ).name;
        }

        public function set parentContainer( ui : Sprite ) : void {
            _parentContainer = ui;
            _parentContainer.getChildByName( "bg" ).addEventListener( MouseEvent.CLICK, _onClick );
        }

        private function _onClick( e : MouseEvent ) : void {
            if ( _talentSelectUI.visible ) {
                _talentSelectUI.visible = false;
//                _parentContainer.getChildByName( "mask" ).visible = false;
            }
        }

        override public function show( data : Object = null ) : void {
            _talentSelectUI.visible = true;
//            _parentContainer.getChildByName( "mask" ).visible = true;
            this._pointID = data.data.pointID;
            this._mainViewSelectSoulConfigId = data.data.soulConfigId;
            var vec : Vector.<CTalentWarehouseData> = CTalentDataManager.getInstance().getTalentPointForWarehouse( data.data.pointID ,(_mediator as CTalentMediator).talentMainView.currentPage);
            var x : Number = data.data.x;
            var y : Number = data.data.y;
            var selectUI : Box = _talentSelectUI.getChildByName( "select" ) as Box;
            var notPointUI : Box = _talentSelectUI.getChildByName( "notPoint" ) as Box;
            if (vec.length|| data.data.state == ETalentPointStateType.EMBED ) {
                notPointUI.visible = false;
                var arr : Array = [];
                vec.forEach( function toArray( item : CTalentWarehouseData, index : int, vec : Vector.<CTalentWarehouseData> ) : void {
                    arr.push( item );
                } );
                _selectList.dataSource = arr;
                arr.sort( _sortTalent );
                var len : int = arr.length;
                if ( len < 2 ) {
                    _selectList.repeatX = len;
                    _selectList.repeatY = len;
                }
                else {
                    _selectList.repeatX = 2;
                    _selectList.repeatY = 2;
                }
                setTimeout( function setSize() : void {
                    _selectList.scrollBar.scrollSize = 5;
                }, 1.5 );
                if ( data.data.state == ETalentPointStateType.OPEN_CAN_EMBED ) {
                    (selectUI.getChildByName( "unload" ) as Box).visible = false;
                    _talentSelectUI.unload.visible=false;
                    selectUI.visible=true;
                    _talentSelectUI.x = x + 70;
                    if ( y > 500 ) {
                        _talentSelectUI.y = y - 60;
                    } else {
                        _talentSelectUI.y = y;
                    }
                }
                else if ( data.data.state == ETalentPointStateType.EMBED ) {
                    if(vec.length==0){
                        selectUI.visible=false;
                        _talentSelectUI.unload.visible=true;
                        (_talentSelectUI.unload.getChildByName( "unloadBtn" ) as Button).clickHandler = new Handler( _unLoadTalentPoint );
                        _talentSelectUI.x = x + 70;
                        _talentSelectUI.y = y + 100;
                    }else{
                        _talentSelectUI.unload.visible=false;
                        selectUI.visible = true;
                        (selectUI.getChildByName( "unload" ) as Box).visible = true;
                        ((selectUI.getChildByName( "unload" ) as Box).getChildByName( "unloadBtn" ) as Button).clickHandler = new Handler( _unLoadTalentPoint );
                        _talentSelectUI.x = x + 70;
                        if ( y > 500 ) {
                            _talentSelectUI.y = y - 60;
                        } else {
                            _talentSelectUI.y = y;
                        }
                    }
                }
            }
            else {
                notPointUI.visible = true;
                var shopSkipBtn : Label = (notPointUI.getChildByName( "shopSkipBtn" ) as Label);
                shopSkipBtn.buttonMode = true;
                shopSkipBtn.mouseChildren = true;
                shopSkipBtn.addEventListener( MouseEvent.CLICK, _shopSkipBtn );
                var currentPage:int=CTalentMediator(_mediator).talentMainView.currentPage;
                if(currentPage==ETalentPageType.BEN_YUAN){
                    shopSkipBtn.text = "斗魂商店";
                }else{
                    shopSkipBtn.text = "扭蛋商店";
                }

                selectUI.visible = false;
                _talentSelectUI.unload.visible=false;
                _talentSelectUI.x = x + 70;
                _talentSelectUI.y = y;
            }
            _parentContainer.addChild( _talentSelectUI );
            _onMove( null );
        }

        private function _shopSkipBtn( e : MouseEvent ) : void {
            var currentPage:int=CTalentMediator(_mediator).talentMainView.currentPage;
            CTalentFacade.getInstance().showShopTalent(currentPage);
        }

        private function _sortTalent( a : CTalentWarehouseData, b : CTalentWarehouseData ) : int {
            var a_talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( a.soulConfigID );
            var b_talentSoul : TalentSoul = CTalentFacade.getInstance().getTalentSoul( b.soulConfigID );
            if ( a_talentSoul.quality > b_talentSoul.quality ) {
                return -1;
            } else if ( a_talentSoul.quality < b_talentSoul.quality ) {
                return 1;
            } else {
                if ( a_talentSoul.mainType > b_talentSoul.mainType ) {
                    return -1;
                } else if ( a_talentSoul.mainType < b_talentSoul.mainType ) {
                    return 1;
                } else {
                    if ( a_talentSoul.ID > b_talentSoul.ID ) {
                        return -1;
                    } else if ( a_talentSoul.ID < b_talentSoul.ID ) {
                        return 1;
                    } else {
                        return 0;
                    }
                }
            }
        }

        private function _unLoadTalentPoint() : void {
            _talentSelectUI.visible = false;
            var id:Number = CTalentFacade.getInstance().getTalentPointSoulForPointIDAndPage(_pointID,CTalentMediator(_mediator).talentMainView.currentPage).ID;
            CTalentFacade.getInstance().requestTakeOff( ETalentPointTakeOffType.UNLOAD, ETalentPageType.BEN_YUAN, id );
        }

        override public function close() : void {
            if ( _parentContainer.contains( _talentSelectUI ) ) {
                _parentContainer.removeChild( _talentSelectUI );
            }
        }

        override public function update() : void {

        }

        public function hide():void{
            _talentSelectUI.visible = false;
        }
    }
}
