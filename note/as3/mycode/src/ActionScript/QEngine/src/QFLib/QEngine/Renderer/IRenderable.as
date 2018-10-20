/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/3/18.
 */
package QFLib.QEngine.Renderer
{
    public interface IRenderable
    {
        function getRenderCommand( cmd : IRenderCommand ) : void;
    }
}
