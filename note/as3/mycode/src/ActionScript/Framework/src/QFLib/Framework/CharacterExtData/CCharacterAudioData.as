//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/9/1.
//----------------------------------------------------------------------
package QFLib.Framework.CharacterExtData {

import QFLib.Foundation.CMap;

public class CCharacterAudioData {
    public function CCharacterAudioData() {
        m_dicAudio  = new CMap();
    }

    public function dispose() : void
    {
        m_dicAudio.clear();
    }

    public function loadData(mdata : Object) : void
    {
        if( mdata != null )
        {
            if( mdata.hasOwnProperty("audio") )
            {
                var keyDataVec:Vector.<CCharacterAudioKey> = null;
                var audioKey:CCharacterAudioKey = null;
                var audioData:Object = mdata["audio"];
                for ( var animationKey : * in audioData )//animationKey 动作名
                {
                    var animationMap:CMap = new CMap();
                    var keyDatas:Object = audioData[ animationKey ];
                    m_dicAudio.add( animationKey, animationMap );

                    for ( var skillKey : * in keyDatas )//skillKey 技能名
                    {
                        var infoDatas:Object = keyDatas[ skillKey ];
                        keyDataVec = new Vector.<CCharacterAudioKey>();
                        if( infoDatas != null)
                        {
                            for each(var keyData:Object in infoDatas)
                            {
                                audioKey = new CCharacterAudioKey();
                                audioKey.loadFromData( keyData );
                                keyDataVec.push(audioKey);
                            }
                            animationMap.add( skillKey, keyDataVec );
                        }
                    }
                }
            }
        }
    }

    public function getAudioKeysByNameAndSkillId( bName:String , skillId:String) : Vector.<CCharacterAudioKey>
    {
        var animationMap:CMap = m_dicAudio.find( bName );
        if( animationMap == null )return null;
        if( skillId == "default" ) skillId = bName;//如果是默认动作，输出的Jsond档动作名跟技能名一样
        var audioVec:Vector.<CCharacterAudioKey> = animationMap.find( skillId );
        return audioVec;
    }

    public function getAudioMap() : CMap
    {
        return m_dicAudio;
    }

    private var m_dicAudio : CMap;
}
}
