//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/3/28.
//----------------------------------------------------------------------

package QFLib.Graphics.Character
{
    import QFLib.Foundation;
    import QFLib.Foundation.CPath;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CVector2;
    import QFLib.ResourceLoader.CQsonLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceCache;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    import flash.geom.Rectangle;
    import spine.Bone;
    import spine.animation.Animation;

    public class CAnimationBounds
    {
        public function CAnimationBounds()
        {
        }

        public function dispose() : void
        {
            if( m_theAnimationBoundJsonResource != null )
            {
                m_theAnimationBoundJsonResource.dispose();
                m_theAnimationBoundJsonResource = null;
            }
            if( m_theAnimationBoundsResource != null )
            {
                m_theAnimationBoundsResource.dispose();
                m_theAnimationBoundsResource = null;
            }
            m_vAnimationBoundsRef = null;
            m_theSpineLoaderRef = null;
            m_sFilename = null;

            m_fnLoadFinished = null;

            m_bDisposed = true;
        }

        [Inline]
        final public function getBound( iAnimationIdx : int, bExtractAnimationOffset : Boolean = false, vExtractAnimationOffsetBoneIndices : Vector.<int> = null ) : CAABBox2
        {
                    if( m_vAnimationBoundsRef == null ) return null;
            if( iAnimationIdx < 0 || iAnimationIdx >= m_vAnimationBoundsRef.length ) iAnimationIdx = 0;
            var theAABB : CAABBox2 = m_vAnimationBoundsRef[ iAnimationIdx ].getBound( bExtractAnimationOffset );
            if( theAABB == null )
            {
                theAABB = _calculateAnimationBound( iAnimationIdx, bExtractAnimationOffset, vExtractAnimationOffsetBoneIndices );
                m_vAnimationBoundsRef[ iAnimationIdx ].insertBound( theAABB, bExtractAnimationOffset );
            }

            return theAABB;
        }

        [Inline]
        final public function get isEmpty() : Boolean
        {
            return ( m_vAnimationBoundsRef == null ) ? true : false;
        }

        //
        // callback: function onLoadFinished( theBounds : CAnimationBounds, iResult : int ) : void
        //
        public function loadFile( sFilename : String, theSpineLoader : CSpineLoader,
                                    iLoadingPriority : int = ELoadingPriority.NORMAL,
                                    onLoadFinished : Function = null ) : void
        {
            var sFile : String = CPath.driverDirName( sFilename );
            sFile += "_boundbox";

            var vBoundFilenames : Vector.<String> = new Vector.<String>( 2 );
            vBoundFilenames[ 0 ] = sFile + ".qson";
            vBoundFilenames[ 1 ] = sFile + ".json";

            m_theSpineLoaderRef = theSpineLoader;
            m_fnLoadFinished = onLoadFinished;
            CResourceLoaders.instance().startLoadFileFromPathSequence( vBoundFilenames, _onLoadFinished, CQsonLoader.NAME, iLoadingPriority, true );
        }

        public function createEmptyAnimationBounds( theSpineLoader : CSpineLoader ) : void
        {
            if( this.isEmpty == false ) return ;

            var sFile : String = CPath.driverDirName( theSpineLoader.skeletonFilename );
            sFile += "_boundbox";

            m_theAnimationBoundsResource = CResourceCache.instance().create( sFile, ".BOUNDS" );
            if( m_theAnimationBoundsResource == null )
            {
                var iNumAnimation : int = theSpineLoader.skeletonAnimation.stateData.skeletonData.animations.length;
                m_vAnimationBoundsRef = new Vector.<CAnimationBound>( iNumAnimation );
                for( var i : int = 0; i < iNumAnimation; i++ ) m_vAnimationBoundsRef[ i ] = new CAnimationBound();

                m_theAnimationBoundsResource = new CResource( sFile, ".BOUNDS", m_vAnimationBoundsRef, -1.0 );
                CResourceCache.instance().add( sFile, ".BOUNDS", m_theAnimationBoundsResource );
            }
            else
            {
                m_vAnimationBoundsRef = m_theAnimationBoundsResource.theObject as Vector.<CAnimationBound>;
            }

            m_theSpineLoaderRef = theSpineLoader;
        }

        //
        //
        private function _onLoadFinished( loader : CQsonLoader, idErrorCode : int ) : void
        {
            if( m_bDisposed ) return;
            if( idErrorCode != 0 )
            {
                if( m_fnLoadFinished != null ) m_fnLoadFinished( this, idErrorCode );
                return;
            }

            m_theAnimationBoundJsonResource = loader.createResource();
            if( m_theAnimationBoundJsonResource == null )
            {
                Foundation.Log.logErrorMsg( "_onLoadFinished(): cannot get theAnimationBound Json data( null): " + loader.loadingFilename );
                return ;
            }

            var sFile : String = CPath.driverDirName( loader.loadingFilename );

            m_theAnimationBoundsResource = CResourceCache.instance().create( sFile, ".BOUNDS" );
            if( m_theAnimationBoundsResource == null )
            {
                var theJson : Object = m_theAnimationBoundJsonResource.theObject;
                m_vAnimationBoundsRef = _createAnimationBoundsFromJson( theJson );
                if( m_vAnimationBoundsRef == null )
                {
                    Foundation.Log.logErrorMsg( "_onLoadFinished(): _createEmptyAnimationBoundsFromJson failed: " + loader.loadingFilename );
                    if( m_fnLoadFinished != null ) m_fnLoadFinished( this, -1 );
                    return ;
                }

                m_theAnimationBoundsResource = new CResource( sFile, ".BOUNDS", m_vAnimationBoundsRef, -1.0 );
                CResourceCache.instance().add( sFile, ".BOUNDS", m_theAnimationBoundsResource );
            }
            else
            {
                m_vAnimationBoundsRef = m_theAnimationBoundsResource.theObject as Vector.<CAnimationBound>;
            }

            m_sFilename = loader.loadingFilename;

            if( m_fnLoadFinished != null ) m_fnLoadFinished( this, 0 );
        }

        private function _createAnimationBoundsFromJson( theJson : Object ) : Vector.<CAnimationBound>
        {
            if( theJson.hasOwnProperty( "boundbox" ) == false )
            {
                Foundation.Log.logErrorMsg( "_createEmptyAnimationBoundsFromJson(): no 'boundbox' found in json object." );
                return null;
            }
            if( theJson.boundbox.hasOwnProperty( "default" ) == false )
            {
                Foundation.Log.logErrorMsg( "_createEmptyAnimationBoundsFromJson(): no 'boundbox.default' found in json object." );
                return null;
            }

            var theAnimationBoundJson : Object = theJson.boundbox[ "default" ];
            var theAnimationBoundNoOffsetJson : Object = theJson.boundbox[ "noOffset" ];

            var iNumAnimation : int = 0;
            for( var s : String in theAnimationBoundJson ) iNumAnimation++;

            var i : int = 0;
            var vAnimationNames : Vector.<String> = new Vector.<String>( iNumAnimation );
            for( var sAnimationName : String in theAnimationBoundJson ) vAnimationNames[ i++ ] = sAnimationName;
            vAnimationNames.sort( Array.CASEINSENSITIVE );

            var fX : Number;
            var fY : Number;
            var fExtX : Number;
            var fExtY : Number;
            var theAABB : CAABBox2;
            var theAnimationBound : CAnimationBound;
            var vAnimationBoundsRef : Vector.<CAnimationBound> = new Vector.<CAnimationBound>( iNumAnimation );
            for( i = 0; i < iNumAnimation; i++ )
            {
                theAnimationBound = new CAnimationBound();

                fX = theAnimationBoundJson[ vAnimationNames[ i ] ].center[ 0 ];
                fY = theAnimationBoundJson[ vAnimationNames[ i ] ].center[ 1 ];
                fExtX = theAnimationBoundJson[ vAnimationNames[ i ] ].ext[ 0 ];
                fExtY = theAnimationBoundJson[ vAnimationNames[ i ] ].ext[ 1 ];
                theAABB = new CAABBox2( CVector2.ZERO );
                theAABB.setCenterExtValue( fX, fY, fExtX, fExtY );
                theAnimationBound.insertBound( theAABB, false );

                if( theAnimationBoundNoOffsetJson != null )
                {
                    fX = theAnimationBoundNoOffsetJson[ vAnimationNames[ i ] ].center[ 0 ];
                    fY = theAnimationBoundNoOffsetJson[ vAnimationNames[ i ] ].center[ 1 ];
                    fExtX = theAnimationBoundNoOffsetJson[ vAnimationNames[ i ] ].ext[ 0 ];
                    fExtY = theAnimationBoundNoOffsetJson[ vAnimationNames[ i ] ].ext[ 1 ];
                    theAABB = new CAABBox2( CVector2.ZERO );
                    theAABB.setCenterExtValue( fX, fY, fExtX, fExtY );
                    theAnimationBound.insertBound( theAABB, true );
                }

                vAnimationBoundsRef[ i ] = theAnimationBound;
            }

            return vAnimationBoundsRef;
        }

        private function _calculateAnimationBound( iAnimationIndex : int, bExtractAnimationOffset : Boolean = false, vExtractAnimationOffsetBoneIndices : Vector.<int> = null ) : CAABBox2
        {
            if( m_theSpineLoaderRef == null ) return null;

            const fTimeSlice : Number = 1 / 15.0;
            if( m_theTempRect == null ) m_theTempRect = new Rectangle();
            if( m_theTempMaxRect == null ) m_theTempMaxRect = new Rectangle();

            var theAnimationClip : Animation = m_theSpineLoaderRef.skeletonAnimation.stateData.skeletonData.animations[ iAnimationIndex ];
            m_theSpineLoaderRef.skeletonAnimation.state.setAnimation( 0, theAnimationClip, false );

            m_theSpineLoaderRef.skeletonAnimation.advanceTime( 0.0 );
            m_theSpineLoaderRef.skeletonAnimation.calcBounds( m_theTempMaxRect );

            var iNumAdvanceTimes : int = int( theAnimationClip.duration / fTimeSlice ) + 1;
            for( var j : int = 0; j < iNumAdvanceTimes; j++ )
            {
                if( bExtractAnimationOffset )
                {
                    m_theSpineLoaderRef.skeletonAnimation.advanceTimeOnly( fTimeSlice, true );
                    _clearAnimationOffsetBonePositions( vExtractAnimationOffsetBoneIndices, true );
                }
                else
                {
                    m_theSpineLoaderRef.skeletonAnimation.advanceTime( fTimeSlice );
                }

                m_theSpineLoaderRef.skeletonAnimation.calcBounds( m_theTempRect );

                if( m_theTempRect.x == Number.MIN_VALUE || m_theTempRect.y == Number.MIN_VALUE ||
                    m_theTempRect.width == ( Number.MAX_VALUE - Number.MIN_VALUE ) ||
                    m_theTempRect.height == ( Number.MAX_VALUE - Number.MIN_VALUE ) )
                {
                    // means no bound at this time frame, skip it
                    continue;
                }

                if( m_theTempMaxRect.left > m_theTempRect.left ) m_theTempMaxRect.left = m_theTempRect.left;
                if( m_theTempMaxRect.right < m_theTempRect.right ) m_theTempMaxRect.right = m_theTempRect.right;
                if( m_theTempMaxRect.top > m_theTempRect.top ) m_theTempMaxRect.top = m_theTempRect.top; // up side down
                if( m_theTempMaxRect.bottom < m_theTempRect.bottom ) m_theTempMaxRect.bottom = m_theTempRect.bottom; // up side down
            }

            var theAABB : CAABBox2 = new CAABBox2( CVector2.ZERO );
            theAABB.setCenterExtValue( ( m_theTempMaxRect.left + m_theTempMaxRect.right ) * 0.5, ( m_theTempMaxRect.top + m_theTempMaxRect.bottom ) * 0.5,
                    m_theTempMaxRect.width * 0.5, m_theTempMaxRect.height * 0.5 );

            return theAABB;
        }

        /*public function createAnimationBounds( theCharacter : CCharacterObject, fTimeSlice : Number = 1.0 / 30.0 ) : Boolean
        {
            var sAnimationBoundResourceName : String = theCharacter.spineLoader.skeletonFilename + ".BOUNDS";
            m_theAnimationBoundsResource = CResourceCache.instance().create( sAnimationBoundResourceName );
            if( m_theAnimationBoundsResource == null )
            {
                m_vAnimationBoundsRef = new Vector.<CAnimationBound>();

                Foundation.Perf.sectionBegin( "CAnimationBounds_CreateAnimationBounds" );
                _calculateAnimationBounds( m_vAnimationBoundsRef, theCharacter, fTimeSlice );
                Foundation.Perf.sectionEnd( "CAnimationBounds_CreateAnimationBounds" );

                if( m_vAnimationBoundsRef != null )
                {
                    m_theAnimationBoundsResource = new CResource( sAnimationBoundResourceName, m_vAnimationBoundsRef );
                    CResourceCache.instance().add( sAnimationBoundResourceName, m_theAnimationBoundsResource );
                }
                else
                {
                    Foundation.Log.logErrorMsg( "createAnimationBounds(): create animation bounds FAILED: " + theCharacter.spineLoader.skeletonFilename );
                    return false;
                }
            }
            else
            {
                m_vAnimationBoundsRef = m_theAnimationBoundsResource.theObject as Vector.<CAnimationBound>;
            }

            return true;
        }

        public function createAnimationOffsetExtractedBounds( theCharacter : CCharacterObject, fTimeSlice : Number = 1.0 / 30.0 ) : Boolean
        {
            if( m_vAnimationBoundsRef == null ) return false;

            _calculateAnimationBoundsWithoutOffset( m_vAnimationBoundsRef, theCharacter, fTimeSlice );

            return true;
        }

        //
        private function _calculateAnimationBounds( theAnimationBounds :  Vector.<CAnimationBound>, theCharacter : CCharacterObject, fTimeSlice : Number = 1.0 / 30.0 ) : void
        {
            if( theCharacter == null ) return;
            if( theCharacter.skeletonAnimation == null ) return;

            var theRect : Rectangle = new Rectangle();
            var theMaxRect : Rectangle = new Rectangle();
            var theMaxRectWithoutOffset : Rectangle = new Rectangle();

            var theAnimationBound : CAnimationBound;
            var theAABB : CAABBox2 = new CAABBox2( CVector2.ZERO );
            var theAABBWithoutOffset : CAABBox2 = new CAABBox2( CVector2.ZERO );
            var theAnimationClip : Animation;
            var theEntry : TrackEntry;

            // get default AABB
            theCharacter.skeletonAnimation.getBounds( theCharacter.skeletonAnimation, theMaxRect );
            var theDefaultAABB : CAABBox2 = new CAABBox2( CVector2.ZERO );
            theDefaultAABB.setCenterExtValue( ( theMaxRect.left + theMaxRect.right ) * 0.5, ( theMaxRect.top + theMaxRect.bottom ) * 0.5,
                                                theMaxRect.width * 0.5, theMaxRect.height * 0.5 );

            // then get AABB of each animation clip
            var iNumAnimations : int =  theCharacter.skeletonAnimation.stateData.skeletonData.animations.length;
            var iIndex : int;
            for( iIndex = 0; iIndex < iNumAnimations; iIndex++ )
            {
                theAnimationClip = theCharacter.skeletonAnimation.stateData.skeletonData.animations[ iIndex ];
                theEntry = theCharacter.skeletonAnimation.state.setAnimation( 0, theAnimationClip, false );

                theCharacter.skeletonAnimation.advanceTime( 0.0 );
                theCharacter.skeletonAnimation.getBounds( theCharacter.skeletonAnimation, theRect );
                theMaxRect.copyFrom( theRect );
                theMaxRectWithoutOffset.copyFrom( theRect );

                var iNumAdvanceTimes : int = int( theAnimationClip.duration / fTimeSlice ) + 1;
                for( var j : int = 0; j < iNumAdvanceTimes; j++ )
                {
                    theCharacter.skeletonAnimation.advanceTime( fTimeSlice );
                    theCharacter.skeletonAnimation.getBounds( theCharacter.skeletonAnimation, theRect );

                    if( theRect.x == Number.MIN_VALUE || theRect.y == Number.MIN_VALUE ||
                        theRect.width == ( Number.MAX_VALUE - Number.MIN_VALUE ) ||
                        theRect.height == ( Number.MAX_VALUE - Number.MIN_VALUE ) )
                    {
                        // means no bound at this time frame, skip it
                        continue;
                    }

                    if( theMaxRect.left > theRect.left ) theMaxRect.left = theRect.left;
                    if( theMaxRect.right < theRect.right ) theMaxRect.right = theRect.right;
                    if( theMaxRect.top > theRect.top ) theMaxRect.top = theRect.top; // up side down
                    if( theMaxRect.bottom < theRect.bottom ) theMaxRect.bottom = theRect.bottom; // up side down

                    theCharacter.clearAnimationOffsetBonePositions( true );
                    theCharacter.skeletonAnimation.getBounds( theCharacter.skeletonAnimation, theRect );

                    if( theMaxRectWithoutOffset.left > theRect.left ) theMaxRectWithoutOffset.left = theRect.left;
                    if( theMaxRectWithoutOffset.right < theRect.right ) theMaxRectWithoutOffset.right = theRect.right;
                    if( theMaxRectWithoutOffset.top > theRect.top ) theMaxRectWithoutOffset.top = theRect.top; // up side down
                    if( theMaxRectWithoutOffset.bottom < theRect.bottom ) theMaxRectWithoutOffset.bottom = theRect.bottom; // up side down
                }

                theAABB.setCenterExtValue( ( theMaxRect.left + theMaxRect.right ) * 0.5, ( theMaxRect.top + theMaxRect.bottom ) * 0.5,
                                             theMaxRect.width * 0.5, theMaxRect.height * 0.5 );
                theAABBWithoutOffset.setCenterExtValue( ( theMaxRectWithoutOffset.left + theMaxRectWithoutOffset.right ) * 0.5, ( theMaxRectWithoutOffset.top + theMaxRectWithoutOffset.bottom ) * 0.5,
                                                          theMaxRectWithoutOffset.width * 0.5, theMaxRectWithoutOffset.height * 0.5 );
                theAnimationBound = new CAnimationBound( theAABB, theAABBWithoutOffset );
                theAnimationBounds.push( theAnimationBound );
            }

            // additional push a default bound to the end of vVisibilityBounds
            theAnimationBound = new CAnimationBound( theDefaultAABB, theDefaultAABB );
            theAnimationBounds.push( theAnimationBound );
        }*/

        private function _clearAnimationOffsetBonePositions( vExtractAnimationOffsetBoneIndices : Vector.<int>, bUpdateTransform : Boolean ) : void
        {
            if( vExtractAnimationOffsetBoneIndices != null )
            {
                var iBoneIdx : int;
                var theBone : Bone;
                for( var i : int = 0; i < vExtractAnimationOffsetBoneIndices.length; i++ )
                {
                    iBoneIdx = vExtractAnimationOffsetBoneIndices[ i ];
                    if( iBoneIdx >= 0 || iBoneIdx < m_theSpineLoaderRef.skeletonAnimation.skeleton.bones.length )
                    {
                        theBone = m_theSpineLoaderRef.skeletonAnimation.skeleton.bones[ iBoneIdx ];
                        theBone.x = theBone.y = 0.0;
                    }
                }

                if( bUpdateTransform ) m_theSpineLoaderRef.skeletonAnimation.skeleton.updateWorldTransform();
            }
        }


        //
        //
        private var m_sFilename : String = null;
        private var m_theAnimationBoundJsonResource : CResource = null;
        private var m_theAnimationBoundsResource : CResource = null;
        private var m_vAnimationBoundsRef : Vector.<CAnimationBound> = null;
        private var m_theSpineLoaderRef : CSpineLoader = null;

        private var m_fnLoadFinished : Function = null;

        private var m_theTempRect : Rectangle = null;
        private var m_theTempMaxRect : Rectangle = null;

        private var m_bDisposed : Boolean = false;
    }

}

import QFLib.Math.CAABBox2;

class CAnimationBound
{
    public function CAnimationBound()
    {
    }

    [Inline]
    final public function insertBound( aabb : CAABBox2, bExtractAnimationOffset : Boolean ) : void
    {
        if( bExtractAnimationOffset == false ) m_theAABB = aabb;
        else m_theAABBWithoutOffset = aabb;
    }

    [Inline]
    final public function getBound( bExtractAnimationOffset : Boolean ) : CAABBox2
    {
        if( bExtractAnimationOffset == false ) return m_theAABB;
        else return m_theAABBWithoutOffset;
    }
    //
    //
    private var m_theAABB : CAABBox2 = null;
    private var m_theAABBWithoutOffset : CAABBox2 = null;
}
