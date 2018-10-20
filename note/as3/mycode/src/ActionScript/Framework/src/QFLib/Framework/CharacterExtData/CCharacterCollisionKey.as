//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/5/22.
//----------------------------------------------------------------------

package QFLib.Framework.CharacterExtData {

public class CCharacterCollisionKey {

    public function CCharacterCollisionKey() {
        m_vboundsList = new Vector.<CCharacterCollisionBoundInfo>();
    }

    public function dispose() : void
    {
        if(null != m_vboundsList)
        {
            m_vboundsList.splice(0,m_vboundsList.length);
        }

        m_vboundsList = null;
    }

    public function loadFromData(data : Object) : void
    {
        var collisonBound : CCharacterCollisionBoundInfo;

        if(null != data)
        {
            if(data.hasOwnProperty("keydata"))
            {
                var keydata : Object = data["keydata"];
                for each(var cb : * in keydata)
                {
                    collisonBound = new CCharacterCollisionBoundInfo();
                    collisonBound.loadFromData(cb);
                    m_vboundsList.push(collisonBound);
                }
            }

            if(data.hasOwnProperty("keytime"))
            {
                m_fKeyTime = data["keytime"];
            }

            if( data.hasOwnProperty("starttime"))
            {
                m_fStartTime = data["starttime"];
            }

        }

    }

    final public function get boundsList() : Vector.<CCharacterCollisionBoundInfo>
    {
        return m_vboundsList;
    }

    final public function get keyTime() : Number
    {
        return m_fKeyTime;
    }

    final public function get startTime() : Number
    {
        return m_fStartTime;
    }

    final public function get boHasTick() : Boolean
    {
        return m_boHasTick;
    }

    final public function set boHasTick(value : Boolean) : void
    {
        m_boHasTick = value;
    }

    private var m_vboundsList : Vector.<CCharacterCollisionBoundInfo>;
    private var m_fKeyTime : Number;
    private var m_fStartTime : Number = 0.0;
    private var m_boHasTick : Boolean;

}
}
