/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/2/14.
 */
package QFLib.QEngine.Renderer.Pipeline
{
    import QFLib.Interface.IDisposable;
    import QFLib.Math.CMatrix4;
    import QFLib.Math.MatrixUtil;
    import QFLib.QEngine.Core.Engine_Internal;
    import QFLib.QEngine.Renderer.*;
    import QFLib.QEngine.Renderer.Camera.Camera;
    import QFLib.QEngine.Renderer.Device.RenderDevice;
    import QFLib.QEngine.Renderer.Device.RenderDeviceManager;
    import QFLib.QEngine.Renderer.Material.BlendMode;
    import QFLib.QEngine.Renderer.Material.IFragmentShader;
    import QFLib.QEngine.Renderer.Material.IMaterial;
    import QFLib.QEngine.Renderer.Material.IPass;
    import QFLib.QEngine.Renderer.Material.IVertexShader;
    import QFLib.QEngine.Renderer.Material.ParamConst;
    import QFLib.QEngine.Renderer.Material.Shaders.ShaderLib;
    import QFLib.QEngine.Renderer.RenderQueue.RenderCommandSet;
    import QFLib.QEngine.Renderer.Utils.VertexData;

    import flash.display3D.Context3DProgramType;
    import flash.display3D.Context3DVertexBufferFormat;
    import flash.display3D.IndexBuffer3D;
    import flash.display3D.Program3D;
    import flash.display3D.VertexBuffer3D;
    import flash.geom.Matrix3D;

    public class ForwardRenderPipeline implements IDisposable
    {
        use namespace Engine_Internal;

        public static const PIPELINERENDERMODE_PASS : int = 1;
        public static const PIPELINERENDREMODE_OBJECT : int = 2;

        public static var PipelineRenderMode : int = PIPELINERENDREMODE_OBJECT;

        private static var sArrayHelper : Array = [ "sourceAlpha", "oneMinusSourceAlpha" ];

        public static function getInstance() : ForwardRenderPipeline
        {
            return SingletonHolder.instance();
        }

        function ForwardRenderPipeline()
        {}
        private var m_CurMVPMatrix : CMatrix4 = new CMatrix4();
        private var m_pLastMVPMatrix : CMatrix4 = null;
        private var m_pLastVPMatrix : CMatrix4 = null;
        private var m_pCurVPMatrix : CMatrix4 = null;
        private var m_pCurCamera : Camera = null;
        private var m_pLastCamera : Camera = null;
        private var m_pCurDevice : RenderDevice = null;

        public function dispose() : void
        {
            m_CurMVPMatrix = null;
            m_pCurVPMatrix = null;
            m_pLastMVPMatrix = null;
            m_pLastVPMatrix = null;

            m_pCurCamera = null;
            m_pLastCamera = null;

            m_pCurDevice = null;
        }

        public function prepare( pLastCamera : Camera, pCurCamera : Camera ) : void
        {
            m_pLastCamera = pLastCamera;
            m_pCurCamera = pCurCamera;

            m_pCurCamera._startRendering();
            m_pCurDevice = RenderDeviceManager.getInstance().current;
            m_pCurDevice.clear();
            m_pCurDevice.commitStates( RenderDevice.PENDING_VIEWPORT | RenderDevice.PENDING_RENDERSTATE );
        }

        public function execute( rcmdSet : RenderCommandSet ) : void
        {
            var i : int = 0;
            var count : int = rcmdSet.count;
            while( i < count )
            {
                renderSingleObject( rcmdSet.getElement( i ) );
                ++i;
            }
        }

        public function finish( pCamera : Camera ) : void
        {
            /*** reset render state per frame ***/

            var pLastDevice : RenderDevice = null;
            if( m_pLastCamera != null )
                pLastDevice = m_pLastCamera.renderTarget.renderDevice;

            pCamera._endRendering( !( m_pLastCamera == null ) || pLastDevice != m_pCurDevice );
        }

        private function renderSingleObject( rcmd : IRenderCommand ) : void
        {
            var i : int = 0;
            var passes : Vector.<IPass> = rcmd.material.passes;
            var passCount : int = passes.length;
            var pass : IPass = null;
            while( i < passCount )
            {
                pass = passes[ i ];
                renderPass( rcmd, pass );
                ++i;
            }
        }

        private function renderPass( rcmd : IRenderCommand, pass : IPass ) : void
        {
            var material : IMaterial = rcmd.material;
            var iBuffer : IndexBuffer3D = rcmd.indexBuffer;
            var vBuffer : VertexBuffer3D = rcmd.vertexBuffer;

            /******** bind vertex buffer ********/
            m_pCurDevice.setVertexBuffer( 0, vBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3 );
            if( material.useColor )
                m_pCurDevice.setVertexBuffer( 1, vBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4 );
            if( material.useTexcoord )
                m_pCurDevice.setVertexBuffer( 2, vBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2 );

            /********** blend mode *********/
            if( pass.blendMode == BlendMode.CUSTOM )
            {
                sArrayHelper[ 0 ] = pass.srcOp;
                sArrayHelper[ 1 ] = pass.dstOp;
            }
            else
            {
                var blendMode : Array = BlendMode.getBlendFactors( pass.blendMode, pass.pma );
                sArrayHelper[ 0 ] = blendMode[ 0 ];
                sArrayHelper[ 1 ] = blendMode[ 1 ];
            }
            m_pCurDevice.setBlendFactors( sArrayHelper[ 0 ], sArrayHelper[ 1 ] );
            //m_pCurDevice.setBlendFactors ( Context3DBlendFactor.ONE, Context3DBlendFactor.ZERO );

            /********** shader program setting **********/
            var vertShader : IVertexShader = ShaderLib.getVertex( pass.vertexShader );
            var fragShader : IFragmentShader = ShaderLib.getFragment( pass.fragmentShader );

            var numTexture : int = fragShader.textureLayout.length;
            var pProgram : Program3D = m_pCurDevice.findShaderProgram( pass.shaderName );
            if( pProgram == null )
            {
                pProgram = m_pCurDevice.createShaderProgram( pass.shaderName, vertShader.name, fragShader.name,
                        vertShader.code, fragShader.code, numTexture, pass.texFlagList );
            }
            m_pCurDevice.bindShaderProgram( pProgram );

            computeMVPMatrix( rcmd );

            /********* vert shader param setting *********/
            var paramCount : int = vertShader.paramLayout.length;
            var param : ParamConst;
            var matrix : Matrix3D;

            /** set mvp matrix **/
            m_pCurDevice.setProgramConstantsFromMatrix( Context3DProgramType.VERTEX, 1, m_CurMVPMatrix.matrix3D, true );

            for( var i : int = 0; i < paramCount; ++i )
            {
                /** the other param **/
                param = vertShader.paramLayout[ i ];
                if( !param.isMatrix )
//                {
//                    matrix = pass.getMatrix ( param.name );
//                    m_pCurDevice.setProgramConstantsFromMatrix ( Context3DProgramType.VERTEX, param.index, matrix, param.transpose );
//                }
//                else
                {
                    m_pCurDevice.setProgramConstantsFromVector( Context3DProgramType.VERTEX, param.index, pass.getVector( param.name ) );
                }
            }

            /********* frag shader param setting *********/
            paramCount = fragShader.paramLayout.length;
            for( i = 0; i < paramCount; ++i )
            {
                /** the other param **/
                param = fragShader.paramLayout[ i ];
                if( !param.isMatrix )
//                {
//                    matrix = pass.getMatrix ( param.name );
//                    m_pCurDevice.setProgramConstantsFromMatrix ( Context3DProgramType.FRAGMENT, param.index, matrix, param.transpose );
//                }
//                else
                {
                    m_pCurDevice.setProgramConstantsFromVector( Context3DProgramType.FRAGMENT, param.index, pass.getVector( param.name ) );
                }
            }

            /** texture slot setting **/
            i = 0;
            while( i < numTexture )
            {
                m_pCurDevice.setTexture( i, pass.getTexture( fragShader.textureLayout [ i ].name ) );
                ++i;
            }

            /*** draw triangls ***/
            m_pCurDevice.commitStates();
            m_pCurDevice.drawTriangles( iBuffer, rcmd.indicesOffset, rcmd.numTriangles );

            /*** clear vertex buffer ***/
            m_pCurDevice.clearVertexBuffer( 0 );
            m_pCurDevice.clearVertexBuffer( 1 );
            m_pCurDevice.clearVertexBuffer( 2 );
        }

        private function computeMVPMatrix( rcmd : IRenderCommand ) : void
        {
            var pWorldMatrix : CMatrix4 = rcmd.worldMatrix;
            var pVPMatrix : CMatrix4 = m_pCurCamera.getVPMatrix();
            MatrixUtil.matrixMultiply( pVPMatrix, pWorldMatrix, m_CurMVPMatrix );
        }
    }
}

import QFLib.QEngine.Renderer.Pipeline.ForwardRenderPipeline;

class SingletonHolder
{
    private static var _instance : ForwardRenderPipeline = new ForwardRenderPipeline();

    public static function instance() : ForwardRenderPipeline
    {
        return _instance;
    }
}
