/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2016/11/8.
 */
package QFLib.QEngine.Renderer
{
    import QFLib.Interface.IDisposable;
    import QFLib.Interface.IUpdatable;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Renderer.Device.RenderDeviceManager;
    import QFLib.QEngine.Renderer.Material.Shaders.ShaderLib;
    import QFLib.QEngine.Renderer.RenderQueue.RenderCommandPool;
    import QFLib.QEngine.SceneManage.SceneManager;

    public class RenderSystem implements IDisposable, IUpdatable
    {
        use namespace Engine_Internal;

        public static function getInstance() : RenderSystem
        {
            return SingletonHolder.instance();
        }

        function RenderSystem()
        {
            m_RenderDeviceManager = RenderDeviceManager.getInstance();
            m_vecRenderTargets = new Vector.<RenderTarget>();
            m_vecSceneManagers = new Vector.<SceneManager>();
            ShaderLib.init();
        }
        private var m_vecRenderTargets : Vector.<RenderTarget> = null;
        private var m_vecSceneManagers : Vector.<SceneManager> = null;
        private var m_RenderDeviceManager : RenderDeviceManager = null;

        public function dispose() : void
        {
            if( m_vecRenderTargets )
            {
                var len : int = m_vecRenderTargets.length;
                for( var i : int = 0; i < len; i++ )
                {
                    m_vecRenderTargets[ i ].dispose();
                }

                m_vecRenderTargets.fixed = false;
                m_vecRenderTargets.length = 0;
                m_vecRenderTargets = null;
            }

            m_RenderDeviceManager.dispose();
        }

        public function createSceneManager( className : Class = null ) : SceneManager
        {
            var sceneMgr : SceneManager;
            if( className == null )
                sceneMgr = new SceneManager( this );
            else
                sceneMgr = new className( this ) as SceneManager;

            if( !sceneMgr )
            {
                throw new Error( className + "is not concrete sceneManager class name!" );
                return null;
            }

            _addSceneMangager( sceneMgr );
            return sceneMgr;
        }

        public function update( delta : Number ) : void
        {
            var len : int = m_vecSceneManagers.length;
            for( var i : int = 0; i < len; i++ )
            {
                m_vecSceneManagers[ i ].render();
            }

            RenderCommandPool.update( delta );
        }

        Engine_Internal function _addRenderTarget( renderTarget : RenderTarget ) : void
        {
            var len : int = m_vecRenderTargets.length;
            m_vecRenderTargets.fixed = false;
            var i : int = 0;
            while( i < len )
            {
                if( null == m_vecRenderTargets[ i ] )
                {
                    m_vecRenderTargets[ i ] = renderTarget;
                    return;
                }
                i++;
            }

            m_vecRenderTargets[ len ] = renderTarget;
            m_vecRenderTargets.fixed = true;
        }

        Engine_Internal function _removeRenderTarget( renderTarget : RenderTarget ) : void
        {
            var len : int = m_vecRenderTargets.length;
            var i : int = 0;
            while( i < len )
            {
                if( m_vecRenderTargets[ i ] == renderTarget )
                {
                    m_vecRenderTargets[ i ] = null;
                    return;
                }
                i++;
            }
        }

        Engine_Internal function _addSceneMangager( sceneMgr : SceneManager ) : void
        {
            var len : int = m_vecSceneManagers.length;
            m_vecSceneManagers.fixed = false;
            var i : int = 0;
            while( i < len )
            {
                if( !m_vecSceneManagers[ i ] )
                {
                    m_vecSceneManagers[ i ] = sceneMgr;
                    return;
                }
                i++;
            }

            m_vecSceneManagers[ len ] = sceneMgr;
            m_vecSceneManagers.fixed = true;
        }

        Engine_Internal function _removeSceneManager( sceneMgr : SceneManager ) : void
        {
            var len : int = m_vecSceneManagers.length;
            var i : int = 0;
            while( i < len )
            {
                if( m_vecSceneManagers[ i ] == sceneMgr )
                {
                    m_vecSceneManagers[ i ] = null;
                    return;
                }
                i++;
            }
        }
    }
}

import QFLib.QEngine.Renderer.RenderSystem;

class SingletonHolder
{
    private static var _instance : RenderSystem = new RenderSystem();

    public static function instance() : RenderSystem { return _instance; }
}
