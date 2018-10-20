/**
 * Created by auto
 */
package core.pathing {

public interface IPathingFacade {
    //
    function findPath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array ;
    function findReversePath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array ;

}
}
