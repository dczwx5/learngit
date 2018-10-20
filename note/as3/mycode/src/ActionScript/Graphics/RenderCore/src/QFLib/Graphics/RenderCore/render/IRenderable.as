/**
 * Created by David on 2016/9/10.
 */
package QFLib.Graphics.RenderCore.render
{
    import QFLib.Graphics.RenderCore.starling.core.RenderSupport;

    public interface IRenderable
    {
        function render(support:RenderSupport, alpha:Number):void;
    }
}
