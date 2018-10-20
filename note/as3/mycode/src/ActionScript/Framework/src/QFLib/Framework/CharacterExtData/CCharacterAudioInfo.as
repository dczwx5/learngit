//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2016/9/22.
 */
package QFLib.Framework.CharacterExtData {

public class CCharacterAudioInfo {

    public function CCharacterAudioInfo()
    {

    }

    public function loadFromData( data:Object ):void
    {
        if( data["name"] != null )
        {
            m_audioName = data["name"];
        }

        if( data["nLoop"] != null )
        {
            m_nLoop = data["nLoop"];
        }

        if( data["nEndPoint"] != null )
        {
            m_endPoint = data["nEndPoint"];
        }

        if( data["fProb"] != null )
        {
            m_prob = data["fProb"];
        }

        if( data["assetsPath"] != null)
        {
            m_audioPath = data["assetsPath"];
        }

        if( data["s_description"] != null )
        {
            s_description = data["sDescription"];
        }

        if( data["randomAudios"] != null )
        {
            m_randomAudios = data["randomAudios"] as Array;
        }
    }

    public function get audioName() : String {
        return m_audioName;
    }

    public function get nLoop() : int {
        return m_nLoop;
    }

    public function get endPoint() : int {
        return m_endPoint;
    }

    public function get prob() : Number {
        return m_prob;
    }

    public function get audioPath() : String {
        return m_audioPath;
    }

    public function get audioDescription() : String {
        return s_description;
    }

    public function get randomAudiosVec() : Array {
        return m_randomAudios;
    }

    public function get isPlayed() : Boolean {
        return m_bIsPlayed;
    }

    public function set isPlayed( value:Boolean ) : void {
        m_bIsPlayed = value;
    }

    private var m_audioName:String;//音效名称
    private var m_nLoop:int;//播放次数
    private var m_endPoint:int;//结束模式
    private var m_prob:Number;//触发概率
    private var m_audioPath:String;//音效路径

    private var s_description:String;//描述
    private var m_randomAudios:Array;//音效随机组

    private var m_bIsPlayed:Boolean = false;

}
}
