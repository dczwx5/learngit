/**
 * Created by Cliff on 2017/5/8.
 */
package QFLib.Graphics.RenderCore.render.shader {
    import QFLib.Graphics.RenderCore.render.IFragmentShader;

public class FUVAnimation extends FBase implements IFragmentShader{

    public static const Name:String = "uvanimation.tc";

    private static const cMaskColor:String = "fc1";
    private static const cOffsetUV:String = "fc2.xy";
    private static const cZero:String = "fc2.z";
    private static const cOne:String = "fc2.w";
    private static  const cTiling:String = "fc3";
    private static const cMargin:String = "fc4";

    private static const tColor:String = "ft0";
    private static const tTemp:String = "ft1";
    private static const tTempAlpha:String = "ft1.w";
    private static const tTempUV:String = "ft2";

    public function FUVAnimation() {
        registerTex(0, mainTexture);
        registerParam(0, "color");
        registerParam(1, "maskColor");
        registerParam(2, "offsetUV");
        registerParam(3, "tilingParams");
        registerParam(4, "marginParams");
    }

    public function get name():String
    {
        return Name;
    }

    public function get code():String
    {
        return	GA.mov(tTempUV, inTexCoord) +
                GA.adds(tTempUV+".xy",cOffsetUV) +
                GA.tex(tColor,tTempUV,0) +
                //"tex " + tColor +", " + tTempUV + ", fs0 <2d,repeat>\n" +
                GA.muls(tColor+".xyz", cMaskColor + ".www") +
                GA.adds(tColor+".xyz", cMaskColor + ".xyz") +
                GA.muls(tColor, inColor) +
                //caculate horizontal alpha
                GA.mov(tTempAlpha, cZero) +
                GA.sge(tTemp+".x", inTexCoord+".x", cMargin+".x") +//satU1 = step(_MarginU,i.uv.x);
                GA.sge(tTemp+".y", inTexCoord+".x", cMargin+".y") +//satU2 = step(_TilingX-_MarginU,i.uv.x);
                GA.sub(tTemp+".z", cTiling+".x",inTexCoord+".x") +//temp += satU2*(_TilingX-i.uv.x)/_MarginU;
                GA.muls(tTemp+".z", tTemp+".y") +
                GA.divs(tTemp+".z",cMargin+".x") +
                GA.adds(tTempAlpha, tTemp+".z") +
                GA.sub(tTemp+".z", tTemp+".x", tTemp+".y") +//temp += (satU1-satU2)*1.0
                GA.adds(tTempAlpha, tTemp+".z") +
                GA.sub(tTemp+".z", cOne,tTemp+".x") +//temp += (1-satU1)*i.uv.x/_MarginU
                GA.muls(tTemp+".z", inTexCoord+".x") +
                GA.divs(tTemp+".z", cMargin+".x") +
                GA.adds(tTempAlpha, tTemp+".z") +
                GA.muls(tColor+".w", tTempAlpha) +//col.w *= temp
                //caculate vertical alpha
                GA.mov(tTempAlpha, cZero) +
                GA.sge(tTemp+".x", inTexCoord+".y", cMargin+".z") +//satV1 = step(_MarginV,i.uv.y);
                GA.sge(tTemp+".y", inTexCoord+".y", cMargin+".w") +//satV2 = step(_TilingY-_MarginV,i.uv.y);
                GA.sub(tTemp+".z", cTiling+".y", inTexCoord+".y") +//temp += satV2*(_TilingY-i.uv.y)/_MarginV;
                GA.muls(tTemp+".z", tTemp+".y") +
                GA.divs(tTemp+".z", cMargin+".z") +
                GA.adds(tTempAlpha, tTemp+".z") +
                GA.sub(tTemp+".z", tTemp+".x", tTemp+".y") +//temp += (satU1-satU2)*1.0
                GA.adds(tTempAlpha, tTemp+".z") +
                GA.sub(tTemp+".z", cOne, tTemp+".x") +//temp += (1-satV1)*i.uv.y/_MarginV;
                GA.muls(tTemp+".z", inTexCoord+".y") +
                GA.divs(tTemp+".z", cMargin+".z") +
                GA.adds(tTempAlpha, tTemp+".z") +
                GA.muls(tColor+".w", tTempAlpha) +//col.w *= temp
                GA.muls(tColor+".xyz", tColor+".w") +
                GA.mov(outColor, tColor);
    }
}
}
