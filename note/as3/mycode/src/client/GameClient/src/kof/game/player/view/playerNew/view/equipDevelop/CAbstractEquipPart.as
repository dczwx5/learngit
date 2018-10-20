//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/22.
 * Time: 16:57
 */
package kof.game.player.view.playerNew.view.equipDevelop {

    import kof.game.bag.data.CBagData;
    import kof.game.common.CLang;
    import kof.game.player.data.CHeroEquipData;
    import kof.game.player.data.CPlayerHeroData;
    import kof.game.player.data.property.CHeroEquipProperty;
    import kof.game.player.view.playerNew.panel.CEquipDevelopPanel;
    import kof.table.Currency;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/22
     */
    public class CAbstractEquipPart {
        protected var _pPanel : CEquipDevelopPanel = null;
        protected var _pData : CPlayerHeroData = null;
        protected var _selectEquipIndex : int = 0;

        public function CAbstractEquipPart( panel : CEquipDevelopPanel ) {
            _pPanel = panel;
        }

        public function set data( value : CPlayerHeroData ) : void {
            _pData = value;
            if ( value ) {
                _update( value );
            }
        }

        public function set selectEquipIndex( value : int ) : void {
            this._selectEquipIndex = value;
            var equiData : CHeroEquipData = _pData.equipList.toArray()[ value ];
            _pPanel.recordCurrentPropertyValue( equiData );
            _show( equiData );
        }

        protected function _show( data : CHeroEquipData ) : void {
            if(!_pPanel.isEquipOpen(data)) {
                _pPanel.equipUI.img_red1.visible = false;
            }else if ( _isCanUpLv( data ) ) {
                _pPanel.equipUI.img_red1.visible = true;
            } else if ( _isCanUpQulity( data ) ) {
                _pPanel.equipUI.img_red1.visible = true;
            } else {
                _pPanel.equipUI.img_red1.visible = false;
            }

            if(!_pPanel.isEquipOpen(data)) {
                _pPanel.equipUI.img_red1.visible = false;
            }else if ( _isCanUpStar( data ) ) {
                _pPanel.equipUI.img_red2.visible = true;
            }
            else {
                _pPanel.equipUI.img_red2.visible = false;
            }
        }

        public function get data() : CPlayerHeroData {
            return _pData;
        }

        protected function _update( data : CPlayerHeroData ) : void {

        }

        public function visible() : void {

        }

        protected function showProNameAndValue( data : CHeroEquipData, nextProType : int ) : Array {
            var arr : Array = [];
            var equipPropertyData : CHeroEquipProperty = null;
            if ( nextProType == EPropertyType.CURRENT_PROPERTY ) {
                equipPropertyData = data.currentProperty;
            } else if ( nextProType == EPropertyType.NEXT_LEVEL ) {
                if ( data.level + 1 > CHeroEquipData.EQUIP_MAX_LEVEL ) {
                    equipPropertyData = data.currentProperty;
                } else {
                    equipPropertyData = data.nextLevelProperty;
                }
            } else if ( nextProType == EPropertyType.NEXT_QUALITY ) {
                equipPropertyData = data.nextQualityProperty;
            } else if ( nextProType == EPropertyType.NEXT_STAR ) {
                equipPropertyData = data.nextAwakenProperty;
            }
            var hp : Number = equipPropertyData.HP;
            var attack : Number = equipPropertyData.Attack;
            var defense : Number = equipPropertyData.Defense;
            var hpPercent : Number = equipPropertyData.PercentEquipHP;
            var attackPercent : Number = equipPropertyData.PercentEquipATK;
            var denfensePercent : Number = equipPropertyData.PercentEquipDEF;
            if ( hp > 0 ) {
                arr.push( {name : "装备" + CLang.Get( "player_hp" ), value : hp + ""} );
            }
            if ( attack > 0 ) {
                arr.push( {name : "装备" + CLang.Get( "player_attack" ), value : attack + ""} );
            }
            if ( defense > 0 ) {
                arr.push( {name : "装备" + CLang.Get( "player_denfense" ), value : defense + ""} );
            }
            if ( hpPercent > 0 ) {
                arr.push( {
                    name : "装备" + CLang.Get( "player_hp" ),
                    value : hpPercent * 100 / 10000 + "%"
                } );
            }
            if ( attackPercent > 0 ) {
                arr.push( {
                    name : "装备" + CLang.Get( "player_attack" ),
                    value : attackPercent * 100 / 10000 + "%"
                } );
            }
            if ( denfensePercent > 0 ) {
                arr.push( {
                    name : "装备" + CLang.Get( "player_denfense" ),
                    value : denfensePercent * 100 / 10000 + "%"
                } );
            }
            return arr;
        }

        public function judgeRedPt( data : CHeroEquipData ) : Boolean
        {
            if(!_pPanel.isEquipOpen(data))
            {
                return false;
            }

            if ( _isCanUpLv( data ) ) {
                return true;
            }

            if ( _isCanUpQulity( data ) ) {
                return true;
            }

            return _isCanUpStar( data );
        }

        /**
         * 能否装备升级
         * @param data
         * @return
         */
        protected function _isCanUpLv( data : CHeroEquipData ) : Boolean {
            if(!_pPanel.isEquipStrengOpen())
            {
                return false;
            }

            if ( data.level+1 > _pPanel.playerData.teamData.level )return false;
            if ( data.isCanLevelUp() ) {
                if ( data.part > 4 ) {
                    if(!_pPanel.isEquipOpen(data))
                    {
                        return false;
                    }

                    if ( data.nextLevelGoldCost <= _pPanel.playerData.currency.gold ) {
                        if ( data.nextLevelOtherCurrencyType == 10 ) {
                            if ( data.nextLevelOtherCurrencyCost <= _pPanel.playerData.equipData.huizhang ) {
                                return true;
                            }
                        }
                        if ( data.nextLevelOtherCurrencyType == 11 ) {
                            if ( data.nextLevelOtherCurrencyCost <= _pPanel.playerData.equipData.miji ) {
                                return true;
                            }
                        }
                    }
                } else if ( data.nextLevelGoldCost <= _pPanel.playerData.currency.gold ) {
                    return true;
                }
            }
            return false;
        }

        /**
         * 能否装备升品
         * @param data
         * @return
         */
        protected function _isCanUpQulity( data : CHeroEquipData ) : Boolean {
            if(!_pPanel.isEquipStrengOpen())
            {
                return false;
            }

            if(data.isCanLevelUp())return false;
            if ( data.nextQualityTeamLevelNeed > _pPanel.playerData.teamData.level )return false;
            if ( data.part > 4 ) {
                if(!_pPanel.isEquipOpen(data))
                {
                    return false;
                }

                if ( data.nextQualityGoldCost <= _pPanel.playerData.currency.gold ) {
                    if ( data.nextQualityOtherCurrencyType == 10 ) {
                        if ( data.nextQualityOtherCurrencyCost <= _pPanel.playerData.equipData.huizhang ) {
                            if ( isCanQuality( data ) ) {
                                return true;
                            }
                        }
                    }
                    if ( data.nextQualityOtherCurrencyType == 11 ) {
                        if ( data.nextQualityOtherCurrencyCost <= _pPanel.playerData.equipData.miji ) {
                            if ( isCanQuality( data ) ) {
                                return true;
                            }
                        }
                    }
                }
            } else if ( data.nextQualityGoldCost <= _pPanel.playerData.currency.gold ) {
                if ( isCanQuality( data ) ) {
                    return true;
                }
            }
            return false;
        }

        private function isCanQuality( data : CHeroEquipData ) : Boolean {
            if(!_pPanel.isEquipStrengOpen())
            {
                return false;
            }

            var bagDataVec : Vector.<CBagData> = data.nextQualityItemCost;
            for each ( var value : CBagData in bagDataVec ) {
                var hasBagData : CBagData = _pPanel.bagManager.getBagItemByUid( value.itemID );
                if ( hasBagData ) {
                    if ( hasBagData.num < value.num ) {
                        return false;
                    }
                } else {
                    return false;
                }
            }
            return true;
        }

        /**
         * 能否装备觉醒
         * @param data
         * @return
         */
        protected function _isCanUpStar( data : CHeroEquipData ) : Boolean {
            if(!_pPanel.isEquipBreakOpen())
            {
                return false;
            }

            if ( data.nextAwakenTeamLevelNeed > _pPanel.playerData.teamData.level )return false;
            var hasBagData : CBagData = null;
            if ( data.isExclusive ) {//是否专属，已废弃，没有专属设计了
                hasBagData = _pPanel.bagManager.getBagItemByUid( data.awakenSoulID ); //当前拥有
                if ( hasBagData ) {
                    if ( hasBagData.num >= data.nextAwakenSoulCost ) {
                        hasBagData = _pPanel.bagManager.getBagItemByUid( data.nextAwakenStoneType ); //当前拥有
                        if ( hasBagData ) {
                            if ( hasBagData.num >= data.nextAwakenStoneCost ) {
                                if ( data.nextAwakenGoldCost <= _pPanel.playerData.currency.gold ) {
                                    return true;
                                }
                            }
                        }
                    }
                }
            } else {

                hasBagData = _pPanel.bagManager.getBagItemByUid( data.nextAwakenStoneType ); //当前拥有
                if ( hasBagData ) {
                    if ( hasBagData.num >= data.nextAwakenStoneCost ) {
                        if ( data.nextAwakenGoldCost <= _pPanel.playerData.currency.gold ) {
                            if(data.part>4){

                                return false;// 盾辉和秘卷不开启觉醒功能

                                if(!_pPanel.isEquipOpen(data))
                                {
                                    return false;
                                }

                                if ( data.nextAwakenCurrencyType == 10 ) { //徽章
                                    if ( data.nextAwakenCurrencyCount <= _pPanel.playerData.equipData.huizhang ) {
                                        return true;
                                    }
                                }
                                if ( data.nextAwakenCurrencyType == 11 ) {//秘籍
                                    if ( data.nextAwakenCurrencyCount <= _pPanel.playerData.equipData.miji ) {
                                        return true;
                                    }
                                }
                            }else{
                                return true;
                            }
                        }
                    }
                }
            }
            return false;
        }
    }
}
