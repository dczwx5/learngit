//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by Dan Lin on 2016/6/27.
//----------------------------------------------------------------------
package QFLib.Framework
{

    import QFLib.Audio.CAudioManager;
    import QFLib.Audio.audio.CAudioSource;
    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CPath;
    import QFLib.Foundation.CSet;
    import QFLib.Framework.CharacterExtData.CCharacterAudioData;
    import QFLib.Framework.CharacterExtData.CCharacterAudioInfo;
    import QFLib.Framework.CharacterExtData.CCharacterAudioKey;
    import QFLib.Framework.CharacterExtData.CCharacterCollisionAssemblyData;
    import QFLib.Framework.CharacterExtData.CCharacterCollisionBoundInfo;
    import QFLib.Framework.CharacterExtData.CCharacterCollisionKey;
    import QFLib.Framework.CharacterExtData.CCharacterFXData;
    import QFLib.Framework.CharacterExtData.CCharacterFXDataLoader;
    import QFLib.Framework.CharacterExtData.CCharacterFXKey;
    import QFLib.Graphics.Character.CAnimationClip;
    import QFLib.Graphics.Character.CAnimationClipInfo;
    import QFLib.Graphics.Character.CCharacterObject;
    import QFLib.Graphics.Character.model.CEquipSkinsInfo;
    import QFLib.Graphics.RenderCore.CBaseObject;
    import QFLib.Graphics.RenderCore.CImageObject;
    import QFLib.Graphics.RenderCore.render.IMaterial;
    import QFLib.Graphics.Scene.CLightData;
    import QFLib.Graphics.Scene.CSceneLayer;
    import QFLib.Math.CAABBox2;
    import QFLib.Math.CAABBox3;
    import QFLib.Math.CMath;
    import QFLib.Math.CVector2;
    import QFLib.Math.CVector3;
    import QFLib.Memory.CResourcePool;
    import QFLib.Node.CNode;
    import QFLib.Node.EDirtyFlag;
    import QFLib.Node.EParentMode;
    import QFLib.ResourceLoader.CJsonLoader;
    import QFLib.ResourceLoader.CPackedQsonLoader;
    import QFLib.ResourceLoader.CResource;
    import QFLib.ResourceLoader.CResourceCache;
    import QFLib.ResourceLoader.CResourceLoaders;
    import QFLib.ResourceLoader.ELoadingPriority;

    import spineExt.CCharacterResourceData;

//
    //
    //
    public class CCharacter extends CObject
    {
        protected const STRING_DEFAULT:String = "default";

        public function CCharacter( theBelongFramework : CFramework, animationController : CAnimationController = null )
        {
            super( theBelongFramework );

            m_theAnimationController = animationController;
            if( m_theAnimationController != null )
            {
                m_theAnimationController._setCharacter( this );
                m_theAnimationController.addStateChangedCallback( _onStateChanged );
            }

            m_theCharacterObject = new CCharacterObject( theBelongFramework.renderer, animationController );

            m_mapComHitEffects = new CMap ();
            m_mapBuffEffects = new CMap ();

            m_theCollisionObj = new CCollisionObject( belongFramework.collisionPool,this );

        }

        public override function dispose() : void
        {
            _setShadowImage( null );

            clear( false );

            if( m_theAnimationController != null )
            {
                m_theAnimationController.removeStateChangedCallback( _onStateChanged );
                m_theAnimationController.dispose();
                m_theAnimationController = null;
            }

            super.dispose();
        }

        public function clear( bCreateCharacterObject : Boolean = true ) : void
        {
            m_sFilename = null;

            // recycle fx
            var pFX : CFX;
            if( m_setPlayingFXs.length > 0 )
            {
                for each( pFX in m_setPlayingFXs )
                {
                    var pFxKey : CCharacterFXKey = pFX.fxKey;
                    if ( !pFX.isStopped &&
                            ( pFxKey != null && !pFxKey.playFollowTRS ))
                    {
                        pFX.setAutoRecycle( true );
                        pFX.onStopedCallBack = null;
                        continue;
                    }

                    pFX.stop();
                    _recycleAnimationFX( pFX );
                }
                m_setPlayingFXs.clear();
            }

            if( m_vStoppedFXs.length > 0 )
            {
                for each( pFX in m_vStoppedFXs )
                {
                    pFX.stop();
                    _recycleAnimationFX( pFX );
                }
                m_vStoppedFXs.length = 0;
            }

            // fx
            if( null != m_theCharacterFXDataResource )
            {
                m_theCharacterFXDataResource.dispose();
                m_theCharacterFXDataResource = null;
            }
            m_theCharacterFXDataRef = null;
            m_sCurrentAnimationFXName = null;
            m_fnFXDataLoadFinished = null;
            m_vPreloadActions = null;

            //hit effect
            if ( null != m_theHitEffectDataResource )
            {
                m_theHitEffectDataResource.dispose();
                m_theHitEffectDataResource = null;
            }
            m_theHitEffectDataRef = null;
            m_fnHitEffectLoadFinished = null;

            //clean combine effect
            for each ( var pFXList : Vector.<CFX> in m_mapComHitEffects )
            {
                pFXList.fixed = false;
                pFXList.length = 0;
                pFXList.fixed = true;
            }
            m_mapComHitEffects.clear();
            m_theComHitEffectDataRef = null;
            m_fnComHitEffectLoadFinished = null;

            //clean buff effect
            for each ( pFXList in m_mapBuffEffects )
            {
                pFXList.fixed = false;
                pFXList.length = 0;
                pFXList.fixed = true;
            }
            m_mapBuffEffects.clear();
            m_theBuffEffectDataRef = null;
            m_fnBuffEffectLoadFinished = null;

            // collision
            if( null != m_theCollisionDataResource )
            {
                m_theCollisionDataResource.dispose();
                m_theCollisionDataResource = null;
            }
            m_theCollisionDataRef = null;
            m_fnLoadCollisionFinished = null;

            // audio
            if( null != m_theAudioDataResource )
            {
                m_theAudioDataResource.dispose();
                m_theAudioDataResource = null;
            }
            m_theAudioDataRef = null;
            m_fnLoadAudioFinished = null;

            if( m_theCharacterObject != null )
            {
                m_theCharacterObject.removeOnAnimationChangedCallback( _onAnimationChanged );
                m_theCharacterObject.animationController = null;
                m_theCharacterObject.dispose();
                if( bCreateCharacterObject ) m_theCharacterObject = new CCharacterObject( m_theBelongFramework.renderer, m_theAnimationController );
                else m_theCharacterObject = null;
            }

            if( m_theCollisionObj )
            {
                m_theCollisionObj.setCollisionData( null );
            }

            // packed文件必须在collision、audio等数据dispose之后
            if( null != m_thePackedDataResource )
            {
                m_thePackedDataResource.dispose();
                m_thePackedDataResource = null;
            }
            m_fnLoadExtFinished = null;
        }

        // try getting all used resources
        public override function retrieveAllResources( vResources : Vector.<CResource> = null, iBeginIndex : int = 0 ) : int
        {
            var iCount : int = 0;
            if( m_theCharacterObject != null)
            {
                iCount += m_theCharacterObject.retrieveAllResources(vResources, iBeginIndex + iCount );
            }
            if( m_theCollisionDataResource != null)
            {
                if(vResources != null)
                    vResources[ iBeginIndex + iCount ] = m_theCollisionDataResource;
                iCount++;
            }
            if( m_theAudioDataResource != null)
            {
                if(vResources != null)
                    vResources[ iBeginIndex + iCount ] = m_theAudioDataResource;
                iCount++;
            }
            if( m_theCharacterFXDataResource != null)
            {
                if(vResources != null)
                    vResources[ iBeginIndex + iCount ] = m_theCharacterFXDataResource;
                iCount++;
            }
            if( m_theHitEffectDataResource != null)
            {
                if(vResources != null)
                    vResources[ iBeginIndex + iCount ] = m_theHitEffectDataResource;
                iCount++;
            }
            return iCount;
        }

        [Inline]
        final public function get filename() : String
        {
            return m_sFilename;
        }
        [Inline]
        final public function set fxBasedOnScreenLimit ( value : Boolean ) : void
        {
            m_bFXBasedOnScreenLimit = value;
        }
        [Inline]
        final public function get arrResURL () : Array { return m_arrResURL; }

        //
        // loading functions
        // callback: function onLoadFinished( theCharacter : CCharacter, iResult : int ) : void
        // callback: function onLoadCollisionFinish( theCharacter : CCharacter, iResult : int ) : void
        // callback: function onLoadAnimFXFinish( theCharacter : CCharacter, iResult : int ) : void
        // callback: function onLoadAudioFinish( theCharacter : CCharacter, iResult : int ) : void
        //
        public function loadFile( sFilename : String, sSkinUrl : String = null, theEquipSkinsInfo : CEquipSkinsInfo = null,
                                    iLoadingPriority : int = ELoadingPriority.NORMAL,
                                    onLoadFinished : Function = null, onLoadCollisionFinish : Function = null,
                                    onLoadAnimFXFinish : Function = null, onLoadAudioFinish : Function = null,
                                    bFxPreload : Boolean = true, bAudioPreload : Boolean = true, vPreloadActions : Vector.<String> = null ) : void
        {
            loadCharacterFile( sFilename, sSkinUrl, theEquipSkinsInfo, iLoadingPriority, onLoadFinished );
            loadCharacterGameFile( sFilename, iLoadingPriority, onLoadCollisionFinish, onLoadAnimFXFinish , onLoadAudioFinish ,bFxPreload, bAudioPreload, vPreloadActions );
        }

        //
        // callback: function onLoadFinished( theCharacter : CCharacter, iResult : int ) : void
        //
        public function loadCharacterFile( sFilename : String , sSkinUrl : String = null, theEquipSkinsInfo : CEquipSkinsInfo = null,
                                             iLoadingPriority : int = ELoadingPriority.NORMAL, onLoadFinished: Function = null ) : void
        {
            if( m_theCharacterObject.spineLoader != null )
            {
                _resetCharacterObject();
            }

            m_iLoadingPriority = iLoadingPriority;
            m_fnLoadCharacterFinished = onLoadFinished;
            m_bLoadCharacterFinishedCalled = false;
            m_sFilename = sFilename;
            m_theCharacterObject.loadFile( sFilename, sSkinUrl, theEquipSkinsInfo, iLoadingPriority, _onLoadCharacterFinished, m_arrResURL );
        }

        //
        // loading functions
        // callback: function onLoadCollisionFinish( theCharacter : CCharacter, iResult : int ) : void
        // callback: function onLoadAnimFXFinish( theCharacter : CCharacter, iResult : int ) : void
        // callback: function onLoadAudioFinish( theCharacter : CCharacter, iResult : int ) : void
        //
        public function loadCharacterGameFile( sFilename : String, iLoadingPriority : int = ELoadingPriority.NORMAL,
                                                 onLoadCollisionFinish : Function = null, onLoadAnimFXFinish : Function = null, onLoadAudioFinish : Function = null,
                                                 bFxPreload : Boolean = true, bAudioPreload : Boolean = true, vPreloadActions : Vector.<String> = null ) : void
        {
            m_iLoadingPriority = iLoadingPriority;
            m_bFXPreload = CFramework.StatisticsResourceOn? true:bFxPreload;
            m_bAudioPreload = CFramework.StatisticsResourceOn? true:bAudioPreload;
            m_vPreloadActions = CFramework.StatisticsResourceOn? null:vPreloadActions; // bPreload 为 true, vPreloadActions 为 null 或者 length 为 0 时表示全部预加载

            var sFile : String = CPath.driverDirName( sFilename ) ;

            function loadCharacterPackedFile() : void
            {
                // collision
                var sCollisionFile : String = sFile + "_collision.json";
                loadCollisionFile( sCollisionFile, onLoadCollisionFinish );

                // effects
                var sFXAttachFile:String = sFile + "_animfx.json";
                loadCharacterFXFile( sFXAttachFile, onLoadAnimFXFinish );

                // audio
                var sAudioFile : String = sFile + "_audio.json";
                loadAudioFile( sAudioFile, onLoadAudioFinish );

                //hit effect
                var sHitEffectFile : String = sFile + "_he.json";
                loadHitEffectFile( sHitEffectFile, null );
            }
            if(CPackedQsonLoader.enablePackedQsonLoading == true)
            {
                loadPackedDataFile(sFile, loadCharacterPackedFile);

            }else
            {
                loadCharacterPackedFile();
            }

            //combine hit effects
            if( m_theBelongFramework.combineEffectDataResource == null && !m_sCombineEffectIsLoading )
            {
                m_sCombineEffectIsLoading = true;
                var sComHitEffectFile : String= "assets/character/combined_effect_model/combined_effect_model_he.json";
                loadCombineOrBuffEffectFile( sComHitEffectFile );
            }
            else if ( m_theBelongFramework.combineEffectDataResource != null )
            {
                m_theComHitEffectDataRef = m_theBelongFramework.combineEffectDataResource.theObject as CCharacterFXData;
                m_theComHitEffectDataRef.dataLinked;
            }

            //buff effects
            if( m_theBelongFramework.buffEffectDataResource == null && !m_sBuffEffectIsLoading )
            {
                m_sBuffEffectIsLoading = true;
                var sBuffEffectFile : String= "assets/character/buff_effect_model/buff_effect_model_he.json";
                loadCombineOrBuffEffectFile( sBuffEffectFile, CCharacterFXKey.BUFF_FX );
            }
            else if ( m_theBelongFramework.buffEffectDataResource != null )
            {
                m_theBuffEffectDataRef = m_theBelongFramework.buffEffectDataResource.theObject as CCharacterFXData;
                m_theBuffEffectDataRef.dataLinked;
            }
        }

        //
        // callback: function onLoadExtFinish(theCharacter : CCharacter, iResult : int) : void
        //
        public function loadPackedDataFile( sFile : String, onLoadExtFinish : Function = null) : void
        {
            m_fnLoadExtFinished = onLoadExtFinish;
            var vPackedFile : Vector.<String> = new Vector.<String>(2);
            vPackedFile[0] = sFile + "_packed.qson";
            vPackedFile[1]=  sFile + "_packed.json";
            CResourceLoaders.instance().startLoadFileFromPathSequence(vPackedFile, _onLoadExtFinished, CPackedQsonLoader.NAME, ELoadingPriority.NORMAL, true);
        }

        //
        // callback: function onLoadCollisionFinish( theCharacter : CCharacter, iResult : int ) : void
        //
        public function loadCollisionFile( sFilename : String , onLoadCollisionFinished: Function = null ) : void
        {
            m_fnLoadCollisionFinished = onLoadCollisionFinished;
            CResourceLoaders.instance().startLoadFile( sFilename, _onLoadCollisionFinished, CJsonLoader.NAME, m_iLoadingPriority, true );
        }

        public function loadAudioFile(sFilename : String, onLoadAudioFinished : Function = null) : void
        {
            m_fnLoadAudioFinished = onLoadAudioFinished;
            CResourceLoaders.instance().startLoadFile( sFilename, _onLoadAudioFinished, CJsonLoader.NAME, m_iLoadingPriority, true );
        }
        public function loadCharacterFXFile( sFilename : String, onLoadFXDataFinished : Function = null ) : void
        {
            m_fnFXDataLoadFinished = onLoadFXDataFinished;
            CResourceLoaders.instance().startLoadFile( sFilename, _onLoadCharacterFXFinished, CJsonLoader.NAME, m_iLoadingPriority, true );
        }

        public function loadHitEffectFile ( sFilename : String, onLoadHitEffectFinished : Function = null ) : void
        {
            CResourceLoaders.instance().startLoadFile( sFilename, _onLoadHitEffectFinished, CJsonLoader.NAME, m_iLoadingPriority, true );
        }

        public function loadCombineOrBuffEffectFile ( sFilename : String, type : String = "combine" /*COMBINE_FX OR BUFF_FX*/, onLoadComHitEffectFinished : Function = null ) : void
        {
            if ( type == CCharacterFXKey.COMBINE_FX )
                CResourceLoaders.instance().startLoadFile( sFilename, _onLoadCombineEffectFinished, CCharacterFXDataLoader.NAME, m_iLoadingPriority, true );
            else if ( type == CCharacterFXKey.BUFF_FX )
                CResourceLoaders.instance().startLoadFile( sFilename, _onLoadBuffEffectFinished, CCharacterFXDataLoader.NAME, m_iLoadingPriority, true );
        }

        public function get velocityPerSec() : CVector3{
            return m_vVelocityPerSec;
        }

        // animation controller
        public function get animationController() : CAnimationController
        {
            return m_theAnimationController;
        }
        public function set animationController( controller : CAnimationController ) : void
        {
            if( m_theAnimationController == controller ) return;

            if( m_theAnimationController ) {
                m_theAnimationController._setCharacter( null );
                m_theAnimationController.removeStateChangedCallback( _onStateChanged );
            }
            m_theAnimationController = controller;

            if ( m_theAnimationController ) {
                m_theAnimationController._setCharacter( this );
                m_theAnimationController.addStateChangedCallback( _onStateChanged );
            }

            m_theCharacterObject.animationController = controller;
        }

        //
        public function playState( sStateName : String, bForceLoop : Boolean = false, bForceReplay : Boolean = false, iTrackIdx : int = 0 ) : void
        {
            m_theCharacterObject.playState( sStateName, bForceLoop, bForceReplay, iTrackIdx );
        }

        //
        // callback: function _onAnimationFinished( theCharacter : CCharacter ) : void
        //
        public function playAnimation( sClipName : String, bLoop : Boolean, bForceReplay : Boolean = false,
                                         bExtractAnimationOffset : Boolean = false, iTrackIdx : int = 0, bRandomStart : Boolean = false,
                                         fLoopTime : Number = 0.0, fnOnAnimationFinished : Function = null ) : Boolean
        {
            var result : Boolean = m_theCharacterObject.playAnimation( sClipName, bLoop, bForceReplay, bExtractAnimationOffset, iTrackIdx, bRandomStart, fLoopTime, fnOnAnimationFinished );
            this._fxStopedWhenAnimationChanged ();
            this._playAnimationFXs();
            return result;
        }

        //
        // callback: function _onAnimationFinished( theCharacter : CCharacter ) : void
        //
        public function addNextPlayAnimation( sClipName : String, bLoop : Boolean, bForceReplay : Boolean = false,
                                                bExtractAnimationOffset : Boolean = false, iTrackIdx : int = 0, bRandomStart : Boolean = false,
                                                fLoopTime : Number = 0.0, fnOnAnimationFinished : Function = null, bAutoFinishPreviousAnimation : Boolean = true ) : void
        {
            if( m_vNextPlayAnimations == null ) m_vNextPlayAnimations = new Vector.<_CNextPlayAnimationInfo>();

            m_vNextPlayAnimations.push( new _CNextPlayAnimationInfo( this, sClipName, bLoop, bForceReplay,
                                                                     bExtractAnimationOffset, iTrackIdx, bRandomStart,
                                                                     fLoopTime, fnOnAnimationFinished, bAutoFinishPreviousAnimation ) );
        }

        public function loadSkin(skinName : String) : void
        {
            if (skinName == null)
                return ;
            m_theCharacterObject.loadSkin(skinName, m_theCharacterObject.characterInfo.equipSkinsInfo);
        }
        public function loadEquipSkin(equipIndex : int, equipName  : String) : void
        {
            if (equipIndex < 0 || equipName == null)
                return;
            m_theCharacterObject.loadEquipSkin(equipIndex, equipName);
        }
        public function loadSkinByAtlas(atlasName : String) : void
        {
            m_theCharacterObject.loadSkinByAtlas(atlasName);
        }
        [Inline]
        final public function get numAnimationClipInfos() : int
        {
            return m_theCharacterObject.numAnimationClipInfos;
        }
        [Inline]
        final public function retrieveAllAnimationClipNames( vAnimationNames : Vector.<String> ) : void
        {
            m_theCharacterObject.retrieveAllAnimationClipNames( vAnimationNames );
        }

        //
        //
        [Inline]
        final public function get currentAnimationClip() : CAnimationClip
        {
            return m_theCharacterObject.currentAnimationClip;
        }
        [Inline]
        final public function get currentAnimationClipTime() : Number
        {
            return m_theCharacterObject.getCurrentAnimationClipTime( 0 );
        }
        [Inline]
        final public function get currentAnimationClipTotalTime() : Number
        {
            return m_theCharacterObject.getCurrentAnimationTotalTime( 0 );
        }
        [Inline]
        final public function get currentAnimationClipDuration() : Number
        {
            return m_theCharacterObject.getCurrentAnimationClipDuration( 0 );
        }
        [Inline]
        final public function get currentAnimationClipTimeLeft() : Number
        {
            return m_theCharacterObject.getCurrentAnimationClipTimeLeft( 0 );
        }
        [Inline]
        final public function getAnimationClipDurationByName( sClipName : String ) : Number
        {
            return m_theCharacterObject.getAnimationClipDurationByName( sClipName );
        }
        [Inline]
        final public function getStateDuration( sStateName : String ) : Number
        {
            return m_theCharacterObject.getStateDuration( sStateName );
        }

        [Inline]
        final public function findAnimationClipInfo( sClipName : String ) : CAnimationClipInfo
        {
            return m_theCharacterObject.findAnimationClipInfo( sClipName );
        }
        [Inline]
        final public function findBoneIndex( sBoneName : String ) : int
        {
            return m_theCharacterObject.findBoneIndex( sBoneName );
        }
        [Inline]
        final public function retrieveBonePosition( iIndex : int, vBonePos : CVector2, bLocal : Boolean, bAddOn : Boolean ) : Boolean
        {
            return m_theCharacterObject.retrieveBonePosition( iIndex, vBonePos, bLocal, bAddOn );
        }
        [Inline]
        final public function setRootBonePosition( vBonePos : CVector2, bAddOn : Boolean = false, bUpdateTransform : Boolean = true ) : void
        {
            return m_theCharacterObject.setRootBonePosition(vBonePos, bAddOn, bUpdateTransform);
        }
        [Inline]
        final public function retrieveBoneRotation( iIndex : int ):Number
        {
            return m_theCharacterObject.retrieveBoneRotation( iIndex );
        }

        [Inline]
        final public function getAnimationOffset( iTrackIdx : int = -1, clear : Boolean = false ) : CVector2 // -1 means add on all entry's animation offset
        {
            return m_theCharacterObject.getAnimationOffset( iTrackIdx, clear );
        }
        [Inline]
        final public function getAnimationOffsetPerSec( iTrackIdx : int = -1 ) : CVector2 // -1 means add on all entry's animation offset
        {
            return m_theCharacterObject.getAnimationOffsetPerSec( iTrackIdx );
        }

        //
        public function getBound( sAnimationClipName : String, bExtractAnimationOffset : Boolean ) : CAABBox2
        {
            return m_theCharacterObject.getBound( sAnimationClipName, bExtractAnimationOffset );
        }

        // animation / update speed
        [Inline]
        final public function get animationSpeed() : Number
        {
            return m_fAnimationSpeed;
        }
        [Inline]
        final public function set animationSpeed( fSpeed : Number ) : void
        {
             m_fAnimationSpeed = fSpeed;
        }

        [Inline]
        final public function get stageChangedSpeed () : Number
        {
            return m_fStateChangedSpeed;
        }

        // collision functions
        [Inline]
        final public function get currentAnimationTag() : String
        {
            return m_sCurrentAnimationTag;
        }
        [Inline]
        final public function get currentAnimationTagParam() : String
        {
            return m_sCurrentAnimationTagParam;
        }

        [Inline]
        final public function setCurrentAnimationTag( sAnimationTag : String, sAnimationTagParam : String ) : void
        {
            if( sAnimationTag == null || sAnimationTag.length == 0) {
                m_sCurrentAnimationTag = STRING_DEFAULT;
                m_sCurrentAnimationTagParam = "";
                return;
            }

            if( m_sCurrentAnimationTag != sAnimationTag)// || sAnimationTagParam != m_sCurrentAnimationTagParam)
            {
                m_readyChangeTag = true;
            }

            m_sCurrentAnimationTagParam = sAnimationTagParam;
            m_sCurrentAnimationTag = sAnimationTag;

        }

        [Inline]
        final public function get collisionData() : CCharacterCollisionAssemblyData
        {
            return m_theCollisionDataRef;
        }
        public function get currentCollisionData() : Vector.<CCharacterCollisionKey>
        {
            var animtionClip : CAnimationClip = m_theCharacterObject.currentAnimationClip;
            var collisionKeyRet : Vector.<CCharacterCollisionKey>

            if( null != animtionClip && m_theCollisionDataRef != null ) {

                if( currentAnimationTag == STRING_DEFAULT) {
                    collisionKeyRet = m_theCollisionDataRef.getTimeLineKeysByName( animtionClip.m_sName , currentAnimationClip.m_sName)
                    //子弹的。。
                    if( collisionKeyRet == null ) {
                        collisionKeyRet = m_theCollisionDataRef.getTimeLineKeysByName( animtionClip.m_sName, STRING_DEFAULT );
                    }
                }else
                    collisionKeyRet = m_theCollisionDataRef.getSkillTimeLineKeysByName( animtionClip.m_sName, currentAnimationTag );
            }
           return collisionKeyRet;
        }

        public function get blockCollisionData() : Vector.<CCharacterCollisionKey>
        {
            return m_theCollisionDataRef.getSkillTimeLineKeysByName( "Idle_1" , "Idle_1" );
        }

        final public function get currentCollisionDurationTime() : Number
        {
            var animationClip : CAnimationClip = m_theCharacterObject.currentAnimationClip;
            if( null != animationClip && m_theCollisionDataRef != null)
            {
                var dTime : Number = animationClip.m_fDuration;
                if( dTime  >  0.0) return dTime;

                return m_theCollisionDataRef.getDurationTime( animationClip.m_sName );
            }
            return 0;
        }

        final public function getCollisionDurationTimeByName( animationStr : String ) : Number
        {
            if( !animationStr || !animationStr.length )
                    return 0.0;
            return m_theCollisionDataRef.getDurationTime( animationStr );
        }

        public function get audioData() : CCharacterAudioData
        {
            return m_theAudioDataRef;
        }

        public function get currentAudioData() : Vector.<CCharacterAudioKey>
        {
            var animationClip : CAnimationClip = this.currentAnimationClip;
            if( animationClip != null && m_theAudioDataRef != null )return m_theAudioDataRef.getAudioKeysByNameAndSkillId( animationClip.m_sName, this.m_sCurrentAnimationTag );
            else return null;
        }

        [Inline]
        final public function set alignToFramePerSec( fFPS : Number ) : void
        {
            if( fFPS <= 0.0 ) m_fAlignToFrameInterval = 0.0;
            else m_fAlignToFrameInterval = 1.0 / fFPS;
        }
        [Inline]
        final public function get alignToFramePerSec() : Number
        {
            if( m_fAlignToFrameInterval <= 0.0 ) return 0.0;
            return 1.0 / m_fAlignToFrameInterval;
        }

        public override function set opaque( fOpaque : Number ) : void
        {
            super.opaque = fOpaque;
            m_theCharacterObject.opaque = fOpaque * m_fInnerOpaque;
        }

        public override function set innerOpaque( fInnerOpaque : Number ) : void
        {
            super.innerOpaque = fInnerOpaque;
            m_theCharacterObject.opaque = fInnerOpaque * m_fOpaque;
        }

        public override function set visible( bVisible : Boolean ) : void
        {
            setVisible( bVisible, true );
        }
        public function setVisible( bVisible : Boolean, bCheck : Boolean ) : void
        {
            if( bCheck && m_bVisible == bVisible ) return ;

            var bVisibleApplied : Boolean = bVisible && m_bEnabled;
            m_theCharacterObject.visible = bVisibleApplied;
            if( m_theShadowObject != null ) m_theShadowObject.visible = bVisibleApplied;

            if( m_setPlayingFXs.length > 0 )
            {
                for each( var fx : CFX in m_setPlayingFXs )
                {
                    if ( fx == null || fx.disposed )
                    {
                        Foundation.Log.logErrorMsg ( "There were something error in character playing fx set!" );
                        continue;
                    }
                    fx.visible = bVisibleApplied;
                }
            }

            super.visible = bVisible;
        }

        public override function set enabled( bEnable : Boolean ) : void
        {
            if( m_bEnabled == bEnable ) return ;

            super.enabled = bEnable;
            if( m_setPlayingFXs.length > 0 )
            {
                for each( var fx : CFX in m_setPlayingFXs )
                {
                    if ( fx == null )
                    {
                        Foundation.Log.logErrorMsg ( "There were something error in character playing fx set!" );
                        continue;
                    }
                    fx.enabled = bEnable;
                }
            }

            setVisible( m_bVisible, false );
        }

        /**
         * IFXModify interface
         * @param r
         * @param g
         * @param b
         * @param alpha
         * @param masking
         */
        override public function setColor( r : Number, g : Number, b : Number, alpha : Number = 1.0, masking : Boolean = false ) : void
        {
            if ( m_theCharacterObject != null ) m_theCharacterObject.setColor( r, g, b, alpha, masking );
            else Foundation.Log.logWarningMsg( " The character has been disposed! FX still running? " );
        }
        override public function resetColor () : void
        {
            if ( m_theCharacterObject != null ) m_theCharacterObject.resetColor ();
        }
        [Inline] override public function get material () : IMaterial
        {
            if ( m_theCharacterObject != null ) return m_theCharacterObject.material;
            return null;
        }

        override public function set castShadow( bCast : Boolean ) : void
        {
            super.castShadow = bCast;

            if( bCast && m_theBelongFramework.shadowMode == 1 )
            {
                _setShadowImage( m_theBelongFramework.shadowCircleFilename, m_theBelongFramework.shadowCircleScaleFactor );
            }
            else
            {
                _setShadowImage( null );
            }
        }

        override public function setParent( theParentNode : CNode, bResetLocalTransform : Boolean = true, eParentMode : int = EParentMode.PARENT_NORMAL ) : void
        {
            if( this.parent == theParentNode && this.parentMode == eParentMode ) return ;
            super.setParent( theParentNode, bResetLocalTransform, eParentMode );

            if( m_theShadowObject != null )
            {
                var theParentSceneLayer : CBaseObject = m_theCharacterObject.findParentByType( CSceneLayer );
                if( theParentSceneLayer != null ) m_theShadowObject.setParent( theParentSceneLayer );
            }
        }

        //
        [inline] override public function get theObject() : CBaseObject { return m_theCharacterObject; }
        [Inline] final public function get characterObject() : CCharacterObject { return m_theCharacterObject; }

        /**
         * the update function
         * @param fDeltaTime
         */
        public override function update( fDeltaTime : Number ) : void
        {
            // check animation offset flag
            var fCollisionRealDelta : Number = fDeltaTime;
            var bApplyAnimationOffsetToPosition : Boolean = false;
            if( m_theAnimationController != null && animationController.theCurrentState.applyAnimationOffsetToPosition )
            {
                bApplyAnimationOffsetToPosition = true;

                var bEnablePhysics : Boolean = m_bEnablePhysics;
                m_bEnablePhysics = false;
                super.update( fDeltaTime );
                m_bEnablePhysics = bEnablePhysics;
            }
            else super.update( fDeltaTime );

            // realign fDeltaTime if m_fAlignToFrameInterval != 0.0
            if( m_fAlignToFrameInterval > 0.0 )
            {
                var fCurrentTime : Number = this.currentAnimationClipTime;
                var fTotalTime : Number = fCurrentTime + m_fUpdateTimeRemains + fDeltaTime;
                m_fUpdateTimeRemains = fTotalTime % m_fAlignToFrameInterval;
                var fAlignedTime : Number = fTotalTime - m_fUpdateTimeRemains;
                fDeltaTime = fAlignedTime - fCurrentTime;
                if( fDeltaTime < CMath.EPSILON )
                {
                    updateMatrix();
                    return;
                }
            }

            var bDoAnimation : Boolean = true;
            if( m_bEnableViewingCheckAnimation && m_bInViewRange == false ) bDoAnimation = false;

            if( m_theCharacterObject.isLoaded && bDoAnimation )
            {
                var fAnimationDeltaTime : Number = fDeltaTime * m_fAnimationSpeed;

                // adjust animation speed according to the animation offset
                if( m_theAnimationController != null && animationController.theCurrentState.applyAnimationOffsetToAnimationSpeed && m_fAlignToFrameInterval == 0.0 )
                {
                    // calculate the ratio of velocity and the animation offset
                    var fAnimationOffsetLength : Number = m_theCharacterObject.getAnimationOffsetPerSec().length();
                    var fVelocityLength : Number = m_vVelocityPerSec.length();
                    if( fAnimationOffsetLength > CMath.EPSILON && fVelocityLength > CMath.EPSILON )
                    {
                        var fSpeedRatio : Number = fVelocityLength / fAnimationOffsetLength;
                        fAnimationDeltaTime *= fSpeedRatio;
                    }
                }

                m_theCharacterObject.update( fAnimationDeltaTime );

                if( bApplyAnimationOffsetToPosition )
                {
                    var vOffset : CVector2 = m_theCharacterObject.getAnimationOffset();
                    if( vOffset.isZero() == false )
                    {
                        var bTerrain : Boolean = false;
                        if( CMath.abs( vOffset.y ) < CMath.EPSILON ) bTerrain = true;

                        if(  move( vOffset.x, vOffset.y, 0.0, true, bTerrain ) == false )
                        {
                            move( 0.0, vOffset.y, 0.0, true, bTerrain ); // remove X/Z volume just in case the character run into a wall in applying animation offset state
                        }
                    }
                }

                if( m_vNextPlayAnimations != null && m_vNextPlayAnimations.length > 0 ) _tackleNextPlayAnimation();

                if( this.isShaking ) m_theCharacterObject.setRootBonePosition( m_vShakeOffset );

                // animation fx update
                if( this.animationController != null )
                {
                    _animationFXUpdate();
                    _animationAudioUpdate( fDeltaTime );
                }

                if( m_theCollisionDataRef != null &&  m_theCollisionObj != null )
                    _updateCollision( fCollisionRealDelta * updateSpeed );
                //test
//                if( m_sFilename.indexOf("banqiliang") >= 0 && currentAnimationClip.m_sName != "Idle_1")
//                        Foundation.Log.logMsg("班启辽uodate时间" + fCollisionRealDelta + " updateSpeed" + updateSpeed );

            }

            updateMatrix();

        }

        private function _updateCollision( delta : Number ) : void
        {
            if( currentAnimationClip == null ) return;
            if( m_sCurrentAnimationTag == STRING_DEFAULT)
            {
                var currentLoopTimes : int;
                var boTickAnyway : Boolean ;
                currentLoopTimes = currentAnimationClip.m_nCurrentLoopTimes;

                {
                    if ( m_theCollisionDataRef && currentAnimationClip && currentAnimationClipDuration == 0.0 ) {
                        var animationDurationTime : Number = m_theCollisionDataRef.getDurationTime( currentAnimationClip.m_sName );
                        currentLoopTimes = int( currentAnimationClip.m_fTotalTime / animationDurationTime );
                        boTickAnyway = true;
                    }
                }

                if( currentAnimationClip && m_nCollisionLoop != currentLoopTimes ) {
                    _setCollisionChange();
                    m_nCollisionLoop = currentLoopTimes;
                }

                if( currentAnimationClipTimeLeft != 0 || boTickAnyway )
                        m_theCollisionObj.update( delta );
            }else{
                m_theCollisionObj.update( delta );
            }

        }

        public override function updateMatrix( bCheckDirty : Boolean = true ) : void
        {
            super.updateMatrix( bCheckDirty );

            if( _checkDirtyFlags( EDirtyFlag.MX_FLAG_UPDATED ) || bCheckDirty == false )
            {
                _unsetDirtyFlags( EDirtyFlag.MX_FLAG_UPDATED );

                // set matrix to character object
                var vPosition : CVector3 = this.position;
                m_theCharacterObject.setPosition3D( vPosition.x, vPosition.y, vPosition.z );

                // set 2D position again due to the customized depth value,
                if( this.depth2D != 0.0 ) m_theCharacterObject.setPosition( m_theCharacterObject.x, m_theCharacterObject.y, this.depth2D );

                m_theCharacterObject.setRotation( CMath.degToRad( this.localRotation.z ) );

                var vScale : CVector3 = this.scale;
                m_theCharacterObject.setScale( vScale.x, vScale.y );

                m_theCharacterObject.flipX = this.flipX;
                m_theCharacterObject.flipY = this.flipY;

                if( this.isStatic == false )
                {
                    var lightData : CLightData = this.getTerrainLight( vPosition.x, vPosition.z );
                    if( lightData != null )
                    {
                        m_theCharacterObject.setLightColorAndContrast( lightData.m_aColorInfo[ 1 ], lightData.m_aColorInfo[ 2 ], lightData.m_aColorInfo[ 3 ], lightData.m_aColorInfo[ 0 ], lightData.m_aColorInfo[ 4 ] );
                    }
                    else
                    {
                        m_theCharacterObject.setLightColorAndContrast( 1.0, 1.0, 1.0, 1.0, 0.0 );
                    }
                }

                if( m_theShadowObject != null && m_theShadowObject.currentBound != null )
                {
                    var fDis : Number = CMath.abs( vPosition.y - m_fTerrainHeight );
                    var fMaxDis : Number = CMath.abs( m_fCharacterGravityAcc ) * 0.2;   // CMath.abs( GRAVITY_ACC ) * 0.2;
                    var fScaleRatio : Number = ( fMaxDis - fDis ) / fMaxDis;
                    if( fScaleRatio > 1.0 ) fScaleRatio = 1.0;
                    else if( fScaleRatio < 0.4 ) fScaleRatio = 0.4;

                    var fScaleRatioX : Number = fScaleRatio;
                    var fScaleRatioY : Number = fScaleRatio;
                    var theShadowAABB : CAABBox2 = m_theShadowObject.currentBound;

                    if( m_fShadowBoundWidth < 0.0 ) _calculateShadowBoundWidth( 0.1 );
                    fScaleRatioX *= m_fShadowBoundWidth / theShadowAABB.extX;
                    fScaleRatioY *= m_fShadowBoundWidth / theShadowAABB.extX;

					var finalScale : CVector3 = new CVector3(vScale.x * fScaleRatioX * m_fShadowObjectScaleFactor, vScale.y * fScaleRatioY * m_fShadowObjectScaleFactor);
					
                    m_theShadowObject.setPosition3D( vPosition.x, m_fTerrainHeight, vPosition.z );

                    // set 2D position again due to the customized depth value,
					m_theShadowObject.setPosition( m_theShadowObject.x - theShadowAABB.extX * finalScale.x ,
						m_theShadowObject.y - theShadowAABB.extY * finalScale.y , -1000.0 );

                    m_theShadowObject.setScale( finalScale.x, finalScale.y );
                }
            }
        }

        public function setGravityAcceleration( acc : Number ) : void
        {
            if( acc == m_fCharacterGravityAcc )
                    return;
            _setGravityAcc( acc );
        }

        public function resumeGravityAcceleration() : void
        {
            _setGravityAcc( GRAVITY_ACC );
        }

        //play hit effect
        public function playHitEffects ( hitName : String, position : CVector3, depth : Number  = 0.0 ) : void
        {
            if ( m_theHitEffectDataRef != null && m_theHitEffectDataRef.dataLinked )
            {
                var fxKeys : Vector.<CCharacterFXKey> = m_theHitEffectDataRef.getValueByName( hitName, STRING_DEFAULT );
                if( null == fxKeys || fxKeys.length <= 0 ) { return; }

                var fxKey : CCharacterFXKey = null;
                var flip : int = this.flipX ? -1 : 1;
                var scale : CVector3 = null;
                for ( var i : int = 0, n : int = fxKeys.length; i < n; i++ )
                {
                    fxKey = fxKeys[ i ];
                    var fx : CFX = _createFX( fxKey );
                    fx.setAutoRecycle( true );
                    fx.theObject.setParent(this.theObject.parent);
                    fx.play ( false, fxKey.playTime, fxKey.keyTime, fxKey.keyTime, 1.0 );

                    fx.setLocalRotation ( 0, 0, fxKey.localRotation.z * -flip );

                    scale = this.characterObject.scale;
                    fx.setScale( fxKey.localScale.x * Math.abs( scale.x ), fxKey.localScale.y * scale.y, 1.0 );
                    fx.flipX = this.flipX;

                    fx.setPosition( position.x + fxKey.localPosition.x * flip,
                            position.y + fxKey.localPosition.y,
                            position.z );
                    fx.extraDepth = fxKey.localPosition.z + depth;
                }
            }
            else
            {
//                Foundation.Log.logWarningMsg( "Please check that whether the hit effect exsit? if it exsit, call the programer!" )
            }
        }

        //play combine hit effect or buff effects
        public function playCombineOrBuffEffects ( name : String, type : String = "combine" /*COMBINE_FX*/, loop : Boolean = false ) : void
        {
            if ( type == CCharacterFXKey.NORMAL_FX ) return;

            var pEffectDataRef : CCharacterFXData = null;
            var pEffectsMap : CMap = null;
            if ( type == CCharacterFXKey.COMBINE_FX )
            {
                if ( m_theBelongFramework.combineEffectDataResource == null ) return;
                m_theComHitEffectDataRef = m_theBelongFramework.combineEffectDataResource.theObject as CCharacterFXData;
                pEffectDataRef = m_theComHitEffectDataRef;
                pEffectsMap = m_mapComHitEffects;
            }
            if ( type == CCharacterFXKey.BUFF_FX )
            {
                if ( m_theBelongFramework.buffEffectDataResource == null ) return;
                m_theBuffEffectDataRef = m_theBelongFramework.buffEffectDataResource.theObject as CCharacterFXData;
                pEffectDataRef = m_theBuffEffectDataRef;
                pEffectsMap = m_mapBuffEffects;
            }

            if ( pEffectDataRef != null && pEffectDataRef.dataLinked )
            {
                stopCombineOrBuffEffect ( name, type );

                var pFXList : Vector.<CFX> = pEffectsMap.find( name );
                if ( pFXList == null )
                {
                    pFXList = new Vector.<CFX>();
                    pEffectsMap.add( name, pFXList );
                }

                var pFxKeys : Vector.<CCharacterFXKey> = pEffectDataRef.getValueByName( name, STRING_DEFAULT );
                if( null == pFxKeys || pFxKeys.length <= 0 ) return;

                var pFxKey : CCharacterFXKey = null;
                pFXList.fixed = false;
                for ( var i : int = 0, n : int = pFxKeys.length; i < n; i++ )
                {
                    pFxKey = pFxKeys[ i ];
                    pFxKey.fxType = type;
                    pFxKey.buffName = name;
                    pFxKey.boneIndex = m_theCharacterObject.findBoneIndex( pFxKey.boneName );
                    var pFX : CFX = _createFX ( pFxKey );
                    pFX.attachToCharacter( this, pFxKey );
                    pFX.onStopedCallBack = _removeCombineOrBuffEffect;
                    m_setPlayingFXs.add( pFX );
                    pFX.play ( loop, pFxKey.playTime, pFxKey.keyTime, pFxKey.keyTime, 1.0 );

                    pFXList.length += 1;
                    pFXList[ i ] = pFX;
                }
                pFXList.fixed = true;
            }
            else
            {
                Foundation.Log.logWarningMsg( "Please check that whether the combine hit effect exsit? if it exsit, call the programer!" );
            }
        }

        public function stopCombineOrBuffEffect ( name : String, type : String = "combine" /*COMBINE_FX*/ ) : void
        {
            var effectsMap : CMap = ( type == CCharacterFXKey.COMBINE_FX ) ? m_mapComHitEffects : m_mapBuffEffects;
            if ( effectsMap == null ) return;

            var pFXList : Vector.<CFX> = effectsMap.find( name );
            if ( pFXList != null && pFXList.length != 0 )
            {
                for each ( var pFX : CFX in pFXList )
                {
                    if ( pFX == null ) continue;
                    pFX.stop();
                    m_setPlayingFXs.remove( pFX );
                    _recycleAnimationFX( pFX );
                }
                pFXList.fixed = false;
                pFXList.length = 0;
                pFXList.fixed = true;
            }
        }
        override public function _notifyDetached ( object : Object ) : void
        {
            var pFX : CFX = object as CFX;
            if ( pFX == null || pFX.fxKey == null ) return;
            var type : String = pFX.fxKey.fxType;
            if ( type == CCharacterFXKey.NORMAL_FX ) return;

            var pEffectsMap : CMap = ( type == CCharacterFXKey.COMBINE_FX ) ? m_mapComHitEffects : m_mapBuffEffects;
            var pFXList : Vector.<CFX> = pEffectsMap.find( pFX.fxKey.buffName );
            if ( pFXList == null ) return;

            var index : int = pFXList.indexOf ( pFX );
            if ( index < 0 ) return;
            pFXList[ index ] = null;
        }


        /**
         * 是否开启轮廓滤镜，并设置滤镜属性
         * 注意：blur参数应该设置尽可能小，轮廓性能消耗将随blur增加而增加，性能与blur的复杂度为O(n)
         * @param enable 是否开启轮廓滤镜
         * @param red    设置轮廓滤镜颜色值的红色通道
         * @param green  设置轮廓滤镜颜色值的绿色通道
         * @param blue   设置轮廓滤镜颜色值的蓝色通道
         * @param alpha  设置轮廓滤镜颜色值的Alpha通道
         * @param size   设置轮廓滤镜大小
         * @param strength  设置轮廓滤镜强度
         */
        public function rimLightOutline( enable:Boolean, red:Number = 1.0, green:Number = 1.0 , blue:Number = 1.0, alpha:Number = 1.0, size: Number = 1.0):void
        {
            if ( m_theCharacterObject != null ) m_theCharacterObject.rimLightOutline(enable, red, green, blue, alpha, size);
        }

        //
        //
        protected function _onLoadCharacterFinished( theCharacterObj : CCharacterObject, iResult : int ) : void
        {
            if( this.disposed )
            {
                theCharacterObj.dispose();
                return;
            }

            if( theCharacterObj != m_theCharacterObject )
            {
                Foundation.Log.logErrorMsg( "theCharacterObj should equal to m_theCharacterObject!" );
                return;
            }

            if( theCharacterObj.isLoaded )
            {
                AssetsSize = theCharacterObj.AssetsSize;
                //trace( "character " + this.filename + ": " + AssetsSize / 1048576 + "MB" );

                if( this.castShadow ) this.castShadow = true;
                setVisible( m_bVisible, false );
                this.opaque = m_fOpaque;

                // get bone index again when the character is loaded( if m_theCharacterFXDataRef is not linked before )
                if( m_theCharacterFXDataRef != null && m_theCharacterFXDataRef.dataLinked == false )
                {
                    var fxKey : CCharacterFXKey = null;
                    var dataMap : CMap = m_theCharacterFXDataRef.getData();
                    var fxKeysMap : CMap ;
                    for each( fxKeysMap in dataMap )
                    {
                        for each( var fxKeys : Vector.<CCharacterFXKey> in fxKeysMap )
                        {
                            for( var i : int = 0, k : int = fxKeys.length; i < k; i++ )
                            {
                                fxKey = fxKeys[ i ];
                                fxKey.boneIndex = this.findBoneIndex( fxKey.boneName );
                                if( fxKey.boneIndex < 0 ) Foundation.Log.logErrorMsg( "Cannot find bone: " + fxKey.boneName + " in character: " + this.m_theCharacterObject.spineLoader.skeletonFilename );
                            }
                        }
                    }
                    m_theCharacterFXDataRef.dataLinked = true;
                }

                theCharacterObj.addOnAnimationChangedCallback( _onAnimationChanged );
                updateMatrix( false );
            }
            else
            {
                m_sFilename = null;
            }

            // begin of debug
            if( m_bLoadCharacterFinishedCalled )
            {
                Foundation.Log.logErrorMsg( "Should not call m_fnLoadCharacterFinished twice!!" );
            }
            else m_bLoadCharacterFinishedCalled = true;
            // end of debug

            if( m_fnLoadCharacterFinished != null )
            {
                m_fnLoadCharacterFinished( this, iResult );
                m_fnLoadCharacterFinished = null;
            }
        }

        protected function _onLoadExtFinished(loader : CPackedQsonLoader, idErrorCode : int) : void
        {
            if(this.disposed) return;

            if(idErrorCode == 0)
            {
                m_thePackedDataResource = loader.createResource();
                m_arrResURL.push( m_sFilename + "_packed.json" );
                RelatedAssetsSize += m_thePackedDataResource.resourceSize;
                CCharacterResourceData.addResource(filename,m_sFilename + "_packed.json",  m_thePackedDataResource.resourceSize);
            }

            if(m_fnLoadExtFinished != null)
            {
                m_fnLoadExtFinished();
                m_fnLoadExtFinished = null;
            }
        }

        protected function _onLoadCollisionFinished( loader : CJsonLoader, idErrorCode : int ) : void
        {
            if( this.disposed ) return ;

            if( idErrorCode == 0 )
            {
                m_theCollisionDataResource = loader.createResource();
                if( m_theCollisionDataResource == null ) return;

                if ( !CPackedQsonLoader.enablePackedQsonLoading )
                {
                    m_arrResURL.push( m_sFilename + "_collision.json" );
                    RelatedAssetsSize += m_theCollisionDataResource.resourceSize;
                    CCharacterResourceData.addResource(filename,m_sFilename + "_collision.json",  m_theCollisionDataResource.resourceSize);
                }

                m_theCollisionDataRef = new CCharacterCollisionAssemblyData();
                m_theCollisionDataRef.loadData( m_theCollisionDataResource.theObject );
                //m_theCollisionDataRef = m_theCollisionDataResource.theObject as CCharacterCollisionAssemblyData;
                if(m_theCollisionDataRef == null) return;
                if( m_theCollisionObj ) {
                    if( blockCollisionData && blockCollisionData.length > 0 ) {
                        var list : Vector.<CCharacterCollisionBoundInfo> = blockCollisionData[ 0 ].boundsList;
                        if( list && list.length > 0 ) {
                            var keyInfo : CCharacterCollisionBoundInfo = blockCollisionData[ 0 ].boundsList[ 0 ];
                            var blockBox : CAABBox3 = m_theCollisionObj.createCAABB3FromInfo( keyInfo );
                            m_theCollisionObj.setRelativeBlockAABB( blockBox );
                        }else{
                            Foundation.Log.logTraceMsg("Idle animation has not collision data for creating  block bound");
                        }
                    }else
                    {
                        Foundation.Log.logTraceMsg("Idle animation has not collision data for creating  block bound");
                    }
                }

            }
            if( m_fnLoadCollisionFinished != null )
            {
                m_fnLoadCollisionFinished( this, idErrorCode );
                m_fnLoadCollisionFinished = null;
            }
        }

        protected function _onLoadAudioFinished( loader : CJsonLoader, idErrorCode : int ) : void
        {
            if( this.disposed ) return ;

            if( idErrorCode == 0 )
            {
                m_theAudioDataResource = loader.createResource();
                if( m_theAudioDataResource == null ) return;

                if ( !CPackedQsonLoader.enablePackedQsonLoading )
                {
                    m_arrResURL.push( m_sFilename + "_audio.json" );
                    RelatedAssetsSize += m_theAudioDataResource.resourceSize;
                    CCharacterResourceData.addResource(filename,m_sFilename + "_audio.json",  m_theAudioDataResource.resourceSize);
                }

                m_theAudioDataRef = new CCharacterAudioData();
                m_theAudioDataRef.loadData( m_theAudioDataResource.theObject );

                if( m_bAudioPreload )
                {
                    //预加载音效
                    var audioMap : CMap = m_theAudioDataRef.getAudioMap();
                    var audioManager : CAudioManager = m_theBelongFramework.audioManager as CAudioManager;
                    if( audioManager == null )return;
                    var bName : String;
                    var keyDataVec : Vector.<CCharacterAudioKey>;
                    var infoDataVec : Vector.<CCharacterAudioInfo>;
                    var audioInfo : CCharacterAudioInfo;

                    var skillMap : CMap;
                    var skillId : String;
                    for( bName in audioMap )
                    {
                        skillMap = audioMap[ bName ];
                        for( skillId in skillMap )
                        {
                            keyDataVec = skillMap[ skillId ];
                            for each( var audioKey : CCharacterAudioKey in keyDataVec )
                            {
                                infoDataVec = audioKey.getAudioInfoVec();
                                for each( audioInfo in infoDataVec )
                                {
                                    if( skillId == STRING_DEFAULT || skillId.toLocaleLowerCase() == bName.toLocaleLowerCase() )
                                    {
                                        audioManager.loadAudio( audioInfo.audioPath, CFramework.StatisticsResourceOn ? _onPreLoadAudioFinished : null );
                                    }
                                    else
                                    {
                                        if( audioInfo.randomAudiosVec && audioInfo.randomAudiosVec.length > 0 )
                                        {
                                            for each( var path : String in audioInfo.randomAudiosVec )
                                            {
                                                audioManager.loadAudio( path, CFramework.StatisticsResourceOn ? _onPreLoadAudioFinished : null );
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if( m_fnLoadAudioFinished != null )
            {
                m_fnLoadAudioFinished( this, idErrorCode );
                m_fnLoadAudioFinished = null;
            }
        }
        protected function _onLoadCharacterFXFinished( loader : CJsonLoader, idErrorCode : int ) : void
        {
            if( this.disposed ) return ;

            if( idErrorCode == 0 )
            {
                // get the FX data entry
                m_theCharacterFXDataResource = loader.createResource();
                if( m_theCharacterFXDataResource == null ) return;

                if ( !CPackedQsonLoader.enablePackedQsonLoading )
                {
                    m_arrResURL.push( m_sFilename + "_animfx.json" );
                    RelatedAssetsSize += m_theCharacterFXDataResource.resourceSize;
                    CCharacterResourceData.addResource(filename,m_sFilename + "_animfx.json",  m_theCharacterFXDataResource.resourceSize);
                }

                m_theCharacterFXDataRef = new CCharacterFXData();
                m_theCharacterFXDataRef.loadFromData( m_theCharacterFXDataResource.theObject );
                if( m_theCharacterFXDataRef == null ) return;

                var dataMap : CMap = m_theCharacterFXDataRef.getData();
                var fxKeysMap : CMap;
                var fxKey : CCharacterFXKey;
                var fxKeys : Vector.<CCharacterFXKey>;
                var skillKey:String,actionKey:String;
                var i : int, k : int;

                // setup bone index if character is loaded
                if( m_theCharacterObject.isLoaded && m_theCharacterFXDataRef.dataLinked == false )
                {
                    for each( fxKeysMap in dataMap )
                    {
                        for each( fxKeys in fxKeysMap )
                        {
                            for ( i = 0, k = fxKeys.length; i < k; i++ )
                            {
                                fxKey = fxKeys[ i ];
                                fxKey.boneIndex = this.findBoneIndex( fxKey.boneName );
                                if( fxKey.boneIndex < 0 ) Foundation.Log.logErrorMsg( "Cannot find bone: " + fxKey.boneName + " in character: " + this.m_theCharacterObject.spineLoader.skeletonFilename );
                            }
                        }
                    }
                    m_theCharacterFXDataRef.dataLinked = true;
                }

                // preload FXs to pools
                if( m_bFXPreload )
                {
                    var hasPreloadList:Boolean = m_vPreloadActions != null && m_vPreloadActions.length > 0;
                    var fxResourcePool : CResourcePool;
                    var fx : CFX;
                    for( skillKey in dataMap )
                    {
                        if(hasPreloadList && skillKey!=STRING_DEFAULT) continue;

                        fxKeysMap = dataMap[skillKey];
                        for( actionKey in fxKeysMap )
                        {
                            if( hasPreloadList && m_vPreloadActions.indexOf(actionKey) == -1 ) continue;

                            fxKeys = fxKeysMap[actionKey];
                            for( i = 0, k = fxKeys.length; i < k; i++ )
                            {
                                fxKey = fxKeys[ i ];

                                fxResourcePool = m_theBelongFramework.fxResourcePools.getPool( fxKey.fxURL );
                                if( null == fxResourcePool )
                                {
                                    fxResourcePool = new CResourcePool( fxKey.fxURL, null, 0 );
                                    m_theBelongFramework.fxResourcePools.addPool( fxKey.fxURL, fxResourcePool );
                                }

                                // check if the FX has already inside the pool, if yes then there's no need to load it here.
                                if( fxResourcePool.currentCapacity > 0 )
                                {
                                    if ( CFramework.StatisticsResourceOn )
                                    {
                                        if ( m_arrResURL.indexOf( fxKey.fxURL ) == -1 )
                                    {
                                        m_arrResURL.push( fxKey.fxURL );
                                        var pResource : CResource = CResourceCache.instance().find( fxKey.fxURL, CJsonLoader.NAME );
                                        if ( pResource != null )
                                        {
                                            RelatedAssetsSize += pResource.resourceSize;
                                            CCharacterResourceData.addResource(filename,fxKey.fxURL,  pResource.resourceSize);
                                            //trace( "fx " + fxKey.fxURL + ": " + pResource.resourceSize / 1048576 + "MB" );
                                        }
                                    }
                                    }
                                    continue;
                                }

                                // not loaded before, so load it and recycle it into the pool for later to use(preload fx to prevent the waiting time while we need it)
                                fx = new CFX( m_theBelongFramework );
                                fx.loadFile( fxKey.fxURL, m_iLoadingPriority, CFramework.StatisticsResourceOn ? _onPreLoadFxFinished : null );
                                if(!CFramework.StatisticsResourceOn) fxResourcePool.recycle( fx );
                            }
                        }
                    }
                }

                if( this.animationController != null )
                {
                    // do call the animation state changed callback right after fx data loaded
                    var sCurrentStateName : String = this.animationController.currentState.stateName;
                    _onStateChanged( "", sCurrentStateName );
                }
                _onAnimationChanged( 0 );
            }

            if( m_fnFXDataLoadFinished != null )
            {
                m_fnFXDataLoadFinished( this, idErrorCode );
                m_fnFXDataLoadFinished = null;
            }
        }

        protected function _onLoadHitEffectFinished ( loader : CJsonLoader, idErrorCode : int ) : void
        {
            if( this.disposed ) return ;

            if( idErrorCode == 0 )
            {
                // get the hit effect data entry
                m_theHitEffectDataResource = loader.createResource ();
                if( m_theHitEffectDataResource == null ) return;

                if ( !CPackedQsonLoader.enablePackedQsonLoading )
                {
                    m_arrResURL.push( m_sFilename + "_he.json" );
                    RelatedAssetsSize += m_theHitEffectDataResource.resourceSize;
                    CCharacterResourceData.addResource(filename,m_sFilename + "_he.json",  m_theHitEffectDataResource.resourceSize);
                }

                m_theHitEffectDataRef = new CCharacterFXData();
                m_theHitEffectDataRef.loadFromData( m_theHitEffectDataResource.theObject );
                if ( m_theHitEffectDataRef == null ) return;

                m_theHitEffectDataRef.dataLinked = true;
            }

            if( m_fnHitEffectLoadFinished != null )
            {
                m_fnHitEffectLoadFinished( this, idErrorCode );
                m_fnHitEffectLoadFinished = null;
            }
        }

        protected function _onLoadCombineEffectFinished ( loader : CCharacterFXDataLoader, idErrorCode : int ) : void
        {
            m_sCombineEffectIsLoading = false;
            if( this.disposed ) return;

            if( idErrorCode == 0 )
            {
                m_theBelongFramework.combineEffectDataResource = loader.createResource ();
                if ( m_theBelongFramework.combineEffectDataResource == null ) return;

                // get the combined effect data entry
                m_theComHitEffectDataRef = m_theBelongFramework.combineEffectDataResource.theObject as CCharacterFXData;
                if ( m_theComHitEffectDataRef == null ) return;

                m_theComHitEffectDataRef.dataLinked = true;
            }

            if( m_fnComHitEffectLoadFinished != null )
            {
                m_fnComHitEffectLoadFinished( this, idErrorCode );
                m_fnComHitEffectLoadFinished = null;
            }
        }

        protected function _onLoadBuffEffectFinished ( loader : CCharacterFXDataLoader, idErrorCode : int ) : void
        {
            m_sBuffEffectIsLoading = false;
            if( this.disposed ) return;

            if( idErrorCode == 0 )
            {
                m_theBelongFramework.buffEffectDataResource = loader.createResource ();
                if ( m_theBelongFramework.buffEffectDataResource == null ) return;

                // get the combined effect data entry
                m_theBuffEffectDataRef = m_theBelongFramework.buffEffectDataResource.theObject as CCharacterFXData;
                if ( m_theBuffEffectDataRef == null ) return;

                m_theBuffEffectDataRef.dataLinked = true;
            }

            if( m_fnBuffEffectLoadFinished != null )
            {
                m_fnBuffEffectLoadFinished( this, idErrorCode );
                m_fnBuffEffectLoadFinished = null;
            }
        }

        protected virtual function _onStateChanged( sFromStateName : String, sToStateName : String ):void
        {
            if( m_theCollisionObj ) this._setCollisionChange();
        }

        protected virtual function _onAnimationChanged( iTrackIdx : int ) : void
        {
            if( iTrackIdx == 0 )
            {
                m_fStateChangedSpeed = m_fAnimationSpeed;
                m_bIsChanged = true;

                this._fxStopedWhenAnimationChanged ();
                this._playAnimationFXs();
                this._playAnimationAudio();
                m_bAudioLoop = false;
            }
        }

        protected function _setCollisionChange() : void
        {
            if( m_sCurrentAnimationTag == STRING_DEFAULT )
            {
                m_theCollisionObj.setCollisionData( currentCollisionData );
            }
            else if( m_readyChangeTag )
            {
                m_theCollisionObj.setCollisionData( currentCollisionData );
            }
            m_readyChangeTag = false;
            m_theCollisionObj.update( 0 );
        }

        public function setEnableCollision( value : Boolean ) : void
        {
            if( m_theCollisionObj )
                    m_theCollisionObj.enable = value;
        }

        protected function _playAnimationFXs( bLoopingPlay : Boolean = false ) : void
        {
            if( m_theCharacterFXDataRef == null ) return ;

            var sAnimationName : String;
            var bLoop : Boolean;
            if( currentAnimationClip == null )
            {
                if( this.animationController != null )
                {
                    bLoop = this.animationController.currentState.animationLoop;
                    sAnimationName = this.animationController.currentState.animationName;
                }
                else
                {
                    bLoop = false;
                    sAnimationName = "";
                }
            }
            else
            {
                bLoop = currentAnimationClip.m_bLoop;
                sAnimationName = currentAnimationClip.m_sName;
            }
            sAnimationName = ( m_sCurrentAnimationTag == STRING_DEFAULT ) ? sAnimationName : sAnimationName + "_" + m_sCurrentAnimationTagParam;
            //var sAnimationName : String = ( m_sCurrentAnimationTag == STRING_DEFAULT ) ? currentAnimationClip.m_sName : currentAnimationClip.m_sName + "_" + m_sCurrentAnimationTagParam;
            //var bLoop : Boolean = currentAnimationClip != null ? currentAnimationClip.m_bLoop : this.animationController.currentState.animationLoop;

            var pFXKeys : Vector.<CCharacterFXKey> = m_theCharacterFXDataRef.getValueByName( sAnimationName , this.currentAnimationTag );
            if( null == pFXKeys || pFXKeys.length <= 0 )
            {
                m_sCurrentAnimationFXName = null;
                return;
            }
            m_sCurrentAnimationFXName = sAnimationName;

            var pFXKey : CCharacterFXKey = null;
            for( var i : int = 0, n : int = pFXKeys.length; i < n; i++ )
            {
                pFXKey = pFXKeys[ i ];
                var playCondition : Boolean = !( pFXKey.playOneTime &&
                                                ( pFXKey.playNewPerAnimationLoop ||
                                                  pFXKey.playInAnimationOneLoopTimes )
                                                );
                if ( bLoopingPlay && playCondition ) continue;

                var pFX : CFX = _createFX( pFXKey );
                pFX.attachToCharacter( this, pFXKey );
                pFX.onStopedCallBack = _fxStopedCallBack;
                m_setPlayingFXs.add( pFX );

                if ( pFXKey.playOneTime ) bLoop = false;

                var fPlayTime : Number = pFXKey.playTime;
                playCondition = pFXKey.playOneTime && pFXKey.playInAnimationOneLoopTimes;

                var playSpeed : Number = m_fStateChangedSpeed;
                if ( playCondition )
                {
                    //第loopTimes次循环，keyTime上播放特效
                    var curLoopTimes:int = currentAnimationClip.m_nCurrentLoopTimes;
                    if( curLoopTimes == pFXKey.loopTimes )
                    {
                        pFX.play( bLoop, fPlayTime, pFXKey.keyTime, pFXKey.keyTime, playSpeed );
                    }
                }
                else
                {
//                    trace("播放特效:==========>:",pFXKey.fxURL,pFXKey.keyTime,sAnimationName , this.currentAnimationTag);
                    pFX.play( bLoop, fPlayTime, pFXKey.keyTime, pFXKey.keyTime, playSpeed );
                }
            }
        }

        protected function _playAnimationAudio() : void
        {
            //切换动作后，音效是否播放过状态还原
            this._clearAudioState();
            m_vCurrentAudios = this.currentAudioData;
            m_fAudioDeltaTime = 0.0;
            m_bIsSetFrame = false;
        }

        protected function _clearAudioState() : void
        {
            var audioKeys:Vector.<CCharacterAudioInfo> = null;
            if(m_vCurrentAudios){
                for each ( var audioKey:CCharacterAudioKey in m_vCurrentAudios) {
                    audioKeys = audioKey.getAudioInfoVec();
                    for each ( var audioInfo:CCharacterAudioInfo in audioKeys ) {
                        audioInfo.isPlayed = false;
                    }
                }
            }
        }

        protected function _animationAudioUpdate( fDeltaTime : Number ) : void
        {
            if (m_bIsChanged)
            {
                m_fPlaySpeed = m_fAnimationSpeed;
                if ( m_fPlaySpeed <= 0.0){
                    m_fPlaySpeed = 1.0;
                }
                m_bIsChanged = false;
            }

            if( m_theAudioDataRef == null)return;
            if( m_vCurrentAudios == null　|| m_vCurrentAudios.length <= 0)return;
            var audioManager:CAudioManager = m_theBelongFramework.audioManager as CAudioManager;
            if( audioManager == null )return;

            var currentAnimationClip : CAnimationClip = this.currentAnimationClip;
            if( currentAnimationClip != null )
            {
                var fCurrentTime : Number = this.currentAnimationClipTime;

                if(m_fAnimationSpeed <= 0){
                    m_bIsSetFrame = true;
                    m_fAudioDeltaTime += fDeltaTime;
                }

                // replay FX if current animation has looped
                if( currentAnimationClip.m_fLastTime > currentAnimationClip.m_fTime )
                {
                    m_bAudioLoop = true;
                    this._clearAudioState();
                }

                var infoDataVec:Vector.<CCharacterAudioInfo>;
                var audioInfo:CCharacterAudioInfo;
                var randomNum:Number;
                var randomPlay:Number;
                var playTime:Number = 0.0;
                for each(var audioKey:CCharacterAudioKey in m_vCurrentAudios)
                {
                    infoDataVec = audioKey.getAudioInfoVec();
                    if( this.currentAnimationTag == STRING_DEFAULT ||
                        this.currentAnimationTag.toLowerCase() == currentAnimationClip.m_sName.toLowerCase())
                    {
                        if ( !m_bAudioLoop ) {
                            //开始播放时间
                            playTime = audioKey.keyTime - audioKey.startTime;
                            if( playTime <= 0 )playTime = 0.0;
                            if ( fCurrentTime >= playTime ) {
                                for each( audioInfo in infoDataVec ) {
                                    if ( !audioInfo.isPlayed ) {
                                        randomNum = CMath.rand();
                                        if ( audioInfo.prob >= randomNum ) {
                                            if ( audioInfo.randomAudiosVec && audioInfo.randomAudiosVec.length > 0 ) {
                                                randomPlay = Math.floor( CMath.rand()*audioInfo.randomAudiosVec.length );
                                                audioManager.playAudioByPath( audioInfo.randomAudiosVec[ randomPlay ], audioInfo.nLoop );
                                                audioInfo.isPlayed = true;
                                            }
                                        }
                                    }

                                }
                            }
                        }else {
                            playTime = audioKey.keyTime - audioKey.startTime;
                            if( playTime <= 0 )playTime = 0.0;
                            if ( fCurrentTime >= playTime && m_bAudioLoop ) {
                                for each( audioInfo in infoDataVec ) {
                                    if ( !audioInfo.isPlayed ) {
                                        randomNum = CMath.rand();
                                        if ( audioInfo.prob >= randomNum ) {
                                            if ( audioInfo.randomAudiosVec && audioInfo.randomAudiosVec.length > 0 ) {
                                                randomPlay = Math.floor( CMath.rand()*audioInfo.randomAudiosVec.length );
                                                audioManager.playAudioByPath( audioInfo.randomAudiosVec[ randomPlay ], audioInfo.nLoop );
                                                audioInfo.isPlayed = true;
                                                m_bAudioLoop = false;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        //技能音效播放
                        //开始播放时间
                        if(m_bIsSetFrame){
                            //如果是定帧动作
                            fCurrentTime = m_fAudioDeltaTime + this.currentAnimationClipTotalTime;
                            playTime = audioKey.keyTime - audioKey.startTime;
                        }else{
                            playTime = (audioKey.keyTime - audioKey.startTime) * m_fPlaySpeed;
                        }

                        if( playTime <= 0 )playTime = 0.0;
                        if ( fCurrentTime >= playTime ) {
                            for each( audioInfo in infoDataVec ) {

                                if ( !audioInfo.isPlayed ) {
                                    //触发概率
                                    randomNum = CMath.rand();
                                    if ( audioInfo.prob >= randomNum ) {
                                        if ( audioInfo.randomAudiosVec && audioInfo.randomAudiosVec.length > 0 ) {
                                            randomPlay = Math.floor( CMath.rand()*audioInfo.randomAudiosVec.length );
                                            audioManager.playAudioByPath( audioInfo.randomAudiosVec[ randomPlay ], audioInfo.nLoop );
                                            audioInfo.isPlayed = true;
                                        }
                                        else {
                                            Foundation.Log.logWarningMsg( "[CCharacter]  技能音效播放列表为空" );
                                        }
                                    }else{
                                        audioInfo.isPlayed = true;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        protected function _createFX( pFXKey : CCharacterFXKey ) : CFX
        {
            var pFX : CFX = null;
            var pool : CResourcePool = m_theBelongFramework.fxResourcePools.getPool( pFXKey.fxURL );
            if( pool != null )
                pFX = pool.allocate() as CFX;
            if( null == pFX )
            {
                pFX = new CFX( m_theBelongFramework );
                pFX.loadFile( pFXKey.fxURL, m_iLoadingPriority, _onEffectLoaded );
            }

            pFX.basedOnScreenLimit = m_bFXBasedOnScreenLimit;
            pFX.visible = this.visible;
            pFX.enabled = this.enabled;
            return pFX;
        }

        private function _onEffectLoaded(pFx:CFX, iResult:int):void
        {
            if(iResult != 0)
            {
                if(m_setPlayingFXs)
                {
                    m_setPlayingFXs.remove(pFx);
                }
            }
        }

        protected function _animationFXUpdate() : void
        {
//            for each( var fx : CFX in m_setPlayingFXs )
//            {
//                if ( fx.fxKey != null && fx.fxKey.fxType == CCharacterFXKey.NORMAL_FX )
//                {
//                    if ( !fx.fxKey.playOneTime ) fx.timeScale = m_fAnimationSpeed;
//                    else
//                    {
//                        if ( fx.isStartPlayActually ) fx.timeScale = 1.0;
//                        else fx.timeScale = m_fAnimationSpeed;
//                    }
//                }
//            }

            if( m_vStoppedFXs.length > 0 )
            {
                for each( var pFX : CFX in m_vStoppedFXs )
                {
                    m_setPlayingFXs.remove( pFX );
                    _recycleAnimationFX( pFX );
                }
                m_vStoppedFXs.length = 0;
            }

            // fx with loop animation
            var currentAnimationClip : CAnimationClip = this.currentAnimationClip;
            if( currentAnimationClip != null )
            {
                // replay FX if current animation has looped
                //Foundation.Log.logMsg( "m_fLastTime: " + currentAnimationClip.m_fLastTime + ", m_fTime: " + currentAnimationClip.m_fTime );
                if( currentAnimationClip.m_fLastTime > currentAnimationClip.m_fTime )
                {
                    _playAnimationFXs( true );
                }
            }
        }
        protected function _recycleAnimationFX( pFX : CFX ) : void
        {
            if ( pFX.isAutoRecycle ) return;
            CFX.manuallyRecycle ( pFX );
        }
        protected function _removeCombineOrBuffEffect ( params : Array ) : void
        {
            if ( this.disposed ) return;

            var pFX : CFX = params[ 0 ] as CFX;
            //fx stoped, recycle it;
            if ( pFX != null )
            {
                m_setPlayingFXs.remove ( pFX );
                _recycleAnimationFX ( pFX );
            }
        }
        protected function _fxStopedCallBack ( params : Array ) : void
        {
            if ( this.disposed || params == null ) return;
            var pFX : CFX = params[ 0 ];
            if ( pFX != null )
            {
                m_setPlayingFXs.remove ( pFX );
                _recycleAnimationFX ( pFX );
            }
        }

        protected function _calculateShadowBoundWidth( fDeltaTime : Number ):void
        {
            var theShadowAABB : CAABBox2 = m_theShadowObject.currentBound;
            var theCharacterAABB : CAABBox2 = this.getBound( this.animationController.getStateByIndex( 0 ).animationName, true );
            if( theShadowAABB.extX > 0.0 && theCharacterAABB != null && fDeltaTime > 0.0 )
            {
                if( m_fShadowBoundWidth < 0.0 ) m_fShadowBoundWidth = theCharacterAABB.extX;
                /*if( m_fShadowBoundWidth < 0.0 ) m_fShadowBoundWidth = theShadowAABB.extX;
                 else
                 {
                 var fDeltaDis : Number;
                 var fDis : Number = theCharacterAABB.extX - m_fShadowBoundWidth;
                 if( fDis > 1.0 )
                 {
                 fDeltaDis = fDis * fDeltaTime * 0.5;
                 if( fDeltaDis < 0.1 ) fDeltaDis = 0.1;
                 else if( fDeltaDis > fDis ) fDeltaDis = fDis;
                 m_fShadowBoundWidth += fDeltaDis;
                 }
                 else if( fDis < -1.0 )
                 {
                 fDeltaDis = fDis * fDeltaTime * 0.5;
                 if( fDeltaDis > -0.1 ) fDeltaDis = -0.1;
                 else if( fDeltaDis < fDis ) fDeltaDis = fDis;
                 m_fShadowBoundWidth += fDeltaDis;
                 }
                 }*/
            }
        }

        protected function _setGravityAcc( acc : Number ) : void {
            m_fCharacterGravityAcc = acc;
            this.m_vGravityAcceleration.setValueXYZ( 0.0, m_fCharacterGravityAcc, 0.0 );
        }

        //
        internal function _setShadowImage( sFilename : String, fShadowObjectScaleFactor : Number = 1.0 ) : void
        {
            if( sFilename != null && sFilename != "" && m_theShadowObject != null ) return ;

            if( m_theShadowObject != null )
            {
                m_theShadowObject.dispose();
                m_theShadowObject = null;
            }

            if( sFilename != null && sFilename != "" && this.castShadow )
            {
                var img : CImageObject = new CImageObject( m_theBelongFramework.renderer );
                img.loadFile( sFilename, _onShadowImageLoadFinished );
                m_theShadowObject = img;
                m_fShadowObjectScaleFactor = fShadowObjectScaleFactor;
            }
        }

        //
        private function _onShadowImageLoadFinished( theImage : CImageObject, idErrorCode : int ) : void
        {
            if( idErrorCode != 0 )
            {
                Foundation.Log.logErrorMsg( "shadow image load failed: " + theImage.filename );
                return ;
            }

            if( m_theShadowObject != null )
            {
                var theParentSceneLayer : CBaseObject = m_theCharacterObject.findParentByType( CSceneLayer );
                if( theParentSceneLayer != null ) m_theShadowObject.setParent( theParentSceneLayer );
            }
            updateMatrix( false );
        }

        private function _resetCharacterObject() : void
        {
            var theParentBaseObject : CBaseObject = m_theCharacterObject.parent;
            var bSuppressPlayAnimationErrorMsg : Boolean = m_theCharacterObject.suppressPlayAnimationErrorMsg;
            if( m_spVisibleBound != null ) m_theCharacterObject.removeChild( m_spVisibleBound );

            clear();

            m_theCharacterObject.setParent( theParentBaseObject );
            m_theCharacterObject.suppressPlayAnimationErrorMsg = bSuppressPlayAnimationErrorMsg;
            if( m_spVisibleBound != null ) m_theCharacterObject.addChild( m_spVisibleBound );

            updateMatrix( false ); // force update to new character object

            if( m_theBelongFramework.currentCameraScene != null )
            {
                if( m_theBelongFramework.currentCameraTarget == this ) m_theBelongFramework.currentCameraScene.setCameraFollowingTarget( this, m_theBelongFramework.currentCameraTarget2 );
                else if( m_theBelongFramework.currentCameraTarget2 == this ) m_theBelongFramework.currentCameraScene.setCameraFollowingTarget( m_theBelongFramework.currentCameraTarget, this );
            }
        }

        private function _tackleNextPlayAnimation() : void
        {
            var theNextAnimation : _CNextPlayAnimationInfo = m_vNextPlayAnimations[ 0 ];
            if( this.currentAnimationClipTimeLeft <= 0.0 )
            {
                m_vNextPlayAnimations.splice( 0, 1 );
                this.playAnimation( theNextAnimation.m_sClipName, theNextAnimation.m_bLoop, theNextAnimation.m_bForceReplay,
                        theNextAnimation.m_bExtractAnimationOffset, theNextAnimation.m_iTrackIdx, theNextAnimation.m_bRandomStart,
                        theNextAnimation.m_fLoopTime, theNextAnimation._onAnimationFinished );
                //Foundation.Log.logMsg( "play next animation: " + theNextAnimation.m_sClipName + ", time left: " + this.currentAnimationClipTimeLeft );
            }
            else
            {
                if( theNextAnimation.m_bAutoFinishPreviousAnimation )
                {
                    var theAnimationClip : CAnimationClip = m_theCharacterObject.getCurrentAnimationClip( theNextAnimation.m_iTrackIdx );
                    if( theAnimationClip.m_fLoopTime == 0.0 && theAnimationClip.m_bLoop ) theAnimationClip.m_bLoop = false;
                }
            }
        }

        private function _fxStopedWhenAnimationChanged () : void
        {
            var sAnimationName : String;
            if( currentAnimationClip != null  )
                sAnimationName = currentAnimationClip.m_sName;
            else if ( animationController != null && animationController.currentState != null )
                sAnimationName = this.animationController.currentState.animationName;
            else sAnimationName = "";

            if ( m_sCurrentAnimationTag != STRING_DEFAULT )
                sAnimationName += "_" + m_sCurrentAnimationTagParam;

            var pFX : CFX;
            for each( pFX in m_setPlayingFXs )
            {
                var stopCondition : Boolean = m_sCurrentAnimationFXName == null || m_sCurrentAnimationFXName != sAnimationName;
                stopCondition = stopCondition && pFX.fxKey != null && pFX.fxKey.fxType == CCharacterFXKey.NORMAL_FX;
                stopCondition = stopCondition && ( pFX.isLoopPlay || !pFX.isStartPlayActually || pFX.fxKey.fadeWithAnimation );
                if( stopCondition )
                    pFX.stop ();
                if ( pFX.isStopped )
                    m_vStoppedFXs.push( pFX );
            }
        }

        private function _onPreLoadFxFinished ( pFx : CFX, iResult : int ) : void
        {
            if ( iResult != 0 ) return;
            if ( m_arrResURL.indexOf( pFx.filename ) == -1 )
            {
                m_arrResURL.push( pFx.filename );
                RelatedAssetsSize += pFx.AssetsSize;
                CCharacterResourceData.addResource(filename,pFx.filename,  pFx.AssetsSize);

                //trace( "fx " + pFx.filename + ": " + pFx.AssetsSize / 1048576 + "MB" );
            }
        }

        private function _onPreLoadAudioFinished ( iErrorCode : int, pAudioSource : CAudioSource ) : void
        {
            if ( iErrorCode != 0 ) return;
            if ( m_arrResURL.indexOf( pAudioSource.audioPath ) == -1 )
            {
                m_arrResURL.push( pAudioSource.audioPath );
                RelatedAssetsSize += pAudioSource.AssetsSize;
                CCharacterResourceData.addResource(filename,pAudioSource.audioPath,  pAudioSource.AssetsSize);

                //trace( "audio " + pAudioSource.audioPath + ": " + pAudioSource.AssetsSize / 1048576 + "MB" );
            }
        }

        public function loadComplex(complexKey : String, complexUrl : String, depth : Number = -10 , onLoadFinished : Function = null ) : Boolean
        {
            return  m_theCharacterObject.loadComplex( complexKey, complexUrl, depth, null ,onLoadFinished );
        }

        public function unloadComplex(complexKey : String) : Boolean
        {
            return m_theCharacterObject.unloadComplex(complexKey);
        }

        public function set collisable( value : Boolean ) : void
        {
            this.m_boCollisable = value;
        }

        public function get collision() : CCollisionObject
        {
            return m_theCollisionObj;
        }


        //
        //
        protected var m_sFilename : String = null;

        // general update related parameters
        protected var m_fAnimationSpeed : Number = 1.0;
        protected var m_fStateChangedSpeed : Number = 1.0;
        protected var m_fAlignToFrameInterval : Number = 0.0;
        protected var m_fUpdateTimeRemains : Number = 0.0;

        protected var m_theCharacterObject : CCharacterObject = null;
        protected var m_theShadowObject : CBaseObject = null;
        protected var m_fShadowObjectScaleFactor : Number = 1.0;
        protected var m_fShadowBoundWidth : Number = -1.0;
        protected var m_theAnimationController : CAnimationController = null;
        protected var m_fnLoadCharacterFinished : Function = null;
        protected var m_fCharacterGravityAcc : Number = -9.8 * 100.0 * 2.0;

        // for debug
        protected var m_bLoadCharacterFinishedCalled : Boolean = false;

        protected var m_thePackedDataResource : CResource = null;
        protected var m_fnLoadExtFinished : Function = null;

        private var m_vNextPlayAnimations : Vector.<_CNextPlayAnimationInfo>;

        //以后需要优化下，碰撞，音效，技能特效，击打特效，相同角色的数据是相同的
        // collision
        protected var m_theCollisionDataResource : CResource = null;
        protected var m_theCollisionDataRef : CCharacterCollisionAssemblyData = null;
        protected var m_fnLoadCollisionFinished : Function = null;

        protected var m_sCurrentAnimationTag : String = "default"; // for Character's ext data
        protected var m_sCurrentAnimationTagParam : String = ""; // for Character's ext data

        //audio
        protected var m_fnLoadAudioFinished : Function = null;
        protected var m_theAudioDataRef : CCharacterAudioData = null;
        protected var m_theAudioDataResource : CResource = null;
        protected var m_bAudioLoop : Boolean = false;
        protected var m_vCurrentAudios : Vector.<CCharacterAudioKey> = new Vector.<CCharacterAudioKey>();
        protected var m_bIsChanged : Boolean = true;
        protected var m_bAudioPreload : Boolean = true;
        protected var m_fPlaySpeed : Number = 1.0;
        private var m_fAudioDeltaTime : Number = 0.0;
        private var m_bIsSetFrame : Boolean = false;

        //fx
        protected var m_theCharacterFXDataResource : CResource = null;
        protected var m_theCharacterFXDataRef : CCharacterFXData = null;
        protected var m_setPlayingFXs : CSet = new CSet();
        protected var m_vStoppedFXs : Vector.<CFX> = new Vector.<CFX>();
        protected var m_sCurrentAnimationFXName : String = null;
        protected var m_fnFXDataLoadFinished : Function = null;
        protected var m_bFXPreload:Boolean = false;
        protected var m_bFXBasedOnScreenLimit : Boolean = true;

        // additional parameters used in audio & fx resource preload process
        protected var m_vPreloadActions:Vector.<String> = null;

        //hit effects
        protected var m_theHitEffectDataResource : CResource = null;
        protected var m_theHitEffectDataRef : CCharacterFXData = null;
        protected var m_fnHitEffectLoadFinished : Function = null;

        //combine effects
        protected var m_mapComHitEffects : CMap = null;
        protected var m_theComHitEffectDataRef : CCharacterFXData = null;
        protected var m_fnComHitEffectLoadFinished : Function = null;

        //buffer effects
        protected var m_mapBuffEffects : CMap = null;
        protected var m_theBuffEffectDataRef : CCharacterFXData = null;
        protected var m_fnBuffEffectLoadFinished : Function = null;

        protected static var m_sCombineEffectIsLoading : Boolean = false;
        protected static var m_sBuffEffectIsLoading : Boolean = false;

        //collision
        protected var m_theCollisionObj : CCollisionObject;
        protected var m_boCollisable : Boolean;
        protected var m_readyChangeTag : Boolean;
        protected var m_nCollisionLoop : int = -1;

        protected var m_arrResURL : Array = new Array();
    }
}

import QFLib.Framework.CCharacter;
import QFLib.Graphics.Character.CCharacterObject;

class _CNextPlayAnimationInfo
{
    public function _CNextPlayAnimationInfo( theCharacter : CCharacter, sClipName : String, bLoop : Boolean, bForceReplay : Boolean,
                                               bExtractAnimationOffset : Boolean, iTrackIdx : int, bRandomStart : Boolean,
                                               fLoopTime : Number, fnOnAnimationFinished : Function, bAutoFinishPreviousAnimation : Boolean )
    {
        m_theCharacterRef = theCharacter;
        m_sClipName = sClipName;
        m_bLoop = bLoop;
        m_bForceReplay = bForceReplay;
        m_bExtractAnimationOffset = bExtractAnimationOffset;
        m_iTrackIdx = iTrackIdx;
        m_bRandomStart = bRandomStart;
        m_fLoopTime = fLoopTime;
        m_fnOnAnimationFinished = fnOnAnimationFinished;
        m_bAutoFinishPreviousAnimation = bAutoFinishPreviousAnimation;
    }

    public function _onAnimationFinished( theCharacterObject : CCharacterObject ) : void
    {
        if( m_fnOnAnimationFinished != null ) m_fnOnAnimationFinished( m_theCharacterRef );
    }

    public var m_theCharacterRef : CCharacter;
    public var m_sClipName : String;
    public var m_bLoop : Boolean;
    public var m_bForceReplay : Boolean;
    public var m_bExtractAnimationOffset : Boolean;
    public var m_iTrackIdx : int;
    public var m_bRandomStart : Boolean;
    public var m_fLoopTime : Number;
    public var m_fnOnAnimationFinished : Function;
    public var m_bAutoFinishPreviousAnimation : Boolean;
}