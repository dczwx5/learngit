//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/10/18.
//----------------------------------------------------------------------
package QFLib.Framework.CharacterExtData {
import QFLib.Foundation.CMap;

public class CCharacterCollisionAssemblyData {

    public function CCharacterCollisionAssemblyData(test : Boolean = false) {
        m_dicCollisions = new CMap();
//        m_dicAnimationDuration = new CMap();

        m_test = test;
    }

    public function dispose() : void
    {
        m_dicCollisions.clear();
//        m_dicAnimationDuration.clear();
        m_dicAnimationDuration = null;
    }

    public function loadData( mdata : Object ): void
    {
        if( !m_test )
            loadFinalData( mdata );
        else
            loadTestData( mdata );
    }

    private function loadTestData( mdata : Object) : void
    {
        var key : *;
        var data : Object = mdata.collision;
        //collision bound info
        {
            var keyDataList : Vector.<CCharacterCollisionKey>; //
            var keyData : CCharacterCollisionKey;
            for ( key in data ) {
                var kDatas : Object = data[ key ];
                keyDataList = new Vector.<CCharacterCollisionKey>();
                if ( null != kDatas ) {
                    for each( var kData : * in kDatas ) {

                        keyData = new CCharacterCollisionKey();
                        keyData.loadFromData( kData );
                        keyDataList.push( keyData );
                    }
                }

                m_dicCollisions.add( key, keyDataList );
            }
        }
        //collision loop time info , this is for missile
        data = mdata.AnimationDuration;
        if( data != null)
        {
            m_dicAnimationDuration = data;
//            for ( key in data)
//            {
//                m_dicAnimationDuration.add( key , data[key] );
//            }
        }
    }

    private function loadFinalData(mdata : Object) : void
    {
        var animationName : *;
        var data : Object = mdata.collision;
        //collision bound info
        {
            var skillsMap : CMap;
            var keyDataList : Vector.<CCharacterCollisionKey>; //
            var keyData : CCharacterCollisionKey;

            for ( animationName in data ) {
                skillsMap = new CMap();
                var skillsDatas : Object = data[ animationName ];
                var skillItemName : *;
                for ( skillItemName in  skillsDatas) {
                    var skillItemData : Object = skillsDatas[skillItemName];

                    keyDataList = new Vector.<CCharacterCollisionKey>();
                    if ( null != skillItemData ) {
                        for each( var kData : * in skillItemData ) {
                            keyData = new CCharacterCollisionKey();
                            keyData.loadFromData( kData );
                            keyDataList.push( keyData );
                        }
                    }
                    skillsMap.add( skillItemName , keyDataList )
                }

                m_dicCollisions.add( animationName, skillsMap );
            }
        }
        //collision loop time info , this is for missile
        data = mdata.AnimationDuration;

        if( data != null)
        {
            m_dicAnimationDuration = data;
//            for (  animationName in data )
//            {
//                m_dicAnimationDuration.add( animationName , data[animationName] );
//            }
        }
    }

    public function getDurationTime( aName : String ) : Number
    {
        if( m_dicAnimationDuration )
            return m_dicAnimationDuration[ aName ];
        return NaN;
    }

    private function getFinalTimeLineKeysByName(animationName : String , subName : String = "default") : Vector.<CCharacterCollisionKey>
    {
        var result : Vector.<CCharacterCollisionKey>;
        var skilsMap : CMap = m_dicCollisions.find( animationName );
        if( skilsMap )
            result = skilsMap.find(subName);
        return result;
    }

    private function getFinalTimeLineKeysForSkill(animationName : String , subName : String = "default") : Vector.<CCharacterCollisionKey>
    {
        var result : Vector.<CCharacterCollisionKey> = new <CCharacterCollisionKey>[];
        var skillsMap : CMap;
        var tagKeys : Vector.<CCharacterCollisionKey>;

        for( var key : String in m_dicCollisions )
        {
            skillsMap =  m_dicCollisions[key];
            tagKeys = skillsMap.find( subName );
            for each( var  tagKey : CCharacterCollisionKey in tagKeys  )
                    result.push( tagKey );
        }
        return result;
    }

    private function getTestTimeLineKeysByName(animationName : String , subName : String = "default") : Vector.<CCharacterCollisionKey>
    {
        var result : Vector.<CCharacterCollisionKey>;
        result = m_dicCollisions.find(animationName);
        return result;
    }

    public function getTimeLineKeysByName( animationName : String , subName : String = "default" ) :  Vector.<CCharacterCollisionKey>
    {

        return getFinalTimeLineKeysByName( animationName, subName );
    }

    public function getSkillTimeLineKeysByName( animationName : String , subName : String ) : Vector.<CCharacterCollisionKey>
    {
        return getFinalTimeLineKeysForSkill( animationName , subName );
    }

    private var m_dicCollisions : CMap;
    private var m_dicAnimationDuration : Object;
    private var m_test : Boolean;
}
}
