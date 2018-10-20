//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/25.
 * Time: 15:03
 */
package kof.game.itemGetPath.getPaths.paths {

import QFLib.Foundation;

import flash.events.MouseEvent;

import kof.SYSTEM_TAG;
import kof.game.common.CLang;
import kof.game.common.data.CErrorData;
import kof.game.instance.CInstanceHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.mainInstance.CMainInstanceHandler;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.itemGetPath.CItemGetSystem;
import kof.game.itemGetPath.CItemGetView;
import kof.game.itemGetPath.CItemGetViewHandler;
import kof.game.itemGetPath.getPaths.CAbstractGetPath;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.table.InstanceConstant;
import kof.table.ItemGetPath;
import kof.ui.IUICanvas;
import kof.ui.imp_common.GetItemPathItemUI;

import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/8/25
 */
public class CInstancePath extends CAbstractGetPath {
    private var _instanceData : CChapterInstanceData = null;
    private var _playerData : CPlayerData = null;
    private var _uiCanvas : IUICanvas = null;
    private var _isElite : Boolean = false;
    private var _itemUI : GetItemPathItemUI = null;
    private var _vitIsEnough : Boolean = true;

    public function get instanceData() : CChapterInstanceData {
        return _instanceData;
    }

    public function CInstancePath( itemGetView : CItemGetView ) {
        super( itemGetView );
    }

    override public function getPath( path : String, itemUI : GetItemPathItemUI ) : void {
        _itemUI = itemUI;
        var i : int = 0;
        var arr : Array = path.split( ":" );
        var pathId : int = arr[ 0 ];
        var instanceID : int = arr[ 1 ];
        _instanceData = (_pItemGetView.appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).getInstanceByID( instanceID );
        _playerData = (_pItemGetView.appSystem.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
        _uiCanvas = (_pItemGetView.appSystem.getHandler( CItemGetViewHandler ) as CItemGetViewHandler).uiCanvas;
        var itemGetPath : ItemGetPath = _itemGetPath( pathId );
        itemUI.iconBtn.skin = itemGetPath.iconURL; //途径图标
        itemUI.pathName.text = _instanceData.name; //途径名称
        if ( itemGetPath.sysTag == "ELITE" ) {
            _isElite = true;
        } else {
            _isElite = false;
        }

        itemUI.btn_add.clickHandler = null;
//        itemUI.btn_add.removeEventListener(MouseEvent.CLICK, _buyPowerHandler);
        itemUI.btn_add.visible = false;

        var canchanllenge : Boolean = _judgeCanchanllenge( itemUI );
        if ( canchanllenge ) {
            //如果可以打，肯定就能挑战了,因为_judgeCanchanllenge()方法有体力够不够的判断
            itemUI.btn1.clickHandler = new Handler( challenge, [ instanceID ] );
            ObjectUtils.gray( itemUI.btn1, false );
            itemUI.btn1.mouseEnabled = true;
            var canSweep : Boolean = _judgeSweep( itemUI );
            if ( canSweep ) {// 能扫荡
                itemUI.isunLock.visible = false;
                var leftChanllengeCount : int = 0;
                if ( _instanceData.isElite ) {// 精英副本
                    leftChanllengeCount = _getEliteChanllengeLeftCount();
                    if ( !leftChanllengeCount ) {// 没有剩余挑战次数
                        ObjectUtils.gray( itemUI.btn1, true );
                        ObjectUtils.gray( itemUI.btn2, true );
                        ObjectUtils.gray( itemUI.btn3, true );
                        itemUI.btn1.clickHandler = null;
                        itemUI.btn2.clickHandler = null;
                        itemUI.btn3.clickHandler = null;
                        itemUI.btn1.mouseEnabled = false;
                        itemUI.btn2.mouseEnabled = false;
                        itemUI.btn3.mouseEnabled = false;
                        itemUI.isunLock.text = ("(挑战次数不足)");
                        itemUI.btn_add.visible = true;
                    } else {
                        ObjectUtils.gray( itemUI.btn2, false );
                        itemUI.btn2.mouseEnabled = true;
                        itemUI.btn2.clickHandler = new Handler( sweep, [ 1 ] );
                        itemUI.btn2.label = "扫荡1次";
                        if ( _judgeVipLv() ) {
                            ObjectUtils.gray( itemUI.btn3, false );
                            itemUI.btn3.mouseEnabled = true;
                            itemUI.btn3.label = "扫荡"+leftChanllengeCount+"次";
                            itemUI.btn3.clickHandler = new Handler( sweep, [ leftChanllengeCount ] );
                        } else {
                            itemUI.isunLock.visible = true;
                            ObjectUtils.gray( itemUI.btn3, true );
                            itemUI.btn3.mouseEnabled = false;
                            itemUI.btn3.label = "扫荡"+leftChanllengeCount+"次";
                            itemUI.isunLock.text = ("(V3扫荡多次)");
                        }

                        itemUI.btn_add.visible = true;
                    }

                    itemUI.btn_add.clickHandler = new Handler(_buyPowerHandler);

                } else {// 非精英副本
                    ObjectUtils.gray( itemUI.btn2, false );
                    itemUI.btn2.mouseEnabled = true;
                    itemUI.btn2.clickHandler = new Handler( sweep, [ 1 ] );
                    itemUI.btn2.label = "扫荡1次";
                    if ( _judgeVipLv() ) {
                        ObjectUtils.gray( itemUI.btn3, false );
                        itemUI.btn3.mouseEnabled = true;
                        itemUI.btn3.label = "扫荡10次";
                        itemUI.btn3.clickHandler = new Handler( sweep, [ 10 ] );
                    } else {
                        itemUI.isunLock.visible = true;
                        ObjectUtils.gray( itemUI.btn3, true );
                        itemUI.btn3.mouseEnabled = false;
                        itemUI.btn3.label = "扫荡10次";
                        itemUI.isunLock.text = ("(VIP3级开启扫荡)");
                    }
                }
            } else {// 不能扫荡
                itemUI.isunLock.visible = true;
                itemUI.isunLock.text = ("(三星解锁扫荡)");
                ObjectUtils.gray( itemUI.btn2, true );
                ObjectUtils.gray( itemUI.btn3, true );
                itemUI.btn2.clickHandler = null;
                itemUI.btn3.clickHandler = null;
                itemUI.btn2.mouseEnabled = false;
                itemUI.btn3.mouseEnabled = false;
                itemUI.btn_add.visible = false;

                if(_instanceData.isElite)
                {
                    leftChanllengeCount = _getEliteChanllengeLeftCount();
                    itemUI.btn3.label = "扫荡"+leftChanllengeCount+"次";
                }
                else
                {
                    itemUI.btn3.label = "扫荡10次";
                }
            }
        } else {
            //不可以挑战，先将三个按钮全部禁用
            for ( i = 1; i <= 3; i++ ) {
                itemUI[ "btn" + i ].mouseEnabled = false;
                itemUI[ "btn" + i ].clickHandler = null;
                ObjectUtils.gray( itemUI[ "btn" + i ], true );
            }
            if ( _isElite ) {
                itemUI.btn3.label = "扫荡" + 3 + "次";
            } else {
                itemUI.btn3.label = "扫荡" + 10 + "次";
            }
            // _judgeCanchanllenge() 这个方法判断能否打，接口是调用副本里边的，会返回一堆错误数据，如果副本已完成，但是体力不够也是返回不能打
            // 所以如果_judgeCanchanllenge()方法不能打，也要判断一下，副本是否已完成，如果已完成判断下体力，够就可以挑战，
            // 但是不用判断能否扫荡，因为副本里到了判断扫荡这步，_judgeCanchanllenge()方法肯定会返回true能打;
            if ( _instanceData.isCompleted ) {
                //如果副本已完成，判断一下体力，体力够开启btn1挑战按钮
                if ( _vitIsEnough ) {
                    itemUI.btn1.clickHandler = new Handler( challenge, [ instanceID ] );
                    ObjectUtils.gray( itemUI.btn1, false );
                    itemUI.btn1.mouseEnabled = true;
                }
            }//如果副本没完成，分为两种，1、副本没开启；2、副本开启了，但是体力不够打不了
            else {
                //如果没完成，但是错误数据包含“instance_error_vit_not_enough”这条key，副本那边的逻辑只要判断了这个数据，说明副本已开启
                //如果没完成，也没“instance_error_vit_not_enough”这条错误数据，说明没开启
                if ( _vitIsEnough ) {
                    itemUI.isunLock.text = ("(副本未开启)");
                    itemUI.lock.visible = true;
                } else {
                    itemUI.isunLock.text = ("(体力不足)");
                }
            }
        }
    }

    private function _judgeSweep( itemUI : GetItemPathItemUI ) : Boolean {
        if ( _instanceData.isCompleted ) {
            if ( _instanceData.star >= 3 ) {
                return true;
            } else {
                return false;
            }
        }
        return false;
    }

    private function _judgeCanchanllenge( itemUI : GetItemPathItemUI ) : Boolean {
        var errorData : CErrorData = (_pItemGetView.appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).instanceData.checkInstanceCanFight( _instanceData.instanceID, 1, false, false );
        var errorString : String = "";
        var needTeamLevel : int = 0;
        if ( errorData != null && errorData.isError == false ) {
            if ( errorData.contents ) {
                if ( errorData.contents.length > 0 ) {
                    errorString = errorData.contents[ 0 ];
                    if ( errorString.indexOf( CLang.Get( "instance_error_pre_level" ) ) > -1 ) {
                        needTeamLevel = _instanceData.condLevel;
                        itemUI.isunLock.text = ("(战队" + needTeamLevel + "级开启副本)");
                        itemUI.lock.visible = true;
                    }
//                        if ( errorString.indexOf( "instance_error_vit_not_enough" ) > -1 ) {
//                            itemUI.isunLock.text = ("(体力不足)");
//                        }
                }
            }
            return true;
        }
        else {
            if ( errorData.contents ) {
                if ( errorData.contents.length > 0 ) {
                    errorString = errorData.contents[ 0 ];
                    if ( errorString.indexOf( CLang.Get( "instance_error_pre_level" ) ) > -1 ) {
                        needTeamLevel = _instanceData.condLevel;
                        itemUI.isunLock.text = ("(战队" + needTeamLevel + "级开启副本)");
                        itemUI.lock.visible = true;
                    }
                    if ( errorString.indexOf( CLang.Get( "instance_error_pre_task" ) ) > -1 ) {
                        itemUI.isunLock.text = ("(完成任务解锁)");
                        itemUI.lock.visible = true;
                    }
//                        if ( errorString.indexOf( "instance_error_vit_not_enough" ) > -1 ) {
//                            itemUI.isunLock.text = ("(体力不足)");
//                            _vitIsEnough = false;
//                        } else {
//                            _vitIsEnough = true;
//                        }
                    if ( errorString.indexOf( "instance_not_enough_count" ) > -1 ) {
                        itemUI.isunLock.text = ("(副本次数不足)");
                        if ( _instanceData.isElite ) {
                            itemUI.btn3.label = "扫荡" + 3 + "次";
                        } else {
                            itemUI.btn3.label = "扫荡" + 10 + "次";
                        }
                    }
//                        if ( errorString.indexOf( "instance_not_pass" ) > -1 ) {副本未通过不会发这个条key，但是isComplete会是false
//                            itemUI.isunLock.text = ("(通关副本解锁)");
//                            itemUI.lock.visible = true;
//                        }
                }
            }
        }
        return true;
    }

    private function _getEliteChanllengeLeftCount():int{
        return _instanceData.challengeCountLeft;
    }
    //判断体力是否足够挑战指定次数physicalStrength
    private function _calculationPhysicalStrengthIsEnoughForChanllengeCount(chanllengeCount:int) : Boolean {
        var instanceConstant : InstanceConstant = _instanceData.constant;
        var costVit:int=_instanceData.isElite?instanceConstant.INSTANCE_ELITE_PASS_COST_VT_NUM:instanceConstant.INSTANCE_MAIN_PASS_COST_VT_NUM;
        if ( _playerData.vitData.physicalStrength < chanllengeCount * costVit ) {
            return false;
        }
        return true;
    }

    private function _judgeVipLv() : Boolean {
        if ( _playerData.vipData.vipLv < 3 ) {
            return false;
//                if ( false == _playerData.vipHelper.isScenarioInstanceCanSweep10 ) {
//                    return false;
//                }
        }
        return true;
    }

    override protected function sweep( count : int ) : void {
        if(!_calculationPhysicalStrengthIsEnoughForChanllengeCount(count)){
            CItemGetSystem(_pItemGetView.appSystem).openPower();
            _pItemGetView.close();
            return;
        }
        var mainNetHandler : CMainInstanceHandler = (_pItemGetView.appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).mainNetHandler;
        (_pItemGetView.appSystem.stage.getSystem( CInstanceSystem ) as CInstanceSystem).instanceData.resetSweepData();

        mainNetHandler.sendSweepInstance( _instanceData.instanceID, count );
        if ( count != 0 ) {
            super.sweep( count );
        }
        CItemGetSystem( _pItemGetView.appSystem ).currentInstanceData = _instanceData;
    }

    private function _buyPowerHandler(e:MouseEvent = null):void
    {
        if (instanceData == null) return ;
        if (instanceData.isServerData) {
            if (instanceData.challengeCountLeft > 0) {
                // 还有次数
                (uiCanvas.showMsgAlert(CLang.Get("instance_need_not_buy_elite_count")));
                return ;
            }

            var playerData:CPlayerData = (_pItemGetView.appSystem.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
            var resetCountLeft:int = playerData.vipHelper.resetEliteTotalCount - instanceData.resetNum;
            if (resetCountLeft <= 0) {
                // 没重置次数了
                (uiCanvas.showMsgAlert(CLang.Get("instance_buy_elite_count_limit")));
                return ;
            }
//            rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_ADD_FIGHT_COUNT, [data]));

            var instanceSystem:CInstanceSystem = _pItemGetView.appSystem.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            (instanceSystem.getHandler(CInstanceUIHandler) as CInstanceUIHandler).showEliteResetLevelView(instanceData);
        } else {
            (uiCanvas.showMsgAlert(CLang.Get("instance_elite_alawys_need_not_buy")));
        }
    }

    public function get uiCanvas() : IUICanvas
    {
        return _pItemGetView.appSystem.stage.getSystem(IUICanvas) as IUICanvas;
    }
}
}
