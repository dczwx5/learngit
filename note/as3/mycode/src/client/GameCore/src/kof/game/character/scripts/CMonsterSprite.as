//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/3/27.
 */
package kof.game.character.scripts {

    import QFLib.Framework.CFX;
    import QFLib.Framework.CFramework;
    import QFLib.Framework.CharacterExtData.CCharacterFXKey;
    import QFLib.Interface.IUpdatable;
    import QFLib.Memory.CResourcePool;
    import QFLib.ResourceLoader.ELoadingPriority;
    import QFLib.Utils.FileType;

    import kof.game.character.display.IDisplay;
    import kof.game.core.CGameComponent;

    /**
 * 怪物头顶特效
* */
public class CMonsterSprite extends CGameComponent implements IUpdatable {

    private var m_pGraphicFrameWork : CFramework;
    private var m_stopCallbackFun:Function;
    private var m_HeadFX : CFX;
    private var m_HeadFXKey : CCharacterFXKey;

    public function CMonsterSprite(  gf : CFramework  ) {
        super();
        m_pGraphicFrameWork = gf;
        m_HeadFXKey = new CCharacterFXKey();
    }

    override public function dispose() : void {
        super.dispose();
        m_pGraphicFrameWork = null;
        if( m_HeadFX )
        {
            m_HeadFX.stop ();
            CFX.manuallyRecycle( m_HeadFX );
            m_HeadFX = null;
        }
        if ( m_HeadFXKey )
        {
            m_HeadFXKey.dispose();
            m_HeadFXKey = null;
        }

        m_stopCallbackFun = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    public function showWarn(stopCallbackFun:Function = null):void{
        if(owner.data.hasOwnProperty( 'meetEnemyEffect')){
            if( owner.data.meetEnemyEffect != null ){
                var url:String = owner.data.meetEnemyEffect;
                m_stopCallbackFun = stopCallbackFun;
                show(url);
            }else if(stopCallbackFun != null){
                stopCallbackFun( null );
            }
        }else{
            if(stopCallbackFun != null){
                stopCallbackFun( null );
            }
        }
    }

    public function show(_url:String = ""):void{

        var sFX_URL : String;
        if( _url == "" ){
            return;
        }
        sFX_URL = _getURL( _url );

        if(m_HeadFX != null && m_HeadFX.filename != sFX_URL){
            m_HeadFX.stop();
            CFX.manuallyRecycle( m_HeadFX );
            m_HeadFX = null;
        }

        if(m_HeadFX == null){
            var pool : CResourcePool = this.m_pGraphicFrameWork.fxResourcePools.getPool( sFX_URL );
            if ( pool ) {
                m_HeadFX = pool.allocate() as CFX;
            }

            if(m_HeadFX == null) {
                m_HeadFX = new CFX( this.m_pGraphicFrameWork );
                m_HeadFX.loadFile( sFX_URL, ELoadingPriority.NORMAL, _onLoadFinished);
            }

            m_HeadFX.visible = true;
            m_HeadFX.onStopedCallBack = m_stopCallbackFun;
            m_HeadFX.play ( false, -1, 0.0, 0.0 );
        }
        else if ( !m_HeadFX.isPlaying ) {
            m_HeadFX.visible = true;
            m_HeadFX.play ( false, -1, 0.0, 0.0 );
        }

        m_HeadFXKey.playOneTime = true;
        m_HeadFXKey.playFollowTRS = true;
        m_HeadFXKey.boneIndex = pDisplay.modelDisplay.findBoneIndex ( "01_Tou" );
        m_HeadFXKey.localPosition.z = 0.1;
        m_HeadFX.attachToCharacter(pDisplay.modelDisplay,m_HeadFXKey);
    }

    private function _onLoadFinished(theFX : CFX, iResult : int):void{
        if(iResult == 0)
        {
            theFX.play ( false, -1, 0.0, 0.0 );
        }
        else
        {
            m_HeadFX = null;
        }
    }

    public function hideHeadSprite():void{
        if( m_HeadFX ){
            m_HeadFX.pause();
            m_HeadFX.visible = false;
        }
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

    public function update( delta : Number ) : void {
    }
}
}
