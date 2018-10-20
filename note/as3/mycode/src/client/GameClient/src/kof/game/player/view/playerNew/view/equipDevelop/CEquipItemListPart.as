//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/22.
 * Time: 16:55
 */
package kof.game.player.view.playerNew.view.equipDevelop {

    import kof.game.bag.data.CBagData;
    import kof.game.common.CLang;
    import kof.game.player.config.CPlayerPath;
    import kof.game.player.data.CHeroEquipData;
    import kof.game.player.data.CPlayerHeroData;
    import kof.game.player.view.equipmentTrain.CEquTipsView;
    import kof.game.player.view.playerNew.panel.CEquipDevelopPanel;
    import kof.game.player.view.playerNew.util.CPlayerHelpHandler;
    import kof.ui.imp_common.RewardItemUI;
    import kof.ui.master.JueseAndEqu.EquItemUI;
    import kof.ui.master.jueseNew.panel.EquipUI;
    import kof.ui.master.jueseNew.render.EquipItemUI;

    import morn.core.components.Component;
    import morn.core.handlers.Handler;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/22
     */
    public class CEquipItemListPart extends CAbstractEquipPart {
        private var _pView : EquipUI = null;
        private var _currentEquipIndex : int = 0;
        private var _currentTabIndex : int = 0;
        private var _tipsView : CEquTipsView = null;

        public function CEquipItemListPart( panel : CEquipDevelopPanel ) {
            super( panel );
            _pView = panel.equipUI;
            _pView.equipItemList.renderHandler = new Handler( _renderEquipItemList );
            _pView.equipItemList.selectHandler = new Handler( _selectItemHandler );
            _pView.tab.selectHandler = new Handler( _tabSelectHandler );
            _pView.tab.selectedIndex = 0;
            _tipsView = new CEquTipsView();
        }

        public function get currentEquipIndex() : int {
            return _currentEquipIndex;
        }

        public function get currentTabIndex() : int {
            return _currentTabIndex;
        }

        public function set currentTabIndex( value : int ) : void {
            _currentEquipIndex = value;
            _pView.equipItemList.selectedIndex = 0;
            _pView.tab.selectedIndex = value;
            _setItemSelected();
        }

        override protected function _update( data : CPlayerHeroData ) : void {
            _pView.txt_heroName.stroke = _pData.strokeColor;
            _pView.txt_heroName.text = (_pPanel.system.getBean( CPlayerHelpHandler ) as CPlayerHelpHandler).getHeroWholeName( _pData );//格斗家名字
            _pView.img_hero.url = CPlayerPath.getUIHeroFacePath( _pData.prototypeID ); //格斗家半身像
//            _pView.img_hero.alpha = 1;
            _pView.equipItemList.dataSource = data.equipList.toArray();
            _setItemSelected();
        }

        private function _tabSelectHandler( index : int ) : void {
            if ( _currentTabIndex == index ) return;
            _currentTabIndex = index;
            if ( _pView.tab.selectedIndex == 0 ) {
                _pPanel.lvAndQuality.selectEquipIndex = _currentEquipIndex;
            } else {
                _pPanel.awake.selectEquipIndex = _currentEquipIndex;
            }
            _setItemSelected();
        }

        private function _selectItemHandler( index : int ) : void {
            if ( _currentEquipIndex == index ) return;
            if ( _pView.tab.selectedIndex == 0 ) {
                _pPanel.lvAndQuality.selectEquipIndex = index;
            }
            else {
                _pPanel.awake.selectEquipIndex = index;
            }
            _currentEquipIndex = index;
            _setItemSelected();
        }

        //设置选中状态
        private function _setItemSelected() : void {
            _resetState();
            var equipData : CHeroEquipData = _pData.equipList.toArray()[ _currentEquipIndex ];
            var itemUI : EquipItemUI = _pView.equipItemList.getCell( _currentEquipIndex ) as EquipItemUI;
            itemUI.selected.visible = true;
            itemUI.btn.selected = true;
        }

        private function _resetState() : void {
            for ( var i : int = 0; i < _pView.equipItemList.length; i++ ) {
                var itemUI : EquipItemUI = _pView.equipItemList.getCell( i ) as EquipItemUI;
                itemUI.selected.visible = false;
                itemUI.btn.selected = false;
            }
        }

        private function _renderEquipItemList( item : Component, idx : int ) : void {
            var itemUI : EquipItemUI = item as EquipItemUI;
            var equiData : CHeroEquipData = itemUI.dataSource as CHeroEquipData;
            itemUI.heroName.text = equiData.nameQualityWithColor;
            itemUI.heroName.isHtml = true;
            itemUI.lv.text = CLang.Get( "equip_level" ) + equiData.level;
            var rewardItemUI : RewardItemUI = itemUI.rewardItem;
            rewardItemUI.num_lable.text = "";
            rewardItemUI.bg_clip.index = equiData.qualityLevelValue + 1;
            rewardItemUI.icon_image.url = equiData.smallIcon;
            var arr : Array = [];
            for ( var i : int = 0; i < equiData.star; i++ ) {
                arr.push( 1 );
            }
            itemUI.starList.repeatX = equiData.star;
            itemUI.starList.dataSource = arr;

            itemUI.toolTip = new Handler( _showTips, [ itemUI, equiData, rewardItemUI ] );

            itemUI.redpt.visible = judgeRedPt( equiData ) && _pPanel.isEquipOpen(equiData);

            itemUI.img_blackBg.visible = !_pPanel.isEquipOpen(equiData);
            itemUI.img_lock.visible = itemUI.img_blackBg.visible;
            itemUI.txt_openInfo.visible = itemUI.img_blackBg.visible;
            if(itemUI.txt_openInfo.visible)
            {
                itemUI.txt_openInfo.text = "战队等级" + _pPanel.getEquipOpenLevel(equiData) + "级开启";
            }
            else
            {
                itemUI.txt_openInfo.text = "";
            }

            itemUI.lv.visible = !itemUI.img_blackBg.visible;
            itemUI.box_star.visible = !itemUI.img_blackBg.visible;
        }

        private function _showTips( item : EquipItemUI, equiData : CHeroEquipData, rewardItemUI : RewardItemUI ) : void {
            var equItemUI : EquItemUI = new EquItemUI();
            equItemUI.name_label.text = item.heroName.text;
            equItemUI.icon_img.url = rewardItemUI.icon_image.url;
            equItemUI.quality_clip.index = rewardItemUI.bg_clip.index;
            equItemUI.quality_list.visible = false;
            equItemUI.star_list.repeatX = item.starList.repeatX;
            equItemUI.star_list.dataSource = item.starList.dataSource;
            var arr : Array = [];
            for ( var j : int = 0; j < equiData.qualityLevelSubValue; j++ ) {
                arr.push( equiData );
            }

            equItemUI.quality_list.repeatX = equiData.qualityLevelSubValue;
            equItemUI.quality_list.dataSource = arr;
            var proArr : Array = showProNameAndValue( equiData, EPropertyType.CURRENT_PROPERTY );
            _tipsView.showEquiTips( equItemUI, equiData, proArr );
        }

        private function _renderEquipItem( item : Component, idx : int ) : void {
            var itemUI : EquipItemUI = item as EquipItemUI;
            var equipData : CHeroEquipData = item.dataSource as CHeroEquipData;
            var url : String = equipData.bigIcon;
            if ( equipData.part > 4 ) {
                var atk : String = "0";
                var def : String = "0";
                var hp : String = "0";
                if ( equipData.propertyData.PercentEquipATK > 0 ) {
                    atk = (equipData.propertyData.PercentEquipATK / 100).toFixed( 2 ) + "%";
                }
                if ( equipData.propertyData.PercentEquipDEF > 0 ) {
                    def = (equipData.propertyData.PercentEquipDEF / 100).toFixed( 2 ) + "%";
                }
                if ( equipData.propertyData.PercentEquipHP > 0 ) {
                    hp = (equipData.propertyData.PercentEquipHP / 100).toFixed( 2 ) + "%";
                }
            }
        }

    }
}
