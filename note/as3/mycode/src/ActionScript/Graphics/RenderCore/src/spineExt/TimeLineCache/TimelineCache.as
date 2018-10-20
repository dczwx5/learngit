/**
 * Created by Burgess on 2017/9/14.
 *
 * use : cache animation timeline all frame data.
 * when FrameCacheEnabled == true, every frame will be cached when first calculated;
 *
 * its not used current because of the cost of memory; it will cost pretty memory. so if you would like to use it,
 * your game memory must not be big. or you can take some special strategy .
 *
 * this will improve the efficiency about 1/4 to 1/3;
 */
package spineExt.TimeLineCache {

public class TimelineCache {
    public function TimelineCache() {
    }

    static public const FrameGap : Number = 1.0/60.0;
    static public var FrameCacheEnabled : Boolean = false;

    public static function getFrameIndex(duration:Number):int
    {
        var frameIndex:int = int((duration + 0.00001)/ FrameGap) - 1;
        return frameIndex < 0 ? 0 : frameIndex;
    }
}
}
