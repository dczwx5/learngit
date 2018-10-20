//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/5/22.
//----------------------------------------------------------------------

package QFLib.Framework.CharacterExtData {

import QFLib.Foundation.CMap;

public class CCharacterCollisionData {

    public function CCharacterCollisionData() {

        m_dicCollisions = new CMap();
        m_dicAnimationDuration = new CMap();
    }

    public function dispose() : void
    {
        m_dicCollisions.clear();
        m_dicAnimationDuration.clear();
    }

    public function loadData(mdata : Object) : void
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
            for ( key in data)
            {
                m_dicAnimationDuration.add( key , data[key] );
            }
        }
    }

    public function getTimeLineKeysByName(bName : String) : Vector.<CCharacterCollisionKey>
    {
       var result : Vector.<CCharacterCollisionKey>;
        result = m_dicCollisions.find(bName);
        return result;
    }

    public function getDurationTime( aName : String ) : Number
    {
        return m_dicAnimationDuration[ aName ];
    }

    private var m_dicCollisions : CMap;
    private var m_dicAnimationDuration : CMap;
}
}
