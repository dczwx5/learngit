//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/2/13.
//----------------------------------------------------------------------
package kof.game.character.fight.buff {

import QFLib.Foundation;
import QFLib.Foundation.CMap;
    import QFLib.Framework.CharacterExtData.CCharacterFXKey;
    import QFLib.Interface.IUpdatable;

    import kof.game.character.fight.buff.buffentity.CBuff;
    import kof.game.character.fight.buff.buffentity.CBuffAttModifiedProperty;
    import kof.game.character.fight.event.CFightTriggleEvent;
    import kof.game.character.fight.skillchain.CCharacterFightTriggle;
    import kof.game.character.fx.CFXMediator;
    import kof.game.core.CGameComponent;
    import kof.game.scene.CSceneHandler;
    import kof.table.Buff;

    /**
 * buff 自身的逻辑
 */
public class CBuffEffectComponent extends CGameComponent implements IUpdatable{

    public function CBuffEffectComponent( scendHdl : CSceneHandler ) {
        super("buffEffectDisplsy");
        m_pSceneHandler = scendHdl;
    }

    override public function dispose() : void
    {
        m_pSceneHandler = null;
        if( m_inPlayingBuffFX)
            m_inPlayingBuffFX.clear();
        m_inPlayingBuffFX = null;
    }

    override protected function onEnter() : void{
        _attachBuffEvent();
        m_inPlayingBuffFX = new CMap();
    }

    override protected function onExit() : void{
        _dettachBuffEvent();
        for each( var key : String in m_inPlayingBuffFX )
        {
            if( _boLastFXStopRightNow( key ) )
            {
                _stopBuffFX( key );
            }
        }
    }

    public function update( delta : Number ) : void
    {

    }

    public function playAddFX( pBuff : Buff ) : void
    {
        _playBuffFX( pBuff.BuffAddSFX );
    }

    public function playLastFX( pBuff : Buff ) : void
    {
        var buffName : String = pBuff.BuffLastSFX;
        _playBuffFX( buffName , true );
        _modifyLastPlayingFXCount( buffName , false );
    }

    public function playEffectFX( pBuff : Buff ) : void
    {
        _playBuffFX( pBuff.BuffEffectSFX );
    }

    public function playEndFX( pBuff : Buff ) : void
    {
        _playBuffFX( pBuff.BuffEndSFX );

    }

    public function stopLastFX( pBuff : Buff ) : void
    {
        var buffName : String = pBuff.BuffLastSFX;
        _modifyLastPlayingFXCount( buffName , true );
        if( _boLastFXStopRightNow( buffName ))
            _stopBuffFX( buffName );
    }

    private function _modifyLastPlayingFXCount( sFXName : String , boRemove : Boolean) : void
    {
        var currCount : int = m_inPlayingBuffFX[sFXName];
        currCount = boRemove ? (--currCount) : (++currCount);
        currCount = currCount<0?0:currCount;
        m_inPlayingBuffFX[ sFXName ] = currCount;
    }

    private function _boLastFXStopRightNow( sFxName : String ): Boolean
    {
        var currCount : int = m_inPlayingBuffFX[ sFxName ];
        var res : Boolean;
        res = currCount <= 0? true : false;
        return res;
    }

    private function _attachBuffEvent() : void
    {
        if( pCharacterFightTrigger )
        {
            pCharacterFightTrigger.addEventListener( CFightTriggleEvent.BUFF_ADD , _onBuffAdd );
            pCharacterFightTrigger.addEventListener( CFightTriggleEvent.BUFF_REMOVE , _onBuffRemove );
            pCharacterFightTrigger.addEventListener( CFightTriggleEvent.BUFF_EFFECT , _onBuffEffect );
        }
    }

    private function _dettachBuffEvent() : void
    {
        if( pCharacterFightTrigger )
        {
            pCharacterFightTrigger.removeEventListener( CFightTriggleEvent.BUFF_ADD , _onBuffAdd );
            pCharacterFightTrigger.removeEventListener( CFightTriggleEvent.BUFF_REMOVE , _onBuffRemove );
            pCharacterFightTrigger.removeEventListener( CFightTriggleEvent.BUFF_EFFECT , _onBuffEffect );
        }
    }

    private function _onBuffAdd( e : CFightTriggleEvent ): void
    {
        var theBuff : CBuff = e.parmList[0] as CBuff;
        addBuff( theBuff );
    }

    public function addBuff( theBuff : CBuff ) : void
    {
        var theBuffData : Buff = theBuff.buffData;

        if( pBuffProperty )
        {
            pBuffProperty.pushPropertyBuff( theBuff );
        }

        if( theBuffData ){
            playAddFX( theBuffData );
            playLastFX( theBuffData );
        }
    }

    private function _onBuffRemove( e : CFightTriggleEvent ): void
    {
        var theBuff : CBuff = e.parmList[0] as CBuff;
        removeBuff( theBuff );
    }

    public function removeBuff( theBuff : CBuff ) : void
    {

        var theBuffData : Buff = theBuff.buffData;

        if( pBuffProperty )
        {
            pBuffProperty.removeBuffProperty( theBuff );
        }

        if( theBuffData ){
            stopLastFX( theBuffData );
            if( _boLastFXStopRightNow(  theBuffData.BuffLastSFX ));
                playEndFX( theBuffData );
        }

        theBuff.removeBuffGameObject();
    }

    private function _onBuffEffect( e : CFightTriggleEvent ): void
    {
        var theBuff : CBuff = e.parmList[0] as CBuff;
        var theBuffData : Buff = theBuff.buffData;
        if( theBuffData ){
            playEffectFX( theBuffData );
        }
        theBuff.triggerBuffEffect();
    }

    private function _playBuffFX( fxName : String , boLoop : Boolean = false ) : void
    {
        if( pFxMediator && fxName != null ) pFxMediator.playComhitEffects( fxName , boLoop ,CCharacterFXKey.BUFF_FX );
    }

    private function _stopBuffFX( fxName : String ) : void
    {
        if( pFxMediator && fxName != null ) pFxMediator.stopComHitEffects( fxName , CCharacterFXKey.BUFF_FX);
    }

    final private function get pFxMediator() : CFXMediator
    {
        return owner.getComponentByClass( CFXMediator , true ) as CFXMediator;
    }

    final private function get pCharacterFightTrigger() : CCharacterFightTriggle
    {
        return owner.getComponentByClass( CCharacterFightTriggle , true ) as CCharacterFightTriggle;
    }

    final private function get pBuffProperty() : CBuffAttModifiedProperty
    {
        return owner.getComponentByClass( CBuffAttModifiedProperty , true ) as CBuffAttModifiedProperty;
    }

    private var m_pSceneHandler : CSceneHandler;
    protected var m_inPlayingBuffFX : CMap;

}
}
