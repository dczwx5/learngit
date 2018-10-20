//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2016/9/22.
 */
package QFLib.Framework.CharacterExtData {

public class CCharacterAudioKey {

    public function CCharacterAudioKey()
    {
        m_audioVec = new Vector.<CCharacterAudioInfo>();
    }

    public function dispose():void
    {
        if( m_audioVec != null )
        {
            m_audioVec.splice(0,m_audioVec.length);
        }

        m_audioVec = null;
    }

    public function loadFromData( data:Object ):void
    {
        if( data != null)
        {
            if( data.hasOwnProperty("audioInfo"))
            {
                var audios:Array = data["audioInfo"] as Array;
                var audioInfo:CCharacterAudioInfo = null;
                for each(var obj:Object in audios)
                {
                    audioInfo = new CCharacterAudioInfo();
                    audioInfo.loadFromData(obj);
                    m_audioVec.push(audioInfo);
                }
            }

            if( data.hasOwnProperty("keyTime"))
            {
                m_fKeyTime = data["keyTime"];
            }

            if( data.hasOwnProperty("startTime"))
            {
                m_startTime = data["startTime"];
            }
        }
    }

    public function getAudioInfoVec() : Vector.<CCharacterAudioInfo>
    {
        return m_audioVec;
    }

    public function get keyTime() : Number
    {
        return m_fKeyTime;
    }

    public function get startTime() : Number
    {
        return m_startTime;
    }

    private var m_audioVec:Vector.<CCharacterAudioInfo>;
    private var m_fKeyTime:Number;//当前动作在所属技能的时间点
    private var m_startTime:Number;//当前动作开始时间（在所属技能时间轴上）
}
}
