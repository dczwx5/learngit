//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/23.
 */
package kof.game.player.view.playerNew.panel {

import QFLib.Foundation.CPath;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.Utils.PathUtil;

import flash.display.DisplayObject;
import flash.events.Event;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.config.CKOFConfigSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.player.data.CSkillData;
import kof.game.player.event.CPlayerEvent;
import kof.game.player.view.playerNew.CPlayerMainViewHandler;
import kof.game.player.view.playerNew.view.skillvideo.CSkillVideoPlayView;
import kof.game.player.view.skillup.CSkillUpConst;
import kof.table.ActiveSkillUp;
import kof.table.FlagDes;
import kof.table.PlayerSkill;
import kof.table.Skill;
import kof.table.SkillVideo;
import kof.ui.CUISystem;
import kof.ui.master.jueseNew.panel.PlayerSkillVideoUI;
import kof.ui.master.jueseNew.panel.SkillTipsTagUI;
import kof.ui.master.jueseNew.render.PlayerSkillItemViewUI;

import morn.core.components.Component;
import morn.core.events.UIEvent;

import morn.core.handlers.Handler;

/**
 * 招式录像
 */
public class CSkillVideoPanel extends CPlayerPanelBase {

    private var _videoViewUI : PlayerSkillVideoUI = null;

    private var m_pHeroData : CPlayerHeroData;

    private var _activeSkillAry : Array;

    private static const SPACE_INDEX : int = 5;

    private static const TYPE_ARY : Array = ['普','跳','U','I','O','space','','被','被','被','被'];

    private var _videoURL : String= "" ;

    private var _video : CSkillVideoPlayView = null;

    private var _videoIndex : int;

    private var _listRenderIndex : int;

    public function CSkillVideoPanel() {
        super();
    }
    public function get skillVideoUI() : PlayerSkillVideoUI {
        return this._videoViewUI;
    }
    override protected function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && onInitialize();
        if ( loadViewByDefault ) {
            ret = ret && loadAssetsByView( viewClass );
            ret = ret && onInitializeView();
        }
        return ret;
    }

    override public function initializeView() : void {
        super.initializeView();
        _videoViewUI = new PlayerSkillVideoUI();

        _videoViewUI.btn_return.clickHandler = new Handler( _onReturnHandler );

        _videoViewUI.list.renderHandler = new Handler( renderItem );
        _videoViewUI.list.selectHandler = new Handler( selectHandler );

        _videoViewUI.btn_left.clickHandler = new Handler(_onClickLeftHandler);
        _videoViewUI.btn_right.clickHandler = new Handler(_onClickRightHandler);

        _videoViewUI.view_skill.listTag.renderHandler = new Handler( _renderSkillTag );

        _video = new CSkillVideoPlayView( _videoViewUI ,system );


        var pConfigSystem : CKOFConfigSystem = system.stage.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
        _videoURL = pConfigSystem.configuration.getString( "videoURL" );

        this.view = _videoViewUI;

    }
    override protected function _initView():void
    {

    }

    override public function removeDisplay():void
    {
        super.removeDisplay();
        if( _videoViewUI && _videoViewUI.parent )
            _videoViewUI.parent.removeChild( _videoViewUI );
        _viewRemoveFromStage();
        unschedule( _onUpdateVideoPro );
        _videoIndex = 0;
    }

    override public function set data( value : * ) : void {
        m_pHeroData = value as CPlayerHeroData;
        if ( m_bViewInitialized ) {
            var allSkillArr : Array = getHeroSkills( m_pHeroData.prototypeID );
            _activeSkillAry = [allSkillArr[2],allSkillArr[3],allSkillArr[4],allSkillArr[5]];

            _listRenderIndex = 0;
            _videoViewUI.list.removeEventListener( UIEvent.ITEM_RENDER ,_onListRender );
            _videoViewUI.list.addEventListener( UIEvent.ITEM_RENDER ,_onListRender, false, 0, true );

            _videoViewUI.list.dataSource = _activeSkillAry;
            _videoViewUI.txt_heroName.text = m_pHeroData.heroName;

            _updateBtnState();

            unschedule( _onUpdateVideoPro );
            schedule( 300/1000,_onUpdateVideoPro );
        }
    }
    private function _onUpdateVideoPro( delta : Number ):void{
        _video.update();
    }
    private function _onClickLeftHandler():void {
        var playerHeroData : CPlayerHeroData = _playerHelper.getPrevOrNextHeroData(m_pHeroData.prototypeID,1);
        if( playerHeroData ){
            _videoIndex = 0;
            data = playerHeroData;
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.SWITCH_HERO, playerHeroData ) );
        }

    }
    private function _onClickRightHandler():void {
        var playerHeroData : CPlayerHeroData = _playerHelper.getPrevOrNextHeroData( m_pHeroData.prototypeID, 2 );
        if( playerHeroData ){
            _videoIndex = 0;
            data = playerHeroData;
            system.dispatchEvent( new CPlayerEvent( CPlayerEvent.SWITCH_HERO, playerHeroData ) );
        }
    }
    private function _onListRender( evt : UIEvent ):void{
        _listRenderIndex ++;
        if( _listRenderIndex >= 4 ){
            _videoViewUI.list.removeEventListener( UIEvent.ITEM_RENDER ,_onListRender );
            _videoViewUI.list.selectedIndex = _videoIndex;
            _videoViewUI.list.callLater( selectHandler,[_videoIndex] );
        }
    }

    private function renderItem( item : Component, idx : int ) : void {
        if ( !(item is PlayerSkillItemViewUI) ) {
            return;
        }
        var skillItemUI : PlayerSkillItemViewUI = item as PlayerSkillItemViewUI;
        var skillID : int ;
        skillID = int( skillItemUI.dataSource );
        var skillData : CSkillData = getSkillDataByID( skillID );
        var pSkill : Skill;
        if( !skillData ){
            pSkill = _skillTable.findByPrimaryKey( skillID );
        }else{
            pSkill = skillData.pSkill;
        }
        var pMaskDisplayObject : DisplayObject;
        if( idx == 3 ){
            skillItemUI.img_spcicalSkill.url = CPlayerPath.getSkillBigIcon( pSkill.IconName );
            skillItemUI.maskimgII.visible = false;
            pMaskDisplayObject =  skillItemUI.maskimgII;
            if ( pMaskDisplayObject ) {
                skillItemUI.img_spcicalSkill.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                skillItemUI.img_spcicalSkill.mask = pMaskDisplayObject;
            }

            skillItemUI.box_spcicalSkill.visible = true;
            skillItemUI.box_normalSkill.visible = false;
            skillItemUI.txt_type.text = CSkillUpConst.ACTIVE_SKILL_TYPE_ARY[ pSkill.SkillType ];
        }else{
            skillItemUI.img_normalSkill.url = CPlayerPath.getSkillBigIcon( pSkill.IconName );
            skillItemUI.maskimg.visible = false;
            pMaskDisplayObject =  skillItemUI.maskimg;
            if ( pMaskDisplayObject ) {
                skillItemUI.img_normalSkill.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                skillItemUI.img_normalSkill.mask = pMaskDisplayObject;
            }

            skillItemUI.txt_key.text = TYPE_ARY[idx+2];
            skillItemUI.box_spcicalSkill.visible = false;
            skillItemUI.box_normalSkill.visible = true;
            skillItemUI.txt_type.text = CSkillUpConst.ACTIVE_SKILL_TYPE_ARY[ pSkill.SkillType ];
        }
        skillItemUI.txt_name.text = pSkill.Name;
    }

    private function selectHandler( index : int ) : void {
        var playerSkillItemViewUI : PlayerSkillItemViewUI = _videoViewUI.list.getCell( index ) as PlayerSkillItemViewUI;
        if ( !playerSkillItemViewUI )
            return;
        var skillID : int ;
        skillID = int( playerSkillItemViewUI.dataSource );
        var skillData : CSkillData = getSkillDataByID( skillID );

        var activeSkillUp : ActiveSkillUp;
        if( !skillData ){
            activeSkillUp = _activeSkillUp.findByPrimaryKey( skillID );
        }else{
            activeSkillUp = skillData.activeSkillUp;
        }
        var pSkill : Skill;
        if( !skillData ){
            pSkill = _skillTable.findByPrimaryKey( skillID );
        }else{
            pSkill = skillData.pSkill;
        }

        _videoViewUI.view_skill.txt_name.text = pSkill.Name;
        _videoViewUI.view_skill.txt_type.text = CSkillUpConst.ACTIVE_SKILL_TYPE_ARY[ pSkill.SkillType ];
        _videoViewUI.view_skill.txt_cd.text =  activeSkillUp.CD  + "s";
        if( String( activeSkillUp.CD ).indexOf('.') != -1 &&
                String( activeSkillUp.CD ).slice( String( activeSkillUp.CD ).indexOf('.'),String( activeSkillUp.CD ).length ).length > 2 ){
            _videoViewUI.view_skill.txt_cd.text =  activeSkillUp.CD.toFixed( 2 )  + "s";
        }

//        if( skillData.skillPosition == 5 ){
        if( index == 3 ){
            _videoViewUI.view_skill.txt_consume.text = '3点';
            _videoViewUI.view_skill.txt_consumeT.text = '怒气消耗';
        }else{
            _videoViewUI.view_skill.txt_consume.text = String( activeSkillUp.consumeAP1 + activeSkillUp.consumeAP2 + activeSkillUp.consumeAP3 );
            _videoViewUI.view_skill.txt_consumeT.text = '能量消耗';
        }

        _videoViewUI.view_skill.txt_desc.text = '招式描述：'+ pSkill.LongDescription;

        _resetState();
        playerSkillItemViewUI.selected.visible = true;


        //技能标签
        var strII : String = pSkill.SkillFlag.toString(2) ;
        var aryII : Array = strII.split('' ).reverse();
        var tagIndex : int;
        var aryTag : Array = [];
        for( tagIndex = 0 ; tagIndex < aryII.length ; tagIndex++ ){
            if( int( aryII[tagIndex] == 1 )){
                aryTag.push( tagIndex + 1 );
            }
        }
        _videoViewUI.view_skill.listTag.dataSource = aryTag;

        ///视频播放

        var videoPath : String = "";

        var skillVideo : SkillVideo = _skillVideo.findByPrimaryKey( skillID );
        videoPath = _videoURL + skillVideo.VideoSource;
        if (/^http:\/\//g.test(videoPath)) {
            videoPath = videoPath + skillVideo.VideoName + ".mp4";
        } else {
            videoPath = skillVideo.VideoSource + skillVideo.VideoName + ".mp4";
            videoPath = (CResourceLoaders.instance().absoluteURI ? CPath.addRightSlash(CResourceLoaders.instance().absoluteURI) : "") + videoPath;
        }
        videoPath = CResourceLoaders.instance().assetVersion.mappingFilenameWithVersion(videoPath);

        _video.connection();
        _video.m__videoURL = '';//todo
        _video.m__loopState = CSkillVideoPlayView.LOOP;
        _video.playSteam( videoPath, skillVideo.VideoTitle );
        _video.show();

    }

    private function _renderSkillTag(item:Component, idx:int):void {
        if ( !(item is SkillTipsTagUI) ) {
            return;
        }
        var pSkillTipsTagUI : SkillTipsTagUI = item as SkillTipsTagUI;
        var pTable : IDataTable;
        var flagDes : FlagDes;
        if ( pSkillTipsTagUI.dataSource ) {
            pTable   = _databaseSystem.getTable( KOFTableConstants.FLAGDES );
            flagDes  = pTable.findByPrimaryKey( int( pSkillTipsTagUI.dataSource ) );
            if( flagDes ){
                pSkillTipsTagUI.img.url = PathUtil.getVUrl(flagDes.IconName);
            }
        }
    }

    private function _viewRemoveFromStage( evt : Event = null ):void{
        if( _video )
            _video.closeVideo();
    }
    private function _onReturnHandler():void{
        (system.getHandler(CPlayerMainViewHandler) as CPlayerMainViewHandler).hideSkillVideoView();
    }
    override protected function _addListeners():void
    {
        super._addListeners();

        if( _videoViewUI )
            _videoViewUI.addEventListener( Event.REMOVED_FROM_STAGE, _viewRemoveFromStage );
    }

    override protected function _removeListeners():void
    {
        super._removeListeners();

        if( _videoViewUI )
            _videoViewUI.removeEventListener( Event.REMOVED_FROM_STAGE, _viewRemoveFromStage );

    }

    /**
     * 得格斗家技能数据
     * @param heroId
     * @return
     */
    public function getHeroSkills( heroId:int ):Array {
        var playerSkill : PlayerSkill = _playerSkill.findByPrimaryKey(heroId);
        var skillArr : Array = playerSkill.SkillID.concat();
        return skillArr;
    }

    private function getSkillDataByID( skillID : int ):CSkillData{
        var skillData : CSkillData;
        var skillAry:Array = _playerData.heroList.getHero( m_pHeroData.prototypeID ).skillList.list;
        if( skillAry ){
            for each ( skillData in skillAry ){
                if( skillData.skillID == skillID )
                    return skillData;
            }
        }
        return null;
    }

    private function _resetState() : void {
        for ( var i : int = 0; i < _videoViewUI.list.length; i++ ) {
            var itemUI : PlayerSkillItemViewUI = _videoViewUI.list.getCell( i ) as PlayerSkillItemViewUI;
            itemUI.selected.visible = false;
        }
    }
    private function _updateBtnState():void
    {
        if(_playerHelper.isFirstHero(m_pHeroData.prototypeID))
        {
            _videoViewUI.btn_left.disabled = true;
        }
        else
        {
            _videoViewUI.btn_left.disabled = false;
        }

        if(_playerHelper.isLastHero(m_pHeroData.prototypeID))
        {
            _videoViewUI.btn_right.disabled = true;
        }
        else
        {
            _videoViewUI.btn_right.disabled = false;
        }
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }

    private function get _skillVideo():IDataTable {
        return _dataBase.getTable(KOFTableConstants.SKILLVIDEO);
    }
    private function get _playerSkill():IDataTable {
        return _dataBase.getTable(KOFTableConstants.PLAYER_SKILL);
    }
    private function get _skillGetCondition():IDataTable {
        return _dataBase.getTable(KOFTableConstants.SKILLGETCONDITION);
    }
    private function get _activeSkillUp():IDataTable {
        return   _dataBase.getTable( KOFTableConstants.ACTIVE_SKILL_UP );
    }
    private function get _skillTable():IDataTable {
        return  _dataBase.getTable( KOFTableConstants.SKILL );
    }
    private function get _dataBase():IDatabase {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  ( uiCanvas as CAppSystem ).stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pUISystem() : CUISystem {
        return ( uiCanvas as CAppSystem ).stage.getSystem( CUISystem ) as CUISystem;
    }


    public function get m__videoIndex() : int {
        return _videoIndex;
    }

    public function set m__videoIndex( value : int ) : void {
        _videoIndex = value;
    }
}
}
