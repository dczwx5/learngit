//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/3/6.
 */
package kof.game.common.loading {

import flash.geom.Point;

import kof.framework.CAppSystem;
import kof.game.common.loading.movie.CMatchLoadingBeforeSelecteMovieCompoent;
import kof.game.common.loading.movie.CMatchLoadingEndMovieCompoent;
import kof.game.common.loading.movie.CMatchLoadingMovieCompoent;
import kof.game.common.loading.movie.CMatchLoadingSceneDisplayMovieCompoent;
import kof.game.common.loading.movie.CMatchLoadingSelectFinishMovieCompoent;
import kof.game.common.loading.movie.CMatchLoadingSelectMovieCompoent;
import kof.game.common.loading.movie.CMatchLoadingStartMovieCompoent;

import kof.game.common.preLoad.CPreload;
import kof.data.CPreloadData;
import kof.game.common.preLoad.CPreloadEvent;
import kof.game.common.preLoad.EPreloadType;

import kof.game.common.view.CRootView;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.imp_common.MatchLoadingUI;

import morn.core.components.Component;

public class CMatchLoadingView extends CRootView {

    public function CMatchLoadingView() {
        super(MatchLoadingUI, [CMatchLoadingHeroListView, CMatchLoadingHeroListView, CMatchProgressView], EMatchLoadingRes.MATCH_LOADING, false);
    }

    private var _isForceStop:Boolean;
    public function forceStop() : void {
        _isForceStop = true;
        if (_isDoReload) {
            close();
        }
    }

    private var _leftHeroPosList:Array;
    private var _rightHeroPosList:Array;
    protected override function _onCreate() : void {
        _baseLeftBoxPos = new Point(_ui.left_box.x, _ui.left_box.y);
        _baseRightBoxPos = new Point(_ui.right_box.x, _ui.right_box.y);

        _leftHeroPosList = new Array(3);
        _leftHeroPosList[0] = new Point(_ui.hero_1_1_box.x, _ui.hero_1_1_box.y);
        _leftHeroPosList[1] = new Point(_ui.hero_1_2_box.x, _ui.hero_1_2_box.y);
        _leftHeroPosList[2] = new Point(_ui.hero_1_3_box.x, _ui.hero_1_3_box.y);

        _ui.hero_1_icon_1_img.cacheAsBitmap = true;
        _ui.hero_mask_11.cacheAsBitmap = true;
        _ui.hero_1_icon_1_img.mask = _ui.hero_mask_11;

        _ui.hero_1_icon_2_img.cacheAsBitmap = true;
        _ui.hero_mask_12.cacheAsBitmap = true;
        _ui.hero_1_icon_2_img.mask = _ui.hero_mask_12;

        _ui.hero_1_icon_3_img.cacheAsBitmap = true;
        _ui.hero_mask_13.cacheAsBitmap = true;
        _ui.hero_1_icon_3_img.mask = _ui.hero_mask_13;

        _ui.hero_2_icon_1_img.cacheAsBitmap = true;
        _ui.hero_mask_21.cacheAsBitmap = true;
        _ui.hero_2_icon_1_img.mask = _ui.hero_mask_21;

        _ui.hero_2_icon_2_img.cacheAsBitmap = true;
        _ui.hero_mask_22.cacheAsBitmap = true;
        _ui.hero_2_icon_2_img.mask = _ui.hero_mask_22;

        _ui.hero_2_icon_3_img.cacheAsBitmap = true;
        _ui.hero_mask_23.cacheAsBitmap = true;
        _ui.hero_2_icon_3_img.mask = _ui.hero_mask_23;

        _rightHeroPosList = new Array(3);
        _rightHeroPosList[0] = new Point(_ui.hero_2_1_box.x, _ui.hero_2_1_box.y);
        _rightHeroPosList[1] = new Point(_ui.hero_2_2_box.x, _ui.hero_2_2_box.y);
        _rightHeroPosList[2] = new Point(_ui.hero_2_3_box.x, _ui.hero_2_3_box.y);

        _ui.cacheAsBitmap = true;
        _ui.mask_img.cacheAsBitmap = true;
        _ui.mask = _ui.mask_img;
    }

    private var _baseLeftBoxPos:Point;
    private var _baseRightBoxPos:Point;
    protected override function _onDispose() : void {

    }
    private function _initial() : void {
        _ui.black_img.visible = false; // 不要全黑
        _ui.bg1_img.visible = false;
        _ui.bg2_img.visible = false;
        _ui.fight_img.visible = false;
        _ui.fight_img.scaleY = 1;

        _ui.sort_select_black_img.visible = false;
        _ui.sort_select_white_img.visible = false;
        _ui.sort_select_img.visible = false;
        _ui.sort_select_black_img.scaleY = 1;
        _ui.sort_select_white_img.scaleY = 1;
        _ui.sort_select_img.scaleY = 1;

        _ui.left_hero_list_box.visible = false;
        _ui.right_hero_list_box.visible = false;

        _ui.vs_black_img.visible = false;
        _ui.vs_white_img.visible = false;
        _ui.vs_white_img.scale = 1.0;
        _ui.vs_red_img.visible = false;
        _ui.select_black_img.visible = false;
        _ui.select_black_2_img.visible = false;

        _ui.selected_1_clip.index = 0;
        _ui.selected_2_clip.index = 0;

        _ui.left_box.x = _baseLeftBoxPos.x;
        _ui.left_box.y = _baseLeftBoxPos.y;
        _ui.right_box.x = _baseRightBoxPos.x;
        _ui.right_box.y = _baseRightBoxPos.y;

        _ui.left_selected_box.visible = false;
        _ui.right_selected_box.visible = false;
        _ui.left_selected_box.scaleY = 1;
        _ui.right_selected_box.scaleY = 1;

        _ui.hero_1_1_box.x = _leftHeroPosList[0].x;
        _ui.hero_1_1_box.y = _leftHeroPosList[0].y;
        _ui.hero_1_2_box.x = _leftHeroPosList[1].x;
        _ui.hero_1_2_box.y = _leftHeroPosList[1].y;
        _ui.hero_1_3_box.x = _leftHeroPosList[2].x;
        _ui.hero_1_3_box.y = _leftHeroPosList[2].y;

        _ui.hero_2_1_box.x = _rightHeroPosList[0].x;
        _ui.hero_2_1_box.y = _rightHeroPosList[0].y;
        _ui.hero_2_2_box.x = _rightHeroPosList[1].x;
        _ui.hero_2_2_box.y = _rightHeroPosList[1].y;
        _ui.hero_2_3_box.x = _rightHeroPosList[2].x;
        _ui.hero_2_3_box.y = _rightHeroPosList[2].y;

        _ui.hero_1_no_1_img.visible = false;
        _ui.hero_1_no_2_img.visible = false;
        _ui.hero_1_no_3_img.visible = false;
        _ui.hero_2_no_1_img.visible = false;
        _ui.hero_2_no_2_img.visible = false;
        _ui.hero_2_no_3_img.visible = false;


    }
    protected override function _onShow():void {
        _isDoReload = false;
        _initial();
        clearPreloadData();

        _preload = new CPreload((uiCanvas as CAppSystem).stage);
        _preload.addEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
        _preload.addEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);

        // 开始动画
        var startComponentList:Vector.<Component> = new Vector.<Component>(9);
        startComponentList[0] = _ui.black_img;
        startComponentList[1] = _ui.left_box;
        startComponentList[2] = _ui.right_box;
        startComponentList[3] = _ui.vs_black_img;
        startComponentList[4] = _ui.vs_white_img;
        startComponentList[5] = _ui.vs_red_img;
        startComponentList[6] = _ui.fight_img;
        startComponentList[7] = _ui.bg1_img;
        startComponentList[8] = _ui.bg2_img;
        _startComponent = new CMatchLoadingStartMovieCompoent(this, startComponentList, _onStartMovieFinish);

        // 人物掉下来 - 左边
        var componentList:Vector.<Component> = new Vector.<Component>(4);
        componentList[0] = _ui.hero_1_1_box;
        componentList[1] = _ui.hero_1_2_box;
        componentList[2] = _ui.hero_1_3_box;
        componentList[3] = _ui.left_hero_list_box;
        _movieComponent = new CMatchLoadingMovieCompoent(this, componentList, _onMovieFinish);

        // 人物掉下来 - 右边
        var componentRightList:Vector.<Component> = new Vector.<Component>(4);
        componentRightList[0] = _ui.hero_2_1_box;
        componentRightList[1] = _ui.hero_2_2_box;
        componentRightList[2] = _ui.hero_2_3_box;
        componentRightList[3] = _ui.right_hero_list_box;
        _movieComponentRight = new CMatchLoadingMovieCompoent(this, componentRightList, _onMovieFinish);

        // 选人前的动画
        var showSortSelectComponentList:Vector.<Component> = new Vector.<Component>(6);
        showSortSelectComponentList[0] = _ui.sort_select_black_img;
        showSortSelectComponentList[1] = _ui.sort_select_white_img;
        showSortSelectComponentList[2] = _ui.sort_select_img;
        showSortSelectComponentList[3] = _ui.left_selected_box;
        showSortSelectComponentList[4] = _ui.right_selected_box;
        showSortSelectComponentList[5] = _ui.select_black_img;
        showSortSelectComponentList[6] = _ui.select_black_2_img;

        _showSortSelectComponent = new CMatchLoadingBeforeSelecteMovieCompoent(this, showSortSelectComponentList, _onBeforeSelectFinish);


        // 选人动画
        var selectComponentLeftList:Vector.<Component> = new Vector.<Component>(8);
        selectComponentLeftList[0] = _ui.left_selected_box;
        selectComponentLeftList[1] = _ui.selected_1_clip;
        selectComponentLeftList[2] = _ui.hero_1_1_box;
        selectComponentLeftList[3] = _ui.hero_1_2_box;
        selectComponentLeftList[4] = _ui.hero_1_3_box;
        selectComponentLeftList[5] = _ui.hero_1_no_1_img;
        selectComponentLeftList[6] = _ui.hero_1_no_2_img;
        selectComponentLeftList[7] = _ui.hero_1_no_3_img;
        _leftSelectComponent = new CMatchLoadingSelectMovieCompoent(this, selectComponentLeftList, _onSelectFinish);

        var selectComponentRightList:Vector.<Component> = new Vector.<Component>(8);
        selectComponentRightList[0] = _ui.right_selected_box;
        selectComponentRightList[1] = _ui.selected_2_clip;
        selectComponentRightList[2] = _ui.hero_2_1_box;
        selectComponentRightList[3] = _ui.hero_2_2_box;
        selectComponentRightList[4] = _ui.hero_2_3_box;
        selectComponentRightList[5] = _ui.hero_2_no_1_img;
        selectComponentRightList[6] = _ui.hero_2_no_2_img;
        selectComponentRightList[7] = _ui.hero_2_no_3_img;
        _rightSelectComponent = new CMatchLoadingSelectMovieCompoent(this, selectComponentRightList, _onSelectFinish);


        // 选完人之后的动画
        var selectFinishComponentList:Vector.<Component> = new Vector.<Component>(18);
        selectFinishComponentList[0] = _ui.sort_select_black_img;
        selectFinishComponentList[1] = _ui.sort_select_white_img;
        selectFinishComponentList[2] = _ui.sort_select_img;
        selectFinishComponentList[3] = _ui.left_box;
        selectFinishComponentList[4] = _ui.right_box;
        selectFinishComponentList[5] = _ui.fight_img;
        selectFinishComponentList[6] = _ui.hero_1_1_box;
        selectFinishComponentList[7] = _ui.hero_1_2_box;
        selectFinishComponentList[8] = _ui.hero_1_3_box;
        selectFinishComponentList[9] = _ui.hero_2_1_box;
        selectFinishComponentList[10] = _ui.hero_2_2_box;
        selectFinishComponentList[11] = _ui.hero_2_3_box;
        selectFinishComponentList[12] = _ui.hero_1_no_1_img;
        selectFinishComponentList[13] = _ui.hero_1_no_2_img;
        selectFinishComponentList[14] = _ui.hero_1_no_3_img;
        selectFinishComponentList[15] = _ui.hero_2_no_1_img;
        selectFinishComponentList[16] = _ui.hero_2_no_2_img;
        selectFinishComponentList[17] = _ui.hero_2_no_3_img;
        _selectFinishComponent = new CMatchLoadingSelectFinishMovieCompoent(this, selectFinishComponentList, _onSelectFinishCompleted);

        progressView._ui.visible = false;

        _movieComponent1FinishCount = 0;
        _selectCount = 0;
    }

    protected override function _onShowing() : void {
        var heroData:CPlayerHeroData;
        var url:String;
        var i:int = 0;
        for (i = 0; i < p1HeroListView.heroList.length; i++) {
            heroData = p1HeroListView.heroList[i];
            url = CPlayerPath.getUIHeroFacePath(heroData.prototypeID);
            this.loadBmd(url);
        }
        for (i = 0; i < p2HeroListView.heroList.length; i++) {
            heroData = p2HeroListView.heroList[i];
            url = CPlayerPath.getUIHeroFacePath(heroData.prototypeID);
            this.loadBmd(url);
        }
    }

    protected override function _onHide() : void {
        if (_preload) {
            _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
            _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
//            _preload.dispose();
//            _preload = null;
        }
        _isForceStop = false; //不能在show的时候设为false, 因为有可能 会把外部的设定重置

        this.removeEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);

    }
    private function _onUpdateProgress(e:CPreloadEvent) : void {
        _matchData.myProgress = e.data as int;
        sendEvent(new CLoadingEvent(CLoadingEvent.LOADING_PROCESS_UPDATE, e.data as int));
    }
    private function _onFinishProgress(e:CPreloadEvent) : void {
        // 等虚拟进度条ok // _onPlayEnd();
        if (progressView.isLoadFinish()) {
            _onPlayEnd();
        } else {
            this.addEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);
        }
    }
    private function _onVirtualLoadFinish(e:CLoadingEvent) : void {
        this.removeEventListener(CLoadingEvent.VIRTUAL_LOAD_FINISHED, _onVirtualLoadFinish);
        _onPlayEnd();
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        _startComponent.start();
        this.addToPopupDialog();

        return true;
    }

    // =======================finish process===========================

    private function _onStartMovieFinish() : void {
        _startComponent.dispose();
        _startComponent = null;

        _movieComponentRight.start();
        _movieComponent.start();
    }

    private var _movieComponent1FinishCount:int = 0;
    private function _onMovieFinish() : void {
        _movieComponent1FinishCount++;
        if (_movieComponent1FinishCount == 2) {
            // step 3 显示loading
            _movieComponent.dispose();
            _movieComponent = null;
            _movieComponentRight.dispose();
            _movieComponentRight = null;

            _showSortSelectComponent.start();
        }
    }

    private function _onBeforeSelectFinish() : void {
        _leftSelectComponent.start();
        _rightSelectComponent.start();
    }


    private var _selectCount:int = 0;
    private function _onSelectFinish() : void {
        _selectCount++;
        if (2 == _selectCount) {
            _selectFinishComponent.start();
        }
    }

    private function _onSelectFinishCompleted() : void {
        progressView._ui.visible = true;
        var sceneDisplayComponentList:Vector.<Component> = new Vector.<Component>(4);
        sceneDisplayComponentList[0] = progressView._ui.white_img;
        sceneDisplayComponentList[1] = progressView.curSceneImage;
        sceneDisplayComponentList[2] = progressView._ui.title_img;
        sceneDisplayComponentList[3] = progressView.curSceneNameImage;
        _sceneDisplayMovieComponent = new CMatchLoadingSceneDisplayMovieCompoent(this, sceneDisplayComponentList, _onSceneDisplayFinish);
        _sceneDisplayMovieComponent.start();
    }

    private var _isDoReload:Boolean = false;
    private function _onSceneDisplayFinish() : void {
        if (!_isForceStop) {
            _isDoReload = true;
            _doPreload();
        } else {
            close();
        }
    }

    private function _onPlayEnd() : void {
        var endComponentList:Vector.<Component> = new Vector.<Component>(6);
        endComponentList[0] = _ui.left_box;
        endComponentList[1] = _ui.right_box;
        endComponentList[2] = progressView._ui.all_white_img;
        endComponentList[3] = progressView._ui.top_black_img;
        endComponentList[4] = progressView._ui.bottom_black_img;
        endComponentList[5] = progressView._ui;
        _endMovieComponent = new CMatchLoadingEndMovieCompoent(this, endComponentList, _onPlayEndFinish);
        _endMovieComponent.start();
    }
    private function _onPlayEndFinish() : void {
          sendEvent(new CLoadingEvent(CLoadingEvent.LOADING_PROCESS_FINISH, _matchData));
    }

    // =======================preload===========================

    private function _doPreload() : void {
        progressView._ui.left_box.visible = true;
        progressView._ui.right_box.visible = true;
        var isExist:Function = function (list:Vector.<CPreloadData>, preloadData:CPreloadData) : Boolean {
            for each (var listItem:CPreloadData in list) {
                if (listItem.resType == preloadData.resType && preloadData.id == listItem.id) {
                    return true;
                }
            }
            return false;
        };
        var addItem:Function = function (saveList:Vector.<CPreloadData>, heroList:Array) : void {
            var heroData:CPlayerHeroData;
            var preloadData:CPreloadData;
            for each (heroData in heroList) {
                preloadData = new CPreloadData();
                preloadData.resType = EPreloadType.RES_TYPE_HERO;
                preloadData.id = heroData.prototypeID.toString();
                if (false == isExist(saveList, preloadData)) {
                    saveList[saveList.length] = preloadData;
                }
            }
        };

        var preloadDataList:Vector.<CPreloadData> = new Vector.<CPreloadData>();
        addItem(preloadDataList, p1HeroListView.heroList);
        addItem(preloadDataList, p2HeroListView.heroList);
        _preload.load(preloadDataList);
    }
    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);

        // selfData
        var peakSystem:CPeakGameSystem = system.stage.getSystem(CPeakGameSystem) as CPeakGameSystem;
        var embattleListData:CEmbattleListData = peakSystem.embattleListData;
        var heroList:Array = _playerData.embattleManager.getHeroListByEmbattleList(embattleListData);

        //
        var isSelfP1:Boolean = _matchData.isSelfP1;
        var p1List:Array;
        var p2List:Array;
        if (isSelfP1) {
            p1List = heroList;
            p2List = _matchData.heroList.list;
        } else {
            p1List = _matchData.heroList.list;
            p2List = heroList;
        }

        p1HeroListView.setArgs([1, p1List]);
        p1HeroListView.setData(v, forceInvalid);

        p2HeroListView.setArgs([2, p2List]);
        p2HeroListView.setData(v, forceInvalid);

        this.setChildrenData(v, forceInvalid);
    }

    // ====================================event=============================

    public function clearPreloadData() : void {
        if (_preload) {
            _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_UPDATE, _onUpdateProgress);
            _preload.removeEventListener(CPreloadEvent.LOADING_PROCESS_FINISH, _onFinishProgress);
            _preload.dispose();
            _preload = null;
        }
    }
    //===================================get/set======================================
    [Inline]
    private function get p1HeroListView() : CMatchLoadingHeroListView { return getChild(0) as CMatchLoadingHeroListView; }
    [Inline]
    private function get p2HeroListView() : CMatchLoadingHeroListView { return getChild(1) as CMatchLoadingHeroListView; }
    [Inline]
    private function get progressView() : CMatchProgressView { return getChild(2) as CMatchProgressView; }

    [Inline]
    private function get _ui() : MatchLoadingUI {
        return rootUI as MatchLoadingUI;
    }
    [Inline]
    private function get _matchData() : CMatchData {
        return super._data[0] as CMatchData;
    }
    [Inline]
    private function get _playerData() : CPlayerData {
        return super._data[1] as CPlayerData;
    }
    // 对方进度数据
    [Inline]
    private function get _enemyProgressData() : CProgressData {
        return _data[2] as CProgressData;
    }

    private var _preload:CPreload;

    private var _startComponent:CMatchLoadingStartMovieCompoent;
    private var _movieComponent:CMatchLoadingMovieCompoent;
    private var _movieComponentRight:CMatchLoadingMovieCompoent;
    private var _showSortSelectComponent:CMatchLoadingBeforeSelecteMovieCompoent;
    private var _leftSelectComponent:CMatchLoadingSelectMovieCompoent;
    private var _rightSelectComponent:CMatchLoadingSelectMovieCompoent;
    // 中间差选人
    private var _selectFinishComponent:CMatchLoadingSelectFinishMovieCompoent;

    //
    private var _sceneDisplayMovieComponent:CMatchLoadingSceneDisplayMovieCompoent;
    private var _endMovieComponent:CMatchLoadingEndMovieCompoent;
}
}
