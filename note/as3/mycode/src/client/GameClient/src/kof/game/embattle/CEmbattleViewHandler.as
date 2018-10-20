//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/11/14.
 */
package kof.game.embattle {

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.game.audio.IAudio;
import kof.game.common.CLang;
import kof.game.common.hero.CHeroEmbattleListView;
import kof.game.common.view.CTweenViewHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CEmbattleData;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CHeroExtendsData;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.scene.ISceneFacade;
import kof.table.Embattle;
import kof.table.FairPeakConstant;
import kof.table.InstanceType;
import kof.table.PeakConstant;
import kof.table.PlayerBasic;
import kof.table.PlayerDisplay;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.components.KOFNum;
import kof.ui.embattle.Embattle2UI;
import kof.ui.embattle.EmbattleItemUI;
import kof.ui.imp_common.TypeCounterUI;

import morn.core.components.Box;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.Image;
import morn.core.components.ProgressBar;
import morn.core.components.SpriteBlitFrameClip;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

public class CEmbattleViewHandler extends CTweenViewHandler {

    public static const EVENT_FIGHT_CLICK:String = "fight";
    public static const EVENT_CHANGE_BUFF:String = "changeBuff";
    private var m_pCloseHandler : Handler;

    private var m_bViewInitialized : Boolean;

    private var m_embattleUI:Embattle2UI;
//    private var m_embattleUI:EmbattleUI;

    private var _curEmbattleItemUI : EmbattleItemUI;

    private var _position:int;

    private var _pickUpIndex:int;//从已上阵的拖动

    private var _totalEmbatlleNum:int;

    private var _totalEmbatllePower:int;

    private var _playerList:Array;

    private var _onEmbattleAry:Array;

    private var _curSpriteBlitFrameClip:SpriteBlitFrameClip;

    private var _dragBitmap:Bitmap;

    private var _isBest:Boolean;

    private var _isRequestByClose : Boolean;

    private var _curInstanceType : InstanceType;

    private var _needShowTypeEff : Boolean;//是否显示职业信息和攻克关系

    private var _enemyListData:Array;

    public function CEmbattleViewHandler() {
        super( false );
    }
    override public function dispose() : void {
        super.dispose();
        _removeEventListeners();
        removeDisplay();
        m_embattleUI = null;
    }

    override public function get viewClass() : Array {
        return [ Embattle2UI ,EmbattleItemUI ];
    }

    override protected function get additionalAssets() : Array {
        return [
            "frameclip_typecounter.swf"
        ];
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            if ( !m_embattleUI ) {

                m_embattleUI = new Embattle2UI();
                m_embattleUI.list.renderHandler = new Handler( renderItem );
                m_embattleUI.list.selectHandler = new Handler( selectItemHandler );
                m_embattleUI.list.mouseHandler = new Handler( listMouseHandler );

                m_embattleUI.btn_best.clickHandler = new Handler(_onBestEmbattle);
                m_embattleUI.btn_left.clickHandler = new Handler(_onLeft);
                m_embattleUI.btn_right.clickHandler = new Handler(_onRight);
                m_embattleUI.btn_change_buff.label = CLang.Get("common_change");
                m_embattleUI.btn_change_buff.clickHandler = new Handler(_onChangeBuff);
                m_embattleUI.btn_fight.clickHandler = new Handler(_onFight);
//                m_embattleUI.btn_fight.label = CLang.Get("common_fight2");
                m_embattleUI.btn_save.clickHandler = new Handler( _onSave );
                m_embattleUI.closeHandler = new Handler( _onClose );
                m_embattleUI.img_tips.addEventListener( MouseEvent.ROLL_OUT,_onTipsHandler );
                m_embattleUI.img_tips.addEventListener( MouseEvent.ROLL_OVER,_onTipsHandler );

                var pMaskDisplayObject : DisplayObject;
                var index : int;
                for( index  = 1 ; index <= 3 ; index++ ){
                    pMaskDisplayObject = m_embattleUI['img_masking_' + index];
                    if ( pMaskDisplayObject ) {
                        m_embattleUI['img_bg_' + index ].cacheAsBitmap = true;
                        pMaskDisplayObject.cacheAsBitmap = true;
                        m_embattleUI['img_bg_' + index ].mask = pMaskDisplayObject;
                    }
                }

                m_bViewInitialized = true;
            }
        }

        return m_bViewInitialized;
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }
    public function addDisplay() : void {
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }

    private function _addToDisplay() : void {
        if( m_embattleUI ){
            _addEventListeners();

            _curInstanceType = _pEmbattleManager.getInstanceByType( _pEmbattleHandler.type );

            //无尽之塔，试炼之地，世界BOSS，公会BOSS系统使用
            var isEndLessTower : Boolean = EInstanceType.isEndLessTower( _pEmbattleHandler.type );
            var isClimp : Boolean = EInstanceType.isClimp( _pEmbattleHandler.type );
//            var isWorldBoss : Boolean = EInstanceType.isWorldBoss( _pEmbattleHandler.type );
//            var isClubBoss : Boolean = EInstanceType.isClubBoss( _pEmbattleHandler.type );

//            _needShowTypeEff = isEndLessTower || isClimp || isWorldBoss || isClubBoss;
            _needShowTypeEff = isEndLessTower || isClimp  ;
            hideTypeEff( 1 );
            hideTypeEff( 2 );
            hideTypeEff( 3 );
            _onShowHeroProperty( 1 );
            _onShowHeroProperty( 2 );
            _onShowHeroProperty( 3 );

            _onEmbattleAry = [];
            resetUI();

            m_embattleUI.lock_1.visible = false;
            m_embattleUI.clip_p_1.visible = true;
            if( _curInstanceType.embattleNumLimit >= 3){
                m_embattleUI.lock_2.visible = m_embattleUI.lock_3.visible = false;
                m_embattleUI.clip_p_2.visible = m_embattleUI.clip_p_3.visible = true;
            }else if( _curInstanceType.embattleNumLimit >= 2 ){
                m_embattleUI.lock_2.visible = false;
                m_embattleUI.lock_3.visible = true;
                m_embattleUI.clip_p_2.visible = true;
                m_embattleUI.clip_p_3.visible = false;
            }else if( _curInstanceType.embattleNumLimit >= 1 ){
                m_embattleUI.lock_2.visible = m_embattleUI.lock_3.visible = true;
                m_embattleUI.clip_p_2.visible = m_embattleUI.clip_p_3.visible = false;
            }

//            setTweenData( KOFSysTags.EMBATTLE );
//            showDialog( m_embattleUI );
            uiCanvas.addPopupDialog( m_embattleUI );

            this.invalidateData();
            _playerList = playerData.heroList.getSortList(_pEmbattleHandler.type) as Array;
            m_embattleUI.list.dataSource = _playerList;
            m_embattleUI.list.page = 0;
            _onBtnDisabled();


            m_embattleUI.buff_box.visible = false;
            if (enemyList) {
                _enemyListData = enemyList;
            } else {
                _enemyListData = _emptyEnemyList;
            }
            if (_heroEmbattleList == null) {
                _heroEmbattleList = new CHeroEmbattleListView(system, m_embattleUI.hero_em_list, -1, null, _enemyListData, true, true);
            } else {
                _heroEmbattleList.updateData(-1, _enemyListData);
            }
            initData();
            _isBest = false;

            _heroEmbattleList.updateWindow();
            m_embattleUI.hero_em_box.visible = m_embattleUI.hero_em_list.visible;

            _updateEmHeroHP();
            m_embattleUI.btn_fight.visible = isShowFight;
            m_embattleUI.btn_save.visible = !isShowFight;

            m_embattleUI.box_power.visible = _pEmbattleHandler.type != EInstanceType.TYPE_PEAK_GAME_FAIR;
            m_embattleUI.box_addProTips.visible = _pEmbattleHandler.type == EInstanceType.TYPE_PEAK_GAME_FAIR;

            _isRequestByClose = false;

            dispatchEvent(new Event(Event.OPEN));

        }
    }
//    public function removeDisplay() : void {
//        closeDialog(_removeDisplayB);
//    }
//
//    private function _removeDisplayB() : void {
    public function removeDisplay() : void {
        if( m_embattleUI ){
            m_embattleUI.close( Dialog.OK );
            _isRequestByClose = true;
            dispatchEvent(new Event(Event.CLOSE));
            onEmbattleRequest();
            _removeEventListeners();
            system.dispatchEvent( new CEmbattleEvent( CEmbattleEvent.EMBATTLE_CLOSE ) );
            _totalEmbatlleNum = 0;
        }
    }

    private function renderItem(item:Component, idx:int):void {
        if ( !(item is EmbattleItemUI) ) {
            return;
        }
        var pEmbattleItemUI : EmbattleItemUI = item as EmbattleItemUI;
        var heroData:CPlayerHeroData = pEmbattleItemUI.dataSource as CPlayerHeroData;
        if (!heroData) return ;


        //策划说不需要显示品质框
//        if (isShowQuality) {
//            pEmbattleItemUI.quality_clip.index = heroData.qualityLevelValue;
//        } else {
            pEmbattleItemUI.quality_clip.index = 0;
//        }

//        if (isShowLevel) {
//            pEmbattleItemUI.lv_txt.visible = true;
//            pEmbattleItemUI.lv_txt.text = heroData.level.toString();
//        } else {
//            pEmbattleItemUI.lv_txt.visible = false;
//        }
        pEmbattleItemUI.star_list.dataSource = new Array(heroData.star);

        pEmbattleItemUI.lv_txt.visible = false;
        pEmbattleItemUI.level_frame_img.visible = false;

        pEmbattleItemUI.icon_image.cacheAsBitmap = true;
        pEmbattleItemUI.hero_icon_mask.cacheAsBitmap = true;
        pEmbattleItemUI.icon_image.mask = pEmbattleItemUI.hero_icon_mask;
        pEmbattleItemUI.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath(heroData.prototypeID);
        pEmbattleItemUI.img_embattle.visible = _onEmbattleAry.indexOf(heroData) != -1;
//        pEmbattleItemUI.clip_type.index = heroData.job;
        pEmbattleItemUI.clip_type.visible = false;//策划暂时隐藏
//        playerSystem.showCareerTips(pEmbattleItemUI.clip_type);
        pEmbattleItemUI.clip_quality.index = heroData.qualityBaseType;

        pEmbattleItemUI.toolTip = new Handler( playerSystem.showHeroTips, [heroData]);




        ObjectUtils.gray(pEmbattleItemUI.icon_image, false);
        if (pEmbattleItemUI.hp_bar) {
            pEmbattleItemUI.hp_bar.visible = false;
            if (pEmbattleItemUI.state_clip) {
                pEmbattleItemUI.state_clip.visible = false;
            }
            if (isProcessHp) {
                var heroExtendsData:CHeroExtendsData = heroData.extendsData as CHeroExtendsData;
                if (heroExtendsData) {
                    // 添加血条处理 auto
                    var hpBar:ProgressBar = pEmbattleItemUI.hp_bar;
                    var hpMax:int = heroData.propertyData.HP;
                    var hpCur:int = heroExtendsData.hp;
                    if (hpMax > 0) {
                        hpBar.value = hpCur / hpMax;
                    } else {
                        hpBar.value = 0;
                    }
                    hpBar.visible = true;

                    if (pEmbattleItemUI.state_clip) {
                        if (hpCur == 0) {
                            pEmbattleItemUI.state_clip.visible = true;
                            pEmbattleItemUI.state_clip.index = 1;
                            ObjectUtils.gray(pEmbattleItemUI.icon_image, true);
                        }
                    }
                }
            }
        }

    }
    private function selectItemHandler( index : int ) : void {
        if ( index < 0 )return;
        _curEmbattleItemUI = m_embattleUI.list.getCell( index ) as EmbattleItemUI;
        if ( !_curEmbattleItemUI || !_curEmbattleItemUI.dataSource)
            return;

        if (isProcessHp) {
            var heroExtendsData:CHeroExtendsData = (_curEmbattleItemUI.dataSource as CPlayerHeroData).extendsData as CHeroExtendsData;
            if (heroExtendsData && heroExtendsData.hp == 0) {
                uiCanvas.showMsgAlert("该格斗家已经失败");
                return;
            }
        }

        if( _onEmbattleAry.indexOf( _curEmbattleItemUI.dataSource) != -1 ){
            uiCanvas.showMsgAlert("该格斗家已经上阵");
            return;
        }
        if( upHeroNum >= _curInstanceType.embattleNumLimit ){
            uiCanvas.showMsgAlert("已达最大上阵格斗家数量");
            return;
        }

        var pPlayerObject : PlayerBasic = (_curEmbattleItemUI.dataSource as CPlayerHeroData).playerBasic;

        var position : int = freePosition;
        if ( !m_embattleUI["clipCharacter_" + position].framework ) {
            m_embattleUI["clipCharacter_" + position].framework = pScene.scenegraph.graphicsFramework;
        }
        m_embattleUI["clipCharacter_" + position].skin = pPlayerObject.SkinName;
        m_embattleUI["img_bg_" + position ].url = CPlayerPath.getPeakUIHeroFacePath( (_curEmbattleItemUI.dataSource as CPlayerHeroData).prototypeID );
        m_embattleUI["hero_name_txt_" + position ].url = CPlayerPath.getUIHeroNamePath((_curEmbattleItemUI.dataSource as CPlayerHeroData).prototypeID);
        m_embattleUI['clip_p_' + position ].visible = false;
        m_embattleUI["clipCharacter_" + position ].dataSource = _curEmbattleItemUI.dataSource;
        m_embattleUI["clipCharacter_" + position ].visible = true;
        showTypeEff( position , _curEmbattleItemUI.dataSource as CPlayerHeroData );
        _onShowHeroProperty(position , _curEmbattleItemUI.dataSource as CPlayerHeroData );

        updataList( _curEmbattleItemUI.dataSource as CPlayerHeroData);

        m_embattleUI.list.selectedIndex = -1;

        updateTxt();
        onDispatchEvent();

        _onPlayAudio( ( m_embattleUI["clipCharacter_" + position ].dataSource as CPlayerHeroData ).ID  );
    }

    public var forceStopDragHero:Boolean = false;
    private function listMouseHandler( evt:Event,idx : int ) : void {
        if (forceStopDragHero) return ;

        if( evt.type == MouseEvent.MOUSE_DOWN ){
            _curEmbattleItemUI = m_embattleUI.list.getCell(idx) as EmbattleItemUI;
            if( _onEmbattleAry.indexOf( _curEmbattleItemUI.dataSource) != -1 ){
                uiCanvas.showMsgAlert("该格斗家已经上阵");
                return;
            }

            if (isProcessHp) {
                var heroExtendsData:CHeroExtendsData = (_curEmbattleItemUI.dataSource as CPlayerHeroData).extendsData as CHeroExtendsData;
                if (heroExtendsData && heroExtendsData.hp == 0) {
                    uiCanvas.showMsgAlert("该格斗家已经失败");
                    return;
                }
            }

            //可以拖
//            if( upHeroNum >= _pEmbattleHandler.limit ){
//                uiCanvas.showMsgAlert("已达最大上阵格斗家数量");
//                return;
//            }
            embattleShow();
        }
    }
    private function embattleShow():void{

        if ( !(m_embattleUI.clipCharacter_temp as CCharacterFrameClip).framework )
            ( m_embattleUI.clipCharacter_temp as CCharacterFrameClip ).framework = pScene.scenegraph.graphicsFramework;
        var pPlayerObject : PlayerBasic = (_curEmbattleItemUI.dataSource as CPlayerHeroData).playerBasic;
        m_embattleUI.clipCharacter_temp.skin = pPlayerObject.SkinName;
        m_embattleUI.clipCharacter_temp.dataSource = _curEmbattleItemUI.dataSource;
        _curSpriteBlitFrameClip = m_embattleUI.clipCharacter_temp;

        onDrag();
    }
    private function updateTempBitmap( delta : Number ):void{
        if( _curSpriteBlitFrameClip.bitmap && _curSpriteBlitFrameClip.bitmap.bitmapData ){
            _dragBitmap.bitmapData = _curSpriteBlitFrameClip.bitmap.bitmapData;
            _dragBitmap.x = m_embattleUI.mouseX - _dragBitmap.width * .5;
            _dragBitmap.y = m_embattleUI.mouseY- _dragBitmap.height * .5;
        }
    }
    private function onStageMouseUp(evt:MouseEvent):void{
        unschedule(updateTempBitmap);
        App.stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        var isHit:Boolean;
        var i:int;
        var position:int;
        var temSkin:String;
        var tempData:CPlayerHeroData;
//        for( i = 1 ; i < m_embattleUI.box_position.numChildren + 1; i ++ ){
//            var img:Image = m_embattleUI.box_position.getChildByName( "img_" + i ) as Image;
//            if(img.hitTestObject(_dragBitmap)){
//                if( i != _pickUpIndex ){
//                    position = i;
//                    isHit = true;
//                    break;
//                }
//            }
//        }
        ///用鼠标位置判断代替碰撞
        if( m_embattleUI.box_position.mouseX > 0 && m_embattleUI.box_position.mouseX < m_embattleUI.img_postion1.x + m_embattleUI.img_postion1.width
                && m_embattleUI.box_position.mouseY > -65  && m_embattleUI.box_position.mouseY < m_embattleUI.img_postion1.y + m_embattleUI.img_postion1.height ){
            position = 1;
            isHit = true;
        }else if( m_embattleUI.box_position.mouseX > m_embattleUI.img_postion2.x && m_embattleUI.box_position.mouseX < m_embattleUI.img_postion2.x + m_embattleUI.img_postion2.width
                && m_embattleUI.box_position.mouseY > -65  && m_embattleUI.box_position.mouseY < m_embattleUI.img_postion2.y + m_embattleUI.img_postion2.height){
            position = 2;
            isHit = true;
        }else if( m_embattleUI.box_position.mouseX > m_embattleUI.img_postion3.x && m_embattleUI.box_position.mouseX < m_embattleUI.img_postion3.x + m_embattleUI.img_postion3.width
                && m_embattleUI.box_position.mouseY > -65  && m_embattleUI.box_position.mouseY < m_embattleUI.img_postion3.y + m_embattleUI.img_postion3.height){
            position = 3;
            isHit = true;
        }

        if(isHit){
            _isBest = false;
            if(_pickUpIndex ){
                if(m_embattleUI["clipCharacter_" + position ].dataSource){
                    if(  m_embattleUI["lock_" + position ].visible ){
                        uiCanvas.showMsgAlert("不能上阵到该位置");
                        _curSpriteBlitFrameClip.visible = true;
                    }else{
                        tempData = m_embattleUI["clipCharacter_" + position ].dataSource;
                        temSkin =  m_embattleUI["clipCharacter_" + position ].skin;

                        m_embattleUI["clipCharacter_" + position ].dataSource =  _curSpriteBlitFrameClip.dataSource;
                        m_embattleUI["clipCharacter_" + position ].skin =  _curSpriteBlitFrameClip.skin;
                        m_embattleUI["img_bg_" + position ].url = CPlayerPath.getPeakUIHeroFacePath((_curSpriteBlitFrameClip.dataSource as CPlayerHeroData).prototypeID);
                        m_embattleUI["hero_name_txt_" + position ].url = CPlayerPath.getUIHeroNamePath((_curSpriteBlitFrameClip.dataSource as CPlayerHeroData).prototypeID);
                        m_embattleUI['clip_p_' + position ].visible = false;
                        showTypeEff( position ,_curSpriteBlitFrameClip.dataSource as CPlayerHeroData );
                        _onShowHeroProperty(position , _curSpriteBlitFrameClip.dataSource as CPlayerHeroData );

                        m_embattleUI["clipCharacter_" + _pickUpIndex ].dataSource = tempData;
                        m_embattleUI["clipCharacter_" + _pickUpIndex ].skin = temSkin;
                        m_embattleUI["img_bg_" + _pickUpIndex ].url = CPlayerPath.getPeakUIHeroFacePath((tempData as CPlayerHeroData).prototypeID);
                        m_embattleUI["hero_name_txt_" + _pickUpIndex ].url = CPlayerPath.getUIHeroNamePath((tempData as CPlayerHeroData).prototypeID);
                        m_embattleUI['clip_p_' + _pickUpIndex ].visible = false;
                        m_embattleUI["clipCharacter_" + _pickUpIndex ].visible = true;
                        showTypeEff( _pickUpIndex , tempData );
                        _onShowHeroProperty(_pickUpIndex , tempData );

                        _updateEmHeroHP();
                        onDispatchEvent();
                        if( position != _pickUpIndex )
                            _onPlayAudio( ( m_embattleUI["clipCharacter_" + position ].dataSource as CPlayerHeroData ).ID  );

                    }


                }else{
                    if(  m_embattleUI["lock_" + position ].visible ){
                        uiCanvas.showMsgAlert("不能上阵到该位置");
                        _curSpriteBlitFrameClip.visible = true;
                    }else{
                        if ( !m_embattleUI["clipCharacter_" + position].framework ) {
                            m_embattleUI["clipCharacter_" + position].framework = pScene.scenegraph.graphicsFramework;
                        }
                        m_embattleUI["clipCharacter_" + position ].dataSource =  _curSpriteBlitFrameClip.dataSource;
                        m_embattleUI["clipCharacter_" + position].skin = _curSpriteBlitFrameClip.skin;
                        m_embattleUI["img_bg_" + position ].url = CPlayerPath.getPeakUIHeroFacePath((_curSpriteBlitFrameClip.dataSource as CPlayerHeroData).prototypeID);
                        m_embattleUI["hero_name_txt_" + position ].url = CPlayerPath.getUIHeroNamePath((_curSpriteBlitFrameClip.dataSource as CPlayerHeroData).prototypeID);
                        m_embattleUI['clip_p_' + position ].visible = false;
                        m_embattleUI["clipCharacter_" + position ].visible = true;
                        showTypeEff( position ,_curSpriteBlitFrameClip.dataSource as CPlayerHeroData  );
                        _onShowHeroProperty( position ,_curSpriteBlitFrameClip.dataSource as CPlayerHeroData  );

                        if ( m_embattleUI["clipCharacter_" + _pickUpIndex].framework ) {
                            m_embattleUI["clipCharacter_" + _pickUpIndex].framework = null;
                            m_embattleUI["img_bg_" + _pickUpIndex ].url = '';
                            m_embattleUI["hero_name_txt_" + _pickUpIndex ].url = '';
                            m_embattleUI['clip_p_' + _pickUpIndex ].visible = true;
                            hideTypeEff( _pickUpIndex );
                            _onShowHeroProperty( position );
                        }
                        _curSpriteBlitFrameClip.dataSource = null;
                        _updateEmHeroHP();
                        onDispatchEvent();
                    }

                }

            }else{

                if(m_embattleUI["clipCharacter_" + position ].dataSource){
                    if(  m_embattleUI["lock_" + position ].visible ) {
                        uiCanvas.showMsgAlert( "不能上阵到该位置" );
                    }else{
                        updataList(m_embattleUI["clipCharacter_" + position ].dataSource,false);//下阵一个
                        m_embattleUI["clipCharacter_" + position ].dataSource = m_embattleUI.clipCharacter_temp.dataSource;
                        m_embattleUI["clipCharacter_" + position ].skin = m_embattleUI.clipCharacter_temp.skin;
                        m_embattleUI["img_bg_" + position ].url = CPlayerPath.getPeakUIHeroFacePath((m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData).prototypeID);
                        m_embattleUI["hero_name_txt_" + position ].url = CPlayerPath.getUIHeroNamePath((m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData).prototypeID);
                        m_embattleUI['clip_p_' + position ].visible = false;
                        showTypeEff( position ,m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData  );
                        _onShowHeroProperty( position ,m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData   );

                        updataList(m_embattleUI["clipCharacter_" + position ].dataSource);
                        _isBest = false;
                        onDispatchEvent();
                        _onPlayAudio( ( m_embattleUI["clipCharacter_" + position ].dataSource as CPlayerHeroData ).ID  );
                    }


                }else{

                    if(  m_embattleUI["lock_" + position ].visible ) {
                        uiCanvas.showMsgAlert( "不能上阵到该位置" );
                    }else{
                        if ( !m_embattleUI["clipCharacter_" + position].framework ) {
                            m_embattleUI["clipCharacter_" + position].framework = pScene.scenegraph.graphicsFramework;
                        }
                        m_embattleUI["clipCharacter_" + position].skin = m_embattleUI.clipCharacter_temp.skin;
                        m_embattleUI["img_bg_" + position ].url = CPlayerPath.getPeakUIHeroFacePath((m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData).prototypeID);
                        m_embattleUI["hero_name_txt_" + position ].url = CPlayerPath.getUIHeroNamePath((m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData).prototypeID);
                        m_embattleUI['clip_p_' + position ].visible = false;
                        m_embattleUI["clipCharacter_" + position ].dataSource = m_embattleUI.clipCharacter_temp.dataSource;
                        m_embattleUI["clipCharacter_" + position ].visible = true;
                        showTypeEff( position ,m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData );
                        _onShowHeroProperty( position ,m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData  );

                        updataList(m_embattleUI.clipCharacter_temp.dataSource as CPlayerHeroData);
                        onDispatchEvent();
                        _onPlayAudio( ( m_embattleUI["clipCharacter_" + position ].dataSource as CPlayerHeroData ).ID  );
                    }

                }
            }

        }else{
            if(m_embattleUI.list.hitTestObject(_dragBitmap)) {
                if(_pickUpIndex){
                    updataList(_curSpriteBlitFrameClip.dataSource as CPlayerHeroData,false);
                    m_embattleUI["img_bg_" + _pickUpIndex ].url = '';
                    m_embattleUI["hero_name_txt_" + _pickUpIndex ].url = '';
                    m_embattleUI['clip_p_' + _pickUpIndex ].visible = true;
                    _curSpriteBlitFrameClip.dataSource = null;
                    if ( m_embattleUI["clipCharacter_" + _pickUpIndex].framework ) {
                        m_embattleUI["clipCharacter_" + _pickUpIndex].framework = null;
                    }
                    hideTypeEff( _pickUpIndex );
                    _onShowHeroProperty( _pickUpIndex  );
                    _isBest = false;
                    onDispatchEvent();

                }else{
                    //回列表
                }

            }else{
                if(_pickUpIndex){
                    _curSpriteBlitFrameClip.visible = true;
                }else{

                }
            }
        }
        if(_dragBitmap && _dragBitmap.parent){
            _dragBitmap.parent.removeChild(_dragBitmap);
            _dragBitmap = null;
        }
        if ( (m_embattleUI.clipCharacter_temp as CCharacterFrameClip).framework )
            ( m_embattleUI.clipCharacter_temp as CCharacterFrameClip ).framework = null;
        _pickUpIndex = 0;
        updateTxt();

        m_embattleUI.list.selectedIndex = -1;
    }
    private function onDispatchEvent():void{
        _totalEmbatlleNum = 0;
        var list : Array = [];
        for( var i:int = 1 ; i <= 3 ; i ++ ){
            if( m_embattleUI["clipCharacter_" + i ].dataSource is CPlayerHeroData ){
                list.push( m_embattleUI["clipCharacter_" + i ].dataSource );
                _totalEmbatlleNum ++;
            } else {
                list.push( null );
            }
        }
        system.dispatchEvent( new CEmbattleEvent( CEmbattleEvent.EMBATTLE_POSITION_CHANGE , list ) );
    }

    //策划暂时隐藏
    private function showTypeEff( position : int ,playerHeroData:CPlayerHeroData ):void {
//        if ( !_needShowTypeEff || !_enemyListData )
//            return;
//        ( m_embattleUI[ 'box_typeEff_' + position ] as TypeCounterUI ).clip_career.index = playerHeroData.job;
//
//        ( m_embattleUI[ 'box_typeEff_' + position ] as TypeCounterUI ).frameClip_up.visible = _enemyListData[ position - 1 ] && getJobEx( playerHeroData.job, (_enemyListData[ position - 1 ] as CPlayerHeroData).job ) == 1;
//        ( m_embattleUI[ 'box_typeEff_' + position ] as TypeCounterUI ).frameClip_down.visible = _enemyListData[ position - 1 ] && getJobEx( playerHeroData.job, (_enemyListData[ position - 1 ] as CPlayerHeroData).job ) == -1;
//
//        m_embattleUI[ 'box_typeEff_' + position ].visible = true;
    }

    private function getJobEx( job1 : int , job2 : int ):int{
        if( job1 == job2 )
                return 0;
        if( job1 == 0 ){
            if( job2 == 1 )
                    return 1;
            else
                    return -1;
        }else if( job1 == 1 ){
            if( job2 == 2 )
                return 1;
            else
                return -1;
        }else if( job1 == 2 ){
            if( job2 == 0 )
                return 1;
            else
                return -1;
        }
        return 0;
    }
    private function hideTypeEff( position : int  ):void{
        m_embattleUI['box_typeEff_' + position ].visible = false;
    }
    private function get freePosition():int{
        var prosition : int;
        for( var index : int = 1 ; index <= 3 ; index++ ){
            if( m_embattleUI['clipCharacter_' + index ].framework == null ){
                prosition = index;
                break;
            }
        }
        return prosition;
    }
    private function get upHeroNum():int{
        var num : int;
        for( var index : int = 1 ; index <= 3 ; index++ ){
            if( m_embattleUI['clipCharacter_' + index ].framework  )
                num++;
        }
        return num;
    }
    private function _onMouseDownHandler(evt:MouseEvent):void{
        if((evt.currentTarget as SpriteBlitFrameClip).dataSource){
            _pickUpIndex = int(evt.currentTarget.name);
            (evt.currentTarget as SpriteBlitFrameClip).visible = false;
            _curSpriteBlitFrameClip = (evt.currentTarget as SpriteBlitFrameClip);
            onDrag();
        }
    }
    private function onDrag():void{
        _dragBitmap = new Bitmap();
        schedule( 41.666666666667/1000 , updateTempBitmap );
        App.stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
        m_embattleUI.addChild(_dragBitmap);
    }
    private function getEmbattle(type:int, position:int):Embattle{
        var embattle:Embattle;
        var embattleTable:IDataTable = _pCDatabaseSystem.getTable(KOFTableConstants.EMBATTLE);
        var ary : Array = embattleTable.findByProperty( "type", type );
        for each( var obj:Embattle in ary){
            if(obj.position == position ){
                embattle = obj;
            }
        }
        return embattle;
    }

    private function get playerData():CPlayerData{
        var pCPlayerData : CPlayerData = (playerSystem.getBean(CPlayerManager) as CPlayerManager).playerData;
        return pCPlayerData;
    }



    private function updataList( playerHeroData:CPlayerHeroData ,isAdd:Boolean = true):void{
        isAdd ? _onEmbattleAry.push(playerHeroData) : _onEmbattleAry.splice( _onEmbattleAry.indexOf(playerHeroData),1 );
        for each( playerHeroData in _onEmbattleAry ){
            for( var index : int  = 1 ;index <= 3 ; index++ ){
                if(m_embattleUI["clipCharacter_" + index ].dataSource == playerHeroData ){
                    playerHeroData.embattlePosition = index;
                    break
                }
            }
        }
        _onEmbattleAry.sortOn("embattlePosition", Array.NUMERIC | Array.DESCENDING);

        _playerList = playerData.heroList.getCommentList(_pEmbattleHandler.type) as Array;

        for each(var p:CPlayerHeroData in _onEmbattleAry){
            _playerList.splice(_playerList.indexOf(p),1);
            _playerList.unshift(p);
        }

        _updateEmHeroHP();

        m_embattleUI.list.dataSource = _playerList;
//        m_embattleUI.list.page = 0;
//        _onBtnDisabled();
    }
    private function _updateEmHeroHP() : void {
        // 添加血条处理 auto
        var clipCharacter:SpriteBlitFrameClip = null;
        var hpBar:ProgressBar = null;
        var heroData:CPlayerHeroData = null;
        for (var i:int = 0; i < 3; i++) {
            hpBar = (m_embattleUI["hp"+(1+i)] as ProgressBar);
            if (!hpBar) continue ;

            hpBar.visible = false;
            clipCharacter = m_embattleUI["clipCharacter_" + (i+1)] as SpriteBlitFrameClip;
            if (!clipCharacter || !(clipCharacter.visible)) continue ;
            if (isProcessHp) {
                heroData = clipCharacter.dataSource as CPlayerHeroData;
                if (heroData && heroData.extendsData) {
                    var hpMax:int = heroData.propertyData.HP;
                    var heroExtendsData:CHeroExtendsData = heroData.extendsData as CHeroExtendsData;
                    var hpCur:int = hpMax;
                    hpCur = heroExtendsData.hp;
                    if (hpMax > 0) {
                        hpBar.value = hpCur / hpMax;
                    } else {
                        hpBar.value = 0;
                    }
                    hpBar.visible = true;
                }
            }
        }
    }
    private function updateTxt():void{
        _totalEmbatlleNum = _totalEmbatllePower = 0;
        for( var i:int = 1 ; i <= 3 ; i ++ ){
            updatePowText( i , m_embattleUI["clipCharacter_" + i ].dataSource );
        }
//        m_embattleUI.txt_num.text = "出战人数: <font color='#ff00'>" + _totalEmbatlleNum + "/3</font>";
        m_embattleUI.kofnum_power.num = _totalEmbatllePower;
    }

    private function updatePowText( position:int, data:CPlayerHeroData ):void{
        if( !data ){
            return;
        }
        _totalEmbatlleNum += 1;
        _totalEmbatllePower += data.battleValue;
    }
    //todo 修改
    private function _onBestEmbattle():void{
        if( _isBest ){
            uiCanvas.showMsgAlert('已是最佳出战阵容');
            return;
        }

        var i:int;
        for ( i = 1 ; i <= 3 ; i++ ){
            if( m_embattleUI["clipCharacter_" + i ].dataSource ){
                updataList(m_embattleUI["clipCharacter_" + i ].dataSource,false);
                m_embattleUI["clipCharacter_" + i ].dataSource = null;
                m_embattleUI["img_bg_" + i ].url = '';
                m_embattleUI["hero_name_txt_" + i ].url = '';
                m_embattleUI["clipCharacter_" + i ].visible = false;
                m_embattleUI["clip_p_" + i ].visible = true;
                if( m_embattleUI["clipCharacter_" + i].framework )
                    m_embattleUI["clipCharacter_" + i].framework = null;
                hideTypeEff( i );
                _onShowHeroProperty( i );

            }
        }
        var playerHeroData:CPlayerHeroData;
        var data:CEmbattleData;
        var playList : Array = playerData.heroList.getCommentList(_pEmbattleHandler.type) as Array;
        var limit : int = _curInstanceType.embattleNumLimit;

        var chooseCount:int = 0; // 一键 布阵, 不上阵死亡角色
        for (i = 0; i < playList.length; i++) {
            playerHeroData = playList[i] as CPlayerHeroData;
            if (isProcessHp && playerHeroData.extendsData && (playerHeroData.extendsData as CHeroExtendsData).hp == 0) {
                // 死了的
            } else {
                chooseCount++;
                initSkin(chooseCount, playerHeroData);
                if( i == 0 ){
                    _onPlayAudio( playerHeroData.ID  );
                }
            }

            if (chooseCount >= limit) {
                break;
            }
        }
        if (chooseCount > 0) {
            _isBest = true;
        }

        updateTxt();
        onDispatchEvent();
    }
    private function initData():void{
        var embattleListData:CEmbattleListData = playerData.embattleManager.getByType(_pEmbattleHandler.type);
        if( !embattleListData )
                return;
        for each( var data:CEmbattleData in embattleListData.list){
            var playerHeroData:CPlayerHeroData =  playerData.heroList.getByPrimary(data.prosession) as CPlayerHeroData;
            initSkin(data.position,playerHeroData);
        }
        updateTxt();
    }
    private function initSkin(position:int,playerHeroData:CPlayerHeroData):void{
        if(!position || !playerHeroData ){
            return;
        }

        if ( !m_embattleUI["clipCharacter_" + position].framework ) {
            m_embattleUI["clipCharacter_" + position].framework = pScene.scenegraph.graphicsFramework;
        }
        m_embattleUI["clipCharacter_" + position ].visible = true;
        m_embattleUI["clipCharacter_" + position ].dataSource = playerHeroData;
        var pPlayerObject : PlayerBasic = playerHeroData.playerBasic; // pTable.findByPrimaryKey( playerHeroData.prototypeID ) as PlayerBasic;
        m_embattleUI["img_bg_" + position ].url = '';
        m_embattleUI["hero_name_txt_" + position ].url = '';
        m_embattleUI['clip_p_' + position ].visible = true;
        if(m_embattleUI["clipCharacter_" + position]){
            m_embattleUI["clipCharacter_" + position].skin = pPlayerObject.SkinName;
            m_embattleUI["img_bg_" + position ].url = CPlayerPath.getPeakUIHeroFacePath(playerHeroData.prototypeID);
            m_embattleUI["hero_name_txt_" + position ].url = CPlayerPath.getUIHeroNamePath(playerHeroData.prototypeID);
            m_embattleUI['clip_p_' + position ].visible = false;
            showTypeEff( position ,playerHeroData);
            _onShowHeroProperty( position , playerHeroData );
        }



        updataList( playerHeroData );
    }
    private function _addEventListeners():void {
        _removeEventListeners();
        if( m_embattleUI ){
            m_embattleUI.clipCharacter_1.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownHandler , false , 0, true );
            m_embattleUI.clipCharacter_2.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownHandler , false , 0, true );
            m_embattleUI.clipCharacter_3.addEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownHandler , false , 0, true );
        }
    }
    private function _removeEventListeners():void{
        if (m_embattleUI) {
            m_embattleUI.clipCharacter_1.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownHandler );
            m_embattleUI.clipCharacter_2.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownHandler );
            m_embattleUI.clipCharacter_3.removeEventListener(MouseEvent.MOUSE_DOWN, _onMouseDownHandler );

            var i:int;
            var pCharacterClip : CCharacterFrameClip;
            for( i = 1; i <= 3 ; i++ ){
                pCharacterClip  = m_embattleUI[ "clipCharacter_" + i ] as CCharacterFrameClip;
                if ( pCharacterClip ) {
                    pCharacterClip.visible = false;
                    pCharacterClip.skin = null;
                    pCharacterClip.framework = null;
                    pCharacterClip.dataSource = null;
                }
            }
            pCharacterClip = m_embattleUI.clipCharacter_temp as CCharacterFrameClip;

            if ( pCharacterClip ) {
                pCharacterClip.visible = false;
                pCharacterClip.skin = null;
                pCharacterClip.framework = null;
                pCharacterClip.dataSource = null;
            }

        }
    }
    private function _onLeft() : void {
        if( m_embattleUI.list.page <= 0 )
                return;
        m_embattleUI.list.page --;
        _onBtnDisabled();
    }
    private function _onRight() : void {
        if( m_embattleUI.list.page >= m_embattleUI.list.totalPage )
                return;
        m_embattleUI.list.page ++;
        _onBtnDisabled();
    }
    private function _onChangeBuff() : void {
        dispatchEvent(new Event(EVENT_CHANGE_BUFF));
    }

    private function _onFight() : void {
        system.removeEventListener( CEmbattleEvent.EMBATTLE_SUCC ,_embattleSucc );
        system.addEventListener( CEmbattleEvent.EMBATTLE_SUCC ,_embattleSucc );
        onEmbattleRequest();
    }
    private function _onSave():void{
        onEmbattleRequest( CEmbattleConst.SAVE_EMBATTLE );
    }
    private function onEmbattleRequest( handleType : int = 0 ):void{

        if( _curInstanceType && _totalEmbatlleNum < _curInstanceType.embattleNumMin ){
            uiCanvas.showMsgAlert( _curInstanceType.name + "至少要有" + _curInstanceType.embattleNumMin + "位上阵格斗家" );
            system.removeEventListener( CEmbattleEvent.EMBATTLE_SUCC ,_embattleSucc );
            return ;
        }
        if( _totalEmbatlleNum > _curInstanceType.embattleNumLimit ){
            uiCanvas.showMsgAlert("最大上阵格斗家人数为" + _curInstanceType.embattleNumLimit );
            system.removeEventListener( CEmbattleEvent.EMBATTLE_SUCC ,_embattleSucc );
            return ;
        }
//        if(  _totalEmbatlleNum <= 0 ){
//            uiCanvas.showMsgAlert("至少要有1位上阵格斗家");
//            return ;
//        }

        var obj:Object;
        var i:int;
        var playerHeroData:CPlayerHeroData;
        var embattleMessageList:Array = [];
        var embattleData : CEmbattleData;
        var isChange : Boolean;
        for( i = 1 ;i <= 3 ; i++ ){
            playerHeroData = m_embattleUI["clipCharacter_" + i ].dataSource;
            if(playerHeroData){
                obj = {};
                obj.heroID = playerHeroData.ID;
                obj.prosession = playerHeroData.prototypeID;
                obj.position = i;
                embattleMessageList.push(obj);
                embattleData = playerData.embattleManager.getEmbattleDataByTypeAndPosition( _pEmbattleHandler.type, i );
                if( !embattleData || embattleData.heroID != playerHeroData.ID )
                    isChange = true;
            }
        }
        var embattleListData:CEmbattleListData = playerData.embattleManager.getByType(_pEmbattleHandler.type);
        if( embattleMessageList.length != embattleListData.list.length )
            isChange = true;

        if( !isShowFight && !isChange){
//            uiCanvas.showMsgAlert("阵型没发生变化");
            return;
        }

        _pEmbattleHandler.onEmbattleMessageRequest(embattleMessageList , handleType);

//        m_embattleUI.close( Dialog.OK );
    }
    private function _embattleSucc( evt : CEmbattleEvent ):void{
        system.removeEventListener( CEmbattleEvent.EMBATTLE_SUCC ,_embattleSucc );
        if( _isRequestByClose && _pEmbattleHandler.type == EInstanceType.TYPE_CLIMP_CULTIVATE )
                return;
        dispatchEvent(new Event(EVENT_FIGHT_CLICK));
    }
    private function _onBtnDisabled():void{
        m_embattleUI.btn_left.disabled = m_embattleUI.list.page <= 0;
        m_embattleUI.btn_right.disabled = m_embattleUI.list.page >= m_embattleUI.list.totalPage - 1;
    }
    private function resetUI():void{
        for ( var index : int = 1 ; index <= 3 ;index++ ){
            m_embattleUI["img_bg_" + index ].url = '';
            m_embattleUI["hero_name_txt_" + index ].url = '';
            m_embattleUI['clip_p_' + index ].visible = true;
        }
    }
    private function _onShowHeroProperty( index : int ,playerHeroData:CPlayerHeroData = null ):void{
        if( _pEmbattleHandler.type != EInstanceType.TYPE_PEAK_GAME_FAIR || null == playerHeroData ){
            m_embattleUI['box_heroPro_' + index ].visible = false;
            return;
        }

        var num:int = playerHeroData.battleValue * (_peakConstant.battleValueParam / 10000) * 0.01;
        m_embattleUI['kofnum_addPro_'+ index].num = num;
        m_embattleUI['kofnum_addPower_'+ index].num = playerHeroData.battleValue;
        m_embattleUI['box_heroPro_' + index ].visible = true;

        delayCall(0.1, setPosition);
        function setPosition():void
        {
            var attrValue:KOFNum = m_embattleUI['kofnum_addPro_'+ index];
            var percent:Image = m_embattleUI['img_addPro_'+ index];
            percent.x = attrValue.x + attrValue.width + 2;
        }
    }
    private function _onClose( type : String ) : void {

        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }

