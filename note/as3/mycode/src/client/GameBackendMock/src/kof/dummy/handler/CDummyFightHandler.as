//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/2/21.
//----------------------------------------------------------------------
package kof.dummy.handler {

import QFLib.Interface.IUpdatable;

import kof.dummy.CDummyDatabase;
import kof.dummy.CDummyServer;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.message.CAbstractPackMessage;
import kof.message.Fight.FightMissileIdsResponse;
import kof.message.Fight.FightTimeLineResponse;
import kof.message.Fight.SkillCastRequest;
import kof.message.Pvp.AddBufferRequest;
import kof.message.Pvp.AddBufferResponse;
import kof.message.Pvp.RemoveBufferResponse;
import kof.table.Buff;
import kof.table.BuffEmitter;
import kof.table.Emitter;

public class CDummyFightHandler extends CAbstractHandler implements IUpdatable{
    public function CDummyFightHandler() {
        super();
        m_buffList = [];
    }

    public function update( delta : Number ) : void
    {
        for each ( var buff : _Buff in m_buffList )
        {
            if( buff.isValid() )
            {
                buff.update( delta );
            }
            else
            {
               _onRemoveBuff( buff );
            }
        }
    }

    final public function get server() : CDummyServer {
        return system as CDummyServer;
    }

    final public function get database() : CDummyDatabase {
        return server.getBean( CDummyDatabase ) as CDummyDatabase;
    }

    override protected virtual function onSetup() : Boolean {
        this.server.listen( AddBufferRequest, _onAddBuff );
        this.server.listen( SkillCastRequest , _onProduceMissile);
        m_missileID = 0;
        return true;
    }

    protected function _onAddBuff( req : CAbstractPackMessage ) : void
    {
        var msg : AddBufferRequest = req as AddBufferRequest;
        var buffEmitterInfo : BuffEmitter;
        var buffersResponse : Array = [] ;
        var buffResponseItem : _BuffResponseItem;
        var buffEmitterID : int = msg.emitBuffId;
        for each ( var bufferInfo : Object in msg.hitTarget )
        {
            buffEmitterInfo = _getBuffEmitter( buffEmitterID );
            var buffList : Array =  buffEmitterInfo.BuffID;
            buffResponseItem = new _BuffResponseItem();
            buffResponseItem.type = bufferInfo["type"];
            buffResponseItem.targetId = bufferInfo["targetId"];

            var buff : _Buff;
            for each( var buffID : int in buffList )
            {
                    if( buffID == 0 )break;
                    var bIndex : int  = _getBuffID();
                    buffResponseItem.buffers.push( { buffIndex : buffID , buffId : bIndex} );

                    buff = new _Buff();
                    buff.targetId = buffResponseItem.targetId;
                    buff.type = buffResponseItem.type;
                    buff.buffId = bIndex;
                    buff.m_elapsedTime = 0.0;
                    m_buffList.push( buff );
            }

            buffersResponse.push({ type : buffResponseItem.type , targetId : buffResponseItem.targetId ,
                buffers: buffResponseItem.buffers });

            var response : AddBufferResponse = new AddBufferResponse();
            response.type = buffResponseItem.type;
            response.targetId = buffResponseItem.targetId;
            response.buffers = buffResponseItem.buffers;
            response.srcId = msg.srcId;
            response.srcType = msg.type;
            this.server.send( response );
        }

    }

    private function  _onProduceMissile( req : CAbstractPackMessage ) : void{
        var msg : SkillCastRequest = req as SkillCastRequest;
        var emitterIds : Array = msg.dynamicStates["32"];
        var emitterInfo : Emitter;
        var responseData : Object = {};
        var ids : Array ;
        for( var key : String in emitterIds ){
            var count : int;
            emitterInfo =  _getEmitter(emitterIds[key]);
            if( emitterIds[key] in responseData )
                    ids = responseData[emitterIds[key]];
            else
                    ids = [];
            count = emitterInfo.MissileCount;
            for( var i: int = 0 ; i<count ; i++ ){
               ids.push( _getNextMissileID());
            }
            responseData[emitterIds[key]] = ids;
        }


        var response : FightMissileIdsResponse = new FightMissileIdsResponse();
        response.type = msg.type;
        response.ID = msg.ID;
        response.idsForEmitter = responseData;
        this.server.send( response );
    }


    protected function _onRemoveBuff( buff : _Buff) : void
    {
        var removeBuff : _Buff = buff;
        var idx : int  = m_buffList.indexOf( buff );
        var removeResponse : RemoveBufferResponse = new RemoveBufferResponse();
        removeResponse.targetId = removeBuff.targetId;
        removeResponse.type = removeBuff.type;
        removeResponse.bufferId = removeBuff.buffId;
        this.server.send( removeResponse );
        m_buffList.splice( idx , 1 );

    }

    private function _getBuffEmitter( id : int ) : BuffEmitter
    {
        var buffEmitterTable : IDataTable = database.getDataBaseTable( "BuffEmitter" );
        return buffEmitterTable.findByPrimaryKey( id );
    }

    private function _getBuff( id : int ) : Buff
    {
        var buffTable : IDataTable = database.getDataBaseTable( "Buff");
        return buffTable.findByPrimaryKey( id );
    }

     private function _getEmitter( id : int ) : Emitter
    {
        var buffTable : IDataTable = database.getDataBaseTable( "Emitter");
        return buffTable.findByPrimaryKey( id );
    }
    protected function _onResponseAddBuff() : void
    {

    }

    private function _getBuffID() : int
    {
        return m_buffID++;
    }

    private function _getNextMissileID() : int {
        return m_missileID++;
    }

    private var m_buffID : int;
    private var m_missileID : Number;
    private var m_buffList : Array;

}
}

import QFLib.Interface.IUpdatable;

class _BuffResponseItem{
    public function _BuffResponseItem() {
        buffers = [];
    }
    public var type : int;
    public var targetId : int;
    public var buffers : Array;
}

class _Buff implements IUpdatable {
    public var type : int;
    public var targetId : int ;
    public var buffId : int;
    public var m_elapsedTime : Number = 0.0;

    public function isValid() : Boolean
    {
        return 0 <= m_elapsedTime && m_elapsedTime <=20.0;
    }

    public function update( delta : Number ) : void
    {
        m_elapsedTime += delta;
    }

}