//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/15.
 */
package kof.game.character.NPC {

    import QFLib.Framework.CFX;
    import QFLib.Framework.CFramework;
    import QFLib.Framework.CharacterExtData.CCharacterFXKey;
    import QFLib.Interface.IUpdatable;
    import QFLib.Memory.CResourcePool;
    import QFLib.ResourceLoader.ELoadingPriority;
    import QFLib.Utils.FileType;

    import kof.data.KOFTableConstants;
    import kof.framework.IDataTable;
    import kof.framework.events.CEventPriority;
    import kof.game.character.CCharacterEvent;
    import kof.game.character.CDatabaseMediator;
    import kof.game.character.CEventMediator;
    import kof.game.character.display.IDisplay;
    import kof.game.character.scene.CSceneMediator;
    import kof.game.core.CGameComponent;
    import kof.table.NPC;

    public class CNPCSprite extends CGameComponent implements IUpdatable {

    public static const FOOT_FX : String = "npc_tx/ncp_guanghuan_tx_0001";
    public static const HEAD_TASK_FX : String = "npc_touding_ui_tx/npc_ui_tx_0006";
    public static const HEAD_TASKREWARD_FX : String = "npc_touding_ui_tx/npc_ui_tx_0007";

    private var m_pGraphicFrameWork : CFramework;
    private var m_FootFX : CFX = null;
    private var m_HeadFX : CFX = null;
    private var m_FootKey : CCharacterFXKey = null;
    private var m_HeadKey : CCharacterFXKey = null;

    public function CNPCSprite( gf : CFramework ) {
        super();
        m_pGraphicFrameWork = gf;
        m_FootKey = new CCharacterFXKey();
        m_HeadKey = new CCharacterFXKey();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady, false, CEventPriority.DEFAULT, true );
        }
    }

    private function _onCharacterDisplayReady( event : CCharacterEvent ) : void {
        if(m_HeadFX){
            var h:Number = pDisplay.defaultBound.height + 50;
            m_HeadFX.fxKey.localPosition.setValueXYZ(0,-h,0);
        }
    }

    override public function dispose() : void {
        super.dispose();
        m_pGraphicFrameWork = null;
        if( null != m_FootFX ){
            m_FootFX.stop();
            CFX.manuallyRecycle( m_FootFX );
            m_FootFX = null;
        }

        if ( null != m_FootKey )
        {
            m_FootKey.dispose();
            m_FootKey = null;
        }

        if( null != m_HeadFX )
        {
            m_HeadFX.stop();
            CFX.manuallyRecycle( m_HeadFX );
            m_HeadFX = null;
        }

        if ( null != m_HeadKey )
        {
            m_HeadKey.dispose();
            m_HeadKey = null;
        }
    }

    public function showHeadSprite(_url:String = ""):void{

        var sFX_URL : String;
        if(owner.data.taskID && owner.data.taskReward == 0){
            sFX_URL = _getURL( HEAD_TASK_FX );
        }else if(owner.data.taskID && owner.data.taskReward == 1){
            sFX_URL = _getURL( HEAD_TASKREWARD_FX );
        }
        else{
            if( _url == "" ){
                return;
            }
            sFX_URL = _getURL( _url );
        }

        if ( m_HeadFX != null && m_HeadFX.filename != sFX_URL ) {
            m_HeadFX.stop ();
            CFX.manuallyRecycle ( m_HeadFX );
            m_HeadFX = null;
        }

        if( m_HeadFX == null ){
            var pool : CResourcePool = this.m_pGraphicFrameWork.fxResourcePools.getPool( sFX_URL );
            if ( pool ) {
                m_HeadFX = pool.allocate() as CFX;
            }

            if(m_HeadFX == null) {
                m_HeadFX = new CFX( this.m_pGraphicFrameWork );
                m_HeadFX.loadFile( sFX_URL, ELoadingPriority.NORMAL, _onHeadFxLoaded );
            }
        }

        _headFXPlay();
    }

    private function _onHeadFxLoaded(pFx:CFX, iResult:int):void
    {
        if(iResult != 0)
        {
            m_HeadFX = null;
        }
    }

    private function _headFXPlay() : void {
        if(m_HeadFX == null) return;
        m_HeadKey.playFollowAnimationLoop = true;
        var h:Number = pDisplay.defaultBound ? pDisplay.defaultBound.height + 50 : 150;
        m_HeadKey.localPosition.setValueXYZ(0,-h,0);

        var modelDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( modelDisplay )
            m_HeadFX.attachToCharacter(modelDisplay.modelDisplay,m_HeadKey);
        m_HeadFX.play( true );
        m_HeadFX.visible = true;
    }

    public function hideHeadSprite():void{
        if( m_HeadFX ){
            m_HeadFX.pause();
            m_HeadFX.visible = false;
        }
    }

    public function showFootSprite():void {
        var sFX_URL : String = _getURL( FOOT_FX );
        if ( m_FootFX != null && m_FootFX.filename != sFX_URL ) {
            m_FootFX.stop();
            CFX.manuallyRecycle( m_FootFX );
            m_FootFX = null;
        }

        if ( m_FootFX == null ) {
            var pool : CResourcePool = this.m_pGraphicFrameWork.fxResourcePools.getPool( sFX_URL );
            if ( pool ) {
                m_FootFX = pool.allocate() as CFX;
            }

            if ( m_FootFX == null ) {
                m_FootFX = new CFX( this.m_pGraphicFrameWork );
                m_FootFX.loadFile( sFX_URL,ELoadingPriority.NORMAL, _onFootFXLoaded);
            }
            else
                _footFXPlay();
        }
        else {
            _footFXPlay();
        }
    }

    private function _footFXPlay () : void
    {
        m_FootKey.playFollowAnimationLoop = true;
        m_FootKey.localPosition.setValueXYZ(0,-5,0);
        var modelDisplay : IDisplay = owner.getComponentByClass( IDisplay, true ) as IDisplay;
        if ( modelDisplay )
            m_FootFX.attachToCharacter(modelDisplay.modelDisplay,m_FootKey);
        m_FootFX.visible = true;
        m_FootFX.play();
    }

    private function _onFootFXLoaded(theFX : CFX, iResult : int):void{
        if(iResult == 0)
        {
            _footFXPlay();
        }
        else
        {
            m_FootFX = null;
        }
    }

    public function hideFootSprite():void{
        if( m_FootFX ){
            m_FootFX.pause();
            m_FootFX.visible = false;
        }
    }

    final public function get display() : IDisplay {
        return getComponent( IDisplay ) as IDisplay;
    }

    public function update( delta : Number ) : void {
    }

    private function get pSceneMediator() : CSceneMediator
    {
        return owner.getComponentByClass( CSceneMediator , true ) as CSceneMediator;
    }

    final private function get pDisplay() : IDisplay
    {
        return owner.getComponentByClass( IDisplay , true ) as IDisplay;
    }

    private function _getURL( sName : String ) : String
    {
        if ( !sName || !sName.length )
            return null;

        return "assets/fx/" + sName + "." + FileType.JSON;
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
        if(owner.data.taskID){
            showHeadSprite();
        }else{
            hideHeadSprite();
        }

        var pNPCTable:IDataTable = (getComponent(CDatabaseMediator) as CDatabaseMediator).getTable(KOFTableConstants.NPC);
        var npc:NPC = pNPCTable.findByPrimaryKey( owner.data.prototypeID ) as NPC;
        if(npc.headImg != ""){
            showHeadSprite(npc.headImg);
        }
    }
}
}