//        switch ( type ) {
//            case Dialog.CLOSE:
//                _isRequestByClose = true;
//                dispatchEvent(new Event(Event.CLOSE));
//                onEmbattleRequest();
//                break;
//            case Dialog.OK:
//                break;
//
//        }
//        _removeEventListeners();
//        system.dispatchEvent( new CEmbattleEvent( CEmbattleEvent.EMBATTLE_CLOSE ) );
//        _totalEmbatlleNum = 0;
    }
    private function _onPlayAudio( ID : int ):void{
        var audio:IAudio = system.stage.getSystem( IAudio ) as IAudio;
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.PLAYER_DISPLAY );
        var playerDisplay : PlayerDisplay = pTable.findByPrimaryKey( ID );
        audio.playAudioByPath( playerDisplay.TeamSound, 1, 0);
    }
    private function _onTipsHandler( evt : MouseEvent ):void{
        m_embattleUI.view_tips.visible = evt.type == MouseEvent.ROLL_OVER;
    }
    private function get pScene():ISceneFacade{
        return system.stage.getSystem( ISceneFacade ) as ISceneFacade;
    }
    override protected virtual function updateData() : void {
        super.updateData();
    }

    private function get _peakConstant():PeakConstant{
        var dataTable : IDataTable  = _pCDatabaseSystem.getTable(KOFTableConstants.PEAK_GAME_CONSTANT) as IDataTable;
        return dataTable.findByPrimaryKey(1) as PeakConstant;
    }

    private function get _pEmbattleHandler():CEmbattleHandler{
        return system.getBean(CEmbattleHandler ) as CEmbattleHandler
    }
    private function get _pEmbattleManager():CEmbattleManager{
        return system.getBean(CEmbattleManager ) as CEmbattleManager
    }

    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get playerSystem():CPlayerSystem{
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }



    public function isViewShow() : Boolean {
        return m_embattleUI && m_embattleUI.stage;
    }

    [Inline]
    public function get isProcessHp():Boolean {
        return _isProcessHp;
    }
    [Inline]
    public function set isProcessHp(value:Boolean):void {
        _isProcessHp = value;
    }
    private var _isProcessHp:Boolean;

    [Inline]
    public function get isShowQuality():Boolean {
        return _isShowQuality;
    }
    [Inline]
    public function set isShowQuality(value:Boolean):void {
        _isShowQuality = value;
    }
    private var _isShowQuality:Boolean;
    [Inline]
    public function get isShowLevel():Boolean {
        return _isShowLevel;
    }
    [Inline]
    public function set isShowLevel(value:Boolean):void {
        _isShowLevel = value;
    }
    private var _isShowLevel:Boolean;

    [Inline]
    public function get isShowFight():Boolean {
        return _isShowFight;
    }
    [Inline]
    public function set isShowFight(value:Boolean):void {
        _isShowFight = value;
    }
    private var _isShowFight:Boolean;

    [Inline]
    public function get enemyList():Array {
        return _enemyList;
    }
    [Inline]
    public function set enemyList(value:Array):void {
        _enemyList = value;
    }
    public function get buffBox() : Box {
        return m_embattleUI.buff_box;
    }
    public function get buffIcon() : Image {
        return m_embattleUI.buff_icon;
    }
    private var _enemyList:Array;
    private var _emptyEnemyList:Array = [null, null, null];

    private var _heroEmbattleList:CHeroEmbattleListView;


}
}
